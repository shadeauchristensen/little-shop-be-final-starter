class CouponSerializer
    include JSONAPI::Serializer

    attributes :name, :code, :discount_type, :discount_value, :active

    attribute :usage_count do |coupon, params|
        params[:usage_count] || 0
    end

    attribute :discount_value do |object| # Why TF did this try and do 'scientific notation' and is this common is coding? Gross... (output started as:⁡⁢⁣⁣ expected: 0.5e2⁡
                                                                                                                                            #           ⁡⁢⁣⁣got: "50.0" ⁡⁢⁢⁢)⁡
        object.discount_value.to_f  # so i changed it to a float
    end
end