
(function($){

	window.__SVMX_LOAD_APPLICATION__ = function(options){

		$(document).ready(function(){
			// create the client instance
			var client = new com.servicemax.client.lib.core.Client();
			
			var configType = options.configType ? options.configType : "remote";
			var configData = options.configData ? options.configData : "installigence-config.json";
			client.run({configType : configType, data : configData, loadVersion : options.loadVersion});
		});
	};

})(jQuery);

// end of file