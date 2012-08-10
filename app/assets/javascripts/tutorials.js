var frame;

function fanTutorial(){
	frame = 0;
	//inital setup
	$('body').append("<div class='tutorial'></div>");
	$('.tutorial').append("<div class='dimmer'></div>").append("<div class='items'></div>").append("<div class='controls'></div>");
	$('.items').append("<div class='fan-01'></div>").append("<div class='fan-02'></div>").append("<div class='fan-03'></div>").append("<div class='fan-04'></div>").append("<div class='fan-05'></div>").append("<div class='fan-06'></div>").append("<div class='fan-07'></div>").append("<div class='fan-08'></div>").append("<div class='fan-09'></div>").append("<div class='fan-10'></div>")
	$('.controls').append("<div class='next'><h2>see next</h2></div>");
	
	//events
	$('.next').click(nextFrame);

	$(window).scroll(function(){
    $(this).scrollTop(top).scrollLeft(left);
  });
}

function nextFrame(){
	switch(frame){
		case 0:
			$('.dimmer').remove();
			$('.fan-01').remove();
			$('.fan-02').toggle();
			break;
		case 1:
			$('.fan-02').remove();
			$('.fan-03').toggle();
			break;
		case 2:
			$('.fan-03').remove();
			$('.fan-04').toggle();
			break;		
		case 3:
			$('.fan-04').remove();
			$('.fan-05').toggle();
			break;		
		case 4:
			$('.fan-05').remove();
			$('.fan-06').toggle();
			break;
		case 5:
			$('.fan-06').remove();
			$('.fan-07').toggle();
			break;
		case 6:
			$('.fan-07').remove();
			$('.fan-08').toggle();
			break;
		case 7:
			$('.fan-08').remove();
			$('.fan-09').toggle();
			break;		
		case 8:
			$('.fan-09').remove();
			$('.fan-10').toggle();
			break;
		case 9:
		default: 

      $(window).unbind('scroll');
			$('.tutorial').remove();
			break;
	}
	frame++;
	return;
}