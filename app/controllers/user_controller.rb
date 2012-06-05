class UserController < ApplicationController
  before_filter :require_login

  def index
    begin
      home_actor                    = current_actor
      if home_actor == current_user
        @user                       = current_user
        @is_fan                     = true
        #----------Get Objects------------------------------------------------------------
        @posts                      = @user.find_own_as_well_as_following_user_posts(params[:page])
        @posts_order_by_dates       = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
        next_page                   = @posts.next_page
        @load_more_path             =  next_page ? more_post_path(:page => next_page) : nil
        @unread_mentioned_count     = current_user.unread_mentioned_post_count
        @unread_post_replies_count  = current_user.unread_post_replies_count
        @unread_messages_count      = current_user.received_messages.unread.count
        @song_items                 = current_user.find_radio_feature_playlist_songs
        get_user_associated_objects
        render :template =>"/fan/index" and return
        #----------------------------------------------------------------------------------
      elsif home_actor.instance_of?(Band)
        @band                       = home_actor
        @is_band                    = true
        get_band_associated_objects(@band)
        render "/artist/index" and return
        #---------------------------------------------------------------------------------
      end
    rescue =>exp
      logger.error "Error in User#Index => #{exp.message}"
      render :nothing =>true and return
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
          @posts                      = @user.find_own_as_well_as_following_user_posts(params[:page])
          @posts_order_by_dates       = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
          next_page                   = @posts.next_page
          @load_more_path             =  next_page ? more_post_path(:page => next_page) : nil
          @unread_mentioned_count     = @user.unread_mentioned_post_count
          @unread_post_replies_count  = @user.unread_post_replies_count
          @unread_messages_count      = @user.received_messages.unread.count
          @song_items                 = @user.find_radio_feature_playlist_songs
          get_user_associated_objects
          #----------------------------------------------------------------------------------
        else          
          @band                      = Band.where(:name =>params[:artist_name]).first
          set_current_fan_artist(@band.id)
          @is_artist                  = true
          #----------Get Objects------------------------------------------------------------
          get_band_associated_objects(@band)
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
      @actor               = current_actor
      if @actor.is_fan?    # in case of fan profile login
        @user             = @actor
        @additional_info  = current_user.additional_info
        get_user_associated_objects
        render :template =>"/fan/manage_profile" and return
      else                # in case of artist profile login
        @band             = @actor
        get_artist_objects_for_right_column(@band)
        render :template =>"/artist/edit" and return
      end
    rescue =>exp
      logger.error "Error in User#ManageProfile :=> #{exp.message}"
      render :nothing => true and return
    end
  end

  # renders the current fan's artist profiles
  def pull_artist_profiles
    @user     = current_user
    @artists  = current_user.bands.includes(:song_albums, :songs)
    get_fan_objects_for_right_column(@user)
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
    rescue =>exp
      logger.error "Error in User::GiveFeedback :=> #{exp.message}"
    end
  end 

end