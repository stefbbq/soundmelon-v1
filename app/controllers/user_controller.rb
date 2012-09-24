class UserController < ApplicationController
  before_filter :require_login

  def index
    begin
      home_actor                    = current_actor
      @song_items                   = current_user.find_radio_feature_playlist_songs unless request.xhr?
      messages_and_posts_count
      @is_homepage                  = true
      if home_actor.is_fan?
        @user                       = home_actor
        @is_fan                     = true
        #----------Get Objects------------------------------------------------------------
        get_current_fan_posts          
        get_user_associated_objects
        render :template =>"/fan/index" and return
        #----------------------------------------------------------------------------------
      elsif home_actor.is_artist?
        @artist                     = home_actor
        @is_artist                  = true
        @from_home                  = true        
        @has_link_access            = true
        get_artist_associated_objects(@artist)
        render "/artist/index" and return
        #---------------------------------------------------------------------------------
      elsif home_actor.is_venue?
        @venue                      = home_actor
        @is_venue                   = true
        @from_home                  = true
        @has_link_access            = true
        get_venue_objects_for_right_column(@venue)
        render "/venue/index" and return
      end            
    rescue =>exp
      logger.error "Error in User#Index => #{exp.message}"
      render :nothing =>true and return
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  def change_login
    if request.xhr?
      begin
        @is_homepage                  = true
        if params[:artist_name].present?
          @artist                     = Artist.where(:mention_name =>params[:artist_name]).first
          @from_home                  = true
          set_current_useritem(@artist)
          @actor                      = current_actor          
          @is_artist                  = true
          @has_link_access            = true
          @first_login                = current_user.last_artist_login_at.blank?
          current_user.update_attribute(:last_artist_login_at , Time.now)
          get_artist_mentioned_posts(@artist)
          #----------Get Objects------------------------------------------------------------
          get_artist_associated_objects(@artist)
          #---------------------------------------------------------------------------------
        elsif params[:venue_name].present?
          @venue                      = Venue.where(:mention_name =>params[:venue_name]).first
          @from_home                  = true
          set_current_useritem(@venue)
          @actor                      = current_actor          
          @is_venue                   = true
          @has_link_access            = true          
          messages_and_posts_count
#          get_artist_mentioned_posts(@artist)
          #----------Get Objects------------------------------------------------------------
          get_venue_objects_for_right_column(@venue)
          #---------------------------------------------------------------------------------
        else
          @user                       = current_user
          reset_current_useritem
          @is_fan                     = true
          #----------Get Objects------------------------------------------------------------
          get_current_fan_posts
          messages_and_posts_count
          get_user_associated_objects
          #----------------------------------------------------------------------------------
        end
      rescue =>exp
        logger.error "Error in User#ChangeLogin => #{exp.message}"
        render :nothing =>true and return
      end
    else
      redirect_to user_home_path and return
    end
  end

  # renders the form for updating the current actor(fan/artist/venue) profile details
  def manage_profile
    begin
      @has_link_access             = true
      if @actor.is_fan?    # in case of fan profile login
        @user                     = @actor
        @additional_info          = current_user.additional_info
        get_user_associated_objects
        render :template =>"/fan/manage_profile" and return
      elsif @actor.is_artist?                # in case of artist profile login
        @user                     = current_user
        @artist                   = @actor
        @artist_user              = ArtistUser.for_user_and_artist(current_user, @artist).first || ArtistUser.new
        get_artist_objects_for_right_column(@artist)
        render :template =>"/artist/edit" and return
      elsif @actor.is_venue?                 # in case of venue profile login
        @user                     = current_user
        @venue                    = @actor
        @venue_user               = VenueUser.for_user_and_venue(current_user, @venue).first || VenueUser.new
        get_venue_objects_for_right_column(@venue)
        render :template =>"/venue/edit" and return
      end
    rescue =>exp
      logger.error "Error in User#ManageProfile :=> #{exp.message}"
      render :nothing => true and return
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  # remove the profile
  # logs out the user and returns to home page
  def remove_user_profile
#    redirect_to user_home_url and return unless request.xhr?
    @actor               = current_actor    
    if @actor.is_fan?
      @is_fan            = true
      logout
      @actor.remove_me
      respond_to do |format|
        format.html{ redirect_to root_url, :alert =>"Your profile for '#{@actor.get_name}' has been removed." and return}
        format.js{ redirect_to root_url, :alert =>"Your profile for '#{@actor.get_name}' has been removed." and return}
      end      
    else
      reset_current_useritem
      get_current_fan_posts
      messages_and_posts_count
      @song_items                 = current_user.find_radio_feature_playlist_songs
      get_user_associated_objects
      @actor.remove_me    
    end   
  end

  # renders the current fan's artist profiles
  def pull_profiles
    @user                 = current_user
    @accessible_artists   = @user.artists.includes(:artist_musics, :songs)
    @accessible_venues    = @user.venues
    get_fan_objects_for_right_column(@user)
    respond_to do |format|
      format.js
      format.html
    end
  end
  
  def check_user_validity
    unless params[:user].blank?
      @user         = User.authenticate(current_user.email, params[:user][:password])
      @tested       = true
    else
      @user         = nil
      @tested       = false
    end       
  end

  def feedback_page
    redirect_to root_path and return unless request.xhr?
    @feedback  = Feedback.new
  end

  def give_feedback    
    begin
      actor           = current_actor
      feedback_params = params[:feedback]
      if feedback_params
        feedback_params.update({:user_type =>actor.class.name, :user_id =>actor.id})
      end
      @feedback       = Feedback.new(feedback_params)
      @status         = @feedback.save
      @feedback       = Feedback.new if @status
      unless @status
        render :action =>'feedback_page'
      end
    rescue =>exp
      logger.error "Error in User::GiveFeedback :=> #{exp.message}"
    end
  end 

end