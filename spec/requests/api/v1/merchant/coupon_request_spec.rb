require 'rails_helper'

RSpec.describe "Merchants Coupons API", type: :request do
  describe "GET api/v1/merchants/:merchants_id/coupons/:id" do
    let!(:merchant) { create(:merchant) }
    let!(:coupon) { create(:coupon, merchant: merchant) }
    let!(:invoices) { create_list(:invoice, 3, coupon: coupon) }


    describe "validations" do
      it "expects coupon to be valid" do
        expect(coupon).to be_valid
      end
    end
    
    describe "instances of coupons" do
      it "counts the instances of coupons: coupon_count" do
        expect(coupon.usage_count).to eq(3)
      end
    end

    describe "request coupon" do
      it "returns the usage_count of coupon" do
        get "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}"

        json = JSON.parse(response.body, symbolize_names: true)
        data_of_coupon = json[:data]

        expect(data_of_coupon).to have_key(:id)
        expect(data_of_coupon[:id]).to eq(coupon.id.to_s)

        expect(data_of_coupon[:attributes]).to have_key(:name)
        expect(data_of_coupon[:attributes][:name]).to eq(coupon.name)

        expect(data_of_coupon[:attributes]).to have_key(:code)
        expect(data_of_coupon[:attributes][:code]).to eq(coupon.code)

        expect(data_of_coupon[:attributes]).to have_key(:discount_type)
        expect(data_of_coupon[:attributes][:discount_type]).to eq(coupon.discount_type)

        expect(data_of_coupon[:attributes]).to have_key(:discount_value)
        expect(data_of_coupon[:attributes][:discount_value]).to eq(coupon.discount_value)

        expect(data_of_coupon[:attributes]).to have_key(:usage_count)
        expect(data_of_coupon[:attributes][:usage_count]).to eq(3)
      end
    end
  end
end
