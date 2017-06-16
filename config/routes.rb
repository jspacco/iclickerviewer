Rails.application.routes.draw do
  root 'courses#index'
  resources :courses, :only => [:index, :show]
  resources :sessions, :only => [:show, :update]

  # FIXME Edit will let us add the correct answers, or should this be
  #   part of show? Have to figure out how to use RESTful here.
#  resources :questions, :only => [:show, :update]

  # For details on the DSL available within this file,
  #   see http://guides.rubyonrails.org/routing.html
end
