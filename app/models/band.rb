class Band < ActiveRecord::Base
  before_validation :sanitize_mention_name
  
  acts_as_messageable :required => :body ,:order => "created_at desc" 
  has_many :band_users, :dependent => :destroy
  has_many :band_members, :through => :band_users, :source => :user
  has_many :band_albums
  has_many :band_invitations, :dependent => :destroy
  has_many :song_albums
  has_many :posts
  has_many :mentioned_posts
  has_many :songs, :through => :song_albums

  acts_as_followable
  
  accepts_nested_attributes_for :band_invitations , :reject_if => proc { |attributes| attributes['email'].blank? }
  has_attached_file :logo, 
    :styles => { :small => '50x50#', :medium => '100x100>', :large => '350x180>' },
    :url => "/assets/images/bands/:id/:style/:basename.:extension"
  validates_attachment_content_type :logo, :content_type => ['image/jpeg', 'image/png', 'image/jpg'] 
  validates_attachment_size :logo, :less_than => 5.megabytes
  
  validates :name, :presence => true
  validates :name, :uniqueness => true
  validates :mention_name, :uniqueness => true

  searchable do
    text :genre
    text :name
  end
  
  def self.find_bands_in_mentioned_post mentioned_name_arr
    return where(:mention_name => mentioned_name_arr).select('DISTINCT(id)').all
  end
  
  def sanitize_mention_name
    unless self.mention_name.blank?
      self.mention_name = self.mention_name.strip =~ /^@/ ? self.mention_name : "@#{self.mention_name}"  
    end  
  end
  
  def find_own_as_well_as_mentioned_posts page=1   
    Post.joins('LEFT OUTER JOIN mentioned_posts ON posts.id = mentioned_posts.post_id').where('mentioned_posts.band_id = :band_id or (posts.band_id = :band_id and posts.is_deleted = :is_deleted)',  :band_id => self.id, :is_deleted => false).order('posts.created_at DESC').uniq.paginate(:page => page, :per_page => 10)
  end
  
  def is_part_of_post? post
    if(post.band == self || post.mentioned_posts.map{|mentioned_post| mentioned_post.band.id}.include?(self.id))
      return true
    else
      return false
    end
  end
  
  def mention_count
    self.mentioned_posts.where('band_id = ? and created_at >= ?', self.id, MENTION_COUNT_FOR_LAST_N_HOURS.hours.from_now).count
  end
  
  def song_albums_count
    self.song_albums.count
  end
  
  def songs_count
    self.songs.count
  end
  
end