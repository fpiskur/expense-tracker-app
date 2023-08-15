class Expense < ApplicationRecord
  belongs_to :category
  accepts_nested_attributes_for :category

  has_many :expenses_areas, dependent: :destroy
  has_many :areas, through: :expenses_areas
  accepts_nested_attributes_for :areas

  validate :parent_category_with_children_selected
  validates_presence_of :amount, :date, :description, :category_id

  def self.get_expenses_by_period(period, **options)
    if period == 'year' || period == 'month'
      expenses = where("EXTRACT(YEAR FROM date) = ?", options[:year])
    end
    if period == 'month'
      expenses = expenses.where("EXTRACT(MONTH FROM date) = ?", options[:month])
    end
    if options[:ordered]
      expenses = expenses.order(date: :desc, created_at: :desc)
    end
    expenses
  end

  def self.get_expenses_by_area(month: nil, year: nil)
    if month && year
      get_expenses_by_period('month', month: month, year: year)
        .joins(:areas)
        .group('areas.name')
        .sum('expenses.amount')
    elsif year
      get_expenses_by_period('year', year: year)
        .joins(:areas)
        .group('areas.name')
        .sum('expenses.amount')
    else
      joins(:areas)
        .group('areas.name')
        .sum('expenses.amount')
    end
  end

  def self.get_total_for_period(month: nil, year: nil)
    if month && year
      get_expenses_by_period('month', month: month, year: year).sum(:amount)
    elsif year
      get_expenses_by_period('year', year: year).sum(:amount)
    else
      sum(:amount)
    end
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
