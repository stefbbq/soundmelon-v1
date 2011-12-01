class FollowController < ApplicationController
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
      redirect_to user_home_url and return
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
      redirect_to user_home_url and return
    end
  end
  
  def follower
    if request.xhr?
      begin
        if params[:id]
          user = User.find(params[:id])
          @followers = user.user_followers.page(params[:page]).per(FOLLOWING_FOLLOWER_PER_PAGE)
        else  
          @followers = current_user.user_followers.page(params[:page]).per(FOLLOWING_FOLLOWER_PER_PAGE)
        end
        respond_to do |format|
          format.js and return
        end
      rescue 
       render :nothing => true and return
      end    
    else
      redirect_to user_home_url and return
    end
  end
  
  def following
    if request.xhr?
      begin
        if params[:id]
          user = User.find(params[:id])
          @following = user.following_users.page(params[:page]).per(FOLLOWING_FOLLOWER_PER_PAGE)
        else  
          @following = current_user.following_users.page(params[:page]).per(FOLLOWING_FOLLOWER_PER_PAGE)
        end
        respond_to do |format|
          format.js  and return
        end
      rescue 
       render :nothing => true and return
      end    
    else
      redirect_to user_home_url and return
    end
  end
  
end