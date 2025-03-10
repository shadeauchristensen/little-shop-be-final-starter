FactoryBot.define do
  factory :coupon do
    association :merchant

    sequence(:name) { |n| "Discount #{n}" }    
    sequence(:code) { |n| "BOGO50-#{n}" }
    discount_type { "percent_off" }
    discount_value { 50.0 }
    active { true }
  end
end
