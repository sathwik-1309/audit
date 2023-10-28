CREDITCARD = "creditcard"
DEBITCARD = "debitcard"
CTYPES = [CREDITCARD, DEBITCARD]

DEBIT = "debit"
CREDIT = "credit"
PAID_BY_YOU = "paid_by_you"
PAID_BY_PARTY = "paid_by_party"
SETTLED_BY_PARTY = "settled_by_party"
SETTLED_BY_YOU = "settled_by_you"
SPLIT = "split"

TTYPES = [DEBIT, CREDIT, PAID_BY_YOU, PAID_BY_PARTY, SETTLED_BY_PARTY, SETTLED_BY_YOU, SPLIT]
CREDIT_TRANSACTIONS = [CREDIT, SETTLED_BY_PARTY]
PERIODS = ["today", "month", "week"]

#channels
ACCOUNTS_CHANNEL = "AccountsChannel"
CARDS_CHANNEL = "CardsChannel"
MOPS_CHANNEL = "MopsChannel"
CATEGORY_CHANNEL = "CategoryChannel"
SUBCATEGORY_CHANNEL = "SubcategoryChannel"
USER_CHANNEL = "UserChannel"

#react
PIE_CHART_COLORS = ['orange', '#e74c3c', '#9b59b6', '#f1c40f', '#1d81de', 'brown', 'red', 'blue']
# PIE_CHART_COLORS = ['#e67e22', '#3498db', '#9b59b6', '#f1c40f']
CATEGORY_COLORS = [
  {
    'color' => 'orange',
    'name' => 'orange'
  },
  {
    'color' => '#3498db',
    'name' => 'blue'
  },
  {
    'color' => '#e74c3c',
    'name' => 'red'
  },
  {
    'color' => '#f1c40f',
    'name' => 'yellow'
  },
  {
    'color' => '#9b59b6',
    'name' => 'purple'
  },
  {
    'color' => '#2ecc71',
    'name' => 'emerald'
  },
  {
    'color' => '#1abc9c',
    'name' => 'turquoise'
  },
  {
    'color' => '#34495e',
    'name' => 'graphite'
  },
  {
    'color' => '#e84393',
    'name' => 'pink'
  },
]

#env
ADMIN_MAIL_ID = 'sathwik1309@gmail.com'
