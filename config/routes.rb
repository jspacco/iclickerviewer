Rails.application.routes.draw do
  root 'courses#index'
  resources :courses, :only => [:index, :show]
  resources :sessions, :only => [:show, :update]
end
