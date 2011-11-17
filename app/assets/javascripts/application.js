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
$('.msgbox#message_text').keyup(function()
                    {
                        if($(this).val() == ''){
                         $("#send_message_btn").attr('disabled','disabled');
                        }
                        else
                        {
                          if(parseInt($(this).val().length) > 200)
                          {
                            $("#send_message_btn").attr('disabled','disabled');
                            //$(".inputerror").html('No more than 100 charactres');
                           }
                           else
                           {
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
		                 //
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