Rails.application.routes.draw do
  get 'sessions/index'

  get 'sessions/show'

  root 'courses#index'
  resources :courses, :only => [:index, :show]
  resources :sessions, :only => [:show]
  # FIXME Edit will let us add the correct answers, or should this be
  #   part of show? Have to figure out how to use RESTful here.
  resources :questions, :only => [:show, :edit]

  # For details on the DSL available within this file,
  #   see http://guides.rubyonrails.org/routing.html
end
