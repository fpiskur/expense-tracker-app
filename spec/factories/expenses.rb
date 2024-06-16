# frozen_string_literal: true

FactoryBot.define do
  factory :expense do
    amount { 1 }
    description { 'MyString' }
    date { '2023-07-02' }
    category
  end
end
