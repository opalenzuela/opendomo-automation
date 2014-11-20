include_script("/scripts/vendor/jquery-ui.js");

$(function($) {
	setTimeout(sequenceDragandropEnable,1000);
	$('button[name="submit_editSequence.sh"]').on("click",saveSequence);
});
var sortableIn = 0;
function sequenceDragandropEnable(){
	$( "#stepListContainer" ).sortable({
		revert: true,
		receive: function(event, ui){sortableIn = 1;},
		over: function(event, ui){sortableIn = 1;},
		out: function(event, ui){sortableIn = 0;},
		beforeStop: function(event, ui){
			if (sortableIn == 0) {
				ui.item.remove();
			} else {
				var command = $(ui.item).find("input").val();
				if (command.indexOf("???")>0){
					command = command.replace("???",prompt("Value"));
					$(ui.item).find("input").val(command);
				}else if ((command.indexOf("[")>0) && (command.indexOf("]")>0)){
					var possible = command.split(/[\[\]]/);
					var def = possible[1].split(",")[0];
					command = possible[0] +  prompt("Choose value between " + possible[1], def) + possible[2];
					$(ui.item).find("input").val(command);				
				}
			}
		}
    });
    $( "#editSequenceSteps li.item" ).draggable({
		connectToSortable: "#stepListContainer",
		helper: "clone",
		revert: "invalid",
		start: function () {
			$("#stepListContainer").css("border","2px dashed gray");
		},
		stop: function() { 
		 // Hide the helper once user started dragging
			$("#stepListContainer").css("border","none");
			$("p.info").hide();
		}
    });
    $( "ul, li" ).disableSelection();
}



var result;
function saveSequence() {
	result = "";
	$('#stepListContainer li').each(function() {
		var value = $(this).find("input").val().replace("+"," ");
		var literal = $(this).find("p").text();
		result = result + value + " # " + literal + "\n";
	});
	console.log(result)	
	$("#steplist").val(result);
	submitForm("editSequence_frm");
}
