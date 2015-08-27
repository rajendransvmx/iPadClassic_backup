/**
 * This file needs a description 
 * @class com.servicemax.client.native.laptop.impl
 * @singleton
 * @author unknown 
 * 
 * @copyright 2013 ServiceMax, Inc. 
 */
(function(){

	var Impl = SVMX.Package("com.servicemax.client.native.laptop.impl");

	Impl.Class("Module", com.servicemax.client.lib.api.ModuleActivator, {

		__constructor : function(){
			this.__base();
		},

		initialize : function(){
			com.servicemax.client.nativeservice.init();
		}
	}, {});
})();