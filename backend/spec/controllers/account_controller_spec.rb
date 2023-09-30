require 'rails_helper'

describe AccountController do
  before :each do
    @account = create(:account, balance: 1000)
    @user = @account.user
    sign_in(@user)
  end

  it 'index api should return all accounts' do
    create(:account, user_id: @account.user_id)
    get :index
    resp = Oj.load(response.body)
    expect(resp.length).to eq 2
  end

  context 'Account#create:' do

    it 'creates new account' do
      post :create, params: { name: 'new_account', balance: 1000 }
      validate_response(response, 200, 'Account created')
      resp = Oj.load(response.body)
      expect(resp['balance']).to eq 1000
      expect(resp['owed']).to eq false
    end

    it 'creates new owed account' do
        post :create_owed, params: { name: 'Somename' }
        validate_response(response, 200, 'Owed Account created')
        resp = Oj.load(response.body)
        expect(resp['balance']).to eq 0
        expect(resp['owed']).to eq true
        expect(resp['name']).to eq 'Somename'
      end

    it 'returns 400 when tried to create account without name without name' do
      post :create, params: { balance: 1000, owed: true }
      validate_error_response(response, 400, "SQLite3::ConstraintException: NOT NULL constraint failed: accounts.name")
    end

    it 'sends websocket message on account create' do
      expect { post :create, params: { name: 'new_account', balance: 1000, owed: true } }.to have_broadcasted_to(ACCOUNTS_CHANNEL)
                                                                .with(a_hash_including())
    end

  end

  context 'Account#update:' do

    it 'update account' do
      put :update, params: {id: @account.id, name: 'new_name' }
      validate_response(response, 200, 'Account updated')
      resp = Oj.load(response.body)
      expect(resp['name']).to eq 'new_name'
      expect(@account.reload.name).to eq 'new_name'
    end

  end

  context 'Account#delete:' do

    it 'delete account' do
      delete :delete, params: {id: @account.id }
      validate_response(response, 200, 'Account deleted')
      get :index
      expect(Oj.load(response.body).length).to eq 0
    end

  end

  context 'Account#home:' do

    it 'check response of home api' do
      get :home, params: {}
      validate_response(response, 200)
      resp = Oj.load(response.body)
      expect(resp['theme']).to eq @account.user.theme
      expect(resp['username']).to eq @account.user.name
    end

  end

end