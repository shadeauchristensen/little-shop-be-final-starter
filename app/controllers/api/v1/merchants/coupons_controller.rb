class Api::V1::Merchants::CouponsController < ApplicationController
    def show
        merchant = Merchant.find(params[merchant_id])
        coupon = merchant.coupons.find(params[:id])

        render json: CouponSerializer.new(coupon, { params: { usage_count: coupon_usage_count(coupon) } })
    end

    private

    def coupon_usage_count(coupon)
        coupon.invoices.count
    end
end