module ApplicationHelper
  
  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end
  
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, ("add_fields(this, '#{association}', '#{escape_javascript(fields)}')"))
  end
  
  def get_avatar_small(user)
    if user.profile_pic
      image_tag(user.profile_pic.avatar.url(:small), :alt=>'')
    else
      image_tag('fan-defaults-photo-thumbnail.png', :alt=>'')
    end
  end
  
  def get_avatar_medium(user)
    if user.profile_pic
      image_tag(user.profile_pic.avatar.url(:medium), :alt=>'')
    else
      image_tag('fan-defaults-photo-profile.png', :alt=>'')
    end
  end
  
  def get_avatar_large(user, my_avatar = false)
    my_avatar = true if current_user.id == user.id
    if my_avatar
      if user.profile_pic(true)
        edit_delete_links_and_img_str = '<div>'
        edit_delete_links_and_img_str += link_to 'edit', crop_avatar_path, :remote=>:true,:class=>'ajaxopen'
        edit_delete_links_and_img_str += link_to 'change', new_avatar_path, :remote=>:true,:class=>'ajaxopen'
        edit_delete_links_and_img_str += link_to 'delete', delete_avatar_path, :remote=>:true
        edit_delete_links_and_img_str += '</div>'
        edit_delete_links_and_img_str += '<div>'
        edit_delete_links_and_img_str += image_tag(user.profile_pic.avatar.url(:large))
        edit_delete_links_and_img_str += '</div>' 
        raw edit_delete_links_and_img_str  
      else
        raw "<div>#{link_to 'Add', new_avatar_path, :remote=>:true,:class=>'ajaxopen'}</div><div>#{image_tag('fan-defaults-photo-profile.jpg')}</div>"
      end
    else
      if user.profile_pic
        image_tag(user.profile_pic.avatar.url(:large), :alt=>'')
      else
        image_tag('fan-defaults-photo-profile.png', :alt=>'')
      end
    end
  end

  def get_band_logo_small(band)
    if band.logo_content_type.nil?
      image_tag('artist-defaults-photo-thumbnail.jpg', :alt=>'')
    else
      image_tag(band.logo.url(:small), :alt=>'')
    end  
  end
  
  def get_band_logo_medium(band)
     if band.logo_content_type.nil?
      image_tag('artist-defaults-photo-profile.jpg', :alt=>'')
    else
      image_tag(band.logo.url(:medium), :alt=>'')
    end  
  end
  
  def get_band_logo_large(band)
    if band.logo_content_type.nil?
      image_tag('artist-defaults-photo-thumbnail.jpg', :alt=>'')
    else
      image_tag(band.logo.url(:large), :alt=>'')
    end   
  end
  
  def genre_atuofill
    genres = Genre.all
    avail_genre = ''
    genres.each do |genre|
      avail_genre += "{id: '#{genre.name}', name: '#{genre.name}'},"
    end
    return avail_genre
  end
  
  def genre_prepopullate genre
    pre_popullate_genre = ''
    unless genre.nil?
      genre.split(',').each do |cur_genre|
        pre_popullate_genre += "{id: '#{cur_genre}', name: '#{cur_genre}'},"
      end
    end
    return pre_popullate_genre
  end
  
  def user_mention_lists(user)
    auto_mention_list = ''
    mention_list_arr = []
    user.following_user.select('mention_name').map{|user_following| mention_list_arr << user_following.mention_name}
    user.user_followers.select('mention_name').map{|follower_user| mention_list_arr << follower_user.mention_name}
    user.following_band.select('mention_name').map{|band_following| mention_list_arr << band_following.mention_name}
    mention_list_arr.uniq.each do |mentioner|
      auto_mention_list += "{name: '#{mentioner}'},"
    end
    return auto_mention_list
  end
  
  def band_follower_mention_lists band
    auto_mention_list = ''
    mention_list_arr = []
    band.user_followers.select('mention_name').map{|follower_user| mention_list_arr << follower_user.mention_name}
    mention_list_arr.uniq.each do |mentioner|
      auto_mention_list += "{name: '#{mentioner}'},"
    end
    return auto_mention_list
  end
  
  def get_album_cover_image(song_album, type='small', width=nil, height=nil)
    if song_album.cover_img_content_type.nil?
      image_tag('no-image.png', :alt=>'')
    else
      (width.nil? and height.nil?) ? image_tag(song_album.cover_img.url(type), :alt=>'aa') : image_tag(song_album.cover_img.url(type), :width =>width,:height=>height, :alt=>'')
    end  
  end
  
  def get_band_photo_album_teaser_photo(band_photo_album, type='thumb')
    if band_photo_album.band_photos.first.blank? || band_photo_album.band_photos.first.image_content_type.nil?
      image_tag('no-image.png', :alt=>'')
    else
      image_tag(band_photo_album.band_photos.first.image.url(type), :alt=>'')
    end  
  end
  
end
