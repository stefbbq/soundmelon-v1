class ApplicationController < ActionController::Base
  protect_from_forgery
  #before_filter :http_basic_authenticate
  # this is needed to prevent XHR request form using layouts
  before_filter proc { |controller| (controller.action_has_layout = false) if controller.request.xhr? }

  after_filter :messages_and_posts_count

  protected
  
  def get_user_associated_objects
    @following_artists        = current_user.following_band.order('RAND()').limit(NO_OF_FOLLOWING_TO_DISPLAY)
    @following_artist_count   = current_user.following_band.count
    @following_users          = current_user.following_user.order('RAND()').limit(NO_OF_FOLLOWING_TO_DISPLAY)
    @following_count          = current_user.following_user.count
    @followers_users          = current_user.user_followers.order('RAND()').limit(NO_OF_FOLLOWER_TO_DISPLAY)
    @followers_count          = current_user.user_followers.count
    @playlist_songs           = current_user.playlists
    @playlist_songs_id        = @playlist_songs.map{|playlist_song| playlist_song.song_id}
    @user ||= current_user
  end

  def get_fan_objects_for_right_column fan
    @following_artists        = fan.following_band.order('RAND()').limit(NO_OF_FOLLOWING_TO_DISPLAY)
    @following_artist_count   = fan.following_band.count
    @following_users          = fan.following_user.order('RAND()').limit(NO_OF_FOLLOWING_TO_DISPLAY)
    @following_count          = fan.following_user.count
    @followers_users          = fan.user_followers.order('RAND()').limit(NO_OF_FOLLOWER_TO_DISPLAY)
    @followers_count          = fan.user_followers.count
    @playlist_songs           = fan.playlists
    @playlist_songs_id        = @playlist_songs.map{|playlist_song| playlist_song.song_id}
    @user ||= fan
  end

  # instantiates all artist objects for rendering in right column
  def get_artist_objects_for_right_column artist
    @song_album_count          = artist.song_albums.size
    @photo_album_count         = artist.band_albums.size
    @tour_count                = artist.band_tours.size
    @band_artist_count         = artist.band_members.size
    @band_fan_count            = artist.followers_count
    @song_albums               = artist.limited_song_albums
    @photo_albums              = artist.limited_band_albums
    @band_tours                = artist.band_tours
    @band_artists              = artist.limited_band_members
    @band_fans                 = artist.limited_band_follower
  end

  private
  
  def not_authenticated
    redirect_to root_url, :alert => "First login to access this page."
  end
  
  def logged_in_user
    redirect_to fan_home_url and return if current_user
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
