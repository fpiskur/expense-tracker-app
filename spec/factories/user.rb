FactoryBot.define do
  factory :user do
    email { generate(:email) }
    password { 'password' }
  end

  sequence :email do |n|
    "test#{n}@example.com"
  end
end
