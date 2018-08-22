Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks"}
  root 'courses#index'
  resources :courses, :only => [:index, :show]
  resources :class_periods, :only => [:show, :update, :update_course_hash]
  resources :questions, :only => [:index, :show, :update]
  resources :admin, :only => [:index]
  resources :clusters, :only => [:show]
  patch '/admin', to: 'admin#update'
  get   '/update_course_hash/:id', to: 'class_periods#update_course_hash'
  # download csv data paths
  resources :data, :only => [:index]
  get   '/data', to: 'data#index'
  get   '/data/match', to: 'data#match_data'
  # AJAX paths
  get   '/ajax/courses/:id', to: 'ajax#show_course'
  get   '/ajax/courses', to: 'ajax#show_all_courses'
end
