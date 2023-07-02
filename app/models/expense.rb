class Expense < ApplicationRecord
  belongs_to :category
  accepts_nested_attributes_for :category

  validates_presence_of :amount, :date, :description, :category_id
end
