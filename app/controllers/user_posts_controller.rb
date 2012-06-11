class UserPostsController < ApplicationController
  before_filter :require_login
  
  def index
    if params[:type]
      if params[:type] == 'mentioned'
        @posts = current_user.mentioned_posts(params[:page])
      else
        @posts = current_user.replies_post(params[:page])
      end
    elsif params[:id]
      user = User.find params[:id]
      @posts = user.find_own_posts(params[:page])
    else
      @posts = current_user.find_own_as_well_as_following_user_posts(params[:page])
    end
    @posts_order_by_dates = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
    if request.xhr?
      next_page           = @posts.next_page
      if params[:type]
        @load_more_path =  next_page ?  more_post_path(:page => next_page, :type => params[:type]) : nil
      elsif params[:id]
        @load_more_path =  next_page ?  user_more_post_path(user, :page => next_page) : nil
      else
        @load_more_path =  next_page ?  more_post_path(:page => next_page) : nil
      end
    end
    respond_to do |format|
      format.json
      format.html
    end
  end
  
  def create
    if params[:band_id].present?
      begin
        @band = Band.where(:id => params[:band_id]).first
        if current_user.is_admin_of_band?(@band)
          @post = @band.posts.build(params[:post])    
        else
          raise
        end
      rescue
        render :nothing => true and return
      end
    else  
      @post = current_user.posts.build(params[:post])
      @post.is_bulletin = false
    end 
    
    if @post.save
      respond_to do |format|
        format.html { redirect_to fan_home_path, notice: 'Successfully Posted.' }
        format.js {render :layout => false }
      end
    end
  end
 
  def destroy
    @post = Post.where(:id => params[:id]).includes(:user, :band).first
    if !@post.user.nil? && @post.user == current_user
      @post.is_deleted = true
    elsif !@post.band.nil? && current_user.is_admin_of_band?(@post.band)   
      @post.is_deleted = true
    end
    if @post.save
      respond_to do |format|
        format.html { redirect_to fan_home_path }
        format.js {render :layout => false }
      end
    end
  end
  
  def new_reply
    if request.xhr?
      begin
        @parent_post          = Post.find(params[:id])
        if params[:band_id].present?
          @band               = Band.where(:id => params[:band_id]).first
          if current_user.is_admin_of_band?(@band) #&& @band.is_part_of_post?(@parent_post)
            participating_users_and_band_mention_names_arr = @parent_post.owner_as_well_as_all_mentioned_users_and_bands_except(@band.id, false)
          else
            raise
          end
        elsif #current_user.is_part_of_post?(@parent_post)
          participating_users_and_band_mention_names_arr = @parent_post.owner_as_well_as_all_mentioned_users_and_bands_except(current_user.id)
        else
          render :nothing => true and return 
        end
      rescue =>exp
        logger.error "Error in UserPosts#NewReply :=> #{exp.message}"
        render :nothing => true and return
      end
      @post = Post.new
      @post.msg = participating_users_and_band_mention_names_arr.join(' ')
      respond_to do |format|
        format.js {render :layout => false}
      end
    else
      redirect_to root_url and return
    end
  end
  
  def reply
    if request.xhr?
      begin
        @parent_post = Post.find(params[:parent_post_id])
        if params[:band_id].present?
          @band = Band.where(:id => params[:band_id]).first
          if current_user.is_admin_of_band?(@band) #&& @band.is_part_of_post?(@parent_post)
            @post = @band.posts.build(params[:post])
          else
            raise
          end
        else #current_user.is_part_of_post?(@parent_post)
          @post = current_user.posts.build(params[:post])          
        end
      rescue
        render :nothing => true and return
      end
      @post.parent_id = @parent_post.id
      if @post.save
        @saved_successfully = true
      end
      respond_to do |format|
        format.js {render :layout => false}
      end
    else
      redirect_to root_url and return
    end  
  end
  
  def post_threads
    if request.xhr?
      @post       = Post.where(:id => params[:id]).first
      @posts      = @post.path
      respond_to do |format|
        format.js {render :layout => false}
      end
    else
      redirect_to root_url and return
    end
  end
  
  def mentioned
    @user                         = current_actor
    if @user.is_fan?
      @posts                      = @user.mentioned_posts(params[:page])
      @posts_order_by_dates       = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      next_page                   = @posts.next_page
      @load_more_path             = next_page ? more_post_path(next_page, :type=>'mentioned') : nil
      @unread_mentioned_count     = @user.unread_mentioned_post_count
      @unread_post_replies_count  = @user.unread_post_replies_count
      @unread_messages_count      = @user.received_messages.unread.count      
      get_user_associated_objects unless request.xhr?
      render :template =>'/user_posts/mentioned' and return
    else
      @band                       = @user
      @posts                      = @band.mentioned_in_posts(params[:page])
      @posts_order_by_dates       = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      next_page                   = @posts.next_page
      @load_more_path             = next_page ? more_posts_path(next_page, :type => 'mentions') : nil
      @unread_mentioned_count     = @band.unread_mentioned_post_count
      @unread_post_replies_count  = @band.unread_post_replies_count
      @unread_messages_count      = @band.received_messages.unread.count
      # get right column objects
      get_artist_objects_for_right_column(@band) unless request.xhr?
      render :template =>"/user_posts/mentions_post" and return
    end    
  end
  
  def replies
    @user   = current_actor
    if @user.is_fan?
      @posts                      = @user.replies_post(params[:page])
      @posts_order_by_dates       = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      next_page                   = @posts.next_page
      @load_more_path             = next_page ? more_post_path(next_page, :type=>'replies') : nil
      @unread_mentioned_count     = @user.unread_mentioned_post_count
      @unread_post_replies_count  = @user.unread_post_replies_count
      @unread_messages_count      = @user.received_messages.unread.count
      # get right column objects
      get_user_associated_objects unless request.xhr?
      render :template =>"/user_posts/replies" and return
    else
      @band                      = @user
      @posts                     = @band.replies_post(params[:page])
      @posts_order_by_dates      = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      next_page                  = @posts.next_page
      @load_more_path            =  next_page ? more_posts_path(next_page, :type => 'replies') : nil
      @unread_mentioned_count    = @band.unread_mentioned_post_count
      @unread_post_replies_count = @band.unread_post_replies_count
      @unread_messages_count     = @band.received_messages.unread.count
      # get right column objects
      get_artist_objects_for_right_column(@band) unless request.xhr?
      render :template =>"/user_posts/replies_post" and return
    end
  end

  def more_bulletins
    if request.xhr?
      begin
        @band                       = Band.where(:name => params[:band_name]).first
        @bulletins                  = @band.bulletins(params[:page])
        bulletin_next_page          = @bulletins.next_page
        @load_more_bulletins_path   = bulletin_next_page ? band_more_bulletins_path(:band_name => @band.name, :page => bulletin_next_page) : nil
      rescue
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end
  end

  def more_posts
    if request.xhr?
      begin
        @band = Band.where(:name => params[:band_name]).first
        if params[:type] && params[:type] == 'general'
          @posts          = @band.find_own_posts(params[:page])
          next_page       = @posts.next_page
          @load_more_path =  next_page ? band_more_posts_path(:band_name => @band.name, :page => next_page) : nil
        elsif params[:type] && current_user.is_admin_of_band?(@band)
          if params[:type] == 'replies'
            @posts = @band.replies_post(params[:page])
          elsif params[:type] == 'mentions'
            @posts = @band.mentioned_in_posts(params[:page])
          else
            @posts = @band.find_own_as_well_as_mentioned_posts(params[:page])
          end
          @is_admin_of_band = true
          next_page = @posts.next_page
          @load_more_path =  next_page ? band_more_posts_path(:band_name => @band.name, :page => next_page, :type => params[:type]) : nil
        else
          render :nothing => true and return
        end
      rescue
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end
  end
  
end