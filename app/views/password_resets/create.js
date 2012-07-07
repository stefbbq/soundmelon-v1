
  $('#facebox .close').remove();
  $('#facebox .content').html("<div class='mini-content centered'><h2>Instructions have been sent to your email.</h2></div>");
  setTimeout('$(document).trigger(\"close.facebox\")',2500);