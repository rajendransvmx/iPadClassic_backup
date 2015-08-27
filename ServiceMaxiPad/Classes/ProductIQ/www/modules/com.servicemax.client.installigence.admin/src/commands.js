/**
 * This file needs a description 
 * @class com.servicemax.client.sfmopdocdelivery.commands
 * @singleton
 * @author unknown 
 * 
 * @copyright 2013 ServiceMax, Inc. 
 */

(function(){
	var installigenceadmincommands = SVMX.Package("com.servicemax.client.installigence.admin.commands");
	
installigenceadmincommands.init = function(){
	
	installigenceadmincommands.Class("GetSetupMetadata", com.servicemax.client.mvc.api.CommandWithResponder, {
		__cbContext : null,
		__constructor : function(){ this.__base(); },
		
		executeAsync : function(request, responder){
			this.__cbContext = request.context;
			this._executeOperationAsync(request, this, {operationId : "INSTALLIGENCEADMIN.GET_SETUP_METADATA"});
		},
	
		result : function(data) { 
			this.__cbContext.onGetSetupMetadataComplete(data);
		}
		
	},{});
	
	installigenceadmincommands.Class("SaveSetupData", com.servicemax.client.mvc.api.CommandWithResponder, {
		__cbContext : null,
		__constructor : function(){ this.__base(); },
		
		executeAsync : function(request, responder){
			this.__cbContext = request.context;
			this._executeOperationAsync(request, this, {operationId : "INSTALLIGENCEADMIN.SAVE_SETUP_DATA"});
		},
	
		result : function(data) { 
			this.__cbContext.onSaveSetupDataComplete(data);
		}
		
	},{});
	
	installigenceadmincommands.Class("GetTopLevelIBs", com.servicemax.client.mvc.api.CommandWithResponder, {
		__cbContext : null,
		__constructor : function(){ this.__base(); },
		
		executeAsync : function(request, responder){
			this.__cbContext = request.context;
			this._executeOperationAsync(request, this, {operationId : "INSTALLIGENCEADMIN.FIND_TOPLEVEL_IBS"});
		},
	
		result : function(data) { 
			this.__cbContext.__findComplete(data);
		}
		
	},{});
	
	installigenceadmincommands.Class("GetTemplateFromIB", com.servicemax.client.mvc.api.CommandWithResponder, {
		__cbContext : null,
		__constructor : function(){ this.__base(); },
		
		executeAsync : function(request, responder){
			this.__cbContext = request.context;
			this._executeOperationAsync(request, this, {operationId : "INSTALLIGENCEADMIN.GET_TEMPLATE_FROM_IB"});
		},
	
		result : function(data) { 
			this.__cbContext.GetTemplateFromIBComplete(data);
		}
		
	},{});
	
};
})();

// end of file