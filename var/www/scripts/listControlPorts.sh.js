
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
							li.find("a").attr("class",p.Value.toLowerCase());
							break;
						case "AI":
							li.find("p").innerHTML =  parseFloat(p.Value);
							break;
						case "AO":
							li.find("input").val(parseFloat(p.Value));
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
							li.className="DO " + p.Tag;
							//li.setAttribute("value",p.Value=="ON"?"OFF":"ON");
							li.onclick = function() {
								var value = $(this).find("a").attr("class");
								var uri = "/cgi-bin/od.cgi/listControlPorts.sh?port="+this.title+"&value="+(value=="on"?"OFF":"ON");
								$.get(uri,function(){
									setTimeout(updatePorts,1000);
									}
								);
							}
							li.innerHTML="<label>"+p.Name+ "</label><p><a class='" + p.Value.toLowerCase() + "'> </a></p>";
							break;
							
						case "DI":
							li.className="DI " + p.Tag;
							//li.setAttribute("value",p.Value=="ON"?"OFF":"ON");
							li.innerHTML="<label>"+p.Name+ "</label><p><a class='" + p.Value.toLowerCase() + "'> </a></p>";
							break;
							
						case "AI":
							li.className="AI " + p.Tag;
							li.innerHTML = "<label>"+p.Name+ "</label><p class='ro'>" + parseFloat(p.Value) + "</p>";
							break;
							
						case "AO":
							li.className="AO " + p.Tag;
							li.innerHTML = "<label>"+p.Name+ "</label><p class='AO' id='"+p.Name+"_cont'>" + 
								"<input class='preview' type='text' pattern='[0-9]' id='" + p.Name + "_disp' value='" + p.Value+ "' size='3'>" +
								"<input class='range' name='" + p.Id + "' type='range' id='"+ p.Name + "' step='10' min='0' max='100' value='" + p.Value+ "' ></p>";
							
							var rng = document.getElementById(p.Name);
							rng.onchange = function() {
								var uri = "/cgi-bin/od.cgi/listControlPorts.sh?port="+this.name +"&value="+this.value;
								$("#" + this.id + "_disp").val(this.value);
								$.get(uri,function(){
									setTimeout(updatePorts,1000);
									}
								);
							}							
							break;
							
						case "TXT":
							li.className="TXT " + p.Tag;
							li.innerHTML="<label>"+p.Name+ "</label><p class='ro'>" + p.Value + "</p>";
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
