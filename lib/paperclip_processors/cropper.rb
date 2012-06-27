module Paperclip
  class Cropper < Thumbnail
    def transformation_command
      #      if crop_command
      #        crop_command + super.join(' ').sub(/ -crop \S+/, '').split(' ') # super returns     an array like this: ["-resize", "100x", "-crop", "100x100+0+0", "+repage"]
      #      else
      #        super
      #      end      
      crop_command
    end

    # logic : resize the image to 414x size and
    # chop of the top and bottom part for profile image
    # chop of the top/bottom and left/right part for avatar
    def crop_command
      pi_height       = 246
      pi_width        = 414
      command_array   = []
      # target geometry
      t_height        = target_geometry.height.to_i
      t_width         = target_geometry.width.to_i
      # current file's dimension
      c_height        = current_geometry.height.to_i
      c_width         = current_geometry.width.to_i

      re_width      = pi_width
      resize_dim    = "#{pi_width}x"

      width         = pi_width
      height        = pi_height

      # calculate width and height after resize to 414x
      re_height     = (c_height*re_width)/c_width
      crop_x        = width <= re_width ? (re_width - width)/2 : 0
      crop_y        = height <= re_height ? (re_height - height)/2 : 0                
      command_array = ["-resize", resize_dim, "+repage", "-crop", "#{pi_width}x#{pi_height}+#{crop_x}+#{crop_y}"]
      
      if t_width != pi_width  # for other images except the profile image one
        crop_x2 = (pi_width - pi_height)/2
        crop_y2 = 0                
        command_array << ["+repage", "-crop", "#{pi_height}x#{pi_height}+#{crop_x2}+#{crop_y2}", "-resize", "#{t_width}x#{t_height}"]
      end      
      command_array
    end
  end
end
