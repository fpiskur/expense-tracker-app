# frozen_string_literal: true

class Area < ApplicationRecord
  has_many :expenses_areas
  has_many :expenses, through: :expenses_areas

  validates_presence_of :name
end
