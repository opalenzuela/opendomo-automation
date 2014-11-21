include_script("/scripts/vendor/jquery-ui.js");

$(function($) {
	setTimeout(sequenceDragandropEnable,100);
	$('button[name="submit_editSequence.sh"]').on("click",saveSequence);
	$("body").append("<div id='dialog' title='Enter a value'><p></p></div>");
});
var sortableIn = 0;
function sequenceDragandropEnable(){
	$("#editSequenceSteps a").prop("href","#");
	$( "#stepListContainer" ).sortable({
		revert: true,
		receive: function(event, ui){sortableIn = 1;},
		over: function(event, ui){sortableIn = 1;},
		out: function(event, ui){sortableIn = 0;},
		beforeStop: function(event, ui){
			var htmlcode = "";
			if (sortableIn == 0) {
				ui.item.remove();
			} else {
				var command = $(ui.item).find("input").val();

				if ((command.indexOf("???")>0) ||((command.indexOf("[")>0) && (command.indexOf("]")>0))){
					if (command.indexOf("???")>0){
						var possible = command.split(/\?\?\?/);
						$("#dialog p").html("<input id='dialogvalue' type='text' />");
					} else {
						var possible = command.split(/[\[\]]/);
					}
					
					if (possible[1].indexOf(",")>0) {
						var def = possible[1].split(",");
						for (var i=0;i<def.length;i++) {
							htmlcode=htmlcode+"<option value='"+def[i]+"'>"+def[i]+"</option>";
						}
						$("#dialog p").html("<select id='dialogvalue'> " + htmlcode + "</select>");
					} 
					
					if (possible[1].indexOf("-")>0) {
						var def = possible[1].split("-");
						$("#dialog p").html("<input id='dialogvalue' type='range' min='" + def[0] +"'  max='"+ def[1] + "'><br/><div id='dialogvaluerender'></div>");
						$("#dialogvalue").on("change", function(){$("#dialogvaluerender").text($(this).val())});
					}
					//command = possible[0] +  prompt("Choose value between " + possible[1], def[0]) + possible[2];
					//$(ui.item).find("input").val(command);
					$( "#dialog" ).dialog({
						resizable: false,
						draggable: false,
						modal: true,
						buttons: {
							"Ok": function() {
								var value = $("#dialogvalue").val();
								command = possible[0] + value + possible[2];
								$(ui.item).find("input").val(command);								
								$(ui.item).find("p").text($(ui.item).find("p").text().replace("???",value));
								$( this ).dialog( "close" );
							},
							"Cancel": function() {
								ui.item.remove();
								$( this ).dialog( "close" );
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
function saveSequence(event) {
	event.preventDefault();
	result = "";
	$('#stepListContainer li').each(function() {
		var value = $(this).find("input").val().replace("+"," ");
		var literal = $(this).find("p").text();
		result = result + value + " # " + literal + "!";
	});
	console.log(result)	
	$("#steplist").val(result);
	submitForm("editSequence_frm");
}
