class ChangeCouponIdNullInInvoices < ActiveRecord::Migration[7.1]
  def change
    change_column_null :invoices, :coupon_id, false
  end
end
