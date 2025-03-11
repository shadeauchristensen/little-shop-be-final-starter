FactoryBot.define do
    factory :coupon do
      association :merchant
  
      name { "Buy one get one fifty percent off" }
      sequence(:code) { Faker::Alphanumeric.alphanumeric(number: 8).upcase } 
      discount_type { "percent_off" }
      discount_value { 50.0 }
      active { true }
    end
  end