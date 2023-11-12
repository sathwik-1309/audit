require 'rails_helper'

describe CategoryController do
  before :each do
    @category = create(:category)
    @user = @category.user
    sign_in(@user)
  end

  it 'index api should return all categories' do
    create(:category, user: @user)
    get :index
    resp = Oj.load(response.body)
    expect(resp.length).to eq 2
  end

  context 'Category#create:' do
    it 'should create a new category' do
      post :create, params: { name: 'category2', color: 'orange'}
      validate_response(response, 200, 'Category created')
      get :index
      resp = Oj.load(response.body)
      expect(resp.length).to eq 2
    end

    it 'should create a new category' do
      post :create, params: { name: @category.name }
      validate_response(response, 202, 'Category already exists')
    end
  end

  context 'Category#delete' do
    it 'should throw error when category does not exist' do
      delete :delete, params: { id: 200 }
      validate_response(response, 202, 'Category not found')
    end

    it 'should delete category' do
      delete :delete, params: { id: @category.id }
      validate_response(response, 200, 'Category deleted')
    end
  end
end