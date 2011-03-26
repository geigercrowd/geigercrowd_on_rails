Geigercrowd::Application.routes.draw do
  resources :data_types
  resources :instruments do
    resources :samples
  end
  resources :locations
  devise_for :users
  root :to => "instruments#index"
end
