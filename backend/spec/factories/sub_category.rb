FactoryBot.define do
  factory :sub_category do
    user
    category
    sequence(:name) { |n| "Sub Category#{n}" }
  end
end
