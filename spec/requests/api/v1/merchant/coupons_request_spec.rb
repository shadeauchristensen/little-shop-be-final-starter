require 'rails_helper'

RSpec.describe "Merchant Coupons Index", type: :request do
  describe "Merchant Coupons Activate" do
    let(:merchant) { create(:merchant) }
    let!(:coupon) { create(:coupon, merchant: merchant, status: "inactive") }

        it "activates a coupon successfully" do
            patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}/activate"

            expect(response).to have_http_status(:ok)

            json = JSON.parse(response.body, symbolize_names: true)

            expect(json[:data][:attributes][:status]).to eq("active")
        end

        it "does not allow more than 5 active coupons" do
            create_list(:coupon, 5, merchant: merchant, status: "active")

            patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}/activate"

            expect(response).to have_http_status(:unprocessable_entity)

            json = JSON.parse(response.body, symbolize_names: true)

            expect(json[:error]).to eq("Merchant cannot have more than 5 active coupons")
        end

        it "returns an error if the coupon does not exist" do
            patch "/api/v1/merchants/#{merchant.id}/coupons/9999/activate"

            expect(response).to have_http_status(:not_found)

            json = JSON.parse(response.body, symbolize_names: true)

            expect(json[:error]).to eq("Coupon not found")
        end
    end
end