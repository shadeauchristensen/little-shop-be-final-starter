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

    scope :active, -> { where(active: true) }
    scope :inactive, -> { where(active: false) }

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

    def can_be_activated?
        merchant.coupons.where(active: true).count < 5
      end
    
      def activate!
        raise ActiveRecord::RecordInvalid, "Merchant cannot have more than 5 active coupons." unless can_be_activated?
        
        update!(active: true)
    end


    def self.filter_by_status(merchant, status)
        case status # Checks value of status, used when we want to evaluate multiple conditions
        when "active"
            merchant.coupons.active
        when "inactive"
            merchant.coupons.inactive
        else
            merchant.coupons
        end
    end
end