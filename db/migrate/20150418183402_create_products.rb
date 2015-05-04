class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :title
      t.text :urls, array: true, default: []
      t.decimal :price
      t.string :email

      t.timestamps null: false
    end
  end
end
