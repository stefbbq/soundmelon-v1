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
          @unread_mentioned_count     = current_user.unread_mentioned_post_count
          @unread_post_replies_count  = current_user.unread_post_replies_count
          @unread_messages_count      = current_user.received_messages.unread.count
          @song_items                 = current_user.find_radio_feature_playlist_songs
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
end