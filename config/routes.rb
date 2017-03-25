Rails.application.routes.draw do
  
  get 'books/index'

  get 'books/show'

  get 'books/new'

  get 'books/edit'

  root      'static_pages#home'
  get       '/about',       to: 'static_pages#about'
  get       '/signup',      to: 'users#new'
  get       '/login',       to: 'sessions#new'
  post      '/login',       to: 'sessions#create'
  delete    '/logout',      to: 'sessions#destroy'


  resources :users
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :books
end
