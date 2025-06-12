Rails.application.routes.draw do
  devise_for :users

  root 'products#index'

  resources :products, only: [:index, :show] do
    collection do
      get :search
      get :categories
      get :autocomplete
    end
  end

  resources :orders, only: [:index, :show, :new, :create] do
    member do
      patch :cancel
    end
    collection do
      get :current, to: 'orders#cart'
      post :add_item
      delete :remove_item
      patch :update_item
    end
  end
  get 'checkout', to: 'orders#checkout'
  post 'orders', to: 'orders#create'  # For processing the order

  get 'cart', to: 'orders#cart'

  get "up" => "rails/health#show", as: :rails_health_check
end
