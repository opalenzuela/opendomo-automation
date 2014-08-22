
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
		list.innerHTML = "";
		for(var i=0;i<portdata.ports.length;i++) {
			var p = portdata.ports[i];
			if ((p.Value) && (p.Value !="") && (p.Name.indexOf("$")==-1)) {
				switch(p.Type.substr(0,2)) {
					case "Dv":
					case "DV":
					case "DO":
						var li = document.createElement("li");
						li.setAttribute("title",p.Id);
						li.className="subcommand";
						li.setAttribute("value",p.Value=="ON"?"OFF":"ON");
						li.onclick = function() {
							var uri = "/cgi-bin/od.cgi/listControlPorts.sh?port="+this.title+"&value="+this.getAttribute("value");
							$.get(uri,function(){
								setTimeout(updatePorts,1000);
								}
							);
						}
						li.innerHTML="<label>"+p.Name+ "</label><p class='DO " + p.Value.toLowerCase() + "'><a class='sw-" + p.Value.toLowerCase() + "'> </a></p>";
						list.appendChild(li);
						break;
					case "DI":
						var li = document.createElement("li");
						li.setAttribute("title",p.Id);
						li.className="DI";
						li.setAttribute("value",p.Value=="ON"?"OFF":"ON");
						li.innerHTML="<label>"+p.Name+ "</label><p class='DI " + p.Value.toLowerCase() + "'><a class='sw-" + p.Value.toLowerCase() + "'> </a></p>";
						list.appendChild(li);				
						break;
					case "AI":
						var li = document.createElement("li");
						li.setAttribute("title",p.Id);
						li.className="subcommand";
						li.setAttribute("value",p.Value=="ON"?"OFF":"ON");
						li.innerHTML="<label>"+p.Name+ "</label><p class='ro'>" + parseFloat(p.Value) + "</p>";
						list.appendChild(li);				
						break;
					case "AO":
						var rng = document.createElement("input");
						rng.setAttribute("type","range");
						rng.setAttribute("title",p.Id);
						rng.setAttribute("name",p.Name);
						rng.className="range";
						rng.value =  p.Value;
						var li = document.createElement("li");
						
						rng.onchange = function() {
							var uri = "/cgi-bin/od.cgi/listControlPorts.sh?port="+this.title+"&value="+this.getAttribute("value");
							$.get(uri,function(){
								setTimeout(updatePorts,1000);
								}
							);
						}
						li.innerHTML="<label>"+p.Name+ "</label><p class='AO' id='"+p.Name+"_cont'></p>";
						list.appendChild(li);
						var c = document.getElementById(p.Name+"_cont");
						c.appendChild(rng);
						break;
					case "TXT":
						case "AI":
						var li = document.createElement("li");
						li.innerHTML="<label>"+p.Name+ "</label><p class='ro'>" + p.Value + "</p>";
						list.appendChild(li);				
						break;
				}
			}
		}
	}
}

setInterval(updatePorts,5000);
