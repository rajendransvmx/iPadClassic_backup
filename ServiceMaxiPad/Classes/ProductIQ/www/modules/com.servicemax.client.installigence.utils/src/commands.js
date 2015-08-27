/**
 * 
 */

(function(){
	
    var commandsImpl = SVMX.Package("com.servicemax.client.installigence.utils.commands");
    
commandsImpl.init = function(){
    
    commandsImpl.Class("GetTranslations", com.servicemax.client.mvc.api.CommandWithResponder, {
    	__cbContext : null, __params : null, __cbHandler : null,
        __constructor : function(){ this.__base(); },
        
        executeAsync : function(request, responder){
        	this.__cbContext = request.context;
			this.__cbHandler = request.handler;
			this.__params = request.params;
            this._executeOperationAsync(request, this, {operationId : "INSTALLIGENCE.GET_TRANSLATIONS"});
        },
    
        result : function(data) { 
        	this.__cbHandler.call(this.__cbContext, data, this.__params);
        }
        
    },{});
};

})();

// end of file