require 'activerecord-import'

class MentionedPost < ActiveRecord::Base  
  belongs_to :user
  belongs_to :band
  belongs_to :post
  
  def self.create_post_mentions(post, mentioned_users, mentioned_bands)
    mentioned_posts = []
    actor           = post.writer_actor
    mentioned_users.each do |mentioned_user| 
      mentioned_posts << self.new(:post_id => post.id, :user_id => mentioned_user.id, :status => UNREAD)
      #NotificationMail.mention_notification mentioned_user, actor, post
    end
    
    mentioned_bands.each do |mentioned_band| 
      mentioned_posts << self.new(:post_id => post.id, :band_id => mentioned_band.id, :status => UNREAD)
      #NotificationMail.mention_notification mentioned_band, actor, post
    end
    
    self.import mentioned_posts
  end
  
end