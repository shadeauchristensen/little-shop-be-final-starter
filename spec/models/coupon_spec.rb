require 'rails_helper'

RSpec.describe Coupon, type: :model do
    describe "validations" do
        it { should validate_presence_of(:name) }
        it { should validate_presence_of(:code) }
        it { should validate_uniqueness_of(:code) }
        it { should validate_presence_of(:discount_type) }
        it { should validate_inclusion_of(:discount_type).in_array(["percent_off", "dollar_off"]) }
        it { should validate_presence_of(:discount_value) }
        it { should validate_numericality_of(:discount_value).is_greater_than(0) }

        subject { create(:coupon, merchant: create(:merchant)) } 
        it { should validate_uniqueness_of(:code) }

    describe "active coupon limit" do
        it "should not allow merchants to have more than 5 active coupons" do
            merchant = create(:merchant)
            create_list(:coupon, 5, merchant: merchant, active: true)

            new_coupon = merchant.coupons.new(
                name: "Extra Discount",
                code: "EXTRA10",
                discount_type: "percent_off",
                discount_value: 10,
                active: true
            )

            expect(new_coupon.valid?).to be false
            expect(new_coupon.errors.full_messages).to include("Merchant cannot have more than 5 active coupons.")
            end
        end
    end
  
    describe "relationships" do
        it { should belong_to :merchant }
        it { should have_many :invoices }
    end

    describe "instances of coupons" do
        let!(:merchant) { create(:merchant) }
        let!(:coupon) { create(:coupon, merchant: merchant) }
        let!(:invoices) { create_list(:invoice, 3, coupon: coupon) }

        it "should return usage_count" do 
            expect(coupon.usage_count).to eq(3)
        end
    end
end
