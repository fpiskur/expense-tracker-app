class Expense < ApplicationRecord
  belongs_to :category
  accepts_nested_attributes_for :category

  has_many :expenses_areas
  has_many :areas, through: :expenses_areas
  accepts_nested_attributes_for :areas

  validates_presence_of :amount, :date, :description, :category_id
end
