$("#name").on("change",function(){
	var code = $(this).val();
	code = code.replace(/[^a-z]/g,"").replace(/\ /,"");
	$("#code").val(code);
});