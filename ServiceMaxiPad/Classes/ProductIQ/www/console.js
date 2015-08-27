(function(){
	//var c = window.console; // backup
 
	function log(type, message){
		BRIDGE.invoke("Console", "log", {type : type, message : message});
	}
 
 	console.info = function(message) { log("INFO", message); };
	console.log = function(message) { log("LOG", message); };
	console.error = function(message) { log("ERROR", message); };
	console.warn = function(message) { log("WARN", message); };
	console.debug = function(message) { log("DEBUG", message); };
 
})();