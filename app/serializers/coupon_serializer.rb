class CouponSerializer
    include JSONAPI::Serializer

    attributes :name, :code, :discount_type, :discount_value

    attribute :usage_count do |coupon, params|
        params[:usage_count] || 0
    end
end