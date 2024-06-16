# frozen_string_literal: true

Rails.application.routes.draw do
  resources :areas
  resources :expenses
  resources :categories
  # resources :stats, only: [:index]
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root 'stats#month'
  get 'stats/month', to: 'stats#month'
  get 'stats/year', to: 'stats#year'
  get 'stats/max', to: 'stats#max'
end
