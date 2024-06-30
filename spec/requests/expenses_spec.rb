# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Expenses', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }

  before do
    sign_in user
  end

  context 'index action with no expenses' do
    it 'should render index page' do
      get expenses_path
      expect(response).to render_template :index
    end
  end

  context 'index action with expenses' do
    before do
      travel_to Date.new(2024, 1, 24)

      create(:expense, date: Date.new(2023, 4, 21))
      create(:expense, date: Date.new(2023, 4, 25))

      create(:expense, date: Date.new(2024, 1, 12))
      create(:expense, date: Date.new(2024, 1, 18))
      create(:expense, date: Date.new(2024, 1, 23))
      create(:expense, date: Date.new(2024, 5, 3))

      create(:expense, date: Date.new(2025, 11, 7))
    end

    it "should populate @expenses with current month's expenses when no params are given" do
      get expenses_path
      expect(assigns(:expenses).count).to eq(3)
    end

    it "should populate @expenses with given month's expenses when params are given" do
      get expenses_path, params: { year: 2023, month: 4 }
      expect(assigns(:expenses).count).to eq(2)
    end
  end

  context 'new action' do
    it 'should render new page' do
      get new_expense_path
      expect(response).to render_template :new
    end

    it 'should populate @expense with an instance of Expense' do
      get new_expense_path
      expect(assigns(:expense).class).to eq(Expense)
    end
  end

  context 'create action' do
    let(:category) { create(:category) }
    let(:area) { create(:area) }

    it 'should create expense with valid arguments' do
      post '/expenses', params: { expense: FactoryBot.attributes_for(:expense, category_id: category.id) }
      expect(response).to redirect_to expenses_path
      expect(flash[:notice]).to eq('Expense was successfully created')
    end

    it 'should create expense with area assigned' do
      post '/expenses',
           params: { expense: FactoryBot.attributes_for(:expense, category_id: category.id, area_ids: [area.id]) }
      expect(response).to redirect_to expenses_path
      expect(flash[:notice]).to eq('Expense was successfully created')
      expect(Expense.last.areas.first).to eq(area)
    end

    it 'should not create expense with invalid arguments' do
      post '/expenses', params: { expense: FactoryBot.attributes_for(:expense, category_id: category.id, amount: nil) }
      expect(response).to render_template :new
      expect(flash[:notice]).to eq(nil)
    end
  end
end
