var repositoryURL="https://github.com/opalenzuela/opendomo-automation/";
include_script("/scripts/jquery.optionTree.js");
include_script("/scripts/vendor/jquery.optionTree.js");

$(function(){
	setTimeout(function(){
		$('input[name=command]').optionTree(option_tree);
		$('input[name=command]').hide();
	},1000);
});


