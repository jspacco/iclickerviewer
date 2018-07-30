Rails.application.routes.draw do
  #get 'admin/change_verification'
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks"}
  root 'courses#index'
  resources :courses, :only => [:index, :show]
  resources :class_periods, :only => [:show, :update, :update_course_hash]
  resources :questions, :only => [:index, :show, :update]
  resources :data, :only => [:index]
  resources :admin, :only => [:index]
  #get    '/change_verification' => 'admin'
  patch '/admin', to: 'admin#update'

  get    '/update_course_hash/:id', to: 'class_periods#update_course_hash'
  #get   '/update_course_hash', to: 'class_periods#update_course_hash'

#WHAT LOGAN SAYS:
#add the post url, then to table # method name
#that shoudl help with the problem
end
