# frozen_string_literal: true

class StatsController < ApplicationController
  before_action :set_date
  before_action :setup_data

  def month
    @period = 'day'

    year = @date.year
    month = @date.month

    @heading = Date.new(year, month).strftime('%B %Y.')

    @total = Expense.get_total_for_period(month: month, year: year)
    @total_average = get_average(@period)
    @average_divider = days_in_month(@date)
    @time_period = '€/day'

    @data = Expense.group_by_period('day', :date,
                                    range: Date.new(year, month)..Date.new(year, month).end_of_month)
                   .sum(:amount)
    @sub_category_data = Expense.get_expenses_by_period('month', month: month, year: year)
                                .joins(:category)
                                .group('categories.name')
                                .sum('expenses.amount')
    areas_expenses = Expense.get_expenses_by_area(month: month, year: year)
    @areas_data = get_areas_data(areas_expenses, @total)

    subquery = Expense.get_expenses_by_period('month', month: month, year: year)
                      .joins(:category)
                      .group('categories.parent_id, COALESCE(categories.parent_id, categories.id)')
                      .select('COALESCE(categories.parent_id, categories.id) AS category_id, SUM(amount) AS total_amount')
    @parent_category_data = get_parent_category_data(subquery)
    render :index
  end

  def year
    @period = 'month'

    year = @date.year

    @heading = "#{year}."

    @total = Expense.get_total_for_period(year: year)
    @total_average = get_average(@period)
    @average_divider = 12 # months in year
    @time_period = '€/mo'

    @data = Expense.group_by_period('month', :date,
                                    range: Date.new(year)..Date.new(year).end_of_year)
                   .sum(:amount)
    @sub_category_data = Expense.get_expenses_by_period('year', year: year)
                                .joins(:category)
                                .group('categories.name')
                                .sum('expenses.amount')
    areas_expenses = Expense.get_expenses_by_area(year: year)
    @areas_data = get_areas_data(areas_expenses, @total)

    subquery = Expense.get_expenses_by_period('year', year: year)
                      .joins(:category)
                      .group('categories.parent_id, COALESCE(categories.parent_id, categories.id)')
                      .select('COALESCE(categories.parent_id, categories.id) AS category_id, SUM(amount) AS total_amount')
    @parent_category_data = get_parent_category_data(subquery)
    render :index
  end

  def max
    @period = 'year'

    min_year = @oldest_date.year
    max_year = @newest_date.year

    @heading = 'Max period'

    @total = Expense.get_total_for_period
    @total_average = get_average(@period)
    @average_divider = total_num_of_years
    @time_period = '€/yr'

    @data = Expense.group_by_period('year', :date,
                                    range: Date.new(min_year)..Date.new(max_year).end_of_year)
                   .sum(:amount)
    @sub_category_data = Expense.all
                                .joins(:category)
                                .group('categories.name')
                                .sum('expenses.amount')
    areas_expenses = Expense.get_expenses_by_area
    @areas_data = get_areas_data(areas_expenses, @total)

    subquery = Expense.all
                      .joins(:category)
                      .group('categories.parent_id, COALESCE(categories.parent_id, categories.id)')
                      .select('COALESCE(categories.parent_id, categories.id) AS category_id, SUM(amount) AS total_amount')
    @parent_category_data = get_parent_category_data(subquery)
    render :index
  end

  private

  def get_areas_data(areas_expenses, total)
    other_expenses = total - areas_expenses.values.sum
    areas_expenses.merge('No area' => other_expenses)
  end

  def get_parent_category_data(subquery)
    Category.where(parent_id: nil)
            .joins("LEFT JOIN (#{subquery.to_sql}) AS category_expenses ON categories.id = category_expenses.category_id")
            .select('categories.name as category_name, COALESCE(category_expenses.total_amount, 0) as total_amount')
            .map { |expense| [expense.category_name, expense.total_amount] }
  end

  def current_date
    @current_date = Date.current
  end

  def set_date
    @date = if params[:month] && params[:year]
              Date.new(params[:year].to_i, params[:month].to_i)
            elsif params[:year]
              Date.new(params[:year].to_i, current_date.month)
            else
              current_date
            end
  end

  def setup_data
    @oldest_date = Expense.oldest_date || current_date
    @newest_date = Expense.newest_date || current_date
  end

  def get_average(period)
    if period == 'day'
      # selected month is in past
      if @date.beginning_of_month < current_date.beginning_of_month
        (@total / days_in_month(@date)).round(2)
      # selected month is the oldest_month
      elsif @date.beginning_of_month == @oldest_date.beginning_of_month
        (@total / (days_in_month(@date) - @date.day + 1)).round(2)
      # selected month is current month
      else
        (@total / @date.day).round(2)
      end
    elsif period == 'month'
      # selected year is in past
      if @date.year < current_date.year
        (@total / 12).round(2)
      # selected year is the oldest_year
      elsif @date.year == @oldest_date.year
        (@total / (
          12 - @oldest_date.month + (
            (days_in_month(@oldest_date) - @oldest_date.day + 1) \
            / days_in_month(@oldest_date)
          )
        )).round(2)
      # selected year is current year
      else
        (@total / (
          current_date.month - 1 + (
            current_date.day / days_in_month(current_date)
          )
        )).round(2)
      end
    elsif period == 'year'
      (@total / total_num_of_years).round(2)
    end
  end

  def days_in_month(date)
    Time.days_in_month(date.month, date.year)
  end

  def total_num_of_years
    (@oldest_date.year..@newest_date.year).count - 2 + (
      (((@oldest_date.end_of_year - @oldest_date).to_i + 1).to_f / Time.days_in_year(@oldest_date.year)) \
      + (((@newest_date - @newest_date.beginning_of_year).to_i + 1).to_f / Time.days_in_year(@newest_date.year))
    )
  end
end
