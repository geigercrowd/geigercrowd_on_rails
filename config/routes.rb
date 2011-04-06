Geigercrowd::Application.routes.draw do
  resources :data_types
  resources :locations
  resources :user do
    resources :instruments do
      resources :samples
    end
  end
  
  devise_for :users
  root :to => "welcome#index"
  match "instruments(/:option)" => "instruments#list"
  match "samples(/:option)" => "samples#list"
end
