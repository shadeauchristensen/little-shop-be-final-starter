require "rails_helper"

RSpec.describe "Merchant invoices endpoints" do
  before :each do
    @merchant2 = Merchant.create!(name: "Merchant")
    @merchant1 = Merchant.create!(name: "Merchant Again")

    @customer1 = Customer.create!(first_name: "Papa", last_name: "Gino")
    @customer2 = Customer.create!(first_name: "Jimmy", last_name: "John")

    @invoice1 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "packaged")
    @invoice2 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "shipped")
    @invoice3 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "shipped")
    @invoice4 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "shipped")
    @invoice5 = Invoice.create!(customer: @customer1, merchant: @merchant2, status: "shipped")
  
    @coupon = Coupon.create!(name: "Spring Sale", code: "SPRING20", discount_type: "percent_off", discount_value: 20, merchant: @merchant1)

    @invoice_with_coupon = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "shipped", coupon: @coupon)
    @invoice_without_coupon = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "shipped", coupon: nil)
  end

  it "should return all invoices for a given merchant based on status param" do
    get "/api/v1/merchants/#{@merchant1.id}/invoices?status=packaged"

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(json[:data].count).to eq(1)
    expect(json[:data][0][:id]).to eq(@invoice1.id.to_s)
    expect(json[:data][0][:type]).to eq("invoice")
    expect(json[:data][0][:attributes][:customer_id]).to eq(@customer1.id)
    expect(json[:data][0][:attributes][:merchant_id]).to eq(@merchant1.id)
    expect(json[:data][0][:attributes][:status]).to eq("packaged")
  end

  it "should get multiple invoices if they exist for a given merchant and status param" do
    get "/api/v1/merchants/#{@merchant1.id}/invoices?status=shipped"

    json = JSON.parse(response.body, symbolize_names: true)

    expected_count = @merchant1.invoices.where(status: "shipped").count
    expect(response).to be_successful
    expect(json[:data].count).to eq(expected_count)
  end

  it "should only get invoices for merchant given" do
    get "/api/v1/merchants/#{@merchant2.id}/invoices?status=shipped"

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(json[:data].count).to eq(1)
    expect(json[:data][0][:id]).to eq(@invoice5.id.to_s)
  end

  it "should return 404 and error message when merchant is not found" do
    get "/api/v1/merchants/100000/customers"

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(:not_found)
    expect(json[:message]).to eq("Your query could not be completed")
    expect(json[:errors]).to be_a Array
    expect(json[:errors].first).to eq("Couldn't find Merchant with 'id'=100000")
  end

  it "should return all invoices for a given merchant without status filter" do
    get "/api/v1/merchants/#{@merchant1.id}/invoices"

    json = JSON.parse(response.body, symbolize_names: true)

    expected_count = @merchant1.invoices.count
    expect(response).to be_successful
    expect(json[:data].count).to eq(expected_count)
  end


  it "returns all invoices for a given merchant including coupon_id if present" do
    get "/api/v1/merchants/#{@merchant1.id}/invoices"

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(json[:data].count).to eq(@merchant1.invoices.count)

    json[:data].each do |invoice|
      expected_coupon_id = Invoice.find(invoice[:id]).coupon_id
      expect(invoice[:attributes][:coupon_id]).to eq(expected_coupon_id)
    end
  end
end
