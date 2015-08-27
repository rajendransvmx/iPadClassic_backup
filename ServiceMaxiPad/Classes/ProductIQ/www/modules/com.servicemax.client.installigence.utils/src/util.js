/**
 * 
 */

(function(){
	
	var instUtils = SVMX.Package("com.servicemax.client.installigence.utils.impl");
	
	instUtils.Class("Util", com.servicemax.client.lib.api.Object, {}, {
		
		guid : function(){
		    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
		        var r = Math.random()*16|0, v = c === 'x' ? r : (r&0x3|0x8);
		        return v.toString(16);
		    });
		}
	});
	
})();

// end of file