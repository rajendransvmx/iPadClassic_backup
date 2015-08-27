
(function(){
	SVMX.OrgNamespace = SVMX.getClient().getApplicationParameter("org-name-space") || "SVMXC";
	
	var instImpl = SVMX.Package("com.servicemax.client.installigence.admin.impl");

	instImpl.Class("Module", com.servicemax.client.lib.api.ModuleActivator, {
		__constructor : function(){
			this.__base();
			//SVMX.orgNamespace = S
		},

		afterInitialize : function(){
			
		},
		
		beforeInitialize: function() {
			com.servicemax.client.installigence.admin.root.init();
			com.servicemax.client.installigence.admin.filters.init();
			com.servicemax.client.installigence.admin.useractions.init();
			com.servicemax.client.installigence.admin.datavalidationrules.init();
			com.servicemax.client.installigence.admin.producttemplates.init();
			com.servicemax.client.installigence.admin.othersettings.init();
			com.servicemax.client.installigence.admin.commands.init();
			com.servicemax.client.installigence.admin.operations.init();
			com.servicemax.client.installigence.admin.celleditors.init();
			com.servicemax.client.installigence.admin.objectsearch.init();
		},

		registerForSALEvents : function(serviceCall, operationObj){
			if(!operationObj){
				SVMX.getLoggingService().getLogger().warn("registerForSALEvents was invoked without operationObj!");
			}

			serviceCall.bind("REQUEST_ERROR", function(errEvt){

				// unblock the UI if is blocked
				var currentApp = operationObj ? operationObj.getEventBus() : SVMX.getCurrentApplication();
				//var de = operationObj ? operationObj.getEventBus().getDeliveryEngine() : null;
				var evt = SVMX.create("com.servicemax.client.lib.api.Event",
					"SFMDELIVERY.CHANGE_APP_STATE", this, {request : {state : "unblock"}, responder : {}});
				currentApp.triggerEvent(evt);
				var message = "Custom Tag ";
 				try{ message  += "::" + errEvt.data.xhr.statusText + "=>" + errEvt.data.xhr.responseText; }catch(e){}
 				// notify about the error
				evt = SVMX.create("com.servicemax.client.lib.api.Event",
					"SFMDELIVERY.NOTIFY_APP_ERROR", this, {request : {message : message }, responder : {}});
 				currentApp.triggerEvent(evt);

				//this.__logger.error(message);
			}, this);
		},
		
		createServiceRequest : function(params, operationObj){
			var servDef = SVMX.getClient().getServiceRegistry().getService("com.servicemax.client.sal.service.factory");
			servDef.getInstanceAsync({handler : function(service){
				var options = params.options || {};
				var p = {type : options.type || "REST", endPoint : options.endPoint || "",
									nameSpace : "SVMXDEV"};
				var sm = service.createServiceManager(p);
				var sRequest = sm.createService();
				this.registerForSALEvents(sRequest, operationObj);
				params.handler.call(params.context, sRequest);
			}, context:this });
		},
		
		checkResponseStatus : function(operation, data, hideQuickMessage, operationObj){

			if(!operationObj){
				SVMX.getLoggingService().getLogger().warn("checkResponseStatus was invoked without operationObj!");
			}

			var ret = true, message = "", msgDetail = "";

			// the success attributes are available in the response from ServiceMax APEX services
			if(data){
				if(data.response && (data.response.success === false || data.response.success === "false")){
					ret = false;

					// user friendly data
					if(data.response.msgDetails && data.response.msgDetails.message){
						message = data.response.msgDetails.message;
						msgDetail = data.response.msgDetails.details;
					}else{
						message = data.response.message;
					}
				}else if(data.success === false || data.success === "false"){
					ret = false;

					// user friendly data
					if(data.msgDetails && data.msgDetails.message){
						message = data.msgDetails.message;
						msgDetail = data.msgDetails.details;
					}else{
						message = data.message;
					}
				}
			}

			var currentApp = operationObj ? operationObj.getEventBus() : SVMX.getCurrentApplication(), evt;
			if(ret == false){
				// unblock the UI if is blocked
				evt = SVMX.create("com.servicemax.client.lib.api.Event",
					"SFMDELIVERY.CHANGE_APP_STATE", this, {
						request : {state : "unblock"}, responder : {}});
				currentApp.triggerEvent(evt);

					// notify about the error
				evt = SVMX.create("com.servicemax.client.lib.api.Event",
					"SFMDELIVERY.NOTIFY_APP_ERROR", this, {
						request : {
							message : message,
							msgDetail : msgDetail
						},
						responder : {}});
				currentApp.triggerEvent(evt);
				var TS = SVMX.getClient().getServiceRegistry().getServiceInstance("com.servicemax.client.translation").getDictionary("SFMDELIVERY");
				this.__logger.error(operation + " : " + TS.T("TAG035") + " " + message);
			}else if(!hideQuickMessage){
				var quickMessage = null, quickMessageType = null;
				if(data.response && data.response.message){
					quickMessage = data.response.message;
					quickMessageType = data.response.messageType;
				}else if(data.message){
					quickMessage = data.message;
					quickMessageType = data.messageType;
				}

				if(quickMessage && typeof(quickMessage) == 'string'){
					evt = SVMX.create("com.servicemax.client.lib.api.Event",
					"SFMDELIVERY.NOTIFY_QUICK_MESSAGE", this, {
						request : {
							message : quickMessage,
							type : quickMessageType
						},
						responder : {}});
					currentApp.triggerEvent(evt);
				}
			}

			return ret;
		}
		
	}, {instance : null});
	
	instImpl.Class("InstalligenceAdminEventBus", com.servicemax.client.lib.api.EventDispatcher, {
		__constructor : function(){ this.__base(); },
		
		triggerEvent : function(e) {
			return this.__base(e);
		}
		
	}, {});
	
	
	
})();