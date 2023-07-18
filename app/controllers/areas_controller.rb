class AreasController < ApplicationController
  before_action :set_area, only: [:show, :edit, :update, :destroy]

  def index
    @areas = Area.all
  end

  def show; end

  def new
    @area = Area.new
  end

  def create
    @area = Area.new(area_params)

    if @area.save
      redirect_to areas_path, notice: 'Area was successfully created'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @area.update(area_params)
      redirect_to areas_path, notice: 'Area was successfully updated'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @area.destroy
    redirect_to areas_path, notice: 'Area was successfully deleted'
  end

  private

  def set_area
    @area = Area.find(params[:id])
  end

  def area_params
    params.require(:area).permit(:name)
  end
end
