class VenuePublicController < ApplicationController
  before_filter :require_login#, :except =>[:index]
  before_filter :check_and_set_admin_access

  def index
    begin
      @venue                       = Venue.where(:mention_name => params[:venue_name]).first
      get_venue_bulletins_and_posts(@venue)
      get_venue_objects_for_right_column(@venue)
      # for public profile
      @is_public                    = true
      @has_link_access              = false
    rescue  => exp
      logger.error "Error in ArtistPublic#Index :=> #{exp.message}"
      render :template =>'/bricks/page_missing' and return
    end    
    respond_to do |format|
      format.js
      format.html
    end    
  end
  
  def send_message
    if request.xhr?
      begin
        to_artist         = Venue.find(params[:id])
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
        @venue    = Venue.find(params[:id])
        @message  = ActsAsMessageable::Message.new
      rescue
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end
  end

  protected

  def check_and_set_admin_access
    begin
      if params[:venue_name] == 'home'
        @venue            = @actor
        @has_admin_access = @venue == @actor
        @has_link_access  = @has_admin_access
      else
        @venue            = Venue.where(:mention_name => params[:venue_name])
        @is_public        = true
        @has_link_access  = false
      end
    rescue
      @venue             = nil
    end
    unless @venue
      render :template =>"bricks/page_missing" and return
    end
  end 

end
