class UserPostsController < ApplicationController
  before_filter :require_login
  
  def index
    @user_posts    = UserPost.listing current_user, params[:page]
    @user_post_dates = @user_posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
    if request.xhr?      
      next_page           = @user_posts.next_page
      @load_more_path =  next_page ?  more_post_path(next_page) : nil
      #render @user_posts
    end

  end
  
  def create
    user = User.find(params[:user_id])
    @user_post = user.user_posts.build(params[:user_post])
    if current_user.id == user.id
      @user_post.user_id = current_user.id
      if @user_post.save
        respond_to do |format|
          format.html { redirect_to user_home_path, notice: 'User post was successfully created.' }
          format.js {render :layout => false }
        end
      end
    end
  end

  def destroy
    @user_post = UserPost.find(params[:id])
    if @user_post.user_id == current_user.id
      if @user_post.update_attribute(:is_deleted,true)
        respond_to do |format|
          format.html { redirect_to user_home_path }
          format.js {render :layout => false }
        end
      end
    end
  end 
end
