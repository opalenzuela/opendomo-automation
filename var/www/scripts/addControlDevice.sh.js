var repositoryURL="https://github.com/opalenzuela/opendomo-automation/";
$(function(){
	$("#type").on("change",function() {
		switch($(this).val()){
			case "odcontrol2":
				$("#username").val("user").prop("disabled",true);
				$("#password_li, #username_li").show();
				break;
			case "odcontrol":
				$("#username").val("admin").prop("disabled",true);
				$("#password_li, #username_li").show();
				break;
			case "domino":
				$("#password_li, #username_li").hide();
				break;
			default:
				$("#username").prop("disabled",false);
				$("#password_li, #username_li").show();
			
		};
	});
});