// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

                $(document).ready( function(){
   
                  $('.delete_post').bind('ajax:before', function() {  
                     $(this).closest("div").addClass("ajaxloadsmall");
                     
                  }); 
                 
                   $(".postsubmit").attr('disabled','disabled');
                   $('.inputbox').keyup(function()
                    {
                        if($(this).val() == ''){
                         $(".postsubmit").attr('disabled','disabled');
                        }
                        else
                        {
                          if(parseInt($(this).val().length) > 200)
                          {
                            $(".postsubmit").attr('disabled','disabled');
                            $(".inputerror").html('No more than 100 charactres');
                           }
                           else
                           {
                            $(".postsubmit").removeAttr('disabled');
                            $(".inputerror").html('');
                           }
                        }
                 });


                  
                  $('#user_post_form').bind('ajax:before', function() {
                    $(".postbtn").addClass("ajaxloadsmall");
                    $(".postsubmit").hide();
                  }); 
                  $('#user_post_form').bind('ajax:success', function() {
                        $(".postbtn").removeClass("ajaxloadsmall");
                        $(".postsubmit").show();
                  }); 
                  
                  
         
  
})

function remove_fields (link) {
  $(link).siblings("input[type=hidden]:first").attr('value', '1');
	$(link).parents(".fields:first").hide();
  
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $(link).parent().before(content.replace(regexp, new_id));
}