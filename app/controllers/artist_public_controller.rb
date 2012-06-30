class ArtistPublicController < ApplicationController
  before_filter :require_login

  def members    
    begin
      @band         = Band.where(:name => params[:band_name]).includes(:band_members).first
      @band_members = @band.band_members
      get_artist_objects_for_right_column(@band)
      respond_to do |format|
        format.js
        format.html
      end
    rescue => exp
      logger.error "Error in ArtistPublic#Members :=> #{exp.message}"
      render :template =>'/bricks/page_missing' and return
      render :nothing => true and return
    end    
  end

  def social
    begin
      @band                       = Band.where(:name => params[:band_name]).includes(:band_members).first
      @is_admin_of_band           = current_user.is_admin_of_band?(@band)
      @band_members_count         = @band.band_members.count
      get_band_bulletins_and_posts(@band)
      get_artist_objects_for_right_column(@band)
    rescue  => exp
      logger.error "Error in ArtistPublic#Members :=> #{exp.message}"
      render :template =>'/bricks/page_missing' and return
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  def store
    if request.xhr?
      @band       = Band.where(:name => params[:band_name]).includes(:band_members).first
    else
      redirect_to root_url and return
    end
  end

  def send_message
    if request.xhr?
      begin
        @actor            = current_actor
        to_artist         = Band.find(params[:id])
        receipt           = @actor.send_message(to_artist, params[:body], 'subject')
        NotificationMail.message_notification to_artist, @actor, receipt.message
      rescue =>exp
        logger.error "Error in ArtistPublic::SendMessage"
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end
  end

  def new_message
    if request.xhr?
      begin
        @band     = Band.find(params[:id])
        @message  = ActsAsMessageable::Message.new
      rescue
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end
  end
  
end
