class RemovePayPalPaymentIdFromPurchases < ActiveRecord::Migration
  def change
    remove_column :purchases, :paypal_payment_id, :string
  end
end
