FactoryBot.define do
  factory :mop do
    account
    user { account.user }
    sequence(:name) { |n| "Mop#{n}" }
  end
end
