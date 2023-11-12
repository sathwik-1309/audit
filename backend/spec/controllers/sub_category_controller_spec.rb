require 'rails_helper'

describe SubCategoryController do
  before :each do
    @category = create(:category, name: 'Movies')
    @sub_category = create(:sub_category, category: @category, user: @category.user, name: 'Movie1')
    @user = @sub_category.user
    sign_in(@user)
  end

  it 'index api should return all sub-categories' do
    create(:sub_category, user: @user, category: @category, name: 'Movie2')
    get :index
    resp = Oj.load(response.body)
    expect(resp.length).to eq 5
  end

  context 'Sub-Category#create:' do
    it 'should throw error when invalid category' do
      post :create, params: { name: @sub_category.name, category_id: 100 }
      resp = Oj.load(response.body)
      validate_response(response, 202, 'Invalid Category')
    end

    it 'should throw error when sub_category exists' do
      post :create, params: { name: @sub_category.name, category_id: @category.id }
      resp = Oj.load(response.body)
      validate_response(response, 202, "Sub-category #{@sub_category.name} already exists in this category")
    end

    it 'should create sub-category' do
      post :create, params: { name: 'new', category_id: @category.id }
      resp = Oj.load(response.body)
      validate_response(response, 200, 'Sub-category created')
    end
  end

  context 'Sub-Category#delete' do
    it 'should throw error when category does not exist' do
      delete :delete, params: { id: 200 }
      validate_response(response, 202, 'Sub-category not found')
    end

    it 'should delete category' do
      id = @sub_category.id
      expect(SubCategory.find_by_id(id).nil?).to eq false
      delete :delete, params: { id: @sub_category.id }
      expect(SubCategory.find_by_id(id).nil?).to eq true
      validate_response(response, 200, 'Sub-category deleted')
    end
  end

end