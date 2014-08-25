include_script("/scripts/jquery.optionTree.js");

$(function($) {
	$('input[name=command]').optionTree(option_tree);
	$('input[name=command]').hide();
});


