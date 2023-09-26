require 'rails_helper'
require 'sidekiq/testing'
RAILS_ENV='development'

describe TransactionController do
  before :each do
    @account = create(:account, balance: 1000)
    @user = @account.user
    @mop = create(:mop, account: @account, user: @user)
    sign_in(@user)
  end

  # it 'index api should return all transactions' do
  #   create(:transaction)
  #   get :index
  #   resp = Oj.load(response.body)
  #   expect(resp.length).to eq 2
  # end

  context 'Transaction_debit#create:' do

    it 'throw error if mop_id is invalid' do
      post :debit, params: { amount: 100, mop_id: 1000 }
      validate_error_response(response, 400, 'mop_id or account_id is invalid')
    end

    it 'throw error if mop_id is invalid' do
      post :debit, params: { amount: 100 }
      validate_error_response(response, 400, 'Either mop_id or account_id must be sent in request')
    end

    it 'throw error if account_id is invalid' do
      post :debit, params: { amount: 100, account_id: 100 }
      validate_error_response(response, 400, 'mop_id or account_id is invalid')
    end

    it 'creates new debit transaction' do
      post :debit, params: { amount: 100, mop_id: @mop.id }
      resp = Oj.load(response.body)
      transaction = Transaction.find_by_id(resp['id'])
      validate_response(response, 200, 'Debit Transaction added')
      get :index
      resp = Oj.load(response.body)
      expect(resp.length).to eq 2
      bal = @account.balance
      expect(@account.reload.balance).to eq(bal - 100)
      expect([transaction.balance_before, transaction.balance_after]).to eq([bal, bal-100])
      log = @account.daily_logs.find_by_date(transaction.date)
      expect(log.meta['tr_ids'].include? transaction.id).to eq true
      expect([log.opening_balance, log.closing_balance]).to eq([0, 900])
    end

    it 'creates new debit transaction using debitcard' do
      @card = create(:card, account: @account, ctype: DEBITCARD, user: @user)
      post :debit, params: { amount: 100, card_id: @card.id }
      resp = Oj.load(response.body)
      transaction = Transaction.find_by_id(resp['id'])
      validate_response(response, 200, 'Debit Transaction added')
      get :index
      resp = Oj.load(response.body)
      expect(resp.length).to eq 2
      bal = @account.balance
      expect(@account.reload.balance).to eq(bal - 100)
      expect([transaction.balance_before, transaction.balance_after]).to eq([bal, bal-100])
      log = @account.daily_logs.find_by_date(transaction.date)
      expect(log.meta['tr_ids'].include? transaction.id).to eq true
      expect([log.opening_balance, log.closing_balance]).to eq([0, 900])
    end

    it 'creates new debit transaction using creditcard' do
      @card = create(:card, ctype: CREDITCARD, user: @user)
      post :debit, params: { amount: 100, card_id: @card.id }
      resp = Oj.load(response.body)
      transaction = Transaction.find_by_id(resp['id'])
      validate_response(response, 200, 'Debit Transaction added')
      get :index
      resp = Oj.load(response.body)
      expect(resp.length).to eq 2
      @account = @card.account
      bal = @account.balance
      expect(@account.reload.balance).to eq(bal - 100)
      expect([transaction.balance_before, transaction.balance_after]).to eq([bal, bal-100])
      log = @account.daily_logs.find_by_date(transaction.date)
      expect(log.meta['tr_ids'].include? transaction.id).to eq true
      expect([log.opening_balance, log.closing_balance]).to eq([0, -100])
      expect(@card.reload.outstanding_bill).to eq 100
    end

    it 'throw error if transaction date is before account opening' do
      post :debit, params: { amount: 100, mop_id: @mop.id, date: Date.today - 2 }
      validate_response(response, 202, "Cannot add a transaction in past date of account opening")
    end

    it 'create multiple debit transactions and ensure subsequent transactions are updated' do
      bal = @account.balance
      Sidekiq::Testing.inline! do
        tr0 = create(:transaction, amount: 50, mop: @mop, date: Date.today + 2)
        expect([tr0.balance_before, tr0.balance_after]).to eq([1000, 950])
        tr1 = create(:transaction, amount: 50, mop: @mop, date: Date.today + 2)
        expect([tr1.balance_before, tr1.balance_after]).to eq([950, 900])
        tr2 = create(:transaction, amount: 200, mop: @mop, date: Date.today + 1)
        expect([tr2.balance_before, tr2.balance_after]).to eq([1000, 800])
        expect([tr1.reload.balance_before, tr1.balance_after]).to eq([750, 700])
        tr3 = create(:transaction, amount: 300, mop: @mop, date: Date.today )
        expect([tr1.reload.balance_before, tr1.balance_after]).to eq([450, 400])
        expect([tr2.reload.balance_before, tr2.balance_after]).to eq([700, 500])
        expect([tr3.reload.balance_before, tr3.balance_after]).to eq([1000, 700])
      end
      expect(@account.reload.balance).to eq(bal - 600)
    end

    it 'create multiple debit transactions and ensure subsequent daily_logs are updated' do
      bal = @account.balance
      Sidekiq::Testing.inline! do
        # tr1 = create(:transaction, amount: 100, mop: @mop, date: Date.today + 2)
        post :debit, params: { amount: 100, mop_id: @mop.id, date: Date.today+2}
        log = @account.daily_logs.find_by_date(Date.today+2)
        expect([log.opening_balance, log.closing_balance]).to eq([1000,900])
        post :debit, params: { amount: 200, mop_id: @mop.id, date: Date.today+1 }
        # tr2 = create(:transaction, amount: 200, mop: @mop, date: Date.today + 1)
        log2 = @account.daily_logs.find_by_date(Date.today+1)
        expect([log2.opening_balance, log2.closing_balance]).to eq([1000,800])
        expect([log.reload.opening_balance, log.closing_balance]).to eq([800,700])
        # tr3 = create(:transaction, amount: 300, mop: @mop, date: Date.today )
        post :debit, params: { amount: 300, mop_id: @mop.id, date: Date.today }
        log3 = @account.daily_logs.find_by_date(Date.today)
        expect([log3.opening_balance, log3.closing_balance]).to eq([0,700])
        expect([log2.reload.opening_balance, log2.closing_balance]).to eq([700,500])
        expect([log.reload.opening_balance, log.closing_balance]).to eq([500,400])
      end
      expect(@account.reload.balance).to eq(bal - 600)
    end

  end

  context 'Transaction_credit#create:' do

    it 'throw error if account_id is invalid' do
      post :credit, params: { amount: 100, account_id: 1000 }
      validate_error_response(response, 400, 'account not found')
    end

    it 'throw error if account_id is not sent' do
      post :credit, params: { amount: 100 }
      validate_error_response(response, 400, 'account not found')
    end

    it 'creates new credit transaction' do
      post :credit, params: { amount: 100, account_id: @account.id }
      resp = Oj.load(response.body)
      transaction = Transaction.find_by_id(resp['id'])
      validate_response(response, 200, 'Credit Transaction added')
      get :index
      resp = Oj.load(response.body)
      expect(resp.length).to eq 2
      bal = @account.balance
      expect(@account.reload.balance).to eq(bal + 100)
      expect([transaction.balance_before, transaction.balance_after]).to eq([bal, bal+100])
      log = @account.daily_logs.find_by_date(transaction.date)
      expect(log.meta['tr_ids'].include? transaction.id).to eq true
      expect([log.opening_balance, log.closing_balance]).to eq([0, 1100])
    end

    it 'create multiple credit transactions and ensure subsequent transactions are updated' do
      bal = @account.balance
      Sidekiq::Testing.inline! do
        tr0 = create(:transaction, ttype: CREDIT, amount: 50, account: @account, user: @user, date: Date.today + 2)
        expect([tr0.balance_before, tr0.balance_after]).to eq([1000, 1050])
        tr1 = create(:transaction, ttype: CREDIT, amount: 50, account: @account, user: @user, date: Date.today + 2)
        expect([tr1.balance_before, tr1.balance_after]).to eq([1050, 1100])
        tr2 = create(:transaction, ttype: CREDIT, amount: 200, account: @account, user: @user, date: Date.today + 1)
        expect([tr2.balance_before, tr2.balance_after]).to eq([1000, 1200])
        expect([tr1.reload.balance_before, tr1.balance_after]).to eq([1250, 1300])
        tr3 = create(:transaction, ttype: CREDIT, amount: 300, account: @account, user: @user, date: Date.today )
        expect([tr1.reload.balance_before, tr1.balance_after]).to eq([1550, 1600])
        expect([tr2.reload.balance_before, tr2.balance_after]).to eq([1300, 1500])
        expect([tr3.reload.balance_before, tr3.balance_after]).to eq([1000, 1300])
      end
      expect(@account.reload.balance).to eq(bal + 600)
    end

    it 'create multiple debit transactions and ensure subsequent daily_logs are updated' do
      bal = @account.balance
      Sidekiq::Testing.inline! do
        # tr1 = create(:transaction, amount: 100, mop: @mop, date: Date.today + 2)
        post :credit, params: { amount: 100, account_id: @account.id, date: Date.today+2}
        log = @account.daily_logs.find_by_date(Date.today+2)
        expect([log.opening_balance, log.closing_balance]).to eq([1000,1100])
        post :credit, params: { amount: 200, account_id: @account.id, date: Date.today+1 }
        # tr2 = create(:transaction, amount: 200, mop: @mop, date: Date.today + 1)
        log2 = @account.daily_logs.find_by_date(Date.today+1)
        expect([log2.opening_balance, log2.closing_balance]).to eq([1000,1200])
        expect([log.reload.opening_balance, log.closing_balance]).to eq([1200,1300])
        # tr3 = create(:transaction, amount: 300, mop: @mop, date: Date.today )
        post :credit, params: { amount: 300, account_id: @account.id, date: Date.today }
        log3 = @account.daily_logs.find_by_date(Date.today)
        expect([log3.opening_balance, log3.closing_balance]).to eq([0,1300])
        expect([log2.reload.opening_balance, log2.closing_balance]).to eq([1300,1500])
        expect([log.reload.opening_balance, log.closing_balance]).to eq([1500,1600])
      end
      expect(@account.reload.balance).to eq(bal + 600)
    end
  end

  context 'Transactions_mix#create' do
    it 'should handle credit and debit in order' do
      bal = @account.balance
      Sidekiq::Testing.inline! do
        tr0 = create(:transaction, ttype: CREDIT, amount: 300, account: @account, user: @user, date: Date.today)
        tr1 = create(:transaction, ttype: DEBIT, amount: 100, mop: @mop, user: @user, date: Date.today)
        tr2 = create(:transaction, ttype: DEBIT, amount: 50, mop: @mop, user: @user, date: Date.today+1)
        tr3 = create(:transaction, ttype: CREDIT, amount: 100, account: @account, user: @user, date: Date.today+1)
        tr4 = create(:transaction, ttype: DEBIT, amount: 200, mop: @mop, user: @user, date: Date.today+1)
        tr5 = create(:transaction, ttype: DEBIT, amount: 300, mop: @mop, user: @user, date: Date.today+2)

        expect([tr0.reload.balance_before, tr0.balance_after]).to eq([1000, 1300])
        expect([tr1.reload.balance_before, tr1.balance_after]).to eq([1300, 1200])
        expect([tr2.reload.balance_before, tr2.balance_after]).to eq([1200, 1150])
        expect([tr3.reload.balance_before, tr3.balance_after]).to eq([1150, 1250])
        expect([tr4.reload.balance_before, tr4.balance_after]).to eq([1250, 1050])
        expect([tr5.reload.balance_before, tr5.balance_after]).to eq([1050, 750])
      end
      expect(@account.reload.balance).to eq(750)
    end

    it 'should handle credit and debit in jumbled order' do
      bal = @account.balance
      Sidekiq::Testing.inline! do
        tr2 = create(:transaction, ttype: DEBIT, amount: 50, mop: @mop, user: @user, date: Date.today+1)
        tr5 = create(:transaction, ttype: DEBIT, amount: 300, mop: @mop, user: @user, date: Date.today+2)
        tr0 = create(:transaction, ttype: CREDIT, amount: 300, account: @account, user: @user, date: Date.today)
        tr3 = create(:transaction, ttype: CREDIT, amount: 100, account: @account, user: @user, date: Date.today+1)
        tr1 = create(:transaction, ttype: DEBIT, amount: 100, mop: @mop, user: @user, date: Date.today)
        tr4 = create(:transaction, ttype: DEBIT, amount: 200, mop: @mop, user: @user, date: Date.today+1)

        expect([tr0.reload.balance_before, tr0.balance_after]).to eq([1000, 1300])
        expect([tr1.reload.balance_before, tr1.balance_after]).to eq([1300, 1200])
        expect([tr2.reload.balance_before, tr2.balance_after]).to eq([1200, 1150])
        expect([tr3.reload.balance_before, tr3.balance_after]).to eq([1150, 1250])
        expect([tr4.reload.balance_before, tr4.balance_after]).to eq([1250, 1050])
        expect([tr5.reload.balance_before, tr5.balance_after]).to eq([1050, 750])
      end
      expect(@account.reload.balance).to eq(750)
    end
  end

  context 'Transaction:paid_by_party' do
    
    it 'throw error if party is invalid' do
      post :paid_by_party, params: { amount: 100 , party: 100}
      validate_response(response, 202, 'party not found')
    end

    it 'throw error if party is not sent' do
      post :paid_by_party, params: { amount: 100 }
      validate_response(response, 202, 'party not found')
    end

    it 'should create a paid_by_party transaction' do
      account = create(:account, owed: true, user: @user)
      post :paid_by_party, params: { amount: 73 , party: account.id}
      validate_response(response, 200, "Paid by party Transaction added")
      expect(account.reload.balance).to eq -73
      expect(account.owed_transactions.last.amount).to eq 73
    end

  end

  context 'Transaction:paid_by_you' do
    
    it 'throw error if party is invalid' do
      post :paid_by_you, params: { amount: 100 , party: 100}
      validate_response(response, 202, 'party not found')
    end

    it 'throw error if party is not sent' do
      post :paid_by_you, params: { amount: 100 }
      validate_response(response, 202, 'party not found')
    end

    it 'should create a paid_by_you transaction' do
      account = create(:account, owed: true, user: @user)
      post :paid_by_you, params: { amount: 73 , party: account.id, mop_id: @mop.id}
      validate_response(response, 200, "Paid by you Transaction added")
      expect(@mop.reload.account.balance).to eq 927
      log1 = @mop.account.daily_logs.find_by_date(Date.today)
      expect([log1.opening_balance, log1.closing_balance]).to eq([0,927])

      expect(account.reload.balance).to eq 73
      expect(account.owed_transactions[-1].amount).to eq 73
      log2 = account.daily_logs.find_by_date(Date.today)
      expect([log2.opening_balance, log2.closing_balance]).to eq([0,73])
    end

  end

  context 'Transaction:settled_by_party' do

    it 'throw error if party is invalid' do
      post :settled_by_party, params: { amount: 100 , party: 100, account_id: @account.id}
      validate_response(response, 202, 'party not found')
    end

    it 'throw error if party and account is not sent' do
      post :settled_by_party, params: { amount: 100 }
      validate_response(response, 202, 'account not found')
    end

    it 'throw error if party is not sent' do
      post :settled_by_party, params: { amount: 100 , account_id: @account.id}
      validate_response(response, 202, 'party not found')
    end

    it 'throw error if account is invalid' do
      account = create(:account, owed: true, user: @user)
      post :settled_by_party, params: { amount: 100 , party: account.id, account_id: 1001}
      validate_response(response, 202, 'account not found')
    end

    it 'should create a settled_by_party transaction' do
      account = create(:account, owed: true, user: @user)
      post :settled_by_party, params: { amount: 80 , party: account.id, account_id: @account.id}
      validate_response(response, 200, "Settled by party Transaction added")
      expect(@account.reload.balance).to eq 1080
      log1 = @account.daily_logs.find_by_date(Date.today)
      expect([log1.opening_balance, log1.closing_balance]).to eq([0,1080])

      expect(account.reload.balance).to eq -80
      expect(account.owed_transactions.last.amount).to eq 80
      log2 = account.daily_logs.find_by_date(Date.today)
      expect([log2.opening_balance, log2.closing_balance]).to eq([0,-80])
    end
  end

  context 'Transaction:settled_by_you' do

    it 'throw error if party is invalid' do
      post :settled_by_you, params: { amount: 100 , party: 100, account_id: @account.id}
      validate_response(response, 202, 'party not found')
    end

    it 'throw error if mop or account is not sent' do
      account = create(:account, owed: true, user: @user)
      post :settled_by_you, params: { amount: 100 , party: account.id }
      validate_response(response, 202, 'Either mop_id or account_id must be sent in request')
    end

    it 'throw error if mop or account is invalid' do
      account = create(:account, owed: true, user: @user)
      post :settled_by_you, params: { amount: 100 , party: account.id, account_id: 1001}
      validate_response(response, 202, 'mop_id or account_id is invalid')
    end

    it 'should create a settled_by_you transaction' do
      account = create(:account, owed: true, user: @user)
      post :settled_by_you, params: { amount: 80 , party: account.id, account_id: @account.id}
      validate_response(response, 200, "Settled by you Transaction added")
      expect(@account.reload.balance).to eq 920
      log1 = @account.daily_logs.find_by_date(Date.today)
      expect([log1.opening_balance, log1.closing_balance]).to eq([0,920])

      expect(account.reload.balance).to eq 80
      expect(account.owed_transactions.last.amount).to eq 80
      log2 = account.daily_logs.find_by_date(Date.today)
      expect([log2.opening_balance, log2.closing_balance]).to eq([0,80])
    end
  end

  context 'Split#create' do
    it 'should throw error when money does not add up in a split transaction' do
      owed1 = create(:account, user: @user, owed: true, name: 'owed1')
      tr_array = [
        {
          "party": owed1.id,
          "amount": 30,
        },
        {
          "amount": 80,
          "user": true,
        }
      ]
      post :split, params: { amount: 100, account_id: @account.id, transactions: tr_array }
      validate_response(response, 202, "Sum does not add up to the amount 100")
    end

    it 'should create a split transaction' do
      owed1 = create(:account, user: @user, owed: true, name: 'owed1')
      tr_array = [
        {
          "party": owed1.id,
          "amount": 20,
        },
        {
          "amount": 80,
          "user": true,
        }
      ]
      Sidekiq::Testing.inline! do
        post :split, params: { amount: 100, account_id: @account.id, transactions: tr_array }
        validate_response(response, 200, "Split transactions will be added")
        expect(owed1.reload.balance).to eq 20
        expect(@account.reload.balance).to eq 900
      end
    end

    it 'should add only for others' do
      owed1 = create(:account, user: @user, owed: true, name: 'owed1')
      owed2 = create(:account, user: @user, owed: true, name: 'owed2')
      tr_array = [
        {
          "party": owed1.id,
          "amount": 20,
        },
        {
          "party": owed2.id,
          "amount": 80,
        }
      ]
      Sidekiq::Testing.inline! do
        post :split, params: { amount: 100, account_id: @account.id, transactions: tr_array }
        validate_response(response, 200, "Split transactions will be added")
        expect(owed1.reload.balance).to eq 20
        expect(owed2.reload.balance).to eq 80
        expect(@account.reload.balance).to eq 900
      end
    end

  end

end