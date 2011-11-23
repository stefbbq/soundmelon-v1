function update_crop(coords) {
	   var rx = 100/coords.w;
	   var ry = 100/coords.h;
	   $('#preview').css({
		    width: Math.round(rx * 200) + 'px',
		    height: Math.round(ry * 200) + 'px',
		    marginLeft: '-' + Math.round(rx * coords.x) + 'px',
		    marginTop: '-' + Math.round(ry * coords.y) + 'px'
	   });
    var ratio = 200 / 200;
    $("#crop_x").val(Math.round(coords.x * ratio));
    $("#crop_y").val(Math.round(coords.y * ratio));
    $("#crop_w").val(Math.round(coords.w * ratio));
    $("#crop_h").val(Math.round(coords.h * ratio));
  }