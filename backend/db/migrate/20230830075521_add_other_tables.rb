class AddOtherTables < ActiveRecord::Migration[7.0]
  def change
    create_table :cards do |t|
      t.string :name
      t.string :ctype
      t.float :outstanding_bill, default: 0
      t.date :last_paid
      t.belongs_to :account
      t.belongs_to :user
      t.timestamps
    end

    create_table :mops do |t|
      t.string :name, null: false
      t.json :meta, default: {}
      t.belongs_to :account
      t.belongs_to :user
      t.timestamps
    end

    create_table :transactions do |t|
      t.float :amount
      t.string :ttype
      t.date :date
      t.integer :party
      t.integer :category_id
      t.boolean :pseudo, default: false
      t.float :balance_before
      t.float :balance_after
      t.json :meta, default: {}
      t.string :comments, default: ""
      t.integer :sub_category_id
      t.integer :mop_id
      t.integer :card_id
      t.integer :t_order, default: 1
      t.belongs_to :account
      t.belongs_to :user
      t.timestamps
    end

    create_table :categories do |t|
      t.string :name, null: false
      t.string :color, null: false
      t.float :monthly_limit
      t.float :yearly_limit
      t.json :budget, default: {}
      t.belongs_to :user
      t.timestamps
    end

    # create_table :daily_logs do |t|
    #   t.float :opening_balance
    #   t.float :closing_balance
    #   t.date :date
    #   t.integer :total_transactions
    #   t.json :meta
    #   t.belongs_to :account
    #   t.belongs_to :user
    #   t.timestamps
    # end

    create_table :sub_categories do |t|
      t.string :name, null: false
      t.belongs_to :category
      t.belongs_to :user
      t.float :monthly_limit
      t.float :yearly_limit
      t.json :budget, default: {}
      t.timestamps
    end
    
  end
end
