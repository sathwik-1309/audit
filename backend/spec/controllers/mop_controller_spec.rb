require 'rails_helper'

describe MopController do
  before :each do
    @account = create(:account, balance: 1000)
    @user = @account.user
    @mop = create(:mop, account: @account, user: @user)
    sign_in(@user)
  end

  it 'index api should return all mops' do
    create(:mop, user: @user)
    get :index, params: { unfiltered: true }
    resp = Oj.load(response.body)
    expect(resp.length).to eq 2
  end

  context 'Mop#create:' do

    it 'creates new mop' do
      post :create, params: { name: 'New Mop', account_id: @account.id }
      validate_response(response, 200, "Mode of payment created")
      resp = Oj.load(response.body)
      expect(resp['name']).to eq 'New Mop'
      expect(resp['account_id']).to eq @account.id
    end

    # it 'returns 400 when tried to create account without name without account' do
    #   post :create, params: { name: 'new_mop' }
    #   validate_error_response(response, 400, "Validation failed: Account must exist")
    # end

  end

  context 'Mop#update:' do

    it 'update mop' do
      put :update, params: { id: @mop.id, name: 'new_mop' }
      validate_response(response, 200, 'Mode of payment updated')
      resp = Oj.load(response.body)
      expect(resp['name']).to eq 'new_mop'
      expect(@mop.reload.name).to eq 'new_mop'
    end

  end

  context 'Mop#delete:' do

    it 'delete mop' do
      delete :delete, params: { id: @mop.id }
      validate_response(response, 200, 'Mode of payment deleted')
      get :index, params: { unfiltered: true }
      expect(Oj.load(response.body).length).to eq 0
    end

  end
end