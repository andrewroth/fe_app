Rails.application.routes.draw do
  match '/auth/:provider/callback' => 'sessions#create', via: :get
  match '/auth/:provider/logout' => 'sessions#logout_callback', via: :get
  match '/auth/failure' => 'sessions#failure', via: :get
  match '/logout' => "sessions#destroy", :as => :logout, via: [:get, :post, :delete]
  resources :sessions

  resources :applications
  root 'applications#index'
end
