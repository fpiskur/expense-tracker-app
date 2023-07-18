class ExpensesController < ApplicationController
  before_action :set_expense, only: [:show, :edit, :update, :destroy]
  before_action :set_categories, only: [:new, :create, :edit, :update]
  before_action :set_areas, only: [:new, :create, :edit, :update]

  def index
    @expenses = Expense.all
  end

  def show; end

  def new
    @expense = Expense.new
  end

  def create
    @expense = Expense.new(expense_params)
    @expense.category = Category.find(expense_params[:category_id]) if expense_params[:category_id].present?

    if @expense.save
      redirect_to expenses_path, notice: 'Expense was successfully created'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @expense.update(expense_params)
      redirect_to expenses_path, notice: 'Expense was successfully updated'
    else
      render :edit, status: :unprocessable_entity
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
