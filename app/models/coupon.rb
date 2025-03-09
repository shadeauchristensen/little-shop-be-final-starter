class Coupon < ApplicationRecord
    belongs_to :merchant
    has_many :invoices

    validates :name, presence: true
    validates :code, presence: true, uniqueness: true
    validates :discount_type, presence: true, inclusion: { in: ["percent_off", "dollar_off"] }
    validates :discount_value, presence: true, numericality: { greater_than: 0 }

    def usage_count
        invoices.count
    end

end
