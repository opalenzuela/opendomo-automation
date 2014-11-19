include_script("/scripts/vendor/jquery-ui.js");

$(function($) {
	setTimeout(sequenceDragandropEnable,1000);
});
var sortableIn = 0;
function sequenceDragandropEnable(){
	$( "#editSequence" ).sortable({
		revert: true,
		receive: function(event, ui){sortableIn = 1;},
		over: function(event, ui){sortableIn = 1;},
		out: function(event, ui){sortableIn = 0;},
		beforeStop: function(event, ui){
			if (sortableIn == 0) ui.item.remove();
		}
    });
    $( "#editSequenceSteps li.item" ).draggable({
		connectToSortable: "#editSequence",
		helper: "clone",
		revert: "invalid",
		stop: function() { $("p.info").hide();}	  // Hide the helper once user started dragging
    });
    $( "ul, li" ).disableSelection();
}

