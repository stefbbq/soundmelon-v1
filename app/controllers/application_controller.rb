class ApplicationController < ActionController::Base
  protect_from_forgery
  #before_filter :http_basic_authenticate
  # this is needed to prevent XHR request form using layouts
  before_filter proc { |controller| (controller.action_has_layout = false) if controller.request.xhr? }
  before_filter :check_user_browser, :current_actor
  
  after_filter :messages_and_posts_count
  
  helper_method :current_actor, :admin_login?

  protected

  def check_user_browser
    agent = Agent.new request.env['HTTP_USER_AGENT']
    if agent.name.to_s == "IE"
      case agent.version
      when "6.0"
        render :template =>'/bricks/page_for_ie', :layout => false and return
      when "7.0"
        render :template =>'/bricks/page_for_ie', :layout => false and return
      when "8.0"
        render :template =>'/bricks/page_for_ie', :layout => false and return
      end
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
      @has_admin_access          = @actor == artist
      @artist_music_count        = artist.artist_musics.size
      @photo_album_count         = artist.albums.size
      @show_count                = artist.upcoming_shows_count
      @artist_member_count       = artist.artist_members.size
      @artist_fan_count          = artist.followers_count
      @artist_connection_count   = artist.connections_count
      @artist_musics             = artist.limited_artist_musics
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

  # instantiates all venue objects for rendering in right column
  def get_venue_objects_for_right_column venue
    begin
      @has_admin_access   = @actor == venue
      @photo_album_count  = venue.albums.size
      @show_count         = venue.upcoming_shows_count
      @fan_count          = venue.followers_count      
      @photo_albums       = venue.limited_albums(2)
      @shows              = venue.limited_shows
      @fans               = venue.limited_followers      
    rescue =>exp
      logger.error "Error in Application::GetVenueObjectsForRightColumn :=> #{exp.message}"
    end
  end

  def get_artist_associated_objects artist
    @artist_members_count        = artist.artist_members.count
    @other_artists               = current_user.admin_artists_list(artist)
    get_artist_mentioned_posts artist
    #    get_artist_bulletins_and_posts artist
    messages_and_posts_count
    get_artist_objects_for_right_column(artist)
  end

  def get_artist_bulletins_and_posts artist
    @posts                     = artist.find_own_posts(params[:page])
    next_page                  = @posts.next_page
    @load_more_path            = next_page ? artist_more_posts_path(artist, 'general', next_page) : nil
    @posts_order_by_dates      = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
    @bulletins                 = artist.bulletins
    bulletin_next_page         = @bulletins.next_page
    @load_more_bulletins_path  = bulletin_next_page ? artist_more_bulletins_path(artist, bulletin_next_page) : nil
  end

  def get_venue_associated_objects venue
    @venue_members_count        = venue.venue_members.count
    @other_venues               = current_user.admin_venues_list(venue)
    get_venue_mentioned_posts venue
    messages_and_posts_count
    get_venue_objects_for_right_column(venue)
  end
  
  def get_venue_bulletins_and_posts venue
    @posts                     = venue.find_own_posts(params[:page])
    next_page                  = @posts.next_page
    @load_more_path           = next_page ? venue_more_posts_path(venue, 'general', next_page) : nil
    @load_more_path = nil
    @posts_order_by_dates      = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
    @bulletins                 = venue.bulletins
    bulletin_next_page         = @bulletins.next_page
    @load_more_bulletins_path  = bulletin_next_page ? venue_more_bulletins_path(venue, bulletin_next_page) : nil
    @load_more_bulletins_path  = nil
  end

  def get_current_fan_posts
    @posts                      = current_user.find_own_as_well_as_following_user_posts(params[:page])
    @posts_order_by_dates       = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
    next_page                   = @posts.next_page
    @load_more_path             = next_page ? more_post_path(:page => next_page) : nil
  end

  def get_artist_mentioned_posts artist
    #    @posts                      = artist.mentioned_in_posts(params[:page])
    @posts                      = artist.find_own_as_well_as_mentioned_posts(params[:page])
    @posts_order_by_dates       = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
    next_page                   = @posts.next_page
    #    @load_more_path             = next_page ? artist_more_posts_path(artist, 'mentions', next_page) : nil
    @load_more_path             = next_page ? artist_more_posts_path(artist, 'general', next_page) : nil
  end

  def get_venue_mentioned_posts venue
    @posts                      = venue.find_own_as_well_as_mentioned_posts(params[:page])
    @posts_order_by_dates       = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
    next_page                   = @posts.next_page    
    @load_more_path             = next_page ? venue_more_posts_path(artist, 'general', next_page) : nil
  end

  # checks for logged-in useriem(artist/venue) and if not present returns current user 
  def current_actor
    begin
      if (class_name=session[:useritem_type]).present? and (id=session[:useritem_id]).present?
        @actor = eval(class_name).find(id)
      else
        @actor = current_user
      end
    rescue =>exp
      logger.error "Error in CurrentActor :=> #{exp.message}"
    end
  end
  
  # sets the current user item id(switch to user item profile like artist, venue)
  def set_current_useritem useritem
    session[:useritem_id]   = useritem.id
    session[:useritem_type] = useritem.class.name
  end

  # removes the current user item id(switch back to fan profile)
  def reset_current_useritem
    session[:useritem_id]   = nil
    session[:useritem_type] = nil
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
    if @actor      
      @unread_mentioned_count     ||= @actor.unread_mentioned_post_count
      @unread_post_replies_count  ||= @actor.unread_post_replies_count
      @unread_messages_count      ||= @actor.receipts.inbox.unread.not_trash.size
    else
      logger.error "no actor is present at #{Time.now.to_s}"
    end
  end
  
end
