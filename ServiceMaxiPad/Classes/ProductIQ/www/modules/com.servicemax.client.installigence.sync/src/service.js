/**
 * 
 */
(function(){
    var syncServiceImpl = SVMX.Package("com.servicemax.client.installigence.sync.service.impl");

syncServiceImpl.init = function(){

    // sync type enum
    var eSyncType = {
        INITIAL     : "initial",
        IB          : "ib",
        INCREMENTAL : "incremental",
        RESET       : "reset",
        CONFIG      : "config",
        PURGE       : "purge",
        INSERT_REQUESTED : "insert_requested" 
    };
    
    syncServiceImpl.Class("Service", com.servicemax.client.lib.api.EventDispatcher, {
        __listOfDBTables : null, __currentSyncType : null, totalStepCount : 0, __syncState : null, __logger : null,
        
        __constructor : function(){
            this.__listOfDBTables = [];
            this.__logger = SVMX.getLoggingService().getLogger();
        },

        __bindHttpConnectionWatcher : function(){
            var me = this;
            this.onConnectionCanceled = function(){
                SVMX.getLoggingService().getLogger().info("Sync was canceled!");
                me.notify({type : 'canceled', msg : "Sync canceled", syncType : me.__currentSyncType});
            };
            com.servicemax.client.installigence.offline.model.utils.Http
            .onConnectionCanceled(this.onConnectionCanceled);
        },

        __unbindHttpConnectionWatcher : function(){
            com.servicemax.client.installigence.offline.model.utils.Http
            .offConnectionCanceled(this.onConnectionCanceled);
        },
        
        /**
         * {
         *      IBs : []
         * }
         */
        start : function(params){
            if(params == null) return;
            if(params.type) this.__currentSyncType = params.type;
            
            this.__syncState = {
                inserted : {},
                updated : {},
                deleted : {},
                referenced : {},
                conflicted : [],
                insertRecordsMap : []
                
            };

            this.__bindHttpConnectionWatcher();
            
            if(params.type == eSyncType.INITIAL){
                // initial sync
                this.__startInitialSync(params);
            }else if(params.type == eSyncType.RESET){
                // reset sync
                this.__startResetSync(params);
            }else if(params.type == eSyncType.IB){
                // only IBs
                this.__startIBSync(params);
            }else if(params.type == eSyncType.CONFIG){
                // only configuration
                this.__startConfigSync(params);
            }else if(params.type == eSyncType.INCREMENTAL){
                // incremental sync
                this.__startIncrementalSync(params);
            }else if(params.type == eSyncType.PURGE){
                // purge sync
                this.__startPurgeSync(params);
            }else if(params.type == eSyncType.INSERT_REQUESTED){
            	this.__performInsertRecordsSync(params);
            }
        },
        
        __startResetSync : function(params){
            var me = this;
            // update translations
            this.getTranslations(true).done(function(){
                me.__startInitialSync(params);
            });
        },

        __startInitialSync : function(params){
            // TODO: dynamically discover step count vs hardcoded :(
            this.totalStepCount = 8;
            this.notify({
                type : "start",
                msg : "Starting Initial Sync",
                syncType : this.__currentSyncType
            });
            this.__performInitialSync(params, eSyncType.INITIAL);
        },

        __startPurgeSync : function(params){
            // TODO: dynamically discover step count vs hardcoded :(
            this.totalStepCount = 8;
            this.notify({
                type : "start",
                msg : "Starting Data Purge",
                syncType : this.__currentSyncType
            });
            this.__performPurgeSync(params, eSyncType.PURGE);
        },

        __startConfigSync : function(params){
            // TODO: dynamically discover step count vs hardcoded :(
            this.totalStepCount = 2;
            this.notify({
                type : "start",
                msg : "Downloading Configuration",
                syncType : this.__currentSyncType
            });
            this.__performConfigSync(params, eSyncType.CONFIG);
        },
        
        __startIncrementalSync : function(params){
            this.notify({
                type : "start",
                msg : "Starting Data Sync",
                syncType : this.__currentSyncType
            });
            this.__performIncrementalSync(params, eSyncType.INCREMENTAL);
        },
        
        __startIBSync : function(params){
            this.totalStepCount = 3; // hardcoded? :(
            this.notify({type : 'start', msg : "Starting IB sync", syncType : this.__currentSyncType});
            this.__getIBs(params, eSyncType.IB);
        },

        __performInitialSync : function(params, type){
            var me = this;
            var csProvider = SVMX.create("com.servicemax.client.installigence.sync.service.impl.ConfigSyncProvider", {
                service : this
            });
            csProvider.run(params, type)
            .done(function(){
                // continue to get IBs
                this.__getIBs(params, type, csProvider);
            });
        },

        __performPurgeSync : function(params, type){
            var me = this;
            var context = {
                onGetLMTopLevelIBsComplete : function(results) {
                    if (results.length) {
                        me.getSObjectInfo(SVMX.getCustomObjectName("Installed_Product"))
                        .done(function(objectInfo){
                            var allFields = [];
                            var fieldsDesc = {};
                            for(var i = 0; i < objectInfo.fields.length; i++){
                                if(objectInfo.fields[i].name == "Id"){
                                    objectInfo.fields[i].label = "Id";
                                    allFields.push(objectInfo.fields[i].name);
                                    fieldsDesc.Id = objectInfo.fields[i];
                                    break;
                                }
                            }
                            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                                "INSTALLIGENCE.FIND_BY_IB", this, {request : {
                                    context : context,
                                    params : params,
                                    locationIds : results,
                                    fields : allFields,
                                    fieldsDescribe : fieldsDesc
                            }});
                            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
                        });
                    } else {
                        // No locations/IBs
                        params.IBs = [];
                        me.__getIBs(params, type);
                    }
                },
                onSearchByIBComplete : function(results) {
                    if (results.data.length) {
                        params.IBs = results.data.map(function(rec){
                            return rec.Id;
                        });
                    } else {
                        // No IBs
                        params.IBs = [];
                    }
                    me.__getIBs(params, type);
                }
            };
            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                    "INSTALLIGENCE.GET_LM_TOP_LEVEL_IBS", this, {request : { context : context, ids: [], params : this.__params}});
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
        },
        
        __performConfigSync : function(params, type){
            var me = this;
            var csProvider = SVMX.create("com.servicemax.client.installigence.sync.service.impl.ConfigSyncProvider", {
                service : this
            });
            
            csProvider.run(params, type)
            .done(function(){
                me.__finalizeSuccess(params, type, csProvider);
            });
        },

        __performIncrementalSync : function(params, type){
            var me = this;
            var incProvider = SVMX.create("com.servicemax.client.installigence.sync.service.impl.IncrementalSyncProvider", {
                service : this
            });
            incProvider.run(params, type)
            .done(function(){
                me.__unbindHttpConnectionWatcher();
                SVMX.getLoggingService().getLogger().info("Data synced successfully!");
                var notifyParams = {
                    type : "complete", msg : "Sync completed", syncType : me.__currentSyncType,
                    state : me.__syncState
                }
                me.notify(notifyParams);
            });
        },
        
        __performInsertRecordsSync : function(params, type){
        	 var me = this;
             var incProvider = SVMX.create("com.servicemax.client.installigence.sync.service.impl.IncrementalSyncProvider", {
                 service : this
             });
             incProvider.putInsertRequested(params.recordIds)
             .done(function(){
                 me.__unbindHttpConnectionWatcher();
                 SVMX.getLoggingService().getLogger().info("Records inserted successfully!");
                 var notifyParams = {
                     type : "complete", msg : "Sync completed", syncType : me.__currentSyncType,
                     state : me.__syncState
                 }
                 me.notify(notifyParams);
             });
             
        },
        
        __getIBs : function(params, type, provider){
            var me = this;
            var isProvider = SVMX.create("com.servicemax.client.installigence.sync.service.impl.IBSyncProvider", {
                service : this, link : provider
            });
            
            isProvider.run(params, type)
            .done(function(){
                me.__getIBTemplates(params, type, isProvider);
            });
        },

        __getIBTemplates : function(params, type, provider){
            var me = this;
            var isProvider = SVMX.create("com.servicemax.client.installigence.sync.service.impl.IBTemplateSyncProvider", {
                service : this, link : provider
            });
            
            isProvider.run(params, type)
            .done(function(){
                me.__getLocations(params, type, isProvider);
            });
        },
        
        __getLocations : function(params, type, provider){
            var me = this;
            var locProvider = SVMX.create("com.servicemax.client.installigence.sync.service.impl.LocationSyncProvider", {
                service : this, link : provider
            });
            
            locProvider.run(params, type)
            .done(function(){
                me.__getProducts(params, type, locProvider);
            });
        },
        
        __getProducts : function(params, type, provider){
            var me = this;
            var prodProvider = SVMX.create("com.servicemax.client.installigence.sync.service.impl.ProductSyncProvider", {
                service : this, link : provider
            });
            
            prodProvider.run(params, type)
            .done(function(){
                me.__getAccounts(params, type, prodProvider);
            });
        },
        
        __getAccounts : function(params, type, provider){
            var me = this;
            var accProvider = SVMX.create("com.servicemax.client.installigence.sync.service.impl.AccountSyncProvider", {
                service : this, link : provider
            });
            
            accProvider.run(params, type)
            .done(function(){
                me.__getRecordNames(params, type, accProvider);
            });
        },

        __getRecordNames : function(params, type, provider){
            var me = this;
            var recNameProvider = SVMX.create("com.servicemax.client.installigence.sync.service.impl.RecordNameSyncProvider", {
                service : this, link : provider
            });
            
            var syncDate = new Date();
            recNameProvider.run(params, type)
            .done(function(){
                me.__finalizeSuccess(params, type, recNameProvider);
            });
        },

        __finalizeSuccess : function(params, type, provider){
            var me = this;
            var syncDate = new Date();
            // success!
            provider.cleanup().done(function(){
                if(type === eSyncType.INITIAL || type === eSyncType.RESET){
                    me.__updateLastDataSyncTime(syncDate);
                }
                if(type === eSyncType.INITIAL || type === eSyncType.RESET || type === eSyncType.CONFIG){
                    me.__updateLastConfigSyncTime(syncDate);
                }
                me.__updateLoggedInUserInfoInCache();
                me.__unbindHttpConnectionWatcher();
                var notifyParams = {
                    type : "complete",
                    msg : "Sync completed",
                    syncType : me.__currentSyncType
                };
                me.notify(notifyParams);
            });
        },
        
        hasUserChanged : function(){
            var d = SVMX.Deferred(), me = this;
            var qo = this.getQueryObject();
            qo.select("*").from("ClientCache").where("Key = 'UserInfo'")
            .execute().done(function(resp){
                if(resp && resp.length > 0){
                    me.__getLoggedInUserInfo().done(function(info){
                        d.resolve(info.UserName != SVMX.toObject(resp[0].Value).UserName);
                    });
                }else{
                    d.resolve(true);
                }
            });
            return d;
        },
        
        __updateLoggedInUserInfoInCache : function(){
            var me = this;
            var d = SVMX.Deferred();
            this.__getLoggedInUserInfo().done(function(userInfo){
                me.__getSFDCUserInfo().done(function(remoteInfo){
                    userInfo.UserId = remoteInfo.UserId;
                    var qo = me.getQueryObject();
                    qo.replaceInto("ClientCache")
                    .columns([{name : "Key"}, {name : "Value"}])
                    .values({Key : "UserInfo", Value : SVMX.toJSON(userInfo)})
                    .execute().done(function(resp){
                        d.resolve();
                    });
                });
            });
            return;
        },
        
        getUserInfo : function(){
        	return this.__getLoggedInUserInfo();
        },
        
        __getLoggedInUserInfo : function(){
            var d = SVMX.Deferred();
            var nativeService = com.servicemax.client.installigence.offline.sal.model.nativeservice.Facade;
            var request = nativeService.createLoginInfoRequest();
            request.bind("REQUEST_COMPLETED", function(evt){ d.resolve(evt.data.data); }, this);
            request.bind("REQUEST_ERROR", function(evt){ d.resolve({}); }, this);
            request.execute();
            return d;
        },

        __getSFDCUserInfo : function(){
            var d = SVMX.Deferred();
            this.getHttpObject().doPost({
                url : "/services/apexrest/"+SVMX.OrgNamespace+"/svmx/MobServiceIntf/getUserInfo",
                data : {} // at least empty object is required
            })
            .done(function(resp){
                d.resolve(resp.data);
            });
            return d;
        },
        
        getLastConfigSyncDetails : function(context){
            var d = SVMX.Deferred(), me = this;
            var queryObj = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            queryObj.select("*")
            .from("ClientCache")
            .where("Key = 'LastConfigSyncTime'")
            .execute().done(function(resp){
                if(resp && resp.length > 0)d.resolveWith(context || me, resp);
                else d.rejectWith(context || me, resp);
            });
            
            return d;
        },

        __setInitialLastDataSyncTime : function(date){
            var d = SVMX.Deferred();
            var value = this.__getSyncTimestamp(date);
            this.getQueryObject()
                .replaceInto("TEMP__ClientCache")
                .columns([{name : "Key"}, {name : "Value"}])
                .values({Key : "LastDataSyncTime", Value : value})
                .execute().done(function(){
                    SVMX.getLoggingService().getLogger().info("Updated last data sync time: " + value);
                    d.resolve();
                });
            return d;
        },

        __updateLastDataSyncTime : function(date){
            var d = SVMX.Deferred();
            var value = this.__getSyncTimestamp(date);
            this.getQueryObject()
                .replaceInto("ClientCache")
                .columns([{name : "Key"}, {name : "Value"}])
                .values({Key : "LastDataSyncTime", Value : value})
                .execute().done(function(){
                    SVMX.getLoggingService().getLogger().info("Updated last data sync time: " + value);
                    d.resolve();
                });
            return d;
        },
        
        __updateLastConfigSyncTime : function(date){
            var d = SVMX.Deferred();
            var value = this.__getSyncTimestamp(date);
            this.getQueryObject()
                .replaceInto("ClientCache")
                .columns([{name : "Key"}, {name : "Value"}])
                .values({Key : "LastConfigSyncTime", Value : value})
                .execute().done(function(){
                    SVMX.getLoggingService().getLogger().info("Updated last config sync time: " + value);
                    d.resolve();
                });
            return d;
        },

        __getSyncTimestamp : function(date){
            date = date || new Date();
            return date.toISOString();
        },
        
        notify : function(params){
            var evt = SVMX.create("com.servicemax.client.lib.api.Event", "SYNC.STATUS", this, params);
            this.triggerEvent(evt);
        },
        
        getQueryObject : function(params){
            var queryObj = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {
                query : params ? params.query : null
            });
            return queryObj;
        },
        
        getHttpObject : function(params){
            var httpObj = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Http", {});
            return httpObj;
        },
        
        // !!! not in use yet !!!!
        getListOfDBTables : function(){
            var d = SVMX.Deferred(), me = this;
            setTimeOut(function(){
                if(me.__listOfDBTables.length > 0){
                    return me.__listOfDBTables;
                }else{
                    var queryObj = me._getQueryObject();
                    queryObj.select("name").from("sqlite_master").execute()
                    .done(function(resp){
                        debugger;
                    });
                }
            }, 1);
            return d;
        },
        
        getAttributeArrayFromCollection : function(col, name){
            var ret = [], i, l = col.length;
            for(i = 0; i < l; i++){
                ret.push(col[i][name]);
            }
            
            return ret;
        },
        
        updateSyncState : function(params){
            var objectInfo = params.objectInfo;
            var objectName = objectInfo.name;
            var records = params.records || [];
            var ids = this.getAttributeArrayFromCollection(records, "Id");
            
            if(params.isInserted){
                var insertCollection = this.__syncState.inserted[objectName] || [];
                insertCollection = insertCollection.concat(ids);
                this.__syncState.inserted[objectName] = insertCollection;
            }else if(params.isUpdated){
                // TODO
            }else if(params.isDeleted){
                // TODO
            }

            // capture record references
            for(var i = 0; i < objectInfo.fields.length; i++){
                var field = objectInfo.fields[i];
                var refObjectName = field.referenceTo[0];
                if(!refObjectName || field.type !== 'reference') continue;
                for(var j = 0; j < records.length; j++){
                    var record = records[j];
                    var value = record[field.name];
                    if(!value) continue;
                    var refCollection = this.__syncState.referenced[refObjectName]
                        = this.__syncState.referenced[refObjectName] || [];
                    if(refCollection.indexOf(value) === -1){
                        refCollection.push(value);
                    }
                }
            }
        },
        
        getSyncState : function(){
            return this.__syncState;
        },
        
        // sync service will always return from the actual table and not from the temp table
        getSObjectInfo : function(objectName){
            var d = SVMX.Deferred();
            var qo = this.getQueryObject();
            
            qo.select("*").from("ObjectDescribe").where("ObjectName = '" + objectName + "'")
            .execute().done(function(resp){
                if(resp.length){
                    d.resolve(SVMX.toObject(resp[0].DescribeResult));
                }else{
                    d.resolve();
                }
            });
            
            return d;
        },
        
        getTableInfoFromDescribe : function(desc, records){
            desc = SVMX.toObject(desc);
            var tableInfo = {name : desc.name, columns : []}
            if(desc && desc.fields && desc.fields.length){
                var i, fields = desc.fields, l = fields.length, f; 
                for(i = 0; i < l; i++){
                    f = fields[i];
                    tableInfo.columns.push({
                        name : f.name,
                        type : "VARCHAR",
                        isUnique : f.name == "Id" ? true : false
                    });
                }
            }else if(records && records[0]){
                var fields = Object.keys(records[0]);
                for(var i = 0; i < fields.length; i++){
                    if(fields[i] === 'attributes') continue;
                    tableInfo.columns.push({
                        name : fields[i],
                        type : "VARCHAR",
                        isUnique : fields[i] == "Id" ? true : false
                    });
                }
            }
            return tableInfo;
        },

        getTranslations : function(reset, d){
            d = d || $.Deferred();
            var qo = this.getQueryObject(), me = this;
            
            // during reset app
            if(reset){
                var provider = SVMX.create("com.servicemax.client.installigence.sync.service.impl.TranslationProvider", {
                    service : this
                });
                provider.run().done(function(){
                    __getTranslations(d);
                });
            }else{
                // regular flow
                __getTranslations(d);
            }

            function __getTranslations(d){
                
                qo.select("*").from("Translations").execute()
                .done(function(resp){
                    if(resp.length > 0){
                        d.resolve(resp);
                    }else{
                        // this happens during first time setup
                        me.getTranslations(true, d);
                    }
                });
            }

            return d;
        }
    }, {});
    
    syncServiceImpl.Class("SyncProvider", com.servicemax.client.lib.api.Object, {
        _service : null, _d : null, _link : null, _cleanupD : null, _parentProvider : null,
        _params : null, _type : null, _refs : null,
        
        __constructor : function(opts){
            this._service = opts.service;
            this._link = opts.link;
            this._parentProvider = opts.parentProvider;
            this._refs = [];
            this.__base();
        },
        
        _runInitialSync : function(){
            throw new Error("Please override this method!");
        },
        
        _runIBSync : function(){
            throw new Error("Please override this method!");
        },
        
        _runInternal : function(params, type){
            this._params = params;
            this._type = type;

            // can be initial or ib or incremental sync.
            if(type == eSyncType.INITIAL || type == eSyncType.RESET || type == eSyncType.PURGE){
                this._runInitialSync();
            }else if(type == eSyncType.IB){
                this._runIBSync();
            }else if(type == eSyncType.INCREMENTAL){
                this._runIncrementalSync();
            }else{
                SVMX.getLoggingService().getLogger().warning("Invalid sync type!");
            }
        },
        
        run : function(params, type){
            this._d = SVMX.Deferred();
            var me = this;
            setTimeout(function(){ me._runInternal(params, type); }, 1);
            return this._d;
        },
        
        cleanup : function(){
            this._cleanupD = SVMX.Deferred();
            var me = this;
            
            setTimeout(function(){ 
                // no need to clean up if it is not intial/reset sync
                if(me._type == eSyncType.IB){
                    me._cleanupD.resolve();
                    return;
                }
                
                if(me._link){
                    me._link.cleanup().done(function(){
                        me._cleanupInternal();
                    });
                }else{
                    me._cleanupInternal();
                } 
            }, 1);
            
            return this._cleanupD;
        },
        
        _getQueryObject : function(params){
            return this._service.getQueryObject(params);
        },
        
        _getHttpObject : function(params){
            return this._service.getHttpObject(params);
        },

        _doHttpGet : function(params){
            return this._getHttpObject().doGet(params);
        },

        _doHttpPost : function(params){
            return this._getHttpObject().doPost(params);
        },

        _doHttpGetQuery : function(queryString){
            var apiVersion = SVMX.getClient().getApplicationParameter("sfdc-api-version") || "32.0";
            var url = "/services/data/v{{apiVersion}}/query?q={{queryString}}";
            url = SVMX.string.substitute(url, {
                apiVersion : apiVersion,
                queryString : encodeURI(queryString)
            });
            return this._doHttpGet({url : url});
        },

        _doHttpGetQueryAll : function(queryString){
            var apiVersion = SVMX.getClient().getApplicationParameter("sfdc-api-version") || "32.0";
            var url = "/services/data/v{{apiVersion}}/queryAll?q={{queryString}}";
            url = SVMX.string.substitute(url, {
                apiVersion : apiVersion,
                queryString : encodeURI(queryString)
            });
            return this._doHttpGet({url : url});
        },

        _doHttpSObjectPost : function(objectName, record){
            var apiVersion = SVMX.getClient().getApplicationParameter("sfdc-api-version") || "32.0";
            var url = "/services/data/v{{apiVersion}}/sobjects/{{objectName}}/";
            url = SVMX.string.substitute(url, {
                apiVersion : apiVersion,
                objectName : objectName
            });
            return this._doHttpPost({
                url : url,
                data : SVMX.toJSON(record)
            });
        },

        _doHttpServiceRequest : function(params){
            return this._doHttpPost({
                url : "/services/apexrest/"+SVMX.OrgNamespace+"/svmx/rest/ProductIQServiceIntf/"+params.name+"/9.0/",
                data : params.data || {} // at least empty object is required
            });
        },

        _doDownloadRequest : function(params){
            var d = SVMX.Deferred();
            var nativeService = com.servicemax.client.installigence.offline.sal.model.nativeservice.Facade;
            var req = nativeService.createRequest("DownloadRequest");
            req.bind("REQUEST_COMPLETED", function(evt){
                d.resolve(evt.data.data);
            }, this);
            req.bind("REQUEST_ERROR", function(evt){
                d.reject(null);
                debugger;
            }, this);
            req.execute(params);
            return d;
        },
        
        notifyBeforeRun : function(params){
            if(this._service) this._service.notify({type : 'beforerun', msg : params.msg});
        },
        
        notifySuccess : function(params){
            if(this._service) this._service.notify({type : 'success', msg : params.msg});
            
            // also resolve the deferred
            this._d.resolveWith( this._parentProvider || this._service);
        },
        
        notifyError : function(params){
            if(this._service) this._service.notify({type : 'error', msg : params.msg});
        },
        
        notifyStatus : function(params){
            if(this._service) this._service.notify({type : 'status', msg : params.msg});
        },
        
        notifyStep : function(params){
            if(this._service) this._service.notify({type : 'step', msg : params.msg});
        },
        
        _replaceTempTables : function(listOfTables){
            if(this._type === eSyncType.PURGE){
                this._purgeTableData(listOfTables);
            }else{
                var i, l = listOfTables.length, responseCount = 0;
                var me = this;
                for(i = 0; i < l; i++){
                    (function(table){
                        var qo = me._getQueryObject();
                        qo.replaceTable(SVMX.getTempTableName(table), table)
                        .done(function(){
                            responseCount++;
                            if(responseCount == l) me._replaceTempTablesComplete(); 
                        });
                    })(listOfTables[i]);
                }
            }
        },

        _purgeTableData : function(tableNames){
            var me = this;
            var responseCount = 0;
            for(var i = 0; i < tableNames.length; i++){
                (function(table){
                    var qo = me._getQueryObject({query:
                        "DELETE FROM "+table+" WHERE Id NOT IN("
                            +"SELECT Id FROM "+SVMX.getTempTableName(table)
                        +")"
                    });
                    qo.execute().done(function(){
                        var qo2 = me._getQueryObject();
                        qo2.dropTable(SVMX.getTempTableName(table));
                        responseCount++;
                        if(responseCount == tableNames.length) me._replaceTempTablesComplete(); 
                    });
                })(tableNames[i]);
            }
        },

        _replaceTempTablesComplete : function(){
            this._cleanupD.resolve(); // default behavior
        },

        
        _createTempTables : function(tables){
            var me = this;
            var i, l = tables.length, responseCount = 0;
            for(i = 0; i < l; i++){
                (function(table){
                    var qo = me._getQueryObject();
                    qo.createTable(SVMX.getTempTableName(table.name), table.columns)
                    .done(function(){
                        responseCount++;
                        if(responseCount == l) me._createTempTablesComplete(); 
                    });
                })(tables[i]);
            }
        },
        
        _getAttributeArrayFromCollection : function(col, name){
            return this._service.getAttributeArrayFromCollection(col, name);
        },
        
        _createTempTablesComplete : function(){
            // do nothing
        },
        
        _createTempTablesFromObjectDescribe : function(tableNames){
            var d = SVMX.Deferred(), me = this;
            var qo = this._getQueryObject();
            var objectDescribeTable = SVMX.getTempTableName("ObjectDescribe");
            if(this._type === eSyncType.PURGE){
                objectDescribeTable = "ObjectDescribe";
            }
            qo.select("*").from(objectDescribeTable)
            .where("ObjectName IN " + "('" + tableNames.join("','") + "')")
            .execute().done(function(resp){
                var i, l = resp.length, listOfTables = [];
                for(i = 0; i < l; i++){
                    listOfTables.push(me._getTableInfoFromDescribe(resp[i].DescribeResult));
                }
                me._createTempTables(listOfTables);
            });
            
            return d;
        },

        _getSObjectInfo : function(objectName){
            var d = SVMX.Deferred();
            var qo = this._getQueryObject();

            var tableName = "ObjectDescribe";
            if(this._type == eSyncType.INITIAL || this._type == eSyncType.RESET){
                tableName = SVMX.getTempTableName("ObjectDescribe");
            }
            
            qo.select("*").from(tableName).where("ObjectName = '" + objectName + "'")
            .execute().done(function(resp){
                if(resp && resp[0]){
                    d.resolve(SVMX.toObject(resp[0].DescribeResult));
                }else{
                    // Fake it
                    d.resolve({name: objectName, fields: []});
                }
            });
            
            return d;
        },
        
        _getTableInfoFromDescribe : function(desc, records){
            if(this._type === eSyncType.PURGE){
                // Purge will download IDs only
                desc = SVMX.toObject(desc);
                return {
                    name : desc.name,
                    columns : [{
                        name: "Id",
                        type: "VARCHAR",
                        isUnique: true
                    }]
                };
            }
            return this._service.getTableInfoFromDescribe(desc, records);
        },
        
        __batchCount : 0,
        
        _downloadRecords : function(objectName, queryString, d){
            if(d) this._downloadD = d;
            if(typeof(queryString) == 'string') queryString = [queryString];
            
            // explicit query batching
            // note: batching doesn't work this way, max offset is 2000
            if(false && queryString.batchSize){
                this.__batchSize = queryString.batchSize;
                this._downloadRecordsInternalBatchLimit(objectName, queryString[0]);
            }else{
                var i, l = queryString.length;
                this.__batchCount = l;
                for(i = 0; i < l; i++){
                    this._downloadRecordsInternal(objectName, queryString[i]);
                }
            }
        },
        
        _downloadRecordsInternal : function(objectName, queryString){
            var me = this;
            this._getSObjectInfo(objectName)
            .done(function(sObjectInfo){
                var apiVersion = SVMX.getClient().getApplicationParameter("sfdc-api-version") || "32.0";
                var url = "/services/data/v{{apiVersion}}/query?q={{queryString}}";
                url = SVMX.string.substitute(url, {
                    apiVersion : apiVersion,
                    queryString : encodeURI(queryString)
                });
                me._downloadMore(url, sObjectInfo);
            });
        },
        
        _downloadMore : function(url, sObjectInfo){
            var me = this;
            this._doHttpGet({url : url})
            .done(function(resp){
                var records = resp.data.records;
                var nextRecordsUrl = resp.data.nextRecordsUrl;
                if(typeof me._downloadRecordsFilter === 'function'){
                    me._downloadRecordsFilter(records, sObjectInfo);
                }
                me._insertRecords(records, sObjectInfo)
                .done(function(){
                    if(nextRecordsUrl){
                        me._downloadMore(nextRecordsUrl, sObjectInfo);
                    }else{
                        me.__batchCount--;
                        if(me.__batchCount == 0){
                            me._downloadRecordsComplete();
                            if(me._downloadD){
                                me._downloadD.resolve();
                            }
                        }
                    }
                });
            });
        },

        _downloadRecordsInternalBatchLimit : function(objectName, queryString){
            var me = this;
            this._getSObjectInfo(objectName)
            .done(function(sObjectInfo){
                me._downloadMoreBatchLimit(queryString, sObjectInfo);
            });
        },

        _downloadMoreBatchLimit : function(queryString, sObjectInfo, i){
            var me = this;

            // append limit
            var i = i || 0;
            var queryStringBatch = queryString
                +" LIMIT "+this.__batchSize
                +" OFFSET "+(i*this.__batchSize);

            this._doHttpGetQuery(queryStringBatch)
            .done(function(resp){
                var records = resp.data.records;
                if(records.length){
                    if(typeof me._downloadRecordsFilter === 'function'){
                        me._downloadRecordsFilter(records, sObjectInfo);
                    }
                    me._insertRecords(records, sObjectInfo)
                    .done(function(){
                        me._downloadMoreBatchLimit(queryString, sObjectInfo, i+1);
                    });
                }else{
                    me._downloadRecordsComplete();
                    if(me._downloadD){
                        me._downloadD.resolve();
                    }
                }
            });
        },

        _downloadRecordsBatchWithSubquery : function(objectName, mainQuery, subQuery, allIds, d){
            var me = this;

            if(!d){
                d = SVMX.Deferred();
                allIds = allIds.slice();
            }

            var batchIds = allIds.splice(0, 100);

            var queryString = mainQuery
            .clone()
            .where("Id").within(subQuery.clone().where("Id").within(batchIds))
            .q();

            // Explicit internal batch size
            queryString.batchSize = 5000;

            var d2 = SVMX.Deferred();
            me._downloadRecords(objectName, queryString, d2);
            d2.done(function(){
                if(!allIds.length){
                    d.resolve();
                    return;
                }
                me._downloadRecordsBatchWithSubquery(
                    objectName, mainQuery, subQuery, allIds, d
                );
            });
            return d;
        },
        
        _downloadRecordsComplete : function(){
            // Do nothing
        },
        
        _insertRecords : function(records, sObjectInfo){
            var me = this
            var d = SVMX.Deferred();

            if(!records || !records.length){
                d.resolve();
                return d;
            }

            var qo = this._getQueryObject();
            var ti = this._getTableInfoFromDescribe(sObjectInfo, records);
            var tableName = sObjectInfo.name;
            if(this._type == eSyncType.INITIAL
            || this._type == eSyncType.RESET
            || this._type == eSyncType.PURGE){
                tableName = SVMX.getTempTableName(sObjectInfo.name);
            }
            
            var conflictedIds = this._service.getSyncState().conflicted || [];
            if(conflictedIds.length){
                for(var i = 0; i < records.length; i++){
                    if(conflictedIds.indexOf(records[i].Id) !== -1){
                        records.splice(i, 1);
                        i--;
                    }
                }
            }
            qo.replaceInto(tableName).columns(ti.columns).values(records)
            .execute().done(function(){
                // update the sync status
                me._service.updateSyncState({isInserted : true, objectInfo : sObjectInfo, records : records});
                // done
                d.resolve();
            });
            return d;
        }

    }, {});
    
    syncServiceImpl.Class("IBSyncProvider", syncServiceImpl.SyncProvider, {

        __constructor : function(opts){
            this.__base(opts);
        },
        
        _runInitialSync : function(){
            this.notifyBeforeRun({msg : "Before starting IB sync"});
            this.notifyStep({msg : "Starting IB sync"});
            
            // create temp tables from object describe
            var tableNames = [SVMX.getCustomObjectName("Installed_Product")];
            this._createTempTablesFromObjectDescribe(tableNames);
        },

        _runIBSync : function(){
            this.notifyBeforeRun({msg : "Before starting IB sync"});
            this.notifyStep({msg : "Starting IB sync"});
            this.__downloadIBs();
        },

        _runIncrementalSync : function(){
            this.notifyBeforeRun({msg : "Before starting IB sync"});
            this.notifyStep({msg : "Starting IB sync"});
            this.__updateLMTopLevelIBs();
        },

        __updateLMTopLevelIBs : function(){
            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                    "INSTALLIGENCE.GET_LM_TOP_LEVEL_IBS", this, {request : { context : this, ids: [], params : this.__params}});
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
        },
        
        onGetLMTopLevelIBsComplete : function(locationIds){
            var me = this;
            if(!locationIds.length){
                this.__downloadIBs();
                return;
            }
            this._getSObjectInfo(SVMX.getCustomObjectName("Installed_Product"))
            .done(function(sObjectInfo){
                var allfields = me._getAttributeArrayFromCollection(sObjectInfo.fields, "name");
                var queryString = me._getQueryObject()
                .select(allfields)
                .from(sObjectInfo.name)
                .where(SVMX.getCustomFieldName("Top_Level")+" = NULL")
                .and(SVMX.getCustomFieldName("Site")).batchWithinIds(locationIds)
                .q();

                var d = SVMX.Deferred();
                me._downloadRecords(sObjectInfo.name, queryString, d);
                d.done(function(){
                    me._getQueryObject()
                    .select("Id")
                    .from(SVMX.getCustomObjectName("Installed_Product"))
                    .where(SVMX.getCustomFieldName("Top_Level")+" = ''")
                    .and("Id NOT LIKE 'transient%'")
                    .execute().done(function(results){
                        var ibs = [];
                        for(var i = 0; i < results.length; i++){
                            var id = results[i].Id
                            if(me._params.IBs.indexOf(id) === -1){
                                ibs.push(id);
                            }
                        }
                        me.__downloadIBs();
                    });
                });
            });
        },

        __downloadIBs : function(){
            if(!this._params.IBs.length){
                this._downloadedIBsComplete();
                return;
            }
            var me = this;
            this._getSObjectInfo(SVMX.getCustomObjectName("Installed_Product"))
            .done(function(sObjectInfo){
                var allfields = me._getAttributeArrayFromCollection(sObjectInfo.fields, "name");
                var queryString = me._getQueryObject()
                .select(allfields)
                .from(sObjectInfo.name)
                .where("Id").batchWithinIds(me._params.IBs)
                .or(SVMX.getCustomFieldName("Top_Level")).batchWithinIds(me._params.IBs)
                .q();

                // Last sync time used during incremental sync
                if(me._params.lastDataSyncTime){
                    for(var i = 0; i < queryString.length; i++){
                        queryString[i] = queryString[i].replace(/WHERE (.*)/,
                            "WHERE LastModifiedDate > "+me._params.lastDataSyncTime+" AND ($1)");
                    }
                }
                var d = SVMX.Deferred();
                me._downloadRecords(sObjectInfo.name, queryString, d);
                d.done(function(){
                    me._downloadedIBsComplete();
                });
            });
        },

        _downloadRecordsFilter : function(records, objectInfo){
            for(var i = 0; i < records.length; i++){
                var rec = records[i];
                if(this._params.IBs.indexOf(rec.Id) === -1){
                    this._params.IBs.push(rec.Id);
                }
            }
        },
        
        _downloadedIBsComplete : function(){
            // After updating IBs, record the updated Ids for usage in later processes
            if(this._params.lastDataSyncTime){
                var objectName = SVMX.getCustomObjectName("Installed_Product");
                var updatedIds = this._service.getSyncState().inserted[objectName] || [];
                this._service.getSyncState().updated[objectName] = updatedIds;
                if(this._params.IBs){
                    this._params.updatedIBs = [];
                    this._params.remainingIBs = [];
                    for(var i = 0; i < this._params.IBs.length; i++){
                        var id = this._params.IBs[i];
                        if(updatedIds.indexOf(id) === -1){
                            this._params.remainingIBs.push(id);
                        }else{
                            this._params.updatedIBs.push(id);
                        }
                    }
                }
            }else{
                this._params.updatedIBs = this._params.IBs;
                this._params.remainingIBs = [];
            }
            this.notifySuccess({msg : "Success: IB sync finished successfully"});
        },
        
        _createTempTablesComplete : function(){
            // now download the intial set of IBs
            this.__downloadIBs();
        },
        
        _cleanupInternal : function(){
            this.notifyStatus({msg : "cleaning up IB sync provider"});
            
            var tableNames = [SVMX.getCustomObjectName("Installed_Product")];
            this._replaceTempTables(tableNames);
        }
    }, {});

    syncServiceImpl.Class("IBTemplateSyncProvider", syncServiceImpl.SyncProvider, {
        __isTemp : null,
        __lastDataSyncTime : null,

        __constructor : function(opts){
            this.__base(opts);
        },
        
        _runInitialSync : function(){
            this.notifyBeforeRun({msg : "Before starting Template sync"});
            this.notifyStep({msg : "Starting Template sync"});
            this.__isTemp = true;
            this.__getTemplateIds()
            .done(this.__downloadTemplates.bind(this));
        },

        _runIBSync : function(){
            this.notifyBeforeRun({msg : "Before starting Template sync"});
            this.notifyStep({msg : "Starting Template sync"});
            this.__getTemplateIds()
            .done(this.__downloadTemplates.bind(this));
        },

        _runIncrementalSync : function(){
            this.notifyBeforeRun({msg : "Before starting Template sync"});
            this.notifyStep({msg : "Starting Template sync"});
            this.__getTemplateIds()
            .done(this.__downloadTemplates.bind(this));
        },

        __getTemplateIds : function(){
            var d = SVMX.Deferred(), me = this;
            var objName = SVMX.getCustomObjectName("Installed_Product");
            var tableName = this.__isTemp ? SVMX.getTempTableName(objName) : objName;
            var tplFieldName = SVMX.getCustomFieldName('ProductIQTemplate');
            this._getQueryObject()
            .select(tplFieldName)
            .from(tableName)
            .execute().done(function(resp){
                var templateIds = [];
                var i, l = resp.length;
                for(i = 0; i < l; i++){
                    var tplId = resp[i][tplFieldName];
                    if(tplId) templateIds.push(tplId);
                }
                d.resolve(templateIds);
            });
            return d;
        },
        
        __downloadTemplates : function(templateIds){
            var me = this;
            if(!templateIds.length){
                me.__downloadTemplatesComplete();
                return;
            }
            // TODO: need a way to get only updated template data in case of incremental sync
            this._doHttpServiceRequest({
                name : "getTemplates",
                data : {templateIds: templateIds}
            })
            .done(function(resp){
                me.__downloadIcons(resp.data);
            });
        },

        __downloadIcons : function(templates){
            var me = this;
            var allIcons = [];
            var templateIndexByIcon = this.__getIconsIndexWithTemplates(templates, allIcons);
            if(!allIcons.length){
                this.__downloadIconsComplete();
                return;
            }
            var docFields = ["Id", "Name", "DeveloperName", "Type"];
            var queryField = "DeveloperName";
            var queryString = this._getQueryObject().select(docFields).from("Document").where(queryField).batchWithinIds(allIcons).q();
            this._doHttpGetQuery(queryString)
            .done(function(resp){
                var i, l = resp.data.records.length, responseCount = 0;
                for(i = 0; i < l; i++){
                    (function(record){
                        var iconName = record[queryField];
                        var fileName = iconName+"."+record.Type;
                        // Update all template product paths with file name
                        for(var j = 0; j < templateIndexByIcon[iconName].length; j++){
                            templateIndexByIcon[iconName][j].productIcon = fileName;
                        }
                        // Download the icon
                        me._doDownloadRequest({
                            sourceObject : "Document",
                            recordId : record.Id,
                            file : fileName
                        })
                        .always(function(){
                            responseCount++;
                            if(responseCount === l) me.__downloadIconsComplete(templates);
                        });
                    })(resp.data.records[i]);
                }
            });
        },

        __getIconsIndexWithTemplates : function(templates, allIcons){
            var templateIndexByIcon = [];
            var i, l = templates.length;
            for(i = 0; i < l; i++){
                var template = templates[i].template;
                if(!template) continue;
                getIconsRecursive(template);
            }
            function getIconsRecursive(template){
                var tplIcon = template.product && template.product.productIcon;
                if(tplIcon){
                    templateIndexByIcon[tplIcon] = templateIndexByIcon[tplIcon] || [];
                    templateIndexByIcon[tplIcon].push(template.product);
                    if(allIcons.indexOf(tplIcon) === -1){
                        allIcons.push(tplIcon);
                    }
                }
                if(template.children){
                    var i, l = template.children.length;
                    for(i = 0; i < l; i++){
                        getIconsRecursive(template.children[i]);
                    }
                }
            }
            return templateIndexByIcon;
        },

        __downloadIconsComplete : function(templates){
            var me = this;
            if(templates && templates.length){
                var i, l = templates.length, responseCount = 0;
                for(i = 0; i < l; i++){
                    this.__insertTemplate(templates[i])
                    .done(function(){
                        responseCount++;
                        if(responseCount === l) me.__downloadTemplatesComplete();
                    });
                }
            }else{
                me.__downloadTemplatesComplete();
            }
        },

        __insertTemplate : function(data){
            var me = this;
            var d = SVMX.Deferred();
            var tname = "Configuration";
            var tableName = this.__isTemp ? SVMX.getTempTableName(tname) : tname;
            this._getQueryObject()
            .select("Key")
            .from(tableName)
            .where("Type = 'template' AND Key = '"+data.sfdcId+"'")
            .execute().done(function(results){
                if(results && results.length){
                    // Already exists
                    d.resolve();
                    return;
                }
                me._getQueryObject()
                .replaceInto(tableName)
                .columns(syncServiceImpl.DBSchema.getMetaTableSchema(tname).columns)
                .values({
                    Type : "template",
                    Key : data.sfdcId,
                    Value : SVMX.toJSON(data)
                })
                .execute().done(function(){
                    d.resolve();
                });
            });
            return d;
        },

        __downloadTemplatesComplete : function(){
            this.notifySuccess({msg : "Success: Template sync finished successfully"});
        },
        
        _cleanupInternal : function(){
            this.notifyStatus({msg : "cleaning up Template sync provider"});
            // nothing to clean up
            this._cleanupD.resolve();
        }
    }, {});
    
    syncServiceImpl.Class("LocationSyncProvider", syncServiceImpl.SyncProvider, {

        __constructor : function(opts){
            this.__base(opts);
        },
        
        _runInitialSync : function(){
            this.notifyBeforeRun({msg : "Before starting Location sync"});
            this.notifyStep({msg : "Starting Location sync"});
            
            // create temp tables from object describe
            var tableNames = [
                SVMX.getCustomObjectName("Site"),
                SVMX.getCustomObjectName("Sub_Location")
            ];
            this._createTempTablesFromObjectDescribe(tableNames);
        },

        _runIBSync : function(){
            this.notifyBeforeRun({msg : "Before starting Location sync"});
            this.notifyStep({msg : "Starting Location sync"});
            this.__downloadLocations();
        },

        _runIncrementalSync : function(){
            this.notifyBeforeRun({msg : "Before starting Location sync"});
            this.notifyStep({msg : "Starting Location sync"});
            this.__downloadLocations();
        },

        _createTempTablesComplete : function(){
            this.__downloadLocations();
        },

        __downloadLocations : function(){
            var me = this;
            this.__parentIds = [];
            this._getSObjectInfo(SVMX.getCustomObjectName("Site"))
            .done(function(locObjectInfo){
                if(!me._params.IBs.length){
                    me.__downloadLMAccountsLocations();
                }else{
                    me.__downloadNewLocations(locObjectInfo)
                    .then(function(){
                        return me.__downloadUpdatedLocations(locObjectInfo);
                    })
                    .then(function(){
                        me._getSObjectInfo(SVMX.getCustomObjectName("Sub_Location"))
                        .done(function(sublocObjectInfo){
                            me.__downloadNewSubLocations(sublocObjectInfo)
                            .then(function(){
                                return me.__downloadUpdatedSubLocations(sublocObjectInfo);
                            })
                            .then(function(){
                                return me.__downloadRemainingLocations(locObjectInfo, sublocObjectInfo);
                            })
                            .then(function(){
                                me.notifySuccess({msg : "Success: Location sync finished successfully"});
                            });
                        });
                    });
                }
            });
        },
        
        __downloadNewLocations : function(objectInfo){
            // Fetch locations from all inserted/updated IBs
            var me = this;
            var d = SVMX.Deferred();

            var ibObjectName = SVMX.getCustomObjectName("Installed_Product");
            var ibIds = me._params.updatedIBs;
            if(!ibIds.length){
                d.resolve();
                return d;
            }

            var subQuery = me._getQueryObject()
            .select(SVMX.getCustomObjectName("Site"))
            .from(ibObjectName);

            var allfields = me._getAttributeArrayFromCollection(objectInfo.fields, "name");
            var mainQuery = me._getQueryObject()
            .select(allfields)
            .from(objectInfo.name);

            me.__parentIds = [];
            me._downloadRecordsBatchWithSubquery(
                objectInfo.name, mainQuery, subQuery, ibIds
            ).done(function(){
                me.__downloadParentLocations(objectInfo, me.__parentIds)
                .done(function(){
                    d.resolve();
                });
            });

            return d;
        },

        _downloadRecordsFilter : function(records, objectInfo){
            this.__allParentIds = this.__allParentIds || [];
            for(var i = 0; i < records.length; i++){
                var recordId = records[i].Id;
                if(this.__allParentIds.indexOf(recordId) === -1){
                    this.__parentIds.push(recordId);
                    this.__allParentIds.push(recordId);
                }
                var parentId = records[i][SVMX.getCustomFieldName("Parent")];
                if(parentId && this.__allParentIds.indexOf(parentId) === -1){
                    this.__parentIds.push(parentId);
                    this.__allParentIds.push(parentId);
                }
            }
        },

        __downloadParentLocations : function(objectInfo, parentIds){
            var me = this;
            var d = SVMX.Deferred();

            if (!parentIds.length){
                d.resolve();
                return d;
            }

            var allfields = me._getAttributeArrayFromCollection(objectInfo.fields, "name");
            var queryString = me._getQueryObject()
            .select(allfields)
            .from(objectInfo.name)
            .where("Id").within(parentIds)
            .or(SVMX.getCustomObjectName("Parent")).within(parentIds)
            .q();

            me.__parentIds = [];
            var d2 = SVMX.Deferred();
            me._downloadRecords(objectInfo.name, queryString, d2);
            d2.done(function(){
                me.__downloadParentLocations(objectInfo, me.__parentIds)
                .done(function(){
                    d.resolve();
                });
            });

            return d;
        },

        __downloadUpdatedLocations : function(objectInfo){
            // Fetch only related locations where LastModifiedDate, within IBs that were NOT updated
            var me = this;
            var d = SVMX.Deferred();

            var ibIds = me._params.remainingIBs;
            if(!ibIds.length){
                d.resolve();
                return d;
            }

            var subQuery = me._getQueryObject()
            .select(SVMX.getCustomObjectName("Site"))
            .from(SVMX.getCustomObjectName("Installed_Product"));

            var allfields = me._getAttributeArrayFromCollection(objectInfo.fields, "name");
            var mainQuery = me._getQueryObject()
            .select(allfields)
            .from(objectInfo.name)
            .where("LastModifiedDate > "+me._params.lastDataSyncTime);

            me.__parentIds = [];
            me._downloadRecordsBatchWithSubquery(
                objectInfo.name, mainQuery, subQuery, ibIds
            ).done(function(){
                me.__downloadParentLocations(objectInfo, me.__parentIds)
                .done(function(){
                    d.resolve();
                });
            });

            return d;
        },

        __downloadNewSubLocations : function(objectInfo){
            // Fetch sub locations from all inserted/updated IBs
            var me = this;
            var d = SVMX.Deferred();

            var ibObjectName = SVMX.getCustomObjectName("Installed_Product");
            var ibIds = me._params.updatedIBs;
            if(!ibIds.length){
                d.resolve();
                return d;
            }

            var subQuery = me._getQueryObject()
            .select(SVMX.getCustomObjectName("Sub_Location"))
            .from(ibObjectName);

            var allfields = me._getAttributeArrayFromCollection(objectInfo.fields, "name");
            var mainQuery = me._getQueryObject()
            .select(allfields)
            .from(objectInfo.name);

            me._downloadRecordsBatchWithSubquery(
                objectInfo.name, mainQuery, subQuery, ibIds
            ).done(function(){
                me.__downloadParentSubLocations(objectInfo, me.__parentIds)
                .done(function(){
                    d.resolve();
                });
            });

            return d;
        },

        __downloadParentSubLocations : function(objectInfo, parentIds){
            var me = this;
            var d = SVMX.Deferred();

            if (!parentIds.length){
                d.resolve();
                return d;
            }

            var allfields = me._getAttributeArrayFromCollection(objectInfo.fields, "name");
            var queryString = me._getQueryObject()
            .select(allfields)
            .from(objectInfo.name)
            .where("Id").within(parentIds)
            .q();

            var d2 = SVMX.Deferred();
            me._downloadRecords(objectInfo.name, queryString, d2);
            d2.done(function(){
                me.__downloadParentSubLocations(objectInfo, me.__parentIds)
                .done(function(){
                    d.resolve();
                });
            });

            return d;
        },

        __downloadUpdatedSubLocations : function(objectInfo){
            // Fetch only related locations where LastModifiedDate, within IBs that were NOT updated
            var me = this;
            var d = SVMX.Deferred();

            var ibIds = me._params.remainingIBs;
            if(!ibIds.length){
                d.resolve();
                return d;
            }

            var subQuery = me._getQueryObject()
            .select(SVMX.getCustomObjectName("Sub_Location"))
            .from(SVMX.getCustomObjectName("Installed_Product"));

            var allfields = me._getAttributeArrayFromCollection(objectInfo.fields, "name");
            var mainQuery = me._getQueryObject()
            .select(allfields)
            .from(objectInfo.name)
            .where("LastModifiedDate > "+me._params.lastDataSyncTime);

            me._downloadRecordsBatchWithSubquery(
                objectInfo.name, mainQuery, subQuery, ibIds
            ).done(function(){
                me.__downloadParentSubLocations(objectInfo, me.__parentIds)
                .done(function(){
                    d.resolve();
                });
            });

            return d;
        },

        __downloadRemainingLocations : function(locObjectInfo, sublocObjectInfo){
            // Fetch locations that already exist locally but were not updated by previous methods
            var me = this;
            var d = SVMX.Deferred();
            if (me._params.lastDataSyncTime){
                var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                    "INSTALLIGENCE.GET_LOCATIONS", me, {
                    request : {
                        context : me,
                        handler : me.__onGetExistingLocationsComplete,
                        params : {
                            locObjectInfo : locObjectInfo,
                            sublocObjectInfo : sublocObjectInfo,
                            d : d
                        }
                    }
                });
                com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
            }else{
                d.resolve();
            }
            return d;
        },

        __onGetExistingLocationsComplete : function(result, params) {
            var me = this;
            var locObject = SVMX.getCustomObjectName("Site");
            var sublocObject = SVMX.getCustomObjectName("Sub_Location");

            var locationIds = [];
            var sublocationIds = [];
            for(var i = 0; i < result[locObject].length; i++){
                locationIds.push(result[locObject][i].Id);
            }
            for(var i = 0; i < result[sublocObject].length; i++){
                sublocationIds.push(result[sublocObject][i].Id);
            }
            if (locationIds.length){

                var allfields = me._getAttributeArrayFromCollection(params.locObjectInfo.fields, "name");
                var queryString = me._getQueryObject()
                .select(allfields)
                .from(params.locObjectInfo.name)
                .where("Id").within(locationIds)
                .and("LastModifiedDate > "+me._params.lastDataSyncTime)
                .q();

                var d2 = SVMX.Deferred();
                me._downloadRecords(params.locObjectInfo.name, queryString, d2);
                d2.done(function(){

                    if(sublocationIds.length){

                        var allfields = me._getAttributeArrayFromCollection(params.sublocObjectInfo.fields, "name");
                        var queryString = me._getQueryObject()
                        .select(allfields)
                        .from(params.sublocObjectInfo.name)
                        .where("Id").within(locationIds)
                        .and("LastModifiedDate > "+me._params.lastDataSyncTime)
                        .q();

                        var d2 = SVMX.Deferred();
                        me._downloadRecords(params.sublocObjectInfo.name, queryString, d2);
                        d2.done(function(){
                            params.d.resolve();
                        });
                    }else{
                        params.d.resolve();
                    }
                });
            }else{
                params.d.resolve();
            }
        },

        __downloadLMAccountsLocations : function(){
            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                    "INSTALLIGENCE.GET_LM_ACCOUNTS_LOCATIONS", this, {request : { context : this, params : this.__params}});
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
        },

        onGetLMAccountsLocationsComplete : function(accountIds, locationIds){

            // LM accounts eferred for account sync provider to pick up
            this._params.lmaccounts = accountIds;

            if(!locationIds || !locationIds.length){
                this.notifySuccess({msg : "Success: Location sync finished successfully"});
                return;
            }
            // Fetch locations based on account ids from LM
            var me = this;
            this._getSObjectInfo(SVMX.getCustomObjectName("Site"))
            .done(function(objectInfo){

                var allfields = me._getAttributeArrayFromCollection(objectInfo.fields, "name");
                var queryString = me._getQueryObject()
                .select(allfields)
                .from(objectInfo.name)
                .where("Id").batchWithinIds(locationIds)
                .q();

                var d = SVMX.Deferred();
                me._downloadRecords(objectInfo.name, queryString, d);
                d.done(function(){
                    me.notifySuccess({msg : "Success: Location sync finished successfully"});
                });
            });
        },
        
        _cleanupInternal : function(){
            this.notifyStatus({msg : "cleaning up Location sync provider"});
            
            var tableNames = [
                SVMX.getCustomObjectName("Site"),
                SVMX.getCustomObjectName("Sub_Location")
            ];
            this._replaceTempTables(tableNames);
        }
    }, {});

    syncServiceImpl.Class("ProductSyncProvider", syncServiceImpl.SyncProvider, {

        __constructor : function(opts){ this.__base(opts); },
        
        _runInitialSync : function(){
            this.notifyBeforeRun({msg : "Before starting Product sync"});
            this.notifyStep({msg : "Starting Product sync"});
            
            // create temp tables from object describe
            var tableNames = ["Product2"];
            this._createTempTablesFromObjectDescribe(tableNames);
        },

        _runIBSync : function(){
            this.notifyBeforeRun({msg : "Before starting Product sync"});
            this.notifyStep({msg : "Starting Product sync"});
            this.__downloadProducts();
        },

        _runIncrementalSync : function(params){
            this.notifyBeforeRun({msg : "Before starting Product sync"});
            this.notifyStep({msg : "Starting Product sync"});
            this.__downloadProducts();
        },

        _createTempTablesComplete : function(){
            this.__downloadProducts();
        },

        __updateLMProducts : function(){
            // TODO: Need a better way to get products in stand-alone mode
            // This solution is used bring extra products from MFL to PriQ,
            // But is not a valid solution for stand-alone install
            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                    "INSTALLIGENCE.GET_LM_PRODUCTS", this, {request : { context : this, ids: [], params : this.__params}});
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
        },
        
        onGetLMProductsComplete : function(products){
            var me = this;
            if(!products.length){
                this.__downloadProducts();
                return;
            }
            this._getSObjectInfo("Product2")
            .done(function(sObjectInfo){
                var upfields = [];
                for(var i = 0; i < sObjectInfo.fields.length; i++) {
                    upfields.push({name: sObjectInfo.fields[i].name});
                }
                me._getQueryObject()
                .replaceInto("Product2")
                .columns(upfields)
                .values(products)
                .execute().done(function(){
                    me.__downloadProducts();
                });
            });
        },

        __downloadProducts : function(){
            var me = this;
            this._getSObjectInfo("Product2")
            .done(function(objectInfo){
                me.__downloadNewProducts(objectInfo)
                .then(function(){
                    return me.__downloadUpdatedProducts(objectInfo);
                })
                .then(function(){
                    return me.__downloadTemplateProducts(objectInfo);
                })
                .then(function(){
                    me.notifySuccess({msg : "Product sync finished successfully"});
                });
            });
        },
        
        __downloadNewProducts : function(objectInfo){
            // Fetch products from all inserted/updated IBs
            var me = this;
            var d = SVMX.Deferred();

            var ibObjectName = SVMX.getCustomObjectName("Installed_Product");
            var ibIds = me._params.updatedIBs;
            if(!ibIds.length){
                d.resolve();
                return d;
            }

            var subQuery = me._getQueryObject()
            .select(SVMX.getCustomObjectName("Product"))
            .from(ibObjectName);

            var allfields = me._getAttributeArrayFromCollection(objectInfo.fields, "name");
            var mainQuery = me._getQueryObject()
            .select(allfields)
            .from(objectInfo.name);

            me._downloadRecordsBatchWithSubquery(
                objectInfo.name, mainQuery, subQuery, ibIds
            ).done(function(){
                d.resolve();
            });

            return d;
        },

        __downloadUpdatedProducts : function(objectInfo){
            // Fetch only related products where LastModifiedDate, within IBs that were NOT updated
            var me = this;
            var d = SVMX.Deferred();

            var ibIds = me._params.remainingIBs;
            if(!ibIds.length){
                d.resolve();
                return d;
            }

            var subQuery = me._getQueryObject()
            .select(SVMX.getCustomObjectName("Product"))
            .from(SVMX.getCustomObjectName("Installed_Product"));

            var allfields = me._getAttributeArrayFromCollection(objectInfo.fields, "name");
            var mainQuery = me._getQueryObject()
            .select(allfields)
            .from(objectInfo.name)
            .where("LastModifiedDate > "+me._params.lastDataSyncTime);

            me._downloadRecordsBatchWithSubquery(
                objectInfo.name, mainQuery, subQuery, ibIds
            ).done(function(){
                d.resolve();
            });

            return d;
        },

        __downloadTemplateProducts : function(objectInfo){
            var me = this;
            var d = SVMX.Deferred();
            var tname = "Configuration";
            var tableName = (this._type === eSyncType.INITIAL)
                ? SVMX.getTempTableName(tname) : tname;
            var qo = this._getQueryObject();
            qo.select("Value")
            .from(tableName)
            .where("Type = 'template'")
            .execute().done(function(result){
                var templateProductIds = [];
                for(var i = 0; i < result.length; i++){
                    var template = SVMX.toObject(result[i].Value);
                    var productIds = me.__getProductIdsFromTemplate(template);
                    for(var j = 0; j < productIds.length; j++){
                        var productId = productIds[j];
                        if(templateProductIds.indexOf(productId) === -1){
                            templateProductIds.push(productId);
                        }
                    }
                }
                me.__filterLocalProductIds(templateProductIds)
                .done(function(){
                    if(templateProductIds.length){
                        var allfields = me._getAttributeArrayFromCollection(objectInfo.fields, "name");
                        var qo = me._getQueryObject()
                        .select(allfields)
                        .from(objectInfo.name);
                        // TODO: disabled until we can implement check for updated vs remaining templates
                        if(false && me._params.lastDataSyncTime){
                            qo.where("LastModifiedDate > "+me._params.lastDataSyncTime)
                            .and("Id").within(templateProductIds);
                        }else{
                            qo.where("Id").within(templateProductIds);
                        }
                        var queryString = qo.q();
                        me._downloadRecords(objectInfo.name, queryString, d);
                    }else{
                        d.resolve();
                    }
                });
            });
            return d;
        },

        __getProductIdsFromTemplate : function(template){
            var productIds = [];
            if(template.template.product){
                productIds.push(template.template.product.productId);
            }
            getProductIdsRecursive(template.template.children);
            function getProductIdsRecursive(children){
                if(!children) return;
                for(var i = 0; i < children.length; i++){
                    var child = children[i];
                    if(child.product){
                        productIds.push(child.product.productId);
                    }
                    if(child.children){
                        getProductIdsRecursive(child.children);
                    }
                }
            }
            return productIds;
        },

        __filterLocalProductIds : function(templateProductIds){
            var me = this;
            var d = SVMX.Deferred();
            var tname = "Product2";
            var tableName = (this._type === eSyncType.INITIAL)
                ? SVMX.getTempTableName(tname) : tname;
            this._getQueryObject()
            .select("Id")
            .from(tableName)
            .where("Id").within(templateProductIds)
            .execute().done(function(result){
                for(var i = 0; i < result.length; i++){
                    var localId = result[i].Id;
                    var idx = templateProductIds.indexOf(localId);
                    if(idx !== -1){
                        templateProductIds.splice(idx, 1);
                    }
                }
                d.resolve();
            });
            return d;
        },
        
        _cleanupInternal : function(){
            this.notifyStatus({msg : "cleaning up Product sync provider"});
            
            var tableNames = ["Product2"];
            this._replaceTempTables(tableNames);
        }
    }, {});
    
    syncServiceImpl.Class("AccountSyncProvider", syncServiceImpl.SyncProvider, {
        __acc4locDownloaded : false,
        
        __constructor : function(opts){
            this.__base(opts);
        },
        
        _runInitialSync : function(){
            this.__acc4locDownloaded = false;
            
            this.notifyBeforeRun({msg : "Before starting Account sync"});
            this.notifyStep({msg : "Starting Account sync"});
            
            // create temp tables from object describe
            var tableNames = ["Account"];
            this._createTempTablesFromObjectDescribe(tableNames);
        },

        _runIBSync : function(){
            this.notifyBeforeRun({msg : "Before starting Account sync"});
            this.notifyStep({msg : "Starting Account sync"});
            this.__downloadAccounts();
        },

        _runIncrementalSync : function(params){
            this.notifyBeforeRun({msg : "Before starting Account sync"});
            this.notifyStep({msg : "Starting Account sync"});
            this.__downloadAccounts();
        },

        _createTempTablesComplete : function(){
            this.__downloadAccounts();
        },

        __downloadAccounts : function(){
            var me = this;
            this._getSObjectInfo("Account")
            .done(function(objectInfo){
                me.__downloadNewAccounts(objectInfo)
                .then(function(){
                    return me.__downloadLMAccounts(objectInfo);
                })
                .then(function(){
                    return me.__downloadUpdatedAccounts(objectInfo);
                })
                .then(function(){
                    return me.__downloadAccountsForLocations(objectInfo);
                })
                .then(function(){
                    me.notifySuccess({msg : "Account sync finished successfully"});
                });
            });
        },
        
        __downloadNewAccounts : function(objectInfo){
            // Fetch products from all inserted/updated IBs
            var me = this;
            var d = SVMX.Deferred();

            var ibIds = me._params.updatedIBs;
            if(!ibIds.length){
                d.resolve();
                return d;
            }

            var subQuery = me._getQueryObject()
            .select(SVMX.getCustomObjectName("Company"))
            .from(SVMX.getCustomObjectName("Installed_Product"));

            var allfields = me._getAttributeArrayFromCollection(objectInfo.fields, "name");
            var mainQuery = me._getQueryObject()
            .select(allfields)
            .from(objectInfo.name);

            me._downloadRecordsBatchWithSubquery(
                objectInfo.name, mainQuery, subQuery, ibIds
            ).done(function(){
                d.resolve();
            });

            return d;
        },

        __downloadLMAccounts : function(objectInfo){
            // Fetch only related accounts where LastModifiedDate, within IBs that were NOT updated
            var me = this;
            var d = SVMX.Deferred();

            var accountIds = me._params.lmaccounts;
            if(!accountIds || !accountIds.length){
                d.resolve();
                return d;
            }

            var allfields = me._getAttributeArrayFromCollection(objectInfo.fields, "name");
            var queryString = me._getQueryObject()
            .select(allfields)
            .from(objectInfo.name)
            .where("Id").batchWithinIds(accountIds)
            .q();

            var d2 = SVMX.Deferred();
            me._downloadRecords(objectInfo.name, queryString, d2);
            d2.done(function(){
                d.resolve();
            });

            return d;
        },

        __downloadUpdatedAccounts : function(objectInfo){
            // Fetch only related accounts where LastModifiedDate, within IBs that were NOT updated
            var me = this;
            var d = SVMX.Deferred();

            var ibIds = me._params.remainingIBs;
            if(!ibIds.length){
                d.resolve();
                return d;
            }

            var subQuery = me._getQueryObject()
            .select(SVMX.getCustomObjectName("Company"))
            .from(SVMX.getCustomObjectName("Installed_Product"));

            var allfields = me._getAttributeArrayFromCollection(objectInfo.fields, "name");
            var mainQuery = me._getQueryObject()
            .select(allfields)
            .from(objectInfo.name)
            .where("LastModifiedDate > "+me._params.lastDataSyncTime);

            me._downloadRecordsBatchWithSubquery(
                objectInfo.name, mainQuery, subQuery, ibIds
            ).done(function(){
                d.resolve();
            });

            return d;
        },

        __downloadAccountsForLocations : function(objectInfo){
            var me = this;
            var d = SVMX.Deferred();
            me._getAccountIdsFromLocations()
            .then(function(accountIds){
                if(!accountIds || !accountIds.length){
                    d.resolve();
                    return;
                }
                var allfields = me._getAttributeArrayFromCollection(objectInfo.fields, "name");
                var queryString = me._getQueryObject()
                .select(allfields)
                .from(objectInfo.name)
                .where("Id").batchWithinIds(accountIds)
                .q();

                // Explicit batch size
                queryString.batchSize = 5000;

                me._downloadRecords(objectInfo.name, queryString, d);
            });
            return d;
        },

        _getAccountIdsFromLocations : function(){
            var d = SVMX.Deferred();
            var accountField = SVMX.getCustomFieldName("Account");
            if(this._type === eSyncType.INCREMENTAL){
                // Get account ids from local database
                this._getQueryObject()
                .select(accountField)
                .from(SVMX.getCustomObjectName("Site"))
                .execute().done(function(results){
                    var ids = [];
                    for(var i = 0; i < results.length; i++){
                        var record = results[i];
                        var id = record[accountField];
                        if(!id || ids.indexOf(id) !== -1) continue;
                        ids.push(id);
                    }
                    d.resolve(ids);
                });
            }else{
                // Get account ids from server
                var siteIds = this._service.getSyncState().inserted[SVMX.getCustomObjectName("Site")];
                if(!siteIds || !siteIds.length){
                    d.resolve();
                    return d;
                }
                var queryString = this._getQueryObject()
                .select(SVMX.getCustomFieldName("Account"))
                .from(SVMX.getCustomObjectName("Site"))
                .where("Id").batchWithinIds(siteIds)
                .q();

                var ids = [];

                var counter = 0;
                for(var i = 0; i < queryString.length; i++){
                    var qs = queryString[i];
                    this._doHttpGetQuery(qs)
                    .done(function(resp){
                        for(var i = 0; i < resp.data.records.length; i++){
                            var record = resp.data.records[i];
                            if(!record[accountField]) continue;
                            ids.push(record[accountField]);
                        }
                        counter++;
                        if(counter === queryString.length){
                            d.resolve(ids);
                        }
                    });
                }
            }
            return d;
        },
        
        _cleanupInternal : function(){
            this.notifyStatus({msg : "cleaning up Account sync provider"});
            
            var tableNames = ["Account"];
            this._replaceTempTables(tableNames);
        }
    }, {});

    syncServiceImpl.Class("RecordNameSyncProvider", syncServiceImpl.SyncProvider, {
        
        __constructor : function(opts){
            this.__base(opts);
        },
        
        _runInitialSync : function(){
            this.notifyBeforeRun({msg : "Before starting Record Name sync"});
            this.notifyStep({msg : "Starting Record Name sync"});
            this.__downloadRecordNames();
        },

        _runIBSync : function(){
            this.notifyBeforeRun({msg : "Before starting Record Name sync"});
            this.notifyStep({msg : "Starting Record Name sync"});
            this.__downloadRecordNames();
        },

        _runIncrementalSync : function(params){
            this.notifyBeforeRun({msg : "Before starting Record Name sync"});
            this.notifyStep({msg : "Starting Record Name sync"});
            this.__downloadRecordNames();
        },

        __downloadRecordNames : function(){
            var me = this;
            var counter = 0;
            var refs = this._service.getSyncState().referenced;
            for(var objectName in refs){
                counter++;
                var allRefIds = refs[objectName];
                this.__getRemoteReferenceIds(objectName, allRefIds)
                .done(function(objectName, remoteRefIds){
                    me.__downloadRecordNamesRemote(objectName, remoteRefIds)
                    .done(function(){
                        counter--;
                        if(counter === 0){
                            me.__downloadRecordNamesComplete();
                        }
                    });
                });
            }
            if(counter === 0){
                me.__downloadRecordNamesComplete();
            }
        },

        __getRemoteReferenceIds : function(objectName, allRefIds){
            var d = SVMX.Deferred();
            var tableName = this._type === eSyncType.INITIAL
                ? SVMX.getTempTableName(objectName) : objectName;
            var remoteRefIds = SVMX.cloneObject(allRefIds);

            var insertedObject = this._service.getSyncState().inserted[objectName];
            if(!insertedObject){
                d.resolve(objectName, remoteRefIds);
                return d;
            }

            this._getQueryObject()
            .select("Id")
            .from(tableName)
            .where("Id").within(allRefIds)
            .execute().done(function(results){
                if(results){
                    for(var i = 0; i < results.length; i++){
                        var localId = results[i].Id;
                        var index = remoteRefIds.indexOf(localId);
                        remoteRefIds.splice(index, 1);
                    }
                }
                d.resolve(objectName, remoteRefIds);
            });
            return d;
        },

        __downloadRecordNamesRemote : function(objectName, recordIds){
            var me = this;
            var d = SVMX.Deferred();

            if(!recordIds.length){
                d.resolve();
                return d;
            }
            var recordNameTable = this._type === eSyncType.INITIAL ? SVMX.getTempTableName("RecordName") : "RecordName";
            var nameField = (objectName === "Case") ? "CaseNumber" : "Name";
            var queryString = this._getQueryObject()
            .select(["Id", nameField])
            .from(objectName)
            .where("Id").batchWithinIds(recordIds)
            .q();

            var counter = 0;
            for(var i = 0; i < queryString.length; i++){
                this._doHttpGetQuery(queryString[i])
                .done(function(resp){
                    var recordNames = [];
                    for(var i = 0; i < resp.data.records.length; i++){
                        var record = resp.data.records[i];
                        recordNames.push({
                            Id : record.Id,
                            Name : record[nameField]
                        });
                    }
                    me._getQueryObject()
                    .replaceInto(recordNameTable)
                    .columns([{name : "Id"}, {name : "Name"}])
                    .values(recordNames)
                    .execute().done(function(){
                        counter++;
                        if(counter === queryString.length){
                            d.resolve();
                        }
                    });
                });
            }
            return d;
        },

        __downloadRecordNamesComplete : function(){
            this.notifySuccess({msg : "Record Name sync finished successfully"});
        },

        _cleanupInternal : function(){
            this.notifyStatus({msg : "cleaning up Template sync provider"});
            // nothing to clean up
            this._cleanupD.resolve();
        }

    }, {});
    
    /**
     * 01. Reset application
     * 02. Stand alone config sync
     * 03. Incremental data sync?
     */
    syncServiceImpl.Class("ConfigSyncProvider", syncServiceImpl.SyncProvider, {
        __doProvider : null,
        
        __constructor : function(opts){
            this.__base(opts);
        },
        
        /**
         * 01. get user configurations
         * 02. get permission sets
         * 03. describe objects
         * 04. setup data tables
         */
        _runInternal : function(params, type){
            this._type = type;
            this.notifyBeforeRun({msg : "Before starting config sync"});
            this.notifyStep({msg : "Starting config sync"});
            if(this._service.__currentSyncType === eSyncType.CONFIG){
                var configTables = syncServiceImpl.DBSchema.getConfigTables();
                this._createTempTables(configTables);
            }else{
                var metaTables = syncServiceImpl.DBSchema.metaTables;
                this._createTempTables(metaTables);
            }
        },
        
        _createTempTablesComplete : function(){
            this.__downloadUserConfig();
        },

        __downloadUserConfig : function(){
            var me = this;
            this._doHttpServiceRequest({
                name : "getUserConfiguration"
            })
            .done(function(result){
                var tname = "Configuration";
                var qo = me._getQueryObject();
                qo.insertInto(SVMX.getTempTableName(tname)).columns(syncServiceImpl.DBSchema.getMetaTableSchema(tname).columns)
                .values({Type : "user", Value : SVMX.toJSON(result.data)})
                .execute().done(function(){
                    me.__downloadUserConfigComplete();
                });
                
            });
        },

        __downloadUserConfigComplete : function(){
            this.__configSyncComplete();
        },

        __configSyncComplete : function(){
            this.__doProvider = SVMX.create("com.servicemax.client.installigence.sync.service.impl.DescribeObjectProvider", {
                service : this._service, parentProvider : this 
            });
            this.__doProvider.run()
            .done(function(){
                this.notifySuccess({msg : "Config sync finished successfully"});
            });
        },
        
        _cleanupInternal : function(){
            this.notifyStatus({msg : "cleaning up config sync provider"});
            
            var tables = [];
            if(this._service.__currentSyncType === eSyncType.CONFIG){
                tables = syncServiceImpl.DBSchema.getConfigTables();
            }else{
                tables = syncServiceImpl.DBSchema.metaTables;
            }
            var i, l = tables.length;
            var tmp = [];
            for(i = 0; i < l; i++){
                tmp.push(tables[i].name);
            }
            this._replaceTempTables(tmp);
        },
        
        _replaceTempTablesComplete : function(){
            this.__doProvider.cleanup().done(function(){
                this._cleanupD.resolve();
            });
        }
    }, {});
    
    syncServiceImpl.Class("DescribeObjectProvider", syncServiceImpl.SyncProvider, {
        __constructor : function(opts){
            this.__base(opts);
        },
        
        _runInternal : function(params){
            this.notifyBeforeRun({msg : "Before starting describe object sync"});
            this.notifyStep({msg : "Describing object definitions"});
            this.__describeObjects();
        },
        
        __describeObjects : function(){
            var i, tables = syncServiceImpl.DBSchema.dataTables, l = tables.length, responseCount = 0;
            var me = this;
            
            var apiVersion = SVMX.getClient().getApplicationParameter("sfdc-api-version") || "32.0";
            var url = "/services/data/v{{apiVersion}}/sobjects/{{objectName}}/describe";
            
            for(i = 0; i < l; i++){
                (function(table, url){
                    var objectName = table.name;
                    url = SVMX.string.substitute(url, {apiVersion : apiVersion, objectName : objectName});
                    var ho = me._getHttpObject();
                    ho.doGet({url : url})
                    .done(function(resp){

                        // insert into database
                        var describe = resp.data, objectName = describe.name;
                        var qo = me._getQueryObject();
                        var tname = "ObjectDescribe";
                        qo.insertInto(SVMX.getTempTableName(tname)).columns(syncServiceImpl.DBSchema.getMetaTableSchema(tname).columns)
                        .values({ObjectName : objectName, DescribeResult : SVMX.toJSON(describe)})
                        .execute().done(function(){
                            responseCount++;
                            if(responseCount == l) me.__describeObjectsComplete();
                        });
                    });
                })(tables[i], url);
            }
        },
        
        __describeObjectsComplete : function(){
            this.notifySuccess({msg : "Describe object sync finished successfully"});
        },
        
        _cleanupInternal : function(){
            this.notifyStatus({msg : "cleaning up describe object sync provider"});
            this._cleanupD.resolveWith(this._parentProvider);
        }
    }, {});

    syncServiceImpl.Class("TranslationProvider", syncServiceImpl.SyncProvider, {
        __constructor : function(opts){
            this.__base(opts);
        },
        
        _runInternal : function(params){
            this.notifyBeforeRun({msg : "Getting translations"});
            this.__downloadTranslations();
        },
        
        __downloadTranslations : function(){
            var me = this;
            this._doHttpServiceRequest({ name : "getTranslations" })
            .done(function(result){
                var schema = { name : "Translations", columns : [
                    {name : "Key", type : "VARCHAR"},
                    {name : "Text", type : "VARCHAR"}
                ] };

                result = result.data;

                // create the table
                var qo = me._getQueryObject();
                qo.createTable(schema.name, schema.columns).done(function(){
                    // insert
                    qo.insertInto(schema.name).columns(schema.columns)
                    .values(result)
                    .execute().done(function(){
                        me.__downloadTranslationsComplete(result);
                    });
                });
            });
        },
        
        __downloadTranslationsComplete : function(result){
            this.notifySuccess({msg : "Translations sync finished successfully"});
        }
    }, {});

    syncServiceImpl.Class("IncrementalSyncProvider", syncServiceImpl.SyncProvider, {
        __lastDataSyncTime : null,
        
        __constructor : function(opts){
            this.__base(opts);
        },
        
        _runInternal : function(params){
            this.notifyBeforeRun({msg : "Syncing"});
            var me = this;
            this.__getLastDataSyncTime()
            .done(function(lst){
                me.__lastDataSyncTime = lst;
                me._putInsert();
            });
        },

        __getLastDataSyncTime : function(){
            var d = SVMX.Deferred();
            this._getQueryObject()
                .select("Value")
                .from("ClientCache")
                .where("Key = 'LastDataSyncTime'")
                .execute().done(function(resp){
                    var lastDataSyncTime = new Date(resp[0] && resp[0].Value);
                    d.resolve(lastDataSyncTime.toISOString());
                });
            return d;
        },

        updateLastDataSyncTime : function(date){
            var syncTime = new Date().toISOString();
            return this._getQueryObject()
                .replaceInto("ClientCache")
                .columns([{name : "Key"}, {name : "Value"}])
                .values({Key : "LastDataSyncTime", Value : syncTime})
                .execute();
        },
        
        
        
        // Insert only requested records
        putInsertRequested : function(recordIds){
        	 var me = this;
        	 me.__fetchInsertDependentRecordsFor(recordIds)
        	 .done(function(allrecs){
        		 me.__buildInsertSyncTree(allrecs)
                 .done(function(syncTree){
                     me.__putInsertRecords(syncTree)
                     .done(function(){
                    	 this.notifySuccess({msg : "Success: Incremental data sync finished successfully for requested records"});
                     });
                 }); 
        	 });            
        },
        
        // Step 1:
        _putInsert : function(){
            var me = this;
            me.__deleteConflictRecords()
            .done(function(){
                me.__buildInsertSyncTree()
                .done(function(syncTree){
                    me.__putInsertRecords(syncTree)
                    .done(function(){
                        me.__putInsertComplete();
                    });
                });
            });
        },       
        
        __putInsertComplete : function(result){
            this._getDelete();
        },

        // Step 2:
        _getDelete : function(){
            var me = this;
            this.__getDeleteRecords()
            .done(function(){
                me.__getDeleteComplete();
            });
        },

        __getDeleteComplete : function(){var me = this;
            this._putUpdate();
        },

        // Step 3:
        _putUpdate : function(){
            var me = this;
            this.__putUpdateRecords()
            .then(function(){
                return me.__putUpdateConflicts();
            })
            .done(function(){
                me.__putUpdateComplete();
            });
        },

        __putUpdateComplete : function(){
            this.updateLastDataSyncTime();
            this._getUpdate();
        },

        // Step 4:
        _getUpdate : function(){
            var me = this;
            this.__getUpdateRecords()
            .done(function(){
                me.__getUpdateComplete();
            });
        },

        __getUpdateComplete : function(){
            // The End
            this.notifySuccess({msg : "Success: Incremental data sync finished successfully"});
        },

        __deleteConflictRecords : function(){
            var me = this;
            var d = SVMX.Deferred();
            var qo = me._getQueryObject()
            .select("*")
            .from("ClientSyncConflict")
            .where("Action = 'CLIENT_DELETE'");
            qo.execute().done(function(results){
                if(!results || !results.length){
                    d.resolve();
                    return;
                }
                var deleteRecords = [];
                for(var i = 0; i < results.length; i++){
                    deleteRecords.push({
                        id : results[i].Id,
                        objectName : results[i].ObjectName
                    });
                }
                var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                    "INSTALLIGENCE.DELETE_RECORDS", me, {
                        request : {
                            context : me,
                            handler : me.onDeleteRecordsComplete,
                            records: deleteRecords,
                            params : {
                                d : d,
                                records: deleteRecords
                            }
                        }
                });
                com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);

            });
            return d;
        },

        onDeleteRecordsComplete : function(success, params){
            if(!success){
                // TODO
            }else{
                if(params.records){
                    for(var i = 0; i < params.records.length; i++){
                        this.__removeSyncLogRecord(params.records[i].id);
                        this.__removeSyncConflictRecord(params.records[i].id);
                    }
                }
                if(params.d){
                    params.d.resolve();
                }
            }
        },

        __buildInsertSyncTree : function(recordIds){
            var me = this;
            var d = SVMX.Deferred();
            var syncTree = [];
            // Locations
            me.__selectSyncRecords(
                SVMX.getCustomObjectName("Site"), 'insert', recordIds
            )
            .then(function(locations){
                var objectName = SVMX.getCustomObjectName("Site");
                me.__sortSyncRecords(objectName, syncTree, locations);
            })
            // SubLocations
            .then(function(){
                return me.__selectSyncRecords(
                    SVMX.getCustomObjectName("Sub_Location"), 'insert', recordIds
                );
            })
            .then(function(sublocations){
                var objectName = SVMX.getCustomObjectName("Sub_Location");
                me.__sortSyncRecords(objectName, syncTree, sublocations);
            })
            // IBs
            .then(function(){
                return me.__selectSyncRecords(
                    SVMX.getCustomObjectName("Installed_Product"), 'insert', recordIds
                );
            })
            .then(function(ibs){
                var objectName = SVMX.getCustomObjectName("Installed_Product");
                me.__sortSyncRecords(objectName, syncTree, ibs);
            })
            .then(function(ibs){
                d.resolve(syncTree);
            });
            return d;
        },

        __sortSyncRecords : function(objectName, syncTree, records){
            var parentField = SVMX.getCustomFieldName("Parent");
            var topLevel = syncTree.length;
            var allRecords = {};
            syncTree[topLevel] = [];
            syncTree[topLevel].objectName = objectName;
            for(var i = 0; i < records.length; i++){
                var record = records[i];
                allRecords[record.Id] = allRecords[record.Id] || {};
                allRecords[record.Id].record = record;
                var parentId = record[parentField];
                if(parentId){
                    allRecords[parentId] = allRecords[parentId] || {};
                    allRecords[parentId].children = allRecords[parentId].children || [];
                    allRecords[parentId].children.push(allRecords[record.Id]);
                    allRecords[record.Id].parent = allRecords[parentId];
                }
            }
            var keys = Object.keys(allRecords);
            for(var i = 0; i < keys.length; i++){
                var rec = allRecords[keys[i]];
                if(rec.record && (!rec.parent || !rec.parent.record)){
                    syncTree[topLevel].push(rec.record);
                    findAndSortChildRecords(rec.record, topLevel + 1);
                }
            }
            function findAndSortChildRecords(parent, level){
                for(var i = 0; i < records.length; i++){
                    var record = records[i];
                    if(record[parentField] === parent.Id){
                        if(!syncTree[level]){
                            syncTree[level] = [];
                            syncTree[level].objectName = objectName;
                        }
                        syncTree[level].push(record);
                        findAndSortChildRecords(record, level + 1);
                    }
                }
            }
        },

        __selectSyncRecords : function(objectName, operation, recordIds){
            var me = this;
            var d = SVMX.Deferred();
            var query = me._getQueryObject()
            .select("Id")
            .from("ClientSyncLog")
            .where("Operation = '"+operation+"'")
            .and("ObjectName = '"+objectName+"'")
            .and("(Pending IS NULL OR Pending != 'true')");
            if(recordIds !== undefined && recordIds.length){
            	query.and("Id in ('" + recordIds.join("','") + "')");
            }
            query.execute().done(function(results){
                if (!results.length){
                    d.resolve([]);
                    return;
                }
                var recordIds = [];
                for(var i = 0; i < results.length; i++){
                    recordIds.push(results[i].Id);
                }
                me._getQueryObject()
                .select("*")
                .from(objectName)
                .where("Id").within(recordIds)
                .execute().done(function(records){
                    d.resolve(records);
                });
            });
            return d;
        },

        __removeSyncLogRecord : function(recordId){
            return this._getQueryObject()
            .deleteFrom("ClientSyncLog")
            .where("Id").equals(recordId)
            .execute();
        },

        __removeSyncConflictRecord : function(recordId){
            return this._getQueryObject()
            .deleteFrom("ClientSyncConflict")
            .where("Id").equals(recordId)
            .execute();
        },
        
        __fetchInsertDependentRecordsFor : function(recordIds){
        	var d = SVMX.Deferred();
        	var me = this;
        	var allRecordIds = recordIds;
        	me.__fetchLocationsDependentRecordsFor(recordIds, allRecordIds).done(
    			function(allRecordIds){
    				me.__fetchSubLocationsDependentRecordsFor(recordIds, allRecordIds).done(
						function(allRecordIds){
							me.__fetchIBDependentRecordsFor(recordIds, allRecordIds).done(
								function(allRecordIds){
									d.resolve(allRecordIds);
								});
						});
    			});
        	return d;
        },
        
        __fetchLocationsDependentRecordsFor : function(recordIds, allRecordIds){
        	var me = this;
            var d = SVMX.Deferred();
            me._getQueryObject()
            .select(SVMX.getCustomFieldName("Parent"))
            .from(SVMX.getCustomObjectName("Site"))
            .where("Id in ('" + recordIds.join("','") + "')")
            .execute().done(function(results){
            	if(results && results.length){
            		var iRecs = 0, iRecLen = results.length;
            		var localRecs = [];
            		for(iRecs = 0; iRecs < iRecLen; iRecs++){
            			if(results[iRecs][SVMX.getCustomFieldName("Parent")] 
            							&& results[iRecs][SVMX.getCustomFieldName("Parent")].indexOf('transient-') !== -1 ){
            				if(allRecordIds.indexOf(results[iRecs][SVMX.getCustomFieldName("Parent")]) == -1){
            					allRecordIds.push(results[iRecs][SVMX.getCustomFieldName("Parent")]);
            					localRecs.push(results[iRecs][SVMX.getCustomFieldName("Parent")]);;
            				}
            			}
            		}
    				if(localRecs.length){
    					me.__fetchLocationsDependentRecordsFor(localRecs, allRecordIds).done(function(results){
    						d.resolve(results);
    					});
    				}else{
    					d.resolve(allRecordIds);
    				}                 		            		        		
            	}else{
            		d.resolve(allRecordIds);
            	}
            });
            return d;
        },
        
        __fetchSubLocationsDependentRecordsFor : function(recordIds, allRecordIds){
        	var me = this;
            var d = SVMX.Deferred();
            me._getQueryObject()
            .select([SVMX.getCustomFieldName("Parent"), SVMX.getCustomFieldName("Location")])
            .from(SVMX.getCustomObjectName("Sub_Location"))
            .where("Id in ('" + recordIds.join("','") + "')")
            .execute().done(function(results){
            	if(results && results.length){
            		var iRecs = 0, iRecLen = results.length;
            		var localRecs = [], localLocationRecs = [];
            		for(iRecs = 0; iRecs < iRecLen; iRecs++){
            			
            			if(results[iRecs][SVMX.getCustomFieldName("Location")] 
						&& results[iRecs][SVMX.getCustomFieldName("Location")].indexOf('transient-') !== -1 ){
							if(allRecordIds.indexOf(results[iRecs][SVMX.getCustomFieldName("Location")]) === -1){
								allRecordIds.push(results[iRecs][SVMX.getCustomFieldName("Location")]);
								localLocationRecs.push(results[iRecs][SVMX.getCustomFieldName("Location")]);;
							}
						}
            			if(results[iRecs][SVMX.getCustomFieldName("Parent")] 
            							&& results[iRecs][SVMX.getCustomFieldName("Parent")].indexOf('transient-') !== -1 ){
            				if(allRecordIds.indexOf(results[iRecs][SVMX.getCustomFieldName("Parent")]) === -1){
            					allRecordIds.push(results[iRecs][SVMX.getCustomFieldName("Parent")]);
            					localRecs.push(results[iRecs][SVMX.getCustomFieldName("Parent")]);;
            				}
            			}
            		}
            		
            		if(localLocationRecs.length){
            			//resolve locations and then sublocations
            			me.__fetchLocationsDependentRecordsFor(localLocationRecs, allRecordIds).done(function(results){
            				me.__fetchSubLocationsDependentRecordsFor(localRecs, results).done(function(results){
        						d.resolve(results);
        					});
    					});
            		}else if(localRecs.length){
            			//resolve sublocations
    					me.__fetchSubLocationsDependentRecordsFor(localRecs, allRecordIds).done(function(results){
    						d.resolve(results);
    					});
    				}else{
    					d.resolve(allRecordIds);
    				}            		            		        		
            	}else{
            		d.resolve(allRecordIds);
            	}
            });
            return d;
        },
        
        __fetchIBDependentRecordsFor : function(recordIds, allRecordIds){
        	var me = this;
            var d = SVMX.Deferred();
            me._getQueryObject()
            .select([SVMX.getCustomFieldName("Parent"), SVMX.getCustomFieldName("Top_Level"), 
                     								SVMX.getCustomFieldName("Site"), SVMX.getCustomFieldName("Sub_Location")])
            .from(SVMX.getCustomObjectName("Installed_Product"))
            .where("Id in ('" + recordIds.join("','") + "')")
            .execute().done(function(results){
            	if(results && results.length){
            		var iRecs = 0, iRecLen = results.length;
            		var localRecs = [], localLocationRecs = [], localSubLocRecs = [];
            		for(iRecs = 0; iRecs < iRecLen; iRecs++){
            			
            			if(results[iRecs][SVMX.getCustomFieldName("Site")] 
						&& results[iRecs][SVMX.getCustomFieldName("Site")].indexOf('transient-') !== -1 ){
							if(allRecordIds.indexOf(results[iRecs][SVMX.getCustomFieldName("Site")]) === -1){
								allRecordIds.push(results[iRecs][SVMX.getCustomFieldName("Site")]);
								localLocationRecs.push(results[iRecs][SVMX.getCustomFieldName("Site")]);
							}
						}
            			if(results[iRecs][SVMX.getCustomFieldName("Parent")] 
            							&& results[iRecs][SVMX.getCustomFieldName("Parent")].indexOf('transient-') !== -1 ){
            				if(allRecordIds.indexOf(results[iRecs][SVMX.getCustomFieldName("Parent")]) === -1){
            					allRecordIds.push(results[iRecs][SVMX.getCustomFieldName("Parent")]);
            					localRecs.push(results[iRecs][SVMX.getCustomFieldName("Parent")]);
            				}
            			}
            			
            			if(results[iRecs][SVMX.getCustomFieldName("Top_Level")] 
										&& results[iRecs][SVMX.getCustomFieldName("Top_Level")].indexOf('transient-') !== -1 ){
							if(allRecordIds.indexOf(results[iRecs][SVMX.getCustomFieldName("Top_Level")]) === -1){
								allRecordIds.push(results[iRecs][SVMX.getCustomFieldName("Top_Level")]);
								localRecs.push(results[iRecs][SVMX.getCustomFieldName("Top_Level")]);
							}
        				}
            			
            			if(results[iRecs][SVMX.getCustomFieldName("Sub_Location")] 
										&& results[iRecs][SVMX.getCustomFieldName("Sub_Location")].indexOf('transient-') !== -1 ){
							if(allRecordIds.indexOf(results[iRecs][SVMX.getCustomFieldName("Sub_Location")]) === -1){
								allRecordIds.push(results[iRecs][SVMX.getCustomFieldName("Sub_Location")]);
								localSubLocRecs.push(results[iRecs][SVMX.getCustomFieldName("Sub_Location")]);
							}
        				}            			
            		}
            		
            		if(localLocationRecs.length){
            			//resolve locations and then sublocations
            			me.__fetchLocationsDependentRecordsFor(localLocationRecs, allRecordIds).done(function(results){
            				me.__fetchSubLocationsDependentRecordsFor(localSubLocRecs, results).done(function(results){
            					me.__fetchIBDependentRecordsFor(localRecs, results).done(function(results){
            						d.resolve(results);
            					});
        					});
    					});
            		}else if(localSubLocRecs.length){
            			//resolve sublocations
    					me.__fetchSubLocationsDependentRecordsFor(localSubLocRecs, allRecordIds).done(function(results){
    						me.__fetchIBDependentRecordsFor(localRecs, results).done(function(results){
        						d.resolve(results);
        					});
    					});
    				}else if(localRecs.length){
            			//resolve ibs
    					me.__fetchIBDependentRecordsFor(localRecs, allRecordIds).done(function(results){
    						d.resolve(results);
    					});
    				}else{
    					d.resolve(allRecordIds);
    				}            		            		        		
            	}else{
            		d.resolve(allRecordIds);
            	}
            });
            return d;
        },

        __putInsertRecords : function(syncTree){
            var me = this;
            var d = SVMX.Deferred();

            syncNextLevel(0);

            function syncNextLevel(level){
                if(!syncTree[level] || !syncTree[level].length){
                    if(syncTree[level + 1] !== undefined){
                        // Continue
                        syncNextLevel(level + 1);
                    } else {
                        // Finished
                        d.resolve();
                    }
                    return;
                }
                var objectName = syncTree[level].objectName;
                me.__putInsertRecordsBatchLevel(objectName, syncTree[level])
                .done(function(insertRecordIds){
                    var replaceRefHandler = null;
                    if(objectName === SVMX.getCustomObjectName("Site")){
                        replaceRefHandler = me.__replaceLocationReferences;
                    }else if(objectName === SVMX.getCustomObjectName("Sub_Location")){
                        replaceRefHandler = me.__replaceSubLocationReferences;
                    }else if(objectName === SVMX.getCustomObjectName("Installed_Product")){
                        replaceRefHandler = me.__replaceIBReferences;
                    }
                    me._service.getSyncState().insertRecordsMap = 
                    		me._service.getSyncState().insertRecordsMap.concat(insertRecordIds);
                    replaceRefHandler.call(me, insertRecordIds, syncTree, level)
                    .done(function(){
                        // Continue
                        syncNextLevel(level + 1);
                    });
                });
            }
            return d;
        },

        __putInsertRecordsBatchLevel : function(objectName, records){
            var me = this;
            var d = SVMX.Deferred();
            var batchSize = 100;
            if(!records || !records.length){
                d.resolve();
                return d;
            }
            var insertRecords = [];
            for(var i = 0; i < records.length; i++){
                var record = records[i];
                if(SVMX.toJSON(record).replace('"Id":"transient-', '').indexOf('"transient-') === -1){
                    insertRecords.push(record);
                }else{
                    me._service.getSyncState().conflicted.push(record.Id);
                }
            }
            this.__filterInsertRecords(objectName, insertRecords)
            .done(function(insertRecords){
                var insertRecordIds = [];
                insertNextBatch();
                function insertNextBatch(index){
                    var indexStart = index || 0;
                    var indexEnd = indexStart + batchSize;
                    var origRecords = records.slice(indexStart, indexEnd);
                    var batchRecords = insertRecords.slice(indexStart, indexEnd);
                    if(!batchRecords.length){
                        // Finished
                        d.resolve(insertRecordIds);
                        return;
                    }
                    me._doHttpServiceRequest({
                        name : "insertRecords",
                        data : {
                            records : batchRecords
                        }
                    })
                    .done(function(resp){
                        for(var i = 0; i < resp.data.recordsStatus.length; i++){
                            var status = resp.data.recordsStatus[i];
                            // TODO: change to status.localId when ready
                            var localId = status.localId || origRecords[i].Id;
                            if(status.success){
                                insertRecordIds.push({
                                    localId : localId,
                                    remoteId : status.recId
                                });
                                me.__removeSyncConflictRecord(localId);
                                me.__removeSyncLogRecord(localId);
                            }else{
                                me._getQueryObject()
                                .replaceInto("ClientSyncConflict")
                                .columns([
                                    {name : "Id"},
                                    {name : "ObjectName"},
                                    {name : "Message"},
                                    {name : "Type"},
                                    {name : "CreatedDate"},
                                    {name : "Action"}
                                ])
                                .values({
                                    Id : localId,
                                    ObjectName : objectName,
                                    Message : status.message,
                                    Type : 'error',
                                    CreatedDate : new Date().toISOString(),
                                    Action : ""
                                })
                                .execute().done(function(resp){
                                    //
                                });
                            }
                        }
                        // Continue
                        insertNextBatch(indexEnd);
                    });
                }
            });
            return d;
        },

        __filterInsertRecords : function(objectName, records){
            var d = SVMX.Deferred();
            this._getSObjectInfo(objectName)
            .done(function(objectInfo){
                var insertFields = [];
                for(var i = 0; i < objectInfo.fields.length; i++){
                    var field = objectInfo.fields[i];
                    if(field.createable){
                        insertFields.push(field);
                    }
                }
                var insertRecords = [];
                for(var i = 0; i < records.length; i++){
                    var record = records[i];
                    var insertRecord = {
                        attributes: {
                            type: objectName
                        }
                    };
                    for(var j = 0; j < insertFields.length; j++){
                        var fieldName = insertFields[j].name;
                        if(record[fieldName]){
                            insertRecord[fieldName] = record[fieldName];
                        }
                    }
                    insertRecords.push(insertRecord);
                }
                d.resolve(insertRecords);
            });
            return d;
        },

        __filterUpdateRecords : function(objectName, records){
            var d = SVMX.Deferred();
            this._getSObjectInfo(objectName)
            .done(function(objectInfo){
                var updateFields = [];
                var filterFields = [
                    "SystemModstamp", "LastReferencedDate", "LastViewedDate", "LastActivityDate", "CreatedDate", "CreatedById", "LastModifiedById", "LastModifiedDate", "OwnerId"
                ];
                for(var i = 0; i < objectInfo.fields.length; i++){
                    var field = objectInfo.fields[i];
                    if(field.updateable && filterFields.indexOf(field.name) === -1){
                        updateFields.push(field);
                    }
                }
                var updateRecords = [];
                for(var i = 0; i < records.length; i++){
                    var record = records[i];
                    var updateRecord = {
                        attributes: {
                            type: objectName
                        }
                    };
                    updateRecord.Id = record.Id;
                    for(var j = 0; j < updateFields.length; j++){
                        var field = updateFields[j];
                        var fieldName = field.name;
                        // Ignore empty date fields
                        if(field.type === "date" && !record[fieldName]){
                            continue;
                        }
                        updateRecord[fieldName] = record[fieldName];
                    }
                    updateRecords.push(updateRecord);
                }
                d.resolve(updateRecords);
            });
            return d;
        },

        __replaceLocationReferences : function(insertRecordIds, syncTree, level){
            var me = this;
            var d = SVMX.Deferred();
            if(!insertRecordIds || !insertRecordIds.length){
                d.resolve();
                return d;
            }
            me.__replaceLocalReferences({
                insertRecordIds : insertRecordIds,
                syncTree : syncTree,
                level : level,
                mappings : [
                    {
                        targetObject : SVMX.getCustomObjectName("Site"),
                        targetFields : [
                            "Id",
                            SVMX.getCustomFieldName("Parent")
                        ]
                    },
                    {
                        targetObject : SVMX.getCustomObjectName("Sub_Location"),
                        targetFields : [
                            SVMX.getCustomFieldName("Location")
                        ]
                    },
                    {
                        targetObject : SVMX.getCustomObjectName("Installed_Product"),
                        targetFields : [
                            SVMX.getCustomFieldName("Site")
                        ]
                    }
                ]
            })
            .done(function(){
                d.resolve();
            });
            return d;
        },

        __replaceSubLocationReferences : function(insertRecordIds, syncTree, level){
            var me = this;
            var d = SVMX.Deferred();
            if(!insertRecordIds || !insertRecordIds.length){
                d.resolve();
                return d;
            }
            me.__replaceLocalReferences({
                insertRecordIds : insertRecordIds,
                syncTree : syncTree,
                level : level,
                mappings : [
                    {
                        targetObject : SVMX.getCustomObjectName("Sub_Location"),
                        targetFields : [
                            "Id",
                            SVMX.getCustomFieldName("Parent")
                        ]
                    },
                    {
                        targetObject : SVMX.getCustomObjectName("Installed_Product"),
                        targetFields : [
                            SVMX.getCustomFieldName("Sub_Location")
                        ]
                    }
                ]
            })
            .done(function(){
                d.resolve();
            });
            return d;
        },

        __replaceIBReferences : function(insertRecordIds, syncTree, level){
            var me = this;
            var d = SVMX.Deferred();
            if(!insertRecordIds || !insertRecordIds.length){
                d.resolve();
                return d;
            }
            me.__replaceLocalReferences({
                insertRecordIds : insertRecordIds,
                syncTree : syncTree,
                level : level,
                mappings : [
                    {
                        targetObject : SVMX.getCustomObjectName("Installed_Product"),
                        targetFields : [
                            "Id",
                            SVMX.getCustomFieldName("Top_Level"),
                            SVMX.getCustomFieldName("Parent")
                        ]
                    }
                ]
            })
            .done(function(){
                d.resolve();
            });
            return d;
        },

        __replaceLocalReferences : function(params){
            var me = this;
            var d = SVMX.Deferred();
            for(var i = 0; i < params.mappings.length; i++){
                var map = params.mappings[i];
                // 1) Replace references in sync tree
                for(var j = params.level; j < params.syncTree.length; j++){
                    var syncRecords = params.syncTree[j];
                    if(syncRecords.objectName !== map.targetObject){
                        continue;
                    }
                    var dependentSyncRecordIndexes = [];
                    for(var k = 0; k < params.insertRecordIds.length; k++){
                        var insertRecord = params.insertRecordIds[k];
                        for(var l = 0; l < syncRecords.length; l++){
                            var syncRecord = syncRecords[l];
                            for(var m = 0; m < map.targetFields.length; m++){
                                var mapField = map.targetFields[m];
                                if(syncRecord[mapField] === insertRecord.localId){
                                    if(insertRecord.error){
                                        // Index dependent records for removal
                                        dependentSyncRecordIndexes.push(l);
                                    }else{
                                        syncRecord[mapField] = insertRecord.remoteId;
                                    }
                                }
                            }
                        }
                    }
                    // Remove dependent records from syncTree
                    for(var k = 0; k < dependentSyncRecordIndexes.length; k++){
                        var idx = dependentSyncRecordIndexes[k];
                        syncRecords.splice(idx, 1);
                    }
                }
                // 2) Replace references in database
                var counter = 0;
                for(var k = 0; k < params.insertRecordIds.length; k++){
                    var insertRecord = params.insertRecordIds[k];
                    if(insertRecord.error){
                        continue;
                    }
                    for(var m = 0; m < map.targetFields.length; m++){
                        var mapField = map.targetFields[m];
                        counter++;
                        me._getQueryObject()
                        .update(map.targetObject)
                        .setValue(mapField).equals(insertRecord.remoteId)
                        .where(mapField).equals(insertRecord.localId)
                        .execute().done(function(){
                            counter--;
                            if(counter === 0){
                                d.resolve();
                            }
                        });
                    }
                }
            }
            return d;



            /*var replaceRecords = [];
            for(var i = 0; i < insertRecordIds.length; i++){
                var localId = insertRecordIds[i].localId;
                var remoteId = insertRecordIds[i].remoteId;
                for(var j = 0; j < localRecords.length; j++){
                    var localRecord = localRecords[j];
                    if(localRecord[fieldName] === localId){
                        replaceRecords.push({
                            Id : localRecord.Id,
                            field : fieldName,
                            value : remoteId
                        });
                        localRecord[fieldName] = remoteId;
                    }
                }
            }
            return replaceRecords;*/
        },

        __replaceDatabaseReferences : function(objectName, syncTreeLevel, insertRecordIds, replaceFields){
            /*var d = SVMX.Deferred();
            var replaceRecords = [];
            for(var i = 0; i < replaceFields.length; i++){
                var field = replaceFields[i];
                replaceRecords = replaceRecords.concat(this.__replaceLocalReferences(field, insertRecordIds, syncTreeLevel);
            }
            if(!replaceRecords.length){
                d.resolve();
                return d;
            }
            var counter = 0;
            for(var i = 0; i < replaceRecords.length; i++){
                var record = replaceRecords[i];
                this.__removeSyncLogRecord(record.Id);
                this._getQueryObject()
                .update(objectName)
                .setValue(record.field).equals(record.value)
                .where("Id").equals(record.Id)
                .execute().done(function(){
                    counter++;
                    if(counter === replaceRecords.length){
                        d.resolve();
                    }
                });
            }
            return d;*/
        },

        __getDeleteRecords : function(){
            // Locations
            var d1 = this.__getDeleteRecordsBatch(SVMX.getCustomObjectName("Site"));
            // SubLocations
            var d2 = this.__getDeleteRecordsBatch(SVMX.getCustomObjectName("Sub_Location"));
            // IBs
            var d3 = this.__getDeleteRecordsBatch(SVMX.getCustomObjectName("Installed_Product"));
            return $.when(d1, d2, d3);
        },

        __getDeleteRecordsBatch : function(objectName){
            var me = this;
            var d = SVMX.Deferred();
            var batchSize = 100;

            syncNextBatch(0);
            function syncNextBatch(batch){
                var query = me._getQueryObject()
                    .select("Id")
                    .from(objectName)
                    .where("IsDeleted = True"
                        +" AND LastModifiedDate > "+me.__lastDataSyncTime
                        +" LIMIT "+batchSize+" OFFSET "+(batch*batchSize)).q();
                me._doHttpGetQueryAll(query)
                .done(function(resp){
                    var records = resp.data.records;
                    if(!records.length){
                        // Finished
                        d.resolve();
                        return;
                    }
                    var responseCount = 0;
                    for(var i = 0; i < records.length; i++){
                        me._getQueryObject()
                            .deleteFrom(objectName)
                            .where("Id").equals(records[i].Id)
                            .execute().done(function(){
                                responseCount++;
                                if(responseCount === records.length){
                                    syncNextBatch(batch + 1);
                                }
                            });
                    }
                });
            }
            return d;
        },

        __putUpdateRecords : function(){
            // Locations
            var d1 = this.__putUpdateRecordsBatch(SVMX.getCustomObjectName("Site"));
            // SubLocations
            var d2 = this.__putUpdateRecordsBatch(SVMX.getCustomObjectName("Sub_Location"));
             // IBs
            var d3 = this.__putUpdateRecordsBatch(SVMX.getCustomObjectName("Installed_Product"));
            return $.when(d1, d2, d3);
        },

        __putUpdateRecordsBatch : function(objectName){
            var me = this;
            var d = SVMX.Deferred();
            var batchSize = 100;
            var updatedRecords = [];
            // TODO: sync log for updated records
            var qo = me._getQueryObject()
            .select("c1.Id, c1.ObjectName")
            .from("ClientSyncLog c1 LEFT JOIN ClientSyncConflict c2 ON c1.Id = c2.Id")
            .where("c1.Operation = 'update'")
            .and("(c2.Id IS NULL OR c2.Action = 'CLIENT_OVERRIDE' OR c2.Action = '')")
            .and("c1.ObjectName = '"+objectName+"'")
            .and("(c1.Pending != 'true' OR c1.Pending IS NULL)");
            qo.execute().done(function(results){
                me.__getRecordsFromSyncLogResults(results)
                .done(function(records){
                    if(!records){
                        d.resolve();
                        return;
                    }
                    me.__filterUpdateRecords(objectName, records)
                    .done(function(updatedRecordsTemp){
                        updatedRecords = [];
                        for(var i = 0; i < updatedRecordsTemp.length; i++){
                            var record = updatedRecordsTemp[i];
                            if(SVMX.toJSON(record).indexOf('"transient-') === -1){
                                updatedRecords.push(record);
                            }else{
                                me._service.getSyncState().conflicted.push(record.Id);
                            }
                        }
                        syncNextBatch();
                    });
                });
            });

            function syncNextBatch(){
                var batchRecords = updatedRecords.splice(0, batchSize);
                if(!batchRecords.length){
                    d.resolve();
                    return;
                }
                me._doHttpServiceRequest({
                    name : "updateRecords",
                    data : {
                        lastSyncTimestamp : me.__lastDataSyncTime,
                        updateRecordsList : [{
                            objectName : objectName,
                            records : batchRecords
                        }]
                    }
                })
                .done(function(resp){
                    // Handle conflicts/errors from server
                    if(resp && resp.data && resp.data.recordsStatus){
                        var keys = Object.keys(resp.data.recordsStatus);
                        for(var i = 0; i < keys.length; i++){
                            var key = keys[i];
                            var status = resp.data.recordsStatus[key];
                            if(status.success){
                                me.__removeSyncLogRecord(status.recId);
                                me.__removeSyncConflictRecord(status.recId);
                            }else{
                                var type = "error";
                                var action = "CLIENT_OVERRIDE";
                                if(status.message === "LMD conflict"){
                                    type = "conflict";
                                    status.message = "Conflict: Record modified online";
                                    action = "";
                                }
                                me._getQueryObject()
                                .replaceInto("ClientSyncConflict")
                                .columns([
                                    {name : "Id"},
                                    {name : "ObjectName"},
                                    {name : "Message"},
                                    {name : "Type"},
                                    {name : "CreatedDate"},
                                    {name : "Action"}
                                ])
                                .values({
                                    Id : status.recId,
                                    ObjectName : objectName,
                                    Message : status.message,
                                    Type : type,
                                    CreatedDate : new Date().toISOString(),
                                    Action : action
                                })
                                .execute().done(function(resp){
                                    //
                                });
                            }
                        }
                    }
                    // Continue
                    syncNextBatch();
                });
            }
            return d;
        },

        __putUpdateConflicts : function(){
            var me = this;
            var d = SVMX.Deferred();
            me._getQueryObject()
            .select("Id, ObjectName")
            .from("ClientSyncConflict")
            .where("Action = 'SERVER_OVERRIDE'")
            .execute().done(function(results){
                me.__getRecordsFromSyncLogResults(results)
                .done(function(records){
                    if(!records){
                        d.resolve();
                        return;
                    }
                    var counter = 0;
                    for(var i = 0; i < records.length; i++) {
                        var record = records[i];
                        var objectName = null;
                        for(var j = 0; j < results.length; j++){
                            if(results[j].Id === record.Id){
                                objectName = results[j].ObjectName;
                                break;
                            }
                        }
                        me.__restoreRecordFromServer(objectName, record.Id)
                        .done(function(){
                            counter++;
                            if(counter === records.length){
                                d.resolve();
                            }
                        });
                    }
                });
            });
            return d;
        },

        __restoreRecordFromServer : function(objectName, recordId){
            var me = this;
            var d = SVMX.Deferred();
            this.__getObjectInfoCached(objectName)
            .done(function(objectInfo){
                var allfields = me._getAttributeArrayFromCollection(objectInfo.fields, "name");
                var queryString = me._getQueryObject()
                .select(allfields)
                .from(objectInfo.name)
                .where("Id").equals(recordId)
                .q();
                me._downloadRecords(objectInfo.name, queryString, d);
                d.done(function(){
                    me.__removeSyncLogRecord(recordId);
                    me.__removeSyncConflictRecord(recordId);
                });
            });
            return d;
        },

        __getObjectInfoCached : function(objectName){
            var me = this;
            var d = SVMX.Deferred();
            if(this.__objectInfoCache && this.__objectInfoCache[objectName]){
                d.resolve(this.__objectInfoCache[objectName]);
                return d;
            }
            this._getSObjectInfo(objectName)
            .done(function(objectInfo){
                me.__objectInfoCache = me.__objectInfoCache || {};
                me.__objectInfoCache[objectName] = objectInfo;
                d.resolve(objectInfo);
            });
            return d;
        },

        __getUpdateRecords : function(){
            var me = this;
            var d = SVMX.Deferred();
            var params = {};
            this.__getIBsForUpdate()
            .then(function(ibs){
                // Download IBs
                params.IBs = ibs;
                return me.__getUpdateFromIncrementalSyncProvider("IBSyncProvider", params);
            })
            .then(function(){
                // Download IB Templates
                return me.__getUpdateFromIncrementalSyncProvider("IBTemplateSyncProvider", params);
            })
            .then(function(){
                // Download Locations
                return me.__getUpdateFromIncrementalSyncProvider("LocationSyncProvider", params);
            })
            .then(function(){
                // Download Products
                return me.__getUpdateFromIncrementalSyncProvider("ProductSyncProvider", params);
            })
            .then(function(){
                // Download Accounts
                return me.__getUpdateFromIncrementalSyncProvider("AccountSyncProvider", params);
            })
            .then(function(){
                // Download Record Names
                return me.__getUpdateFromIncrementalSyncProvider("RecordNameSyncProvider", params);
            })
            .then(function(){
                d.resolve();
            });
            return d;
        },

        __getUpdateFromIncrementalSyncProvider : function(className, params){
            params = params || {};
            params.lastDataSyncTime = this.__lastDataSyncTime;
            return SVMX.create("com.servicemax.client.installigence.sync.service.impl."+className,
                {service : this._service, link : this._link})
                .run(params, eSyncType.INCREMENTAL);
        },

        __getIBsForUpdate : function(){
            var d = SVMX.Deferred();
            this._getQueryObject()
            .select("ib.Id")
            .from(SVMX.getCustomObjectName("Installed_Product")
                +" ib LEFT JOIN ClientSyncLog cl ON ib.Id = cl.Id")
            .where(SVMX.getCustomFieldName("Top_Level")+" = ''")
            .and("cl.Id IS NULL")
            .execute().done(function(results){
                var ibs = [];
                for(var i = 0; i < results.length; i++){
                    ibs.push(results[i].Id);
                }
                d.resolve(ibs);
            });
            return d;
        },

        __getRecordsFromSyncLogResults : function(results){
            var me = this;
            var d = SVMX.Deferred();
            if (!results.length){
                d.resolve();
                return d;
            }
            var recordIdsByObject = {};
            for(var i = 0; i < results.length; i++){
                var obj = results[i].ObjectName;
                recordIdsByObject[obj] = recordIdsByObject[obj] || [];
                recordIdsByObject[obj].push(results[i].Id);
            }
            var counter = 0;
            var records = [];
            var objectNames = Object.keys(recordIdsByObject);
            for(var i = 0; i < objectNames.length; i++){
                var objectName = objectNames[i];
                me._getQueryObject()
                .select("*")
                .from(objectName)
                .where("Id").within(recordIdsByObject[objectName])
                .execute().done(function(result){
                    records = records.concat(result);
                    counter++;
                    if(counter === objectNames.length){
                        d.resolve(records);
                    }
                });
            }
            return d;
        }

    }, {});

    syncServiceImpl.Class("DBSchema", com.servicemax.client.lib.api.Object, {}, {
        metaTables : [
            { name : "ObjectDescribe", isConfig : true, columns : [
                  {name : "ObjectName", type : "VARCHAR", isUnique : true},
                  {name : "DescribeResult", type : "VARCHAR"}
            ] },
            
            { name : "FieldDescribe", isConfig : true, columns : [
                  {name : "FieldName", type : "VARCHAR"},
                  {name : "DescribeResult", type : "VARCHAR"}
            ] },
            
            { name : "Configuration", isConfig : true, columns : [
                  {name : "Type", type : "VARCHAR"},
                  {name : "Key", type : "VARCHAR"},
                  {name : "Value", type : "VARCHAR"}
            ] },

            { name : "RecordName", columns : [
                  {name : "Id", type : "VARCHAR", isUnique : true},
                  {name : "Name", type : "VARCHAR"}
            ] },

            { name : "ClientCache", columns : [
                  {name : "Key", type : "VARCHAR", isUnique : true},
                  {name : "Value", type : "VARCHAR"}
            ] },

            { name : "ClientSyncLog", columns : [
                  {name : "Id", type : "VARCHAR", isUnique : true},
                  {name : "ObjectName", type : "VARCHAR"},
                  {name : "Operation", type : "VARCHAR"},
                  {name : "LastModifiedDate", type : "VARCHAR"},
                  {name : "Pending", type : "VARCHAR"}
            ] },

            { name : "ClientSyncLogTransient", columns : [
                  {name : "Id", type : "VARCHAR", isUnique : true},
                  {name : "ObjectName", type : "VARCHAR"},
                  {name : "Operation", type : "VARCHAR"},
                  {name : "LastModifiedDate", type : "VARCHAR"},
                  {name : "Pending", type : "VARCHAR"}
            ] },

            { name : "ClientSyncConflict", columns : [
                  {name : "Id", type : "VARCHAR", isUnique : true},
                  {name : "ObjectName", type : "VARCHAR"},
                  {name : "Type", type : "VARCHAR"},
                  {name : "Message", type : "VARCHAR"},
                  {name : "CreatedDate", type : "VARCHAR"},
                  {name : "Action", type : "VARCHAR"}
            ] },

            { name : "SyncDependentLog", columns : [
                  {name : "local_id", type : "VARCHAR"},
                  {name : "parent_object_name", type : "VARCHAR"},
                  {name : "parent_record_id", type : "VARCHAR"},
                  {name : "parent_field_name", type : "VARCHAR"},
                  {name : "sfdc_Id", type : "VARCHAR"}
            ] }
        ],
        
        dataTables : [
            { name : SVMX.getCustomObjectName("Installed_Product")},
            { name : SVMX.getCustomObjectName("Site")},
            { name : SVMX.getCustomObjectName("Sub_Location")},
            { name : "Account"},
            { name : "Product2"}
        ],

        getConfigTables : function(){
            var metaTables = syncServiceImpl.DBSchema.metaTables;
            var configTables = [];
            for(var i = 0; i < metaTables.length; i++){
                if(metaTables[i].isConfig){
                    configTables.push(metaTables[i]);
                }
            }
            return configTables;
        },
        
        getMetaTableSchema : function(name){
            var i, metaTables = syncServiceImpl.DBSchema.metaTables, l = metaTables.length;
            for(i = 0; i < l; i++){
                if(metaTables[i].name == name) return metaTables[i];
            }
            return null;
        }
    });
};
})();

// end of file