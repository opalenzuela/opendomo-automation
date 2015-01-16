include_script("/scripts/vendor/jquery-ui.js");

$(function($) {
	setTimeout(ruleDragandropEnable,100);
	$('button[name="submit_manageRules.sh"]').on("click",saverule);
	$("body").append("<div id='dialog' title='Enter a value'><p class='dialogcomp'></p><p class='dialogval'></p></div>");
});
var sortableIn = 0;
function ruleDragandropEnable(){
	$("#editConditions a").prop("href","#");
	$( "#ruleListContainer" ).sortable({
		revert: true,
		receive: function(event, ui){sortableIn = 1;},
		over: function(event, ui){sortableIn = 1;},
		out: function(event, ui){sortableIn = 0;},
		beforeStop: function(event, ui){
			var htmlcode = "";
			if (sortableIn == 0) {
				ui.item.remove();
				$("#submit-manageRules").show();
			} else {
				var command = $(ui.item).find("input").val();
				$("p.dialogcomp").html("<select id='dialogcomparison'><option value='smaller'>Smaller</option><option selected value='equal'>Equal</option><option value='greater'>Greater</option></select>");
				
				if ((command.indexOf("[")>0) && (command.indexOf("]")>0)){
					var possible = command.split(/[\[\]]/);
					if (command.indexOf(",")>0) {
						var def = possible[1].split(",");
						for (var i=0;i<def.length;i++) {
							htmlcode=htmlcode+"<option value='"+def[i]+"'>"+def[i]+"</option>";
						}
						$("p.dialogval").html("<select id='dialogvalue'> " + htmlcode + "</select>");
					} 
					
					if (possible[1].indexOf("-")>0) {
						var def = possible[1].split("-");
						$("p.dialogval").html("<input id='dialogvalue' type='range' min='" + def[0] +"'  max='"+ def[1] + "'><br/><div id='dialogvaluerender'></div>");
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
								var comparison = $("#dialogcomparison").val();
								switch(comparison){
									case "equal":
										var cmdcomp = "=+" + value ;
										break;
									case "smaller":
										var cmdcomp = "-lt+" + value;
										break;
									case "greater":
										var cmdcomp = "-gt+" + value;
										break;
								}
								command =  ui.item.find("input").val().split("+")[0] + "+" + cmdcomp;
								$(ui.item).find("input").val(command);								
								$(ui.item).find("p").text(value);
								$(ui.item).addClass(comparison);
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
    $( "li.item.drag" ).draggable({
		connectToSortable: "#ruleListContainer",
		helper: "clone",
		revert: "invalid",
		start: function () {
			$("#ruleListContainer").css("border","2px dashed gray");
		},
		stop: function() { 
		 // Hide the helper once user started dragging
			$("#ruleListContainer").css("border","2px solid white");
			$("p.info").hide();
			$("#submit-manageRules").show();
		}
    });
    $( "ul, li" ).disableSelection();
}



var result;
function saverule(event) {
	event.preventDefault();
	result = "";
	$('#ruleListContainer li').each(function() {
		var value = $(this).find("input").val().replace("+"," ");
		result = result + "test (DOLLAR)" + value + "!";
	});
	console.log(result)	
	$("#rules").val(result);
	submitForm("editRule_frm");
	$("#submit-manageRules").hide();
}

