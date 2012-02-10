class BandSongAlbumController < ApplicationController
  before_filter :require_login
  
  def index
   # @photos = Photos.all
  end
  
#  def show
#    begin
#      @band = Band.where(:name => params[:band_name]).first
#      if current_user.is_member_of_band?(@band)
#        @band_album = BandAlbum.where('band_id = ? and name = ?', @band.id, params[:band_album_name]).first
#        @photo = BandPhoto.find(params[:id])
#        render :nothing => true and return unless @photo.band_album_id == @band_album.id
#      else
#        render :noting => true and return
#      end
#    rescue
#      render :nothing => true and return
#    end       
#  end

  def new
    @band = Band.where(:name => params[:band_name]).first
    if current_user.is_admin_of_band?(@band)
      @song = Song.new
    else
      render :nothing => true and return
    end
  end

  def create
    begin
      @band = Band.where(:name => params[:band_name]).first
      if current_user.is_admin_of_band?(@band)
        newparams = coerce(params)
        if params[:album_name].blank?
         params[:album_name] = @band.name + Time.now.strftime("%Y-%m-%d")
        end
        @song_album = SongAlbum.where(:album_name => params[:album_name], :band_id => @band.id).first || SongAlbum.create(:album_name=>params[:album_name], :user_id => current_user.id, :band_id => @band.id)
        @song = @song_album.songs.build(newparams[:song])
        @song.user_id = current_user.id
        if @song.save
          flash[:notice] = "Song successfully uploaded."
          respond_to do |format|
           format.html {redirect_to manage_band_url(:band_name => @band.name) and return}
           format.json {render :json => { :result => 'success', :upload => @song.song_file_name, :album_name => @song_album.album_name } }
         end
       else
          render :action => 'new'
       end
     else
       render :nothing => true and return
     end
   rescue
     render :nothing => true and return 
   end   
  end

  def destroy

  end
  
  def band_song_albums
   begin
     @band = Band.where(:name => params[:band_name]).first
     if current_user.is_member_of_band?(@band)
       @song_albums = @band.song_albums.includes(:songs)
     else
       render :noting => true and return
     end
   rescue
     render :nothing => true and return
   end
  end
  
  def album_songs
   begin
     @band = Band.where(:name => params[:band_name]).first
     if current_user.is_member_of_band?(@band)
       @song_album = SongAlbum.where('band_id = ? and album_name = ?', @band.id, params[:song_album_name]).includes(:songs).first
     else
       render :noting => true and return
     end
   rescue
     render :nothing => true and return
   end   
  end
  
  def edit_song_album
    begin
      @band = Band.where(:name => params[:band_name]).first
      if current_user.is_member_of_band?(@band)
        @song_album = SongAlbum.where('band_id = ? and album_name = ?', @band.id, params[:song_album_name]).includes(:songs).first
        2.times { @song_album.songs.build }
      else
        render :noting => true and return
      end
    rescue
      render :nothing => true and return
    end
  end
  
  def update_song_album
    begin
      @band = Band.where(:name => params[:band_name]).first
      if current_user.is_member_of_band?(@band)
        @song_album = SongAlbum.where('band_id = ? and id = ?', @band.id, params[:id]).first
        @song_album.update_attributes(params[:song_album])
        render :action => 'album_songs' and return
      else
        render :noting => true and return
      end
    rescue
      render :nothing => true and return
    end
  end
  
  private 
  def coerce(params)
    if params[:song].nil? 
      h = Hash.new 
      h[:song] = Hash.new  
      h[:song][:song] = params[:Filedata] 
      h[:song][:song].content_type = MIME::Types.type_for(h[:song][:song].original_filename).to_s
      h
    else 
      params
    end 
  end  
end