class ArtistPublicController < ApplicationController
  before_filter :require_login, :except =>[:index]
  before_filter :check_and_set_admin_access, :only =>[:members]
  
  def index    
    begin
      @artist                       = Artist.where(:mention_name => params[:artist_name]).includes(:artist_members).first
      @artist_members_count         = @artist.artist_members.count
      get_artist_bulletins_and_posts(@artist)
      get_artist_objects_for_right_column(@artist)
      # for public profile
      @is_public                    = true
      @has_link_access              = false
    rescue  => exp
      logger.error "Error in ArtistPublic#Index :=> #{exp.message}"
      render :template =>'/bricks/page_missing' and return
    end
    if current_user
      respond_to do |format|
        format.js
        format.html
      end
    else
      @song_items                   = @artist.songs.processed.limit(5)      
      render :template =>'/artist_public/publicprofile', :layout =>false
    end
  end
  
  def members    
    begin      
      @artist_members               = @artist.artist_members
      get_artist_objects_for_right_column(@artist)
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

  def store
    if request.xhr?
      @artist       = Artist.where(:mention_name => params[:artist_name]).includes(:artist_members).first
    else
      redirect_to root_url and return
    end
  end

  def send_message
    if request.xhr?
      begin
        @actor            = current_actor
        to_artist         = Artist.find(params[:id])
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
        @artist   = Artist.find(params[:id])
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
      if params[:artist_name] == 'home'
        @artist           = @actor
        @has_admin_access = @artist == @actor
        @has_link_access  = @has_admin_access        
      else        
        @artist           = Artist.where(:mention_name => params[:artist_name]).includes(:artist_members).first
        @is_public        = true
        @has_link_access  = false
      end
    rescue
      @artist             = nil
    end
    unless @artist
      render :template =>"bricks/page_missing" and return
    end
  end
  
end
