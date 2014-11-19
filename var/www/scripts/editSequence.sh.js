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
		start: function () {
			$("#editSequence").css("border","2px dashed gray");
		},
		stop: function() { 
		 // Hide the helper once user started dragging
			$("#editSequence").css("border","none");
			$("p.info").hide();
		}
    });
    $( "ul, li" ).disableSelection();
}

