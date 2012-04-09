class ApplicationController < ActionController::Base
  protect_from_forgery
  #before_filter :http_basic_authenticate
  # this is needed to prevent XHR request form using layouts
  before_filter proc { |controller| (controller.action_has_layout = false) if controller.request.xhr? }

  after_filter :messages_and_posts_count

  protected
  
  def get_user_associated_objects
    @following_artist_count = current_user.following_band.count
    @following_count = current_user.following_user.count
    @follower_count = current_user.user_followers.count
    @following_artists = current_user.following_band.order('RAND()').limit(NO_OF_FOLLOWING_TO_DISPLAY)
    @following_users = current_user.following_user.order('RAND()').limit(NO_OF_FOLLOWING_TO_DISPLAY)
    @follower_users = current_user.user_followers.order('RAND()').limit(NO_OF_FOLLOWER_TO_DISPLAY)
    @playlist_songs = current_user.playlists
    @playlist_songs_id = @playlist_songs.map{|playlist_song| playlist_song.song_id}
    
    @user ||= current_user
  end

  private
  
  def not_authenticated
    redirect_to root_url, :alert => "First login to access this page."
  end
  
  def logged_in_user
    redirect_to user_home_url and return if current_user
  end

  #added to restrict the site from anonymous access
  def http_basic_authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "mustang" && password == 'mustang' #"must@ngs0undm3l0n"
    end
  end

  def messages_and_posts_count
    if current_user      
      @unread_mentioned_count ||= current_user.unread_mentioned_post_count
      @unread_post_replies_count ||= current_user.unread_post_replies_count
      @unread_messages_count ||= current_user.received_messages.unread.count
    end
  end
  
end
