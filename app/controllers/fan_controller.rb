class FanController < ApplicationController
  before_filter :require_login, :except => [:fan_new, :musician_new, :activate, :new]
  before_filter :logged_in_user, :only => ['musician_new', :activate]  

  def index
    @user = current_user 
    logger.debug ">>> CURRENT ID: #{@user}"
    @posts = current_user.find_own_as_well_as_following_user_posts(params[:page])
    @posts_order_by_dates = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}    
    next_page = @posts.next_page
    @load_more_path =  next_page ? more_post_path(:page => next_page) : nil
    @unread_mentioned_count = current_user.unread_mentioned_post_count
    @unread_post_replies_count = current_user.unread_post_replies_count
    @unread_messages_count = current_user.received_messages.unread.count
    @song_items = current_user.find_radio_feature_playlist_songs
    unless request.xhr?
      get_user_associated_objects  
    end
  end

  def fan_new
    if request.post?  
      @user               = User.new(params[:user])
      @user.account_type  = 0
      if verify_recaptcha(:model => @user, :message => "Captha do not match") && @user.save
        @page_type        = 'Fan'
        render 'successful_signup_info' and return
        #redirect_to successful_fan_signup_url, :notice => "Signed up successfully! "
      else
        render :fan_new
      end
    else
      @user = User.new
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
          band = Band.new  
          band_user = BandUser.new
          BandUser.transaction do
            band.name = params[:band_name].strip
            band.mention_name = params[:band_mention_name].strip
            band.genre = params[:genre].strip
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
      session[:user_id] = @user.id if @user.activate!
      @confirmation_thanks = true
      @additional_info = @user.additional_info
      @payment_info = @user.payment_info
      if @user.account_type
        @page_type = 'Musician'
      else
        @page_type = 'Fan'
      end
      render 'profile/additional_info' and return
      #redirect_to root_url, :notice => 'User was successfully activated.'
    else
      redirect_to root_url, :notice => 'Unable to activate your account. Try Again!'
    end
  end
  
end