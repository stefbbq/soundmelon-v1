class PhotoPost < ActiveRecord::Base
  has_ancestry

  def self.band_album_buzz_for(band_album_id)
    PhotoPost.where(:band_album_id => band_album_id).order('created_at desc')
  end

  def self.photo_buzz_for(band_photo_id)
    PhotoPost.where(:band_photo_id => band_photo_id).order('created_at desc')
  end

  def self.create_band_album_buzz_by(user_id, params)
    PhotoPost.create(
      :band_album_id => params[:id],
      :user_id => user_id,
      :msg => params[:msg]
    )
  end

  def self.create_photo_buzz_by(user_id, params)
    PhotoPost.create(
      :band_photo_id => params[:id],
      :user_id => user_id,
      :msg => params[:msg]
    )
  end
end
