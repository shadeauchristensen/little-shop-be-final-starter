class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :transactions, dependent: :destroy
  belongs_to :coupon, optional: true 

  validates :status, inclusion: { in: ["pending", "shipped", "packaged", "returned"] }

  def self.for_merchant(merchant_id)
    where(merchant_id: merchant_id).select(:id, :customer_id, :merchant_id, :coupon_id, :status)
  end
end