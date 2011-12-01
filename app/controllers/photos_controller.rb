class PhotosController < ApplicationController 
  before_filter :require_login
  
  def index
    @photos = Photos.all
  end
  
  def show
    @photo = Photo.find(params[:id])
  end

  def new
    @photo = Photo.new
  end

  def edit
    @photo = Photo.find(params[:id])
  end

  def create
    newparams = coerce(params)
    if params[:album_name].blank?
       params[:album_name] = Time.now.strftime("%Y-%m-%d")
    end
    
    @album = Album.find_or_create_by_name(params[:album_name], :user_id => current_user.id)
    @photo = @album.photos.build(newparams[:photo])
    if @photo.save
      flash[:notice] = "Successfully created upload."
      respond_to do |format|
        format.html {redirect_to user_home_url and return}
        format.json {render :json => { :result => 'success', :upload => @photo.image.url(:thumb), :album_name => @album.name } }
      end
    else
      render :action => 'new'
    end
  end

  def update
    @photo = Photo.find(params[:id])
    respond_to do |format|
      if @photo.update_attributes(params[:photo])
        format.html { redirect_to(@photo, :notice => 'Photo was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy
    respond_to do |format|
      format.html { redirect_to(photos_url) }
    end
  end
  
  def albums
    @albums = current_user.albums.includes('photos')
  end
  
  def album_photos
    @album = Album.where('name = ? and user_id = ? ', params[:album_name], current_user.id).includes('photos').first
  end
  
  private 
  def coerce(params)
    if params[:photo].nil? 
      h = Hash.new 
      h[:photo] = Hash.new  
      h[:photo][:image] = params[:Filedata] 
      h[:photo][:image].content_type = MIME::Types.type_for(h[:photo][:image].original_filename).to_s
      h
    else 
      params
    end 
  end  
end