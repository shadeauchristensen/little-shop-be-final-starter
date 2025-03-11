class Api::V1::Merchants::CouponsController < ApplicationController
    def index
        begin
            merchant = Merchant.find(params[:merchant_id])
            coupons = merchant.coupons
            render json: CouponSerializer.new(coupons)
            
        rescue ActiveRecord::RecordNotFound
            render json: { error: "Merchant not found" }, status: :not_found
        rescue StandardError => e
            render json: { error: "Something went wrong: #{e.message}" }, status: :internal_server_error
        end
    end

    def show
        begin
            merchant = Merchant.find(params[:merchant_id])
            coupon = merchant.coupons.find(params[:id])
            render json: CouponSerializer.new(coupon, { params: { usage_count: coupon_usage_count(coupon) } })

        rescue ActiveRecord::RecordNotFound
            render json: { error: "Merchant or Coupon not found" }, status: :not_found
        rescue StandardError => e
            render json: { error: "Something went wrong: #{e.message}" }, status: :internal_server_error
        end
    end

    def create
        begin
            merchant = Merchant.find(params[:merchant_id])
            coupon = merchant.coupons.new(coupon_params)

            if coupon.save
                render json: CouponSerializer.new(coupon), status: :created
            else
                render json: { errors: coupon.errors.full_messages }, status: :unprocessable_entity
            end

        rescue ActiveRecord::RecordNotFound
            render json: { error: "Merchant not found" }, status: :not_found
        rescue StandardError => e
            render json: { error: "Something went wrong: #{e.message}" }, status: :internal_server_error
        end
    end

    def deactivate
        begin
          coupon = Coupon.find(params[:id])
          
          if coupon.can_be_deactivated?
            coupon.update!(active: false)
            render json: CouponSerializer.new(coupon), status: :ok
          else
            render json: { error: "Coupon cannot be deactivated while there are pending invoices." }, status: :unprocessable_entity
          end
          
        rescue ActiveRecord::RecordNotFound
            render json: { error: "Coupon not found." }, status: :not_found
        rescue StandardError => e
            render json: { error: "Something went wrong: #{e.message}" }, status: :internal_server_error
        end
    end
    

    

    private

    def coupon_usage_count(coupon)
        coupon.invoices.count
    end

    def coupon_params
        params.require(:coupon).permit(:name, :code, :discount_type, :discount_value, :active)
    end
end