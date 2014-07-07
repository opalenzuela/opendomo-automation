
jQuery(function($) {
	updatePorts();
});

var portdata;
function updatePorts()
{
	var url= "/data/odauto.json";
	var list = document.getElementById("listControlPorts");
	portdata = loadJSON(url);
	list.innerHTML = "";
	for(var i=0;i<portdata.ports.length;i++) {
		var p = portdata.ports[i];
		if (p.Value && p.Value !="") {
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
		}
	}
}

function loadJSON(filePath) {
  // Load json file;
  var json = loadTextFileAjaxSync(filePath, "application/json");
  // Parse json
  return JSON.parse(json);
}   

// Load text with Ajax synchronously: takes path to file and optional MIME type
function loadTextFileAjaxSync(filePath, mimeType)
{
  var xmlhttp=new XMLHttpRequest();
  xmlhttp.open("GET",filePath,false);
  if (mimeType != null) {
    if (xmlhttp.overrideMimeType) {
      xmlhttp.overrideMimeType(mimeType);
    }
  }
  xmlhttp.send();
  if (xmlhttp.status==200)
  {
    return xmlhttp.responseText;
  }
  else {
    // TODO Throw exception
    return null;
  }
}




