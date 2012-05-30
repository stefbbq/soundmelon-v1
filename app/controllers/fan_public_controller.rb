class FanPublicController < ApplicationController
  before_filter :require_login
  
  def index    
    messages_and_posts_count
    #for other users
    @user = User.find(params[:id])
    if @user #&& @user!=current_user
      @posts                  = @user.find_own_posts(params[:page])
      @posts_order_by_dates   = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      next_page               = @posts.next_page
      @load_more_path         = next_page ? user_more_post_path(@user, :page => next_page) : nil
      get_fan_objects_for_right_column(@user)
    else
      redirect_to fan_home_path, :error => "No user has been found with this user id"
    end
  end

  def latest_posts
    if request.xhr?
      @user                   = User.find(params[:id])
      if @user #&& @user!=current_user
        @posts                = @user.find_own_posts(params[:page])
        @posts_order_by_dates = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
        next_page             = @posts.next_page
        @load_more_path       = next_page ? user_more_post_path(@user, :page => next_page) : nil
        get_fan_objects_for_right_column(@user)
      else
        render :nothing =>true and return
      end
    else
      redirect_to root_url and return
    end
  end
  
end