
(function(){
	    var appImpl = SVMX.Package("com.servicemax.client.installigence.app");
	    
    appImpl.Class("Application", com.servicemax.client.lib.api.AbstractApplication,{
        __rootContainer : null,
        __rootModel : null, __spinner : null, __pendingMessage : null,
        
        __constructor : function(){
        		
        },
        
        __onAppLaunched: function(evt) {
            var me = this;
            
            var nativeService = com.servicemax.client.installigence.offline.sal.model.nativeservice.Facade;
            var req = nativeService.createSetExternalHandlerRequest();
            req.bind("REQUEST_COMPLETED", function(evt) {
                
            });
            req.bind("REQUEST_ERROR", function(evt) {
                
            });
            req.execute({
                handler: "window.externalRequestHandler",
            });            
            
            window.externalRequestHandler = function(data) {
            	SVMX.getCurrentApplication().setPendingMessage(data);
            	var evt = SVMX.create("com.servicemax.client.lib.api.Event", "EXTERNAL_MESSAGE", this, data);
            	SVMX.getClient().triggerEvent(evt);            	
            };
        },
        
        setPendingMessage: function(message){
        	this.__pendingMessage = message;
        },
        
        getPendingMessage: function(){
        	return this.__pendingMessage;
        },
        
        emptyPendingMessage: function(){
        	this.__pendingMessage = null;
        },
        
        run : function(){
            var ni = SVMX.getClient().getServiceRegistry().getService("com.servicemax.client.niservice").getInstance();
            
            var me = this; 
            
            // create the named default controller
            ni.createNamedInstanceAsync("CONTROLLER",{ handler : function(controller){

                // now create the named default model
                ni.createNamedInstanceAsync("MODEL",{ handler : function(model){
                    controller.setModel(model);
                    this.runInternal();
                }, context : this});

            }, context : this, additionalParams : { eventBus : com.servicemax.client.installigence.impl.EventBus.getInstance() }});
        },
        
        runInternal : function(){
        	
        	this.__onAppLaunched();
            // register for sync events
            var syncService = SVMX.getClient().getServiceRegistry()
            .getService("com.servicemax.client.installigence.sync").getInstance();
            syncService.bind("SYNC.STATUS", function(evt){
                var status = evt.data.type;
                var message = evt.data.msg;
                var syncType = evt.data.syncType;
                SVMX.getLoggingService().getLogger().info("SYNC.STATUS: " + status + " " + message);
                
                if(status === "start" && 
                    (syncType === "initial" || syncType === "reset" || syncType === "ib")){
                    this.__handleSyncSetupStarted(evt.data);
                }else if(status === "canceled"){
                    this.__handleSyncCanceled(evt.data);
                }else if(status === "complete"){
                    this.__handleSyncCompleted(evt.data);
                    if(syncType === "incremental"){
                        this.__checkSyncConflicts();
                    }
                }
            }, this);
            // end sync events

            // setup translation
            this.blockUI();
            var me = this;

            var translationService = SVMX.getClient().getServiceRegistry()
            .getService("com.servicemax.client.installigence.translation").getInstance();
            translationService.refresh().done(function(){
                // setup the global $TR           	
                window.$TR = translationService;
                me.unblockUI();
                me.setup();
            });
        },
        
        __clearLocks : function(params){
        	var updatedRecs = params.state ? params.state.updated : undefined;
        	if(updatedRecs) {
        		
        		var recordIds = [];
        		for(var obj in updatedRecs){
        			if(updatedRecs[obj]){
        				recordIds = recordIds.concat(updatedRecs[obj]);
        			}
        		}        		
        		var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                        "INSTALLIGENCE.EXECUTE_API", this, {request : {context : this, recordIds: recordIds, method: "CLEARLOCKS"}});
                com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
        	}        	 
        },

        __checkSyncConflicts : function(){
            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                    "INSTALLIGENCE.GET_SYNC_CONFLICTS", this, {request : {context : this}});
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
        },

        onGetSyncConflictsComplete : function(result){
            if(result && result.length){
                this.__rootContainer.showSyncConflicts();
            }
        },
        
        __handleSyncCompleted : function(params){
            if(params.syncType === "incremental" || params.syncType === "purge"){
                this.hideDataLoading();
                this.__clearLocks(params);
            }else{
                this.unblockUI();
                this.__rootContainer.handleHome({
                    type : "sync_complete",
                    params : params
                });
            }
            
            //clear locks
        },

        __handleSyncCanceled : function(params){
            this.__handleSyncCompleted(params);
        },
        
        __handleSyncSetupStarted : function(params){
            this.__rootContainer.handleProgress(params);
        },
        
        blockUI : function(){
            this.__blockCounter = this.__blockCounter || 0;
            this.__blockCounter++;
            if(this.__spinner){
                // Already blocked
                return;
            }
            var opts = {
                lines: 25, // The number of lines to draw
                length: 25, // The length of each line
                width: 5, // The line thickness
                radius: 30, // The radius of the inner circle
                corners: 1, // Corner roundness (0..1)
                rotate: 0, // The rotation offset
                direction: 1, // 1: clockwise, -1: counterclockwise
                color: '#ffa384', // #rgb or #rrggbb or array of colors
                speed: 3, // Rounds per second
                trail: 60, // Afterglow percentage
                shadow: false, // Whether to render a shadow
                hwaccel: false, // Whether to use hardware acceleration
                className: 'spinner', // The CSS class to assign to the spinner
                zIndex: 2e9 // The z-index (defaults to 2000000000)
            };
            var rootElement = $("#spincenter")[0];
            if(!rootElement){
                $('body').append(
                    '<div id="spincenter" style="position:fixed;top:50%;left:50%;z-index:999999"></div>'
                );
                rootElement = $("#spincenter")[0];
            }
            this.__spinner = new Spinner(opts).spin(rootElement);
        },
        
        unblockUI : function(){
            this.__blockCounter--;
            if(this.__blockCounter > 0){
                return;
            } else {
                this.__blockCounter = 0;
            }
            if(!this.__spinner){
                return;
            }
            var rootElement = $("#" + SVMX.getDisplayRootId())[0];
            rootElement.style.height = 'auto';
            this.__spinner.stop();
            delete this.__spinner;
        },

        showDataLoading : function(){
            var opts = {
                lines: 13, // The number of lines to draw
                length: 6, // The length of each line
                width: 3, // The line thickness
                radius: 7, // The radius of the inner circle
                corners: 1, // Corner roundness (0..1)
                rotate: 0, // The rotation offset
                direction: 1, // 1: clockwise, -1: counterclockwise
                color: '#ffffff', // #rgb or #rrggbb or array of colors
                speed: 3, // Rounds per second
                trail: 60, // Afterglow percentage
                shadow: false, // Whether to render a shadow
                hwaccel: false, // Whether to use hardware acceleration
                className: 'spinner', // The CSS class to assign to the spinner
                zIndex: 2e9 // The z-index (defaults to 2000000000)
            }; 
            $(".logo.img").hide();
            $(".logo.spinner").show();
            this.__dataSpinner = new Spinner(opts).spin($(".logo.spinner")[0]);
        },

        hideDataLoading : function(){
            $(".logo.img").show();
            $(".logo.spinner").hide();
            if(this.__dataSpinner){
                this.__dataSpinner.stop();
            }
        },

        showQuickMessage : function(type, message, options, callback){
            type = type.toLowerCase();
            if(typeof options === 'function'){
                callback = options;
                options = {};
            }
            if(type === "confirm"){
                typeMessage = $TR.MESSAGE_CONFIRM;
                Ext.Msg.confirm(typeMessage, message, callback);
            }else{
                switch(type){
                    case "success":
                        typeMessage = $TR.MESSAGE_SUCCESS;
                        break;
                    case "error":
                        typeMessage = $TR.MESSAGE_ERROR;
                        break;
                    case "info":
                    // TODO: add more types as needed
                    default:
                        typeMessage = $TR.MESSAGE_INFO;
                        break;
                }
                Ext.Msg.alert(typeMessage, message);
            }
        },

        /**
         * Show a connection warning. There is an intermittent connection.
         *
         */
        showConnectionWarningDialog : function(params){
            var me = this;

            Ext.Msg.buttonText.ok = "Continue";
            Ext.Msg.buttonText.cancel = "Cancel";

            $("#spincenter").hide();
            Ext.Msg.show({
                title : "Connection Warning",
                msg : "Poor connectivity detected. Please continue when internet connectivity has improved.",
                buttons : Ext.Msg.OKCANCEL,
                fn : SVMX.proxy(
                    me,
                    function(buttonId) {
                        $("#spincenter").show();
                        if(buttonId === "ok"){
                            params.onRetry && params.onRetry();
                        }else{
                            params.onCancel && params.onCancel();
                        }
                    }
                )
            });

            // Reset button text
            Ext.Msg.buttonText.ok = "OK";
        },

        /**
         * Show a connection failure notification. Sync was not able to connect to network.
         *
         */
        showConnectionErrorDialog : function(params){
            var me = this;

            Ext.Msg.buttonText.ok = "Retry";
            Ext.Msg.buttonText.cancel = "Cancel";

            $("#spincenter").hide();
            this.__connectionMsg = Ext.Msg.show({
                title : "Connection Error",
                msg : "Internet connectivity lost. Please retry when connectivity is available.",
                buttons : Ext.Msg.OKCANCEL,
                fn : SVMX.proxy(
                    me,
                    function(buttonId) {
                        $("#spincenter").show();
                        if(buttonId === "ok"){
                            params.onRetry && params.onRetry();
                        }else{
                            params.onCancel && params.onCancel();
                        }
                    }
                )
            });

            // Reset button text
            Ext.Msg.buttonText.ok = "OK";
        },

        /**
         * Show a request failure notification. Server returned an error repeatedly.
         *
         */
        showRequestErrorDialog : function(params){
            var me = this;
			var message;
            if(params.errorMessage){
                message = params.errorMessage;
            }else{
                message = "The server is unable to complete your request.";
            }
            Ext.Msg.buttonText.ok = "Retry";
            Ext.Msg.buttonText.cancel = "Cancel";

            $("#spincenter").hide();
            this.__connectionMsg = Ext.Msg.show({
                title : "Server Error",
                msg : message,
                buttons : Ext.Msg.OKCANCEL,
                fn : SVMX.proxy(
                    me,
                    function(buttonId) {
                        $("#spincenter").show();
                        if(buttonId === "ok"){
                            params.onRetry && params.onRetry();
                        }else{
                            params.onCancel && params.onCancel();
                        }
                    }
                )
            });

            // Reset button text
            Ext.Msg.buttonText.ok = "OK";
        },
        
        getSearchResultsLimit : function(){
            return 250; // TODO: move to configuration
        },
        
        getAppFocus : function(){
        	var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                    "INSTALLIGENCE.GET_APP_FOCUS", this, {request : {}});
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
        },

        updateDependentRecords: function(data){
            var mapRecordIds = data.mapRecordIds;
            var lstLocalRecIds = [];
            for(var localId in mapRecordIds){
                lstLocalRecIds.push(localId);
            }

            var queryObj = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            queryObj.select("parent_object_name, local_id, parent_record_id, parent_field_name").from("SyncDependentLog")
            .where("local_id").within(lstLocalRecIds).execute()
            .done(SVMX.proxy(this, function(resp){
                if(resp && resp.length > 0){
                    var count = resp.length;
                    for(var i=0; i<resp.length; i++){
                        this.updateParentRecord(resp[i], mapRecordIds, function(){
                            count--;
                            if(!count){
                                // Call the sync.
                                this.getRootContainer().handleIncrementalSync();
                            }
                        });
                    }
                }

            }));
        },

        errorFromMFL: function(error){
            var errorType = error.type;
            var messageType;

            if(errorType === 'SYNC_PAUSED' || errorType === 'REQUEST_REJECTED')
                messageType = $TR.MESSAGE_INFO;
            else if(errorType === 'SYNC_FAILED')
                messageType = $TR.MESSAGE_ERROR;

            Ext.Msg.alert(messageType, error.message);
        },

        getRootContainer: function(){
            return this.__rootContainer;
        },

        updateParentRecord: function(record, mapRecordIds, callback){
            var updateSet = record["parent_field_name"] + " = '" + mapRecordIds[record["local_id"]] + "'";
            var tableName = record["parent_object_name"];
            var whereCondition = "Id = '" + record["parent_record_id"] + "'";
            var queryObjUpdate = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            queryObjUpdate.update(tableName)
            .setValue(updateSet);
            queryObjUpdate.where(whereCondition).execute()
            .done(SVMX.proxy(this, function(resp){
                this.deleteDependentLogEntry(record, callback);
            }));
        },
        
        deleteDependentLogEntry: function(record, callback){
            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            qo.deleteFrom("SyncDependentLog")
            .where("parent_field_name").equals(record["parent_field_name"])
            .where("parent_record_id").equals(record["parent_record_id"])
            .execute().done(function(){
                callback.call(this);
            });
        },

        externalMessage: function(edata){
            var data = SVMX.toObject(edata);
            if(data.action === "SYNC" && data.operation === "INCREMENTAL" && !(data.data && data.data.error)){
                me.getRootContainer().handleIncrementalSync();

            }

            if(data.action === "SYNC" && data.operation === "INSERT_LOCAL_RECORDS"){
               if(data.type === "REQUEST") {
                   console.log("REQUEST");
               }else if(data.type === "RESPONSE") {
                    data = data.data;
                    if(data.error){
                        this.errorFromMFL(data.error);
                    }else{
                        this.updateDependentRecords(data);    
                    }
               }
           }
        },

        
        setup : function(){
            this.__rootModel = SVMX.create("com.servicemax.client.installigence.metamodel.Root");
            this.__rootContainer = SVMX.create('com.servicemax.client.installigence.root.Root', { meta : this.__rootModel });
            
            SVMX.getClient().bind("EXTERNAL_MESSAGE", function(evt){
                this.externalMessage(evt.data);
            }, this);
            
            
            SVMX.onWindowResize(function(size){
                this.__rootContainer.setHeight(size.height - 40);
                this.__rootContainer.doLayout();
            }, this);
            
            var me = this;
            SVMX.doLater(function(){
                me.__rootContainer.doLayout();

                //for integrated app sync is handled by the launchig app.
                if(SVMX.appType === 'integrated'){
                    me.__rootContainer.handleHome({type : "initialize"});
                    me.__rootModel.initialize();
                    return;
                }

                // navigate to find and get if this is the first time
                var pendingMessage = SVMX.getCurrentApplication().getPendingMessage();
                if(pendingMessage !== null){
                	pendingMessage = SVMX.toObject(pendingMessage);                	          	
                }
                
                var syncService = SVMX.getClient().getServiceRegistry()
                .getService("com.servicemax.client.installigence.sync").getInstance();
                
                syncService.getLastConfigSyncDetails(me)
                .done(function(){
                    syncService.hasUserChanged().done(function(result){
                        if(result){
                            me.__rootContainer.handleFindAndGet({syncType : "initial"});
                        }else if(pendingMessage !== null && pendingMessage.action === "SYNC" && pendingMessage.operation === "INCREMENTAL"){
                    		me.__rootContainer.handleIncrementalSync();
                    		SVMX.getCurrentApplication().emptyPendingMessage();
                    	}else {
                            // sync is complete and user has not changed
                            me.__rootContainer.handleHome({type : "initialize"});
                            me.__rootModel.initialize();
                        }
                    });
                })
                .fail(function(){
                    me.__rootContainer.handleFindAndGet({syncType : "initial"});
                });
                // end navigate
                
            });
        }
        
    },{});
})();