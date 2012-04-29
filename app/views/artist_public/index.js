alert("eat poop!");
$('.primary .left').html('#{escape_javascript(render 'status_input')}');
$('.primary .left').append('#{escape_javascript(render 'social_header')}');
$('.primary .left').append('#{escape_javascript(render 'posts')}');
setTimeout('$(document).trigger(\"close.facebox\")',10);
$('.selection-box').removeClass('active').removeClass('button-fill-artist');
$('#user-posts').addClass('active').addClass('button-fill-artist');
