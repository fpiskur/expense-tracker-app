class Expense < ApplicationRecord
  belongs_to :category
  accepts_nested_attributes_for :category

  has_many :expenses_areas, dependent: :destroy
  has_many :areas, through: :expenses_areas
  accepts_nested_attributes_for :areas

  validate :parent_category_with_children_selected
  validates_presence_of :amount, :date, :description, :category_id

  def self.get_expenses_by_date(month: Date.current.month, year: Date.current.year)
    where("EXTRACT(MONTH FROM date) = ?", month)
      .and(where("EXTRACT(YEAR FROM date) = ?", year))
      .order(date: :desc, created_at: :desc)
  end

  def self.oldest_date
    Expense.order(date: :asc).limit(1).first&.date
  end

  def self.newest_date
    Expense.order(date: :desc).limit(1).first&.date
  end

  private

  # Validations
  def parent_category_with_children_selected
    if self.category&.sub_categories&.any?
      errors.add(:category, 'has sub-categories. Please pick one.')
    end
  end
end
