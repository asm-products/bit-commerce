class AddPayPalPaymentIdToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :paypal_payment_id, :string
  end
end
