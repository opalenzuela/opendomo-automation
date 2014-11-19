include_script("/scripts/vendor/jquery-ui.js");

$(function($) {
	sequenceDragandropEnable();
});

function sequenceDragandropEnable(){
	$( "#editSequence" ).sortable({
      revert: true
    });
    $( "#editSequenceSteps li" ).draggable({
      connectToSortable: "#editSequence",
      helper: "clone",
      revert: "invalid"
    });
    $( "ul, li" ).disableSelection();
}

