require 'activerecord-import'

class MentionedPost < ActiveRecord::Base  
  belongs_to :user
  belongs_to :artist
  belongs_to :post
  belongs_to :mentionitem, :polymorphic =>true
  def self.create_post_mentions(post, mentioned_users, mentioned_artists)
    mentioned_posts = []
    actor           = post.writer_actor
    mentioned_users.each do |mentioned_user| 
      mentioned_posts << self.new(:post_id => post.id, :user_id => mentioned_user.id, :status => UNREAD)
      NotificationMail.mention_notification mentioned_user, actor, post
    end
    
    mentioned_artists.each do |mentioned_artist| 
      mentioned_posts << self.new(:post_id => post.id, :artist_id => mentioned_artist.id, :status => UNREAD)
      NotificationMail.mention_notification mentioned_artist, actor, post
    end
    
    self.import mentioned_posts
  end
  
end