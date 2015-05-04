class AddTokenToProduct < ActiveRecord::Migration
  def change
    add_column :products, :token, :string
  end
end
