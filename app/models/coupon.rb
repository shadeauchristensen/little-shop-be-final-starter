class Coupon < ApplicationRecord
    belongs_to :merchant
    has_many :invoices

    validates :name, presence: true
    validates :code, presence: true, uniqueness: true
    validates :discount_type, presence: true, inclusion: { in: ["percent_off", "dollar_off"] }
    validates :discount_value, presence: true, numericality: { greater_than: 0 }
    validates :merchant, presence: true
    validate :merchant_active_coupon_limit, on: :create
    validate :cannot_deactivate_with_pending_invoices, on: :update

    def usage_count
        invoices.count
    end

    def merchant_active_coupon_limit
        if merchant && merchant.coupons.where(active: true).count >= 5
          errors.add(:merchant, "cannot have more than 5 active coupons.")
        end
    end

    def has_pending_invoices?
        invoices.where(status: 'pending').exists?
    end

    def deactivate!
        if has_pending_invoices?
          raise ActiveRecord::RecordInvalid, "Coupon cannot be deactivated while it has pending invoices."
        end
        update!(active: false)
    end

    def cannot_deactivate_with_pending_invoices
        if has_pending_invoices? && !active
          errors.add(:base, "Cannot deactivate coupon with pending invoices")
        end
    end
end