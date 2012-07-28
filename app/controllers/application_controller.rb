class ApplicationController < ActionController::Base
  protect_from_forgery
  #before_filter :http_basic_authenticate
  # this is needed to prevent XHR request form using layouts
  before_filter proc { |controller| (controller.action_has_layout = false) if controller.request.xhr? }
  before_filter :check_user_browser, :set_current_actor
  
  after_filter :messages_and_posts_count
  
  helper_method :current_actor, :admin_login?

  protected

  def set_current_actor
    @actor = current_actor
  end

  def check_user_browser
    agent = Agent.new request.env['HTTP_USER_AGENT']
    puts agent.version
    puts agent.name
    if agent.name == "IE" && agent.version == "8.0" || agent.version == "7.0" || agent.version == "6.0"
      render :template =>'/bricks/page_for_ie', :layout => false and return
    end    
  end
  
  def get_user_associated_objects
    @following_artists        = current_user.following_artist.order('RAND()').limit(NO_OF_FOLLOWING_TO_DISPLAY)
    @following_artist_count   = current_user.following_artist.count
    @following_users          = current_user.following_user.order('RAND()').limit(NO_OF_FOLLOWING_TO_DISPLAY)
    @following_count          = current_user.following_user.count
    @followers_users          = current_user.limited_followers
    @followers_count          = current_user.followers_count
    @playlist_songs           = current_user.playlists
    @playlist_songs_id        = @playlist_songs.map{|playlist_song| playlist_song.song_id}
    @user ||= current_user
  end

  def get_fan_objects_for_right_column fan
    @following_artists        = fan.following_artist.order('RAND()').limit(NO_OF_FOLLOWING_TO_DISPLAY)
    @following_artist_count   = fan.following_artist.count
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
      @song_album_count          = artist.artist_musics.size
      @photo_album_count         = artist.artist_albums.size
      @show_count                = artist.artist_shows.size
      @artist_member_count       = artist.artist_members.size
      @artist_fan_count          = artist.followers_count
      @artist_connection_count   = artist.connections_count
      @song_albums               = artist.limited_artist_musics
      @featured_songs            = artist.limited_artist_featured_songs
      @photo_albums              = artist.limited_artist_albums(2)
      @artist_shows              = artist.limited_artist_shows
      @artist_members            = artist.limited_artist_members
      @artist_fans               = artist.limited_followers
      @connected_artists         = artist.connected_artists      
    rescue =>exp
      logger.error "Error in Application::GetArtistObjectsForRightColumn :=> #{exp.message}"
    end
  end

  def get_artist_associated_objects artist
    @artist_members_count        = artist.artist_members.count
    @other_artists               = current_user.admin_artists_list(artist)
    get_artist_mentioned_posts artist
    messages_and_posts_count
    get_artist_objects_for_right_column(artist)
  end

  def get_artist_bulletins_and_posts artist
    @posts                     = artist.find_own_posts(params[:page])
    next_page                  = @posts.next_page
    @load_more_path            = next_page ? artist_more_posts_path(artist, next_page, 'general') : nil
    @posts_order_by_dates      = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
    @bulletins                 = artist.bulletins
    bulletin_next_page         = @bulletins.next_page
    @load_more_bulletins_path  = bulletin_next_page ? artist_more_bulletins_path(artist, bulletin_next_page) : nil
  end

  def get_current_fan_posts
    @posts                      = current_user.find_own_as_well_as_following_user_posts(params[:page])
    @posts_order_by_dates       = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
    next_page                   = @posts.next_page
    @load_more_path             = next_page ? more_post_path(:page => next_page) : nil
  end

  def get_artist_mentioned_posts artist
    @posts                      = artist.mentioned_in_posts(params[:page])    
    #@posts                      = artist.find_own_as_well_as_mentioned_posts(params[:page])
    @posts_order_by_dates       = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
    next_page                   = @posts.next_page
    @load_more_path             = next_page ? more_posts_path(next_page, :type => 'mentions') : nil
  end

  # checks whether the logged in user is administrating the artist  
  def current_actor
    session[:artist_id].blank? ? current_user : Artist.find(session[:artist_id])
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
