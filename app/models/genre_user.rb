class GenreUser < ActiveRecord::Base
  belongs_to :genre
  belongs_to :user

  def self.add_genre_and_users genres, user
    user_genre_ids  = user.genre_ids
    for gen in genres
      if user_genre_ids.include? gen.id
        genre = gen.genre_users.where(:user_id =>user.id).first
        genre.increase_count
      else
        user.genre_users.create(:genre_id =>gen.id)
      end
    end
  end

  def self.remove_genre_and_users genres, user
    user_genre_ids  = user.genre_ids
    for gen in genres
      if user_genre_ids.include? gen.id
        genre = gen.genre_users.where(:user_id =>user.id).first
        genre.decrease_count
      end
    end
  end

  def increase_count
    self.increment! :liking_count
  end

  def decrease_count
    self.decrement! :liking_count
  end
  
end
