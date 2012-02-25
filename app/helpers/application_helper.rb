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
      image_tag('user_blank_small.jpg', :alt=>'')
    end
  end
  
  def get_avatar_medium(user)
    if user.profile_pic
      image_tag(user.profile_pic.avatar.url(:medium), :alt=>'')
    else
      image_tag('user_blank_large.jpg', :alt=>'')
    end
  end
  
  def get_avatar_large(user, my_avatar = false)
    my_avatar = true if current_user.id == user.id
    if my_avatar
      if user.profile_pic(true)
        raw "<div>#{link_to 'Change', new_avatar_path, :remote=>:true,:class=>'ajaxopen'} #{link_to 'Delete', delete_avatar_path, :remote=>:true}</div><div>#{image_tag(user.profile_pic.avatar.url(:large))}</div>"  
      else
        raw "<div>#{link_to 'Add', new_avatar_path, :remote=>:true,:class=>'ajaxopen'}</div><div>#{image_tag('user_blank_large.jpg')}</div>"
      end
    else
      if user.profile_pic
        image_tag(user.profile_pic.avatar.url(:large), :alt=>'')
      else
        image_tag('user_blank_large.jpg', :alt=>'')
      end
    end
  end

  def get_band_logo_small(band)
    if band.logo_content_type.nil?
      image_tag('band_logo_blank_small.jpg', :alt=>'')
    else
      image_tag(band.logo.url(:small), :alt=>'')
    end  
  end
  
  def get_band_logo_medium(band)
     if band.logo_content_type.nil?
      image_tag('band_logo_blank_medium.jpg', :alt=>'')
    else
      image_tag(band.logo.url(:medium), :alt=>'')
    end  
  end
  
  def get_band_logo_large(band)
    if band.logo_content_type.nil?
      image_tag('band_logo_blank_large.jpg', :alt=>'')
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
  
end
