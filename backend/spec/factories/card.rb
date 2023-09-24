FactoryBot.define do
  factory :card do
    user
    account
    sequence(:name) { |n| "Card#{n}" }
    ctype { DEBITCARD }
  end
end
