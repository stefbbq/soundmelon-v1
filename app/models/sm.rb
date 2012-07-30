class Sm

  # update all older posts
  def self.update_older_posts
    Post.all.each do |post|
      postitem_type = post.postitem_type
      case postitem_type
      when 'BandTour'
        itemtype = 'ArtistShow'
      when 'SongAlbum'
        itemtype = 'ArtistMusic'
      when 'BandAlbum'
        itemtype = 'ArtistAlbum'
      when 'BandPhoto'
        itemtype = 'ArtistPhoto'
      end
      post.update_attribute(:postitem_type, itemtype)      
    end    
  end

  def self.update_mention_name
    Artist.all.each do |artist|
      if artist.mention_name
        artist.update_attribute(:mention_name, artist.mention_name.gsub("@",''))
      else
        artist.update_attribute(:mention_name, artist.name.parameterize)
      end
    end
    
    User.all.each do |fan|
      fan.update_attribute(:mention_name, fan.mention_name.gsub("@",'')) unless fan.mention_name.blank?
    end
  end

end