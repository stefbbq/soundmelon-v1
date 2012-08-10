class FanController < ApplicationController
  before_filter :require_login, :except => [:signup, :musician_new, :activate, :new, :signup_success]
  before_filter :logged_in_user, :only  => [:activate]

  def index    
    @user                       = current_user    
    @posts                      = current_user.find_own_as_well_as_following_user_posts(params[:page])
    @posts_order_by_dates       = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
    next_page                   = @posts.next_page
    @load_more_path             =  next_page ? more_post_path(:page => next_page) : nil
    @unread_mentioned_count     = current_user.unread_mentioned_post_count
    @unread_post_replies_count  = current_user.unread_post_replies_count
    @unread_messages_count      = current_user.received_messages.unread.count
    @song_items                 = current_user.find_radio_feature_playlist_songs
    get_user_associated_objects
    respond_to do |format|
      format.js
      format.html
    end
  end

  def signup
    if current_user
      redirect_to fan_home_path
    else
      if request.post?
        successful_signup             = false
        @artist                       = Artist.new(params[:artist])
        if(params[:artist][:name].blank? && params[:artist][:mention_name].blank?)
          @is_artist_data_valid       = true          
        else          
          @is_artist_data_valid       = @artist.valid?
        end        
        @user                         = User.new(params[:user])
        if @is_artist_data_valid
          if @user.save
            @artist.save
            artist_user               = @user.artist_users.new
            artist_user.artist_id       = @artist.id
            artist_user.access_level  = 1
            artist_user.save
            successful_signup       = true
          end          
        end        
        if successful_signup          
          render :action =>'signup_success' and return          
        end
      else
        @user                       = User.new(:invitation_token => params[:invitation_token])
        if @user.invitation
          @user.email               = @user.invitation.recipient_email
          @user.email_confirmation  = @user.invitation.recipient_email
          @is_invited               = true
        end
        @artist                       = Artist.new
        @is_artist_data_valid         = true
      end
    end    
  end
  
  def activate
    if @user = User.load_from_activation_token(params[:id])
      if @user.activate!
        session[:user_id]     = @user.id
        @user.deliver_pending_invitations
      end      
      messages_and_posts_count
      @confirmation_thanks  = true
      @additional_info      = @user.additional_info
      @payment_info         = @user.payment_info
      @firstLogin           = true
      #      render 'fan/additional_info' and return
      redirect_to root_url, :notice => 'User was successfully activated.'      
    else
      redirect_to root_url, :notice => 'Unable to activate your account. Try Again!'
    end
  end

  def additional_info
    @user             = current_user
    @additional_info  = @user.additional_info
    @payment_info     = @user.payment_info
    #redirect_to fan_home_url and return if !@additional_info.nil? || !@payment_info.nil?
  end

  def add_additional_info
    if request.xhr?
      #redirect_to root_url and return unless current_user.additional_info.nil?
      if current_user.additional_info.nil?
        @additional_info = current_user.build_additional_info(params[:additional_info])
        @additional_info.save
      else
        @additional_info_update = true
        @additional_info = current_user.additional_info
        @additional_info.update_attributes(params[:additional_info])
      end
      respond_to do |format|
        format.js
      end
    else
      redirect_to root_url and return
    end
  end

  def add_payment_info
    if request.xhr?
      if current_user.payment_info.nil?
        @payment_info = current_user.build_payment_info(params[:payment_info])
        @payment_info.save
      else
        @payment_info = current_user.payment_info
        @payment_info.update_attributes(params[:payment_info])
        @payment_info_update = true
      end
      respond_to do |format|
        format.js
      end
    else
      redirect_to root_url and return
    end
  end

  def invite_bandmates
    redirect_to root_url and return unless current_user.account_type
    if request.post?
      @artist             = current_user.artists.first
      @artist.update_attributes(params[:artist])
      redirect_to fan_home_url and return
    else
      @artist             = Artist.new
      @artist_invitations = @artist.artist_invitations.build
    end
  end

  def activate_invitation
    unless params[:id].blank?
      artist_invitation = ArtistInvitation.find_by_token(params[:id])
      if artist_invitation
        artist_user = ArtistUser.find_or_create_by_artist_id_and_user_id(artist_invitation.artist_id, current_user.id)          
        artist_user.update_attribute(:access_level, artist_invitation.access_level)
        artist_invitation.update_attribute(:token, nil)
        redirect_to show_artist_url(artist_user.artist.name), :notice => "You have successfully joined the artist." and return
      else
        redirect_to fan_home_url ,:error => "Invitation token has been already used or token missmatch" and return
      end
    else
      redirect_to fan_home_url ,:error => "Undefined invitation token" and return
    end
  end

  def update_basic_info
    if request.xhr?
      begin
        if params[:user][:fname].blank? || params[:user][:fname].blank?
          @msg = 'first and last names cannot be blank'
        else
          current_user.fname = params[:user][:fname]
          current_user.lname = params[:user][:lname]
          if current_user.save
            @msg = 'info updated successfully'
          else
            @msg = 'something went wrong, try again'
          end
        end
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

  def update_password
    if request.xhr?
      begin
        if params[:user][:password_confirmation].blank?
          @msg = 'new password can\'t be blank'
        elsif params[:user][:password] != params[:user][:password_confirmation]
          @msg = 'new password doesn\'t match'        
        else
          if current_user.change_password!(params[:user][:password])
            @msg = 'password updated'
          else
            @msg = 'something went wrong, try again'
          end
        end
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

  def update_payment_info
    if request.xhr?
      @payment_info = current_user.payment_info
    else
      redirect_to fan_home_url and return
    end
  end

  def update_notification_setting
    if request.xhr?
      current_user.toggle! :notification_on
      @status   = current_user.notification_on ? 'on' : 'off'
    else
      redirect_to fan_home_url and return
    end
  end

  def signup_success    
  end
  
end