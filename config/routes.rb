Rails.application.routes.draw do
  resources :companies, only: [:index]
  root to: 'companies#index'
end
