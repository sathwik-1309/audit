require 'rails_helper'

describe Mop do

  it 'is valid with valid attributes' do
    mop = create(:mop)
    expect(mop).to be_valid
  end

end
