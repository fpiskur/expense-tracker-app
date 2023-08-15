Rails.application.routes.draw do
  resources :areas
  resources :expenses
  resources :categories
  resources :stats, only: [:index]
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root 'stats#index'
end
