class FavoriteItem < ActiveRecord::Base
  belongs_to :favoreditem, :polymorphic =>:true
  belongs_to :item, :polymorphic =>:true
  scope :for_venues, :conditions =>['favoreditem_type = ?', 'Venue']
  scope :for_artists, :conditions =>['favoreditem_type = ?', 'Artist']
  scope :for_genres, :conditions =>['favoreditem_type = ?', 'Genre']
end
