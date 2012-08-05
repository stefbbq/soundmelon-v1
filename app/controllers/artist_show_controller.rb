class ArtistShowController < ApplicationController
  before_filter :require_login
  before_filter :check_and_set_admin_access, :only =>[:index, :new, :create, :edit, :update, :destroy_show, :artist_show]
  before_filter :instantiate_artist_show, :only =>[:edit, :destroy_show, :artist_show, :like_dislike_artist_show]

  def index
    begin
      @artist_show_list = @artist.artist_shows
      get_artist_objects_for_right_column(@artist)
    rescue =>exp
      logger.error "Error in ArtistShow#Index :=> #{exp.message}"
      render :nothing => true and return
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  def artist_show
    begin
      @status           = true
      @artist_show_list = [@artist_show]
      @show_all         = true
      get_artist_objects_for_right_column(@artist)
      render :template =>"/artist_show/index" and return
    rescue =>exp      
      logger.error "Error in ArtistShow#ArtistShow :=> #{exp.message}"
      @status = false
      render :nothing => true and return
    end
  end

  def show_detail
    @artist_show        = ArtistShow.find(params[:artist_show_id])
    unless request.xhr?
      redirect_to show_artist_path(params[:artist_name]) and return
    end
  end

  def new
    redirect_to show_artist_path(params[:artist_name]) and return unless request.xhr?
    if @has_admin_access
      @artist_show = ArtistShow.new
    else
      render :nothing => true and return
    end
  end

  def create
    begin
      if @has_admin_access
        @artist_show = @artist.artist_shows.build(params[:artist_show])
        if @artist_show.save
        else
          render :action => 'new'
        end
      else
        render :nothing => true and return
      end
    rescue =>exp
      logger.error "Error in ArtistShow#Create :=> #{exp.message}"
      render :nothing => true and return
    end
  end

  def edit
    redirect_to show_artist_path(params[:artist_name]) and return unless request.xhr?
    begin
      unless @has_admin_access
        render :noting => true and return
      end
    rescue =>exp
      logger.error "Error in ArtistShow#Edit :=> #{exp.message}"
      render :nothing => true and return
    end
  end

  def update
    redirect_to show_artist_path(params[:artist_name]) and return unless request.xhr?
    begin
      if @has_admin_access
        @artist_show = ArtistShow.find(params[:id])
        @artist_show.update_attributes(params[:artist_show])
      else
        render :noting => true and return
      end
    rescue =>exp
      logger.info {"Error in ArtistShow::Update :#{exp.message}"}
      render :nothing => true and return
    end
  end
  
  def like_dislike_artist_show
  end

  def destroy_show
    if request.xhr?
      begin
        unless @has_admin_access
          render :nothing => true and return
        end
        @status = @artist_show.destroy
      rescue
        @status = false
        render :nothing => true and return
      end
    else
      redirect_to show_artist_url(params[:artist_name]) and return
    end
  end

  private

  # finds the artist profile by artist_name parameter, and checks whether the current login is artist or fan
  # and accordingly sets the variable @has_admin_access to be used in views and other actions
  def check_and_set_admin_access
    @artist           = Artist.where(:mention_name => params[:artist_name]).first
    @actor            = current_actor
    @has_admin_access = @artist == @actor    
  end

  def instantiate_artist_show
    begin
      @artist_show      = ArtistShow.find(params[:artist_show_id])
    rescue
      @artist_show        = nil
    end
    unless @artist_show
      render :template =>'/bricks/page_missing' and return
    end
  end
  
end
