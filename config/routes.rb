Soundmelon::Application.routes.draw do

  get "venue_public/index"

  get "venue_public/shows"

  get "venue/index"

  get "venue/edit"

  get "venue/update"

  # oauth login routes
  match "oauth/callback" => "oauths#callback", :as => :oauth_callback
  match "oauth/:provider" => "oauths#oauth", :as => :auth_at_provider

  resources :invitations  

  get 'application/loginvitation/:artist_name'=>'invitations#login_or_invitation',  :as => :new_loginvitation

  get "artist/index"

  # pages and feedback
  get "feedbacks"                               => "user#feedback_page",              :as => :feedback_start
  match "/feedback/send"                        => "user#give_feedback",              :as => :send_feedback
  get 'page/:page_name'                         => 'page#show',                       :as => :page
  #global
  get "search/index"
  get 'logout'                                  => 'sessions#destroy',                :as => :logout
  match 'login'                                 => 'sessions#create',                 :as => :login

  get 'ChangeLogin(/:artist_name)'              => 'user#change_login',               :as => :change_login
  get 'ChangeLogin(/:venue_name)/venue'         => 'user#change_login',               :as => :change_login_venue

  # administrator section
  get '/home/admin/feedbacks'                   => 'admin#feedbacks',                 :as => :admin_feedbacks_list
  get '/home/admin/feedback/:id/:opcode'        => 'admin#feedback_handler',          :as => :admin_feedback_handler
  get '/home/admin(/:sent)'                     => 'admin#index',                     :as => :admin_home #home
  get '/home/admin/:id/:opcode'                 => 'admin#invitation_request_handler',:as => :request_handler
  #fan
  get '/home'                                   => 'user#index',                      :as => :user_home #home
  #fan
  get '/home'                                   => 'user#index',                      :as => :fan_home #home
  get 'home/post/:id/threads'                   => 'user_posts#show_conversation_thread',         :as => :get_show_conversation_thread #posts
  get 'home/mentions'                           => 'user_posts#mentioned',            :as => :mentioned #mentions
  get 'home/replies'                            => 'user_posts#replies',              :as => :replies #replies
  match 'home/messages'                         => 'messages#inbox',                  :as => :user_inbox #messages

  #-------------------------------------------- followings, followers, follower artists, follower fans ---------------
  get ':id/followers(/:page)'                   => 'user_connections#fan_followers',          :as => :fan_followers
  get ':artist_name/fans(/:page)'               => 'user_connections#artist_followers',       :as => :artist_followers
  get ':artist_name/connections(/:page)'        => 'user_connections#artist_connections',     :as => :artist_connections
  get '/venue/:venue_name/fans(/:page)'         => 'user_connections#venue_followers',        :as => :venue_followers
  get ':id/following/fans(/:page)'              => 'user_connections#fan_following_fans',     :as => :fan_following_fans # id: following items
  get ':id/following/artists(/:page)'           => 'user_connections#fan_following_artists',  :as => :fan_following_artists # id: following items
  
  #fan functions
  get 'home/profiles/fan'                       => 'user#pull_profiles',                    :as => :associated_profiles
  get 'home/new/artist'                         => 'artist#new',                            :as => :new_artist
  match 'home/setup/artist/profile/:id'         => 'artist#setup_profile',                  :as => :artist_setup
  match 'home/setup/artist/info/:id'            => 'artist#add_info',                       :as => :add_artist_info
  post 'home/create/artist'                     => 'artist#create',                         :as => :create_artist  
  get 'home/new/venue'                          => 'venue#new',                             :as => :new_venue
  post 'home/create/venue'                      => 'venue#create',                          :as => :create_venue
  match 'home/venue/location/state'             => 'venue#state_options',                   :as => :venue_state_options
  get 'home/setup/venue/profile/:id'            => 'venue#setup_profile',                   :as => :venue_setup
  match 'home/setup/venue/info/:id'             => 'venue#add_info',                        :as => :venue_add_info
  match 'home/manage/profile'                   => 'user#manage_profile',                   :as => :manage_profile #manage session profile
  match '/home/setup/fan/profile'               => 'fan#profile_setup',                     :as => :profile_setup
  match '/home/setup/fan/location'              => 'fan#update_fan_items',                  :as => :profile_item_setup
  
    
  #fan public
  match 'fan/(:id)'                             => 'fan_public#index',                      :as => :fan_profile
  match 'fan/posts/:id'                         => 'fan_public#latest_posts',               :as => :fan_latest_post

  match 'fan/home/check_password'               => 'user#check_user_validity',              :as => :ask_and_check_user_password
  
  #artist
  get 'home/artist/:artist_name'                => 'artist#index',                          :as => :manage_artist
  match 'update/artist/:id'                     => 'artist#update',                         :as => :update_artist
  match 'update/venue/:id'                     => 'venue#update',                           :as => :update_venue
  
  get ':artist_name/artist/member/invitation'   => 'artist#invite_artist_members',          :as => :bandmates_invitation
  get ':artist_name/social'                     => 'artist#social',                         :as => :artist_social
  get ':artist_name/store'                      => 'artist#store',                          :as => :artist_store
  match ':artist_name/artist/send/inviation'    => 'artist#send_artist_member_invitation',  :as => :send_bandmates_invitation
  get ':artist_name/artist/search'              => 'artist#search_fan_popup',               :as => :artist_search_fan_popup
  get ':artist_name/:id/search/invitation'      => 'artist#search_fan_invitation',          :as => :artist_search_fan_invitation
  get "profile/additional_info"
  match 'registration(/:invitation_token)'      => 'fan#signup',                            :as => :fan_registration
  get 'users/:id/activate'                      => 'fan#activate',                          :as => :user_activation
  get 'user/reset/password'                     => 'password_resets#index',                 :as => :password_reset
  post 'add/additional_info'                    => 'fan#add_additional_info',               :as => :create_additional_info
  post 'add/payment_info'                       => 'fan#add_payment_info',                  :as => :create_payment_info
  match "invite/bandmates"                    => "fan#invite_bandmates" ,               :as => :invite_artist_member
  #get "invite/accept/:id/join" => "profile#activate_invitation" ,:as => "join_artist_invitation"
  match 'invitation/accept/:old_user/:id/join'  => 'fan#activate_invitation' ,              :as => :join_artist_invitation
  match "messages/sendmessage"                  => 'messages#send_message',                 :as => :send_message

  resources :user_posts
  match 'post/:artist_id/new/mention/artist'    => 'user_posts#new_mention_post',           :as => :new_artist_mention_post
  match 'post/:fan_id/new/mention/fan'          => 'user_posts#new_mention_post',           :as => :new_fan_mention_post
  match 'post/mention'                          => 'user_posts#create_mention_post',        :as => :mention_post
  match 'post/:id/reply/(:artist_id)'           => 'user_posts#new_reply',                  :as => :new_post_reply
  match 'post/reply'                            => 'user_posts#reply',                      :as => :post_reply
  
  get ':artist_name/mentioned/posts'            => 'user_posts#mentions_post',              :as => :artist_mentions_post
  get ':artist_name/replies/posts'              => 'user_posts#replies_post',               :as => :artist_replies_post
  
  resources :messages

  match 'messages/:conversation_id/view/all'    =>'messages#show_conversation_thread',      :as => :conversation_thread_view
  match 'message/reply'                         =>'messages#reply' ,                        :as => :reply_to_message
  match '(:artist_name)/inbox/messages/:page'   =>'messages#index',                         :as => :more_inbox_messages
  match '(:type)/posts/more/:page'              =>'user_posts#index',                       :as => :more_post
  match 'user/:id/posts/more/:page'             =>'user_posts#index',                       :as => :user_more_post
  match ':artist_name/bulletins/more/:page'     =>'user_posts#more_bulletins',              :as => :artist_more_bulletins
  match ':artist_name/:type/posts/more/:page'   =>'user_posts#more_posts',                  :as => :artist_more_posts
  match ':venue_name/venue/bulletins/more/:page'     =>'user_posts#more_bulletins',         :as => :venue_more_bulletins
  match ':venue_name/venue/:type/posts/more/:page'   =>'user_posts#more_posts',             :as => :venue_more_posts

  match 'update/basic/profile'                => 'fan#update_basic_info',                   :as => :update_basic_info
  match 'update/additional/info'              => 'fan#update_additional_info',              :as => :update_additional_info
  match 'update/password'                     => 'fan#update_password',                     :as => :update_password
  match 'edit/payment/info'                   => 'fan#update_payment_info',                 :as => :edit_payment_info
  match 'update/notification/setting'         => 'fan#update_notification_setting',         :as => :update_notification_setting
  match 'update/artist/notification/:id'      => 'artist#update_notification_setting',      :as => :update_artist_notification_setting
  match 'update/venue/notification/:id'      => 'venue#update_notification_setting',      :as => :update_venue_notification_setting
  
  #--------------------------------------------------AvatarController[Fan Profile Pic/Artist Logo]----------------------
  post 'profile/pic/add'                      => 'avatar#create',                           :as => :add_avatar
  get 'profile/pic/new'                       => 'avatar#new',                              :as => :new_avatar
  match 'profile/pic/crop'                    => 'avatar#crop',                             :as => :crop_avatar
  match 'profile/pic/update'                  => 'avatar#update',                           :as => :update_avatar
  get 'profile/pic/delete'                    => 'avatar#delete',                           :as => :delete_avatar

  post 'home/logo/add'                      => 'avatar#create_logo',                      :as => :add_logo
  get 'home/logo/new'                       => 'avatar#new_logo',                         :as => :new_logo
  match 'home/logo/crop'                    => 'avatar#crop_logo',                        :as => :crop_logo
  match 'home/logo/update'                  => 'avatar#update_logo',                      :as => :update_logo
  get 'home/logo/delete'                    => 'avatar#delete_logo',                      :as => :delete_logo
  #---------------------------------------------------------------------------------------------------------------------
  
  resources :password_resets
  match '/user/resest/password/:id'           => 'password_resets#update',                  :as => :reset_password
  resources :photos
  get 'albums'                                => 'photos#albums',                           :as => :albums
  get 'album/photos/:album_name'              => 'photos#album_photos',                     :as => :album_photos
  get ':album_name/photo/:id'                 => 'photos#show',                             :as => :album_photo
  
  #invitation
  match 'contacs/fetch/login/:emailtype'      => "invite#fetch_contacts_login",             :as => :fetch_contacts_form
  match 'contacs/fetch'                       => "invite#fetch_contacts",                   :as => :fetch_contacts
  post 'send/invitation'                      => "invite#send_invitation",                  :as => :send_invitation
 
  #autocomplete
  match 'autocomplete/suggestions'            => 'search#autocomplete_suggestions',               :as => :autocomplete_suggestions
  match 'autocomplete/location/suggestions'   => 'search#location_autocomplete_suggestions',      :as => :location_autocomplete_suggestions
  match 'autocomplete/venue/suggestions'      => 'search#venue_autocomplete_suggestions',      :as => :venue_autocomplete_suggestions
  get 'check/fanusername'                     => 'search#check_fanusername',                      :as => :check_fanusername
  get 'check/artistname'                      => 'search#check_artistname',                       :as => :check_artistname
  get 'check/artistmentionname'               => 'search#check_artistmentionname',                :as => :check_artistmentionname
  #get 'fan/sign_up/message' => 'users#fan_signup_sucessful_info', :as => successful_fan_signup
  #get 'musician/sign_up/message' => 'users#musician_signup_sucessful_info', :as => successful_musician_signup

  # Artist Shows
  get ':artist_name/show/new'                       => 'artist_show#new',                         :as => :new_artist_show
  get ':artist_name/shows'                          => 'artist_show#index',                       :as => :artist_shows
  get ':artist_name/:artist_show_id/show'           => 'artist_show#artist_show',                 :as => :artist_show
  get ':artist_name/:artist_show_id/showdetail'     => 'artist_show#show_detail',                 :as => :artist_show_detail
  get ':artist_name/showchange/:artist_show_id'     => 'artist_show#edit',                        :as => :edit_artist_show
  get ':artist_name/showlike/:artist_show_id'       => 'artist_show#like_dislike_artist_show',    :as => :like_dislike_artist_show
  match ':artist_name/showremove/:artist_show_id'   => 'artist_show#destroy_show',                :as => :delete_artist_show

  resources :album_photos
  get ':artist_name/photos/new'                     => 'artist_photo#new',                        :as => :new_artist_album
  get ':artist_name/photos'                         => 'artist_photo#index',                      :as => :artist_albums
  get ':artist_name/:album_name/photo'              => 'artist_photo#artist_album',               :as => :artist_album
  get ':artist_name/album/photos/:album_name'       => 'artist_photo#artist_album_photos',        :as => :artist_album_photos
  get ':artist_name/:album_name/photo/:id'          => 'artist_photo#show',                       :as => :artist_album_photo
  get ':artist_name/:album_name/photos/add'         => 'artist_photo#add',                        :as => :add_photos_to_album
  get ':artist_name/edit/:album_name'               => 'artist_photo#edit',                       :as => :edit_album
  match ':artist_name/delete/:album_name'           => 'artist_photo#destroy_album',              :as => :delete_album
  get ':artist_name/:album_name/photo/:id/cover'    => 'artist_photo#make_cover_image' ,          :as => :make_cover_image
  get ':artist_name/:album_name/photo/:id/edit'     => 'artist_photo#edit_photo' ,                :as => :edit_photo
  get ':artist_name/:album_name/photo/:id/delete'   => 'artist_photo#destroy' ,                   :as => :delete_photo
  get ':artist_name/:album_name/album/public'       => 'artist_photo#disable_enable_artist_album',:as => :disable_enable_artist_album
  match ':artist_name/:album_name/photo/:id/update' => 'artist_photo#update_photo',               :as => :update_artist_photo
  get ':artist_name/:album_name/plike'              => 'artist_photo#like_dislike',               :as => :like_artist_album
  
  #artist song albums and songs
  get ':artist_name/music/new'                      => 'artist_music#new',                        :as => :new_artist_music
  get ':artist_name/music'                          => 'artist_music#index',                      :as => :artist_musics
  get ':artist_name/:artist_music_name/music'       => 'artist_music#artist_music',               :as => :artist_music
  get ':artist_name/music/songs/:artist_music_name' => 'artist_music#artist_music_songs',         :as => :artist_songs
  get ':artist_name/song/:id/edit'                  => 'artist_music#edit_song',                  :as => :song_edit
  match ':artist_name/song/:id/update'              => 'artist_music#update_song',                :as => :song_update
  get ':artist_name/:artist_music_name/songs/add'   => 'artist_music#add',                        :as => :add_song
  get ':artist_name/artist/music/download/:id'      => 'artist_music#download_artist_music',      :as => :download_artist_music
  match ':artist_name/music/delete/:artist_music_id'=> 'artist_music#destroy_artist_music',       :as => :delete_artist_music
  match ':artist_name/song/delete/:song_id'         => 'artist_music#destroy_song',               :as => :delete_song
  get ':artist_name/:artist_music_name/public'      => 'artist_music#disable_enable_artist_music',:as => :disable_enable_artist_music
  get ':artist_name/set_featured_songs'             => 'artist_music#songs_for_featured_list',    :as => :popup_for_feature_songs
  get ':artist_name/:artist_music_name/featured'    => 'artist_music#make_song_album_featured',   :as => :make_artist_music_featured
  get ':artist_name/:artist_music_name/featured/:id'=> 'artist_music#make_song_featured',         :as => :make_song_featured
  get ':artist_name/:artist_music_name/edit'        => 'artist_music#edit_artist_music',          :as => :edit_artist_music
  get ':song_name/:id/like(/:do_like)'              => 'artist_music#do_like_dislike_song',       :as => :like_song

  # venue photos
  get '/venue/:venue_name/photos/new'                    => 'venue_photo#new',                       :as => :new_venue_album
  get '/venue/:venue_name/photos'                        => 'venue_photo#index',                     :as => :venue_albums
  get '/venue/:venue_name/:album_name/photo'             => 'venue_photo#venue_album',               :as => :venue_album
  get '/venue/:venue_name/album/photos/:album_name'      => 'venue_photo#venue_album_photos',        :as => :venue_album_photos
  get '/venue/:venue_name/:album_name/photo/:id'         => 'venue_photo#show',                      :as => :venue_album_photo
  get '/venue/:venue_name/:album_name/photos/add'        => 'venue_photo#add',                       :as => :add_photos_to_venue_album
  get '/venue/:venue_name/edit/:album_name'              => 'venue_photo#edit',                      :as => :edit_venue_album
  match '/venue/:venue_name/delete/:album_name'          => 'venue_photo#destroy_album',             :as => :delete_venue_album
  get '/venue/:venue_name/:album_name/photo/:id/cover'   => 'venue_photo#make_cover_image' ,         :as => :make_cover_image_venue
  get '/venue/:venue_name/:album_name/photo/:id/edit'    => 'venue_photo#edit_photo' ,               :as => :edit_venue_photo
  get '/venue/:venue_name/:album_name/photo/:id/delete'  => 'venue_photo#destroy' ,                  :as => :delete_venue_photo
  get '/venue/:venue_name/:album_name/album/public'      => 'venue_photo#disable_enable_album',      :as => :disable_enable_album
  match '/venue/:venue_name/:album_name/photo/:id/update'=> 'venue_photo#update_photo',              :as => :update_venue_photo
  get '/venue/:venue_name/:album_name/plike'             => 'venue_photo#like_dislike',              :as => :like_venue_album



  root :to => 'home#index'
  
  #--------------------------------------------UserConnections----------------------------------------------------
  # follow/un-follow artist
  get 'follow/artist/:artist_name/:source'         => 'user_connections#follow_artist',           :as => :follow_artist
  get 'unfollow/artist/:artist_name/:source'       => 'user_connections#unfollow_artist',         :as => :unfollow_artist
  get 'follow/venue/:venue_name/:source'           => 'user_connections#follow_venue',            :as => :follow_venue
  get 'unfollow/venue/:venue_name/:source'         => 'user_connections#unfollow_venue',          :as => :unfollow_venue
  get 'connection/request/artist/:artist_name/(/:id)'              => 'user_connections#connect_artist',    :as => :connect_artist
  get 'connection/request/artist/venue/:artist_name/(/:venue_id)'  => 'user_connections#connect_artist',    :as => :connect_artist_from_venue
  get 'connection/accept/artist/:artist_name'      => 'user_connections#connect_artist',          :as => :accept_artist_connection
  get 'connection/reject/artist/:artist_name'      => 'user_connections#disconnect_artist',       :as => :reject_artist_connection
  get 'connection/remove/artist/:artist_name'      => 'user_connections#disconnect_artist',       :as => :remove_artist_connection
  get 'connection/request/venue/:venue_id(/:id)'  => 'user_connections#connect_artist',          :as => :connect_venue
  get 'connection/accept/venue/:venue_id'          => 'user_connections#connect_venue',           :as => :accept_venue_connection
  get 'connection/reject/venue/:venue_id'          => 'user_connections#disconnect_venue',        :as => :reject_venue_connection
  get 'connection/remove/venue/:venue_id'          => 'user_connections#disconnect_venue',        :as => :remove_venue_connection
  
  # follow/un-follow fan
  get 'follow/fan/:id/:source'            => 'user_connections#follow',                           :as => :follow_user
  get 'unfollow/fan/:id/:source'          => 'user_connections#unfollow',                         :as => :unfollow_user
  #---------------------------------------------------------------------------------------------------------------
  #message artist
  get ':artist_name/message/new'          => 'artist_public#new_message',                 :as => :artist_new_message
  match ':artist_name/message/create'     => 'artist_public#send_message',                :as => :artist_send_message
  get ':artist_name/members'              => 'artist_public#members',                     :as => :artist_members
  
  get ':artist_name'                      => 'artist_public#index',                       :as => :show_artist
  get 'venue/:venue_name'                 => 'venue_public#index',                        :as => :show_venue
  get 'venue/:venue_name/shows(/:page)'   => 'venue_show#index',                          :as => :venue_shows
  
  #album and song buzz
  get ':artist_name/:id/tbuzz'            => 'buzz#artist_show_buzz',                     :as => :artist_show_buzz
  get ':album_name/:id/photo_album_buzz'  => 'buzz#photo_album_buzz',                     :as => :photo_album_buzz  
  get ':album_name/:id/buzz'              => 'buzz#artist_music_buzz',                    :as => :album_buzz
  get 'buzz/:id'                          => 'buzz#song_buzz',                            :as => :song_buzz
  
  match ':album_name/:id/buzz/create'     => 'buzz#artist_music_buzz_post',               :as => :artist_music_buzz_post
  match 'buzz/:id/create'                 => 'buzz#song_buzz_post',                       :as => :song_buzz_post
  match ':album_name/:id/photobuzz/create'=> 'buzz#photo_album_buzz_post',                :as => :photo_album_buzz_post
  match 'photobuzz/:id/create'            => 'buzz#photo_buzz_post',                      :as => :hoto_buzz_post
  match 'tbuzz/:id/create'                => 'buzz#artist_show_buzz_post',                :as => :artist_show_buzz_post

  #song download
  get ':artist_name/:id/download'         => 'artist_music#download',                     :as => :download_song
  
  #playlist
  get 'playlist/add/songs/list'           => 'playlists#add_radio_songs',                 :as => :add_radio_song_to_playlist
  get 'playlist/:song_name/:id/add'       => 'playlists#add',                             :as => :add_to_playlist
  get 'playlist/:song_name/:id/remove'    => 'playlists#remove',                          :as => :remove_from_playlist
  get 'playlistPlayer/:id/add'            => 'playlists#add_to_player_queue',             :as => :add_album_to_player_playlist
  get 'playlist/:id/add'                  => 'playlists#add_all_songs_of_album',          :as => :add_album_to_playlist

  get '/home/remove/profile'              => 'user#remove_user_profile',                  :as => :remove_my_profile

  match ':controller(/:action(/:id(.:format)))'
end
