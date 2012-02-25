Soundmelon::Application.routes.draw do
  
  get "bands/index"

  get  "search/index"

  get 'follow/user/:id' => 'follow#follow', :as => 'follow_user'

  get 'user/(:id)/follower' => 'follow#follower', :as => 'user_follower'

  get 'unfollow/user/:id' => 'follow#unfollow', :as => 'unfollow_user'
  
  get 'user/(:id)/following' => 'follow#following', :as => 'user_following'
  
  get 'user/(:id)/following/artists' => 'follow#following_artists', :as => 'user_following_artists'

  get "profile/additional_info"
  get 'logout' => 'sessions#destroy', :as => 'logout'
  post 'login' => 'sessions#create', :as => 'login'
  get 'users' => 'users#index', :as => 'user_home'
  match 'fan/registration' => 'users#fan_new', :as => 'fan_registration'
  match 'musician/registration' => 'users#musician_new', :as => 'musician_registration'
  get 'users/:id/activate' => 'users#activate', :as => 'user_activation'
  #get 'user/reset/password' => 'password_resets#index', :as => 'password_reset'
  post 'add/additional_info' => 'profile#add_additional_info', :as => 'create_additional_info'
  post 'add/payment_info' => 'profile#add_payment_info', :as => 'create_payment_info'
  match "invite/bandmates" => "profile#invite_bandmates" ,:as => "invite_band_member"
  #get "invite/accept/:id/join" => "profile#activate_invitation" ,:as => "join_band_invitation"
  match 'invitation/accept/:old_user/:id/join' => 'profile#activate_invitation' ,:as => 'join_band_invitation'
  match "messages/sendmessage" => 'messages#send_message',:as=>"send_message" 
  match 'user/profile/:id' => 'profile#user_profile',:as => 'user_profile'
  match 'messages/inbox' => 'messages#inbox' ,:as => 'user_inbox'
  get ':band_name/messages/inbox' => 'messages#inbox' ,:as => 'band_inbox'
  resources :user_posts
  match 'post/:id/reply/(:band_id)' => 'user_posts#new_reply', :as => 'new_post_reply'
  match 'post/reply' => 'user_posts#reply', :as => 'post_reply'
  get 'post/:id/threads' => 'user_posts#post_threads', :as => 'get_post_threads'
  get 'mentioned/posts' => 'user_posts#mentioned', :as => 'mentioned'
  get 'replies/posts' => 'user_posts#replies', :as => 'replies'
  
  get ':band_name/mentioned/posts' => 'bands#mentions_post', :as => 'band_mentions_post'
  get ':band_name/replies/posts' => 'bands#replies_post', :as => 'band_replies_post'
  
  match 'messages/:id/band/:band_id' => 'messages#show', :as => 'band_message' 
  resources :messages
 
  match 'message/reply' => 'messages#reply' ,:as => 'reply_to_message'
  match '(:band_name)/inbox/messages/:page'   =>'messages#index', :as => :more_inbox_messages
  match '(:type)/posts/more/:page'   =>'user_posts#index', :as => :more_post
  match 'user/:id/posts/more/:page'   =>'user_posts#index', :as => :user_more_post
  match ':band_name/bulletins/more/:page' =>'bands#more_bulletins', :as => :band_more_bulletins
  match ':band_name/(:type)/posts/more/:page' =>'bands#more_posts', :as => :band_more_posts
  
  match 'edit/profile' => 'profile#edit_profile', :as => 'user_profile_edit'
  match 'update/basic/profile' => 'profile#update_basic_info', :as => 'update_basic_info'
  match 'update/additional/info' => 'profile#update_additional_info', :as => 'update_additional_info'
  match 'update/password' => 'profile#update_password', :as => 'update_password'
  match 'edit/payment/info' => 'profile#update_payment_info', :as => 'edit_payment_info'
  #avatar
  post 'profile/pic/add' => 'avatar#create', :as => 'add_avatar'
  get 'profile/pic/new' => 'avatar#new', :as => 'new_avatar'
  match 'profile/pic/crop' => 'avatar#crop', :as => 'crop_avatar'
  match 'profile/pic/update' => 'avatar#update', :as => 'update_avatar'
  get 'profile/pic/delete' => 'avatar#delete', :as => 'delete_avatar'
 # match 'profile/pic/delete' => 'avatar#delete', :as => 'delete_avatar'
  resources :password_resets
  resources :photos
  get 'albums' => 'photos#albums', :as => 'albums'
  get 'album/photos/:album_name' => 'photos#album_photos', :as => 'album_photos'
  get ':album_name/photo/:id' => 'photos#show', :as => 'album_photo'
  #invitation 
  match 'contacs/fetch' => "invite#fetch_contacts", :as => 'fetch_contacts'
  post 'send/invitation' => "invite#send_invitation", :as => 'send_invitation'
 
  #autocomplete
  match 'autocomplete/suggestions' => 'search#autocomplete_suggestions', :as => 'autocomplete_suggestions'
  match 'autocomplete/location/suggestions' => 'search#location_autocomplete_suggestions', :as => 'location_autocomplete_suggestions'
  get 'check/bandname' => 'search#check_bandname', :as => 'check_bandname'
  #get 'fan/sign_up/message' => 'users#fan_signup_sucessful_info', :as => successful_fan_signup
  #get 'musician/sign_up/message' => 'users#musician_signup_sucessful_info', :as => successful_musician_signup
  
  
  get 'user/bands' => 'bands#index', :as => 'associated_band'
  get 'user/new/band' => 'bands#new', :as => 'new_band'
  post 'user/create/band' => 'bands#create', :as => 'create_band'
  get 'manage/band/:band_name' => 'bands#manage', :as => 'manage_band'
  get 'edit/band/:band_name' => 'bands#edit', :as => 'edit_band'
  match 'update/band/:id' => 'bands#update', :as => 'update_band'
  get ':band_name/members' => 'bands#members', :as => 'band_members'
  get ':band_name/bandmates/inivtation' => 'bands#invite_bandmates', :as => 'bandmates_invitation'
  get ':band_name' => 'bands#social', :as => 'show_band'
  get ':band_name/social' => 'bands#social', :as => 'band_social'
  get ':band_name/store' => 'bands#store', :as => 'band_store'
  match ':band_name/bandmates/send/inviation' => 'bands#send_bandmates_invitation', :as => 'send_bandmates_invitation'
  
  
  resources :album_photos
  get ':band_name/album/new' => 'band_photos#new', :as => 'new_band_album'
  get ':band_name/albums' => 'band_photos#band_albums', :as => 'band_albums'
  get ':band_name/album/photos/:band_album_name' => 'band_photos#band_album_photos', :as => 'band_album_photos'
  get ':band_name/:band_album_name/photo/:id' => 'band_photos#show', :as => 'band_album_photo'
  get ':band_name/:band_album_name/photos/add' => 'band_photos#add', :as => 'add_photos_to_album'
  get ':band_name/edit/:band_album_name' => 'band_photos#edit', :as => 'edit_album'
  match ':band_name/delete/:band_album_name' => 'band_photos#destroy_album', :as => 'delete_album' 
  get ':band_name/:album_name/photo/:id/edit' => 'band_photos#edit' , :as => 'edit_photo'
  get ':band_name/:album_name/photo/:id/delete' => 'band_photos#destroy' , :as => 'delete_photo'
  match ':band_name/:album_name/photo/:id/update' => 'band_photos#update',  :as => 'update_band_photo'
  
  #band song albums and songs
  get ':band_name/song/album/new' => 'band_song_album#new', :as => 'new_band_song_album'
  get ':band_name/song/albums' => 'band_song_album#band_song_albums', :as => 'band_song_albums'
  get ':band_name/album/songs/:song_album_name' => 'band_song_album#album_songs', :as => 'band_album_songs'
  get ':band_name/:song_album_name/download/song/:id' => 'band_photos#download', :as => 'band_album_song_download'
  get ':band_name/:song_album_name/edit' => 'band_song_album#edit_song_album', :as => 'edit_band_song_album'
  root :to => 'home#index'
  
  #follow band
  get ':band_name/become/fan' => 'bands#follow_band', :as => 'follow_band'
  
  #message band
  get ':band_name/message/new' => 'bands#new_message', :as => 'band_new_message'
  match ':band_name/message/create' => 'bands#send_message', :as => 'band_send_message'
  
  match ':controller(/:action(/:id(.:format)))'
end
