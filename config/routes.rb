Rails.application.routes.draw do
  root 'courses#index'
  resources :courses, :only => [:index, :show]
  resources :class_periods, :only => [:show, :update,:update_course_hash]
  resources :questions, :only => [:index, :show, :update]
  resources :data, :only => [:index]

  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  get    '/update_course_hash/:id', to: 'class_periods#update_course_hash'

  #get   '/update_course_hash', to: 'class_periods#update_course_hash'


#WHAT LOGAN SAYS:
#add the post url, then to table # method name
#that shoudl help with the problem
end
