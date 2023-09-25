FactoryBot.define do
  factory :sub_category do
    user
    category
    sequence(:name) { |n| "sub-category#{n}" }
  end
end
