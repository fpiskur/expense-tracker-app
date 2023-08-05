class StatsController < ApplicationController
  def index
    # GRAPH
    @filter = params[:period] || 'month' # 'year' / 'month' / 'day'
    period = case @filter
             when 'month'
               'day'
             when 'year'
               'month'
             when 'max'
               'year'
             end
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
    @category_data = Expense.joins(:category).where("EXTRACT(MONTH FROM date) = ?", 8)
                            .and(Expense.where("EXTRACT(YEAR FROM date) = ?", 2023))
                            .group('categories.name')
                            .sum('expenses.amount')

    @areas_data = Expense.joins(:areas).where("EXTRACT(MONTH FROM date) = ?", 8)
                         .and(Expense.where("EXTRACT(YEAR FROM date) = ?", 2023))
                         .group('areas.name')
                         .sum('expenses.amount')
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
