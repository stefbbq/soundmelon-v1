$(document).ready( function(){
  var searchAutoComplete = $('.auto_search_complete').autocomplete({
    minLength: 3,
    delay: 600,
    source: function(request, response) {
      $.ajax({
        url: "/autocomplete/suggestions.js",
        dataType: "json",
        data: {
          term: request.term
        },
        success: function( data ){
          response( data );
        }
      });
    },
    open: function(event, ui) {
      $('ul.ui-autocomplete').addClass('search-autocomplete').prepend('<div class="pointer"></div>').removeClass('ui-menu ui-widget ui-widget-content ui-corner-all');      
    },
    select: function(event, ui) {          
      $('#search input#term').val(ui.item.label);
      $("#search").submit();
    }
  });
                
  $('[data-validate]').blur(function() {
    $this = $(this);
    $.get($this.data('validate'), {
      band_name: $this.val()
    }).success(function() {
      $('.artist-name-popout').html('');
    }).error(function() {
      $('.artist-name-popout').html('<span>This name is unavailable</span>');
    });
  });

  $('[data-validatemn]').blur(function() {
    $this = $(this);
    $.get($this.data('validatemn'), {
      band_mention_name: $this.val()
    }).success(function() {
      $('.artist-username-popout').html('');
    }).error(function() {
      $('.artist-username-popout').html('<span>This username is unavailable</span>');
    });
  });


  $('#post_msg').keyup(function( event )
  {
    if(event.keyCode == 13 && !event.shiftKey)
    {
      $(this).closest("form").submit();
      $(this).css('height','25px');
    }
  });
  
	//status input
  $(".post-btn").attr('disabled','disabled');
  $('.input-box').keyup(function() {
    if($(this).val() == ''){
      $(".post-btn").attr('disabled','disabled');
    } 
    else{
      if(parseInt($(this).val().length) > 200){
        $(".post-btn").attr('disabled','disabled');
        $(".inputerror").html('no more than 200 charactres');
      } else {
	      $('.mentions-autocomplete-list').css('top', $('.status-input .input-box').height() + 5);      
	      $('.status-input input[type=checkbox]').removeAttr("disabled");
	      $('.status-input .pin .text').css('color', '#bbb');
	      $('.post-btn').css({ opacity: 1 });	
        $(".post-btn").removeAttr('disabled');
        $(".inputerror").html('');
      }
    }
  });
  
  $('.primary-wrapper#message_text').keyup(function(){
    if($(this).val() == ''){
      $("#send_message_btn").attr('disabled','disabled');
    }
    else{
      if(parseInt($(this).val().length) > 200){
        $("#send_message_btn").attr('disabled','disabled');
      //$(".inputerror").html('No more than 100 charactres');
      }
      else{
        $("#send_message_btn").removeAttr('disabled');
      //$(".inputerror").html('');
      }
    }
  });
                 
  $(".ajaxload").bind('ajax:before', function() {
    jQuery.facebox($('#globalloading').html());
    $(':submit').attr('disabled','disabled');
  });
		
  $(".ajaxload").bind('ajax:success', function() {
    $(document).trigger("close.facebox");
    $(':submit').removeAttr('disabled');
  });
		                
  $("a.ajaxopen").bind('ajax:before', function() {
    jQuery.facebox($('#globalloading').html());
    $(':submit').attr('disabled','disabled');
  });
		                  
  $(document).delegate('a[rel*=topup]', 'click', function(e) {
    $.facebox({
      div: this.hash
    });
    $("a.ajaxopen").bind({
      'ajax:before': function() {
        jQuery.facebox($('#globalloading').html());
      },
      'ajax:success': function() {
      //$(':submit').removeAttr('disabled');
      }
    });
    e.preventDefault();
  });
  
  $('a.backable').live('click', function(){
    if(location.href!= this.href){
      history.pushState({
        sm:true
      }, document.title, this.href);      
    }    
    return false;
  });
  
  $(window).bind("popstate", function(event){    
    if(event.originalEvent.state){
      jQuery.facebox($('#globalloading').html());      
      $.getScript(location.href,function(data, textStatus, jqxhr) {
        $(document).trigger("close.facebox");
      });      
    }
  });
});

function remove_fields (link) {
  $(link).siblings("input[type=hidden]:first").attr('value', '1');
  $(link).parents(".fields:first").hide();
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $(link).parent().before(content.replace(regexp, new_id));
}

function hide_parent_posts(div_id) {
  $(div_id).siblings().hide();
  $(div_id).siblings('.thread-expand').show();
}

function show_parent_posts(div_id) {
  $(div_id).siblings().show();
  $(div_id).siblings('.thread-expand').hide();
  $('.thread-collapse').show();
}

function hide_songs(div_id){
  $(div_id).children('.song').hide();
  $(div_id).find('.thread-expand').hide();
  $(div_id).find('.toggle-thread').show(); 
}

function show_songs(div_id){
  $(div_id).children('.song').show();
  $(div_id).find('.thread-expand').hide();
  $(div_id).find('.thread-collapse').show();    
}

function set_right_height(height){
  var resizeTarget = $('.primary .left');
  var target = $('.primary .right');
  if(height)
    target.css('height', height);
  else
    target.css('height', resizeTarget.height());
}

function updateSections(live_content, left_content, right_content){
// update live section
// update left section
// update right section
}

function scrollToElement(elementIdOrClass){
  if($(elementIdOrClass).length>0){
    $('html body').animate({
      scrollTop: $(elementIdOrClass).offset().top
      });
  }
}

function scrollToTop(){
  if($('#page-header').length>0){
    $('html body').animate({
      scrollTop: $('#page-header').offset().top-$('#page-header').height
      });
  }
}

//cursor position jquery
new function($) {
  $.fn.getCursorPosition = function() {
    var pos = 0;
    var el = $(this).get(0);
    // IE Support
    if (document.selection) {
      el.focus();
      var Sel = document.selection.createRange();
      var SelLength = document.selection.createRange().text.length;
      Sel.moveStart('character', -el.value.length);
      pos = Sel.text.length - SelLength;
    }
    // Firefox support
    else if (el.selectionStart || el.selectionStart == '0')
      pos = el.selectionStart;

    return pos;
  }
} (jQuery);
