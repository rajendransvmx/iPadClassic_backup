/**
 * 
 */

(function(){
	
	var syncImpl = SVMX.Package("com.servicemax.client.installigence.sync.impl");
	
	syncImpl.Class("Module", com.servicemax.client.lib.api.ModuleActivator, {
		__constructor : function(){
			this.__base();
			
			SVMX.getTempTableName = function(name){ return "TEMP__" + name; };
		},
		
		beforeInitialize : function(){
			com.servicemax.client.installigence.sync.service.impl.init();
		}
	}, {});
})();

// end of file