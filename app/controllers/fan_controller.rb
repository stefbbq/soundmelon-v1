class FanController < ApplicationController
  before_filter :require_login, :except => [:signup, :musician_new, :activate, :new]
  before_filter :logged_in_user, :only  => [:musician_new, :activate]

  def index    
    @user                       = current_user
    logger.debug ">>> CURRENT ID: #{@user}"
    @posts                      = current_user.find_own_as_well_as_following_user_posts(params[:page])
    @posts_order_by_dates       = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
    next_page                   = @posts.next_page
    @load_more_path             =  next_page ? more_post_path(:page => next_page) : nil
    @unread_mentioned_count     = current_user.unread_mentioned_post_count
    @unread_post_replies_count  = current_user.unread_post_replies_count
    @unread_messages_count      = current_user.received_messages.unread.count
    @song_items                 = current_user.find_radio_feature_playlist_songs
    get_user_associated_objects
  end

  def signup
    if current_user
      redirect_to fan_home_path
    else
      if request.post?
        @user                     = User.new(params[:user])
        @user.account_type        = 0
        #      if verify_recaptcha(:model => @user, :message => "Captha do not match") && @user.save
        if @user.save
          band_name               = params[:band_name]
          @band                   = Band.find_by_name(band_name)
          unless @band
            band_user             = @user.band_users.new
            @band                 = Band.create(:name =>band_name)
            band_user.band_id     = @band.id
            band_user.access_level= 1
            band_user.save
          end
          @page_type              = 'Fan'
          render 'signup_success' and return
          #redirect_to successful_fan_signup_url, :notice => "Signed up successfully! "
        else
          render :template =>'/fan/splash'
        end
      else
        @user       = User.new(:invitation_token => params[:invitation_token])
        if @user.invitation
          @user.email               = @user.invitation.recipient_email
          @user.email_confirmation  = @user.invitation.recipient_email
          @is_invited               = true
        end
      end
    end
    
  end

  def musician_new 
    @error_msg = Array.new
    if request.post?      
      @user = User.new(params[:user])
      @user.account_type = 1
      if !params[:band_name] || !params[:genre]
        redirect_to root_url and return
      else  
        if params[:band_name].blank? || params[:genre].blank?
          @errors = true
          @error_msg << "Band Name cannot be blank" if params[:band_name].blank?
          @error_msg << "Genre cannot be blank" if params[:genre].blank?
        end
      end
      
      if verify_recaptcha(:model => @user, :message => "Captha do not match") && @user.valid? && !@errors
        begin
          band                = Band.new
          band_user           = BandUser.new
          BandUser.transaction do
            band.name         = params[:band_name].strip
            band.mention_name = params[:band_mention_name].strip
            band.genre        = params[:genre].strip
            unless band.valid?
              band.errors.messages.each do |key, value|
                @error_msg << key + ' ' + value
              end
              raise
            end
            @user.save!
            band.save!
            band_user.user_id = @user.id
            band_user.band_id = band.id
            band_user.access_level = 1
            band_user.save!
            @page_type = 'Musician'
            render 'successful_signup_info' and return
          end
        rescue
          render :musician_new
        end
        #redirect_to successful_musician_signup_url, :notice => "Signed up successfully!"
	    else
        render :musician_new
      end    
    else
      @user = User.new
    end
  end
    
  def activate
    if @user = User.load_from_activation_token(params[:id])
      session[:user_id]     = @user.id if @user.activate!
      @confirmation_thanks  = true
      @additional_info      = @user.additional_info
      @payment_info         = @user.payment_info
      if @user.account_type
        @page_type = 'Musician'
      else
        @page_type = 'Fan'
      end
      render 'fan_public/additional_info' and return
      #redirect_to root_url, :notice => 'User was successfully activated.'
    else
      redirect_to root_url, :notice => 'Unable to activate your account. Try Again!'
    end
  end

  def additional_info
    @user = current_user
    @additional_info = @user.additional_info
    @payment_info = @user.payment_info
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
      @band = current_user.bands.first
      @band.update_attributes(params[:band])
      redirect_to fan_home_url and return
    else
      @band = Band.new
      @band_invitations = @band.band_invitations.build
    end
  end

  def activate_invitation
    unless params[:id].blank?
      band_invitation = BandInvitation.find_by_token(params[:id])
      if band_invitation
        band_user = BandUser.new(:band_id => band_invitation.band_id,
          :user_id => current_user.id,
          :access_level => band_invitation.access_level
        )
        band_user.save
        band_invitation.update_attribute(:token, nil)
        redirect_to fan_home_url, :notice => "You have successfully joined the band." and return
      else
        redirect_to fan_home_url ,:error => "Invitation token has been already used or token missmatch" and return
      end
    else
      redirect_to fan_home_url ,:error => "Undefined invitation token" and return
    end
  end

  # renders the form for updating the current user's details
  def manage_profile
    begin
      @user             = current_user
      @additional_info  = current_user.additional_info
      get_user_associated_objects
      respond_to do |format|
        format.js and return
        format.html and return
      end
    rescue =>exp
      logger.error "Error in Fan#ManageProfile :=> #{exp.message}"
      render :nothing => true and return
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
        if params[:old_password].blank?
          @msg = 'old password isn\'t correct'
        elsif params[:user][:password].blank? || params[:user][:password_confirmation].blank?
          @msg = 'new password can\'t be blank'
        elsif params[:user][:password] != params[:user][:password_confirmation]
          @msg = 'new password doesn\'t match'
        elsif !login(current_user.email, params[:old_password])
          @msg = 'old password isn\'t correct'
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
  
end