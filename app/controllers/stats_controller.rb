class StatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_date

  def index
    # GRAPH
    @filter = params[:period] || 'month' # 'month' / 'year' / 'max'
    period = map_filter_to_period[@filter]

    @current_date = Date.current
    @oldest_date = Expense.oldest_date
    @newest_date = Expense.newest_date
    # group_by = 'category' / 'area'

    # INFO
    # info = 'sum/total' / 'average'

    # GENERAL
    @heading = 'Something went wrong, check the StatsController'

    get_relevant_data(period)
  end

  private

  def get_relevant_data(period)
    if period == 'day'
      handle_day_period
    elsif period == 'month'
      handle_month_period
    elsif period == 'year'
      handle_year_period
    end
  end

  # Filter: month
  def handle_day_period
    year = @date.year
    month = @date.month

    @heading = Date.new(year, month).strftime('%B %Y.')

    @total = Expense.get_total_for_period(month: month, year: year)
    @total_average = get_average('day')
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
                      .group("categories.parent_id, COALESCE(categories.parent_id, categories.id)")
                      .select("COALESCE(categories.parent_id, categories.id) AS category_id, SUM(amount) AS total_amount")
    @parent_category_data = get_parent_category_data(subquery)
  end

  # Filter: year
  def handle_month_period
    year = @date.year

    @heading = "#{year}."

    @total = Expense.get_total_for_period(year: year)
    @total_average = get_average('month')
    @time_period = '€/month'

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
                      .group("categories.parent_id, COALESCE(categories.parent_id, categories.id)")
                      .select("COALESCE(categories.parent_id, categories.id) AS category_id, SUM(amount) AS total_amount")
    @parent_category_data = get_parent_category_data(subquery)
  end

  # Filter: max
  def handle_year_period
    min_year = @oldest_date.year
    max_year = @newest_date.year

    @heading = 'Max period'

    @total = Expense.get_total_for_period
    @total_average = get_average('year')
    @time_period = '€/year'

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
                      .group("categories.parent_id, COALESCE(categories.parent_id, categories.id)")
                      .select("COALESCE(categories.parent_id, categories.id) AS category_id, SUM(amount) AS total_amount")
    @parent_category_data = get_parent_category_data(subquery)
  end

  def get_areas_data(areas_expenses, total)
    other_expenses = total - areas_expenses.values.sum
    areas_expenses.merge('No area' => other_expenses)
  end

  def get_parent_category_data(subquery)
    Category.where(parent_id: nil)
            .joins("LEFT JOIN (#{subquery.to_sql}) AS category_expenses ON categories.id = category_expenses.category_id")
            .select("categories.name as category_name, COALESCE(category_expenses.total_amount, 0) as total_amount")
            .map { |expense| [expense.category_name, expense.total_amount] }
  end

  def map_filter_to_period
    {
      'month' => 'day',
      'year' => 'month',
      'max' => 'year'
    }
  end

  def set_date
    if params[:month] && params[:year]
      @date = Date.new(params[:year].to_i, params[:month].to_i)
    elsif params[:year]
      @date = Date.new(params[:year].to_i, @current_date.month)
    else
      @date = @current_date
    end
  end

  def get_average(period)
    if period == 'day'
      # selected month is in past
      if @date.beginning_of_month < @current_date.beginning_of_month
        (@total / Time.days_in_month(@date.month, @date.year)).round(2)
      # selected month is the oldest_month
      elsif @date.beginning_of_month == @oldest_date.beginning_of_month
        (@total / (Time.days_in_month(@date.month, @date.year) - @date.day + 1)).round(2)
      # selected month is current month
      else
        (@total / @date.day).round(2)
      end
    elsif period == 'month'
      # selected year is in past
      if @date.year < @current_date.year
        (@total / 12).round(2)
      # selected year is the oldest_year
      elsif @date.year == @oldest_date.year
        (@total / (
          12 - @oldest_date.month + (
            (Time.days_in_month(@oldest_date.month, @oldest_date.year) - @oldest_date.day + 1) \
            / Time.days_in_month(@oldest_date.month, @oldest_date.year)
          )
        )).round(2)
      # selected year is current year
      else
        (@total / (
          @current_date.month - 1 + (
            @current_date.day / Time.days_in_month(@current_date.month, @current_date.year)
          )
        )).round(2)
      end
    elsif period == 'year'
      (@total / (
        (@oldest_date.year..@newest_date.year).count - 2 + (
          (((@oldest_date.end_of_year - @oldest_date).to_i + 1) / Time.days_in_year(@oldest_date.year)) \
          + (((@newest_date - @newest_date.beginning_of_year).to_i + 1) / Time.days_in_year(@newest_date.year))
        )
      )).round(2)
    end
  end
end
