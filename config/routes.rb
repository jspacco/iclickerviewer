Rails.application.routes.draw do
  root 'courses#index'
  resources :courses, :only => [:index, :show]
  resources :class_periods, :only => [:show, :update]
end
