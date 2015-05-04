class AddEmailAddressToPurchase < ActiveRecord::Migration
  def change
    add_column :purchases, :email, :string
  end
end
