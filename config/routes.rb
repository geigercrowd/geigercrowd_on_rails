Geigercrowd::Application.routes.draw do
  resources :data_types
  resources :locations
  resources :instruments do
    resources :samples
  end
  devise_for :users
  root :to => "instruments#index"
end
