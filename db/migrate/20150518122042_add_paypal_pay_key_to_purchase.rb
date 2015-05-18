class AddPaypalPayKeyToPurchase < ActiveRecord::Migration
  def change
    add_column :purchases, :paypal_pay_key, :string
  end
end
