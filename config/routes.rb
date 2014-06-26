Rails.application.routes.draw do
  devise_for :users

  root :to => 'info_pages#index', via: [:get, :post]
  match '/info_pages' => 'info_pages#index', via: [:get, :post]
  match '/info_pages/index' => 'info_pages#index', via: [:get, :post]
  match '/info_pages/home' => 'info_pages#home', via: [:get, :post]
  match '/info_pages/instructions' => 'info_pages#instructions', via: [:get, :post]
end
