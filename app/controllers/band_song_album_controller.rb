# Handling all the stuffs related to song and song albums
class BandSongAlbumController < ApplicationController
  before_filter :require_login, :check_and_set_admin_access

  # renders the form for new song album, :only =>ajax_request
  def new
    redirect_to  show_band_url(:band_name => params[:band_name]) and return unless request.xhr?    
    if @has_admin_access
      @song = Song.new
    else
      render :nothing => true and return
    end
  end

  # creates the new song album
  def create
    begin
      @band = Band.where(:name => params[:band_name]).first
      if @has_admin_access
        newparams = coerce(params)
        if params[:album_name].blank?
          params[:album_name] = @band.name + Time.now.strftime("%Y-%m-%d")
        end
        @song_album           = SongAlbum.where(:album_name => params[:album_name], :band_id => @band.id).first || SongAlbum.create(:album_name=>params[:album_name], :user_id => current_user.id, :band_id => @band.id)
        @song                 = @song_album.songs.build(newparams[:song])
        @song.user_id         = current_user.id
        if @song.save
          flash[:notice] = "Song successfully uploaded."
          respond_to do |format|
            format.html {redirect_to manage_band_url(:band_name => @band.name) and return}
            format.json {
              render :json => {
                :result         => 'success',
                :upload         => @song.song_file_name,
                :album_name     => @song_album.album_name,
                :song_album_id  => @song_album.id,
                :song_count_str => @song_album.song_count,
                :image_src      => '/assets/no-image.png',
                :add_url        => "#{add_songs_to_album_path(:band_name =>@band.name, :song_album_name =>@song_album.album_name)}",
                :album_url      => "#{band_song_album_path(:band_name =>@band.name, :song_album_name =>@song_album.album_name)}",
                :delete_url     => "#{delete_song_album_path(@band.name, @song_album.id)}",
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
      logger.error "Error in BandSongAlbum#Create :=>#{exp.message}"
      render :nothing => true and return
    end
  end

  def add
    if request.xhr?
      begin
        @song_album       = SongAlbum.where(:album_name => params[:song_album_name], :band_id => @band.id).first
        if @has_admin_access
          @song           = Song.new
        else
          # render :nothing => true and return
        end
        render :action    => 'new', :format => 'js' and return
      rescue =>exp
        logger.error "Error in BandSongAlbum#Add :=> #{exp.message}"
        render :nothing   => true and return
      end
    else
      redirect_to show_band_url(params[:band_name]) and return
    end
  end
  
  def band_song_albums    
    begin
      @band               = Band.where(:name => params[:band_name]).first
      @is_admin_of_band   = current_user.is_member_of_band?(@band)
      @artist_song_albums = @band.song_albums.includes(:songs)
      get_artist_objects_for_right_column(@band)
    rescue
      render :nothing => true and return
    end
  end
  
  def band_song_album    
    begin
      @band               = Band.where(:name => params[:band_name]).first
      @is_admin_of_band   = current_user.is_member_of_band?(@band)
      @song_album         = SongAlbum.where('band_id = ? and album_name = ?', @band.id, params[:song_album_name]).includes(:songs).first
      @artist_song_albums = [@song_album]
      @show_all           = true
      get_artist_objects_for_right_column(@band)
      render :template  =>"/band_song_album/band_song_albums" and return
    rescue =>exp
      logger.error "Error in BandSongAlbum#BandSongAlbum :=> #{exp.message}"
      render :nothing => true and return
    end
  end

  def album_songs
    if request.xhr?
      begin
        @band = Band.where(:name => params[:band_name]).first
        @is_admin_of_band = current_user.is_member_of_band?(@band)
        @song_album = SongAlbum.where('band_id = ? and album_name = ?', @band.id, params[:song_album_name]).includes(:songs).first
      rescue
        render :nothing => true and return
      end
    else
      redirect_to show_band_path(:band_name => params[:band_name]) and return
    end
  end

  # edit form for song album, renders the pop-up to change the image and upload more songs
  def edit_song_album
    redirect_to show_band_path(:band_name => params[:band_name]) and return unless request.xhr?
    begin      
      if @has_admin_access
        @song_album = SongAlbum.where('band_id = ? and album_name = ?', @band.id, params[:song_album_name]).includes(:songs).first
        5.times { @song_album.songs.build }
      else
        render :noting => true and return
      end
    rescue
      render :nothing => true and return
    end
  end

  # updates the song album, adding more songs, changing the cover image
  def update_song_album
    begin      
      if @has_admin_access
        @song_album       = SongAlbum.where('band_id = ? and id = ?', @band.id, params[:id]).first
        @song_album.update_attributes(params[:song_album])        
        @is_updated       = true
        5.times { @song_album.songs.build }
        render :action => 'edit_song_album' and return
      else
        render :noting => true and return
      end
    rescue =>exp
      logger.error "Error in BandSongAlbum#UpdateSongAlbum :=> #{exp.message}"
      render :nothing => true and return
    end
  end

  def destroy_album
    if request.xhr?
      begin        
        @song_album         = SongAlbum.where(:id => params[:song_album_id], :band_id => @band.id).first
        unless @has_admin_access
          render :nothing => true and return
        end
        @status             = @song_album.destroy
      rescue =>exp
        logger.error "Error in BandSongAlbum#DestroyAlbum :=> #{exp.message}"
        @status             = false
        render :nothing => true and return
      end
    else
      redirect_to show_band_url(params[:band_name]) and return
    end
  end

  def destroy_song
    if request.xhr?
      begin
        @song           = Song.where(:id => params[:song_id]).first
        unless @has_admin_access
          render :nothing => true and return
        end
        @status         = @song.destroy
      rescue =>exp
        logger.error "Error in BandSongAlbum#DestroySong :=> #{exp.message}"
        @status         = false
        render :nothing => true and return
      end
    else
      redirect_to show_band_url(params[:band_name]) and return
    end
  end

  # edit form for a single song, renders the pop-up to change the song title
  def edit_song
    if request.xhr?
      begin                
        @song             = Song.find(params[:id])
        @is_updated       = false
        unless @has_admin_access
          render :nothing => true and return
        end
      rescue =>exp
        logger.error "Error in ArtistSongAlbum#EditSong :=> #{exp.message}"
        render :nothing => true and return
      end
    else
      redirect_to show_artist_url(params[:artist_name]) and return
    end
  end

  # updates the single song detail
  def update_song
    if request.xhr?
      begin        
        @song                   = Song.find(params[:id])
        if @has_admin_access
          @song.update_attributes(params[:song])
          @song.delay.update_metadata_to_file
          render :action => 'edit_song' and return
        end
      rescue =>exp
        logger.error "Error in BandSongAlbum#UpdateSong :=> #{exp.message}"
        render :nothing => true and return
      end
    else
      redirect_to show_artist_url(params[:artist_name]) and return
    end
  end

  # requested song album download
  def download_album
    begin      
      @song_album              = SongAlbum.find(params[:id])      
      zipped_album             = @song_album.songs_bundle(@song_album.songs.processed)      
      send_file zipped_album,  :disposition => 'inline'
    rescue =>exp
      logger.error "Error in ArtistSongAlbum#DownloadAlubm :=> #{exp.message}"
      render :nothing => true and return
    end
  end

  # requested song download
  def download
    begin
      song                      = Song.find(params[:id])
      send_file song.song.path, :disposition => 'inline'
    rescue
      render :nothing => true and return
    end
  end

  # song like by current user
  def do_like_song
    begin
      @song                     = Song.find(params[:id])
      @song.do_like_by current_user
      @song.vote_by current_user
    rescue
      render :nothing => true and return
    end
  end

  # song dislike by current user
  def do_dislike_song
    begin
      @song                     = Song.find(params[:id])
      @song.do_dislike_by current_user
    rescue
      render :nothing => true and return
    end
  end

  def disable_enable_song_album
    begin
      @band                     = Band.where(:name => params[:band_name]).first
      if current_user.is_member_of_band?(@band)
        @song_album             = SongAlbum.where('band_id = ? and album_name = ?', @band.id, params[:song_album_name]).includes(:songs).first
      end
      if @song_album
        @song_album.update_attribute(:disabled,!@song_album.disabled)
      end
    rescue
      render :nothing => true and return
    end
  end

  # lists artist's song albums to choose from for setting as featured album
  def albums_for_featured_list    
    begin
      @band               = Band.where(:name => params[:band_name]).first
      @song_albums = @band.song_albums.where('featured is false')
      @status             = true
    rescue
      @status            = false
    end
    render :layout =>false
  end

  # sets the requested song album as featured album
  def make_song_album_featured
    begin
      @band               = Band.where(:name => params[:band_name]).first
      if current_user.is_member_of_band?(@band)
        @song_album       = SongAlbum.where('band_id = ? and album_name = ?', @band.id, params[:song_album_name]).first
      end
      if @song_album
        @song_album.update_attribute(:featured, !@song_album.featured)
        @status = true        
      end
    rescue
      @status   = false      
    end
  end 
  
  private
  
  def coerce(params)
    if params[:song].nil?
      h                             = Hash.new
      h[:song]                      = Hash.new
      h[:song][:song]               = params[:Filedata]
      h[:song][:song].content_type  = MIME::Types.type_for(h[:song][:song].original_filename).to_s
      h
    else
      params
    end
  end

  # finds the artist profile by band_name parameter, and checks whether the current login is artist or fan
  # and accordingly sets the variable @has_admin_access to be used in views and other actions
  def check_and_set_admin_access
    @band             = Band.where(:name => params[:band_name]).first
    @actor            = current_actor
    @has_admin_access = @band == @actor    
  end
end

