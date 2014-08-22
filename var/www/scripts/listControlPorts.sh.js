
jQuery(function($) {
	updatePorts();
});

var portdata;
function updatePorts()
{
	var url= "/data/odauto.json";
	var list = document.getElementById("listControlPorts");
	portdata = loadJSON(url);
	if (portdata) {
		// Only if "loading" is visible, we clear it
		if (document.getElementById("loading_li")) list.innerHTML = "";
		
		for(var i=0;i<portdata.ports.length;i++) {
			var p = portdata.ports[i];
			var li = $("[title='" + p.Id+ "']");
			if (li.length==1) { // It already exists. Just update value if required
				if ((p.Value) && (p.Value !="") && (p.Name.indexOf("$")==-1)) {
					switch(p.Type.toUpperCase()) {
						case "DV":
						case "DO":
						case "DI":
							li.find("a").attr("class","sw-"+p.Value.toLowerCase());
							break;
						case "AI":
							li.find("p").innerHTML =  parseFloat(p.Value);
							break;
						case "AO":
							li.find("input").attr("value",p.Value);
							li.trigger("change");
							break;
						case "TXT":							
							li.find("p").innerHTML =  p.Value;
							break;
					}
				}
			} else {  // It does not exists, we create it:	
				if ((p.Value) && (p.Value !="") && (p.Name.indexOf("$")==-1)) {
					
					var li = document.createElement("li");
					li.setAttribute("title",p.Id);
					list.appendChild(li);
					
					switch(p.Type.toUpperCase()) {
						case "DV":
						case "DO":
							li.className="subcommand";
							li.setAttribute("value",p.Value=="ON"?"OFF":"ON");
							li.onclick = function() {
								var uri = "/cgi-bin/od.cgi/listControlPorts.sh?port="+this.title+"&value="+this.getAttribute("value");
								$.get(uri,function(){
									setTimeout(updatePorts,1000);
									}
								);
							}
							li.html("<label>"+p.Name+ "</label><p class='DO " + p.Value.toLowerCase() + "'><a class='sw-" + p.Value.toLowerCase() + "'> </a></p>");
							break;
							
						case "DI":
							li.className="DI";
							li.setAttribute("value",p.Value=="ON"?"OFF":"ON");
							li.html("<label>"+p.Name+ "</label><p class='DI " + p.Value.toLowerCase() + "'><a class='sw-" + p.Value.toLowerCase() + "'> </a></p>");
							break;
							
						case "AI":
							li.html("<label>"+p.Name+ "</label><p class='ro'>" + parseFloat(p.Value) + "</p>");
							break;
							
						case "AO":
							var rng = document.createElement("input");
							rng.setAttribute("type","range");
							//rng.setAttribute("title",p.Id);
							rng.setAttribute("name",p.Id);
							rng.className="range";
							rng.setAttribute("step","10");
							rng.value =  p.Value;
							var li = document.createElement("li");
							
							rng.onchange = function() {
								var uri = "/cgi-bin/od.cgi/listControlPorts.sh?port="+this.name +"&value="+this.value;
								$.get(uri,function(){
									setTimeout(updatePorts,1000);
									}
								);
							}
							li.html("<label>"+p.Name+ "</label><p class='AO' id='"+p.Name+"_cont'></p>");
							var c = document.getElementById(p.Name+"_cont");
							
							c.appendChild(rng);
							break;
							
						case "TXT":
							li.html("<label>"+p.Name+ "</label><p class='ro'>" + p.Value + "</p>");
							break;
					}
				}
			}
		}
	} else {
		console.log("No port data available");
	}
}

setInterval(updatePorts,5000);
