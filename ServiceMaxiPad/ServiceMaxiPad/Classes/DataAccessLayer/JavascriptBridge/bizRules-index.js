
(function($){
 window.__SVMX_LOAD_APPLICATION__ = function(options){
 $(document).ready(function(){
                   // create a console logger
                   new com.servicemax.client.lib.services.BrowserConsoleLogTarget();
                   
                   // create the client instance
                   var client = new com.servicemax.client.lib.core.Client();
                   
                   // set up the application parameters
                   if(options.appParams){
                   var appParams = options.appParams;
                   for(var paramName in appParams){
                   client.addApplicationParameter(paramName, appParams[paramName]);
                   }
                   }
                   
                   
                   
                   // set up the onload callback if there is any.
                   if(options.handler){
                   var handler = options.handler;
                   var context = options.context;
                   client.addApplicationParameter("onappload-handler", {handler : handler, context : context});
                   }
                   var configType = options.configType ? options.configType : "remote";
                   var configData = options.configData ? options.configData : "config.json";
                   client.run({configType : configType, data : configData, loadVersion : options.loadVersion});
                   });
 
 };
 
 })(jQuery);

// end of file