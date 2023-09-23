require 'rails_helper'

describe User do
    
  it 'is valid with valid attributes' do
    user = create(:user)
    expect(user).to be_valid
  end

  # Add more tests using FactoryBot as needed
end
