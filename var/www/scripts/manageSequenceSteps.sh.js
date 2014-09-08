include_script("/scripts/jquery.optionTree.js");

$(function($) {
	setTimeout(function(){
		$('input[name=command]').optionTree(option_tree);
		$('input[name=command]').hide();
	},500);
});


