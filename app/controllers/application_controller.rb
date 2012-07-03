class ApplicationController < ActionController::Base
  protect_from_forgery
  #before_filter :http_basic_authenticate
  # this is needed to prevent XHR request form using layouts
  before_filter proc { |controller| (controller.action_has_layout = false) if controller.request.xhr? }
  before_filter :check_user_browser
  
  after_filter :messages_and_posts_count
  
  helper_method :current_actor, :admin_login?

  protected

  def check_user_browser
    user_browser      = request.env['HTTP_USER_AGENT']        
    if user_browser =~ /MSIE/
      render :template =>'/bricks/page_for_ie', :layout =>false and return
    end    
  end
  
  def get_user_associated_objects
    @following_artists        = current_user.following_band.order('RAND()').limit(NO_OF_FOLLOWING_TO_DISPLAY)
    @following_artist_count   = current_user.following_band.count
    @following_users          = current_user.following_user.order('RAND()').limit(NO_OF_FOLLOWING_TO_DISPLAY)
    @following_count          = current_user.following_user.count
    @followers_users          = current_user.limited_followers
    @followers_count          = current_user.followers_count
    @playlist_songs           = current_user.playlists
    @playlist_songs_id        = @playlist_songs.map{|playlist_song| playlist_song.song_id}
    @user ||= current_user
  end

  def get_fan_objects_for_right_column fan
    @following_artists        = fan.following_band.order('RAND()').limit(NO_OF_FOLLOWING_TO_DISPLAY)
    @following_artist_count   = fan.following_band.count
    @following_users          = fan.following_user.order('RAND()').limit(NO_OF_FOLLOWING_TO_DISPLAY)
    @following_count          = fan.following_user.count
    @followers_users          = fan.limited_followers
    @followers_count          = fan.followers_count
    @playlist_songs           = fan.playlists
    @playlist_songs_id        = @playlist_songs.map{|playlist_song| playlist_song.song_id}
    @user ||= fan
  end

  # instantiates all artist objects for rendering in right column
  def get_artist_objects_for_right_column artist
    begin
      actor                      = current_actor
      @has_admin_access          = actor == artist
      @song_album_count          = artist.song_albums.size
      @photo_album_count         = artist.band_albums.size
      @tour_count                = artist.band_tours.size
      @band_artist_count         = artist.band_members.size
      @band_fan_count            = artist.followers_count
      @band_connection_count     = artist.connections_count
      @song_albums               = artist.limited_song_albums
      @featured_songs            = artist.limited_band_featured_songs
      @photo_albums              = artist.limited_band_albums(2)
      @band_tours                = artist.limited_band_tours
      @band_artists              = artist.limited_band_members
      @band_fans                 = artist.limited_followers
      @connected_artists         = artist.connected_artists
    rescue =>exp
      logger.error "Error in Application::GetArtistObjectsForRightColumn :=> #{exp.message}"
    end
  end

  def get_band_associated_objects artist
    @band_members_count        = artist.band_members.count
    @other_bands               = current_user.admin_artists(artist)
    get_band_mentioned_posts artist
    messages_and_posts_count
    get_artist_objects_for_right_column(artist)
  end

  def get_band_bulletins_and_posts artist
    @posts                     = artist.find_own_as_well_as_mentioned_posts(params[:page])
    next_page                  = @posts.next_page
    @load_more_path            =  next_page ? band_more_posts_path(:band_name => artist.name, :page => next_page, :type => 'general') : nil
    @posts_order_by_dates      = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
    @bulletins                 = artist.bulletins
    bulletin_next_page         = @bulletins.next_page
    @load_more_bulletins_path  = bulletin_next_page ? band_more_bulletins_path(:band_name => artist.name, :page => bulletin_next_page) : nil
  end

  def get_band_mentioned_posts artist
    @posts                      = artist.mentioned_in_posts(params[:page])
    @posts_order_by_dates       = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
    next_page                   = @posts.next_page
    @load_more_path             = next_page ? more_posts_path(next_page, :type => 'mentions') : nil
  end

  # checks whether the logged in user is administrating the artist  
  def current_actor
    session[:artist_id].blank? ? current_user : Band.find(session[:artist_id])
  end

  # sets the current artist id when a ban starts administrating the artist profile
  def set_current_fan_artist artist_id
    session[:artist_id] = artist_id
  end

  # removes the current artist id(when a ban leaves administrating the artist profile)
  def reset_current_fan_artist
    session[:artist_id] = nil
  end

  def admin_login?
    is_admin = current_user && current_user.user_account_type == USER_TYPE_ADMIN
    is_admin
  end

  private
  
  def not_authenticated
    redirect_to root_url, :alert => "First login to access this page."
  end
  
  def logged_in_user
    #    redirect_to fan_home_url and return if current_user
    redirect_to user_home_url and return if current_user
  end

  #added to restrict the site from anonymous access
  def http_basic_authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "mustang" && password == 'mustang' #"must@ngs0undm3l0n"
    end
  end

  def messages_and_posts_count
    actor                         = current_actor
    if actor      
      @unread_mentioned_count     ||= actor.unread_mentioned_post_count
      @unread_post_replies_count  ||= actor.unread_post_replies_count      
      @unread_messages_count      ||= actor.receipts.inbox.unread.not_trash.size
    end
  end
  
end
