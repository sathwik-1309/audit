class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :password, default: ""
      t.string :theme, default: "dark"
      t.string :app_theme, default: "midnight"
      t.timestamps
    end
  end
end
