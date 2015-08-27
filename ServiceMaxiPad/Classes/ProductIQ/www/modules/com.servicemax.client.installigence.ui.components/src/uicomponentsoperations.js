(function(){
    var uicomponentsoperations = SVMX.Package("com.servicemax.client.installigence.ui.components.operations");

uicomponentsoperations.init = function(){
	
	var Module = com.servicemax.client.installigence.ui.components.impl.Module;	
	uicomponentsoperations.Class("GetLookupData", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },
        
        performAsync: function(request, responder){
        	var requestData = {};
        	var searchFields = request.searchFields;
        	var displayFields = request.displayFields;
        	var fldDiscInfo = this.__getProductFieldsMap(request.productDesc.fields);
        	var flds = searchFields.concat(displayFields);
        	var iDesc = 0, iDescLen = flds.length;
        	var refFields = {}; var isRefExists = false;
        	for(iDesc = 0; iDesc < iDescLen; iDesc++){
        		if(fldDiscInfo[flds[iDesc]] && fldDiscInfo[flds[iDesc]].type == "REFERENCE"){
        			refFields[fldDiscInfo[flds[iDesc]].referenceTo] = fldDiscInfo[flds[iDesc]];
        			//refFields[flds[iDesc]] = fldDiscInfo[flds[iDesc]];
        			isRefExists = true;
        		}        		
        	}
        	var req = request;
            var module = Module.instance;
            if(isRefExists === true){
            	var iLength = 0;
            	var refDesc = {};
            	Module.instance.createServiceRequest({handler : function(sRequest){
            		var refDesc = {};
    				sRequest.bind("REQUEST_COMPLETED", function(evt){
    					
    					if(module.checkResponseStatus("GetLookupData", evt.data, false, this) == true){
    						var data = evt.data;
    						refDesc[data.name] = data;
    					}

						iLength--;
    					if(iLength == 0) this.__queryData(request, responder, refDesc);
    				}, this);
    				
    				sRequest.bind("REQUEST_ERROR", function(evt){

    					if(module.checkResponseStatus("GetLookupData", evt.data, false, this) == true){
    						
    					}
    					iLength--;
    					if(iLength == 0) this.__queryData(request, responder, refDesc);
    				}, this);
    				
    				for(var key in refFields){
    					iLength++;
    					sRequest.callApiAsync({url : "sobjects/" + key + "/describe"});
    				}
    				
    			}, context : this}, this); 
            }else {
            	this.__queryData(request, responder);
        	}
              
        },

        __queryData: function(request, responder, refDesc){

            var requestData = {

            };
            var module = Module.instance;
            Module.instance.createServiceRequest({handler : function(sRequest){
            	var fldsInfo = {};
				sRequest.bind("REQUEST_COMPLETED", function(evt){

					if(module.checkResponseStatus("GetLookupData", evt.data, false, this) == true){
						var recs = evt.data.records;
						var i = 0, l = recs.length;
						if(request.aliasInfo){
							for(i = 0; i < l; i++){
								for(var key in request.aliasInfo){
									var flds = key.split(".");
									recs[i][request.aliasInfo[key]] = recs[i][flds[0]][flds[1]];
								}
							}
						}						
						responder.result(recs);
					}
				}, this);
				
				sRequest.bind("REQUEST_ERROR", function(evt){

					if(module.checkResponseStatus("GetLookupData", evt.data, false, this) == true){
						responder.result([]);//([{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003sbIbIAI"},"Id":"01tF0000003sbIbIAI","Name":"prodPR1"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003sZoWIAU"},"Id":"01tF0000003sZoWIAU","Name":"Laptop"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003sbI7IAI"},"Id":"01tF0000003sbI7IAI","Name":"prodPR1"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003sbIWIAY"},"Id":"01tF0000003sbIWIAY","Name":"prodPR1"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003sbIRIAY"},"Id":"01tF0000003sbIRIAY","Name":"prodPR1"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003t6XtIAI"},"Id":"01tF0000003t6XtIAI","Name":"Test's Prod"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003tABvIAM"},"Id":"01tF0000003tABvIAM","Name":"Charger"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003sbICIAY"},"Id":"01tF0000003sbICIAY","Name":"prodPR1"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003t1igIAA"},"Id":"01tF0000003t1igIAA","Name":"SmartPhone"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003sREKIA2"},"Id":"01tF0000003sREKIA2","Name":"saProd1"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003tAC0IAM"},"Id":"01tF0000003tAC0IAM","Name":"Battery"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003tABlIAM"},"Id":"01tF0000003tABlIAM","Name":"Laptopset"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003t3NmIAI"},"Id":"01tF0000003t3NmIAI","Name":"OptiPlex 320"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003sdRMIAY"},"Id":"01tF0000003sdRMIAY","Name":"newProductforINVT"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003sSJwIAM"},"Id":"01tF0000003sSJwIAM","Name":"INVT_Product"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003tABqIAM"},"Id":"01tF0000003tABqIAM","Name":"Laptop"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003Ono6IAC"},"Id":"01tF0000003Ono6IAC","Name":"GenWatt Diesel 200kW"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003Ono7IAC"},"Id":"01tF0000003Ono7IAC","Name":"Coffee beans"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003Ono8IAC"},"Id":"01tF0000003Ono8IAC","Name":"Installation: Industrial - High"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003Ono9IAC"},"Id":"01tF0000003Ono9IAC","Name":"SLA: Silver"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoAIAS"},"Id":"01tF0000003OnoAIAS","Name":"GenWatt Propane 500kW"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoBIAS"},"Id":"01tF0000003OnoBIAS","Name":"SLA: Platinum"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoCIAS"},"Id":"01tF0000003OnoCIAS","Name":"GenWatt Propane 100kW"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoDIAS"},"Id":"01tF0000003OnoDIAS","Name":"GenWatt Propane 1500kW"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoEIAS"},"Id":"01tF0000003OnoEIAS","Name":"Coffee machine Filter"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoFIAS"},"Id":"01tF0000003OnoFIAS","Name":"SLA: Bronze"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoGIAS"},"Id":"01tF0000003OnoGIAS","Name":"GenWatt Gasoline 750kW"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoHIAS"},"Id":"01tF0000003OnoHIAS","Name":"Installation: Portable"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoIIAS"},"Id":"01tF0000003OnoIIAS","Name":"SLA: Gold"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoJIAS"},"Id":"01tF0000003OnoJIAS","Name":"GenWatt Gasoline 300kW"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoKIAS"},"Id":"01tF0000003OnoKIAS","Name":"Installation: Industrial - Low"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoLIAS"},"Id":"01tF0000003OnoLIAS","Name":"GenWatt Gasoline 2000kW"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoMIAS"},"Id":"01tF0000003OnoMIAS","Name":"Installation: Industrial - Medium"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003sW2RIAU"},"Id":"01tF0000003sW2RIAU","Name":"InvSerial"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003sW2WIAU"},"Id":"01tF0000003sW2WIAU","Name":"InvNonSerial"}]);
					}
				}, this);
				
				var filters = "";
				var prodDiscInfo = this.__getProductFieldsMap(request.productDesc.fields);
	        	
				if(request.filter){
	            	if(request.searchFields && request.searchFields.length > 0){
	            		var searchFields = this.__getQuerybleFields(request.searchFields, refDesc, prodDiscInfo);
	                	var iSearch, iLength = searchFields.finalFields.length;	                	
	                	for(iSearch = 0; iSearch < iLength; iSearch++){
	                		var fld = searchFields.finalFields[iSearch];	                		              		
	                		if(iSearch == 0)
	                			filters = " where ";
	                		else
	                			filters += " or ";
	                		filters += fld + " like '%" + request.filter + "%'";	                		
	                	}
	                }else {
	                	filters = " where Name like '%" + request.filter + "%'";
	                }
	            }
				fldsInfo = this.__getQuerybleFields(request.displayFields, refDesc, prodDiscInfo);
				request.aliasInfo = fldsInfo.aliasInfo;
				displayFlds = this.__getCommaSeparated(fldsInfo.finalFields);
				var query = encodeURI("select " + displayFlds + " from Product2");
				if(request.filter !== undefined && request.filter.length > 0) {
					query = encodeURI("select " + displayFlds + " from Product2" + filters);
				}
				sRequest.callApiAsync({url : "query?q=" + query});
			}, context : this}, this);            
        },
        
        __getQuerybleFields: function(fields, fldDiscInfo, prodDiscInfo){
        	var i = 0, l = fields.length;
        	var finalFlds = [];
        	var aliasFlds = {};
        	for(i = 0; i < l; i++){
        		var fld = fields[i];
        		var proFld = prodDiscInfo[fld];
        		if(proFld.type == "REFERENCE" && fldDiscInfo){
        			var objName = proFld.referenceTo;
        			var objInfo = fldDiscInfo[objName];
        			if(objInfo){
        				var nameField = this.__getNameField(objInfo.fields);
        				aliasFlds[proFld.relationshipName + "." + nameField] = fld; 
        				fld = proFld.relationshipName + "." + nameField;        				
        			}        				
        		}
        		finalFlds.push(fld);
        	}
        	return {"finalFields" : finalFlds, "aliasInfo" : aliasFlds};
        },
        
        __getNameField: function(fields){
        	var i = 0, l = fields.length;
        	for(i = 0; i < l; i++){
        		if(fields[i].nameField == true){
        			return fields[i].name;
        		}
        	}
        	return "";
        },
        
        __getCommaSeparated: function(fields){
        	var ifields = 0, lfields = fields.length, queryFlds = "";
        	for(ifields = 0; ifields < lfields; ifields++){
        		if(ifields == 0) queryFlds = fields[ifields];
        		else queryFlds += ', ' + fields[ifields];
        	}
        	return queryFlds;
        },
        
        __getProductFieldsMap: function(fields){
        	var fields = fields;
        	var fieldsMap = {};
        	if(fields){
        		var i = 0, l = fields.length;
        		for(i = 0; i < l; i++){
        			fieldsMap[fields[i].fieldAPIName] = fields[i];
        		}
        	}
        	return fieldsMap;
        }

    }, {});

};
})();

// end of file
