class StatsController < ApplicationController
  def index
    # GRAPH
    @filter = params[:period] || 'month' # 'month' / 'year' / 'max'
    filter_to_period_map = {
      'month' => 'day',
      'year' => 'month',
      'max' => 'year'
    }
    period = filter_to_period_map[@filter]
    # range_start =
    # range_end =
    # group_by = 'category' / 'area'

    # INFO
    # info = 'sum/total' / 'average'

    if params[:month] && params[:year]
      @date = Date.new(params[:year].to_i, params[:month].to_i)
    elsif params[:year]
      @date = Date.new(params[:year].to_i, Date.current.month)
    else
      @date = Date.current
    end

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
    @total = total_expenses_for_period(month: month, year: year)

    @data = Expense.group_by_period('day', :date,
                                   range: Date.new(year, month)..Date.new(year, month).end_of_month)
                                   .sum(:amount)
    @sub_category_data = Expense.get_expenses_by_period('month', month: month, year: year)
                                .joins(:category)
                                .group('categories.name')
                                .sum('expenses.amount')
    other_expenses = @total - areas_expenses(month: month, year: year).values.sum
    @areas_data = areas_expenses(month: month, year: year).merge('No area' => other_expenses)

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
    @total = total_expenses_for_period(year: year)

    @data = Expense.group_by_period('month', :date,
                                     range: Date.new(year)..Date.new(year).end_of_year)
                                     .sum(:amount)
    @sub_category_data = Expense.get_expenses_by_period('year', year: year)
                                .joins(:category)
                                .group('categories.name')
                                .sum('expenses.amount')
    other_expenses = @total - areas_expenses(year: year).values.sum
    @areas_data = areas_expenses(year: year).merge('No area' => other_expenses)

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
    @total = total_expenses_for_period

    @data = Expense.group_by_period('year', :date,
                                    range: Date.new(min_year)..Date.new(max_year).end_of_year)
                                    .sum(:amount)
    @sub_category_data = Expense.all
                                .joins(:category)
                                .group('categories.name')
                                .sum('expenses.amount')
    other_expenses = @total - areas_expenses.values.sum
    @areas_data = areas_expenses.merge('No area' => other_expenses)

    subquery = Expense.all
                      .joins(:category)
                      .group("categories.parent_id, COALESCE(categories.parent_id, categories.id)")
                      .select("COALESCE(categories.parent_id, categories.id) AS category_id, SUM(amount) AS total_amount")
    @parent_category_data = get_parent_category_data(subquery)
  end

  def areas_expenses(month: nil, year: nil)
    if month
      Expense.get_expenses_by_period('month', month: month, year: year)
            .joins(:areas)
            .group('areas.name')
            .sum('expenses.amount')
    elsif year
      Expense.get_expenses_by_period('year', year: year)
            .joins(:areas)
            .group('areas.name')
            .sum('expenses.amount')
    else
      Expense.all
             .joins(:areas)
             .group('areas.name')
             .sum('expenses.amount')
    end
  end

  def total_expenses_for_period(month: nil, year: nil)
    if month
      Expense.get_expenses_by_period('month', month: month, year: year)
             .sum(:amount)
    elsif year
      Expense.get_expenses_by_period('year', year: year)
             .sum(:amount)
    else
      Expense.all.sum(:amount)
    end
  end

  def get_parent_category_data(subquery)
    Category.where(parent_id: nil)
            .joins("LEFT JOIN (#{subquery.to_sql}) AS category_expenses ON categories.id = category_expenses.category_id")
            .select("categories.name as category_name, COALESCE(category_expenses.total_amount, 0) as total_amount")
            .map { |expense| [expense.category_name, expense.total_amount] }
  end
end
