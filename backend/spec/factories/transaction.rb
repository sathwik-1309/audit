FactoryBot.define do
  factory :transaction do
    user { account.user }
    amount { 100 }
    date { Date.today }
    ttype { DEBIT }
  end
end
