class AddAuthTokenToProduct < ActiveRecord::Migration
  def change
    add_column :products, :auth_token, :string
    add_index :products, :auth_token, unique: true
  end
end
