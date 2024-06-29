# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Areas', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  context 'index action' do
    before do
      5.times do
        create(:area)
      end
    end

    it 'should render index page' do
      get areas_path
      expect(response).to render_template :index
    end

    it 'should populate @areas with all available areas' do
      get areas_path
      expect(assigns(:areas).count).to eq(5)
    end
  end

  context 'new action' do
    it 'should render new page' do
      get new_area_path
      expect(response).to render_template :new
    end

    it 'should populate @area with an instance of Area' do
      get new_area_path
      expect(assigns(:area).class).to eq(Area)
    end
  end

  context 'create action' do
    it 'should create an area with valid attributes' do
      post '/areas', params: { area: FactoryBot.attributes_for(:area) }
      expect(response).to redirect_to areas_path
      expect(flash[:notice]).to eq('Area was successfully created')
    end

    it 'should not create an area with invalid attributes' do
      post '/areas', params: { area: FactoryBot.attributes_for(:area, name: nil) }
      expect(response).to render_template :new
      expect(flash[:notice]).to eq(nil)
    end
  end

  context 'edit action' do
    let(:area) { create(:area, name: 'Test Area') }

    it 'should render edit page' do
      get edit_area_path(area)
      expect(response).to render_template :edit
    end

    it 'should forward correct info to the view' do
      get edit_area_path(area)
      expect(assigns(:area).name).to eq(area.name)
    end
  end

  context 'update action' do
    let(:area) { create(:area, name: 'Test Area') }

    it 'should update an area with valid attributes' do
      patch "/areas/#{area.id}", params: { area: FactoryBot.attributes_for(:area) }
      expect(response).to redirect_to areas_path
      expect(flash[:notice]).to eq('Area was successfully updated')
    end

    it 'should not update an area with invalid attributes' do
      patch "/areas/#{area.id}", params: { area: FactoryBot.attributes_for(:area, name: nil) }
      expect(response).to render_template :edit
      expect(flash[:notice]).to eq(nil)
    end
  end

  context 'destroy action' do
    let(:area) { create(:area) }

    it 'should destroy an area' do
      delete "/areas/#{area.id}"
      expect(response).to redirect_to areas_path
      expect(flash[:notice]).to eq('Area was successfully deleted')
    end
  end
end
