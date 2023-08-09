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

    @data = get_relevant_data(period, selected_option)

    # Temporary, example of how it works - try to refactor the get_expenses_by_date method so you can use it here
    @sub_category_data = Expense.joins(:category).where("EXTRACT(MONTH FROM date) = ?", 6)
                                .where("EXTRACT(YEAR FROM date) = ?", 2023)
                                .group('categories.name')
                                .sum('expenses.amount')

    # @parent_category_data = Expense.joins(:category).where("EXTRACT(MONTH FROM date) = ?", 6)
    #                           .where("EXTRACT(YEAR FROM date) = ?", 2023)
    #                           .group('categories.parent_id')
    #                           .sum('expenses.amount')

    # Check ChatGPT history for a refactored version or make your own
    @parent_category_data = Category.where(parent_id: nil)
                                .joins("LEFT JOIN (
                                        SELECT COALESCE(categories.parent_id, categories.id) AS category_id, SUM(expenses.amount) AS total_amount
                                        FROM categories
                                        LEFT JOIN expenses ON categories.id = expenses.category_id
                                        WHERE expenses.date >= '2023-06-01' AND expenses.date <= '2023-06-30'
                                        GROUP BY COALESCE(categories.parent_id, categories.id)
                                      ) AS category_expenses ON categories.id = category_expenses.category_id")
                                .select('categories.name as category_name, COALESCE(category_expenses.total_amount, 0) as total_amount')
                                .map { |expense| [expense.category_name, expense.total_amount] }

    areas_expenses = Expense.joins(:areas).where("EXTRACT(MONTH FROM date) = ?", 6)
                            .where("EXTRACT(YEAR FROM date) = ?", 2023)
                            .group('areas.name')
                            .sum('expenses.amount')
    total_expenses_for_period = Expense.where("EXTRACT(MONTH FROM date) = ?", 6)
                                       .where("EXTRACT(YEAR FROM date) = ?", 2023)
                                       .sum(:amount)
    other_expenses = total_expenses_for_period - areas_expenses.values.sum
    @areas_data = areas_expenses.merge('No area' => other_expenses)
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
    @total = Expense.get_expenses_by_date(month: month, year: year).sum(:amount)

    Expense.group_by_period('day', :date,
                                   range: Date.new(year, month)..Date.new(year, month).end_of_month)
                                   .sum(:amount)
  end

  # Filter: year
  def handle_month_period(selected_option)
    year = Date.current.year
    year = selected_option.to_i if selected_option

    @heading = "#{year}."

    Expense.group_by_period('month', :date,
                                     range: Date.new(year)..Date.new(year).end_of_year)
                                     .sum(:amount)
  end

  # Filter: max
  def handle_year_period
    min_year = Expense.oldest_date.year
    max_year = Expense.newest_date.year

    @heading = 'Max period'

    Expense.group_by_period('year', :date,
                                    range: Date.new(min_year)..Date.new(max_year).end_of_year)
                                    .sum(:amount)
  end
end
