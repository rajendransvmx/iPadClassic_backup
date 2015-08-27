/**
 * This file needs a description 
 * @class com.servicemax.client.runtime.constants
 * @singleton
 * @author unknown 
 * 
 * @copyright 2013 ServiceMax, Inc. 
 */
(function(){
	
	var constantsImpl = SVMX.Package("com.servicemax.client.runtime.constants");

	constantsImpl.Class("Constants", com.servicemax.client.lib.api.Object, {
		__constructor : function(){}
	}, {
		PREF_KEY_THEME : "CURRENT-THEME"
	});
	
})();

// end of file
