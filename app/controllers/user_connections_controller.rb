class UserConnectionsController < ApplicationController
  before_filter :require_login

  def follow
    if request.xhr?
      begin
        @user_to_be_followed = User.find(params[:id])
        current_user.follow(@user_to_be_followed)
        respond_to do |format|
          format.js and return
        end
      rescue
        render :nothing => true and return
      end
    else
      redirect_to fan_home_url and return
    end
  end

  def unfollow
    if request.xhr?
      begin
        @user_to_be_unfollowed = User.find(params[:id])
        current_user.stop_following(@user_to_be_unfollowed)
        respond_to do |format|
          @others = true if params[:others]
          format.js and return
        end
      rescue
        render :nothing => true and return
      end
    else
      redirect_to fan_home_url and return
    end
  end

  def follow_band
    if request.xhr?
      begin
        @band       = Band.find_band(params)
        current_user.follow(@band) unless current_user.following?(@band)
      rescue
        render :nothing => true and return
      end
    else
      redirect_to show_band_url(:band_name => params[:band_name]) and return
    end
  end

  def unfollow_band
    if request.xhr?
      begin
        @band       = Band.find_band(params)
        current_user.stop_following(@band)  if current_user.following?(@band)
      rescue
        render :nothing => true and return
      end
    else
      redirect_to show_band_url(:band_name => params[:band_name]) and return
    end
  end

  def band_followers    
    begin
      if params[:band_name]   # band item
        @band        = Band.find_band params        
        #          @followers  = band.user_followers.page(params[:page]).per(FOLLOWING_FOLLOWER_PER_PAGE)
        @followers   = @band.followers
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

  def fan_followers    
    begin
      if params[:id]
        @user            = User.find(params[:id])
        @followers       = @user.user_followers.page(params[:page]).per(FOLLOWING_FOLLOWER_PER_PAGE)
      else
        @user            = current_user
        @followers       = @user.user_followers.page(params[:page]).per(FOLLOWING_FOLLOWER_PER_PAGE)
      end
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
        @user                = User.find(params[:id])
        @following_artists   = @user.following_bands.page(params[:page]).per(FOLLOWING_FOLLOWER_PER_PAGE)
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
        @user           = User.find(params[:id])
        #          @following_fans = user.following_fans.page(params[:page]).per(FOLLOWING_FOLLOWER_PER_PAGE)
        @following_fans = @user.following_users.page(params[:page]).per(FOLLOWING_FOLLOWER_PER_PAGE)
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