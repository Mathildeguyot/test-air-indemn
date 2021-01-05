Rails.application.routes.draw do
  root to: 'pages#home'
  resources :depositions, only: [:create, :show, :new, :index]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
