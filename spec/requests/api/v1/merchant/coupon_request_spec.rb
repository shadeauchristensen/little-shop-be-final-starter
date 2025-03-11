require 'rails_helper'

RSpec.describe "Merchants Coupons API", type: :request do
  describe "GET api/v1/merchants/:merchants_id/coupons/:id" do
    before(:each) do
      @merchant = create(:merchant)
      @customer = create(:customer)
      @coupons = create_list(:coupon, 3, merchant: @merchant)

      @coupons.each do |coupon|
        create_list(:invoice, 3, merchant: @merchant, customer: @customer, coupon: coupon)
      end
    end

    describe "validations" do
      it "expects coupon to be valid" do
        expect(@coupons.first).to be_valid
      end
    end

    describe "instances of coupons" do
      it "counts the instances of coupons: coupon_count" do
        expect(@coupons.first.usage_count).to eq(3)
      end
    end

    describe "GET /api/v1/merchants/:merchant_id/coupons" do
      it "returns all coupons for a merchant" do
        get "/api/v1/merchants/#{@merchant.id}/coupons"

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body, symbolize_names: true)

        expect(json[:data].length).to eq(3)

        coupon_attributes = json[:data].first[:attributes]

        json[:data].each do |coupon|
          expect(coupon).to have_key(:id)
          expect(coupon_attributes).to have_key(:name)
          expect(coupon_attributes).to have_key(:code)
          expect(coupon_attributes).to have_key(:discount_type)
          expect(coupon_attributes).to have_key(:discount_value)
          expect(coupon_attributes).to have_key(:active)
        end
      end
    end

    describe "GET /api/v1/merchants/:merchant_id/coupons/:id" do
      it "returns the usage_count of coupon" do
        get "/api/v1/merchants/#{@merchant.id}/coupons/#{@coupons.first.id}"

        json = JSON.parse(response.body, symbolize_names: true)
        data_of_coupon = json[:data]

        expect(data_of_coupon).to have_key(:id)
        expect(data_of_coupon[:id]).to eq(@coupons.first.id.to_s)

        expect(data_of_coupon[:attributes]).to have_key(:name)
        expect(data_of_coupon[:attributes][:name]).to eq(@coupons.first.name)

        expect(data_of_coupon[:attributes]).to have_key(:code)
        expect(data_of_coupon[:attributes][:code]).to eq(@coupons.first.code)

        expect(data_of_coupon[:attributes]).to have_key(:discount_type)
        expect(data_of_coupon[:attributes][:discount_type]).to eq(@coupons.first.discount_type)

        expect(data_of_coupon[:attributes]).to have_key(:discount_value)
        expect(data_of_coupon[:attributes][:discount_value]).to eq(@coupons.first.discount_value)

        expect(data_of_coupon[:attributes]).to have_key(:usage_count)
        expect(data_of_coupon[:attributes][:usage_count]).to eq(3)
      end
    end

    describe "POST /api/v1/merchants/:merchant_id/coupons" do
      it "creates a new coupon for a merchant" do 
        coupon_params = {
          coupon: {
            name: "Spring Sale",
            code: "SPRING25",
            discount_type: "percent_off",
            discount_value: 25,
            active: true
          }
        }

        post "/api/v1/merchants/#{@merchant.id}/coupons", params: coupon_params.to_json, headers: { "CONTENT_TYPE" => "application/json" }

        expect(response).to have_http_status(:created)

        json = JSON.parse(response.body, symbolize_names: true)
        data_attributes = json[:data][:attributes]

        expect(data_attributes[:name]).to eq("Spring Sale")
        expect(data_attributes[:code]).to eq("SPRING25")
        expect(data_attributes[:discount_type]).to eq("percent_off")
        expect(data_attributes[:discount_value]).to eq(25)
        expect(data_attributes[:active]).to eq(true)
      end

      it "does not allow more than 5 active coupons" do
        merchant = create(:merchant)
        create_list(:coupon, 5, merchant: merchant, active: true) # Ensure 5 active coupons exist
    
        coupon_params = { 
          coupon: { 
            name: "Extra Discount", 
            code: "EXTRA10", 
            discount_type: "dollar_off", 
            discount_value: 10, 
            active: true } 
          }
    
        post "/api/v1/merchants/#{merchant.id}/coupons", params: coupon_params.to_json, headers: { "CONTENT_TYPE" => "application/json" }
    
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:errors]).to include("Merchant cannot have more than 5 active coupons.")
      end
    end

    describe "PATCH /api/v1/merchants/:merchant_id/coupons/:id/deactivate" do
      it "successfully deactivates a coupon" do
        coupon = create(:coupon, merchant: @merchant, active: true)
    
        patch "/api/v1/merchants/#{@merchant.id}/coupons/#{coupon.id}/deactivate"
    
        expect(response).to have_http_status(:ok)
    
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:data][:attributes][:active]).to eq(false)
      end

      it "does not deactivate a coupon if it has pending invoices" do
        coupon = create(:coupon, merchant: @merchant, active: true)
        create(:invoice, merchant: @merchant, customer: @customer, coupon: coupon, status: "pending")
      
        patch "/api/v1/merchants/#{@merchant.id}/coupons/#{coupon.id}/deactivate"
      
        expect(response).to have_http_status(:unprocessable_entity)
      
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:error]).to eq("Coupon cannot be deactivated while it has pending invoices.")
      end
    end
  end
end