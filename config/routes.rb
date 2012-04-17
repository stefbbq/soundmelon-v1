Soundmelon::Application.routes.draw do
  get "bands/index"
  
  #global
  get "search/index"
  get 'logout' => 'sessions#destroy', :as => 'logout'
  post 'login' => 'sessions#create', :as => 'login'

  #users (fans and artists alike)
  get 'follow/user/:id' => 'user_connections#follow', :as => 'follow_user'
  get 'unfollow/user/:id' => 'user_connections#unfollow', :as => 'unfollow_user'
    
  #fan
  get 'home' => 'fan#index', :as => 'fan_home' #home
  get 'home/post/:id/threads' => 'user_posts#post_threads', :as => 'get_post_threads' #posts
  get 'home/mentions' => 'user_posts#mentioned', :as => 'mentioned' #mentions
  get 'home/replies' => 'user_posts#replies', :as => 'replies' #replies
  match 'home/messages' => 'messages#inbox' ,:as => 'user_inbox' #messages
  get 'home/(:id)/followers' => 'user_connections#followers', :as => 'fan_followers'
  get 'home/(:id)/following' => 'user_connections#following', :as => 'fan_following'
  get 'home/(:id)/following/artists' => 'user_connections#following_artists', :as => 'fan_following_artists'  
  
  #fan functions
  get 'user/bands' => 'artist#pull', :as => 'associated_band'
  get 'user/new/band' => 'artist#new', :as => 'new_band'
  post 'user/create/band' => 'artist#create', :as => 'create_band'
  match 'home/manage' => 'fan_public#manage_profile', :as => 'manage_profile' #manage session profile
    
  #fan public
  match 'fan/(:id)' => 'fan_public#index',:as => 'fan_profile'  
  
  #artist
  get 'home/artist/:band_name' => 'artist#index', :as => 'manage_band'
  get 'edit/band/:band_name' => 'artist#edit', :as => 'edit_band'
  match 'update/band/:id' => 'artist#update', :as => 'update_band'
  get ':band_name/members' => 'artist#members', :as => 'band_members'
  get ':band_name/bandmates/inivtation' => 'artist#invite_bandmates', :as => 'bandmates_invitation'
  get ':band_name' => 'artist#social', :as => 'show_band'
  get ':band_name/social' => 'artist#social', :as => 'band_social'
  get ':band_name/store' => 'artist#store', :as => 'band_store'
  match ':band_name/bandmates/send/inviation' => 'artist#send_bandmates_invitation', :as => 'send_bandmates_invitation'

  get "profile/additional_info"
  
  match 'fan/registration' => 'fan#fan_new', :as => 'fan_registration'
  match 'musician/registration' => 'users#musician_new', :as => 'musician_registration'
  get 'users/:id/activate' => 'users#activate', :as => 'user_activation'
  #get 'user/reset/password' => 'password_resets#index', :as => 'password_reset'
  post 'add/additional_info' => 'profile#add_additional_info', :as => 'create_additional_info'
  post 'add/payment_info' => 'profile#add_payment_info', :as => 'create_payment_info'
  match "invite/bandmates" => "profile#invite_bandmates" ,:as => "invite_band_member"
  #get "invite/accept/:id/join" => "profile#activate_invitation" ,:as => "join_band_invitation"
  match 'invitation/accept/:old_user/:id/join' => 'profile#activate_invitation' ,:as => 'join_band_invitation'
  match "messages/sendmessage" => 'messages#send_message',:as=>"send_message" 


  get ':band_name/messages/inbox' => 'messages#inbox' ,:as => 'band_inbox'
  resources :user_posts
  match 'post/:id/reply/(:band_id)' => 'user_posts#new_reply', :as => 'new_post_reply'
  match 'post/reply' => 'user_posts#reply', :as => 'post_reply'

  
  get ':band_name/mentioned/posts' => 'artist#mentions_post', :as => 'band_mentions_post'
  get ':band_name/replies/posts' => 'artist#replies_post', :as => 'band_replies_post'
  
  match 'messages/:id/band/:band_id' => 'messages#show', :as => 'band_message' 
  resources :messages
 
  match 'message/reply' => 'messages#reply' ,:as => 'reply_to_message'
  match '(:band_name)/inbox/messages/:page'   =>'messages#index', :as => :more_inbox_messages
  match '(:type)/posts/more/:page'   =>'user_posts#index', :as => :more_post
  match 'user/:id/posts/more/:page'   =>'user_posts#index', :as => :user_more_post
  match ':band_name/bulletins/more/:page' =>'bands#more_bulletins', :as => :band_more_bulletins
  match ':band_name/(:type)/posts/more/:page' =>'bands#more_posts', :as => :band_more_posts
  get ':band_name/fans' => 'artist#fans', :as => :band_fans
  

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
  
  resources :album_photos
  get ':band_name/album/new'                      => 'band_photos#new', :as => 'new_band_album'
  get ':band_name/albums'                         => 'band_photos#band_albums', :as => 'band_albums'
  get ':band_name/:band_album_name/palbum'        => 'band_photos#band_album', :as => 'band_album'
  get ':band_name/album/photos/:band_album_name'  => 'band_photos#band_album_photos', :as => 'band_album_photos'
  get ':band_name/:band_album_name/photo/:id'     => 'band_photos#show', :as => 'band_album_photo'
  get ':band_name/:band_album_name/photos/add'    => 'band_photos#add', :as => 'add_photos_to_album'
  get ':band_name/edit/:band_album_name'          => 'band_photos#edit', :as => 'edit_album'
  match ':band_name/delete/:band_album_name'      => 'band_photos#destroy_album', :as => 'delete_album'
  get ':band_name/:album_name/photo/:id/edit'     => 'band_photos#edit' , :as => 'edit_photo'
  get ':band_name/:album_name/photo/:id/delete'   => 'band_photos#destroy' , :as => 'delete_photo'
  get ':band_name/:album_name/ppublic'            => 'band_photos#disable_enable_band_album', :as => 'disable_enable_band_album'
  match ':band_name/:album_name/photo/:id/update' => 'band_photos#update',  :as => 'update_band_photo'
  
  #band song albums and songs
  get ':band_name/song/album/new'                 => 'band_song_album#new', :as => 'new_band_song_album'
  get ':band_name/song/albums'                    => 'band_song_album#band_song_albums', :as => 'band_song_albums'
  get ':band_name/:song_album_name/album'         => 'band_song_album#band_song_album', :as => 'band_song_album'
  get ':band_name/album/songs/:song_album_name'   => 'band_song_album#album_songs', :as => 'band_album_songs'
  get ':band_name/:song_album_name/download/song/:id' => 'band_photos#download', :as => 'band_album_song_download'
  get ':band_name/:song_album_name/public'        => 'band_song_album#disable_enable_song_album', :as => 'disable_enable_band_song_album'
  get ':band_name/:song_album_name/remove'        => 'band_song_album#remove_song_album', :as => 'remove_band_song_album'
  get ':band_name/:song_album_name/add_song'      => 'band_song_album#add_song_to_album', :as => 'add_song_to_album'
  get ':band_name/set_featured'                   => 'band_song_album#albums_for_featured_list', :as => 'popup_for_feature_albums'
  get ':band_name/:song_album_name/featured'      => 'band_song_album#make_song_album_featured', :as => 'make_song_album_featured'
  get ':band_name/:song_album_name/edit'          => 'band_song_album#edit_song_album', :as => 'edit_band_song_album'
  root :to => 'home#index'
  
  #follow band
  get 'follow/:band_name' => 'bands#follow_band', :as => 'follow_band'
  get 'unfollow/:band_name' => 'bands#unfollow_band', :as => 'unfollow_band'
    
  #message band
  get ':band_name/message/new' => 'bands#new_message', :as => 'band_new_message'
  match ':band_name/message/create' => 'bands#send_message', :as => 'band_send_message'
  
  #album and song buzz
  get ':album_name/:id/photo_album_buzz' => 'buzz#band_photo_album_buzz', :as => 'band_album_buzz'
  get ':album_name/:id/buzz' => 'buzz#album_buzz', :as => 'album_buzz'
  get 'buzz/:id' => 'buzz#song_buzz', :as => 'song_buzz'
  #get ':song_name/:id/buzz' => 'buzz#song_buzz', :as => 'song_buzz'
  match ':album_name/:id/buzz/create' => 'buzz#album_buzz_post', :as => 'album_buzz_post'
  match 'buzz/:id/create' => 'buzz#song_buzz_post', :as => 'song_buzz_post'
  match ':album_name/:id/photobuzz/create' => 'buzz#band_album_buzz_post', :as => 'band_album_buzz_post'
  match 'photobuzz/:id/create' => 'buzz#band_photo_buzz_post', :as => 'band_photo_buzz_post'

  #match ':song_name/:id/buzz/create' => 'buzz#song_buzz_post', :as => 'song_buzz_post' 
  
  #song download
  get ':song_name/:id/download' => 'band_song_album#download', :as => 'download_song'
  
  #playlist  
  get 'playlist/:song_name/:id/add' => 'playlists#add', :as => 'add_to_playlist'
  get 'playlist/:song_name/:id/remove' => 'playlists#remove', :as => 'remove_from_playlist'
  get 'playlistPlayer/:id/add' => 'playlists#add_to_player_queue', :as => 'add_album_to_player_playlist'
  get 'playlist/:id/add' => 'playlists#add_all_songs_of_album', :as => 'add_album_to_playlist'
  match ':controller(/:action(/:id(.:format)))'
end
