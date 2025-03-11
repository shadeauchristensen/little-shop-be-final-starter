FactoryBot.define do
    factory :coupon do
      association :merchant
  
      name { "Buy one get one fifty percent off" }
      sequence(:code) { |n| "BOGO50-#{n}" } 
      discount_type { "percent_off" }
      discount_value { 50.0 }
      active { true }
    end
  end