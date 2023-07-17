class Expense < ApplicationRecord
  belongs_to :category
  accepts_nested_attributes_for :category

  validate :parent_category_with_children_selected
  validates_presence_of :amount, :date, :description, :category_id

  private

  def parent_category_with_children_selected
    if self.category&.sub_categories&.any?
      errors.add(:category, 'has sub-categories. Please pick one.')
    end
  end
end
