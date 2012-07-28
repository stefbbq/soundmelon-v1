class UserConnectionsController < ApplicationController
  before_filter :require_login

  # from the list of own profile[1]
  # from fan's profile(update fan's right list of followers)[2]
  # from the list of other's profile(change the follow/unfollow link of the left list item)[3]
  # from search results list(change the follow/unfollow link of the left list item)[4]

  def follow
    if request.xhr?
      begin
        @actor                  = current_actor
        @user_to_be_followed    = User.find(params[:id])
        @actor.follow(@user_to_be_followed)
        NotificationMail.follow_notification @user_to_be_followed, @actor        
        @source_symbol          = params[:source]            
        if @source_symbol == '1'          
          @last_following_count = @actor.following_user_count
        elsif @source_symbol == '2'
          @last_follower_count  = @user_to_be_followed.followers_count        
        end
        respond_to do |format|
          format.js and return
        end
      rescue => exp
        logger.error "Error in UserConnections::Follow :=> #{exp.message}"
        render :nothing => true and return
      end
    else
      redirect_to fan_home_url and return
    end
  end

  def unfollow
    if request.xhr?
      begin
        @actor                  = current_actor
        @user_to_be_unfollowed  = User.find(params[:id])
        @actor.stop_following(@user_to_be_unfollowed)
        @source_symbol          = params[:source]            
        if @source_symbol == '1'
          @self_profile         = true
          @last_following_count = @actor.following_user_count
          @is_following_me      = @user_to_be_unfollowed.following? @actor
        elsif @source_symbol == '2'
          @last_follower_count  = @user_to_be_unfollowed.followers_count
        end        
        respond_to do |format|          
          format.js and return
        end
      rescue => exp
        logger.error "Error in UserConnections::Unfollow :=> #{exp.message}"
        render :nothing => true and return
      end
    else
      redirect_to fan_home_url and return
    end
  end

  def follow_artist
    if request.xhr?
      begin
        @actor                  = current_actor
        @artist                 = Artist.find_artist(params)
        @actor.follow(@artist)
        @source_symbol          = params[:source]                
        @last_follower_count    = @artist.followers_count
        @last_following_count   = @actor.following_user_count
        NotificationMail.follow_notification @artist, @actor
      rescue => exp
        logger.error "Error in UserConnections::FollowArtist :=> #{exp.message}"
        render :nothing => true and return
      end
    else
      redirect_to show_artist_url(:artist_name => params[:artist_name]) and return
    end
  end

  def unfollow_artist
    if request.xhr?
      begin
        @actor                  = current_actor
        @artist                 = Artist.find_artist(params)
        @actor.stop_following(@artist)
        @source_symbol          = params[:source]        
        @last_follower_count    = @artist.followers_count
        @last_following_count   = @actor.following_artist_count
      rescue => exp
        logger.error "Error in UserConnections::UnollowArtist :=> #{exp.message}"
        render :nothing => true and return
      end
    else
      redirect_to show_artist_url(:artist_name => params[:artist_name]) and return
    end
  end

  def connect_artist
    @actor                  = current_actor
    if request.xhr?
      begin
        @artist                   = Artist.find_artist(params)
        @actor.connect_artist(@artist)        
        @last_connection_count  = @artist.connections_count
        @connected              = @actor.connected_with?(@artist)
        if @connected
          NotificationMail.connect_notification @actor, @artist
        else
          NotificationMail.connect_request_notification @artist, @actor
        end        
      rescue => exp
        logger.error "Error in UserConnections::ConnectArtist :=> #{exp.message}"
        render :nothing => true and return
      end
    else
      redirect_to show_artist_url(params[:artist_name]) and return
    end
  end

  def disconnect_artist
    @actor                      = current_actor
    if request.xhr?
      begin        
        @artist                 = Artist.find_artist(params)
        @actor.disconnect_artist(@artist)
        @last_connection_count  = @artist.connections_count
        @is_self_profile        = params[:self] && params[:self] == "1"
      rescue => exp
        logger.error "Error in UserConnections::DisconnectArtist :=> #{exp.message}"
        render :nothing => true and return
      end
    else
      redirect_to show_artist_url(params[:artist_name]) and return
    end
  end

  def artist_followers    
    begin
      if params[:artist_name]   # artist item
        @actor                  = current_actor
        @artist                   = Artist.find_artist params
        @followers              = @artist.followers params[:page]
        get_artist_objects_for_right_column(@artist)
      end
      respond_to do |format|
        format.js and return
        format.html and return
      end
    rescue =>exp
      logger.error "Error in UserConnections#Followers : #{exp.message}"
      render :nothing => true and return
    end
  end

  def artist_connections
    begin
      if params[:artist_name]   # artist item
        @actor                  = current_actor
        @artist                   = Artist.find_artist params
        @connections            = @artist.connected_artists params[:page]
        get_artist_objects_for_right_column(@artist)
      end
      respond_to do |format|
        format.js and return
        format.html and return
      end
    rescue =>exp
      logger.error "Error in UserConnections#ArtistConnections : #{exp.message}"
      render :nothing => true and return
    end
  end

  def fan_followers    
    begin
      @actor                    = current_actor
      @user                     = User.find(params[:id])
      @followers                = @user.followers params[:page]
      get_fan_objects_for_right_column(@user)
      respond_to do |format|
        format.js and return
        format.html and return
      end
    rescue =>exp
      logger.error "Error in UserConnections#FanFollowers : #{exp.message}"
      render :nothing => true and return
    end
  end

  def fan_following_artists    
    begin
      if params[:id]
        @actor                  = current_actor
        @user                   = User.find(params[:id])
        @fan_following_artists  = @user.following_artists.page(1).per(FOLLOWING_FOLLOWER_PER_PAGE)
      end
      get_fan_objects_for_right_column(@user)
      respond_to do |format|
        format.js and return
        format.html and return
      end
    rescue =>exp
      logger.error "Error in UserConnections#FanFollowingArtists : #{exp.message}"
      render :nothing => true and return
    end    
  end

  def fan_following_fans    
    begin
      if params[:id]
        @actor                  = current_actor
        @user                   = User.find(params[:id])        
        @following_fans         = @user.following_users.page(params[:page]).per(FOLLOWING_FOLLOWER_PER_PAGE)
      end
      get_fan_objects_for_right_column(@user)
      respond_to do |format|
        format.js and return
        format.html and return
      end
    rescue => exp
      logger.error "Error in UserConnections#FanFollowingFans : #{exp.message}"
      render :nothing => true and return
    end
  end
    
end