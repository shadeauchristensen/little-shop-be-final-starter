class CouponSerializer
    include JSONAPI::Serializer
    attributes :name, :code, :discount_type, :discount_value, :active

    attribute :usage_count do |coupon|
        begin
            coupon.invoices.count
        rescue StandardError => e
            Rails.logger.error("Error calculating usage_count: #{e.message}")
            0
        end
    end

    attribute :discount_value do |coupon|
        begin
            coupon.discount_value.to_f
        rescue StandardError => e
            Rails.logger.error("Error formatting discount_value: #{e.message}")
            0.0
        end
    end

    attribute :active_coupon_count do |coupon|
        begin
            coupon.merchant.coupons.where(active: true).count
        rescue StandardError => e
            Rails.logger.error("Error retrieving active coupon count: #{e.message}")
            0
        end
    end

    attribute :merchant_active_coupon_limit do |coupon|
        begin
            active_count = coupon.merchant.coupons.where(active: true).count >= 5
        rescue StandardError => e
            Rails.logger.error("Error checking merchant active coupon limit: #{e.message}")
            false
        end
    end

    attribute :has_pending_invoices do |coupon|
        begin
            coupon.has_pending_invoices?
        rescue StandardError => e
            Rails.logger.error("Error checking pending invoices: #{e.message}")
            false
        end
    end
end
