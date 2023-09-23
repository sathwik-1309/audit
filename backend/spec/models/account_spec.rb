require 'rails_helper'

describe Account do
    
  it 'is valid with valid attributes' do
    account = create(:account)
    expect(account).to be_valid
  end

  # Add more tests using FactoryBot as needed
end
