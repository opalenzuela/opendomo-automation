var repositoryURL="https://github.com/opalenzuela/opendomo-automation/";

jQuery(function($) {
	updatePorts();
});

var portdata;
function updatePorts()
{	
	$.ajax({url:"/data/odauto.json",dataType:"json"})
		.done(function(portdata){
			var list = document.getElementById("listControlPorts");
				if (portdata) {
					// Only if "loading" is visible, we clear it
					//if (document.getElementById("loading_li")) list.innerHTML = "";
					
					for(var i=0;i<portdata.ports.length;i++) {
						var p = portdata.ports[i];
						var field = $(("#" + p.Id).replace("/","-"));
						if (field.length==1) { // It already exists. Just update value if required
							if ((p.Value) && (p.Value !="") && (p.Name.indexOf("$")==-1)) {
								switch(p.Type.toUpperCase()) {
									case "DV":
									case "DO":
									case "DI":
										//li.find("p").find("a").attr("class",p.Value.toLowerCase());
										field.val(p.Value.toLowerCase());
										if (p.Value.toLowerCase()=="on") {
											field.parent().parent().addClass("sw_on").removeClass("sw_off");
										} else {
											field.parent().parent().addClass("sw_off").removeClass("sw_on");
										}
										break;
									case "AI":
										//li.find("p").innerHTML =  parseFloat(p.Value);
										field.val(parseFloat(p.Value));
										break;
									case "AO":
										//li.find("input").val(parseFloat(p.Value));
										field.val(parseFloat(p.Value));
										//li.trigger("change");
										break;
									case "TXT":							
										//li.find("p").innerHTML =  p.Value;
										field.val(p.Value);
										break;
								}
							}
						} else {  // It does not exists, ignore:	
							//console.log("Port does not exists: "+p.Id);
						}
					}
				} else {
					console.log("No port data available");
				}			
		})
		.fail(function(){});
	
	
}

setInterval(updatePorts,5000);
$(function(){
	$("input[type=range]").on("change",function() {
		var value = $(this).val();
		var portid = $(this).prop("id");
		var uri = "/cgi-bin/od.cgi/listControlPorts.sh?port=" + portid.replace("-","/") + "&value=" + value;
		$("#" + this.id + "_disp").val(this.value);
		$.get(uri,function(){
			setTimeout(updatePorts,1000);
			}
		);	
	});
	$("select").on("change",function() {
		var value = $(this).val();
		var portid = $(this).prop("id");
		var uri = "/cgi-bin/od.cgi/listControlPorts.sh?port="+ portid.replace("-","/") +"&value="+value.toUpperCase();
		$.get(uri,function(){
			setTimeout(updatePorts,1000);
			}
		);	
	});
});

