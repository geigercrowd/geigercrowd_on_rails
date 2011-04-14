Geigercrowd::Application.routes.draw do
  devise_for :users
  resources :data_types
  resources :locations
  resources :users do
    resources :instruments do
      resources :samples
    end
  end

  resources :sources, :as => 'data_sources' do
    resources :instruments do
      resources :samples
    end
  end

  root :to => "welcome#index"
  match "instruments" => "instruments#list", as: :instruments
  match "samples" => "samples#search", as: :samples, via: :get
  match "samples/find" => "samples#find", as: :find_samples, via: :post
  match "api" => "welcome#api"
  match "api/public" => "welcome#api_public"
  match "api/private" => "welcome#api_private"
end
