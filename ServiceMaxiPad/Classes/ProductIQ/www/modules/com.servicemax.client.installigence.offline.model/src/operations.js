/**
 * 
 */

(function(){
    var operationsImpl = SVMX.Package("com.servicemax.client.installigence.offline.model.operations");

operationsImpl.init = function(){
    
	operationsImpl.Class("FindByIB", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },
        
        performAsync: function(request, responder){
            var me = this;
            var fields = request.fields;
            var fieldsDesc = request.fieldsDescribe;
            
            var fieldInfo  = this.__getQueryFields(fields, fieldsDesc);
            var fields = fieldInfo.fields;
            var fieldsIndex = fieldInfo.fieldsIndex;
            var searchFields = fieldInfo.searchFields;            
            var queryObj = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            queryObj.select(fields).from(SVMX.getCustomObjectName("Installed_Product"))
                        .where(SVMX.getCustomFieldName("Top_Level") + " = null");

            if(request.text){
                var i = 0, l = request.searchFields.length;
                searchQuery = "";
                for(i = 0; i < l; i++){
                    if(i > 0) searchQuery += " OR ";
                    searchQuery = searchQuery + this.__getSearchableField(request.searchFields[i], fieldsDesc) 
                                + " like '%" + request.text + "%'";
                    
                }
                if(searchQuery.length > 0){
                    searchQuery =  "(" + searchQuery + ")";
                    queryObj.and(searchQuery);
                }
                
            }

            if(request.locationIds && request.locationIds.length > 0){
                this._downloadLocationsRecursive(request.locationIds)
                .done(function(childIds){
                    var locationIds = childIds.concat(request.locationIds);
                    queryObj.and(SVMX.getCustomFieldName("Site"))
                    .batchWithinIds(locationIds);
                    var query = queryObj.q();
                    me._downloadRecords(query)
                    .done(function(results){
                        com.servicemax.client.installigence.offline.model.utils.Http
                        .offConnectionCanceled(me.onConnectionCanceled);

                        me.prepareAndSendResults(results, fields, fieldsIndex, request, responder);
                    });
                });
            }else{
                var query = queryObj.q();
                me._downloadRecords(query)
                .done(function(results){
                    com.servicemax.client.installigence.offline.model.utils.Http
                    .offConnectionCanceled(me.onConnectionCanceled);

                    me.prepareAndSendResults(results, fields, fieldsIndex, request, responder);
                });
            }

            // Catch canceled requests
            this.onConnectionCanceled = function() {
                responder.error();
            }
            com.servicemax.client.installigence.offline.model.utils.Http
            .onConnectionCanceled(this.onConnectionCanceled);
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
                field = fieldsDesc[fields[i]];
                fieldsIndex.push(field.label);
                if(field && field.type == "reference"){
                    colFields.push(field.relationshipName + ".Name");
                }else{
                    colFields.push(fields[i]);
                }
            }
            return {fields : colFields, fieldsIndex : fieldsIndex};
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
        },

        _downloadLocationsRecursive : function(locationIds, parentIds, d){
            var me = this;
            var d = d || SVMX.Deferred();

            parentIds = parentIds || [];
            var parentField = SVMX.getCustomFieldName("Parent");
            var queryObj = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            queryObj.select(["Id", parentField])
            .from(SVMX.getCustomObjectName("Site"))
            .where("Id").within(locationIds);
            var query = queryObj.q();
            this._downloadRecords(query)
            .done(function(results){
                var resultIds = [];
                for(var i = 0; i < results.length; i++){
                    if(results[i][parentField]){
                        resultIds.push(results[i][parentField]);
                    }else if(parentIds.indexOf(results[i].Id) === -1){
                        parentIds.push(results[i].Id);
                    }
                }
                if(resultIds.length){
                    me._downloadLocationsRecursive(resultIds, parentIds, d);
                }else{
                    me._downloadChildLocationsRecursive(parentIds)
                    .done(function(allLocationIds) {
                        d.resolve(allLocationIds);
                    });
                }
            });
            return d;
        },

        _downloadChildLocationsRecursive : function(locationIds, childIds, d){
            var me = this;
            var d = d || SVMX.Deferred();

            this.__allChildLocationIds = this.__allChildLocationIds || [];
            childIds = childIds || [];
            var parentField = SVMX.getCustomFieldName("Parent");
            var queryObj = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            queryObj.select(["Id", parentField])
            .from(SVMX.getCustomObjectName("Site"))
            .where(parentField).batchWithinIds(locationIds);
            var query = queryObj.q();
            this._downloadRecords(query)
            .done(function(results){
                var resultIds = [];
                for(var i = 0; i < results.length; i++){
                    if(me.__allChildLocationIds.indexOf(results[i].Id) === -1){
                        me.__allChildLocationIds.push(results[i].Id);
                        resultIds.push(results[i].Id);
                        childIds.push(results[i].Id);
                    }
                }
                if(resultIds.length){
                    me._downloadChildLocationsRecursive(resultIds, childIds, d);
                }else{
                    d.resolve(childIds);
                }
            });
            return d;
        },

        prepareAndSendResults : function(data, fields, fieldsIndex, request, responder){
            var d = data.data || {}, records = data || [], l = records.length, i, ret = [], r, ids = [];
            var j, fieldCount = fields.length, f;
            var k, depth, v, dataRecord;
            for(i = 0; i < l; i++){
                r = records[i];
                dataRecord = {};
                for(j = 0; j < fieldCount; j++){
                    f = fields[j].split(".");
                    depth = f.length;
                    v = r;
                    for(k = 0; k < depth; k++){
                        v = v[f[k]];
                        if(!v) break;
                    }

                    dataRecord[fieldsIndex[j]] = v;
                }
                ret.push(dataRecord);
                ids.push(dataRecord.Id);
            }

            if(request.params && request.params.syncType == 'reset'){
                responder.result({data : ret, hasMoreRecords : !!d.nextRecordsUrl});
            }else{
                // marks records that are already present locally
                var queryObj = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                queryObj.select("Id").from(SVMX.getCustomObjectName("Installed_Product"))
                .where("Id").within(ids).execute()
                .done(function(resp){
                    var respIds = [], l = resp.length;
                    for(i = 0; i < l; i++){
                        respIds.push(resp[i].Id);
                    }

                    l = ids.length;
                    for(i = 0; i < l; i++){
                        if(SVMX.array.contains(respIds, ids[i])){
                            ret[i].availableInDB = true;
                        }
                    }
                    responder.result({data : ret, hasMoreRecords : !!d.nextRecordsUrl, selectAll : request.selectAll});
                });
                // end mark
            }
        }
    }, {});
        
    operationsImpl.Class("GetMetadata", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },
        
        performAsync : function(request, responder){
            var me = this;
            me.__getUserConfig()
            .done(function(data){
                me.__getUserState(data)
                .done(function(state){
                    data.state = state;
                    responder.result(data);
                });
            });
        },

        __getUserConfig : function(){
            var d = SVMX.Deferred();
            var queryObj = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            queryObj.select("Value").from("Configuration")
            .where("Type = 'user'")
            .execute().done(function(resp){
                var data = {};
                if(resp && resp[0] && resp[0].Value){
                    data = SVMX.toObject(resp[0].Value);
                }
                d.resolve(data);
            });
            return d;
        },

        __getUserState : function(){
            var d = SVMX.Deferred();
            var queryObj = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            queryObj.select("Value").from("Configuration")
            .where("Type = 'state'")
            .execute().done(function(resp){
                var state = {};
                if(resp && resp[0] && resp[0].Value){
                    state = SVMX.toObject(resp[0].Value);
                }
                d.resolve(state);
            });
            return d;
        }

    }, {});

    operationsImpl.Class("GetTopLevelIBs", com.servicemax.client.mvc.api.Operation, {

        __constructor : function(){
            this.__base();
        },
        
        performAsync : function(request, responder){
            var me = this;
            var response = {};
            var exprs = request.context.getFilterExpressions
                ? request.context.getFilterExpressions() : null;
            this.buildQueryWithExpressions(exprs)
            .execute().done(function(resp){
                response.ibs = resp;
                if(!response.ibs.length){
                    me.__getAllAccountsLocations(response)
                    .done(function(){
                        responder.result(response);
                    });
                }else{
                    me.__appendParentRecords(exprs, response)
                    .done(function(){
                        me.__appendTemplateConfigs(response)
                        .done(function(){
                            me.__appendTransientRecordIndex(response)
                            .done(function(){
                                responder.result(response);
                            });
                        });
                    });
                }
            }); 
        },

        buildQueryWithExpressions : function(exprs, topLevel){
            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            //TODO: not all columns are required
            qo.select("*").from(SVMX.getCustomObjectName("Installed_Product"))
            .where("1 = 1");

            // Enables use for child IBs also
            if(topLevel || topLevel === undefined){
                qo.where(SVMX.getCustomFieldName("Top_Level") + " = ''" );
            }

            if(exprs && exprs.length){
                for(var i = 0; i < exprs.length; i++){
                    qo.and(this.__buildFilterQueryRecursive(exprs[i]));
                }
            }

            return qo;
        },

        __buildFilterQueryRecursive : function(expr, operator){
            var filterParts = [];
            operator = operator || "AND";
            expr.children = expr.children || [];
            for(var i = 0; i < expr.children.length; i++){
                var childExpr = expr.children[i];
                switch(childExpr.exprType){
                    case "operator":
                    case "operatorroot":
                        var childOperator = null, childNot = null;
                        switch(childExpr.operator){
                            case "And":
                                childOperator = "AND";
                                break;
                            case "Not And":
                                childOperator = "AND";
                                childNot = true;
                                break;
                            case "Or":
                                childOperator = "OR";
                                break;
                            case "Not Or":
                                childOperator = "OR";
                                childNot = true;
                                break;
                        }
                        var childQuery = this.__buildFilterQueryRecursive(childExpr, childOperator);
                        if(childQuery){
                            if(i > 0){
                                filterParts.push(operator);
                            }
                            if(childNot){
                                filterParts.push("NOT");
                            }
                            filterParts.push("("+childQuery+")");
                        }
                        break;
                    case "expression":
                        // Expression is a leaf node
                        var condition = this.__buildFilterQueryCondition(childExpr);
                        if(condition){
                            if(i > 0){
                                filterParts.push(operator);
                            }
                            filterParts.push(condition);
                        }
                        break;
                    case "root":
                    default:
                        // Continue processing
                        filterParts.push(this.__buildFilterQueryRecursive(childExpr));
                }
            }
            return filterParts.join(" ");
        },

        __buildFilterQueryCondition : function(expr){
            var field = expr.field;
            var value = expr.value;
            if(!field) return;
            // TODO: use sobject info to adjust queries based on field type?
            switch(expr.condition){
                // TODO: remove label values ASAP
                // TODO
                case "Starts With":
                case "startswith":
                    return field+" LIKE '"+value+"%'";
                case "Not Equal":
                case "notequal":
                    return field+" != '"+value+"'";
                case "Less or Equal To":
                case "lessorequalto":
                    if(value === null || value === '') return;
                    return field+" <= "+value;
                case "Less Than":
                case "lessthan":
                    if(value === null || value === '') return;
                    return field+" < "+value;
                case "Is Null":
                case "isnull":
                    return field+" IS NULL";
                case "Is Not Null":
                case "isnotnull":
                    return field+" IS NOT NULL";
                case "Includes":
                case "includes":
                    // TODO: this is for picklist values
                    return field+" LIKE '%"+value+"%'";
                case "Greater or Equal To":
                case "greaterorequalto":
                    if(value === null || value === '') return;
                    return field+" >= "+value;
                case "Greater Than":
                case "greaterthan":
                    if(value === null || value === '') return;
                    return field+" > "+value;
                case "Excludes":
                case "excludes":
                    // TODO: this is for picklist values
                    return field+" NOT LIKE '%"+value+"%'";
                case "Equals":
                case "equals":
                    return field+" = '"+value+"'";
                case "Does Not Contain":
                case "doesnotcontain":
                    return field+" NOT LIKE '%"+value+"%'";
                case "Contains":
                case "contains":
                    return field+" LIKE '%"+value+"%'";
            }
        },

        __appendParentRecords : function(exprs, response){
            var me = this;
            var d = SVMX.Deferred();
            var ds = [];
            var accountIds = [];
            var locationIds = [];
            var sublocationIds = [];
            var allParentLocationIds = [];
            var allParentSubLocationIds = [];
            var accountField = SVMX.getCustomFieldName("Company");
            var locationField = SVMX.getCustomFieldName("Site");
            var sublocationField = SVMX.getCustomFieldName("Sub_Location");
            for(var i = 0; i < response.ibs.length; i++){
                var record = response.ibs[i];
                if(accountIds.indexOf(record[accountField]) === -1){
                    accountIds.push(record[accountField]);
                }
                if(locationIds.indexOf(record[locationField]) === -1){
                    locationIds.push(record[locationField]);
                }
                if(sublocationIds.indexOf(record[sublocationField]) === -1){
                    sublocationIds.push(record[sublocationField]);
                }
            }
            var counter = 0;
            fetchAccounts(accountIds);
            fetchLocationsRecursive(locationIds);
            fetchSubLocationsRecursive(sublocationIds);

            function fetchAccounts(accountIds){
                counter++;
                var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                qo.select("*")
                .from("Account")
                .where("Id").within(accountIds)
                .execute().done(function(results){
                    response.accounts = results;
                    onComplete();
                });
            }
            function fetchLocationsRecursive(locationIds){
                counter++;
                var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                qo.select("*")
                .from(SVMX.getCustomObjectName("Site"));
                if(exprs.length){
                    qo.where("Id").within(locationIds);
                }
                qo.execute().done(function(results){
                    response.locations = response.locations || [];
                    response.locations = response.locations.concat(results);
                    var parentIds = [];
                    var parentField = SVMX.getCustomFieldName("Parent");
                    for(var i = 0; i < results.length; i++){
                        var id = results[i][parentField];
                        if(id && allParentLocationIds.indexOf(id) === -1){
                            parentIds.push(id);
                            allParentLocationIds.push(id);
                        }
                    }
                    if(parentIds.length){
                        fetchLocationsRecursive(parentIds);
                    }
                    onComplete();
                });
            }
            function fetchSubLocationsRecursive(sublocationIds){
                counter++;
                var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                qo.select("*")
                .from(SVMX.getCustomObjectName("Sub_Location"))
                if(exprs.length){
                    qo.where("Id").within(sublocationIds);
                }
                qo.execute().done(function(results){
                    response.sublocations = response.sublocations || [];
                    response.sublocations = response.sublocations.concat(results);
                    var parentIds = [];
                    var parentField = SVMX.getCustomFieldName("Parent");
                    for(var i = 0; i < results.length; i++){
                        var id = results[i][parentField];
                        if(id && allParentSubLocationIds.indexOf(id) === -1){
                            parentIds.push(id);
                            allParentSubLocationIds.push(id);
                        }
                    }
                    if(parentIds.length){
                        fetchSubLocationsRecursive(parentIds);
                    }
                    onComplete();
                });
            }
            function onComplete(){
                counter--;
                if(counter === 0){
                    d.resolve();
                }
            }

            return d;
        },

        __appendTemplateConfigs : function(response){
            var d = SVMX.Deferred();
            var i, l = response.ibs.length, templateIds = [];
            for(i = 0; i < l; i++){
                var record = response.ibs[i];
                var tplId = record[SVMX.getCustomFieldName("ProductIQTemplate")];
                if(tplId && templateIds.indexOf(tplId) === -1){
                    templateIds.push(tplId);
                }
            }
            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            qo.select("Value").from("Configuration")
            .where("Key").within(templateIds)
            .execute().done(function(resp){
                if(resp){
                    var templates = {};
                    for(var i = 0; i < resp.length; i++){
                        var tpl = SVMX.toObject(resp[i].Value);
                        templates[tpl.sfdcId] = tpl;
                    }
                    response.templates = templates;
                }
                d.resolve();
            });
            return d;
        },

        __appendTransientRecordIndex : function(response){
            var d = SVMX.Deferred();
            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            qo.select("Id").from("ClientSyncLogTransient")
            .execute().done(function(result){
                response.transients = [];
                for(var i = 0; i < result.length; i++){
                    response.transients.push(result[i].Id);
                }
                d.resolve();
            });
            return d;
        },

        __getAllAccountsLocations : function(response){
            var d = SVMX.Deferred();
            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            qo.select("*")
            .from("Account")
            .execute().done(function(results){
                response.accounts = results;
                var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                qo.select("*")
                .from(SVMX.getCustomObjectName("Site"))
                .execute().done(function(results){
                    response.locations = results;
                    var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                    qo.select("*")
                    .from(SVMX.getCustomObjectName("Sub_Location"))
                    .execute().done(function(results){
                        response.sublocations = results;
                        d.resolve();
                    });
                });
            });
            return d;
        }

    }, {});
    
    operationsImpl.Class("GetPageLayout", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },
        
        performAsync: function(request, responder){
            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            qo.select("DescribeResult").from("ObjectDescribe").where("ObjectName" + " = '" + request.objectName + "'" )
            .execute().done(function(resp){
                resp = SVMX.toObject(resp[0].DescribeResult);
                //responder.result(resp);
				//Query Business Rules
                getBusinessRulesInfo(request.objectName, resp, responder);
            }); 
        }
    }, {});
   
    function getBusinessRulesInfo(objName, descResp, responder){
    	var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
        qo.select("*").from("Configuration")
    	.execute().done(function(resp){
    		var pageLayoutResp = {};
			pageLayoutResp.DescribeResult = descResp;
            pageLayoutResp.dataValidationRules = [];
			if(resp){
				var strJsonRules = resp[0].Value;
				var objectFromJsonRules = SVMX.toObject(strJsonRules);
				var rulesFromUserConfig = objectFromJsonRules.dataValidationRules;
                if(rulesFromUserConfig){
                    var i = 0;
                    for(i=0;i<rulesFromUserConfig.length; i++){
                        if(rulesFromUserConfig[i].rule.objectName === objName){
                            
                            var dataValidationRule = {};
                            dataValidationRule.header = {};
                            dataValidationRule.details = [];
                            dataValidationRule.header = rulesFromUserConfig[i].rule;
                            dataValidationRule.details = rulesFromUserConfig[i].lstExpressions;
                            pageLayoutResp.dataValidationRules.push(dataValidationRule);
                        }
                    }
                }
			}
			responder.result(pageLayoutResp);
    	});
    	
    }; 
    operationsImpl.Class("GetPageData", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },
        
        performAsync: function(request, responder){
            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            qo.select("*").from(request.objectName).where("Id" + " = '" + request.id + "'" )
            .execute().done(function(resp){
                resp = SVMX.toObject(resp[0]);
                responder.result(resp);
            }); 
        }
    }, {});
    
    operationsImpl.Class("GetLocAccDetails", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },
        
        performAsync: function(request, responder){
            var me = this;
            me.__getLocations(request, responder)
            .done(function(locations){
                me.__getSubLocations(request, responder)
                .done(function(sublocations){
                    me.__getAccounts(request, responder)
                    .done(function(accounts){
                        responder.result({
                            locations : locations,
                            sublocations : sublocations,
                            accounts : accounts
                        });
                    });
                });
            });
        },
        
        __getLocations : function(request, responder){
            var d = SVMX.Deferred();
            var locQ = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            locQ.select(["Id", "Name"]).from(SVMX.getCustomObjectName("Site")).where("Id").within(request.locIds)
            .execute().done(function(resp){
                d.resolve(resp);
            });
            return d;
        },

        __getSubLocations : function(request, responder){
            var d = SVMX.Deferred();
            var locQ = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            locQ.select(["Id", "Name"]).from(SVMX.getCustomObjectName("Sub_Location")).where("Id").within(request.sublocIds)
            .execute().done(function(resp){
                d.resolve(resp);
            });
            return d;
        },
        
        __getAccounts : function(request, responder){
            var d = SVMX.Deferred();
            var locQ = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            locQ.select(["Id", "Name"]).from("Account").where("Id").within(request.accIds)
            .execute().done(function(resp){
                d.resolve(resp);
            });
            return d;
        }
    }, {});
    
    operationsImpl.Class("GetMoreIBs", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },
        
        performAsync: function(request, responder){
            var parentIBId = request.parentIBId;
            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});

            // TODO: reasonable limit
            var queryLimit = 1000000;
            var queryOffset = 0;
            if(request.page){
                queryOffset = (request.page - 1) * queryLimit;
            }

            var topLevelOperation = new operationsImpl.GetTopLevelIBs;
            var exprs = request.context.getFilterExpressions();
            topLevelOperation.buildQueryWithExpressions(exprs, false)
            .where(SVMX.getCustomFieldName("Parent") + " = '" + parentIBId + "'" )
            .limit(queryLimit)
            .offset(queryOffset)
            .execute().done(function(resp){
                responder.result(resp);
            });
        },
        
        performAsync2: function(request, responder){
            // test data
            var lastIBIndex = request.lastIBIndex || 1;
            
            setTimeout(function(){
                var ret = [];
                for(var i = lastIBIndex; i < lastIBIndex + 100; i++){
                    ret.push({
                        Id : "Id" + i,
                        Name : "Name" + i,
                        RecordId : i
                    });
                }
                responder.result(ret);
            },1);   
            // end test data
        }
    }, {});
    
    operationsImpl.Class("FindProducts", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },
        
        performAsync: function(request, responder){
           debugger;
        	var me = this;
            this.__findLocalRecords(request)
            .done(function(localRecords){
                me.__findRemoteRecords(request)
                .done(function(remoteRecords){
                	me.__findServerRecords(request)                
	                .done(function(serverRecords){
	                	var records = me.__mergeRecords(localRecords, remoteRecords, serverRecords);
	                	responder.result(records);
	                });
                });
            });
        },
        
        __findServerRecords : function(request){
        	var d = SVMX.Deferred();
        	/*request.objectName = "Product2";
        	request.fields = request.displayFields;
        	var getRecords = SVMX.create("com.servicemax.client.installigence.offline.model.utils.GetRecords", {});
        	getRecords.fromServer(request).done(function(results){
        		d.resolve(results);
        	});*/
        	d.resolve([]);
        	return d; 
        },

        __findLocalRecords : function(request){
            var d = SVMX.Deferred();
            var fields = request.displayFields;
            var fieldsDesc = request.fieldsDescribe;

            var queryObj = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});

            // TODO: remove these hardcoded fields when field map is available for add new IB
            var hardCodedFields = ['CategoryId__c', 'DeviceType2__c', 'Brand2__c'];
            queryObj.selectDistinct(this.__getQueryFields(fields, fieldsDesc, hardCodedFields));

            var objects = ["Product2 p"];
            var search = {};
            if(request.text && request.searchFields){               
                search = this.__getSearchFields(request.searchFields, fieldsDesc, request.text);
            }
            
            queryObj.from(objects);
            searchFields = search.searchFields;
            var query = queryObj.q();
            var allqueries = "";
            if(request.text && searchFields.length > 0){                
                var iSearch, iLength = searchFields.length;
                for(iSearch = 0; iSearch < iLength; iSearch++){
                    var alias = searchFields[iSearch].alias;
                    if(iSearch > 0) allqueries += " UNION "
                    if(alias !== "plain")
                        allqueries += query + "," + alias + " where " + searchFields[iSearch].where;
                    else
                        allqueries += query + " where " + searchFields[iSearch].where;
                }
                queryObj.query(allqueries);
            }else if(request.text){
                queryObj.where("Name").like(request.text);
            }
            queryObj.orderBy("p.Name");
            queryObj.limit(SVMX.getCurrentApplication().getSearchResultsLimit()).execute().done(function(resp){
                d.resolve(resp);
            });
            return d;
        },

        __findRemoteRecords : function(request){
            var me = this;
            var d = SVMX.Deferred();
            SVMX.getClient().getServiceRegistry()
            .getService("com.servicemax.client.installigence.sync").getInstance()
            .getUserInfo()
            .done(function(userInfo){
                var queryObj = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                var fields = request.displayFields;
                var fieldsDesc = request.fieldsDescribe;
                var hardCodedFields = ['CategoryId__c', 'DeviceType2__c', 'Brand2__c'];                
                queryObj.selectDistinct(me.__getQueryFields(fields, fieldsDesc, hardCodedFields, "SFRecordName"));

                var objects = ["Product2 p"];
                var search = {};
                if(request.text && request.searchFields){               
                    search = me.__getSearchFields(request.searchFields, fieldsDesc, request.text, "SFRecordName");
                }
                
                queryObj.from(objects);
                searchFields = search.searchFields;
                var query = queryObj.q();
                var allqueries = "";
                if(request.text && searchFields.length > 0){                
                    var iSearch, iLength = searchFields.length;
                    for(iSearch = 0; iSearch < iLength; iSearch++){
                        var alias = searchFields[iSearch].alias;
                        if(iSearch > 0) allqueries += " UNION "
                        if(alias !== "plain")
                            allqueries += query + "," + alias + " where " + searchFields[iSearch].where;
                        else
                            allqueries += query + " where " + searchFields[iSearch].where;
                    }
                    queryObj.query(allqueries);
                }else if(request.text){
                    queryObj.where("Name").like(request.text);
                }
                queryObj.limit(SVMX.getCurrentApplication().getSearchResultsLimit());
                var params = {
                    type : "DATAACCESSAPI",
                    method : "SELECT",
                    objectName: "Product2",
                    userName : userInfo.UserName,
                    query : queryObj.q()
                };

                var req = com.servicemax.client.installigence.offline.sal.model.nativeservice.Facade.createDataAccessAPIRequest();

                req.bind("REQUEST_COMPLETED", function(evt){
                    var records = me.__parseResults(evt.data.data);
                    d.resolve(records);
                }, me);
                req.bind("REQUEST_ERROR", function(evt){
                    d.resolve([]);  
                }, me);
                req.execute(params);
            });
            return d;
        },

        __mergeRecords : function(records1, records2, records3){
            if(records2.length || records3.length){
                var recordIds = [];
                for(var i = 0; i < records1.length; i++){
                    recordIds.push(records1[i].Id);
                }
                for(var i = 0; i < records2.length; i++){
                    if(recordIds.indexOf(records2[i].Id) === -1){
                        records1.push(records2[i]);
                        recordIds.push(records2[i].Id);
                    }
                }                
                for(var i = 0; i < records3.length; i++){
                    if(recordIds.indexOf(records3[i].Id) === -1){
                        records1.push(records3[i]);
                    }
                }
            }
            return this.__sort(records1, "Name");
        },
        
        __sort : function(array, key){
            return array.sort(function(a, b) {
                if(a[key] < b[key]){
                    return -1;
                }else if(a[key] > b[key]){
                    return 1;
                }
                return 0;
            });
        },
        
        __getQueryFields : function(fields, fieldsDesc, specFields, nameFieldObject){
            var i = 0, l = fields.length, colFields = [];
            var refObjName = nameFieldObject ? nameFieldObject : "RecordName";
            for(i = 0; i < l; i++){
                field = fieldsDesc[fields[i]];
                if(field && field.type == "reference"){
                    colFields.push("(Select Name from " + refObjName + " where Id = " + fields[i] + ") " + fields[i]);
                }else{
                    colFields.push('p.' + fields[i] + ' ' + fields[i]);
                }
            }
            specFields = specFields || [];
            for(i = 0; i < specFields.length; i++){
                if(fieldsDesc[specFields[i]])
                    colFields.push('p.' + specFields[i] + ' ' + specFields[i] + '__id');
            }
            return colFields;
        },
        
        __getSearchFields : function(fields, fieldsDesc, text, nameFieldObject){
            var searchFields = [], refCount = 0, objects = ["Product2 p"];
            nameFieldObject = nameFieldObject ? nameFieldObject : "RecordName";
            var iSearch, iLength = fields.length, condition = "";
            for(iSearch = 0; iSearch < iLength; iSearch++){
                var field = fieldsDesc[fields[iSearch]];
                var fieldName = "p." + fields[iSearch];
                if(field && field.type == "reference"){                         
                    var alias = "RN" + refCount;
                    var refObjName = nameFieldObject + " " + alias;
                    objects.push(refObjName);
                    searchFields.push({ alias: refObjName, where: "(" + fieldName + " = " + alias 
                                                    + ".id And " + alias + ".Name like '%" + text + "%')"});
                    refCount++;
                    
                }else {
                    if(condition.length > 0) condition += " OR ";
                    condition += fieldName + " like '%" + text + "%'";
                }               
            }
            if(condition.length > 0)
                searchFields.push({alias: "plain", where: condition});
            return {"objects" : objects, "searchFields" : searchFields};
        },

        __parseResults: function(data) {
            data = SVMX.toObject(data);
            var i, ilength = data.length, obj = {};
            for(i = 0; i < ilength; i++) {
                obj[data[i].split(" : ")[0]] = data[i].split(" : ")[1];
            }
            var output = [];
            if(obj["Response Code"] === "1" && obj.Output.length > 0) {
                output = this.__parseOutput(obj.Output);
            }
            return output;
        },

        __parseOutput: function(data) {
            if(data && data[0] === "[" && data[data.length-1] !== "]"){
                // Fix incomplete JSON output
                data += "\"]]";
            }
            data = SVMX.toObject(data);
            var i, ilength = data.length, output = [];
            for(i = 0; i < ilength; i++) {
                var j = 0; jlength = data[i].length, obj = {};
                var currData = data[i];
                for(j = 0; j < jlength; j++){
                    obj[currData[j].split(":")[0]] = currData[j].split(":")[1];
                }
                output.push(obj);
            }
            return output;
        }

    }, {});
    
    operationsImpl.Class("GetRecords", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },

        performAsync: function(request, responder){
           var me = this;
            this.__findLocalRecords(request)
            .done(function(localRecords){
                me.__findRemoteRecords(request)
                .done(function(remoteRecords){
                	me.__findServerRecords(request)                
	                .done(function(serverRecords){
	                    var records = me.__mergeRecords(localRecords, remoteRecords, serverRecords);
	                    var isValid = localRecords.length || remoteRecords.lenhth || serverRecords.length;
	                    responder.result(records, isValid, request.parentNodeId);
	                });
                });
            });
        },
        
        __findServerRecords : function(request){
        	var d = SVMX.Deferred();
        	if(request.objectName === "RecordName" || !request.onlineChecked){
        		d.resolve([]);
        		return d;
            }
        	var getRecords = SVMX.create("com.servicemax.client.installigence.offline.model.utils.GetRecords", {});
        	getRecords.fromServer(request).done(function(results){
        		d.resolve(results);
        	});
        	d.resolve([]);
        	return d; 
        },

        __findLocalRecords : function(request){
            var d = SVMX.Deferred();
            var fields = request.fields;
            var fieldsDesc = request.fieldsDescribe;

            var queryObj = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});

            // TODO: remove these hardcoded fields when field map is available for add new IB
            var hardCodedFields = ['CategoryId__c', 'DeviceType2__c', 'Brand2__c'];
            if(request.objectName === "Product2"){
                hardCodedFields = [];
            }
            queryObj.selectDistinct(fieldsDesc ? this.__getQueryFields(fields, fieldsDesc, hardCodedFields) : fields);

            var objects = [request.objectName + " p"];
            var search = {};
            if(request.text && request.searchFields){               
                search = this.__getSearchFields(request.searchFields, fieldsDesc, request.text, request.objectName);
            }
            
            queryObj.from(objects);
            searchFields = search.searchFields;
            var query = queryObj.q();
            var allqueries = "";
            if(request.text && searchFields.length > 0){                
                var iSearch, iLength = searchFields.length;
                for(iSearch = 0; iSearch < iLength; iSearch++){
                    var alias = searchFields[iSearch].alias;
                    if(iSearch > 0) allqueries += " UNION "
                    if(alias !== "plain")
                        allqueries += query + "," + alias + " where " + searchFields[iSearch].where;
                    else
                        allqueries += query + " where " + searchFields[iSearch].where;
                }
                queryObj.query(allqueries);
            }else if(request.text){
                queryObj.where("Name").like(request.text);
            }else if(request.id){
                queryObj.where("Id").equals(request.id);
            }
            queryObj.limit(SVMX.getCurrentApplication().getSearchResultsLimit()).execute().done(function(resp){
                d.resolve(resp);
            });
            return d;
        },

        __findRemoteRecords : function(request){
            var me = this;
            var d = SVMX.Deferred();
            if(request.objectName === "RecordName" || !request.mflChecked){
                // Record name queries are local only
                d.resolve([]);
                return d;
            }
            SVMX.getClient().getServiceRegistry()
            .getService("com.servicemax.client.installigence.sync").getInstance()
            .getUserInfo()
            .done(function(userInfo){
                var fields = request.fields;
                var fieldsDesc = request.fieldsDescribe;
                var queryObj = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});

                // TODO: remove these hardcoded fields when field map is available for add new IB
                var hardCodedFields = [];
                if(request.objectName === "Product2"){
                    hardCodedFields = ['CategoryId__c', 'DeviceType2__c', 'Brand2__c'];
                }
                queryObj.selectDistinct(fieldsDesc ? me.__getQueryFields(fields, fieldsDesc, hardCodedFields, "SFRecordName") : fields);

                var objects = [request.objectName + " p"];
                var search = {};
                if(request.text && request.searchFields){               
                    search = me.__getSearchFields(request.searchFields, fieldsDesc, request.text, request.objectName, "SFRecordName");
                }
                
                queryObj.from(objects);
                searchFields = search.searchFields;
                var query = queryObj.q();
                var allqueries = "";
                if(request.text && searchFields.length > 0){
                    var iSearch, iLength = searchFields.length;
                    for(iSearch = 0; iSearch < iLength; iSearch++){
                        var alias = searchFields[iSearch].alias;
                        if(iSearch > 0) allqueries += " UNION "
                        if(alias !== "plain")
                            allqueries += query + "," + alias + " where " + searchFields[iSearch].where;
                        else
                            allqueries += query + " where " + searchFields[iSearch].where;
                    }
                    queryObj.query(allqueries);
                }else if(request.text){
                    queryObj.where("Name").like(request.text);
                }else if(request.id){
                    queryObj.where("Id").equals(request.id);
                }
                queryObj.limit(SVMX.getCurrentApplication().getSearchResultsLimit())
                var params = {
                    type : "DATAACCESSAPI",
                    method : "SELECT",
                    objectName: request.objectName,
                    userName : userInfo.UserName,
                    query : queryObj.q()
                };

                var req = com.servicemax.client.installigence.offline.sal.model.nativeservice.Facade.createDataAccessAPIRequest();
                req.bind("REQUEST_COMPLETED", function(evt){
                    var records = me.__parseResults(evt.data.data);
                    var isValid = evt.data.data.indexOf('Response Code : 0') === -1;
                    d.resolve(records, isValid);
                }, me);
                req.bind("REQUEST_ERROR", function(evt){
                    d.resolve([]);  
                }, me);
                req.execute(params);
            });
            return d;
        },

        __parseResults: function(data) {
            data = SVMX.toObject(data);
            var i, ilength = data.length, obj = {};
            for(i = 0; i < ilength; i++) {
                obj[data[i].split(" : ")[0]] = data[i].split(" : ")[1];
            }
            var output = [];
            if(obj["Response Code"] === "1" && obj.Output.length > 0) {
                output = this.__parseOutput(obj.Output);
            }
            return output;
        },

        __parseOutput: function(data) {
            if(data && data[0] === "[" && data[data.length-1] !== "]"){
                // Fix incomplete JSON output
                data += "\"]]";
            }
            data = SVMX.toObject(data);
            var i, ilength = data.length, output = [];
            for(i = 0; i < ilength; i++) {
                var j = 0; jlength = data[i].length, obj = {};
                var currData = data[i];
                for(j = 0; j < jlength; j++){
                    obj[currData[j].split(":")[0]] = currData[j].split(":")[1];
                }
                output.push(obj);
            }
            return output;
        },

        __mergeRecords : function(records1, records2, records3){
            if(records2.length || records3.length){
                var recordIds = [];
                for(var i = 0; i < records1.length; i++){
                    recordIds.push(records1[i].Id);
                }
                for(var i = 0; i < records2.length; i++){
                    if(recordIds.indexOf(records2[i].Id) === -1){
                        records1.push(records2[i]);
                        recordIds.push(records2[i].Id);
                    }
                }                
                for(var i = 0; i < records3.length; i++){
                    if(recordIds.indexOf(records3[i].Id) === -1){
                        records1.push(records3[i]);
                    }
                }
            }
            return this.__sort(records1, "Name");
        },
        
        __sort : function(array, key){
            return array.sort(function(a, b) {
                if(a[key] < b[key]){
                    return -1;
                }else if(a[key] > b[key]){
                    return 1;
                }
                return 0;
            });
        },        

        __getQueryFields : function(fields, fieldsDesc, specFields, nameFieldObject){
            var i = 0, l = fields.length, colFields = [];
            nameFieldObject = nameFieldObject ? nameFieldObject : "RecordName";
            for(i = 0; i < l; i++){
                field = fieldsDesc[fields[i]];
                if(field && field.type == "reference"){
                    colFields.push("(Select Name from " + nameFieldObject + " where Id = " + fields[i] + ") " + fields[i]);
                }else{
                    colFields.push('p.' + fields[i] + ' ' + fields[i]);
                }
            }
            specFields = specFields || [];
            for(i = 0; i < specFields.length; i++){
                if(fieldsDesc[specFields[i]])
                    colFields.push('p.' + specFields[i] + ' ' + specFields[i] + '__id');
            }
            return colFields;
        },
        
        __getSearchFields : function(fields, fieldsDesc, text, objName, nameFieldObject){
            var searchFields = [], refCount = 0, objects = [objName + " p"];
            nameFieldObject = nameFieldObject ? nameFieldObject : "RecordName";
            var iSearch, iLength = fields.length, condition = "";
            for(iSearch = 0; iSearch < iLength; iSearch++){
                var field = fieldsDesc[fields[iSearch]];
                var fieldName = "p." + fields[iSearch];
                if(field && field.type == "reference"){                         
                    var alias = "RN" + refCount;
                    var refObjName = nameFieldObject + " " + alias;
                    objects.push(refObjName);
                    searchFields.push({ alias: refObjName, where: "(" + fieldName + " = " + alias 
                                                    + ".id And " + alias + ".Name like '%" + text + "%')"});
                    refCount++;
                    
                }else {
                    if(condition.length > 0) condition += " OR ";
                    condition += fieldName + " like '%" + text + "%'";
                }               
            }
            if(condition.length > 0)
                searchFields.push({alias: "plain", where: condition});
            return {"objects" : objects, "searchFields" : searchFields};
        }

    }, {});

    operationsImpl.Class("GetLocations", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },

        performAsync: function(request, responder){
            var me = this;
            var locationObject = SVMX.getCustomObjectName("Site");
            var sublocationObject = SVMX.getCustomObjectName("Sub_Location");
            this.__getRecords(locationObject, request)
            .done(function(locations){
                me.__getRecords(sublocationObject, request)
                .done(function(sublocs){
                    var response = {};
                    response[locationObject] = locations;
                    response[sublocationObject] = sublocs;
                    responder.result(response);
                });
            });
        },

        __getRecords : function(objectName, request){
            var d = SVMX.Deferred();
            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            var fields = request.fields ? request.fields[objectName] : "Id";
            qo.select(fields)
            .from(objectName)
            .execute().done(function(results){
                d.resolve(results);
            });
            return d;
        }

    }, {});
    
    operationsImpl.Class("CreateRecords", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },
        
        performAsync: function(request, responder){
            var me = this;
            me.__applyTemplateValueMap(request)
            .done(function(){
                me.__createAllRecords(request)
                .done(function(){
                    responder.result(request.records);
                });
            });
        },

        __createAllRecords : function(request){
            var me = this;
            var d = SVMX.Deferred();
            var util = com.servicemax.client.installigence.utils.impl.Util;
            var syncDataUtil = com.servicemax.client.installigence.offline.model.utils.SyncData;
            var id = null, i, records = request.records, l = records.length;
            for(i = 0; i < l; i++){
                id = "transient-" + util.guid();
                records[i].Id = id;
            }
            var syncService = SVMX.getClient().getServiceRegistry()
            .getService("com.servicemax.client.installigence.sync").getInstance();
            syncService.getSObjectInfo(request.objectName)
            .done(function(objectInfo){
                // Create records
                var tableInfo = syncService.getTableInfoFromDescribe(objectInfo);
                var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                qo.replaceInto(request.objectName)
                .columns(tableInfo.columns)
                .values(request.records)
                .execute().done(function(resp){
                    // Update sync logs
                    var createdIds = [];
                    for(var i = 0; i < request.records.length; i++){
                        createdIds.push(request.records[i].Id);
                    }
                    syncDataUtil.createSyncLogs(request.objectName, createdIds, "insert")
                    .done(function(){
                        d.resolve();
                    });
                });
            });
            return d;
        },

        __applyTemplateValueMap : function(request){
            var me = this;
            var d = SVMX.Deferred();
            var topLevelId = request.records[0][SVMX.getCustomFieldName("Top_Level")];
            if(!topLevelId){
                d.resolve();
                return d;
            }
            var templateField = SVMX.getCustomFieldName("ProductIQTemplate");
            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            qo.select(templateField)
            .from(SVMX.getCustomObjectName("Installed_Product"))
            .where("Id = '"+topLevelId+"'")
            .execute()
            .then(function(result){
                // Get template config
                if(!result[0]){
                    d.resolve();
                    return;
                }
                var templateId = result[0][templateField];
                var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                return qo.select("Value")
                .from("Configuration")
                .where("Type = 'template' AND Key = '"+templateId+"'")
                .execute();
            })
            .then(function(result){
                // Find child products in template config
                var templateConfig = result[0] && result[0].Value;
                if(!templateConfig){
                    d.resolve();
                    return;
                }else{
                    templateConfig = SVMX.toObject(templateConfig);
                }
                for(var i = 0; i < request.records.length; i++){
                    var record = request.records[i];
                    var valueMapId = me.__findValueMapForProduct(record, templateConfig.template);
                    if(valueMapId){
                        me.__applyTemplateValueMapFieldUpdates(record, valueMapId, templateConfig.mappings);
                    }
                }
                // Finished applying value mappings
                d.resolve();
            });
            return d;
        },

        __findValueMapForProduct : function(record, template){
            var productField = SVMX.getCustomFieldName("Product");
            if(template.product){
                if(template.product.productId === record[productField]){
                    return template.product.newProductValueMap;
                }
            }
            if(template.children){
                for(var i = 0; i < template.children.length; i++){
                    var child = template.children[i];
                    var valueMapId = this.__findValueMapForProduct(record, child);
                    if(valueMapId){
                        return valueMapId;
                    }
                }
            }
        },

        __applyTemplateValueMapFieldUpdates : function(record, valueMapId, mappings){
            for(var i = 0; i < mappings.length; i++){
                var valueMap = mappings[i];
                if(valueMap.name !== valueMapId || !valueMap.mappingFields) continue;
                // Matched value map
                for(var j = 0; j < valueMap.mappingFields.length; j++){
                    var mapField = valueMap.mappingFields[j];
                    record[mapField.targetField] = mapField.value;
                }
            }
        }

    }, {});

    operationsImpl.Class("DeleteRecords", com.servicemax.client.mvc.api.Operation, {

        __constructor : function(){
            this.__base();
        },
        
        performAsync : function(request, responder){
            var me = this;

            if(request.params && request.params.node){
                // Delete a node from IBtree
                this.__getAllNodeRecordDetails(request)
                .done(function(recordDetails){
                    if(me.__areAllRecordsTransient(recordDetails)){
                        me.__deleteAllRecords(recordDetails)
                        .done(function(){
                            responder.result(true);
                        });
                    }else{
                        responder.result(false);
                    }
                });
            }else{
                // Delete records directly
                me.__deleteAllRecords(request.records)
                .done(function(){
                    responder.result(true);
                });
            }
        },

        __getAllNodeRecordDetails : function(request){
            var d = SVMX.Deferred();
            var util = com.servicemax.client.installigence.offline.model.utils.Util;
            var node = request.params.node;
            var recordDetails = [{
                id: request.recordId,
                objectName: util.getObjectNameByNodeType(node.data.nodeType)
            }];

            // recursively find all
            findAllRecords(node).done(function(){
                d.resolve(recordDetails);
            });
            function findAllRecords(parentNode){
                var d = SVMX.Deferred();
                var l = parentNode.childNodes.length, responseCount = 0;
                if(l){
                    for(var i = 0; i < l; i++){
                        var child = parentNode.childNodes[i];
                        if(child.data.nodeType === "LOADING"){
                            responseCount++;
                            continue;
                        }
                        recordDetails.push({
                            id : child.id,
                            objectName : util.getObjectNameByNodeType(child.data.nodeType)
                        });
                        // From top level IB, fetch all children
                        if(child.data.nodeType === "IB" && parentNode.data.nodeType !== "IB"){
                            util.getAllChildren4IB(child.id).done(function(childIBs){
                                for(var j = 0; j < childIBs.length; j++){
                                    recordDetails.push({
                                        id : childIBs[j].Id,
                                        objectName : util.getObjectNameByNodeType("IB")
                                    });
                                }
                                responseCount++;
                                if(responseCount === l) d.resolve();
                            });
                        }else{
                            findAllRecords(child).done(function(){
                                responseCount++;
                                if(responseCount === l) d.resolve();
                            });
                        }
                    }
                    if(responseCount === l) d.resolve();
                }else{
                    d.resolve();
                }
                return d;
            }

            return d;
        },

        __areAllRecordsTransient : function(recordDetails){
            for(var i = 0; i < recordDetails.length; i++){
                if(recordDetails[i].id.indexOf('transient') !== 0){
                    return false;
                }
            }
            return true;
        },

        __deleteAllRecords : function(recordDetails){
            var d = SVMX.Deferred();
            var syncDataUtil = com.servicemax.client.installigence.offline.model.utils.SyncData;
            // aggregate queries by object name
            var recordsIdsByObject = {};
            for(var i = 0; i < recordDetails.length; i++){
                var id = recordDetails[i].id;
                var objectName = recordDetails[i].objectName;
                recordsIdsByObject[objectName] = recordsIdsByObject[objectName] || [];
                recordsIdsByObject[objectName].push(id);
            }
            var allQueries = [], qo;
            for(var objectName in recordsIdsByObject){
                qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                qo.deleteFrom(objectName)
                .where("Id").within(recordsIdsByObject[objectName]);
                allQueries.push(qo);
                // Update sync logs
                for(var i = 0; i < recordsIdsByObject[objectName].length; i++){
                    var recordId = recordsIdsByObject[objectName][i];
                    syncDataUtil.deleteSyncLog(recordId);
                }
            }
            if(allQueries.length){
                var stackIndex = allQueries.length;
                for(var i = 0; i < allQueries.length; i++){
                    allQueries[i].execute().done(function(){
                        stackIndex--;
                        if(stackIndex === 0){
                            d.resolve();
                        }
                    });
                }
            }else{
                d.resolve();
            }
            return d;
        }

    }, {});
    
    operationsImpl.Class("GetTranslations", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },
        
        performAsync: function(request, responder){ 
            var syncService = SVMX.getClient().getServiceRegistry()
            .getService("com.servicemax.client.installigence.sync").getInstance();

            syncService.hasUserChanged().done(function(forceReset){
                syncService.getTranslations(forceReset).done(function(translations){
                    responder.result(translations);
                });
            });
        }
    }, {});

    operationsImpl.Class("GetLMTopLevelIBs", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },

        performAsync: function(request, responder){
            var me = this;
            //check the app exists
            var externalAppName = "LaptopMobile";
            me.__chkExternalAppExists(externalAppName)
            .done(function(appinfo){
                var app = SVMX.toObject(appinfo);
                if(app[0].Installed === "true"){
                    var service = SVMX.getClient().getServiceRegistry()
                        .getService("com.servicemax.client.installigence.sync").getInstance();
                    service.getUserInfo()
                    .done(function(resp){
                        var fields = [{name: SVMX.getCustomFieldName("Site"), type: "text"}];
                        var criteria = [{name: SVMX.getCustomFieldName("Site"), operator: "!=", value: ""}];
                        var request = {
                                objectName: SVMX.getCustomObjectName("Service_Order"),
                                fields: fields,
                                criteria: criteria,
                                userName: resp.UserName
                        };

                        request.type = "DATAACCESSAPI";
                        request.method = "SELECT";

                        var req = com.servicemax.client.installigence.offline.sal.model.nativeservice.Facade.createDataAccessAPIRequest();

                        req.bind("REQUEST_COMPLETED", function(evt){
                            var output = me.__parseResults(evt.data.data);
                            output = me.__getIdFieldValues(output);
                            if(!output.length){
                                responder.result([]);
                            }else{
                                var finder = new operationsImpl.FindByIB();
                                finder._downloadLocationsRecursive(output)
                                .done(function(childIds){
                                    var locationIds = childIds.concat(output);
                                    responder.result(locationIds);
                                });
                            }
                        }, this);
                        req.bind("REQUEST_ERROR", function(evt){
                            responder.result({});   
                        }, this);
                        req.execute(request);
                    });
                } else {
                    responder.result([]);
                }

            });

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
        },

        __parseResults: function(data) {
            data = SVMX.toObject(data);
            var i, ilength = data.length, obj = {};
            for(i = 0; i < ilength; i++) {
                obj[data[i].split(" : ")[0]] = data[i].split(" : ")[1];
            }
            var output = [];
            if(obj["Response Code"] === "1" && obj.Output.length > 0) {
                output = this.__parseOutput(obj.Output);
            }
            return output;
        },

        __parseOutput: function(data) {
            if(data && data[0] === "[" && data[data.length-1] !== "]"){
                // Fix incomplete JSON output
                data += "\"]]";
            }
            data = SVMX.toObject(data);
            var i, ilength = data.length, output = [];
            for(i = 0; i < ilength; i++) {
                var j = 0; jlength = data[i].length, obj = {};
                var currData = data[i];
                for(j = 0; j < jlength; j++){
                    obj[currData[j].split(":")[0]] = currData[j].split(":")[1];
                }
                output.push(obj);
            }
            return output;
        },

        __getIdFieldValues: function(data) {
            var i, ilength = data.length, output = [];
            for(i = 0; i < ilength; i++) {
                output.push(data[i][SVMX.getCustomFieldName("Site")]);
            }
            return output;
        }

    }, {});

    operationsImpl.Class("GetLMAccountsLocations", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },

        performAsync: function(request, responder){
            var me = this;
            //check the app exists
            var externalAppName = "LaptopMobile";
            me.__chkExternalAppExists(externalAppName)
            .done(function(appinfo){
                var app = SVMX.toObject(appinfo);
                if(app[0].Installed === "true"){
                    var service = SVMX.getClient().getServiceRegistry()
                        .getService("com.servicemax.client.installigence.sync").getInstance();
                    service.getUserInfo()
                    .done(function(resp){
                        var fields = [{name: SVMX.getCustomFieldName("Company"), type: "text"}];
                        var criteria = [{name: SVMX.getCustomFieldName("Company"), operator: "!=", value: ""}];
                        var request = {
                                objectName: SVMX.getCustomObjectName("Service_Order"),
                                fields: fields,
                                criteria: criteria,
                                userName: resp.UserName
                        };

                        request.type = "DATAACCESSAPI";
                        request.method = "SELECT";

                        var req = com.servicemax.client.installigence.offline.sal.model.nativeservice.Facade.createDataAccessAPIRequest();

                        req.bind("REQUEST_COMPLETED", function(evt){
                            var output = me.__parseResults(evt.data.data);
                            output = me.__getIdFieldValues(output);
                            if(!output.length){
                                responder.result([], []);
                            }else{
                                me._downloadLocationsByAccount(output)
                                .done(function(locationIds){
                                    responder.result(output, locationIds);
                                });
                            }
                        }, this);
                        req.bind("REQUEST_ERROR", function(evt){
                            responder.result([], []);   
                        }, this);
                        req.execute(request);
                    });
                } else {
                    responder.result([]);
                }

            });

        },

        _downloadLocationsByAccount : function(accountIds){
            var me = this;
            var d = SVMX.Deferred();

            locationIds = [];
            var parentField = SVMX.getCustomFieldName("Parent");
            var queryObj = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            queryObj.select(["Id"])
            .from(SVMX.getCustomObjectName("Site"))
            .where(SVMX.getCustomFieldName("Account")).within(accountIds);
            var query = queryObj.q();
            this._downloadRecords(query)
            .done(function(results){
                for(var i = 0; i < results.length; i++){
                    locationIds.push(results[i].Id);
                }
                d.resolve(locationIds);
            });
            return d;
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
        },

        __parseResults: function(data) {
            data = SVMX.toObject(data);
            var i, ilength = data.length, obj = {};
            for(i = 0; i < ilength; i++) {
                obj[data[i].split(" : ")[0]] = data[i].split(" : ")[1];
            }
            var output = [];
            if(obj["Response Code"] === "1" && obj.Output.length > 0) {
                output = this.__parseOutput(obj.Output);
            }
            return output;
        },

        __parseOutput: function(data) {
            if(data && data[0] === "[" && data[data.length-1] !== "]"){
                // Fix incomplete JSON output
                data += "\"]]";
            }
            data = SVMX.toObject(data);
            var i, ilength = data.length, output = [];
            for(i = 0; i < ilength; i++) {
                var j = 0; jlength = data[i].length, obj = {};
                var currData = data[i];
                for(j = 0; j < jlength; j++){
                    obj[currData[j].split(":")[0]] = currData[j].split(":")[1];
                }
                output.push(obj);
            }
            return output;
        },

        __getIdFieldValues: function(data) {
            var i, ilength = data.length, output = [];
            for(i = 0; i < ilength; i++) {
                output.push(data[i][SVMX.getCustomFieldName("Company")]);
            }
            return output;
        }

    }, {});

    operationsImpl.Class("GetLMProducts", operationsImpl.GetLMTopLevelIBs, {

        __constructor: function(){
            this.__base();
        },

        performAsync: function(request, responder){
            var me = this;
            me.__chkExternalAppExists("LaptopMobile")
            .done(function(appinfo){
                var app = SVMX.toObject(appinfo);
                if(app[0].Installed !== "true"){
                    responder.result([]);
                }
                var service = SVMX.getClient().getServiceRegistry()
                    .getService("com.servicemax.client.installigence.sync").getInstance();
                service.getUserInfo()
                .done(function(resp){
                    var util = com.servicemax.client.installigence.offline.model.utils.Util;
                    util.getObjectDescribeByName("Product2")
                    .done(function(objectInfo){
                        var fields = [];
                        for(var i = 0; i < objectInfo.fields.length; i++){
                            fields.push({name: objectInfo.fields[i].name, type: "text"});
                        }
                        var request = {
                            objectName: "Product2",
                            fields: fields,
                            criteria: [{name: "Id", operator: "!=", value: ""}],
                            userName: resp.UserName
                        };

                        request.type = "DATAACCESSAPI";
                        request.method = "SELECT";

                        var req = com.servicemax.client.installigence.offline.sal.model.nativeservice.Facade.createDataAccessAPIRequest();

                        req.bind("REQUEST_COMPLETED", function(evt){
                            var output = me.__parseResults(evt.data.data);
                            responder.result(output);
                        }, this);
                        req.bind("REQUEST_ERROR", function(evt){
                            responder.result({});   
                        }, this);
                        req.execute(request);
                    });
                });
            });
        }

    }, {});

    operationsImpl.Class("GetAllParentIBs", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },

        performAsync: function(request, responder){
            var util = com.servicemax.client.installigence.offline.model.utils.Util;
            util.getAllParents4IB(request.record.Id).done(function(parentIBs){
                responder.result(parentIBs);
            });
        }
    }, {});
    
    operationsImpl.Class("UpdateIBHierarchy", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },
        
        performAsync: function(request, responder){
            var me = this;
            var syncDataUtil = com.servicemax.client.installigence.offline.model.utils.SyncData;
            this.updateIBHierarchy(request.objectName, request.record)
            .done(function(updatedRecordIds){
                // Update sync logs
                syncDataUtil.createSyncLogs(request.objectName, updatedRecordIds, "update")
                .done(function(){
                    responder.result();
                });
            });
        },
        
        createFieldData4API: function(recId){
            var api = SVMX.create("com.servicemax.client.installigence.offline.model.utils.API", {});
            return api.method("UPDATE").objectName(SVMX.getCustomObjectName("Installed_Product"))
                                    .criteria([{"name": "Id", "value": recId, "operator": "="}]);
        },

        updateIBHierarchy : function(objectName, record){
            if(objectName === SVMX.getCustomObjectName("Site")){
                // Special case for location
                return this.updateLocation(record);
            }
            var me = this;
            var d = SVMX.Deferred();
            var util = com.servicemax.client.installigence.offline.model.utils.Util;
            util.getAllChildren4IB(record.Id).done(function(children){
                var updatedRecordIds = [];
                var allQueries = []; me.apiQueries = [];
                // update the parent record with the new location, toplevel and parent
                var qp = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                var locationId = record[SVMX.getCustomFieldName("Site")] || "";
                var sublocationId = record[SVMX.getCustomFieldName("Sub_Location")] || "";
                var parentId = record[SVMX.getCustomFieldName("Parent")] || "";
                var toplevelId = record[SVMX.getCustomFieldName("Top_Level")] || "";

                qp.update(SVMX.getCustomObjectName("Installed_Product"))
                .setValue(SVMX.getCustomFieldName("Site")).equals(locationId)
                .andSetValue(SVMX.getCustomFieldName("Sub_Location")).equals(sublocationId)
                .andSetValue(SVMX.getCustomFieldName("Parent")).equals(parentId)
                .andSetValue(SVMX.getCustomFieldName("Top_Level")).equals(toplevelId)
                .where("Id").equals(record.Id);
                allQueries.push(qp);

                updatedRecordIds.push(record.Id);
                
                if(record.Id.slice(0, 'transient-'.length) !== "transient-"){
                    me.apiQueries.push(
                        me.createFieldData4API(record.Id)
                        .addField(SVMX.getCustomObjectName("Site"), locationId)
                        .addField(SVMX.getCustomObjectName("Sub_Location"), sublocationId)
                        .addField(SVMX.getCustomObjectName("Parent"), parentId)
                        .addField(SVMX.getCustomObjectName("Top_Level"), toplevelId)
                    );
                }
                
                // update all children with location, toplevel
                // if there was no toplevel set, then the current record is the new toplevel
                toplevelId = toplevelId || record.Id; 

                var i, l = children.length;
                for(i = 0; i < l; i++){
                    qp = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                    qp.update(SVMX.getCustomObjectName("Installed_Product"))
                    .setValue(SVMX.getCustomFieldName("Site")).equals(locationId)
                    .andSetValue(SVMX.getCustomFieldName("Sub_Location")).equals(sublocationId)
                    .andSetValue(SVMX.getCustomFieldName("Top_Level")).equals(toplevelId)
                    .where("Id").equals(children[i].Id);
                    allQueries.push(qp);

                    updatedRecordIds.push(children[i].Id);
                    
                    if(children[i].Id.slice(0, 'transient-'.length) !== "transient-")
                        me.apiQueries.push(me.createFieldData4API(children[i].Id).addField(SVMX.getCustomObjectName("Site"), locationId)
                             .addField(SVMX.getCustomObjectName("Sub_Location"), sublocationId)
                             .addField(SVMX.getCustomObjectName("Parent"), parentId)
                             .addField(SVMX.getCustomObjectName("Top_Level"), toplevelId));
                }

                // execute all the queries
                l = allQueries.length;
                var stackIndex = l;
                for(i = 0; i < l; i++){
                    allQueries[i].execute().done(function(resp){
                        stackIndex--;
                        if(stackIndex == 0){
                            me.apiIBUpdate(me.apiQueries);
                            d.resolve(updatedRecordIds);                            
                        }
                    });
                }
            });
            return d;
        },

        updateLocation : function(record){
            var d = SVMX.Deferred();
            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            var parentId = record[SVMX.getCustomFieldName("Parent")] || "";
            qo.update(SVMX.getCustomObjectName("Site"))
            .setValue(SVMX.getCustomFieldName("Parent")).equals(parentId)
            .where("Id").equals(record.Id)
            .execute().done(function(){
                d.resolve([record.Id]);
            });
            return d;
        },
        
        apiIBUpdate: function(apiQueries){
            var d = SVMX.Deferred();
            var i = 0, l = apiQueries.length;
            var stackIndex = l;
            for(i = 0; i < l; i++){
                apiQueries[i].execute().done(function(resp){
                    stackIndex--;
                    if(stackIndex == 0){
                         d.resolve();
                    }
                });
            }
            return d;
        }
    }, {});

    operationsImpl.Class("ApplyFieldUpdate", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },
        
        performAsync: function(request, responder){
            this.__applyFieldUpdate(request.targetIds, request.mapName, request.cascade)
            .done(function(){
                responder.result(true);
            })
            .fail(function(){
                responder.result(false);
            });
        },

        __applyFieldUpdate : function(targetIds, mapName, cascade){
            var d = SVMX.Deferred(), me = this;
            var mapping = null;
            var util = com.servicemax.client.installigence.offline.model.utils.Util;
            util.getUserConfiguration()
            .then(function(config){
                mapping = me.__getMappingByName(mapName, config.mappings);
                if(!mapping){
                    d.reject();
                    return;
                }
                return util.getObjectDescribeByName(mapping.targetObjectName);
            })
            .then(function(objectDesc){
                var ds = [];
                var i, l = targetIds.length;
                for(i = 0; i < l; i++){
                    ds.push(
                        me.__mapTargetFields(targetIds[i], mapping, cascade)
                    );
                }
                SVMX.when(ds).then(function(){
                    d.resolve();
                });
            })
            return d;
        },

        __getMappingByName : function(mapName, mappings){
            if(!mappings) return null;
            var i, l = mappings.length;
            for(i = 0; i < l; i++){
                if(mappings[i].name === mapName){
                    return mappings[i];
                }
            }
        },

        __mapTargetFields : function(targetId, mapping, cascade){
            var me = this;
            var d = SVMX.Deferred();
            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            qo.update(mapping.targetObjectName);
            var i, l = mapping.mappingFields.length;
            for(i = 0; i < l; i++){
                var field = mapping.mappingFields[i];
                if(i === 0){
                    qo.setValue(field.targetField);
                }else{
                    qo.andSetValue(field.targetField);
                }
                
                var DatetimeUtils = com.servicemax.client.lib.datetimeutils.DatetimeUtil;
                
                switch(field.value) {
                    case "Today":
                    case "Tomorrow":
                    case "Yesterday":
                        field.value = DatetimeUtils.macroDrivenDatetime(field.value, "YYYY-MM-DD", "hh:mm:ss", "date");
                        break;
                    case "Now":
                        field.value = DatetimeUtils.macroDrivenDatetime(field.value, "YYYY-MM-DD", "hh:mm:ss");
                        field.value = field.value.replace(" ", "T");
                        field.value = this.__convertToUTC(field.value) + ".000+0000";
                        break;
                    case "SVMX.NOW":
                        field.value = DatetimeUtils.macroDrivenDatetime("Now", "YYYY-MM-DD", "hh:mm:ss");
                        field.value = field.value.replace(" ", "T");
                        field.value = this.__convertToUTC(field.value) + ".000+0000";
                    case "SVMX.TODAY":
                        value = DatetimeUtils.macroDrivenDatetime("Today", "YYYY-MM-DD", "hh:mm:ss", "date");
                        break;
                    case "SVMX.TOMORROW":
                        value = DatetimeUtils.macroDrivenDatetime("Tomorrow", "YYYY-MM-DD", "hh:mm:ss", "date");
                        break;
                    case "SVMX.YESTERDAY":
                        value = DatetimeUtils.macroDrivenDatetime("Yesterday", "YYYY-MM-DD", "hh:mm:ss", "date");
                        break;
                }
                qo.equals(field.value);
            }
            if(cascade){
                var util = com.servicemax.client.installigence.offline.model.utils.Util;
                util.getAllChildren4IB(targetId).done(function(children){
                    var targetIds = [targetId];
                    for(var i = 0; i < children.length; i++){
                        targetIds.push(children[i].Id);
                    }
                    qo.where('Id').within(targetIds);
                    qo.execute().done(function(){
                        me.__mapTargetFieldsComplete(d, mapping, targetIds);
                    });
                });
            }else{
                qo.where('Id').equals(targetId);
                qo.execute().done(function(){
                    me.__mapTargetFieldsComplete(d, mapping, [targetId]);
                });
            }
            return d;
        },

        __mapTargetFieldsComplete : function(d, mapping, targetIds){
            // Update sync log
            var syncDataUtil = com.servicemax.client.installigence.offline.model.utils.SyncData;
            syncDataUtil.createSyncLogs(mapping.targetObjectName, targetIds, "update")
            .done(function(){
                d.resolve();
            });
        },
        
        __convertToUTC : function(value){
            value = new Date(value);
            value = new Date(value.getTime() + (value.getTimezoneOffset() * 60000));
            return value.toISOString();
        }

    }, {});
    
    operationsImpl.Class("SaveRecord", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },
        
        performAsync: function(request, responder){ 
            this.saveRecord(request.objectName, request.meta, request.record, request.dataValidationRules).done(function(resp){
                request.handler(resp);
            });
        },
        
        validateUsingDataValidationRules: function(objectName, meta, record, dataValidationRules){
        	__businessRuleValidator = SVMX.create("com.servicemax.client.sfmbizrules.impl.BusinessRuleValidator");
        	
        	var rules = {};
        	rules.header = {};
        	rules.header.rules = [];

            var iRule = 0, iRuleLength = dataValidationRules.length;
            for(iRule=0; iRule < iRuleLength; iRule++){
                rules.header.rules[iRule] = {};
                rules.header.rules[iRule].message = dataValidationRules[iRule].header.errorMessage;
                rules.header.rules[iRule].ruleInfo = {};
                rules.header.rules[iRule].ruleInfo.bizRule = dataValidationRules[iRule].header;
                rules.header.rules[iRule].ruleInfo.bizRuleDetails = dataValidationRules[iRule].details;
            }
        	var data = record.__r;
        	var fields = [];
        	var fieldTypeMap = [];
        	var i=0;
        	for(i==0; i<meta.length; i++){
        		fieldTypeMap[meta[i].name] = meta[i].type;
        	}
        	
        	fields[dataValidationRules[0].header.objectName] = fieldTypeMap;
        	
        	var businessRulesResult =
				__businessRuleValidator.evaluateBusinessRules( {
					rules: rules, data: data, fields: fields, pageModel: null, recordTypeMaps: null
				});
        	return businessRulesResult;
        },
        
        saveRecordConfirm: function(objectName, meta, record, dataValidationRules){
            var d = SVMX.Deferred();
            var recId = record.pull("Id");
            var i, l = meta.length; var includeAnd = false;
            var recordNames = {};
            var qp = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            var apiQuery = SVMX.create("com.servicemax.client.installigence.offline.model.utils.API", {});
            apiQuery.method("UPDATE").objectName(objectName)
                                .criteria([{"name": "Id", "value": recId, "operator": "="}]);
            qp = qp.update(objectName)
            for(i = 0; i < l; i++){
                var fld = meta[i];
                var value = record.pull(fld.name);
                if(!fld.readOnly && value !== undefined){
                    if(includeAnd)
                        qp = qp.andSetValue(fld.name).equals(value);
                    else{
                        qp = qp.setValue(fld.name).equals(value);
                        includeAnd = true;
                    }
                    apiQuery.addField(fld.name, value);
                    if(value && fld.type === "reference" && fld._binding){
                        var name = fld._binding.name();
                        // TODO: figure out if this is useful
                        // If not, delete it
                        if(false && name){
                            recordNames[fld.name] = {
                                value : value,
                                name : name
                            };
                        }
                    }
                }
            }
            qp = qp.where("Id").equals(recId); 
            qp.execute().done(function(resp){
                var syncDataUtil = com.servicemax.client.installigence.offline.model.utils.SyncData;
                syncDataUtil.createSyncLogs(objectName, [recId], "update")
                .done(function(){
                    //now update API
                    if(recId.slice(0, 'transient-'.length) !== "transient-"){
                        apiQuery.execute().done(function(resp){
                            //nothing to update.
                        });
                    }
                    operationsImpl.recordNameCache = operationsImpl.recordNameCache || {};
                    var rnFields = Object.keys(recordNames);
                    for(var i = 0; i < rnFields.length; i++){
                        rnField = recordNames[rnFields[i]];
                        if(operationsImpl.recordNameCache[rnField.value] !== rnField.name){
                            operationsImpl.recordNameCache[rnField.value] = rnField.name;
                        }else{
                            continue;
                        }
                        var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                        qo.replaceInto("RecordName")
                        .columns([{name : "Id"}, {name : "Name"}])
                        .values({Id : rnField.value, Name : rnField.name})
                        .execute().done(function(){

                        });
                    }
                    d.resolve();
                });

                
            });
            return d;
        },

        saveRecord: function(objectName, meta, record, dataValidationRule){
        	
            if(dataValidationRule && dataValidationRule.length > 0){
                var businessRulesResult = this.validateUsingDataValidationRules(objectName, meta, record, dataValidationRule);

                if(businessRulesResult){
                    if(businessRulesResult.errors.length > 0 || businessRulesResult.warnings.length > 0){
                        var d = SVMX.Deferred();
                        d.resolve({data: businessRulesResult, okCallBack: {handler: this.saveRecordConfirm, context: this}});
                        return d;
                    }
                }
            }
        	
            return this.saveRecordConfirm(objectName, meta, record, dataValidationRule);
        }
        
    }, {});

    operationsImpl.Class("CloneRecord", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },
        
        performAsync: function(request, responder){
            var me = this;
            this.__cloneParentRecord(request)
            .done(function(parent, objectInfo){
                if(request.cascade
                    && objectInfo.name === SVMX.getCustomObjectName("Installed_Product")){
                    me.__cloneChildIBs(request, parent, objectInfo)
                    .done(function(){
                        responder.result(parent);
                    });
                }else{
                    responder.result(parent);
                }
            });
        },

        __cloneParentRecord : function(request){
            var me = this;
            var d = SVMX.Deferred();
            var modelUtil = com.servicemax.client.installigence.offline.model.utils.Util;
            modelUtil.getObjectDescribeByName(request.objectName)
            .done(function(objectInfo){
                me.__cloneRecord(request.targetId, objectInfo)
                .done(function(parent){
                    d.resolve(parent, objectInfo);
                });
            });
            return d;
        },

        __cloneRecord : function(recordId, objectInfo, data){
            var me = this;
            var d = SVMX.Deferred();
            var util = com.servicemax.client.installigence.utils.impl.Util;

            var newRecordId = "transient-"+util.guid();
            var fields = [];
            var specFields = data || {};
            if (objectInfo.name === SVMX.getCustomObjectName("Installed_Product")) {
                // TEMPORARY: hard coded field map for cloned IBs
                // Remove this when clone field maps are available
                specFields.Id = newRecordId;
                specFields.Name = "";
                specFields[SVMX.getCustomFieldName("Top_Level")] = specFields[SVMX.getCustomFieldName("Top_Level")] || "";
                specFields[SVMX.getCustomFieldName("Parent")] = specFields[SVMX.getCustomFieldName("Parent")] || "";
                specFields[SVMX.getCustomFieldName("Site")] = "";
                specFields[SVMX.getCustomFieldName("Product")] = "";
                specFields[SVMX.getCustomFieldName("Sub_Location")] = "";
                specFields[SVMX.getCustomFieldName("Company")] = "";
                specFields.Category__c = "";
                specFields.DeviceType2__c = "";
                specFields.Brand2__c = "";
                var columns = [];
                for(var i = 0; i < objectInfo.fields.length; i++){
                    var field = objectInfo.fields[i];
                    if(specFields[field.name]){
                        fields.push("'"+specFields[field.name]+"'");
                    }else if(field.name in specFields){
                        fields.push(field.name);
                    }
                    if(field.name in specFields){
                        columns.push({name: field.name});
                    }
                }
            }else{
                specFields.Id = newRecordId;
                specFields.OwnerId = "";
                specFields.CreatedDate = "";
                specFields.CreatedById = "";
                specFields.LastModifiedDate = "";
                specFields.LastModifiedById = "";
                specFields.SystemModstamp = "";
                specFields.LastViewedDate = "";
                specFields.LastReferencedDate = "";
                var columns = [];
                for(var i = 0; i < objectInfo.fields.length; i++){
                    var field = objectInfo.fields[i];
                    if(specFields[field.name]){
                        fields.push("'"+specFields[field.name]+"'");
                    }else{
                        fields.push(field.name);
                    }
                    columns.push({name: field.name});
                }
            }
            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            qo.insertIntoSelect(
                objectInfo.name, columns, objectInfo.name, fields
            )
            .where("Id").equals(recordId);
            qo.execute().done(function(){
                var syncDataUtil = com.servicemax.client.installigence.offline.model.utils.SyncData;
                syncDataUtil.createSyncLogs(objectInfo.name, [newRecordId], "insert");
                var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                qo.select("*")
                .from(objectInfo.name)
                .where("Id").equals(newRecordId)
                .execute().done(function(resp){
                    d.resolve(resp[0]);
                });
            });
            return d;
        },

        __cloneChildIBs : function(request, parent, objectInfo, childIBs){
            var me = this;
            var d = SVMX.Deferred();
            var util = com.servicemax.client.installigence.offline.model.utils.Util;
            if(!childIBs){
                util.getAllChildren4IB(request.targetId).done(function(children){
                    var childIBIds = [];
                    for(var i = 0; i < children.length; i++){
                        childIBIds.push(children[i].Id);
                    }
                    var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                    qo.select("*")
                    .from(objectInfo.name)
                    .where("Id").within(childIBIds)
                    .execute().done(function(results){
                        childIBs = results;
                        cloneRecordsInternal();
                    });
                });
            }else{
                cloneRecordsInternal();
            }
            function cloneRecordsInternal(){
                var topLevelField = SVMX.getCustomFieldName("Top_Level");
                var parentField = SVMX.getCustomFieldName("Parent");
                for(var i = 0; i < childIBs.length; i++){
                    childIBs[i].__data = childIBs[i].__data || {};
                    if(childIBs[i][topLevelField] === request.targetId){
                        childIBs[i].__data[topLevelField] = parent.Id;
                    }
                    if(childIBs[i][parentField] === request.targetId){
                        childIBs[i].__data[parentField] = parent.Id;
                    }else{
                        if(childIBs[i][parentField] === parent.__prevId){
                            childIBs[i].__data[parentField] = parent.Id;
                        }
                    }
                }
                var ds = [];
                for(var i = 0; i < childIBs.length; i++){
                    if(childIBs[i].__cloned
                        || childIBs[i].__data[parentField] !== parent.Id){
                        continue;
                    }
                    var d2 = SVMX.Deferred();
                    ds.push(d2);
                    (function(i, d2){
                        childIBs[i].__cloned = true;
                        me.__cloneRecord(childIBs[i].Id, objectInfo, childIBs[i].__data)
                        .done(function(record){
                            record.__prevId = childIBs[i].Id;
                            me.__cloneChildIBs(request, record, objectInfo, childIBs)
                            .done(function(){
                                d2.resolve();
                            });
                        });
                    })(i, d2);
                }
                if(ds.length){
                    SVMX.when(ds).then(function(){
                        d.resolve();
                    });
                }else{
                    d.resolve();
                }
            }
            return d;
        }

    }, {});

    operationsImpl.Class("SaveState", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },
        
        performAsync: function(request, responder){
            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            qo.select("1")
            .from("Configuration")
            .where("Type = 'state'")
            .execute().done(function(resp){
                if(resp.length){
                    var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                    qo.update("Configuration")
                    .setValue("Value").equals(SVMX.toJSON(request.state))
                    .where("Type = 'state'")
                    .execute().done(function(resp){
                        responder.result();
                    });
                }else{
                    var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                    qo.insertInto("Configuration")
                    .columns([{name : "Type"}, {name : "Value"}])
                    .values({Type : "state", Value : SVMX.toJSON(request.state)})
                    .execute().done(function(){
                        responder.result();
                    });
                }
            });
        }
        
    }, {});

    operationsImpl.Class("GetSyncConflicts", com.servicemax.client.mvc.api.Operation, {

        __constructor : function(){
            this.__base();
        },
        
        performAsync : function(request, responder){
            this.getSyncConflicts()
            .done(function(resp){
                responder.result(resp);
            });
        },
        
        getSyncConflicts : function(meta, record){
            var me = this;
            var d = SVMX.Deferred();
            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            qo.select("*")
            .from("ClientSyncConflict c1 LEFT JOIN ClientSyncLog c2 ON c1.Id = c2.Id")
            .execute().done(function(result){
                me.__appendRecordsForConflicts(result)
                .done(function(){
                    d.resolve(result);
                });
            });
            return d;
        },

        __appendRecordsForConflicts : function(result){
            var d = SVMX.Deferred();
            var counter = 0;
            if(!result.length){
                d.resolve();
                return d;
            }
            for(var i = 0; i < result.length; i++){
                var conflict = result[i];
                (function(conflict){
                    var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                    qo.select("*")
                    .from(conflict.ObjectName)
                    .where("Id").equals(conflict.Id)
                    .execute().done(function(res){
                        conflict.record = res[0];
                        counter++;
                        if(counter === result.length){
                            d.resolve();
                        }
                    });
                })(conflict);
            }
            return d;
        }
        
    }, {});

    operationsImpl.Class("UpdateSyncConflicts", com.servicemax.client.mvc.api.Operation, {

        __constructor : function(){
            this.__base();
        },
        
        performAsync : function(request, responder){
            this.updateSyncConflicts(request.records)
            .done(function(){
                responder.result();
            });
        },
        
        updateSyncConflicts : function(records){
            var d = SVMX.Deferred();
            var counter = 0;
            for(var i = 0; i < records.length; i++){
                var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                var record = records[i];
                var fields = Object.keys(record);
                qo.update("ClientSyncConflict");
                for(var j = 0; j < fields.length; j++){
                    var field = fields[j];
                    if(j === 0){
                        qo.setValue(field).equals(record[field]);
                    }else{
                        qo.andSetValue(field).equals(record[field]);
                    }
                }
                qo.where("Id").equals(record.Id)
                .execute().done(function(result){
                    counter++;
                    if(counter === records.length){
                        d.resolve();
                    }
                });
            }
            return d;
        }
        
    }, {});
    
    operationsImpl.Class("SendExternalMessage", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },

        performAsync: function(request, responder){
            
            var nativeService = com.servicemax.client.installigence.offline.sal.model.nativeservice.Facade;
            var extRequest = nativeService.createSendExternalRequest();

            extRequest.bind("REQUEST_COMPLETED", function(evt) {
                
            });

            extRequest.bind("REQUEST_ERROR", function(evt) {
                
            });

            // Fire and forget, for now           
            extRequest.execute({
                appName         : request.appName,
                externalRequest : SVMX.toJSON(request.message)
            });
        }
    }, {});
    
    operationsImpl.Class("ExecuteAPI", com.servicemax.client.mvc.api.Operation, {
        //enhance this further for other api related
        __constructor: function(){
            this.__base();
        },

        performAsync: function(request, responder){
            
            if(request.method === "CLEARLOCKS")
                this.__clearLocks(request);
        },
        
        __clearLocks: function(request){
            var apiQuery = SVMX.create("com.servicemax.client.installigence.offline.model.utils.API", {});
            apiQuery.method("CLEARLOCKS").recordIds(request.recordIds);
            apiQuery.execute().done(function(resp){
                //nothing to update.
            });
        }
    }, {});
    
    operationsImpl.Class("GetApplicationFocus", com.servicemax.client.mvc.api.Operation, {
        //enhance this further for other api related
        __constructor: function(){
            this.__base();
        },

        performAsync: function(request, responder){
            
            var nativeService = com.servicemax.client.installigence.offline.sal.model.nativeservice.Facade;
            var extRequest = nativeService.createApplicationFocusRequest();

            extRequest.bind("REQUEST_COMPLETED", function(evt) {
                
            });

            extRequest.bind("REQUEST_ERROR", function(evt) {
                
            });

            // Fire and forget, for now           
            extRequest.execute({
                
            });
            
        }
    }, {});
    
    /* First version of GetLookupConfig operation, contains some hardcoded values required for working ahead/testing
     * Need to remove them.
     */
    operationsImpl.Class("GetLookupConfig", com.servicemax.client.mvc.api.Operation, {

        __constructor: function() {
            this.__base();
        },
        
        performAsync: function(request, responder) {
            var result = {};
            var me = this;
            this.keyword = request.keyword === undefined ? "" : request.keyword;
            this.searchOperator = request.searchOperator;
            this.includeMFLRecords = false;
            this.includeOnlineRecords = false;
            this.contextValue = request.lookupContext;
            this.contextMatchField = request.lookupQueryField;
            this.callType = request.callType;
			this.request = request;
			this.objectName = request.objectName;
            this.recordId = request.recordId; // BubbleData only
            this.handler = request.handler;
            this.describeData = null;
            this.fieldDefs = {};
            this.onlineQuery = null;
            //TODO : Check usage of waitForData
            var waitForData = false,
                lookupDef = null;
            if(request.mflChecked && request.mflChecked !== undefined && request.mflChecked === 'true')
            	this.includeMFLRecords = true;
            if(request.onlineChecked && request.onlineChecked !== undefined && request.onlineChecked === 'true')
            	this.includeOnlineRecords = true;
            
            // TODO: Build a single state object that contains this and responder and all other state
            // instead of having state vary from method to method within this class
            this.response = {
                namesearchinfo: {
                    namedSearch: [{
                        namedSearchHdr: {},
                        namedSearchDetails: [{
                            fields: []
                        }]
                    }]
                },
                data: [],
                advFilters: [],
                displayCols:[],
                parentNodeId: request.parentNodeId
            };
            responder.__waitCounter = {
                count: 0,
                subRecordsStarted: false
            };
            var utils = com.servicemax.client.installigence.offline.model.utils.Util;
            utils.getObjectDescribeByName(this.objectName)
            .done(function(describeData){
            	me.describeData = describeData;
            	var objectName = describeData.name;
            	me.fieldDefs = {};
                SVMX.array.forEach(describeData.fields, function(f) {
                	me.fieldDefs[f.name] = f;
                }, this);

                if (request.LookupRecordId) {
                    key = request.LookupRecordId;
                    me.queryLookupData(responder, key, result);
                } else {

                	var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                    qo.select("*").from("SFNamedSearch").where("is_default = 'true' AND object_name = '"+objectName+"'")
                    .execute().done(function(resp){
                    	if (resp && resp.length) {
                            key = resp[0].search_sfid;
                            me.queryLookupData(responder, key, result);
                        } else {
                            logger.error("CONFIGURATION WARNING: There is neither a configured nor default LookupConfig for " + this.objectName);
                            me.generateLookupData(this.objectName, responder, result);
                        }
                    }); 
                	key = this.objectName;
                }
            
            });
        },


        generateLookupData: function(objectName, responder, result) {
            responder.__waitCounter.count++;
            responder.__waitCounter.subRecordsStarted = true;

            var nameField = this._getNameField(this.objectName);
            var data = [{
                "expression_type": "SRCH_Object_Fields",
                "field_name": nameField,
                "search_object_field_type": "Search",
                "field_type": "",
                "field_relationship_name": "",
                "sequence": "1.0000"
            }, {
                "expression_type": "SRCH_Object_Fields",
                "field_name": nameField,
                "search_object_field_type": "Result",
                "field_type": "",
                "field_relationship_name": "",
                "sequence": "2.0000"
            }];

            var lookupDefDetail = {
                    bubbleFields: [],
                    defaultLookupColumn: nameField,
                    displayFields: [data[1]],
                    numberOfRecs: 10,
                    preFilterCriteria: "",
                    queryColumns: "Id, Name",
                    searchFields: [data[0]]
                };

                var lookupDef = {
                    key: objectName,
                    advFilters: [],
                    lookupDefDetail: lookupDefDetail
                };


            this.__prepareSearchUsingLookupDef(
                {
                    responder: responder,
                    result: result
                },
                lookupDef
            );
        },

        //querying for all the lookupdata fields from SFNamedSearchComponent
        queryLookupData: function(responder, key, result) {
            var me = this;
        	responder.__waitCounter.count++;
            
            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            qo.select("*").from("SFNamedSearchComponent").where("named_search = '"+key+"'")
            .execute().done(function(resp){
            	if (resp && resp.length) {
                   me._onQueryLookupDataSuccess(responder, resp, result);
                } else {
                    logger.error("CONFIGURATION WARNING: There is neither a configured nor default LookupConfig for " + this.objectName);
                    me._onQueryLookupDataError(responder, result);
                }
            });
            
            
           /* execQuery({
                query: "SELECT * FROM SFNamedSearchComponent WHERE named_search = '{{key}}'",
                queryParams: {
                    key: key
                },
                state: {
                    responder: responder,
                    result: result
                },
                context: this,
                onSuccess: "_onQueryLookupDataSuccess",
                onError: "_onQueryLookupDataError"
            });*/
        },

        //Define search and result fields
        _onQueryLookupDataSuccess: function(responder, resp, result) {
            responder.__waitCounter.subRecordsStarted = true;
            var me = this;
            var key = resp[0].named_search, i, l = resp.length;
            /* var data = getDataFromEvt(evt),
                key = data.length ? data[0].named_search : null,
                i, l = data.length;
            if (data.length == 0) {
                this._onGetLookupDefError(state.responder, SVMX.cloneObject(this.response), evt);
                return;
            } else {*/
                var describeData = me.describeData;
                        var fieldsHash = {};
                        SVMX.array.forEach(describeData.fields, function(f) {
                            fieldsHash[f.name] = true;
                        });
                        this.displayFields = [];
                        this.searchFields = [];
                        var displayFieldsHash = {};
                        var searchFieldsHash = {};
                        for (i = 0; i < l; i++) {
                            var fldName = resp[i].field_name;

                            // TODO: Shouldn't we have a search_object_field_type == "Bubble"?  According to the Designer we should...
                            if (fieldsHash[fldName]) {
                                if (resp[i].search_object_field_type == "Result") {
                                    if (!displayFieldsHash[resp[i].field_name]) {
                                        this.displayFields.push(resp[i]);
                                        displayFieldsHash[resp[i].field_name] = true;
                                        this.response.displayCols.push(resp[i].field_name);
                                    }
                                }

                                if (resp[i].search_object_field_type == "Search") {
                                    if (!searchFieldsHash[resp[i].field_name]) {
                                        this.searchFields.push(resp[i]);
                                        searchFieldsHash[resp[i].field_name] = true;
                                    }
                                }
                            }/* else {
                                logger.error("Minor Error: Lookup Config uses field '" + fldName + "' which is not available to this user");
                            }*/
                        }
                        me.getLookupDef(responder, key, result, displayFieldsHash);

           // }
        },

        _onQueryLookupDataError: function(responder, result) {
            logger.info("No lookup data, NamedSearchComponent table might be empty");
            responder.result(result);
        },

        //Define the lookup definition by querying for the fields from SFNamedSearch
        getLookupDef: function(responder, key, result, displayFieldsHash) {
        	var me = this;
        	var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            qo.select("*").from("SFNamedSearch").where("search_sfid = '"+key+"'")
            .execute().done(function(resp){
            	if (resp && resp.length) {
                    me._onGetLookupDefSuccess(responder, resp, result, key);
            	} else {
            		me._onQueryLookupDataError(responder, result);
            	}
             });
        	
        	
        	
        	/*execQuery({
                query: "SELECT * FROM SFNamedSearch where search_sfid = '{{key}}'",
                queryParams: {
                    key: key
                },
                state: {
                    responder: responder,
                    result: result,
                    key: key
                },
                context: this,
                onSuccess: "_onGetLookupDefSuccess",
                onError: "_onGetLookupDefError"
            })*/
        },

        _onGetLookupDefSuccess: function(responder, resp, result, key) {
            
        	//state.result.data = getDataFromEvt(evt);
            //TODO IMP : check where the query columns info is coming from in the table
            /*var key = state.result.data[0].object_name, me = this,
                displayFields1 = this.displayFields,
                searchFields = this.searchFields,
                numOfRecords = state.result.data[0].no_of_lookup_records;*/
        	
        	var objectName = resp[0].object_name, me = this,
        	displayFields1 = this.displayFields,
            searchFields = this.searchFields,
            numOfRecords = resp[0].no_of_lookup_records;

            var d1 = me.getPreFilterCriteria(responder, key, result);
            var d2 = me.getAdvFilterCriteria(responder, key, result);
            SVMX.when([d1,d2]).then(SVMX.proxy(this, function() {
                var lookupDefDetail = {
                    bubbleFields: [],
                    defaultLookupColumn: resp[0].default_lookup_column,
                    displayFields: displayFields1,
                    numberOfRecs: resp[0].no_of_lookup_records,
                    preFilterCriteria: me.pfc,
                    queryColumns: "Id, Name",
                    searchFields: searchFields
                };

                var lookupDef = {
                    key: objectName,
                    advFilters: me.afc,
                    lookupDefDetail: lookupDefDetail
                };
                return me.__prepareSearchUsingLookupDef(responder, resp, result, lookupDef, key);
            }));
        },

        __prepareSearchUsingLookupDef: function(responder, resp, result, lookupDef, key) {
            var me = this;
            var namedSearchHdr = me.response.namesearchinfo.namedSearch[0].namedSearchHdr,
                namedSearchDetails = me.response.namesearchinfo.namedSearch[0].namedSearchDetails[0],
                fields = namedSearchDetails.fields,
                i, l;

            namedSearchHdr[SVMX.OrgNamespace + "__Default_Lookup_Column__c"] = lookupDef.lookupDefDetail.defaultLookupColumn;

            var displayFields = lookupDef.lookupDefDetail.displayFields,
                l = displayFields.length,
                fld;

            for (i = 0; i < l; i++) {
                fld = {};
                fld[SVMX.OrgNamespace + "__Field_Name__c"] = displayFields[i].field_name;
                fld[SVMX.OrgNamespace + "__Sequence__c"] = displayFields[i].sequence;
                fld[SVMX.OrgNamespace + "__Search_Object_Field_Type__c"] = "Result";
                fld["nameField"] = null; //displayFields[i].refObjectNameField;
                fld["dataType"] = displayFields[i].field_type;
                fld["relationshipName"] = displayFields[i].field_relationship_name;
                fields.push(fld);
            }
            var requestData = {};

            //TODO : Check if the following condition is required
            //TODO: Find out what we are REALLY suppose to do with META; only here
            //because without it, lookups fail.
            if (me.callType == "DATA" || me.callType == "BOTH" || me.callType == "META" || me.callType == "BUBBLE") {
                waitForData = true;
                requestData.lookupRequest = {
                    lookupDef: lookupDef,
                    keyword: me.keyword,
                    Operator: me.searchOperator,
                    ContextValue: me.contextValue,
                    ContextMatchField: me.contextMatchField
                };
            }


            var lookupRequest = {
                lookupDef: lookupDef,
                keyword: this.keyword,
                Operator: this.searchOperator,
                ContextValue: this.contextValue,
                ContextMatchField: this.contextMatchField
            };
            this.onlineQuery = me.buildQueryForOnlineRecords(lookupRequest);
            me.getLUPSearchResults(responder, result, requestData.lookupRequest, fields, key, lookupDef.lookupDefDetail.numberOfRecs);
        },
        
        
        buildQueryForOnlineRecords : function(lookupRequest){

        	var query = '', displayFields = lookupRequest.lookupDef.lookupDefDetail.displayFields, i, l = displayFields.length, queryColumn = lookupRequest.lookupDef.lookupDefDetail.queryColumns, searchClause = '';
        	for(i = 0; i < l; i++){
    			if(query.length > 0 ){
    				query += ', '+displayFields[i].field_name;
    			}
    			else{
    				query = queryColumn;
    			}
    			
    		}
    		if(lookupRequest.keyword !== ''){
    			var serchFields = lookupRequest.lookupDef.lookupDefDetail.lookupDefDetail.searchFields, l = serchFields.lenght;
    			for(i = 0;i<l;i++){
    				if(searchClause.length > 0){
    					searchClause += ' OR '+serchFields[i].field_name + 'like %'+keyword+'%';
    				}else{
    					searchClause += serchFields[i].field_name + 'like %'+keyword+'%';
    				}
    			}
    			searchClause = ' ( '+searchClause+' ) ';
    		}
    		query = 'Select '+query + ' From '+lookupRequest.lookupDef.key;
    		if(lookupRequest.lookupDef.lookupDefDetail.preFilterCriteria !== ''){
    			query = query+' where '+lookupRequest.lookupDef.lookupDefDetail.preFilterCriteria;
    		}
    		if(searchClause !== ''){
    			query = query+searchClause;
    		}
    		if(lookupRequest.lookupDef.lookupDefDetail.numberOfRecs != ''){
    			query = query+' limit '+lookupRequest.lookupDef.lookupDefDetail.numberOfRecs;
    		}
    		console.log(query);
    		return query;
        },
        
        
        getPreFilterCriteria : function(responder, key, result){
			/*var d = new $.Deferred();
			execQuery({
				query: "SELECT * FROM SFNamedSearchCriteria WHERE named_search = '{{key}}' AND rule_type = 'SRCH_OBJECT'",
				queryParams: {key : key},
				context: this,
				state : {responder : responder, key : key, result : result, d:d},
				onSuccess : "_onGetPFCSuccess",
				onError: "_onGetPFCError"
			});
			return d;*/
        	var a = SVMX.Deferred();        	
        	var me = this;
        	
        	var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            qo.select("*").from("SFNamedSearchCriteria").where("rule_type = 'SRCH_OBJECT' AND named_search = '"+key+"'")
            .execute().done(function(resp){
            	//debugger;
            	if (resp && resp.length) {
                    me._onGetPFCSuccess(responder, resp, result);
            	}else {
            		me._onGetPFCError(responder, resp, result);
            		
            	}
            	a.resolve();
             });
        	
        	return a;
		},

		getAdvFilterCriteria : function(responder, key, result){
		    var b = SVMX.Deferred();
		    var me = this;
			/*execQuery({
				query: "SELECT * FROM SFNamedSearchCriteria WHERE named_search = '{{key}}' AND rule_type = 'SRCH_CRITERIA'",
				queryParams: {key : key},
				context: this,
				state : {responder : responder, key : key, result : result, d:d},
				onSuccess : "_onGetAFCSuccess",
				onError: "_onGetAFCError"
			});*/
		    
		    var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            qo.select("*").from("SFNamedSearchCriteria").where("rule_type = 'SRCH_CRITERIA' AND named_search = '"+key+"'")
            .execute().done(function(resp){
            	//debugger;
            	if (resp && resp.length) {
                    me._onGetAFCSuccess(responder, resp, result);
            	} else {
            		//me._onGetAFCError(responder, resp, result);
            	}
            	b.resolve();
             });
		    
			return b;
		},

		_onGetAFCSuccess : function(responder, resp, result){
			var me = this;
			me.afc  = resp;
			var advFilters = [], afc = me.afc, l = afc.length, found = false;

			//Start => check if there are duplciate entries of the filters
			for(var i = 0; i < l; i++){
				if(advFilters.length > 0){
					for(var k =0; k < advFilters.length; k++){
						if(advFilters[k].key == this.afc[i].id)
					 	found = true;
					}
				}

				if(!found)
					advFilters.push({
					    allowOverride : afc[i].allow_override,
					    defaultOn : afc[i].default_on,
                        //Ensure TODAY, TOMORROW, YESTERDAY, NOW are handled correctly.
					    filterCriteria : me.sqlFixCriteria(afc[i].parent_object_criteria),
					    filterCriteriaFields : [],
						filterName : afc[i].name,
						filterObject : afc[i].source_object_name,
						key : afc[i].id,
						lookupField : afc[i].field_name
					});

					found = false;
			}
			//End => check if there are duplciate entries of the filters

			this.afc = advFilters;
		},

		_onGetPFCSuccess : function(responder, resp, result){
			var me = this;
			//Ensure TODAY, TOMORROW, YESTERDAY, NOW are handled correctly.
			me.pfc = me.sqlFixCriteria(resp[0].parent_object_criteria);
	    },

        _onGetLookupDefError: function(state, evt) {
            //logger.info("Could not fetch lookupdef, NamedSearch table might be empty");
            this.afc = [];
            state.d.resolve();
        },

        getLUPSearchResults: function(responder, result, lookupRequest, fields, key, numOfRecords) {
            //var req = nativeService.createSQLRequest(),
            var me = this;  
        	var  keyword = lookupRequest.keyword,
                lookupDef = lookupRequest.lookupDef,
                displayCols = [],
                relatedDisplayCols = [],
                searchCols = [],
                joinCols = [];
            var operator = lookupRequest.Operator;
            this.referenceFields = {};
            var utils = com.servicemax.client.installigence.offline.model.utils.Util;
            //Will be used to replace RecordType.Name in the WHERE clause later
            var recordTypeTableAlias = null;

            //Get all the search fields
            var displayFields = lookupDef.lookupDefDetail.displayFields,
                i, l = displayFields.length;
            for (i = 0; i < l; i++) {
                var fieldDef = this.fieldDefs[displayFields[i].field_name];
                if (fieldDef.type == "reference") {
                    //Ugly hack, to handle RecordType.Name in the WHERE clause
                    var relatedTable = SVMX.array.get(fieldDef.referenceTo, function(tableName) {
                        return utils.isTableInDatabase(tableName);
                    });
                    if (!recordTypeTableAlias && relatedTable && relatedTable == 'RecordType') {
                        //Save the alias so we can try and replace later. We only care about the first
                        recordTypeTableAlias = "tbl" + i;
                    }

                    this._addReferenceToQuery({
                        fieldDef: fieldDef,
                        joinCols: joinCols,
                        displayCols: displayCols,
                        relatedDisplayCols: relatedDisplayCols,
                        searchCols: null,
                        alias: "tbl" + i
                    });

                } else {
                    displayCols.push("MAIN." + displayFields[i].field_name);
                }
            }

            var searchFields = lookupDef.lookupDefDetail.searchFields,
                i, l = searchFields.length;
            for (i = 0; i < l; i++) {
                var fieldDef = this.fieldDefs[searchFields[i].field_name];
                if (fieldDef.type == "reference") {
                    //Ugly hack, to handle RecordType.Name in the WHERE clause
                    var relatedTable = SVMX.array.get(fieldDef.referenceTo, function(tableName) {
                        return utils.isTableInDatabase(tableName);
                    });
                    if (!recordTypeTableAlias && relatedTable && relatedTable == 'RecordType') {
                        //Save the alias so we can try and replace later. We only care about the first
                        recordTypeTableAlias = "tblsearch" + i;
                    }

                    this._addReferenceToQuery({
                        fieldDef: fieldDef,
                        joinCols: joinCols,
                        displayCols: null,
                        relatedDisplayCols: null,
                        searchCols: searchCols,
                        alias: "tblsearch" + i
                    });
                } else {
                    searchCols.push("MAIN." + searchFields[i].field_name + " qry");
                }
            }

            //req.bind("REQUEST_COMPLETED", SVMX.proxy(this, "_getLUPSearchResultsSuccess", responder, result, lookupRequest, fields));
            //req.bind("REQUEST_ERROR", SVMX.proxy(this, "_getLUPSearchResultsError", responder, result, lookupRequest, fields));

            var queryWithContext = 1;
            //respect context if present
            if(lookupRequest.ContextMatchField !== undefined && lookupRequest.ContextValue !== undefined){
            	queryWithContext = this.stitchLUPContextToQuery(lookupRequest, responder);
            }

			//stitch the query with advfilter criteria
            var queryWithAFC = this.stitchAdvFiltersToQuery(lookupDef, responder, key), advCriteria= '';

			if(queryWithAFC.advFilters.length > 0){
                //TODO IMP : Adding Product2 as the table name for testing purpose...need to get this info dynamically
                // NOTE: Order by Id insures that all _local_ ids come after synchronized Ids
                joinCols.push(SVMX.string.substitute(
	                "LEFT JOIN '{{advFilterObj}}' ON '{{advFilterObj}}'.'{{lupField}}' = MAIN.Id",
	                {
                       object_name: result.data[0].object_name,
                       advFilterObj : queryWithAFC.advFilters[0].filterObject,
                       lupField : queryWithAFC.advFilters[0].lookupField,
                       keyword: keyword,
                       display_fields: displayFields
                    }
                ));

                advCriteria = queryWithAFC.advFilters[0].filterCriteria;
            }

            //Hack to replace RecordType in RecordType.Name with an alias
            if (recordTypeTableAlias) {
                //Take care of the prefilter
                if (lookupDef.lookupDefDetail.preFilterCriteria) {
                    lookupDef.lookupDefDetail.preFilterCriteria = lookupDef.lookupDefDetail.preFilterCriteria.replace('RecordType.Name', recordTypeTableAlias + '.Name');
                }
                //Take care of all the advanced criteria
                if (advCriteria) {
                    advCriteria = advCriteria.replace('RecordType.Name', recordTypeTableAlias + '.Name');
                }
            }


            var initialQuery = SVMX.string.substitute(
                "SELECT DISTINCT MAIN.* FROM `{{object_name}}` AS MAIN " + joinCols.join("\n") + " WHERE (temp)",
                {
                   object_name: this.objectName
                }
            );

            var query = this.buildQuery(initialQuery, operator, displayCols, relatedDisplayCols, searchCols, keyword, lookupDef, responder, key, this.objectName, advCriteria, queryWithContext);

            // Bubble info
            if (this.recordId) {
                query += " AND MAIN.Id='" + this.recordId + "'";
            } else {
                query +=  " LIMIT " + numOfRecords;
            }

            /*req.execute({
                query: query
            });*/
            
            
           /* me.__findLocalRecords(query)
            .done(function(){
                me.__findRemoteRecords(query,this.includeMFLRecords)
                .done(function(remoteRecords){
                    var records = me.__mergeRecords(localRecords, remoteRecords);
                    if (localRecords && localRecords.length) {
                    	me._getLUPSearchResultsSuccess(responder, localRecords, lookupRequest, fields, resp);
                    } else {
                    	me._getLUPSearchResultsError(responder, localRecords, lookupRequest, fields, resp);
                    }
                //});
            });*/
            
            var qo = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            
            qo.query(query).execute()
            .done(function(localRecords){
            	me.__findRemoteRecords(query,me.includeMFLRecords)
            	.done(function(remoteRecords){
            		me.__findServerRecords(me.onlineQuery,me.includeOnlineRecords)
            		.done(function(serverRecords){
            			var records = me.__mergeRecords(localRecords, remoteRecords, serverRecords);
            			if (records && records.length) {
            				me._getLUPSearchResultsSuccess(responder, result, lookupRequest, fields, records);
            			} else {
            				me._getLUPSearchResultsError(responder, result, lookupRequest, fields, records);
            			}
            		});
            	});
        	});
        },
        
        __mergeRecords : function(records1, records2, records3){
            if(records2.length || records3.length){
                var recordIds = [];
                for(var i = 0; i < records1.length; i++){
                    recordIds.push(records1[i].Id);
                }
                for(var i = 0; i < records2.length; i++){
                    if(recordIds.indexOf(records2[i].Id) === -1){
                        records1.push(records2[i]);
                        recordIds.push(records2[i].Id);
                    }
                }                
                for(var i = 0; i < records3.length; i++){
                    if(recordIds.indexOf(records3[i].Id) === -1){
                        records1.push(records3[i]);
                    }
                }
            }
            return this.__sort(records1, "Name");
        },
        
        __findLocalRecords : function(query){
            var d = SVMX.Deferred();
            
            var queryObj = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            queryObj.query(query).execute().done(function(resp){
                d.resolve(resp);
                return d;
            });
            
        },
        
        
        __findRemoteRecords : function(query,includeRemote){
            var me = this;
            var d = SVMX.Deferred();
            if(!includeRemote){
                // Record name queries are local only
                d.resolve([]);
               // return d;
            }
            else{
            	SVMX.getClient().getServiceRegistry()
                .getService("com.servicemax.client.installigence.sync").getInstance()
                .getUserInfo()
                .done(function(userInfo){
                	var params = {
                        type : "DATAACCESSAPI",
                        method : "SELECT",
                        objectName: me.objectName,
                        userName : userInfo.UserName,
                        query : query
                    };

                    var req = com.servicemax.client.installigence.offline.sal.model.nativeservice.Facade.createDataAccessAPIRequest();
                    req.bind("REQUEST_COMPLETED", function(evt){
                        var records = me.__parseResults(evt.data.data);
                        var isValid = evt.data.data.indexOf('Response Code : 0') === -1;
                        d.resolve(records, isValid);
                    }, me);
                    req.bind("REQUEST_ERROR", function(evt){
                        d.resolve([]);  
                    }, me);
                    req.execute(params);
                });
            }
            return d;
        },
        
        __findServerRecords : function(query,includeOnlineRecords){
        	var d = SVMX.Deferred();
        	if(!includeOnlineRecords){
        		d.resolve([]);
        		return d;
            } else {
            	var getRecords = SVMX.create("com.servicemax.client.installigence.offline.model.utils.GetRecords", {});
            	getRecords.FromServerWithPreBuildQuery(query).done(function(results){
            		d.resolve(results);
            	});
            }
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
        __sort : function(array, key){
        	return array.sort(function(a, b) {
        		if(a[key] < b[key]){
                    return -1;
                }else if(a[key] > b[key]){
                    return 1;
                }
                return 0;
            });
        },        
        
        __parseResults: function(data) {
            data = SVMX.toObject(data);
            var i, ilength = data.length, obj = {};
            for(i = 0; i < ilength; i++) {
                obj[data[i].split(" : ")[0]] = data[i].split(" : ")[1];
            }
            var output = [];
            if(obj["Response Code"] === "1" && obj.Output.length > 0) {
                output = this.__parseOutput(obj.Output);
            }
            return output;
        },
        
        __parseOutput: function(data) {
            if(data && data[0] === "[" && data[data.length-1] !== "]"){
                // Fix incomplete JSON output
                data += "\"]]";
            }
            data = SVMX.toObject(data);
            var i, ilength = data.length, output = [];
            for(i = 0; i < ilength; i++) {
                var j = 0; jlength = data[i].length, obj = {};
                var currData = data[i];
                for(j = 0; j < jlength; j++){
                    obj[currData[j].split(":")[0]] = currData[j].split(":")[1];
                }
                output.push(obj);
            }
            return output;
        },
        
        _getNameField : function(tableName) {
            var result;
            if (tableName == "Case") {
                result = "CaseNumber";
            } else if (tableName == "Event") {
                result = "Subject";
            } else {
                result = "Name";
            }
            return result;
            
         },
         
        _addReferenceToQuery : function(inParams) {
        	var utils = com.servicemax.client.installigence.offline.model.utils.Util;
            var relatedTable = SVMX.array.get(inParams.fieldDef.referenceTo, function(tableName) {
                return utils.isTableInDatabase(tableName);
            });
            if (!relatedTable) return;
            var nameField = this._getNameField(relatedTable);
            if (!nameField) return;
            this.referenceFields[inParams.fieldDef.name] = relatedTable;
            inParams.joinCols.push(SVMX.string.substitute(
                "LEFT JOIN `{{related_table_name}}` as {{alias}} ON {{alias}}.Id = MAIN.{{source_field_name}}",
				{
                    table_name: this.objectName,
                    alias: inParams.alias,
                    source_field_name: inParams.fieldDef.name,
                    related_table_name: relatedTable
				}
			));
			if (inParams.displayCols) {
                inParams.displayCols.push("MAIN." + inParams.fieldDef.name);
            }
            if (inParams.searchCols) {
               inParams.searchCols.push(SVMX.string.substitute(
                    "`{{related_table_name}}`.{{field_name}} qry",
                    {related_table_name: inParams.alias, field_name: nameField}
                ));
            }
            if (inParams.relatedDisplayCols) {
                inParams.relatedDisplayCols.push(inParams.alias + "." + nameField + " as " + inParams.fieldDef.name.replace(/(__c)?$/, "__r"));
            }
        },

		_onGetPFCError : function(responder, resp, result){
			//logger.info("Could not fetch lookupdef, NamedSearch table might be empty");
			this.pfc = [];
			//d.resolve();
		},

        buildQuery : function(initialQuery, operator, displayCols, relatedDisplayCols, searchCols, keyword, lookupDef, responder, key, objName, advCriteria, queryWithContext) {
            //replace * with displayfields
            var whereQry = "";
            var query = initialQuery;
            var allDisplayCols = displayCols.concat(relatedDisplayCols);

            // Lookup queries need ALL fields so formfield mappings can be executed
            if (this.callType == "BUBBLE") {
                query = initialQuery.replace("MAIN\.*", allDisplayCols.join());
            } else if (relatedDisplayCols.length) {
                query = initialQuery.replace("*", "*, " + relatedDisplayCols.join(","));
            }

            //replace temp with searchfields
            whereQry = searchCols.join(" OR ");
            if (whereQry) whereQry = "(" + whereQry + ")";

            //stitch the query with prefilter criteria
            var queryWithPFC = this.stitchPreFilterCriteriaToQuery(lookupDef, responder, key), afc;
            if(queryWithPFC == "" || queryWithPFC == undefined){
            	queryWithPFC = 1;
            }

            var finalQuery = queryWithContext + " AND " + queryWithPFC;
            if(advCriteria !== null && advCriteria != undefined && advCriteria != ""){
            	finalQuery = finalQuery + " AND " + advCriteria;
            }

            //TODO Imp : Check what happens when keyword is not present
            if (keyword !== "") {
                switch (operator) {
                case "contains":
                    var a = " LIKE '%" + keyword + "%'";
                    var b = finalQuery + " AND " + whereQry.split(' qry').join(a);
                    var formattedQuery = query.replace("temp", b);
                    return formattedQuery;
                case "ew":
                    var a = " LIKE '%" + keyword + "'";
                    var b = finalQuery + " AND " + whereQry.split(' qry').join(a);
                    var formattedQuery = query.replace("temp", b);
                    return formattedQuery;
                case "sw":
                    var a = " LIKE '" + keyword + "%'";
                    var b = finalQuery + " AND " + whereQry.split(' qry').join(a);
                    var formattedQuery = query.replace("temp", b);
                    return formattedQuery;
                case "eq":
                    var a = " = '" + keyword + "'";
                    var b = finalQuery + " AND " + whereQry.split(' qry').join(a);
                    var formattedQuery = query.replace("temp", b);
                    return formattedQuery;
                    //TODO : implement default
                }
            } else {
                return query.replace("temp", finalQuery);
            }
        },

        stitchPreFilterCriteriaToQuery : function(lookupDef, responder, key){
        	//Replace literals with value
        	var pfc = "";

        	if(responder.__parent !== undefined || responder.__parent != null){
            	var pfc = lookupDef.lookupDefDetail.preFilterCriteria, refMetaModel = responder.__parent.getReferenceMetaModel();;
            	pfc = OpUtils.replaceLiteralsWithValue(pfc, refMetaModel, key);
            	//if it has boolean values, convert it to string
            	pfc = OpUtils.replaceBoolToString(pfc);
        	}
			return pfc;
        },

        stitchLUPContextToQuery : function(lookupRequest, responder){
        	var contextCriteria = 1;
        	if(responder.__parent !== undefined || responder.__parent != null){
            	contextCriteria = lookupRequest.ContextMatchField + " LIKE " +  "'" +lookupRequest.ContextValue + "'";
        	}
        	return contextCriteria;
        },

        stitchAdvFiltersToQuery : function(lookupDef, responder, key){
        	//Replace literals with value
        	if(responder.__parent !== undefined || responder.__parent != null){
            	var lookupDefRequest = SVMX.cloneObject(lookupDef), refMetaModel = responder.__parent.getReferenceMetaModel();;
            	var afc = OpUtils.extractDefWithFiltersToQuery(this.request, lookupDefRequest);
            	for(var i = 0; i < afc.advFilters.length; i++){
            		afc.advFilters[i].filterCriteria = OpUtils.replaceLiteralsWithValue(afc.advFilters[0].filterCriteria, refMetaModel, key);
            	}
        	}else{
        		var afc = {advFilters : []};
        	}

			return afc;
        },

        /*
         * 1) converts the LUP Search results datetime to include timezone offsets
         * 2) creates display records
         * 3) trigger completed method
         */
        _processLUPSearchResults: function(userInfo, responder, result, lookupRequest, fields) {
            var offset = userInfo.TimezoneOffset;
            var me = this;
			// Turn all those reference fields into something clearer
			// Though online doesn't yet provide Value so it can't be used yet.
            /*SVMX.array.forEach(result.data, function(item) {
                var record = new RecordClass(result.data, lookupRequest.lookupDef.key);
                var dateTimeFields = record.getFieldsByType("datetime");
                var hashTable = {};

                SVMX.array.forEach(dateTimeFields, function(item, idx){
                    hashTable[item.name] = true;
                });

                SVMX.forEachProperty(item, SVMX.proxy(this, function(inFieldName, inValue) {
                    //convert datetime
                    if (hashTable[inFieldName]) {
                        item[inFieldName] = ((inValue) ? OfflineDataUtils.convertToTimezone(inValue, offset, false):inValue);
                    }

                    if (inFieldName.match(/__r$/)) {
                        var keyName = inFieldName.replace(/__r$/,"__c");
                        if (!(keyName in this.referenceFields)) {
                            keyName = keyName.replace(/__c$/,"");
                        }
                        var value = {
                            "attributes": {
                                "type": this.referenceFields[keyName],
                                "url": "TODO"
                            },
                            "Name": inValue,
                            "Value": item[keyName]
                        };
                        var field = SVMX.array.get(fields, function(f) { return f[SVMX.OrgNamespace + "__Field_Name__c"] == keyName;});

                        item[field.relationshipName] = value;
                    }
                }));
            }, this);*/

            this.response.data = me.__createDisplayRecords(result.data, fields);
            this.response.advFilters = lookupRequest.lookupDef.advFilters;

            this._onSearchCompleted(responder, this.response);
        },

        /*
         * 1) gets the data from the event object,
         * 2) preprocess non"Bubble" call types
         * 3) fetch user data
         * 3a) success: process the results
         * 3b) fail: log error
         */
        _getLUPSearchResultsSuccess: function(responder, result, lookupRequest, fields, resp) {
            result.data = resp;
            if (this.callType != "BUBBLE") {
                SVMX.array.forEach(result.data, function(item) {
                    item.svmx_disabled = Boolean(item.Id && item.Id.match(/_local_/));
                });
            }

            //get the user info first, then process
            var service = SVMX.create("com.servicemax.client.installigence.sync.service.impl.Service", {});
            var userInfo = service.getUserInfo();
            this._processLUPSearchResults(userInfo, responder, result, lookupRequest, fields);
        },

        _getLUPSearchResultsError: function(responder, result, lookupRequest, fields, resp) {
            //logger.error("ERROR IN _getLUPSearchResultsError: " + evt.data.data);
            this._getLUPSearchResultsSuccess(responder, result, lookupRequest, fields, []);
        },

        _onSearchCompleted: function(responder, result) {
        	//debugger;
        	responder.__waitCounter.count--;
            if (responder.__waitCounter.count === 0 && responder.__waitCounter.subRecordsStarted) {
                //logger.info("Lookup results retrieved");
                responder.result(result);
            }
        },

        __createDisplayRecords: function(records, fieldsInfo) {
            var ret = [];
            if (records) {
                var i, l = records.length,
                    rec, key, record, value, fieldInfo, rkey;
                for (i = 0; i < l; i++) {
                	record = records[i];
                    var obj = {};
                    for (key in record) {
                        if (key == "attributes") continue;

                        value = record[key];
                        
                        if (fieldsInfo) {
                            fieldInfo = this.__getFieldInfo(fieldsInfo, key);
                            if(fieldInfo){
                            	if(fieldInfo.dataType == "REFERENCE"){
                            		rkey = fieldInfo.relationshipName;
                            		if (record[rkey]) {
                                       obj[key] = record[rkey].Name;
                                    } else {
                                        obj[key] = "";
                                    }
                            	}
                            	else{
                            		obj[key] = value;
                            	}
                            }
                        }
                    }
                    ret.push(obj);
                }
            }
            return ret;
        },

        __getFieldInfo: function(fieldsInfo, fieldName) {
            var i, l = fieldsInfo.length,
                ret = null;
            for (i = 0; i < l; i++) {
                if (fieldsInfo[i][SVMX.OrgNamespace + "__Field_Name__c"] == fieldName) {
                    ret = fieldsInfo[i];
                    break;
                }
            }
            return ret;
        },

        /**
         * Substitute date functions within a string to match SQLite.
         * TODAY becomes CURRENT_DATE
         * TOMORROW becomes date('now', '+1 day')
         * YESTERDAY becomes date('now', '11 day')
         * NOW becomes CURRENT_TIMESTAMP
         *
         * @param inString (String) the string to add substitutions to
         * @return (sting) the new substituted value
         */
        sqlFixCriteria : function (inString) {
        	var DatetimeUtils = com.servicemax.client.lib.datetimeutils.DatetimeUtil;
        	var criteria = "",
                re_castFields = /\b([\w]+)(?=\s?(?:<>|>|>=|<|<=|=)\s?\d)/gi;

            //Generate our new string
            criteria = String(inString).replace(/["']?\b(TODAY|TOMORROW|YESTERDAY|NOW)\b["']?/g, function (inTerm) {
                var output = inTerm;
                switch(inTerm) {
                    case "TODAY":
                        output = "'" + DatetimeUtils.macroDrivenDatetime('Today', "YYYY-MM-DD").split(" ")[0] + "'";
                        break;
                    case "TOMORROW":
                        output = "'" + DatetimeUtils.macroDrivenDatetime('Tomorrow', "YYYY-MM-DD").split(" ")[0] + "'";
                        break;
                    case "YESTERDAY":
                        output = "'" + DatetimeUtils.macroDrivenDatetime('Yesterday', "YYYY-MM-DD").split(" ")[0] + "'";
                        break;
                    case "NOW":
                        output = "'" + DatetimeUtils.macroDrivenDatetime('Now', "YYYY-MM-DD", "hh:mm:ss") + "'";
                        break;
                }

                return output;
            });

            //Defect: 012062
            //Cast fields as numbers (doubles) so that SQL comparisons will work correctly
            criteria = criteria.replace( re_castFields, 'cast($1 as double)' );

            //Defect: 010758
            //While we are fixing the criteria, also add brackets.
            // x = y AND a = b OR c = d IS not the same as  x = y AND (a = b OR c = d)
            return (criteria) ? '(' + criteria + ')' : criteria;
        }

    }, {});
    
    
};
})();

// end of file