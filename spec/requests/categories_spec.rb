# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Categories', type: :request do
  let(:user) { create(:user) }
  let(:parent_category) { create(:category) }

  before do
    sign_in user
    create(:category)
    5.times do
      create(:category, parent_id: parent_category.id)
    end
  end

  context 'index action' do
    it 'should render index page' do
      get categories_path
      expect(response).to render_template :index
    end

    it 'should populate @categories with all available categories' do
      get categories_path
      expect(assigns(:categories).count).to eq(7)
    end
  end

  context 'new action' do
    it 'should render new page' do
      get new_category_path
      expect(response).to render_template :new
    end

    it 'should populate @category with an instance of Category' do
      get new_category_path
      expect(assigns(:category).class).to eq(Category)
    end

    it 'should populate @parent_categories with all available parent categories' do
      get new_category_path
      expect(assigns(:parent_categories).count).to eq(2)
    end
  end

  context 'create action' do
    it 'should create parent category with valid attributes' do
      post '/categories', params: { category: FactoryBot.attributes_for(:category) }
      expect(response).to redirect_to categories_path
      expect(flash[:notice]).to eq('Category was successfully created')
    end

    it 'should create child category with valid attributes' do
      post '/categories', params: { category: FactoryBot.attributes_for(:category, parent_id: parent_category.id) }
      expect(response).to redirect_to categories_path
      expect(flash[:notice]).to eq('Category was successfully created')
    end

    it 'should not create a category with invalid attributes' do
      post '/categories', params: { category: FactoryBot.attributes_for(:category, name: nil) }
      expect(response).to render_template :new
      expect(flash[:notice]).to eq(nil)
    end

    it 'should populate @parent_categories with all available parent categories' do
      post '/categories', params: { category: FactoryBot.attributes_for(:category, name: nil) }
      expect(assigns(:parent_categories).count).to eq(2)
    end
  end

  context 'edit action' do
    let(:child_category) { create(:category, parent_id: parent_category.id) }

    it 'should render edit page after editing parent category' do
      get edit_category_path(parent_category)
      expect(response).to render_template :edit
    end

    it 'should render edit page after editing child category' do
      get edit_category_path(child_category)
      expect(response).to render_template :edit
    end

    it 'should forward correct info to the view' do
      get edit_category_path(parent_category)
      expect(assigns(:category).name).to eq(parent_category.name)
    end

    it 'should populate @parent_categories with all available parent categories' do
      get edit_category_path(child_category)
      expect(assigns(:parent_categories).count).to eq(2)
    end
  end

  context 'update action' do
    let(:child_category) { create(:category, parent_id: parent_category.id) }
    let(:other_parent_category) { create(:category) }

    it 'should update a parent category with valid attributes' do
      patch "/categories/#{parent_category.id}", params: { category: FactoryBot.attributes_for(:category) }
      expect(response).to redirect_to categories_path
      expect(flash[:notice]).to eq('Category was successfully updated')
    end

    it 'should change a parent category to child category' do
      patch "/categories/#{parent_category.id}",
            params: { category: FactoryBot.attributes_for(:category, parent_id: other_parent_category.id) }
      expect(response).to redirect_to categories_path
      expect(flash[:notice]).to eq('Category was successfully updated')
      expect(parent_category.reload.parent_category).to_not be_nil
    end

    it 'should update a child category with valid attributes' do
      patch "/categories/#{child_category.id}",
            params: { category: FactoryBot.attributes_for(:category, parent_id: parent_category.id) }
      expect(response).to redirect_to categories_path
      expect(flash[:notice]).to eq('Category was successfully updated')
    end

    it 'should change a child category to parent category' do
      patch "/categories/#{child_category.id}",
            params: { category: FactoryBot.attributes_for(:category) }
      expect(response).to redirect_to categories_path
      expect(flash[:notice]).to eq('Category was successfully updated')
      expect(parent_category.reload.parent_category).to be_nil
    end

    it 'should not update a category with invalid attributes' do
      patch "/categories/#{parent_category.id}", params: { category: FactoryBot.attributes_for(:category, name: nil) }
      expect(response).to render_template :edit
      expect(flash[:notice]).to eq(nil)
    end
  end

  context 'destroy action' do
    let(:child_category) { create(:category, parent_id: parent_category.id) }

    it 'should destroy a child category' do
      delete "/categories/#{child_category.id}"
      expect(response).to redirect_to categories_path
      expect(flash[:notice]).to eq('Category was successfully deleted')
    end

    it "should destroy a parent category with it's children" do
      delete "/categories/#{parent_category.id}"
      expect(response).to redirect_to categories_path
      expect(flash[:notice]).to eq('Category was successfully deleted')
      expect(Category.count).to be(1)
    end
  end
end
