class StatsController < ApplicationController
  def index
    # GRAPH
    @filter = params[:period] || 'month' # 'year' / 'month' / 'day'
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

    # GENERAL
    @heading = 'Something went wrong, check the StatsController'
    # options = [months] / [years]
    selected_option = params[:selected_option]

    get_relevant_data(period, selected_option)

    start_date = Date.new(2023, 6, 1)
    end_date = Date.new(2023, 6, 30)
    #####################################
    # THE ORIGINAL RESPONSE, NON-DYNAMIC
    #####################################
    # @parent_category_data = Category.where(parent_id: nil)
    #                             .joins("LEFT JOIN (
    #                                     SELECT COALESCE(categories.parent_id, categories.id) AS category_id, SUM(expenses.amount) AS total_amount
    #                                     FROM categories
    #                                     LEFT JOIN expenses ON categories.id = expenses.category_id
    #                                     WHERE expenses.date >= '2023-6-1' AND expenses.date <= '2023-6-30'
    #                                     GROUP BY COALESCE(categories.parent_id, categories.id)
    #                                   ) AS category_expenses ON categories.id = category_expenses.category_id")
    #                             .select('categories.name as category_name, COALESCE(category_expenses.total_amount, 0) as total_amount')
    #                             .map { |expense| [expense.category_name, expense.total_amount] }
    #####################################

    # This version is vulnerable to SQL injections, see how you can sanitize the date inputs
    # query = <<-SQL
    #   SELECT categories.name as category_name, COALESCE(category_expenses.total_amount, 0) as total_amount
    #   FROM categories
    #   LEFT JOIN (
    #     SELECT COALESCE(categories.parent_id, categories.id) AS category_id, SUM(expenses.amount) AS total_amount
    #     FROM categories
    #     LEFT JOIN expenses ON categories.id = expenses.category_id
    #     WHERE expenses.date >= ? AND expenses.date <= ?
    #     GROUP BY COALESCE(categories.parent_id, categories.id)
    #   ) AS category_expenses ON categories.id = category_expenses.category_id
    #   WHERE categories.parent_id IS NULL
    # SQL
    # @parent_category_data = Category.find_by_sql([query, start_date, end_date])
    #                             .map { |expense| [expense.category_name, expense.total_amount] }

    # This version should be resistant to SQL injections
    subquery = Expense.where(date: start_date..end_date)
                    .joins(:category)
                    .group("categories.parent_id, COALESCE(categories.parent_id, categories.id)")
                    .select("COALESCE(categories.parent_id, categories.id) AS category_id, SUM(amount) AS total_amount")

    @parent_category_data = Category.where(parent_id: nil)
                                    .joins("LEFT JOIN (#{subquery.to_sql}) AS category_expenses ON categories.id = category_expenses.category_id")
                                    .select("categories.name as category_name, COALESCE(category_expenses.total_amount, 0) as total_amount")
                                    .map { |expense| [expense.category_name, expense.total_amount] }
  end

  private

  def get_relevant_data(period, selected_option)
    if period == 'day'
      handle_day_period(selected_option)
    elsif period == 'month'
      handle_month_period(selected_option)
    elsif period == 'year'
      handle_year_period
    end
  end

  # Filter: month
  def handle_day_period(selected_option)
    year = Date.current.year
    month = Date.current.month
    year = JSON.parse(selected_option)[1].to_i if selected_option
    month = JSON.parse(selected_option)[0].to_i if selected_option

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
  end

  # Filter: year
  def handle_month_period(selected_option)
    year = Date.current.year
    year = selected_option.to_i if selected_option

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
end
