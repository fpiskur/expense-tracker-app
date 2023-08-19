class StatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_date

  def index
    # GRAPH
    @filter = params[:period] || 'month' # 'month' / 'year' / 'max'
    period = map_filter_to_period[@filter]
    # range_start =
    # range_end =
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
    @total_average = (@total / Time.days_in_month(month, year)).round(2)
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
    @total_average = (@total / 12).round(2)
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
    min_year = Expense.oldest_date.year
    max_year = Expense.newest_date.year

    @heading = 'Max period'

    @total = Expense.get_total_for_period
    @total_average = (@total / (Expense.oldest_date.year..Expense.newest_date.year).count).round(2)
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
      @date = Date.new(params[:year].to_i, Date.current.month)
    else
      @date = Date.current
    end
  end

  def get_average
    # period: day, selected month is in past
    # -> (@total / Time.days_in_month(month, year)).round(2)

    # period: day, selected month is the oldest_month
    # -> @total / (days since oldest to end of oldest_month).round(2)

    # period: day, selected month is current month
    # -> (@total / days past since beginning of month, including current day).round(2)



    # period: month, selected year is in past
    # -> (@total / 12).round(2)

    # period: month, selected year is the oldest_year (no data from beginning, started mid-year)
    # -> @total / (
      # number of months from oldest to end of year, not including the oldest
      # + (number of days from oldest_date to end of oldest_month / number of days in oldest_month)
    # ).round(2)

    # period: month, selected year is current year
    # -> @total / (
      # months past since beggining of year, not including current month
      # + (days_since_beginning_of_month_including_current_day / number_of_days_in_current_month)
    # ).round(2)



    # period: year (max)
    # (@total / (
      # number of years between oldest and newest, not including oldest or newest
      # + (number of days since oldest_date to end of that year / number of days in that year)
      # + (number of days since beggining of newest year to newest_date / number of days in that year)
    # ).round(2)
  end
end
