class Band < ActiveRecord::Base
  has_many :band_users, :dependent => :destroy
  has_many :band_members, :through => :band_users, :source => :user
  has_many :band_albums
  has_many :band_invitations, :dependent => :destroy
  accepts_nested_attributes_for :band_invitations , :reject_if => proc { |attributes| attributes['email'].blank? }
  has_attached_file :logo, 
    :styles => { :small => '50x50#', :medium => '100x100>', :large => '350x180>' },
    :url => "/assets/images/bands/:id/:style/:basename.:extension"
  validates_attachment_content_type :logo, :content_type => ['image/jpeg', 'image/png', 'image/jpg'] 
  validates_attachment_size :logo, :less_than => 5.megabytes
  
  validates :name, :presence => true
  validates :name, :uniqueness => true
 
  searchable do
    text :genre
    text :name
  end
end

