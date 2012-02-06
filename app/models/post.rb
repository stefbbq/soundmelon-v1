class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :band
  has_many :mentioned_posts
  
  after_save :check_and_save_mentioned_in_post
  
  # default its being called from current user wall. If current user is replying as a band then second argument would be false  
  def owner_as_well_as_all_mentioned_users_and_bands_except(user_or_band_id, user = true)
    participating_users_and_bands = []
    if user && !self.user_id.blank? && user_or_band_id != self.user_id 
      participating_users_and_bands << self.user.mention_name
    elsif !user && !self.band_id.blank? && !user_or_band_id == self.band_id  
      participating_users_and_bands << self.band.mention_name
    elsif !user && !self.user.nil?
      participating_users_and_bands << self.user.mention_name
    elsif user && !self.band.nil?
      participating_users_and_bands << self.band.mention_name
    end
    
    self.mentioned_posts.each do |mentioned_post|
      if !mentioned_post.user_id.blank?
        if user
          if !mentioned_post.user.nil? && mentioned_post.user_id != user_or_band_id
            participating_users_and_bands << mentioned_post.user.mention_name
          end
        else
          participating_users_and_bands << mentioned_post.band.mention_name unless mentioned_post.band.nil?
        end
      elsif !mentioned_post.band_id.blank?
        if !user
          if !mentioned_post.band.nil? && mentioned_post.band_id != user_or_band_id
            participating_users_and_bands << mentioned_post.band.mention_name
          end
        else
          participating_users_and_bands << mentioned_post.user.mention_name unless mentioned_post.user.nil?
        end
      end
    end
    return participating_users_and_bands 
  end
  
  protected
  
  def check_and_save_mentioned_in_post
    if self.msg =~/@\w/
      splitted_post_msg = self.msg.split(" ")
      mentioned_bands = Band.find_bands_in_mentioned_post(splitted_post_msg)
      mentioned_users = User.find_users_in_mentioned_post(splitted_post_msg)
      MentionedPost.create_post_mentions(self, mentioned_users, mentioned_bands)
    end
  end
  
end
