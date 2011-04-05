Geigercrowd::Application.routes.draw do
  resources :data_types
  resources :locations
  resources :user do
    resources :instruments do
      resources :samples
    end
  end
  
  devise_for :users
  root :to => "instruments#index"
end
