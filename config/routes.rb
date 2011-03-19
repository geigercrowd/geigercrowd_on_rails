Geigercrowd::Application.routes.draw do
  get "location/edit"

  get "location/new"

  get "location/show"

  get "location/delete"

  resources :data_types
  resources :samples
  resources :instruments
  resources :locations
  devise_for :users
  root :to => "samples#index"
end
