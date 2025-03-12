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

      it "returns 404 if merchant is not found" do
        get "/api/v1/merchants/999999/coupons" # Non-existent merchant
        
        json = JSON.parse(response.body, symbolize_names: true)
      
        expect(response).to have_http_status(:not_found)
        expect(json[:error]).to eq("Merchant not found")
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

      it "returns 404 if merchant is not found when viewing a coupon" do
        get "/api/v1/merchants/999999/coupons/1" # Non-existent merchant
      
        json = JSON.parse(response.body, symbolize_names: true)
      
        expect(response).to have_http_status(:not_found)
        expect(json[:error]).to eq("Merchant or Coupon not found")
      end
      
      it "returns 404 if coupon is not found for a merchant" do
        merchant = create(:merchant)
        get "/api/v1/merchants/#{merchant.id}/coupons/999999" # Non-existent coupon
      
        json = JSON.parse(response.body, symbolize_names: true)
      
        expect(response).to have_http_status(:not_found)
        expect(json[:error]).to eq("Merchant or Coupon not found")
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
        create_list(:coupon, 5, merchant: merchant, active: true) # Ensures that 5 active coupons exist
    
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

      it "returns 404 if merchant is not found when creating a coupon" do
        post "/api/v1/merchants/999999/coupons", params: {
          name: "Test Coupon",
          code: "TEST123",
          discount_type: "percent",
          discount_value: 10,
          active: true
        }, as: :json
      
        json = JSON.parse(response.body, symbolize_names: true)
      
        expect(response).to have_http_status(:not_found)
        expect(json[:error]).to eq("Merchant not found")
      end
    end

    describe "PATCH /api/v1/merchants/:merchant_id/coupons/:id/deactivate" do
      let!(:merchant) { create(:merchant) }
      let!(:coupon) { create(:coupon, merchant: merchant, active: true) }
    
      it "successfully deactivates a coupon when there are no pending invoices" do
        patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}/deactivate"
    
        expect(response).to have_http_status(:ok)
    
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:data][:attributes][:active]).to eq(false)
      end
    
      it "fails to deactivate a coupon if it has pending invoices" do
        create(:invoice, merchant: merchant, coupon: coupon, status: "pending")
    
        patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}/deactivate"
    
        expect(response).to have_http_status(:unprocessable_entity)
    
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:error]).to eq("Coupon cannot be deactivated while it has pending invoices.")
      end
    end

    describe "PATCH /api/v1/merchants/:merchant_id/coupons/:id/activate" do
      let!(:merchant) { create(:merchant) }
      let!(:coupon) { create(:coupon, merchant: merchant, active: false) }
  
      it "activates a coupon successfully" do
        patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}/activate"
  
        expect(response).to have_http_status(:ok)
  
        json = JSON.parse(response.body, symbolize_names: true)
  
        expect(json[:data][:id]).to eq(coupon.id.to_s)
        expect(json[:data][:type]).to eq("coupon")
        expect(json[:data][:attributes][:active]).to be true
      end
    end

    describe "GET /api/v1/merchants/:merchant_id/coupons?status=filtered" do
      before(:each) do
        @merchant = create(:merchant)
        @active_coupons = create_list(:coupon, 3, merchant: @merchant, active: true)
        @inactive_coupons = create_list(:coupon, 2, merchant: @merchant, active: false) # Look at line 206
      end
    
      it "returns only active coupons when filtered by status=active" do
        get "/api/v1/merchants/#{@merchant.id}/coupons", params: { status: "active" }
    
        expect(response).to have_http_status(:ok)
    
        json = JSON.parse(response.body, symbolize_names: true)
    
        expect(json[:data].size).to eq(3)
        json[:data].each do |coupon|
          expect(coupon[:attributes][:active]).to be true
        end
      end
    
      it "returns only inactive coupons when filtered by status=inactive" do
        get "/api/v1/merchants/#{@merchant.id}/coupons", params: { status: "inactive" }
    
        expect(response).to have_http_status(:ok)
    
        json = JSON.parse(response.body, symbolize_names: true)
    
        expect(json[:data].size).to eq(2)
        json[:data].each do |coupon|
          expect(coupon[:attributes][:active]).to be false
        end
      end
    
      it "returns all coupons if no status param is given" do
        get "/api/v1/merchants/#{@merchant.id}/coupons"
    
        expect(response).to have_http_status(:ok)
    
        json = JSON.parse(response.body, symbolize_names: true)
    
        expect(json[:data].size).to eq(5) # 3 active + 2 inactive
      end
    end
  end
end