class UserConnectionsController < ApplicationController
  before_filter :require_login

  def follow
    if request.xhr?
      begin
        @actor                  = current_actor
        @user_to_be_followed    = User.find(params[:id])
        @actor.follow(@user_to_be_followed)
        @last_follower_count    = @user_to_be_followed.followers_count
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
        @last_follower_count    = @user_to_be_unfollowed.followers_count
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

  def follow_band
    if request.xhr?
      begin
        @actor                  = current_actor
        @band                   = Band.find_band(params)
        @actor.follow(@band)
        @last_follower_count    = @band.followers_count
        @last_following_count   = @actor.following_user_count
      rescue => exp
        logger.error "Error in UserConnections::FollowBand :=> #{exp.message}"
        render :nothing => true and return
      end
    else
      redirect_to show_band_url(:band_name => params[:band_name]) and return
    end
  end

  def unfollow_band
    if request.xhr?
      begin
        @actor                  = current_actor
        @band                   = Band.find_band(params)
        @actor.stop_following(@band)
        @last_follower_count    = @band.followers_count
        @last_following_count   = @actor.following_band_count
      rescue => exp
        logger.error "Error in UserConnections::UnollowBand :=> #{exp.message}"
        render :nothing => true and return
      end
    else
      redirect_to show_band_url(:band_name => params[:band_name]) and return
    end
  end

  def connect_artist
    @actor                  = current_actor
    if request.xhr?
      begin
        @band                   = Band.find_band(params)
        @actor.connect_artist(@band)
        @last_connection_count  = @band.connections_count
        @connected              = @actor.connected_with?(@band)
        @is_self_profile        = params[:self] && params[:self] == "1"
        logger.error "Is Self#{@is_self_profile}"
      rescue => exp
        logger.error "Error in UserConnect0Testions::ConnectArtist :=> #{exp.message}"
        render :nothing => true and return
      end
    else
      redirect_to show_band_url(:band_name => params[:band_name]) and return
    end
  end

  def disconnect_artist
    @actor                      = current_actor
    if request.xhr?
      begin        
        @band                   = Band.find_band(params)
        @actor.disconnect_artist(@band)
        @last_connection_count  = @band.connections_count
        @is_self_profile        = params[:self] && params[:self] == "1"
      rescue => exp
        logger.error "Error in UserConnections::DisconnectBand :=> #{exp.message}"
        render :nothing => true and return
      end
    else
      redirect_to show_band_url(:band_name => params[:band_name]) and return
    end
  end

  def band_followers    
    begin
      if params[:band_name]   # band item
        @actor                  = current_actor
        @band                   = Band.find_band params
        @followers              = @band.followers params[:page]
        get_artist_objects_for_right_column(@band)
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
      if params[:band_name]   # band item
        @actor                  = current_actor
        @band                   = Band.find_band params
        @connections            = @band.connected_artists# params[:page]
        get_artist_objects_for_right_column(@band)
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
        @following_artists      = @user.following_bands.page(params[:page]).per(FOLLOWING_FOLLOWER_PER_PAGE)
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