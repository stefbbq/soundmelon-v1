class UserController < ApplicationController
  before_filter :require_login

  def index
    begin
      home_actor                    = current_actor
      if home_actor == current_user
        @user                       = current_user
        @is_fan                     = true
        #----------Get Objects------------------------------------------------------------
        get_current_fan_posts
        messages_and_posts_count
        @song_items                 = current_user.find_radio_feature_playlist_songs
        get_user_associated_objects
        render :template =>"/fan/index" and return
        #----------------------------------------------------------------------------------
      elsif home_actor.instance_of?(Artist)
        @artist                     = home_actor
        @is_artist                  = true
        @from_home                  = true
        @is_home                    = true
        get_artist_associated_objects(@artist)
        render "/artist/index" and return
        #---------------------------------------------------------------------------------
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
        if params[:artist_name].blank?
          @user                       = current_user          
          reset_current_fan_artist
          @is_fan                     = true
          #----------Get Objects------------------------------------------------------------
          get_current_fan_posts
          messages_and_posts_count
          @song_items                 = @user.find_radio_feature_playlist_songs
          get_user_associated_objects
          #----------------------------------------------------------------------------------
        else          
          @artist                     = Artist.where(:mention_name =>params[:artist_name]).first
          @from_home                  = true
          set_current_fan_artist(@artist.id)
          @is_artist                  = true
          @is_home                    = true
          get_artist_mentioned_posts(@artist)
          #----------Get Objects------------------------------------------------------------
          get_artist_associated_objects(@artist)
          #---------------------------------------------------------------------------------
        end
      rescue =>exp
        logger.error "Error in User#ChangeLogin => #{exp.message}"
        render :nothing =>true and return
      end
    else
      redirect_to fan_home_path and return
    end
  end

  # renders the form for updating the current actor(fan/artist) profile details
  def manage_profile
    begin
      @actor              = current_actor
      if @actor.is_fan?    # in case of fan profile login
        @user             = @actor
        @additional_info  = current_user.additional_info
        get_user_associated_objects
        render :template =>"/fan/manage_profile" and return
      else                # in case of artist profile login
        @artist             = @actor
        @artist_user        = ArtistUser.for_user_and_artist(current_user, @artist).first || ArtistUser.new
        get_artist_objects_for_right_column(@artist)
        render :template =>"/artist/edit" and return
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
    redirect_to user_home_url and return unless request.xhr?
    @actor               = current_actor
    @is_fan              = @actor.is_fan?
    @actor.remove_me
    if @is_fan
      logout      
    else
      reset_current_fan_artist  
      get_current_fan_posts
      messages_and_posts_count
      @song_items                 = current_user.find_radio_feature_playlist_songs
      get_user_associated_objects      
    end   
  end

  # renders the current fan's artist profiles
  def pull_artist_profiles
    @user                 = current_user
    @accessible_artists   = current_user.artists.includes(:artist_musics, :songs)
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