Soundmelon::Application.routes.draw do
  
  get 'follow/user/:id' => 'follow#follow', :as => 'follow_user'

  get 'user/(:id)/follower' => 'follow#follower', :as => 'user_follower'

  get 'unfollow/user/:id' => 'follow#unfollow', :as => 'unfollow_user'
  
  get 'user/(:id)/following' => 'follow#following', :as => 'user_following'

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
  #get "invite/accept/:id/join" => "profile#activate_invitation" ,:as => "join_band_invitation"
  match 'invitation/accept/:old_user/:id/join' => 'profile#activate_invitation' ,:as => 'join_band_invitation'
  match "messages/sendmessage" => 'messages#send_message',:as=>"send_message" 
  match 'user/profile/:id' => 'profile#user_profile',:as => 'user_profile'
  match 'messages/inbox' => 'messages#inbox' ,:as => 'user_inbox' 
  resources :user_posts
  resources :messages
  match 'message/reply' => 'messages#reply' ,:as => 'reply_to_message'
  match 'user_posts/more(/:page)'   =>'user_posts#index', :as =>:more_post

  #avatar
  post 'profile/pic/add' => 'avatar#create', :as => 'add_avatar'
  get 'profile/pic/new' => 'avatar#new', :as => 'new_avatar'
  match 'profile/pic/crop' => 'avatar#crop', :as => 'crop_avatar'
  match 'profile/pic/update' => 'avatar#update', :as => 'update_avatar'
  get 'profile/pic/delete' => 'avatar#delete', :as => 'delete_avatar'
 # match 'profile/pic/delete' => 'avatar#delete', :as => 'delete_avatar'

  resources :photos
  get 'albums' => 'photos#albums', :as => 'albums'
  get 'album/photos/:album_name' => 'photos#album_photos', :as => 'album_photos'
  get ':album_name/photo/:id' => 'photos#show', :as => 'album_photo'
  #invitation 
  match 'contacs/fetch' => "invite#fetch_contacts", :as => 'fetch_contacts'
  post 'send/invitation' => "invite#send_invitation", :as => 'send_invitation'
 


  #get 'fan/sign_up/message' => 'users#fan_signup_sucessful_info', :as => successful_fan_signup
  #get 'musician/sign_up/message' => 'users#musician_signup_sucessful_info', :as => successful_musician_signup
  
  root :to => 'home#index'
  
  match ':controller(/:action(/:id(.:format)))'
end
