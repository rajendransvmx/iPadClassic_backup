
(function(){
	
	var instUtils = SVMX.Package("com.servicemax.client.installigence.utils.impl");

	instUtils.Class("Module", com.servicemax.client.lib.api.ModuleActivator, {
		__constructor : function(){
			this.__base();
		},

		initialize : function(){
			com.servicemax.client.installigence.utils.commands.init();
		},
		
		afterInitialize : function(){
			
		}
	}, {});
})();