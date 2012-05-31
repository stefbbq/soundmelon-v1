class SongAlbum < ActiveRecord::Base
  require 'zip/zip'
  require 'zip/zipfilesystem'

  acts_as_votable

  belongs_to :user
  belongs_to :band
  has_many :songs
  has_many :posts

  scope :published, :conditions =>["disabled = ?", false]

  accepts_nested_attributes_for :songs, :reject_if => proc { |attributes| attributes['song'].blank?}

  has_attached_file :cover_img,
    :styles => { :small => '35x35#', :medium => '100x100>', :large => '300x180#' },
    :url => "/assets/images/album/cover/image/:id/:style/:basename.:extension"

  validates_attachment_content_type :cover_img, :content_type => ['image/jpeg', 'image/png', 'image/jpg']
  validates_attachment_size :cover_img, :less_than => 5.megabytes

  def download_filename
    "#{self.id}_#{self.album_name}_#{sel.id}.zip"
  end

  # create a zipped archive file of all the tracks in an album
  def songs_bundle(songs = self.songs)
    bundle_filename = "#{Rails.root}/public/#{self.id}_#{self.album_name}.zip"
    logger.info "Bundling songs into '#{bundle_filename}'"

    # check to see if the file exists already, and if it does, delete it.
    if File.file?(bundle_filename)
      File.delete(bundle_filename)
    end

    # open or create the zip file
    Zip::ZipFile.open(bundle_filename, Zip::ZipFile::CREATE) {|zipfile|
      # collect the album's tracks
      songs.collect {|song|        # add each track to the archive, names using the track's attributes
        attached_song  = song.song
        begin
          zipfile.add("#{song.title_with_ext}", attached_song.path) if song.song_file_size>0
        rescue =>exp
          logger.error "Error in Adding Files into a Zip : #{exp.message}"
        end
      }
    }
    # set read permissions on the file
    File.chmod(0644, bundle_filename)
    bundle_filename
  end  

end
