class AdditionalInfo < ActiveRecord::Base
  belongs_to      :user
#  attr_protected  :user_id
  validates       :location, :presence => true
#  validates :location, :presence => { :message => "You should provide your location"}
  after_save      :update_user_genres
  
  searchable do
    text :location
    text :favourite_genre
  end

  def update_user_genres
    user            = self.user
    user_genres     = user.genres    
    new_fav_genres  = self.favourite_genre.blank? ? [] : self.favourite_genre.split(',')
    user_genre_names= user_genres.map{|g| g.name}    
    for genre_name in new_fav_genres
      unless user_genre_names.include?(genre_name)
        genre       = Genre.find_by_name(genre_name)
        if genre
          GenreUser.create(:genre_id =>genre.id, :user_id =>user.id)
        end
      end
    end
  end
  
end

