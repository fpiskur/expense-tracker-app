# frozen_string_literal: true

class CategoriesController < ApplicationController
  before_action :set_category, only: %i[show edit update destroy]
  before_action :set_parent_categories, only: %i[new create edit update]

  def index
    @categories = Category.all
  end

  # def show; end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to categories_path, notice: 'Category was successfully created'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: 'Category was successfully updated'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_path, notice: 'Category was successfully deleted'
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def set_parent_categories
    @parent_categories = Category.parent_categories
  end

  def category_params
    params.require(:category).permit(:name, :parent_id)
  end
end
