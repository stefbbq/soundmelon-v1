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
        success: function( data ) {
          response( data );
        }
      });
    },
    open: function(event, ui) {            
      $('ul.ui-autocomplete').removeAttr('style').hide().appendTo('.searchlist').show();
      $('.searchlist').show();
    },
    close: function(event, ui){
      $('.searchlist').hide();
    }
  });
                
  $('.location_auto_search_complete').autocomplete({
    minLength: 3,
    delay: 600,
    source: function(request, response) {
      $.ajax({
        url: "<%= location_autocomplete_suggestions_url %>",
        dataType: "json",
        data: {
          term: request.term
          },
        success: function( data ) {
          response( data );
        }
      });
    }          
  });
                
  $('[data-validate]').blur(function() {
    $this = $(this);
    $.get($this.data('validate'), {
      band_name: $this.val()
    }).success(function() {
      $('.bandname_available').html('');
    }).error(function() {
      $('.bandname_available').html('This band name is not available');
    });
  });

  $(".postsubmit").attr('disabled','disabled');
  $('.inputbox').keyup(function() {
    if($(this).val() == ''){
      $(".postsubmit").attr('disabled','disabled');
    } 
    else{
      if(parseInt($(this).val().length) > 200){
        $(".postsubmit").attr('disabled','disabled');
        $(".inputerror").html('No more than 100 charactres');
      }
      else{
        $(".postsubmit").removeAttr('disabled');
        $(".inputerror").html('');
      }
    }
  });
  
  $('.container#message_text').keyup(function(){
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
    history.pushState({sm:true}, document.title, this.href);
    return false;
  });
  
  $(window).bind("popstate", function(event){    
    if(event.originalEvent.state)
      $.getScript(location.href);
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