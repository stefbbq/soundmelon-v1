class AdditionalInfo < ActiveRecord::Base
  belongs_to      :user
#  attr_protected  :user_id
#  validates       :location, :presence => true
  after_save      :update_user_genres
  
  searchable do
    text :location
    text :favourite_genre
  end

  def update_user_genres
    user            = self.user    
    fav_genres      = self.favourite_genre.blank? ? [] : self.favourite_genre.split(',')    
    user.genres     = Genre.where('name in (?)', fav_genres)
#    for genre_name in new_fav_genres
#      unless user_genre_names.include?(genre_name)
#        genre       = Genre.find_by_name(genre_name)
#        if genre
#          GenreUser.create(:genre_id =>genre.id, :user_id =>user.id)
#        end
#      end
#    end
  end
  
end

