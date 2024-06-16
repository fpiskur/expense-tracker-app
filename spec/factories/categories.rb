FactoryBot.define do
  factory :category do
    name { generate(:name) }
    parent_id { nil }
  end

  sequence :name do |n|
    "MyString#{n}"
  end
end
