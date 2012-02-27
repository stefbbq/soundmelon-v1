$(document).ready( function(){
  $('.auto_search_complete').autocomplete({
    minLength: 3,
    delay: 600,
    source: function(request, response) {
      $.ajax({
        url: "/autocomplete/suggestions.js",
        dataType: "json",
        data: {term: request.term},
        success: function( data ) {
          response( data );
        }
      });
    }          
  });
                
  $('.location_auto_search_complete').autocomplete({
    minLength: 3,
    delay: 600,
    source: function(request, response) {
      $.ajax({
        url: "<%= location_autocomplete_suggestions_url %>",
        dataType: "json",
        data: {term: request.term},
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
  
  $('.msgbox#message_text').keyup(function(){
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
		                
  $(".ajaxopen").bind('ajax:before', function() {
    jQuery.facebox($('#globalloading').html());
		  $(':submit').attr('disabled','disabled');
		}); 
		                  
		$(document).delegate('a[rel*=topup]', 'click', function(e) {
    $.facebox({ div: this.hash });
   	$(".ajaxopen").bind({
  		  'ajax:before': function() {
        jQuery.facebox($('#globalloading').html());
		    },
		    'ajax:success': function() {
        //$(':submit').removeAttr('disabled');
      }
		  }); 
	   e.preventDefault();
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
  $(div_id).siblings('.thread_expand').show();
}

function show_parent_posts(div_id) {
  $(div_id).siblings().show();
  $(div_id).siblings('.thread_expand').hide();
  $('.thread_collapse').show();
}