class Area < ApplicationRecord
  has_many :expenses_areas
  has_many :expenses, through: :expenses_areas
end
