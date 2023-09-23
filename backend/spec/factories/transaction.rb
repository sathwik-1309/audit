FactoryBot.define do
  factory :transaction do
    mop
    account { mop.account }
    user { mop.user }
    amount { 100 }
    date { Date.today }
    ttype { DEBIT }
  end
end
