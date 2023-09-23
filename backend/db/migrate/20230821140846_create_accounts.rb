class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.float :balance
      t.boolean :owed, default: false
      t.boolean :creditcard, default: false
      t.date :opening_date
      t.belongs_to :user
      t.timestamps
    end
  end
end
