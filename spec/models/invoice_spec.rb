require "rails_helper"

RSpec.describe Invoice, type: :model do
  describe "associations" do
    it { should belong_to :merchant }
    it { should belong_to :customer }
    it { should belong_to(:coupon).optional }
  end

  describe "validations" do
    it { should validate_inclusion_of(:status).in_array(%w(shipped packaged returned)) }
  end
  
  describe "methods" do
    let!(:merchant) { create(:merchant) }
    let!(:coupon) { create(:coupon, merchant: merchant) }
    let!(:customer) { create(:customer) }

    it "counts invoices with coupons" do
      create_list(:invoice, 2, merchant: merchant, coupon: coupon)
      create_list(:invoice, 3, merchant: merchant)

      expect(merchant.invoices.where.not(coupon_id: nil).count).to eq(2)
    end
  end
end