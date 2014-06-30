include_script("/scripts/jquery.optionTree.js");

function init_form(){
	$('input[name=command]').optionTree(option_tree);
	$('input[name=command]').hide();
}


