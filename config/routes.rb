Soundmelon::Application.routes.draw do
  get "profile/additional_info"

  get 'logout' => 'sessions#destroy', :as => 'logout'
  post 'login' => 'sessions#create', :as => 'login'
  get 'users' => 'users#index', :as => 'user_home'
  match 'fan/registration' => 'users#fan_new', :as => 'fan_registration'
  match 'musician/registration' => 'users#musician_new', :as => 'musician_registration'
  get 'users/:id/activate' => 'users#activate', :as => 'user_activation'
  post 'add/additional_info' => 'profile#add_additional_info', :as => 'create_additional_info'
  post 'add/payment_info' => 'profile#add_payment_info', :as => 'create_payment_info'
  match "invite/bandmates" => "profile#invite_bandmates" ,:as => "invite_band_member"
  
  #get 'fan/sign_up/message' => 'users#fan_signup_sucessful_info', :as => successful_fan_signup
  #get 'musician/sign_up/message' => 'users#musician_signup_sucessful_info', :as => successful_musician_signup
  
  root :to => 'home#index'
  
  match ':controller(/:action(/:id(.:format)))'
end
