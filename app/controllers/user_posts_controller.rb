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
#    @has_link_access      = true
  end
  
  def create
    actor     = @actor
    @new_post = actor.posts.build(params[:post])
    if @new_post.save
      respond_to do |format|
        format.html { redirect_to user_home_path, notice: 'Successfully Posted.' }
        format.js {render :layout => false }
      end
    end
  end
 
  def destroy
    begin
      @post               = Post.where(:id => params[:id]).includes(:user, :artist).first
      @parent_post_id     = @post.ancestry      
      actor_has_access    = @post.useritem_id == @actor.id && @post.useritem_type == @actor.class.name
      if actor_has_access        
        @post.delete_me
      end
    rescue =>exp
      logger.error "Error in UserPosts::Destroy :=>#{exp.message}"
      @post = nil
    end
    respond_to do |format|
      format.html { redirect_to user_home_path }
      format.js {render :layout => false }
    end
  end
  
  def new_reply
    if request.xhr?
      begin
        actor                 = @actor
        @parent_post          = Post.find(params[:id])
        #        participating_users_and_artist_mention_names_arr = @parent_post.owner_as_well_as_all_mentioned_users_and_artists_except(actor.id)
      rescue =>exp
        logger.error "Error in UserPosts#NewReply :=> #{exp.message}"
        #        render :nothing => true and return
        @parent_post          = nil
      end
      @new_post               = Post.new
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
        @parent_post                = Post.where('id = ?', params[:parent_post_id]).includes(:artist,:user).first
        actor                       = @actor
        params[:post][:reply_to_id] = params[:parent_post_id]
        @post                       = actor.posts.build(params[:post])
        parent_post_writer_user     = @parent_post.writer_actor
      rescue =>exp        
        @parent_post              = nil
        logger.error "Error in UserPosts::Reply :=>#{exp.message}"
        render :nothing => true and return
      end
      # only if the parent post still exists
      if @parent_post
        @post.parent_id             = @parent_post.id
        if @post.save
          NotificationMail.reply_notification parent_post_writer_user, actor, @post
          @saved_successfully = true
        end
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
      @main_post  = Post.where(:id => params[:id]).first
      @posts      = @main_post.path      
      respond_to do |format|
        format.js {render :layout => false}
      end
    else
      redirect_to root_url and return
    end
  end
  
  def mentioned
    @user                         = @actor
    @has_link_access              = true
    @is_homepage                  = true
    if @user.is_fan?
      @posts                      = @user.item_mentioned_posts(params[:page])
      @posts_order_by_dates       = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      next_page                   = @posts.next_page
      @load_more_path             = next_page ? more_post_path(next_page, :type=>'mentioned') : nil
      messages_and_posts_count
      get_user_associated_objects
      render :template =>'/user_posts/mentioned' and return
    elsif @user.is_artist?
      @artist                     = @user
      get_artist_mentioned_posts(@artist)
      messages_and_posts_count
      # get right column objects
      get_artist_objects_for_right_column(@artist)
      render :template =>"/user_posts/mentions_post" and return
    elsif @user.is_venue?
      @venue                     = @user
      get_venue_mentioned_posts(@venue)
      messages_and_posts_count
      # get right column objects
      get_venue_objects_for_right_column(@venue)
      render :template =>"/user_posts/mentions_post" and return
    end    
  end
  
  def replies
    @user                         = @actor
    @is_homepage                  = true
    @has_link_access              = true
    if @user.is_fan?
      @posts                      = @user.replies_post(params[:page])
      @posts_order_by_dates       = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      next_page                   = @posts.next_page
      @load_more_path             = next_page ? more_post_path(next_page, :type=>'replies') : nil
      messages_and_posts_count
      # get right column objects
      get_user_associated_objects
      render :template =>"/user_posts/replies" and return
    elsif @user.is_artist?
      @artist                    = @user
      @posts                     = @artist.replies_post(params[:page])
      @posts_order_by_dates      = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      next_page                  = @posts.next_page
      @load_more_path            =  next_page ? more_posts_path(next_page, :type => 'replies') : nil
      messages_and_posts_count
      # get right column objects
      get_artist_objects_for_right_column(@artist)
      render :template =>"/user_posts/replies_post" and return
    elsif @user.is_venue?
      @venue                     = @user
      @posts                     = @venue.replies_post(params[:page])
      @posts_order_by_dates      = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      next_page                  = @posts.next_page
      @load_more_path            =  next_page ? more_posts_path(next_page, :type => 'replies') : nil
      messages_and_posts_count
      # get right column objects
      get_venue_objects_for_right_column(@venue)
      render :template =>"/user_posts/replies_post" and return
    end
  end

  def more_bulletins
    if request.xhr?
      begin
        if params[:artist_name].present?
          @artist                     = Artist.where(:mention_name => params[:artist_name]).first
          @bulletins                  = @artist.bulletins(params[:page])
          bulletin_next_page          = @bulletins.next_page
          @load_more_bulletins_path   = bulletin_next_page ? artist_more_bulletins_path(@artist, bulletin_next_page) : nil
        elsif params[:venue_name].present?
          @venue                      = Venue.where(:mention_name => params[:venue_name]).first
          @bulletins                  = @venue.bulletins(params[:page])
          bulletin_next_page          = @bulletins.next_page
          @load_more_bulletins_path   = bulletin_next_page ? venue_more_bulletins_path(@venue, bulletin_next_page) : nil
        end
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
        @posts              = []
        if params[:artist_name].present?
          @artist           = Artist.where(:mention_name => params[:artist_name]).first
          if params[:type] && params[:type] == 'general'
            @posts          = @artist.find_own_posts(params[:page])
            next_page       = @posts.next_page
            @load_more_path =  next_page ? artist_more_posts_path(@artist, params[:type], next_page) : nil
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
            @load_more_path =  next_page ? artist_more_posts_path(@artist, params[:type], next_page) : nil
          else
            render :nothing => true and return
          end
        elsif params[:venue_name].present?
          @venue           = Venue.where(:mention_name => params[:venue_name]).first
          if params[:type] && params[:type] == 'general'
            @posts          = @venue.find_own_posts(params[:page])
            next_page       = @posts.next_page
            @load_more_path =  next_page ? venue_more_posts_path(@venue, params[:type], next_page) : nil
          elsif params[:type] && current_user.is_admin_of_venue?(@venue)
            if params[:type] == 'replies'
              @posts = @venue.replies_post(params[:page])
            elsif params[:type] == 'mentions'
              @posts = @venue.mentioned_in_posts(params[:page])
            else
              @posts    = @venue.find_own_as_well_as_mentioned_posts(params[:page])
            end
            @is_admin_of_venue = true
            next_page   = @posts.next_page
            @load_more_path =  next_page ? venue_more_posts_path(@venue, params[:type], next_page) : nil
          else
            render :nothing => true and return
          end
        end
        @posts_order_by_dates = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      rescue =>exp
        logger.error "Error in UserPosts::MorePosts :=>#{exp.message}"
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
        puts "#{exp.message}"
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
        actor                   = @actor
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