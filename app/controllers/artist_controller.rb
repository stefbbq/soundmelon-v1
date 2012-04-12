class ArtistController < ApplicationController
  before_filter :require_login
  
  def index
    begin
      @band = Band.where(:name => params[:band_name]).includes(:band_members).first
      if @is_admin_of_band = current_user.is_admin_of_band?(@band)
         @band_members_count = @band.band_members.count
         @other_bands = current_user.admin_bands_except(@band)
         @posts = @band.find_own_as_well_as_mentioned_posts(params[:page])
         @bulletins = @band.bulletins
         @posts_order_by_dates = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
         bulletin_next_page = @bulletins.next_page
         @load_more_bulletins_path  = bulletin_next_page ? band_more_bulletins_path(:band_name => @band.name, :page => bulletin_next_page) : nil 
         next_page = @posts.next_page
         @load_more_path =  next_page ? band_more_posts_path(:band_name => @band.name, :page => next_page, :type => 'latest') : nil
         @unread_mentioned_count = @band.unread_mentioned_post_count
         @unread_post_replies_count = @band.unread_post_replies_count
         @unread_messages_count = @band.received_messages.unread.count 
        unless request.xhr?
           @song_albums = @band.limited_song_albums
           @photo_albums = @band.limited_band_albums
           @band_artists = @band.limited_band_members
           @band_fans_count = @band.followers_count
           @band_fans = @band.limited_band_follower  
         end
      else
        logger.error "#User with username:{current_user.get_full_name} and user id #{current_user.id} tried to adminster band with band id: #{@band.id} which he is not a admin" 
        redirect_to fan_home_url, :notice => 'Your action has been reported to admin' and return
      end
    rescue
      redirect_to fan_home_url, :notice => 'Something went wrong! Try Again' and return
    end
  end
  
  def new
    @band = Band.new
  end
  
  def pull
    if request.xhr?
      @bands = current_user.bands.includes(:song_albums, :songs)
    else
      redirect_to root_url and return
    end
  end
  
  def create
    @band = current_user.bands.build(params[:band])
    band_user = current_user.band_users.new

    if @band.save
      band_user.band_id = @band.id
      band_user.access_level = 1
      band_user.save
      @bands = current_user.bands
      render :action => 'index', :format => 'js' and return
    else
      render :action => 'new' and return
    end
  end
  
  def edit
    if request.xhr?
      begin
        @band = Band.where(:name => params[:band_name]).first
        if current_user.is_admin_of_band?(@band)
           respond_to do |format|
             format.js
           end
        else
          logger.error "#User with username:{current_user.get_full_name} and user id #{current_user.id} tried to edit band with band id: #{@band.id} which he is not a admin" 
          render :nothing => true and return
        end
      rescue
        render :nothing => true and return
      end
    else
      redirect_to fan_home_url, :notice => 'Something went wrong! Try Again' and return
    end    
  end
  
  def update
    @band = Band.find(params[:id])
    if current_user.is_admin_of_band?(@band)
      if @band.update_attributes(params[:band])
      respond_to do |format|
        format.js
      end
      else
        respond_to do |format|
          format.js {render :action => 'edit' and return}
        end
      end
    else
      logger.error "#User with username:{current_user.get_full_name} and user id #{current_user.id} tried to update band with band id: #{@band.id} which he is not a admin" 
      render :nothing => true and return
    end    
  end
  
  def show
    @band = Band.where(:name => params[:band_name]).includes(:band_members).first
    @band_members_count = @band.band_members.count
    @is_admin_of_band = current_user.is_admin_of_band?(@band)
  end
  
  def social
    @band = Band.where(:name => params[:band_name]).includes(:band_members).first
    @is_admin_of_band = current_user.is_admin_of_band?(@band)
    @band_members_count = @band.band_members.count
    @is_admin_of_band = current_user.is_admin_of_band?(@band)
    @posts = @band.find_own_posts(params[:page])
    @posts_order_by_dates = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}    
    
    @bulletins = @band.bulletins
    bulletin_next_page = @bulletins.next_page
    @load_more_bulletins_path  = bulletin_next_page ? band_more_bulletins_path(:band_name => @band.name, :page => bulletin_next_page) : nil 
    next_page = @posts.next_page
    @load_more_path =  next_page ? band_more_posts_path(:band_name => @band.name, :page => next_page, :type => 'general') : nil
    
    @song_albums = @band.limited_song_albums
    @photo_albums = @band.limited_band_albums
    @band_artists = @band.limited_band_members
    @band_fans_count = @band.followers_count
    @band_fans = @band.limited_band_follower
  end
  
  def store
    if request.xhr?
      @band = Band.where(:name => params[:band_name]).includes(:band_members).first
      
    else
      redirect_to root_url and return
    end
  end
  
  def members
    if request.xhr?
      begin
        @band = Band.where(:name => params[:band_name]).includes(:band_members).first
        @band_members = @band.band_members
        respond_to do |format|
          format.js
        end
      rescue
        render :nothing => true and return
      end
    else
      redirect_to show_band_url(:band_name => params[:band_name]) and return
    end
  end
  
  def invite_bandmates
    redirect_to show_band_url(:band_name => params[:band_name]) and return unless request.xhr?
    begin
      @band = Band.where(:name => params[:band_name]).first
      if current_user.is_admin_of_band?(@band)
        5.times { @band.band_invitations.new}
      else
        logger.error "#User with username:{current_user.get_full_name} and user id #{current_user.id} tried to invite bandmate for a band with band id: #{@band.id} which he is not a admin" 
        redirect_to fan_home_url, :notice => 'Your action has been reported to admin' and return
      end
    rescue
      redirect_to fan_home_url, :notice => 'Something went wrong! Try Again' and return
    end
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def send_bandmates_invitation
    
    begin
      @band = Band.where(:name => params[:band_name]).first
      if current_user.is_admin_of_band?(@band)
        params['band']['band_invitations_attributes'].each do |key, value|
          value['user_id'] = current_user.id unless value.has_key?('id') 
        end
        if @band.update_attributes(params[:band])
          @msg = 'Invitation Send Successfully'
        end 
      else
        logger.error "#User with username:{current_user.get_full_name} and user id #{current_user.id} tried to send invitation for bandmates to join a band with band id: #{@band.id} which he is not a admin" 
        redirect_to fan_home_url, :notice => 'Your action has been reported to admin' and return
      end
    rescue
      redirect_to fan_home_url, :notice => 'Something went wrong! Try Again' and return
    end
  end
  respond_to do |format|
    format.js {render :action => 'invite_bandmates' and return}
  end
  
  def follow_band
    if request.xhr? 
      begin
        @band = Band.where(:name => params[:band_name]).first
        current_user.follow(@band)  unless current_user.following?(@band)
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
        @band = Band.where(:name => params[:band_name]).first
        current_user.stop_following(@band)  if current_user.following?(@band)
      rescue
        render :nothing => true and return
      end
    else
      redirect_to show_band_url(:band_name => params[:band_name]) and return
    end
  end
  
  def send_message
    if request.xhr?
      begin
        to_band = Band.find(params[:id])
        if current_user.send_message(to_band, :body => params[:body])
        else
          # though body is empty, let the bogus user feel msg is sent   
        end
      rescue
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end
  end
  
  def new_message
    if request.xhr?
      begin
        @band = Band.find(params[:id]) 
        @message = ActsAsMessageable::Message.new
      rescue
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end
  end
  
  def more_bulletins
    if request.xhr?
      begin
        @band = Band.where(:name => params[:band_name]).first
        @bulletins = @band.bulletins(params[:page])
        bulletin_next_page = @bulletins.next_page
        @load_more_bulletins_path  = bulletin_next_page ? band_more_bulletins_path(:band_name => @band.name, :page => bulletin_next_page) : nil 
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
          @posts = @band.find_own_posts(params[:page])
          next_page = @posts.next_page
          @load_more_path =  next_page ? band_more_posts_path(:band_name => @band.name, :page => next_page) : nil
        elsif params[:type] && current_user.is_admin_of_band?(@band)
           if params[:type] == 'replies'
             @posts = @band.replies_post(params[:page])  
           elsif params[:type] == 'mentions'
             @posts = @band.mentioned_in_posts(params[:page])
           else  
             @posts = @band.find_own_as_well_as_mentioned_posts(params[:page])
           end 
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
  
  def mentions_post
    if request.xhr?
      begin
        @band = Band.where(:name => params[:band_name]).includes(:band_members).first
        if current_user.is_admin_of_band?(@band)
         @posts = @band.mentioned_in_posts(params[:page])
         @posts_order_by_dates = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
         next_page = @posts.next_page
         @load_more_path =  next_page ? band_more_posts_path(:band_name => @band.name, :page => next_page, :type => 'mentions') : nil
         @unread_mentioned_count = @band.unread_mentioned_post_count
         @unread_post_replies_count = @band.unread_post_replies_count
         @unread_messages_count = @band.received_messages.unread.count
        else
          render :nothing => true and return
        end
      rescue
        render :nothing => true and return
      end
    else
      redirect_to fan_home_url, :notice => 'Something went wrong! Try Again' and return
    end
  end
  
  def replies_post
    if request.xhr?
      begin
        @band = Band.where(:name => params[:band_name]).includes(:band_members).first
        if current_user.is_admin_of_band?(@band)
         @posts = @band.replies_post(params[:page])
         @posts_order_by_dates = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
         next_page = @posts.next_page
         @load_more_path =  next_page ? band_more_posts_path(:band_name => @band.name, :page => next_page, :type => 'replies') : nil
         @unread_mentioned_count = @band.unread_mentioned_post_count
         @unread_post_replies_count = @band.unread_post_replies_count
         @unread_messages_count = @band.received_messages.unread.count
        else
          render :nothing => true and return
        end
      rescue
        render :nothing => true and return
      end
    else
      redirect_to fan_home_url, :notice => 'Something went wrong! Try Again' and return
    end    
  end
  
  def fans
    if request.xhr?
      band = Band.where(:name => params[:band_name]).first
      @band_fans = band.user_followers
    else
      redirect_to show_band_url(:band_name => params[:band_name])
    end
  end
  
end