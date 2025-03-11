class Coupon < ApplicationRecord
    belongs_to :merchant
    has_many :invoices

    validates :name, presence: true
    validates :code, presence: true, uniqueness: true
    validates :discount_type, presence: true, inclusion: { in: ["percent_off", "dollar_off"] }
    validates :discount_value, presence: true, numericality: { greater_than: 0 }
    validates :merchant, presence: true
    validate :merchant_active_coupon_limit, on: :create

    def usage_count
        invoices.count
    end

    def merchant_active_coupon_limit
        if merchant && merchant.coupons.where(active: true).count >= 5
          errors.add(:merchant, "cannot have more than 5 active coupons.")
        end
    end

    def can_be_deactivated?
        invoices.where(status: "pending").none?
    end

    def deactivate!
        return false unless can_be_deactivated?
        update(active: false)
    end
end