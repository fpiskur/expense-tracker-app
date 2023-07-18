Rails.application.routes.draw do
  resources :areas
  resources :expenses
  resources :categories
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root 'home#index'
end
