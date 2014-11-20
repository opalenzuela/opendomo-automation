include_script("/scripts/vendor/jquery-ui.js");

$(function($) {
	setTimeout(sequenceDragandropEnable,1000);
	$('button[name="submit_editSequence.sh"]').on("click",saveSequence);
	$("body").append("<div id='dialog' title='Enter a value'><p></p></div>");
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
					
				}
				if ((command.indexOf("[")>0) && (command.indexOf("]")>0)){
					var possible = command.split(/[\[\]]/);
					if (possible[1].indexOf(",")>0) {
						var htmlcode = "";
						var def = possible[1].split(",");
						for (var i=0;i<def.length;i++) {
							htmlcode=htmlcode+"<label><input name='dialogvalue' type='radio' value='"+def[i]+"'>"+def[i]+"</label>");
						}
						$("#dialog p").html(htmlcode);
					} else {
						var def = possible[1].split("-");
						$("#dialog p").html("<input name='dialogvalue' type='range' min='" + def[0] +"'  max='"+ def[1] + "'>");
					}
					//command = possible[0] +  prompt("Choose value between " + possible[1], def[0]) + possible[2];
					//$(ui.item).find("input").val(command);
					$( "#dialog" ).dialog({
						resizable: false,
						height:140,
						modal: true,
						buttons: {
							"Ok": function() {
								var value = $("#dialog input").val();
								command = possible[0] + value + possible[2];
								$(ui.item).find("input").val(command);								
								$( this ).dialog( "close" );
							},
							"Cancel": function() {
								ui.item.remove();
							}
						}
					});			
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
