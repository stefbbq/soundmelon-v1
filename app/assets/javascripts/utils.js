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

  $('[data-validatefanusername]').blur(function() {
    $this = $(this);
    if($this.val().trim()!=''){
      $.get($this.data('validatefanusername'), {
        fan_user_name: $this.val()
      }).success(function() {
        $('.fan-username-popout').html('');
      }).error(function() {
        $('.fan-username-popout').html('<span>This username is unavailable</span>');
      });
    }
  });

  $('[data-validate]').blur(function() {
    $this = $(this);
    if($this.val().trim()!=''){
      $.get($this.data('validate'), {
        artist_name: $this.val()
      }).success(function() {
        $('.artist-name-popout').html('');
      }).error(function() {
        $('.artist-name-popout').html('<span>This name is unavailable</span>');
      });
    }    
  });

  $('[data-validatemn]').blur(function() {
    $this = $(this);
    if($this.val().trim()!=''){
      $.get($this.data('validatemn'), {
        artist_mention_name: $this.val()
      }).success(function() {
        $('.artist-username-popout').html('');
      }).error(function() {
        $('.artist-username-popout').html('<span>This username is unavailable</span>');
      });
    }    
  });

  //status input capture enter key
  var openMention = false;
  $('#post_msg').live("keyup", function(event) {
    if($(".status-input .mentions-autocomplete-list").css("display") == "block"){
      openMention = true;
    } else {
      window.setTimeout(function(){
        openMention = false;
      }, 50);
    }
    if(event.keyCode == 13 && !event.shiftKey && openMention == false) {
      $(this).val($(this).val().trim());
      $(this).closest("form").submit();
      $(this).blur();
      $(this).css('height','25px');
    }
  }
  );
  
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
                 
  $(".ajaxload").live('ajax:before', function() {
    jQuery.facebox($('#globalloading').html());    
  });
		
  $(".ajaxload").live('ajax:success', function() {
    $(':submit').removeAttr('disabled');
  });
		                
  $("a.ajaxopen").live('ajax:before', function() {
    jQuery.facebox($('#globalloading').html());    
  });
  
  $("a.ajaxopenwindow").live('click', function() {
    newwindow=window.open(this.href, 'soundmelon', 'height=500,width=700,left=45%,resizable=no,toolbar=no,location=no,status=no');
    if (window.focus) {
      newwindow.focus()
      }
    return false;
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
    var pushToQueue = location.href != this.href
    if(pushToQueue){
      History.pushState({
        sm:true
      },document.title, this.href);
      try{
        _gaq.push(['_trackPageview', this.href]);
      }catch(err){}
    }
    return false;
  });
  
  $(window).bind("popstate", function(event){
    var url         = location.href;    
    var shouldGetPage   = loaded_url != url    
    try{
      if(shouldGetPage){
        jQuery.facebox($('#globalloading').html());
        $.getScript(url,function(data, textStatus, jqxhr){
          });
        loaded_url = url;
        _gaq.push(['_trackPageview', url]);
      }
    }catch(e){}
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

  function scrollToElement(elementIdOrClass){
  if($(elementIdOrClass).length>0){
  $('html body').animate({
    scrollTop: $(elementIdOrClass).offset().top
    });
  }
  }

  function scrollToTop(){
  if($('#page-header').length>0){
  $('html, body').animate({
    scrollTop: $('#page-header').offset().top-$('#page-header').height
    });
  }
  }

  function scrollToContainerTop(){
  if($('#page-container').length>0){
  $('html, body').animate({
    scrollTop: $('#page-header').offset().top+$('#page-content .live').height
    });
  }
  }

  // page content update
  function updatePageContent(live_content, left_content, right_content){
  setUpPage();
  // update live section
  updateLiveSection(live_content);
  // update left section
  updateLeftSection(left_content);
  // update right section
  updateRightSection(right_content);
  // close facebox if exists
  closeFacebox();
  }
  function setUpPage(){
  if($('#page #page-content').length==0){
  $('#page').append('<div id="page-content"></div>');
  }
  if($('#page-content .live').length==0){
  $('#page-content').append("<div class='live'></div>");
  }
  if($('#page-content .primary-container').length==0)
  $('#page-content').append("<div class='primary-container'></div>");
  if($('.primary-container .primary').length==0)
  $('.primary-container').append("<div class='primary'><div class='left'><div class='top'></div></div><div class='right'></div></div>");
  }
  function updateLiveSection(content){
  var pageContent = $('#page-content .live');
  if(pageContent.length==0){
  $('#page-content').prepend("<div class='live'></div>");
  pageContent.html(content);
  }
  else
  pageContent.replaceWith(content);
  }
  function updateLeftSection(content){
  $('.primary-container .primary .left').html(content);
  }
  function updateRightSection(content){
  $('.primary-container .primary .right').html(content);
  }
  function closeFacebox(time){
  setTimeout('$(document).trigger(\"close.facebox\")',time);
  }
  function faceboxContent(content){
  $('#facebox .content').html(content);
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
