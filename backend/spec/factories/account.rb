FactoryBot.define do
  factory :account do
    user
    sequence(:name) { |n| "Account#{n}" }
    balance { 0 }
    opening_date { Date.today }
  end
end
    