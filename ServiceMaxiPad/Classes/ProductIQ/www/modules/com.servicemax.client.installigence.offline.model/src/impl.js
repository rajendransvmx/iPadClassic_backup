/**
 * 
 */

(function(){
	var modelImpl = SVMX.Package("com.servicemax.client.installigence.offline.model.impl");
	
	modelImpl.Class("Module", com.servicemax.client.lib.api.ModuleActivator, {
		__constructor : function(){
			this.__base();
		},

		initialize : function(){
			com.servicemax.client.installigence.offline.model.operations.init();
		},
		
		beforeInitialize : function(){
			com.servicemax.client.installigence.offline.sal.model.nativeservice.init();
		}
	}, {});
	
})();

// end of file