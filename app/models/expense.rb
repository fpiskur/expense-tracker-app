# frozen_string_literal: true

class Expense < ApplicationRecord
  belongs_to :category
  accepts_nested_attributes_for :category

  has_many :expenses_areas, dependent: :destroy
  has_many :areas, through: :expenses_areas
  accepts_nested_attributes_for :areas

  validate :parent_category_with_children_selected
  validates_presence_of :amount, :date, :description, :category_id

  def self.get_expenses_by_period(period, **options)
    expenses = where('EXTRACT(YEAR FROM date) = ?', options[:year]) if %w[year month].include?(period)
    expenses = expenses.where('EXTRACT(MONTH FROM date) = ?', options[:month]) if period == 'month'
    expenses = expenses.order(date: :desc, created_at: :desc) if options[:ordered]
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
    Expense.order(date: :asc).limit(1).first&.date || Date.current
  end

  def self.newest_date
    Expense.order(date: :desc).limit(1).first&.date || Date.current
  end

  private

  # Validations
  def parent_category_with_children_selected
    return unless category&.sub_categories&.any?

    errors.add(:category, 'has sub-categories. Please pick one.')
  end
end
