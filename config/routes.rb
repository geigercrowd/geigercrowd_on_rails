Geigercrowd::Application.routes.draw do
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
  devise_for :user #, :path_prefix => 'd'
  root :to => "welcome#index"
  match "instruments" => "instruments#list"
  match "samples(/:option)" => "samples#list"
  match "api" => "welcome#api"
  match "api/public" => "welcome#api_public"
  match "api/private" => "welcome#api_private"
end
