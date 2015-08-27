/**
 * 
 */
(function(){
    var utilsImpl = SVMX.Package("com.servicemax.client.installigence.offline.model.utils");
    
    utilsImpl.Class("Query", com.servicemax.client.lib.api.Object, {
        __q : null, __logger : null, __insertColumns : null, __multiQueries : null, __multiQueryIndex : 0,
        
        __constructor : function(options){ 
            this.__base(); 
            this.__logger = SVMX.getLoggingService().getLogger();
            this.__q = ""; 
            if(options && options.query) this.__q = options.query;
        },
        
        query : function(query){
        	this.__q = query;
        	return this;
        },

        clone : function(){
            var nq = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            for(var key in this){
                nq[key] = this[key];
            }
            return nq;
        },
        
        update : function(tableName){
            this.__q = "UPDATE `" + tableName + "` ";
            return this;
        },

        setValue : function(name){
            this.__q += " SET " + name;
            return this;
        },

        andSetValue : function(name){
            this.__q += " , " + name;
            return this;
        },

        equals : function(value){
            this.__q += " = '" + value + "'";
            return this;
        },

        select : function(fields){
            if(!(fields instanceof Array)) fields = [fields];
            
            this.__q = "SELECT " + fields.join(",");
            return this;
        },

        selectDistinct : function(fields){
            if(!(fields instanceof Array)) fields = [fields];
            
            this.__q = "SELECT DISTINCT " + fields.join(",");
            return this;
        },
        
        from : function(objects){
            if(!(objects instanceof Array)) objects = [objects];
            
            this.__q += " FROM " + objects.join(","); 
            return this;
        },

        deleteFrom : function(object){

            this.__q = "DELETE FROM "+object;
            return this;
        },
        
        where : function(condition){
            if(this.__whered){
                this.__q += " AND " + condition;
            }else{
                this.__q += " WHERE " + condition;
                this.__whered = true;
            }
            return this;
        },
        
        within : function(input){
            if(typeof(input) == 'string'){
                this.__q += " IN ('" + input + "')";
            }else if(input instanceof Array){
                this.__q += " IN ('" + input.join("','") + "')";
            }else{
                // if it is query object
                if(input.q){
                    var queryString = input.q();
                    if(queryString instanceof Array ){
                        var i, l = queryString.length;
                        var qArray = [];
                        for(i = 0; i < l; i++){
                            qArray.push( this.__q +" IN (" + queryString[i] + ")" );
                        }
                        this.__q = qArray;
                    }else{
                        this.__q += " IN (" + queryString + ")";
                    }
                }
            }
            return this;
        },
        
        batchWithinIds : function(listOfIds){
            var list = [], i, l = listOfIds.length, currentList = [];
            for(i = 0; i < l; i++){
                currentList.push(listOfIds[i]);
                
                if((i+1)%200 == 0){
                    list.push(currentList);
                    currentList = [];
                }
            }
            
            if(currentList.length > 0) list.push(currentList);
            
            l = list.length;
            var qArray = [];
            for(i = 0; i < l; i++){
                if(this.__q instanceof Array){
                    // assumption is that batch length is same as query count!
                    // NOT USED
                    qArray.push( this.__q[i] +" IN ('" + list[i].join("','") + "')" );
                }else{
                    qArray.push( this.__q +" IN ('" + list[i].join("','") + "')" );
                }
            }
            
            this.__q = qArray;
            return this;
        },
        
        or : function(condition){
            if(this.__q instanceof Array){
                var i, l = this.__q.length;
                for(i = 0; i < l; i++){
                    this.__q[i] +=  " OR " + condition;
                }
            }else{
                this.__q += " OR " + condition;
            }
            return this;
        },
        
        and : function(condition){
            this.__q += " AND " + condition;
            return this;
        },
        
        orderBy : function(fields){
        	this.__q += " Order By " + fields;
        	return this;
        },
        
        like : function(value){
            this.__q += " LIKE '%" + value + "%'";
            return this;
        },
        
        q : function(){
            return this.__q;
        },
        
        limit : function(value){
            this.__q += " LIMIT " + value;
            return this;
        },

        offset : function(value){
            this.__q += " OFFSET " + value;
            return this;
        },
        
        insertInto : function(tableName){
            this.__q = "INSERT INTO `" + tableName + "`";
            return this;
        },

        insertIntoSelect : function(tableInsert, cols, tableSelect, fields){
            this.__q = "INSERT INTO `" + tableInsert + "` ";
            this.columns(cols);
            this.__q += " SELECT " + fields.join(",") + " FROM `" + tableSelect + "`";
            return this;
        },
        
        replaceInto : function(tableName){
            this.__q = "INSERT OR REPLACE INTO `" + tableName + "`";
            return this;
        },
        
        columns : function(cols){
            this.__insertColumns = cols;
            var sqlFields = [], i, l = cols.length;
            for(i = 0; i < l; i++){
                var c = cols[i];
                sqlFields.push(c.name);
            }
            this.__q +=  " ('" + sqlFields.join("','") + "')";
            return this;
        },
        
        values : function(records){
            if(!(records instanceof Array)) records = [records];
            
            var batchCount = 200;
            
            if(records.length > batchCount){
                this.__multiQueries = [];
                this.__multiQueryIndex = -1;
            }
            
            var allValues = [];
            var i, l = records.length;
            for(i = 0; i < l; i++){
                allValues.push(this.values2(records[i]));
                
                if(this.__multiQueries != null && (i + 1) % batchCount == 0){
                    this.__multiQueries.push( this.__q + " VALUES " + allValues.join(",") );
                    allValues = [];
                }
            }
            
            if(this.__multiQueries == null)
                this.__q += " VALUES " + allValues.join(",");
            else {
                if(allValues.length > 0){
                    this.__multiQueries.push( this.__q + " VALUES " + allValues.join(",") );
                }
                
                this.__q = this.__moveNext();
            }
            return this;
        },
        
        __moveNext : function(){
            if(this.__multiQueries == null) return null;
            
            this.__multiQueryIndex++;
            if(this.__multiQueryIndex < this.__multiQueries.length){
                return this.__multiQueries[this.__multiQueryIndex];
            }else{
                return null;
            }
        },

        values2 : function(values){
            var tmp = [];
            
            var i, columns = this.__insertColumns, l = columns.length, value;
            for(i = 0; i < l; i++){
                value = values[columns[i].name] || "";
                value = "'" + value + "'";
                
                if(typeof values[columns[i].name] === 'string'){
                    value = "'" + values[columns[i].name].replace(new RegExp("'", "g"), "''") + "'";
                }
                tmp.push(value);
            }
            
            return " (" + tmp.join(",") + ")";
        },
        
        replaceTable : function(oldTable, newTable, context){
            this.__q = "DROP TABLE IF EXISTS `"+newTable+"`;"
                + "ALTER TABLE `" + oldTable + "` RENAME TO `" + newTable + "`;";
            return this.execute(context);
        },

        dropTable : function(tableName, context){
            this.__q = "DROP TABLE IF EXISTS `"+tableName+"`;";
            return this.execute(context);
        },
        
        createTable : function(tableName, columns, context){
            var sqlFields = [], i, l = columns.length;
            var buf = null;
            
            // have an auto id always
            buf = ["'RecordId' ", "INTEGER", " PRIMARY KEY ", " AUTOINCREMENT "];
            sqlFields.push(buf.join(""));
            // end auto id
            
            for(i = 0; i < l; i++){
                var c = columns[i];
                buf = ["'", c.name, "' ", c.type];
                if(c.isUnique) buf.push(" UNIQUE ");
                if(c.isAuto) buf.push(" AUTOINCREMENT ");
                sqlFields.push(buf.join(""));
            }

            var createQuery = ["CREATE TABLE", "`" + tableName +"`", "(", sqlFields.join(","), ")"].join(" ");
            this.__q = "DROP TABLE IF EXISTS `" + tableName + "`; " + createQuery;
            return this.execute(context);
        },
        
        execute : function(context){
            var d = $.Deferred();
            this.executeInternal(this.q(), function(resp){
                if(context) d.resolveWith(context, resp);
                else d.resolve(resp);
            });
            return d;
        },
        
        executeInternal : function(q, cb){
            var f = com.servicemax.client.installigence.offline.sal.model.nativeservice.Facade;
            var r = f.createSQLRequest(), me = this;
            
            r.bind("REQUEST_COMPLETED", function(evt){
                doNext(evt.data.data);
            }, this);

            r.bind("REQUEST_ERROR", function(evt){
                this.__logger.error("Error QUERY: " + q);
                doNext([]);
            }, this);
            
            this.__logger.info("Executing QUERY: " + q.substring(0, q.length > 150?150:q.length));
            r.execute({ query : q });
            
            function doNext(resp){
                var nextQuery = me.__moveNext();
                if(nextQuery){
                    me.executeInternal(nextQuery, cb);
                }else{
                    cb.call(me, resp);
                }
            }
        }
    }, {});
    
    utilsImpl.Class("API", com.servicemax.client.lib.api.Object, {
        __logger : null, __method : null, __record : null, __criteria : null, __objectName : null, __recordIds : null,
        __constructor : function(){ 
            this.__base(); 
            this.__logger = SVMX.getLoggingService().getLogger();
            this.__method = "SELECT";
            this.__record = [];
            this.__criteria = [];
            this.__recordIds = [];
        },
        
        method: function(method){
        	this.__method = method;
        	return this;
        },
        
        objectName: function(objectName){
        	this.__objectName = objectName;
        	return this;
        },
        
        addField: function(name, value){
        	this.__record.push({"name": name, "value": value});
        	return this;
        },
        
        record: function(record){
        	this.__record = record;
        	return this;
        },
        
        recordIds: function(recordIds){
        	this.__recordIds = recordIds;
        	return this;
        },       
        
        criteria: function(criteria){
        	this.__criteria = criteria;
        	return this;
        },
        
        execute : function(context){
            var d = $.Deferred();
            this.executeInternal(function(resp){
                if(context) d.resolveWith(context, resp);
                else d.resolve(resp);
            });
            return d;
        },
        
        executeInternal: function(cb){
        	var me = this;
            //check the app exists
            var externalAppName = "LaptopMobile";
            me.__chkExternalAppExists(externalAppName)
            .done(function(appinfo){
                var app = SVMX.toObject(appinfo);
                if(app[0].Installed === "true"){
                    var service = SVMX.create("com.servicemax.client.installigence.sync.service.impl.Service", {});
                    service.getUserInfo()
                    .done(function(resp){
                    	                   	
                    	var request = {
                                objectName: me.__objectName,
                                fields: me.__record,
                                criteria: me.__criteria,
                                userName: resp.UserName,
                                recordIds: me.__recordIds
                        };

                        request.type = "DATAACCESSAPI";
                        request.method = me.__method;

                        var req = com.servicemax.client.installigence.offline.sal.model.nativeservice.Facade.createDataAccessAPIRequest();

                        req.bind("REQUEST_COMPLETED", function(evt){
                            cb(evt.data);
                        }, this);
                        req.bind("REQUEST_ERROR", function(evt){
                        	cb(evt.data);
                        }, this);
                        req.execute(request);
                    });
                } else {
                    responder.result([]);
                }

            });
        },
        
        __getFieldData: function(record){
        	var rec = record;
        	var fields = [];
        	for(var field in record){
        		fieldData = {};
        		fieldData.name = field;
        		fieldData.value = record[field];
        		fields.push(fieldData);
        	}
        	return fields;
        },       
        
        __chkExternalAppExists: function(appName){
            var d = SVMX.Deferred();
            var request = {
                    appName : appName
            };
            var req = com.servicemax.client.installigence.offline.sal.model.nativeservice.Facade.createCheckExternalRequest();
            req.bind("REQUEST_COMPLETED", function(evt){
                d.resolve(evt.data.data);
            }, this);
            req.bind("REQUEST_ERROR", function(evt){
                d.resolve({});
            }, this);
            req.execute(request);
            return d;
        }
        
        
    }, {});
    
    utilsImpl.Class("Http", com.servicemax.client.lib.api.Object, {
        __logger : null,
        __constructor : function(){ 
            this.__base(); 
            this.__logger = SVMX.getLoggingService().getLogger();
        },
        
        doGet : function(params){
            var d = $.Deferred();
            params.d = d;
            params.method = "GET";
            this._initRequest(params);
            return d;
        },

        doPost : function(params){
            var d = $.Deferred();
            params.d = d;
            params.method = "POST";
            this._initRequest(params);
            return d;
        },
        
        doHttpGetQuery : function(queryString){
            var apiVersion = SVMX.getClient().getApplicationParameter("sfdc-api-version") || "32.0";
            var url = "/services/data/v{{apiVersion}}/query?q={{queryString}}";
            url = SVMX.string.substitute(url, {
                apiVersion : apiVersion,
                queryString : encodeURI(queryString)
            });
            var httpObj = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Http", {});
            return httpObj.doGet({url : url});
        },

        _initRequest : function(params){
            var f = com.servicemax.client.installigence.offline.sal.model.nativeservice.Facade;
            var r = f.createHTTPRequest();
            
            r.bind("REQUEST_COMPLETED", function(evt){
                params.d.resolve(evt.data);
                /*if(window.HTTPFAILTEST){
                    this._handleError(evt, params);
                }else{
                    params.d.resolve(evt.data);
                }*/
            }, this);

            r.bind("REQUEST_ERROR", function(evt){
                this._handleError(evt, params);
            }, this);
            
            this._executeRequest(r, params);
        },

        _executeRequest : function(r, params){
            if(utilsImpl.Http.__resumeHandlers){
                var me = this;
                utilsImpl.Http.__addResumeHandler(function(){
                    me.__logger.info("Executing HTTP ("+params.method+"): " + params.url);
                    r.execute({
                        method : params.method,
                        url : params.url,
                        data : params.data,
                        headers : params.headers
                    });
                });
            }else{
                this.__logger.info("Executing HTTP ("+params.method+"): " + params.url);
                r.execute({
                    method : params.method,
                    url : params.url,
                    data : params.data,
                    headers : params.headers
                });
            }
        },

        _handleError : function(evt, params){
            var message = (typeof evt.data.data === "string") ? evt.data.data : "Unknown";
            this.__logger.error("Request error: "+params.url+" ("+message+") "+SVMX.toJSON(evt.data));

            //For Apex Errors
            if(SVMX.stringStartsWith(message, "InternalServerError ")){
                message = message.replace("InternalServerError ", "");
            }

            var headers = evt.data.headers;
            var isConnectionError = !headers || !headers.status || message.indexOf('UNKNOWN_EXCEPTION') !== -1;
            // Make sure the following status codes (403, 404, etc)
            // are not treated as connection errors
            var messageObj = {};
            try {
                messageObj = JSON.parse(message);
            } catch (e) {
                messageObj.StatusCode = "";
            }
            if(messageObj.constructor === Array){
                if(messageObj.length > 0){
                    if(messageObj[0].errorCode === "APEX_ERROR"){
                        var http = utilsImpl.Http;
                        params.errorMsg = messageObj[0].errorCode + ": " + messageObj[0].message;
                        isConnectionError = false;
                    }
                }
            }
            else{
                isConnectionError = ((isConnectionError) && (messageObj.StatusCode[0] !== "4" && messageObj.StatusCode[0] !== "5"));
            }
            this._retryRequest(params, isConnectionError);
        },

        _retryRequest : function(params, isConnectionError){
            var me = this;
            var http = utilsImpl.Http;
            if(params.requestAttempts >= 3){
                params.requestAttempts = 0;
                if(params.errorMsg && params.errorMsg.length > 0){
                    http.__triggerServerResponseErrorDialog(params.errorMsg);
                }
                else{
                    http.__triggerRequestErrorDialog();
                }
                http.__addResumeHandler(function(){
					params.errorMsg = "";
                    me._retryRequest(params);
                });
                return;
            }else{
                this._checkConnectivity()
                .done(function(isConnected){
                    if(isConnected){
                        if(isConnectionError){
                            params.connectAttempts = params.connectAttempts || 1;
                            params.connectAttempts++;
                            if(params.connectAttempts >= 3){
                                params.connectAttempts = 0;
                                http.__triggerConnectionWarningDialog();
                                http.__addResumeHandler(function(){
                                    me._retryRequest(params, true);
                                });
                            }else{
                                me.__logger.warn('Connection error. Retrying failed request...');
                                me._initRequest(params);
                            }
                        }else{
                            params.requestAttempts = params.requestAttempts || 1;
                            params.requestAttempts++;
                            me.__logger.warn('Server error. Retrying failed request...');
                            me._initRequest(params);
                        }
                    }else{
                        // pause http requests, and retry on resume
                        me.__logger.warn('Not connected, request stream paused...');
                        http.__triggerConnectionErrorDialog();
                        http.__addResumeHandler(function(){
                            me._retryRequest(params, true);
                        });
                    }
                });
            }
        },

        _checkConnectivity : function(){
            var d = SVMX.Deferred();
            var f = com.servicemax.client.installigence.offline.sal.model.nativeservice.Facade;
            var r = f.createConnectivityRequest();
            r.bind("REQUEST_COMPLETED", function(evt){
                var result = evt.data.data.toLowerCase();
                var isConnected = result === "true" ? true : false;
                d.resolve(isConnected);
            }, this);
            r.bind("REQUEST_ERROR", function(evt){
                d.resolve(false);
            }, this);
            r.execute();
            return d;
        }

    }, {

        __resumeHandlers : null,
        __connectionWatchers : null,

        pause : function(){
            utilsImpl.Http.__resumeHandlers = utilsImpl.Http.__resumeHandlers || [];
        },

        resume : function(){
            if(utilsImpl.Http.__resumeHandlers){
                var callback = null;
                while(callback = utilsImpl.Http.__resumeHandlers.shift()){
                    callback();
                }
                utilsImpl.Http.__resumeHandlers = null;
            }
        },

        cancel : function(){
            if(utilsImpl.Http.__connectionWatchers){
                var watchers = utilsImpl.Http.__connectionWatchers;
                for(var i = 0; i < watchers.length; i++){
                    watchers[i]();
                }
                delete utilsImpl.Http.__resumeHandlers;
                delete utilsImpl.Http.__connectionWatchers;
            }
        },

        onConnectionCanceled : function(callback){
            utilsImpl.Http.__connectionWatchers = utilsImpl.Http.__connectionWatchers || [];
            utilsImpl.Http.__connectionWatchers.push(callback);
        },

        offConnectionCanceled : function(callback){
            if(utilsImpl.Http.__connectionWatchers){
                var watchers = utilsImpl.Http.__connectionWatchers;
                for(var i = 0; i < watchers.length; i++){
                    if(watchers[i] === callback){
                        watchers.splice(i, 1);
                        i--;
                    }
                }
            }
        },

        __addResumeHandler : function(callback){
            if(utilsImpl.Http.__resumeHandlers){
                utilsImpl.Http.__resumeHandlers.push(callback);
            }else{
                callback();
            }
        },


        __triggerConnectionWarningDialog : function(callback){
            utilsImpl.Http.pause();
            SVMX.getCurrentApplication().showConnectionWarningDialog({
                onRetry : function(){
                    utilsImpl.Http.resume();
                },
                onCancel : function(){
                    utilsImpl.Http.cancel();
                }
            });
        },

        __triggerConnectionErrorDialog : function(callback){
            utilsImpl.Http.pause();
            SVMX.getCurrentApplication().showConnectionErrorDialog({
                onRetry : function(){
                    utilsImpl.Http.resume();
                },
                onCancel : function(){
                    utilsImpl.Http.cancel();
                }
            });
        },

        __triggerRequestErrorDialog : function(callback){
            utilsImpl.Http.pause();
            SVMX.getCurrentApplication().showRequestErrorDialog({
                onRetry : function(){
                    utilsImpl.Http.resume();
                },
                onCancel : function(){
                    utilsImpl.Http.cancel();
                }
            });
        },

        __triggerServerResponseErrorDialog : function(errorMessage, callback){
            utilsImpl.Http.pause();
            SVMX.getCurrentApplication().showRequestErrorDialog({
                errorMessage: errorMessage,
                onRetry : function(){
                    utilsImpl.Http.resume();
                },
                onCancel : function(){
                    utilsImpl.Http.cancel();
                }
            });
        }
    });
    
    utilsImpl.Class("Util", com.servicemax.client.lib.api.Object, {}, {
        getAllChildren4IB : function(id){
            var d = SVMX.Deferred();
            var queryTemplate = 
              "WITH RECURSIVE all_children(ids) AS ( "
            + "VALUES('{{parentId}}') "
            + "UNION "
            + "SELECT Id FROM {{objectName}}, all_children "
            + "WHERE {{objectName}}.{{fieldName}} = all_children.ids "
            + ") "
            + "SELECT Id FROM {{objectName}} WHERE {{objectName}}.Id IN all_children";

            var query = SVMX.string.substitute(queryTemplate, 
                {   parentId : id, 
                    objectName : SVMX.getCustomObjectName("Installed_Product"),
                    fieldName : SVMX.getCustomFieldName("Parent")
                }
            );

            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {
                query : query
            });

            qo.execute().done(function(resp){
                if(typeof(resp) == 'string'){
                    resp = SVMX.toObject(resp);
                }

                var i, l = resp.length, ret = [];
                for(i = 0; i < l; i++){
                    if(resp[i].Id != id){
                        ret.push(resp[i]);
                    }
                }
                d.resolve(ret);
            });
            return d;
        },

        getAllParents4IB : function(id){
            var d = SVMX.Deferred();
            var queryTemplate = 
              "WITH RECURSIVE all_parents(ids,  level, account, site) AS ( "
            + " SELECT Id, 1, {{companyFieldName}}, {{siteFieldName}}  from {{objectName}} where id = '{{nodeId}}' "
            + "UNION "
            + "SELECT a.{{parentFieldName}}, level + 1, a.{{companyFieldName}}, a.{{siteFieldName}} from {{objectName}} a, all_parents"
            + " where a.id = all_parents.ids"
            + ") "
            + "SELECT ids, level, account, site FROM all_parents a where a.ids != '' order by level";

            var query = SVMX.string.substitute(queryTemplate, 
                {   nodeId : id, 
                    objectName : SVMX.getCustomObjectName("Installed_Product"),
                    parentFieldName : SVMX.getCustomFieldName("Parent"),
                    companyFieldName : SVMX.getCustomFieldName("Company"),
                    siteFieldName : SVMX.getCustomFieldName("Site")
                }
            );

            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {
                query : query
            });

            qo.execute().done(function(resp){
                if(typeof(resp) == 'string'){
                    resp = SVMX.toObject(resp);
                }

                var i, l = resp.length, ret = [];
                for(i = 0; i < l; i++){
                    if(resp[i].Id != id){
                        ret.push(resp[i]);
                    }
                }
                d.resolve(ret);
            });
            return d;
        },

        getObjectDescribeByName : function(objectName){
            var d = SVMX.Deferred();
            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            qo.select('DescribeResult').from('ObjectDescribe')
            .where("ObjectName").equals(objectName)
            .execute().done(function(resp){
                if(resp && resp[0] && resp[0].DescribeResult){
                    var result = SVMX.toObject(resp[0].DescribeResult);
                    d.resolve(result);
                }else{
                    debugger;
                }
            });
            return d;
        },
        
        isTableInDatabase : function(tableName){
        	var d = SVMX.Deferred();
            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            qo.select('*').from('sqlite_master')
            .where("name").equals(tableName)
            .execute().done(function(resp){
                if(resp && resp[0] && resp[0].DescribeResult){
                    var result = SVMX.toObject(resp[0].DescribeResult);
                    d.resolve(result);
                }else{
                  var result = {}
                  d.resolve(result);
                }
            });
            return d;
        },
        
        getUserConfiguration : function(){
            var d = SVMX.Deferred();
            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            qo.select('Value').from('Configuration').where("Type = 'user'")
            .execute().done(function(resp){
                if(resp && resp[0] && resp[0].Value){
                    var result = SVMX.toObject(resp[0].Value);
                    d.resolve(result);
                }else{
                    debugger;
                }
            });
            return d;
        },

        getObjectNameByNodeType : function(nodeType){
            switch(nodeType){
                case "ACCOUNT":
                    return SVMX.getCustomObjectName("Account");
                case "LOCATION":
                    return SVMX.getCustomObjectName("Site");
                case "SUBLOCATION":
                    return SVMX.getCustomObjectName("Sub_Location");
                case "IB":
                    return SVMX.getCustomObjectName("Installed_Product");
            }
        }
    });
    
    utilsImpl.Class("GetRecords", com.servicemax.client.lib.api.Object, {
    	
    	fromServer : function(request){
    		var d = SVMX.Deferred();
    		var me = this;
    		this.__checkConnectivity().done(function(result){
    			if(result == "False"){
    				d.resolve([]);
    				return d;
    			}
    			var fields = request.fields;
                var fieldsDesc = request.fieldsDescribe;
                
                var fields  = me.__getQueryFields(fields, fieldsDesc);
                var queryObj = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                queryObj.select(fields).from(request.objectName);

                if(request.text){
                	var i = 0, l = request.searchFields.length;
                	searchQuery = "";
                	for(i = 0; i < l; i++){
                		if(i > 0) searchQuery += " OR ";
                		searchQuery = searchQuery + me.__getSearchableField(request.searchFields[i], fieldsDesc) 
                					+ " like '%" + request.text + "%'";
                		
                	}
                	if(searchQuery.length > 0){
                		searchQuery =  "(" + searchQuery + ")";
                		queryObj.where(searchQuery);
                	}
                	
                }
                
                var query = queryObj.q();                
                me._downloadRecords(query)
                .done(function(results){
                    com.servicemax.client.installigence.offline.model.utils.Http
                    .offConnectionCanceled(me.onConnectionCanceled);
                    	d.resolve(results);
                });
    		});    		
            
            // Catch canceled requests
            this.onConnectionCanceled = function() {
            	d.resolve([]);
            }
            com.servicemax.client.installigence.offline.model.utils.Http
            .onConnectionCanceled(this.onConnectionCanceled);
            return d;
    	},
        
    	FromServerWithPreBuildQuery : function(query){
    		var d = SVMX.Deferred();
    		var me = this;
    		this.__checkConnectivity().done(function(result){
    			if(result == "False"){
    				d.resolve([]);
    				return d;
    			}
    			me._downloadRecords(query)
                .done(function(results){
                    com.servicemax.client.installigence.offline.model.utils.Http
                    .offConnectionCanceled(me.onConnectionCanceled);
                    	d.resolve(results);
                });
    		});    		
            
            // Catch canceled requests
            this.onConnectionCanceled = function() {
            	d.resolve([]);
            }
            com.servicemax.client.installigence.offline.model.utils.Http
            .onConnectionCanceled(this.onConnectionCanceled);
            return d;
    	},
    	
    	
        __checkConnectivity : function(){
        	var d = SVMX.Deferred();
        	var me = this;
    		var params = {
                type : "CONNECTIVITY",
                method : "CHECKCONNECTIVITY"
            };

            var req = com.servicemax.client.installigence.offline.sal.model.nativeservice.Facade.createConnectivityRequest();
            req.bind("REQUEST_COMPLETED", function(evt){
                d.resolve(evt.data.data);
            }, me);
            req.bind("REQUEST_ERROR", function(evt){
                d.resolve("False");
            }, me);
            req.execute(params);
            return d;
        },
        
        __getSearchableField : function(field, fieldsDesc){
        	var searchField = fieldsDesc[field];
        	if(searchField && searchField.type == "reference"){
        		field = searchField.relationshipName + ".Name";
			}
        	return field;
        },
        
        __getQueryFields : function(fields, fieldsDesc){
        	var i = 0, l = fields.length, colFields = [], fieldsIndex = [];
        	for(i = 0; i < l; i++){
        		field = fieldsDesc ? fieldsDesc[fields[i]] : undefined;
        		if(field && field.type == "reference"){
        			colFields.push(field.relationshipName + ".Name");
				}else{
					colFields.push(fields[i]);
				}
        	}
        	return colFields;
        },        

        _downloadRecords : function(queryString){
            var d = SVMX.Deferred();
            var httpObj = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Http", {});
            var me = this;
            if(typeof(queryString) == 'string') queryString = [queryString];
            var batchCount = 0, records = [];
            var i, l = queryString.length;
            batchCount = l;
            for(i = 0; i < l; i++){
                httpObj.doHttpGetQuery(queryString[i])
                .done(function(resp){
                    records = records.concat(resp.data.records);
                    batchCount--;
                    if(batchCount == 0){
                        d.resolve(records);
                    }
                });
            }
            return d;
        }
    });

    utilsImpl.Class("SyncData", com.servicemax.client.lib.api.Object, {}, {

        createSyncLogs : function(objectName, recordIds, operation){
            var me = this;
            var d = SVMX.Deferred();
            var util = com.servicemax.client.installigence.offline.model.utils.Util;
            util.getObjectDescribeByName(objectName)
            .done(function(objectInfo){
                var d2 = $.when(1);
                for(var i = 0; i < recordIds.length; i++){
                    d2 = d2.then(
                        me.__createSyncLog(objectInfo, recordIds[i], operation)
                    );
                }
                d2.done(function(){
                    d.resolve();
                });
            });
            return d;
        },

        __createSyncLog : function(objectInfo, recordId, operation){
            if(operation === "delete"){
                // Sync log should be simply deleted in this case
                // If we ever implement deleting server side records,
                // then will need to branch here
                return this.deleteSyncLog(recordId);
            }
            var me = this;
            var d = SVMX.Deferred();
            this.__validateRecord(objectInfo, recordId)
            .done(function(isValid, isParentValid){
                var isRecordSynced = !recordId.match(/transient.*/);
                if(operation === "update" && !isRecordSynced){
                    // Operation is always insert for unsynced records
                    operation = "insert";
                }
                if(operation === "insert" && isRecordSynced){
                    // Operation is always update for synced records
                    operation = "update";
                }
                var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                var logTable = isValid ? "ClientSyncLog" : "ClientSyncLogTransient";
                var logDate = new Date().toISOString();
                var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                // Insert/replace
                qo.replaceInto(logTable)
                .columns([
                    {name : "Id"},
                    {name : "Operation"},
                    {name : "ObjectName"},
                    {name : "LastModifiedDate"},
                    {name : "Pending"}
                ])
                .values({
                    Id : recordId,
                    Operation : operation,
                    ObjectName : objectInfo.name,
                    LastModifiedDate : logDate,
                    Pending : !isParentValid ? 'true' : ''
                })
                .execute().done(function(result){
                    me.__updateRecordSyncStatus(isValid, recordId)
                    .done(function(){
                        d.resolve();
                    });
                });
            });
            return d;
        },

        deleteSyncLog : function(recordId){
            var me = this;
            var d = SVMX.Deferred();
            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            qo.deleteFrom("ClientSyncLog")
            .where("Id").equals(recordId)
            .execute().done(function(){
                var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                qo.deleteFrom("ClientSyncLogTransient")
                .where("Id").equals(recordId)
                .execute().done(function(){
                    // Finished
                    me.__updateRecordSyncStatus(true, recordId)
                    .done(function(){
                        d.resolve();
                    });
                });
            });
            return d;
        },

        __validateRecord : function(objectInfo, recordId){
            var me = this;
            var d = SVMX.Deferred();
            var qo = qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            qo.select("*")
            .from(objectInfo.name)
            .where("Id").equals(recordId)
            .execute().done(function(result){
                var record = result[0];
                var isValid = true;
                if(record){
                    for(var i = 0; i < objectInfo.fields.length; i++){
                        var field = objectInfo.fields[i];
                        if(record[field.name] === "" && !field.defaultedOnCreate){
                            if(field.type === "boolean"){
                                record[field.name] = "false";
                            }else{
                                // Nillable means not required
                                if(field.createable && !field.nillable){
                                    isValid = false;
                                    break;
                                }
                            }
                        }
                    }
                }
                me.__validateUpwardHierarchy(objectInfo.name, record)
                .done(function(isParentValid){
                    d.resolve(isValid, isParentValid);
                });
            });
            return d;
        },

        __validateUpwardHierarchy : function(objectName, record){
            var me = this;
            var d = SVMX.Deferred();
            validateRecursiveInternal(objectName, record);
            function validateRecursiveInternal(objectName, record){
                if(objectName === SVMX.getCustomObjectName("Installed_Product")){
                    var parentObject = SVMX.getCustomObjectName("Installed_Product");
                    var parentField = SVMX.getCustomFieldName("Parent");
                    var parentId = record[parentField];
                    if(parentId){
                        me.getSyncLogTransient(parentId)
                        .done(function(result){
                            if(result && result.length){
                                // Parent is invalid
                                d.resolve(false);
                                return;
                            }
                            me.__getRecord(parentObject, parentId)
                            .done(function(result){
                                if(result.length){
                                    validateRecursiveInternal(parentObject, result[0]);
                                }else{
                                    d.resolve(true);
                                }
                            });
                        });
                    }else{
                        parentObject = SVMX.getCustomObjectName("Sub_Location");
                        parentField = SVMX.getCustomFieldName("Sub_Location");
                        parentId = record[parentField];
                        if(parentId){
                            me.getSyncLogTransient(parentId)
                            .done(function(result){
                                if(result && result.length){
                                    // Parent is invalid
                                    d.resolve(false);
                                    return;
                                }
                                me.__getRecord(parentObject, parentId)
                                .done(function(result){
                                    if(result.length){
                                        validateRecursiveInternal(parentObject, result[0]);
                                    }else{
                                        d.resolve(true);
                                    }
                                });
                            });
                        }else{
                            parentObject = SVMX.getCustomObjectName("Sub_Location");
                            parentField = SVMX.getCustomFieldName("Sub_Location");
                            parentId = record[parentField];
                            if(parentId){
                                me.getSyncLogTransient(parentId)
                                .done(function(result){
                                    if(result && result.length){
                                        // Parent is invalid
                                        d.resolve(false);
                                        return;
                                    }
                                    me.__getRecord(parentObject, parentId)
                                    .done(function(result){
                                        if(result.length){
                                            validateRecursiveInternal(parentObject, result[0]);
                                        }else{
                                            d.resolve(true);
                                        }
                                    });
                                });
                            }else{
                                // All parents are valid
                                d.resolve(true);
                            }
                        }
                    }
                }else if(objectName === SVMX.getCustomObjectName("Sub_Location")){
                    var parentField = SVMX.getCustomFieldName("Location");
                    var parentId = record[parentField];
                    me.getSyncLogTransient(parentId)
                    .done(function(result){
                        if(result && result.length){
                            // Parent is invalid
                            d.resolve(false);
                            return;
                        }else{
                            // All parents are valid
                            d.resolve(true);
                        }
                    });
                }else{
                    // Not applicable
                    d.resolve(true);
                }
            }
            return d;
        },

        __updateRecordSyncStatus : function(isValid, recordId){
            var d = SVMX.Deferred();
            // Remove from transient or standard sync log
            var sourceTable = isValid ? "ClientSyncLogTransient" : "ClientSyncLog";
            var targetTable = isValid ? "ClientSyncLog" : "ClientSyncLogTransient";
            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            qo.deleteFrom(sourceTable)
            .where("Id").equals(recordId)
            .execute().done(function(){
                // Notify record sync status
                var syncService = SVMX.getClient().getServiceRegistry()
                .getService("com.servicemax.client.installigence.sync").getInstance();
                syncService.notify({
                    type : "recordstatus",
                    recordId : recordId,
                    valid : isValid,
                    msg : "Record "+recordId+" saved ("+targetTable+")"
                });
                d.resolve();
            });
            return d;
        },

        getSyncLogTransient : function(recordId){
            var qo = qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            return qo.select("Id")
            .from("ClientSyncLogTransient")
            .where("Id").equals(recordId)
            .execute();
        },

        __getRecord : function(objectName, recordId){
            var qo = qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            return qo.select("*")
            .from(objectName)
            .where("Id").equals(recordId)
            .execute();
        }
    });
})();

// end of file
