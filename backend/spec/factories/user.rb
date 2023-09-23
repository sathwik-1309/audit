FactoryBot.define do
  factory :user do
    sequence(:name) {|n| "User#{n}" }
    sequence(:email) {|n| "example#{n}@email.com" }
    password { 'password' }
  end
end
  