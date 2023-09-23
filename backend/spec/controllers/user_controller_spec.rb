require 'rails_helper'

describe UserController do

  before :each do
    @user = create(:user, email: 'valid@example.com', password: 'password')
  end

  it 'index api should return all users' do
    create :user, name: 'user2'
    get :index
    resp = Oj.load(response.body)
    expect(resp.length).to eq 2
  end

  context 'User#check:' do

    it 'when email is not found renders a 202 status and "Email id not found" message' do
      post :check, params: { email: 'nonexistent@example.com', password: 'password' }
      validate_response(response, 202, 'Email id not found')
    end

    it 'when credentials are valid renders a 200 status and "Credentials are valid" message' do
      post :check, params: { email: 'valid@example.com', password: 'password' }
      validate_response(response, 200, 'Credentials are valid')
    end

    it 'when email and password do not match renders a 202 status and "Email id and Password dont match" message' do
      post :check, params: { email: 'valid@example.com', password: 'wrong_password' }
      validate_response(response, 202, 'Email id and Password dont match')
    end
  end

  context 'User#create:' do

    it 'when email is already taken renders a 202 status and "Email already taken" message' do
      post :create, params: { name: 'new', email: 'valid@example.com', password: 'password2' }
      validate_response(response, 202, 'Email already taken')
    end

    it 'when user is created renders a 200 status and "User created" message' do
      post :create, params: { name: 'new', email: 'new@example.com', password: 'password2' }
      validate_response(response, 200, 'User created')
    end

    it 'when user is created renders a 202 status when name not passed' do
      post :create, params: { email: 'new@example.com', password: 'password2' }
      validate_response(response, 202, 'SQLite3::ConstraintException: NOT NULL constraint failed: users.name')
    end
  end

  context 'User#update:' do

    it 'should not allow updates without authorization' do
      put :update, params: { password: 'new_password' }
      validate_error_response(response, 400, "Unauthorized, Please sign in")
    end

    it 'should update user password' do
      sign_in(@user)
      post :check, params: { email: 'valid@example.com', password: 'password' }
      validate_response(response, 200, 'Credentials are valid')
      put :update, params: { password: 'new_password' }
      validate_response(response, 200, "User updated")
      post :check, params: { email: 'valid@example.com', password: 'new_password' }
      validate_response(response, 200, 'Credentials are valid')
    end

    it 'should update user email' do
      sign_in(@user)
      put :update, params: { email: 'new@example.com' }
      validate_response(response, 200, "User updated")
      expect(@user.email).to eq 'new@example.com'
    end
  end

end
