FactoryBot.define do
  factory :category do
    user
    sequence(:name) { |n| "category#{n}" }
    sequence(:color) { |n| 'orange' }
    budget { BUGDET_INIT }
  end
end
