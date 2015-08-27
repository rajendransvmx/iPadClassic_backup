/**
 *
 */

(function(){
 
 var rootImpl = SVMX.Package("com.servicemax.client.installigence.root");
 
 rootImpl.init = function(){
 
 Ext.define("com.servicemax.client.installigence.root.Root", {
            extend: "com.servicemax.client.installigence.ui.components.SVMXPanel",
            alias: 'widget.installigence.root',
            meta : null, home : null, findandget : null, navigationStack : null, progress : null, conflict : null,
            currentView : null,
            
            constructor: function(config) {
            this.meta = config.meta;
            this.navigationStack = [];
            this.home = SVMX.create("com.servicemax.client.installigence.home.Home", { meta : this.meta, root : this });
            this.home.cardIndex = 0;
            if(SVMX.appType !== 'integrated'){
            this.findandget = SVMX.create("com.servicemax.client.installigence.findandget.FindAndGet", { meta : this.meta, root : this });
            this.progress = SVMX.create("com.servicemax.client.installigence.progress.Progress", { meta : this.meta, root : this });
            this.conflict = SVMX.create("com.servicemax.client.installigence.conflict.Conflict", { meta : this.meta, root : this, sourceComponent : this.home.getMenu() });
            
            
            this.findandget.cardIndex = 1;
            this.progress.cardIndex = 2;
            }
            
            
            config = Ext.apply({
                               renderTo: SVMX.getDisplayRootId(),
                               layout : {type : "card"},
                               items : [this.home, this.findandget, this.progress]
                               }, config || {});
            this.callParent([config]);
            
            this.currentView = this.home;
            //once the app loaded invoke LM
            this.invokeLM();
            },
            
            invokeLM : function(){
            var message = {
            action : 'START'
            };
            var evt = SVMX.create("com.servicemax.client.lib.api.Event", "INSTALLIGENCE.SEND_EXTERNAL_MSG",
                                  this, {request : { context : this, message : message, appName : "LaptopMobile"}});
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
            },
            
            invokeLMSync : function(recordIds){
            var message = {
            action : 'SYNC',
            operation: 'INSERT_LOCAL_RECORDS',
            type: 'REQUEST',
            data: { recordIds: recordIds || [] }
            };
            var evt = SVMX.create("com.servicemax.client.lib.api.Event", "INSTALLIGENCE.SEND_EXTERNAL_MSG",
                                  this, {request : { context : this, message : message, appName : "LaptopMobile"}});
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
            },
            
            handleFindAndGet : function(params){
            this.navigationStack.push(this.currentView);
            this.currentView = this.findandget;
            this.getLayout().setActiveItem(this.currentView.cardIndex);
            this.findandget.handleFocus(params);
            },
            
            handleConfigSync : function(params){
            var syncService = SVMX.getClient().getServiceRegistry()
            .getService("com.servicemax.client.installigence.sync").getInstance();
            syncService.start({type : "config"});
            this.handleProgress({syncType : "config"});
            },
            
            handleIncrementalSync : function(params){
            var me = this;
            me.__checkForDependentRecords()
            .done( function(lstLocalRecIds){
                  
                  if(lstLocalRecIds && lstLocalRecIds.length > 0){
                  me.invokeLMSync(lstLocalRecIds);
                  }else{
                  var syncService = SVMX.getClient().getServiceRegistry()
                  .getService("com.servicemax.client.installigence.sync").getInstance();
                  syncService.start({type: "incremental"});
                  me.showDataLoading();
                  }
                  });
            },
            
            handleInsertRecordsSync : function(recordIds){
            var syncService = SVMX.getClient().getServiceRegistry()
            .getService("com.servicemax.client.installigence.sync").getInstance();
            syncService.start({type: "insert_requested", recordIds: recordIds});
            me.showDataLoading();
            },
            
            __checkForDependentRecords: function(){
            var lstLocalRecIds = [];
            var d = SVMX.Deferred();
            var queryObj = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            queryObj.select("local_id").from("SyncDependentLog").execute()
            .done(function(resp){
                  if(resp && resp.length > 0){
                  for(var i=0; i< resp.length; i++){
                  lstLocalRecIds.push(resp[i].local_id);
                  }
                  }
                  d.resolve(lstLocalRecIds);
                  });
            return d;
            },
            
            handlePurgeSync : function(params){
            var me = this;
            var title = "Purge Data" + "?";
            var message = "Purging data may remove locally stored ProductIQ data that has grown over time to ensure only relevant data is stored. This process cannot be undone.";
            com.servicemax.client.installigence.ui.components.utils.Utils
            .confirm({title : title, message : message, buttonText : {yes : "Purge", no : "Cancel"}, handler : function(answer){
                     if(answer == "yes"){
                     var syncService = SVMX.getClient().getServiceRegistry()
                     .getService("com.servicemax.client.installigence.sync").getInstance();
                     syncService.start({type: "purge"});
                     me.showDataLoading();
                     }
                     }});
            },
            
            handleHome : function(params){
            this.currentView = this.home;
            this.getLayout().setActiveItem(this.currentView.cardIndex);
            this.currentView.handleFocus(params);
            },
            
            handleProgress : function(params){
            this.currentView = this.progress;
            this.getLayout().setActiveItem(this.currentView.cardIndex);
            this.currentView.handleFocus(params);
            },
            
            handleNavigateBack : function(){
            this.currentView = this.navigationStack.pop();
            this.getLayout().setActiveItem(this.currentView.cardIndex);
            },
            
            handleResetApplication : function(){
            var me = this;
            var title = $TR.RESET_APPLICATION_TITLE + "?";
            var message = $TR.RESET_APPLICATION_MESSAGE;
            com.servicemax.client.installigence.ui.components.utils.Utils
            .confirm({title : title, message : message, buttonText : {yes : $TR.RESET_YES, no : $TR.RESET_NO}, handler : function(answer){
                     if(answer == "yes"){
                     me.handleFindAndGet({syncType : "reset"});
                     }
                     }});
            },
            
            showSyncConflicts : function(){
            this.conflict.show();
            },
            
            selectTreeNode : function(recordId){
            this.home.selectTreeNode(recordId);
            },
            
            blockUI : function(){
            SVMX.getCurrentApplication().blockUI();
            },
            
            unblockUI : function(){
            SVMX.getCurrentApplication().unblockUI();
            },
            
            showDataLoading : function(){
            SVMX.getCurrentApplication().showDataLoading();
            },
            
            hideDataLoading : function(){
            SVMX.getCurrentApplication().hideDataLoading();
            },
            
            showQuickMessage : function(type, message){
            SVMX.getCurrentApplication().showQuickMessage(type, message);
            }
            });
 
 };
 
 })();

// end of file
