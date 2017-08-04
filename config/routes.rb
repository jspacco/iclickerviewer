Rails.application.routes.draw do
  root 'courses#index'
  resources :courses, :only => [:index, :show]
  resources :class_periods, :only => [:show, :update]
  resources :questions, :only => [:index, :show, :update]

  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
end
