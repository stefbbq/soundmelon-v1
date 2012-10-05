class ArtistPhotoController < ApplicationController
  before_filter :require_login
  before_filter :check_and_set_admin_access 
  
  def index
    begin      
      @artist_album_list  = @has_admin_access ? @artist.albums.includes('photos') : @artist.albums.published.includes('photos')
      get_artist_objects_for_right_column(@artist, @has_admin_access)
    rescue =>exp
      logger.error "Error in ArtistPhoto::Index :=> #{exp.message}"
      render :nothing => true and return
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  def artist_album
    begin
      @artist_album       = @artist.albums.where(:id =>params[:album_id]).includes('photos').first
      @status             = true
      @artist_album_list  = [@artist_album]
      @show_all           = true
      get_artist_objects_for_right_column(@artist, @has_admin_access)
      render :template =>"/artist_photo/index" and return
    rescue =>exp
      logger.error "Error in ArtistPhoto#ArtistAlbum :=> #{exp.message}"
      @status           = false
      render :nothing   => true and return
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  def show
    redirect_to show_artist_path(params[:artist_name]) and return unless request.xhr?    
    begin
      @artist_album     = @artist.albums.where(:id => params[:album_id]).first
      @photo            = Photo.find(params[:id])
    rescue =>exp
      logger.error "Error in ArtistPhoto::Show :#{exp.message}"
      render :nothing => true and return
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  def new
    redirect_to show_artist_path(params[:artist_name]) and return unless request.xhr?    
    if @has_admin_access
      @post_url          = '/artist_photo/create'
      @artist_photo      = Photo.new
      @artist_album      = Album.new
    else      
      render :nothing => true and return
    end
  end

  def create
    begin
      if @has_admin_access
        @has_link_access = true
        newparams = coerce(params)
        if params[:album_name].blank?
          params[:album_name] = @artist.name + Time.now.strftime("%Y-%m-%d")
        end
        @artist_album         = @artist.albums.where(:name => params[:album_name]).first
        unless @artist_album
          @artist_album       = @artist.albums.build(:name=>params[:album_name], :user_id => current_user.id)
          @artist_album.save
          # delay to avoid the same created_at timestamp for both song album and songs
          sleep 1
        end
        @artist_photo         = @artist_album.photos.build(newparams[:artist_photo])
        @artist_photo.user_id = current_user.id
        if @artist_photo.save
          @artist_album.save
          flash[:notice]    = "Successfully created upload."          
          respond_to do |format|
            format.html {redirect_to user_home_url and return}
            format.json {render :json =>
                {
                :result         => 'success',
                :album_id       => @artist_album.id,
                :photo_count_str=> @artist_album.photos.size,
                :upload         => @artist_photo.image.url(:thumb),
                :album_name     => @artist_album.name,
                :image_string   => 'assets/profile/artist-defaults-avatar.jpg',
                :image_src      => (cover_image = @artist_album.cover_image) ? cover_image.image.url(:thumb) : '/assets/no-image.png',
                :add_url        => "#{add_photos_to_album_path('home', @artist_album.id)}",
                :album_url      => "#{artist_album_path('home', @artist_album.id)}",
                :delete_url     => "#{delete_album_path('home', @artist_album.id)}",
                :album_photos_url=>"#{artist_album_photos_path('home', @artist_album.id)}",
                :album_string   => "#{render_to_string('/artist_photo/_album', :layout =>false, :locals =>{:artist_album =>@artist_album, :has_admin_access=>true})}",
                :photo_string   => "#{render_to_string('/artist_photo/_photo', :layout =>false, :locals =>{:artist_album =>@artist_album, :photo =>@artist_photo})}"
              }
            }
          end
        else
          render :action => 'new'
        end
      else        
        render :nothing => true and return
      end
    rescue =>exp
      logger.error "Error in ArtistPhotos::Create :=>#{exp.message}"
      render :nothing => true and return
    end
  end

  def artist_album_photos
    redirect_to show_artist_path(params[:artist_name]) and return unless request.xhr?
    begin
      @artist_album       = @artist.albums.where(:id => params[:album_id]).includes('photos').first
    rescue =>exp
      logger.error "Error in ArtistPhoto#ArtistAlbumPhotos :=> #{exp.message}"
      render :nothing   => true and return
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  def add
    if request.xhr?
      begin
        @artist_album       = @artist.albums.where(:id => params[:album_id]).first
        if @has_admin_access
          @post_url         = '/artist_photo/create'
          @artist_photo     = Photo.new        
        end
        render :action    => 'new', :format => 'js' and return
      rescue =>exp
        logger.error "Error in ArtistPhoto#Add :=> #{exp.message}"
        render :nothing   => true and return
      end
    else
      redirect_to show_artist_url(params[:artist_name]) and return
    end
  end

  def edit
    if request.xhr?
      begin        
        @artist_album       = @artist.albums.where(:id => params[:album_id]).first
        unless @has_admin_access
          render :nothing => true and return
        end
      rescue =>excp
        logger.error "Error in ArtistPhoto::Edit :=>#{excp.message}"
        render :nothing   => true and return
      end
    else
      redirect_to show_artist_url(params[:artist_name]) and return
    end
  end

  def update
    if request.xhr?
      begin
        @artist             = Artist.where(:mention_name => params[:artist_name]).first
        @artist_album       = @artist.albums.where(:id => params[:album_id]).includes('photos').first
        unless @has_admin_access
          render :nothing => true and return
        end
        @artist_album.update_attributes(params[:album])
        @has_link_access = true
      rescue =>exp
        logger.info exp.message
        render :nothing => true and return
      end
    else
      redirect_to show_artist_url(params[:artist_name]) and return
    end
  end

  def destroy_album
    if request.xhr?
      begin
        @artist_album       = @artist.albums.where(:id => params[:album_id]).first
        unless @has_admin_access
          render :nothing => true and return
        end
        @status           = @artist_album.destroy
      rescue =>exp
        logger.error "Error in ArtistPhoto::DestroyAlbum :#{exp.message}"
        @status           = false
        render :nothing => true and return
      end
    else
      redirect_to show_artist_url(params[:artist_name]) and return
    end
  end

  def edit_photo
    if request.xhr?
      begin        
        @artist_album       = @artist.albums.where(:id => params[:album_id]).first
        @artist_photo       = Photo.where(:id => params[:id]).first
        unless @has_admin_access
          render :nothing => true and return
        end
        @has_link_access    = true
      rescue =>excp
        logger.error "Error in ArtistPhoto::EditPhoto :#{excp.message}"
        render :nothing   => true and return
      end
    else
      redirect_to show_artist_url(params[:artist_name]) and return
    end
  end

  def update_photo
    if request.xhr?
      begin
        @artist_album       = @artist.albums.where(:id => params[:album_id]).first
        @artist_photo       = Photo.where(:id => params[:id]).first
        unless @has_admin_access
          render :nothing => true and return
        end
        @artist_photo.update_attributes(params[:photo])
        @has_link_access    = true
      rescue =>exp
        logger.error "Error in ArtistPhoto#UpdatePhoto :=> #{exp.message}"
        render :nothing   => true and return
      end
    else
      redirect_to show_artist_url(params[:artist_name]) and return
    end
  end

  def make_cover_image
    if request.xhr?
      begin
        @artist_album       = @artist.albums.where(:id => params[:album_id]).first
        @artist_photo       = Photo.where(:id => params[:id]).first
        unless @has_admin_access
          render :nothing => true and return
        end
        @artist_album.set_the_cover_image(@artist_photo, true)
        @has_link_access    = true
      rescue =>exp
        logger.error "Error in ArtistPhoto#MakeCoverImage :=> #{exp.message}"
        render :nothing   => true and return
      end
    else
      redirect_to show_artist_url(params[:artist_name]) and return
    end
  end

  def destroy
    if request.xhr?
      begin
        @artist_album       = @artist.albums.where(:id => params[:album_id]).first
        @artist_photo       = Photo.where(:id => params[:id]).first
        unless @has_admin_access
          render :nothing => true and return
        end
        @artist_photo.destroy
        @artist_album.choose_cover_image
        @has_link_access    = true
      rescue =>exp
        logger.error "Error in ArtistPhoto::Destroy :=>#{exp.message}"
        render :nothing => true and return
      end
    else
      redirect_to show_artist_url(params[:artist_name]) and return
    end
  end

  def disable_enable_artist_album
    redirect_to show_artist_path(params[:artist_name]) and return unless request.xhr?
    begin
      @is_admin_of_artist = current_user.is_member_of_artist?(@artist)
      @artist_album       = @artist.albums.where(:id => params[:album_id]).includes('photos').first
      @artist_album.disabled ? @artist_album.enable : @artist_album.disable
      @status             = true      
    rescue =>exp
      logger.error "Error in ArtistPhoto::DisableEnableArtistAlbum :#{exp.message}"
      @status             = false
      render :nothing     => true and return
    end
  end

  def like_dislike
    redirect_to show_artist_path(params[:artist_name]) and return unless request.xhr?
    begin
      @is_admin_of_artist = current_user.is_member_of_artist?(@artist)
      @artist_album       = @artist.albums.where(:id => params[:album_id]).includes('photos').first
      #      @artist_album.update_attribute(:disabled, !@artist_album.disabled)
      @status = true
    rescue
      @status = false
      render :nothing => true and return
    end
  end

  private

  def coerce(params)
    if params[:artist_photo].nil?
      h = Hash.new
      h[:artist_photo] = Hash.new
      h[:artist_photo][:image] = params[:Filedata]
      h[:artist_photo][:image].content_type = MIME::Types.type_for(h[:artist_photo][:image].original_filename).to_s
      h
    else
      params
    end
  end

  # finds the artist profile by artist_name parameter, and checks whether the current login is artist or fan
  # and accordingly sets the variable @has_admin_access to be used in views and other actions
  def check_and_set_admin_access
    begin
      if params[:artist_name] == 'home'
        @artist           = @actor
        @has_admin_access = @artist == @actor
        @has_link_access  = @has_admin_access
        @is_homepage      = true
      else
        @artist           = Artist.where(:mention_name => params[:artist_name]).first
        @has_admin_access = @artist == @actor
        @is_public        = true
        @has_link_access  = false
      end      
    rescue
      @artist             = nil
    end
    unless @artist
      render :template =>"bricks/page_missing" and return
    else
      redirect_to user_home_path and return unless @artist.is_artist?
    end
  end
  
end
