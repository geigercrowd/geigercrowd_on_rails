Geigercrowd::Application.routes.draw do
  resources :data_types
  resources :samples
  resources :instruments
  devise_for :users
  root :to => "samples#index"
end
