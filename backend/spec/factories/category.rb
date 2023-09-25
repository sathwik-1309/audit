FactoryBot.define do
  factory :category do
    user
    sequence(:name) { |n| "category#{n}" }
  end
end
