# frozen_string_literal: true

class Category < ApplicationRecord
  belongs_to :parent_category, class_name: 'Category', foreign_key: 'parent_id', optional: true
  has_many :sub_categories, class_name: 'Category', foreign_key: 'parent_id', dependent: :destroy
  has_many :expenses

  validates_presence_of :name,
                        message: ->(_object, data) { "#{data[:model]} #{data[:attribute].downcase} can't be blank" }
  validate :unique_name_within_scope

  scope :parent_categories, -> { where(parent_id: nil) }

  private

  def unique_name_within_scope
    if parent_category.nil?
      errors.add(:name, 'Category name must be unique') if Category.parent_categories.exists?(name: name)
    elsif parent_category.sub_categories.exists?(name: name)
      errors.add(:name, 'Category name must be unique')
    end
  end
end
