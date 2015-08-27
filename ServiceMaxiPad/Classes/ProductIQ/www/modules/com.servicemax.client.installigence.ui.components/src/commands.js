(function(){
	var uicomponentscommands = SVMX.Package("com.servicemax.client.installigence.ui.components.commands");
	
uicomponentscommands.init = function(){
	
	uicomponentscommands.Class("GetLookupData", com.servicemax.client.mvc.api.CommandWithResponder, {
		__cbContext : null,
		__constructor : function(){ this.__base(); },
		
		executeAsync : function(request, responder){
			this.__cbContext = request.context;
			this._executeOperationAsync(request, this, {operationId : "UICOMPONENTS.GET_LOOKUP_DATA"});
		},
	
		result : function(data) { 
			this.__cbContext.onGetLookupDataComplete(data);
		}
		
	},{});
	
};
})();

// end of file