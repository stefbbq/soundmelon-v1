class TourPost < ActiveRecord::Base
  has_ancestry
  belongs_to :user
  belongs_to :band
  belongs_to :band_tour

  def self.band_tour_buzz_for(band_tour_id)
    TourPost.where(:tour_id => band_tour_id).order('created_at desc')
  end

  def self.create_band_tour_buzz_by(user_id, params)
    TourPost.create(
      :user_id => user_id,
      :tour_id => params[:id],
      :band_id => params[:band_id],
      :msg     => params[:msg]
    )
  end
  
end
