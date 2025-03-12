class CouponSerializer
    include JSONAPI::Serializer
    attributes :name, :code, :discount_type, :discount_value, :active

    attribute :usage_count do |coupon|
        coupon.invoices&.count || 0
    end

    attribute :discount_value do |coupon|
        coupon.discount_value.to_f rescue 0.0
    end

    attribute :active_coupon_count do |coupon|
        coupon.merchant&.coupons&.where(active: true)&.count || 0
    end

    attribute :merchant_active_coupon_limit do |coupon|
        coupon.merchant.coupons.where(active: true).count >= 5
    end

    attribute :has_pending_invoices do |coupon|
        coupon.has_pending_invoices?
    end

    attribute :can_be_activated do |coupon|
        !coupon.merchant_active_coupon_limit
    end
end
