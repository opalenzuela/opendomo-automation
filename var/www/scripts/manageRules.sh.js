include_script("/scripts/vendor/jquery-ui.js");

jQuery( document ).ready(function( $ ) {
	$('#submit-manageRules').on("click",saveRule);
	$('#submit-executeRule').on("click",testRule);
	$('#submit-editDetails').on("click",editDetails);
	$('#submit-editRule').on("click",hideDetails);
	$("body").append("<div id='dialog' title='Enter a value'><p class='dialogcomp'></p><p class='dialogval'></p></div>");
	setTimeout(ruleDragandropEnable,500);
});
var sortableIn = 0;
function ruleDragandropEnable(){
	$("#editConditions a").prop("href","#");
	$("#ruleListContainer").sortable({
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
						$("#dialogvalue").trigger("change");
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
								command =  ui.item.find("input").val().split("+")[0];
								$(ui.item).find("input").val(command+"+"+cmdcomp);								
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
function saveRule(event) {
	event.preventDefault();
	result = "";
	$('#ruleListContainer li').each(function() {
		var value = $(this).find("input").val().replace(/\+/g," ");
		//var operation = $(this).find("p").text();
		result = result + "test (DOLLAR)" + value + "!"; // + "= " + operation + "!";
	});
	console.log(result)	
	$("#rules").val(result);
	submitForm("editRule_frm");
	$("#submit-manageRules").hide();
}

function testRule(event) {
	saveRule(event); // We need to save it first before testing!
	event.preventDefault();
	var ruleid = $("#code").val();
	var response = loadRAW("/cgi-bin/od.cgi/executeRule.sh?odcgioptionsel[]=" + ruleid + "&GUI=XML");
	if (response.indexOf("error")>-1) {
		alert("Condition is FALSE");
	} else {
		alert("Condition is TRUE");
	}
}

function editDetails(event) {
	event.preventDefault();
	$("#editRule_frm fieldset").removeClass("hidden");
}
function hideDetails(event) {
	event.preventDefault();
	$("#editRule_frm fieldset").addClass("hidden");
	saveRule(event);
}