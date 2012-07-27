class Genre < ActiveRecord::Base
  acts_as_followable
  has_many :genre_users
  has_many :users, :through =>:genre_users
  has_and_belongs_to_many :artists
end
