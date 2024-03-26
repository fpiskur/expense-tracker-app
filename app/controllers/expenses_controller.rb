# frozen_string_literal: true

class ExpensesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_expense, only: %i[show edit update destroy]
  before_action :set_categories, only: %i[new create edit update]
  before_action :set_areas, only: %i[new create edit update]

  def index
    @date = if params[:month] && params[:year]
              Date.new(params[:year].to_i, params[:month].to_i)
            elsif params[:month].nil? && params[:year]
              Date.new(params[:year].to_i, Date.current.month)
            elsif params[:month] && params[:year].nil?
              Date.new(Date.current.year, params[:month].to_i)
            else
              Date.new(Date.current.year, Date.current.month)
            end
    @expenses = Expense.get_expenses_by_period('month', month: @date.month, year: @date.year, ordered: true)
    @expenses = @expenses.group_by(&:date)
  end

  def show; end

  def new
    @expense = Expense.new
  end

  def create
    @expense = Expense.new(expense_params)
    @expense.category = Category.find(expense_params[:category_id]) if expense_params[:category_id].present?
    # @expense.build_category

    if @expense.save
      redirect_to expenses_path, notice: 'Expense was successfully created'
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            'expenses-form-errors',
            partial: 'shared/form_errors',
            locals: { object: @expense }
          )
        end
      end
    end
  end

  def edit; end

  def update
    if @expense.update(expense_params)
      redirect_to expenses_path, notice: 'Expense was successfully updated'
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            'expenses-form-errors',
            partial: 'shared/form_errors',
            locals: { object: @expense }
          )
        end
      end
    end
  end

  def destroy
    @expense.destroy
    redirect_to expenses_path, notice: 'Expense was successfully deleted'
  end

  private

  def set_expense
    @expense = Expense.find(params[:id])
  end

  def set_categories
    @parent_categories = Category.parent_categories
  end

  def set_areas
    @areas = Area.all
  end

  def expense_params
    params.require(:expense).permit(:date, :amount, :description, :category_id, area_ids: [])
  end
end
