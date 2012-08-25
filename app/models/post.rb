class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :artist
  belongs_to :postitem, :polymorphic =>true
  belongs_to :useritem, :polymorphic =>true
  has_many :mentioned_posts, :dependent =>:destroy
  has_ancestry :orphan_strategy =>:rootify
  after_save :check_and_save_mentioned_in_post
  
  # default its being called from current user wall. If current user is replying as a artist then second argument would be false  
  def owner_as_well_as_all_mentioned_users_and_artists_except(user_or_artist_id, user = true)
    participating_users_and_artists = []
    if user && !self.user_id.blank? && user_or_artist_id != self.user_id 
      participating_users_and_artists << self.user.mention_name
    elsif !user && !self.artist_id.blank? && !user_or_artist_id == self.artist_id  
      participating_users_and_artists << self.artist.mention_name
    elsif !user && !self.user.nil?
      participating_users_and_artists << self.user.mention_name
    elsif user && !self.artist.nil?
      participating_users_and_artists << self.artist.mention_name
    end
    
    self.mentioned_posts.each do |mentioned_post|
      if !mentioned_post.user_id.blank?
        if user
          if !mentioned_post.user.nil? && mentioned_post.user_id != user_or_artist_id
            participating_users_and_artists << mentioned_post.user.mention_name
          end
        else
          participating_users_and_artists << mentioned_post.artist.mention_name unless mentioned_post.artist.nil?
        end
      elsif !mentioned_post.artist_id.blank?
        if !user
          if !mentioned_post.artist.nil? && mentioned_post.artist_id != user_or_artist_id
            participating_users_and_artists << mentioned_post.artist.mention_name
          end
        else
          participating_users_and_artists << mentioned_post.user.mention_name unless mentioned_post.user.nil?
        end
      end
    end
    return participating_users_and_artists 
  end  

  def self.create_post_for item, writer_user, writer_actor, params    
    post_item = create(
      :postitem_type  => item.class.name,
      :postitem_id    => item.id,
      :user_id        => writer_user.id,
      :useritem_type  => writer_actor.class.name,
      :useritem_id    => writer_actor.id,
      :msg            => params[:msg]
    )
    post_item.create_notification_email_for_post(writer_user, item)
    post_item
  end

  def self.posts_for item, limit = 20, page=1
    where(:postitem_type => item.class.name, :postitem_id => item.id, :is_newsfeed =>false).order('created_at desc').limit(limit).page(page)
  end

  def self.create_newsfeed_for item, user_id, actor_type, actor_id, msg
    last_post = self.find_or_create_by_postitem_type_and_postitem_id(item.class.name, item.id)
    last_post.update_attributes(      
      :user_id        => user_id,      
      :is_newsfeed    => true,
      :useritem_type  => actor_type,
      :useritem_id    => actor_id,
      :msg            => msg
    )
  end

  def has_post_item?
    !self.postitem
  end
  
  def photo_post?
    postitem_type == 'Photo'
  end

  def album_post?
    postitem_type == 'Album'
  end

  def artist_music_post?
    postitem_type == 'ArtistMusic'
  end

  def song_post?
    postitem_type == 'Song'
  end

  def artist_show_post?
    postitem_type == 'ArtistShow'
  end

  def create_notification_email_for_post actor, post_item = self.postitem
    notice_receivers          = []    
    if post_item            
      useritem                = post_item.useritem      
      # posted by user-item itself
      is_own_buzz             = useritem.class.name == self.useritem_type && useritem.id == self.useritem_id      
      unless is_own_buzz        
        admin_users           = useritem.is_artist? ? useritem.artist_admin_users : useritem.venue_admin_users
        notice_receivers      = admin_users - [self.user] # do not send notification to writer fan user
      end      
      unless notice_receivers.blank?
        # send notification
        notice_receivers.each{|user|
          # user-item : on whose item the buzz has been created
          NotificationMail.buzz_notification user, actor, post_item, self
        }
      end
    end    
  end

  # who wrote this post
  def writer_actor    
    self.useritem
  end

#  protected

  def check_and_save_mentioned_in_post
    if self.msg =~/@\w/
      mentioned_items         = []
      splitted_post_msg       = self.msg.split(" ").map{|aa| "@#{aa.gsub(/[^0-9A-Za-z]/, '')}"}
      splitted_post_msg       = splitted_post_msg.map{|aa| aa.gsub('@', '')}
      mentioned_items         << User.find_in_mentioned_post(splitted_post_msg)
      mentioned_items         << Artist.find_in_mentioned_post(splitted_post_msg)
      mentioned_items         << Venue.find_in_mentioned_post(splitted_post_msg)
      MentionedPost.create_post_mentions(self, mentioned_items.flatten)
      mentioned_post_ids      = self.mentioned_posts.map { |mp| mp.id}.join(',')
      self.update_column(:mention_post_ids, mentioned_post_ids)
    end
  end
  
end