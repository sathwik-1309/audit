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

    # it 'throw error if mop_id is invalid' do
    #   post :debit, params: { amount: 100, account_id: 12000 }
    #   validate_response(response, 202, 'mop_id or account_id is invalid')
    # end

    # it 'throw error if mop_id is invalid' do
    #   post :debit, params: { amount: 100 }
    #   validate_response(response, 202, 'Either mop_id or account_id must be sent in request')
    # end

    # it 'throw error if account_id is invalid' do
    #   post :debit, params: { amount: 100, account_id: 100 }
    #   validate_response(response, 202, 'mop_id or account_id is invalid')
    # end

    it 'creates new debit transaction' do
      post :debit, params: { amount: 100, mop_id: @mop.id, account_id: @account.id }
      resp = Oj.load(response.body)
      transaction = Transaction.find_by_id(resp['id'])
      validate_response(response, 200, 'Debit Transaction added')
      expect(@account.transactions.count).to eq 2
      bal = @account.balance
      expect(@account.reload.balance).to eq(bal - 100)
      expect([transaction.balance_before, transaction.balance_after]).to eq([bal, bal-100])
    end

    it 'creates new debit transaction using debitcard' do
      @card = create(:card, account: @account, ctype: DEBITCARD, user: @user)
      post :debit, params: { amount: 100, card_id: @card.id }
      resp = Oj.load(response.body)
      transaction = Transaction.find_by_id(resp['id'])
      validate_response(response, 200, 'Debit Transaction added')
      expect(@account.transactions.count).to eq 2
      bal = @account.balance
      expect(@account.reload.balance).to eq(bal - 100)
      expect([transaction.balance_before, transaction.balance_after]).to eq([bal, bal-100])
    end

    it 'creates new debit transaction using creditcard' do
      @card = create(:card, ctype: CREDITCARD, user: @user)
      post :debit, params: { amount: 100, card_id: @card.id }
      resp = Oj.load(response.body)
      transaction = Transaction.find_by_id(resp['id'])
      validate_response(response, 200, 'Debit Transaction added')
      expect(@card.account.transactions.count).to eq 2
      @account = @card.account
      bal = @account.balance
      expect(@account.reload.balance).to eq(bal - 100)
      expect([transaction.balance_before, transaction.balance_after]).to eq([bal, bal-100])
      expect(@card.reload.outstanding_bill).to eq 100
    end

    # it 'throw error if transaction date is before account opening' do
    #   post :debit, params: { amount: 100, mop_id: @mop.id, date: Date.today - 2 }
    #   validate_response(response, 202, "Cannot add a transaction in past date of account opening")
    # end

    it 'create multiple debit transactions and ensure subsequent transactions are updated' do
      bal = @account.balance
      Sidekiq::Testing.inline! do
        tr0 = create(:transaction, amount: 50, account: @account, date: Date.today + 2)
        expect([tr0.balance_before, tr0.balance_after]).to eq([1000, 950])
        tr1 = create(:transaction, amount: 50, account: @account, date: Date.today + 2)
        expect([tr1.balance_before, tr1.balance_after]).to eq([950, 900])
        tr2 = create(:transaction, amount: 200, account: @account, date: Date.today + 1)
        expect([tr2.balance_before, tr2.balance_after]).to eq([1000, 800])
        expect([tr1.reload.balance_before, tr1.balance_after]).to eq([750, 700])
        tr3 = create(:transaction, amount: 300, account: @account, date: Date.today )
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
        post :debit, params: { amount: 100, account_id: @account.id, date: Date.today+2}
        post :debit, params: { amount: 200, account_id: @account.id, date: Date.today+1 }
        # tr2 = create(:transaction, amount: 200, mop: @mop, date: Date.today + 1)
        # tr3 = create(:transaction, amount: 300, mop: @mop, date: Date.today )
        post :debit, params: { amount: 300, account_id: @account.id, date: Date.today }
      end
      expect(@account.reload.balance).to eq(bal - 600)
    end

  end

  context 'Transaction_credit#create:' do

    it 'throw error if account_id is invalid' do
      post :credit, params: { amount: 100, account_id: 1000 }
      validate_response(response, 202, 'account not found')
    end

    it 'throw error if account_id is not sent' do
      post :credit, params: { amount: 100 }
      validate_response(response, 202, 'account not found')
    end

    it 'creates new credit transaction' do
      post :credit, params: { amount: 100, account_id: @account.id }
      resp = Oj.load(response.body)
      transaction = Transaction.find_by_id(resp['id'])
      validate_response(response, 200, 'Credit Transaction added')
      get :index
      resp = Oj.load(response.body)
      expect(resp.length).to eq 9
      bal = @account.balance
      expect(@account.reload.balance).to eq(bal + 100)
      expect([transaction.balance_before, transaction.balance_after]).to eq([bal, bal+100])
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
        post :credit, params: { amount: 200, account_id: @account.id, date: Date.today+1 }
        post :credit, params: { amount: 300, account_id: @account.id, date: Date.today }
      end
      expect(@account.reload.balance).to eq(bal + 600)
    end
  end

  context 'Transactions_mix#create' do
    it 'should handle credit and debit in order' do
      bal = @account.balance
      Sidekiq::Testing.inline! do
        tr0 = create(:transaction, ttype: CREDIT, amount: 300, account: @account, user: @user, date: Date.today)
        tr1 = create(:transaction, ttype: DEBIT, amount: 100, account: @account, user: @user, date: Date.today)
        tr2 = create(:transaction, ttype: DEBIT, amount: 50, account: @account, user: @user, date: Date.today+1)
        tr3 = create(:transaction, ttype: CREDIT, amount: 100, account: @account, user: @user, date: Date.today+1)
        tr4 = create(:transaction, ttype: DEBIT, amount: 200, account: @account, user: @user, date: Date.today+1)
        tr5 = create(:transaction, ttype: DEBIT, amount: 300, account: @account, user: @user, date: Date.today+2)

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
        tr2 = create(:transaction, ttype: DEBIT, amount: 50, account: @account, user: @user, date: Date.today+1)
        tr5 = create(:transaction, ttype: DEBIT, amount: 300, account: @account, user: @user, date: Date.today+2)
        tr0 = create(:transaction, ttype: CREDIT, amount: 300, account: @account, user: @user, date: Date.today)
        tr3 = create(:transaction, ttype: CREDIT, amount: 100, account: @account, user: @user, date: Date.today+1)
        tr1 = create(:transaction, ttype: DEBIT, amount: 100, account: @account, user: @user, date: Date.today)
        tr4 = create(:transaction, ttype: DEBIT, amount: 200, account: @account, user: @user, date: Date.today+1)

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
      post :paid_by_you, params: { amount: 73 , party: account.id, account_id: @account.id}
      validate_response(response, 200, "Paid by you Transaction added")
      expect(@account.reload.balance).to eq 927
      expect(account.reload.balance).to eq 73
      expect(account.owed_transactions[-1].amount).to eq 73
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
      expect(account.reload.balance).to eq -80
      expect(account.owed_transactions.last.amount).to eq 80
    end
  end

  context 'Transaction:settled_by_you' do

    it 'throw error if party is invalid' do
      post :settled_by_you, params: { amount: 100 , party: 100, account_id: @account.id}
      validate_response(response, 202, 'party not found')
    end

    # it 'throw error if mop or account is not sent' do
    #   account = create(:account, owed: true, user: @user)
    #   post :settled_by_you, params: { amount: 100 , party: account.id }
    #   validate_response(response, 202, 'Either mop_id or account_id must be sent in request')
    # end

    # it 'throw error if mop or account is invalid' do
    #   account = create(:account, owed: true, user: @user)
    #   post :settled_by_you, params: { amount: 100 , party: account.id, account_id: 1001}
    #   validate_response(response, 202, 'mop_id or account_id is invalid')
    # end

    it 'should create a settled_by_you transaction' do
      account = create(:account, owed: true, user: @user)
      post :settled_by_you, params: { amount: 80 , party: account.id, account_id: @account.id}
      validate_response(response, 200, "Settled by you Transaction added")
      expect(@account.reload.balance).to eq 920
      expect(account.reload.balance).to eq 80
      expect(account.owed_transactions.last.amount).to eq 80
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
          "amount": "20",
        },
        {
          "party": owed2.id,
          "amount": "80",
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

  context 'sequences' do
    it 'add a future transaction' do
      user = create(:user, name: 'new_user')
      acc1 = user.accounts.find_by_name('Account 1')
      sign_in(user)
      Sidekiq::Testing.inline! do
        post :debit, params: { amount: 100, account_id: acc1.id, comments: 'trans1' }
        tr1 = acc1.transactions.find_by(comments: 'trans1')
        post :debit, params: { amount: 200, account_id: acc1.id, comments: 'trans2' }
        tr2 = acc1.transactions.find_by(comments: 'trans2')
        post :debit, params: { amount: 150, account_id: acc1.id, comments: 'trans3', date: Date.today+1 }
        tr3 = acc1.transactions.find_by(comments: 'trans3')
        expect([tr1.reload.balance_before, tr1.balance_after]).to eq [800, 700]
        expect([tr2.reload.balance_before, tr2.balance_after]).to eq [700, 500]
        expect([tr3.reload.balance_before, tr3.balance_after]).to eq [500, 350]
      end
    end

    it 'add a future transaction 2' do
      user = create(:user, name: 'new_user')
      acc1 = user.accounts.find_by_name('Account 1')
      sign_in(user)
      Sidekiq::Testing.inline! do
        post :debit, params: { amount: 100, account_id: acc1.id, comments: 'trans1' }
        tr1 = acc1.transactions.find_by(comments: 'trans1')
        post :debit, params: { amount: 150, account_id: acc1.id, comments: 'trans3', date: Date.today+1 }
        tr3 = acc1.transactions.find_by(comments: 'trans3')
        post :debit, params: { amount: 200, account_id: acc1.id, comments: 'trans2' }
        tr2 = acc1.transactions.find_by(comments: 'trans2')
        post :debit, params: { amount: 200, account_id: acc1.id, comments: 'trans4', date: Date.today-2 }
        tr4 = acc1.transactions.find_by(comments: 'trans4')
        expect([tr4.reload.balance_before, tr4.balance_after]).to eq [1200, 1000]
        expect([tr1.reload.balance_before, tr1.balance_after]).to eq [800, 700]
        expect([tr2.reload.balance_before, tr2.balance_after]).to eq [700, 500]
        expect([tr3.reload.balance_before, tr3.balance_after]).to eq [500, 350]
        
      end
    end

    it 'add few and delete a transaction' do
      user = create(:user, name: 'new_user')
      acc1 = user.accounts.find_by_name('Account 1')
      sign_in(user)
      Sidekiq::Testing.inline! do
        post :debit, params: { amount: 100, account_id: acc1.id, comments: 'trans1' }
        tr1 = acc1.transactions.find_by(comments: 'trans1')
        post :debit, params: { amount: 200, account_id: acc1.id, comments: 'trans2' }
        tr2 = acc1.transactions.find_by(comments: 'trans2')
        post :debit, params: { amount: 150, account_id: acc1.id, comments: 'trans3', date: Date.today+1 }
        tr3 = acc1.transactions.find_by(comments: 'trans3')
        expect([tr1.reload.balance_before, tr1.balance_after]).to eq [800, 700]
        expect([tr2.reload.balance_before, tr2.balance_after]).to eq [700, 500]
        expect([tr3.reload.balance_before, tr3.balance_after]).to eq [500, 350]
        delete :delete, params: { id: tr1.id }
        expect([tr2.reload.balance_before, tr2.balance_after]).to eq [800, 600]
        expect([tr3.reload.balance_before, tr3.balance_after]).to eq [600, 450]
      end
    end

    it 'add few and delete a transaction 2' do
      user = create(:user, name: 'new_user')
      acc1 = user.accounts.find_by_name('Account 1')
      sign_in(user)
      Sidekiq::Testing.inline! do
        post :debit, params: { amount: 100, account_id: acc1.id, comments: 'trans1' }
        tr1 = acc1.transactions.find_by(comments: 'trans1')
        post :credit, params: { amount: 200, account_id: acc1.id, comments: 'trans2' }
        tr2 = acc1.transactions.find_by(comments: 'trans2')
        post :debit, params: { amount: 150, account_id: acc1.id, comments: 'trans3', date: Date.today+1 }
        tr3 = acc1.transactions.find_by(comments: 'trans3')
        expect([tr1.reload.balance_before, tr1.balance_after]).to eq [800, 700]
        expect([tr2.reload.balance_before, tr2.balance_after]).to eq [700, 900]
        expect([tr3.reload.balance_before, tr3.balance_after]).to eq [900, 750]
        delete :delete, params: { id: tr2.id }
        expect([tr1.reload.balance_before, tr1.balance_after]).to eq [800, 700]
        expect([tr3.reload.balance_before, tr3.balance_after]).to eq [700, 550]
      end
    end

    it 'add few and delete a transaction for split' do
      user = create(:user, name: 'new_user')
      acc1 = user.accounts.find_by_name('Account 1')
      owed1 = create(:account, user: user, owed: true, name: 'owed1')
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
      sign_in(user)
      Sidekiq::Testing.inline! do
        post :split, params: { amount: 100, account_id: acc1.id, comments: 'trans1', transactions: tr_array }
        expect(owed1.reload.balance).to eq 20
        tr1 = acc1.transactions.find_by(comments: 'trans1', ttype: SPLIT)
        post :debit, params: { amount: 200, account_id: acc1.id, comments: 'trans2' }
        tr2 = acc1.transactions.find_by(comments: 'trans2')
        post :debit, params: { amount: 150, account_id: acc1.id, comments: 'trans3', date: Date.today+1 }
        tr3 = acc1.transactions.find_by(comments: 'trans3')
        expect([tr1.reload.balance_before, tr1.balance_after]).to eq [800, 700]
        expect([tr2.reload.balance_before, tr2.balance_after]).to eq [700, 500]
        expect([tr3.reload.balance_before, tr3.balance_after]).to eq [500, 350]
        delete :delete, params: { id: tr1.id }
        expect([tr2.reload.balance_before, tr2.balance_after]).to eq [800, 600]
        expect([tr3.reload.balance_before, tr3.balance_after]).to eq [600, 450]
        expect(owed1.reload.balance).to eq 0
        expect(owed1.transactions.count).to eq 1
        expect(acc1.transactions.count). to eq 4
      end
    end
  end

end