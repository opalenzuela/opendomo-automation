include_script("/scripts/vendor/jquery-ui.js");

$(function($) {
	setTimeout(sequenceDragandropEnable,1000);
});

function sequenceDragandropEnable(){
	$( "#editSequence" ).sortable({
      revert: true
    });
    $( "#editSequenceSteps li.item" ).draggable({
      connectToSortable: "#editSequence",
      helper: "clone",
      revert: "invalid"
    },
	// Hide the helper once user started dragging
	stop: function() { $("p.info").hide();}
	);
    $( "ul, li" ).disableSelection();
}

