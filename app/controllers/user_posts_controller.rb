class UserPostsController < ApplicationController
  before_filter :require_login
  
  def index
    if params[:type]
      if params[:type] == 'mentioned'
        @posts            = current_user.mentioned_posts(params[:page])
      else
        @posts            = current_user.replies_post(params[:page])
      end
    elsif params[:id]
      user                = User.find params[:id]
      @posts              = user.find_own_posts(params[:page])
    else
      @posts              = current_user.find_own_as_well_as_following_user_posts(params[:page])
    end
    @posts_order_by_dates = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
    if request.xhr?
      next_page           = @posts.next_page
      if params[:type]
        @load_more_path   =  next_page ?  more_post_path(:page => next_page, :type => params[:type]) : nil
      elsif params[:id]
        @load_more_path   =  next_page ?  user_more_post_path(user, :page => next_page) : nil
      else
        @load_more_path   =  next_page ?  more_post_path(:page => next_page) : nil
      end
    end
  end
  
  def create
    actor = current_actor
    @post = actor.posts.build(params[:post])
    if @post.save
      respond_to do |format|
        format.html { redirect_to fan_home_path, notice: 'Successfully Posted.' }
        format.js {render :layout => false }
      end
    end
  end
 
  def destroy
    @post = Post.where(:id => params[:id]).includes(:user, :artist).first
    if !@post.user.nil? && @post.user == current_user
      @post.is_deleted = true
      @post.destroy
    elsif !@post.artist.nil? && current_user.is_admin_of_artist?(@post.artist)   
      @post.is_deleted = true
      @post.destroy
    end    
    respond_to do |format|
      format.html { redirect_to fan_home_path }
      format.js {render :layout => false }
    end
  end
  
  def new_reply
    if request.xhr?
      begin
        actor                 = current_actor
        @parent_post          = Post.find(params[:id])
        #        participating_users_and_artist_mention_names_arr = @parent_post.owner_as_well_as_all_mentioned_users_and_artists_except(actor.id)
      rescue =>exp
        logger.error "Error in UserPosts#NewReply :=> #{exp.message}"
#        render :nothing => true and return
        @parent_post          = nil
      end
      @post                   = Post.new
      #      @post.msg               = participating_users_and_artist_mention_names_arr.join(' ')
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
        @parent_post              = Post.where('id = ?', params[:parent_post_id]).includes(:artist,:user).first
        actor                     = current_actor
        @post                     = actor.posts.build(params[:post])
        parent_post_writer_user   = @parent_post.artist || @parent_post.user
      rescue =>exp
        logger.error "Error in UserPosts::Reply :=>#{exp.message}"
        render :nothing => true and return
      end
      @post.parent_id = @parent_post.id
      if @post.save
        NotificationMail.reply_notification parent_post_writer_user, actor, @post
        @saved_successfully = true
      end
      respond_to do |format|
        format.js {render :layout => false}
      end
    else
      redirect_to root_url and return
    end  
  end
  
  def show_conversation_thread
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
      messages_and_posts_count
      get_user_associated_objects
      render :template =>'/user_posts/mentioned' and return
    else
      @artist                     = @user
      @posts                      = @artist.mentioned_in_posts(params[:page])
      @posts_order_by_dates       = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      next_page                   = @posts.next_page
      @load_more_path             = next_page ? more_posts_path(next_page, :type => 'mentions') : nil
      messages_and_posts_count
      # get right column objects
      get_artist_objects_for_right_column(@artist)
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
      messages_and_posts_count
      # get right column objects
      get_user_associated_objects
      render :template =>"/user_posts/replies" and return
    else
      @artist                    = @user
      @posts                     = @artist.replies_post(params[:page])
      @posts_order_by_dates      = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      next_page                  = @posts.next_page
      @load_more_path            =  next_page ? more_posts_path(next_page, :type => 'replies') : nil
      messages_and_posts_count
      # get right column objects
      get_artist_objects_for_right_column(@artist)
      render :template =>"/user_posts/replies_post" and return
    end
  end

  def more_bulletins
    if request.xhr?
      begin
        @artist                     = Artist.where(:mention_name => params[:artist_name]).first
        @bulletins                  = @artist.bulletins(params[:page])
        bulletin_next_page          = @bulletins.next_page
        @load_more_bulletins_path   = bulletin_next_page ? artist_more_bulletins_path(@artist, bulletin_next_page) : nil
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
        @artist           = Artist.where(:mention_name => params[:artist_name]).first
        if params[:type] && params[:type] == 'general'
          @posts          = @artist.find_own_posts(params[:page])
          next_page       = @posts.next_page
          @load_more_path =  next_page ? artist_more_posts_path(@artist, next_page, params[:type]) : nil
        elsif params[:type] && current_user.is_admin_of_artist?(@artist)
          if params[:type] == 'replies'
            @posts = @artist.replies_post(params[:page])
          elsif params[:type] == 'mentions'
            @posts = @artist.mentioned_in_posts(params[:page])
          else
            @posts    = @artist.find_own_as_well_as_mentioned_posts(params[:page])
          end
          @is_admin_of_artist = true
          next_page   = @posts.next_page
          @load_more_path =  next_page ? artist_more_posts_path(@artist, next_page, params[:type]) : nil
        else
          render :nothing => true and return
        end
        @posts_order_by_dates = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      rescue
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end
  end

  def new_mention_post
    if request.xhr?
      begin
        mention_item          = params[:artist_id].present? ? Artist.find(params[:artist_id]) : User.find(params[:fan_id])
      rescue =>exp
        logger.error "Error in UserPosts#NewReply :=> #{exp.message}"
        render :nothing => true and return
      end
      @post                   = Post.new
      @post.msg               = "@#{mention_item.mention_name}" if mention_item
      respond_to do |format|
        format.js {render :layout => false}
      end
    else
      redirect_to root_url and return
    end    
  end

  def create_mention_post
    if request.xhr?
      begin
        #mention_item           = params[:artist_id].present? ? Artist.find(params[:artist_id]) : User.find(params[:fan_id])
        actor                   = current_actor
        @post                   = actor.posts.build(params[:post])        
      rescue =>exp
        logger.error "Error in UserPosts::CreateMentionPost :=>#{exp.message}"
        render :nothing => true and return
      end      
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
  
end