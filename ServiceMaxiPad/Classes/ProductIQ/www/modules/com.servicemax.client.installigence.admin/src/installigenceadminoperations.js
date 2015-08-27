(function(){
    var installigenceadminoperations = SVMX.Package("com.servicemax.client.installigence.admin.operations");

installigenceadminoperations.init = function(){

	var Module = com.servicemax.client.installigence.ui.components.impl.Module;	
	installigenceadminoperations.Class("GetSetupMetadata", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },

        performAsync: function(request, responder){

            var requestData = {

            };
            
            /*result = {"status":true,"message":"","translations":[{"Text":"--None--","Key":"NONE"},{"Text":"Field Update","Key":"FIELD_UPDATE"},{"Text":"User Actions & Filters","Key":"USERACTIONS_FILTERS"},{"Text":"External App","Key":"EXTERNAL_APP"},{"Text":"Filters","Key":"FILTERS"},{"Text":"User Actions","Key":"USERACTIONS"},{"Text":"IB Templates","Key":"TEMPLATES"},{"Text":"Other Settings","Key":"OTHERSETTINGS"},{"Text":"Name","Key":"UAF_GRID_COL_NAME"},{"Text":"Type","Key":"UAF_GRID_COL_TYPE"},{"Text":"Action","Key":"UAF_GRID_COL_ACTION"},{"Text":"Is Global","Key":"UAF_GRID_COL_ISGLOBAL"},{"Text":"Select a profile","Key":"SELECT_PROFILE"},{"Text":"ProductIQ Setup","Key":"SETUP_TITLE"},{"Text":"Template Name","Key":"TEMPLATE_NAME"},{"Text":"Template id","Key":"TEMPLATE_ID"},{"Text":"IB Display Text","Key":"IB_DISPLAY_TEXT"},{"Text":"Location Display Text","Key":"LOCATION_DISPLAY_TEXT"},{"Text":"Sub-Location Display Text","Key":"SUB_LOCATION_DISPLAY_TEXT"},{"Text":"Product","Key":"PRODUCT"},{"Text":"Icon","Key":"ICON"},{"Text":"Default values","Key":"DEFAULT_VALUES"},{"Text":"Value map for old IB","Key":"VALUE_MAP_OLD_IB"},{"Text":"Value map for new IB","Key":"VALUE_MAP_NEW_IB"},{"Text":"Select a template","Key":"SELECT_TEMPLATE"},{"Text":"Product Swap","Key":"PRODUCT_SWAP"},{"Text":"Product Configuration","Key":"PRODUCT_CONFIGURATION"},{"Text":"Selected Expression","Key":"SELECTED_EXPR"},{"Text":"Add Condition","Key":"ADD_CONDITION"},{"Text":"Add Group","Key":"ADD_GROUP"},{"Text":"Change Group","Key":"CHANGE_GROUP"},{"Text":"Delete Group","Key":"DELETE_GROUP"},{"Text":"And","Key":"AND"},{"Text":"Or","Key":"OR"},{"Text":"Not And","Key":"NOT_AND"},{"Text":"Not Or","Key":"NOT_OR"},{"Text":"Search","Key":"SEARCH_EMPTY_TEXT"},{"Text":"Add Product","Key":"ADD_PRODUCT"},{"Text":"enter a value","Key":"ENTER_VALUE"},{"Text":"Automatically copy configuration while swapping products","Key":"OTHER_SET_SWAP_TEXT"},{"Text":"Starts With","Key":"STARTS_WITH"},{"Text":"Not Equal","Key":"NOT_EQUAL"},{"Text":"Less or Equal To","Key":"LESS_OR_EQUAL"},{"Text":"Less Than","Key":"LESS_THAN"},{"Text":"Is Null","Key":"ISNULL"},{"Text":"Is Not Null","Key":"ISNOTNULL"},{"Text":"Includes","Key":"INCLUDES"},{"Text":"Greater or Equal To","Key":"GREATER_OR_EQUAL"},{"Text":"Greater Than","Key":"GREATER_THAN"},{"Text":"Excludes","Key":"EXCLUDES"},{"Text":"Equals","Key":"EQUALS"},{"Text":"Does Not Contain","Key":"DOES_NOT_CONTAIN"},{"Text":"Contains","Key":"CONTAINS"}],"svmxProfiles":[{"profileName":"Cloned Default for SP","profileId":"a10F0000002izWFIAY","mappings":null,"filters":[],"actions":[]},{"profileName":"Default Group Profile","profileId":"a10F0000002i2SvIAI","mappings":null,"filters":[{"parentProfileId":"a10F0000002i2SvIAI","name":"Test1","isGlobal":false,"expression":{"value":null,"operator":null,"field":null,"exprType":null,"condition":null,"children":[{"value":"","operator":"Test1","field":null,"exprType":"root","condition":null,"children":[{"value":"","operator":"And","field":null,"exprType":"operatorroot","condition":null,"children":[{"value":"Prod1","operator":"","field":"SVMXDEV__Product_Name__c","exprType":"expression","condition":"startswith","children":null},{"value":"","operator":"And","field":null,"exprType":"operator","condition":null,"children":[{"value":"ACC","operator":"","field":"SVMXDEV__Distributor_Contact__c","exprType":"expression","condition":"lessthan","children":null}]}]}]}]}}],"actions":[{"parentProfileId":"a10F0000002i2SvIAI","name":"Actoin1","isGlobal":false,"actionType":"Field Map","action":"KKG_Mapps_inst_to_inst_FM"}]},{"profileName":"NV Group Profile","profileId":"a10F0000002is1mIAA","mappings":null,"filters":[{"parentProfileId":"a10F0000002is1mIAA","name":"SYMMETRA Device","isGlobal":false,"expression":{"value":null,"operator":null,"field":null,"exprType":null,"condition":null,"children":[{"value":"","operator":"SYMMETRA Device","field":null,"exprType":"root","condition":null,"children":[{"value":"","operator":"And","field":null,"exprType":"operatorroot","condition":null,"children":[{"value":"SYMMETRA","operator":"","field":"SVMXDEV__Product_Name__c","exprType":"expression","condition":"equals","children":null}]}]}]}}],"actions":[{"parentProfileId":"a10F0000002is1mIAA","name":"Deinstall","isGlobal":false,"actionType":"fieldupdate","action":"Deinstall_PRIQ"},{"parentProfileId":"a10F0000002is1mIAA","name":"In Transit - Return","isGlobal":false,"actionType":"fieldupdate","action":"InTransit_PRIQ"},{"parentProfileId":"a10F0000002is1mIAA","name":"Installed","isGlobal":false,"actionType":"fieldupdate","action":"Installed_PRIQ"}]},{"profileName":"Santosh GP","profileId":"a10F0000003dHiYIAU","mappings":null,"filters":[],"actions":[{"parentProfileId":"a10F0000003dHiYIAU","name":"User Action~1","isGlobal":false,"actionType":"fieldupdate","action":"MAP043V"}]},{"profileName":"","profileId":"global","mappings":null,"filters":[],"actions":[]}],
            		"sforceObjectDescribes":[{"objectLabel":"Product","objectAPIName":"Product2","fields":[{"fieldLabel":"Enable Serialized Tracking of Stock","fieldAPIName":"SVMXC__Enable_Serialized_Tracking__c"},{"fieldLabel":"Product Code","fieldAPIName":"ProductCode"},{"fieldLabel":"Inherit Parent Warranty","fieldAPIName":"SVMXC__Inherit_Parent_Warranty__c"},{"fieldLabel":"Stockable","fieldAPIName":"SVMXC__Stockable__c"},{"fieldLabel":"Select","fieldAPIName":"SVMXC__Select__c"},{"fieldLabel":"Created Date","fieldAPIName":"CreatedDate"},{"fieldLabel":"Product Cost","fieldAPIName":"SVMXC__Product_Cost__c"},{"fieldLabel":"Tracking","fieldAPIName":"SVMXC__Tracking__c"},{"fieldLabel":"Replacement Available?","fieldAPIName":"SVMXC__Replacement_Available__c"},{"fieldLabel":"Created By ID","fieldAPIName":"CreatedById"},{"fieldLabel":"Last Modified Date","fieldAPIName":"LastModifiedDate"},{"fieldLabel":"Product ID","fieldAPIName":"Id"},{"fieldLabel":"Active","fieldAPIName":"IsActive"},{"fieldLabel":"Product Description","fieldAPIName":"Description"},{"fieldLabel":"Product Family","fieldAPIName":"Family"},{"fieldLabel":"Deleted","fieldAPIName":"IsDeleted"},{"fieldLabel":"Product Name","fieldAPIName":"Name"},{"fieldLabel":"Unit of Measure","fieldAPIName":"SVMXC__Unit_Of_Measure__c"},{"fieldLabel":"Product Line","fieldAPIName":"SVMXC__Product_Line__c"},{"fieldLabel":"System Modstamp","fieldAPIName":"SystemModstamp"},{"fieldLabel":"Last Modified By ID","fieldAPIName":"LastModifiedById"},{"fieldLabel":"Currency ISO Code","fieldAPIName":"CurrencyIsoCode"}]},{"objectLabel":"Installed Product","objectAPIName":"SVMXDEV__Installed_Product__c","fields":[{"fieldLabel":"Last Date Shipped","fieldAPIName":"SVMXDEV__Last_Date_Shipped__c"},{"fieldLabel":"Status","fieldAPIName":"SVMXDEV__Status__c"},{"fieldLabel":"Date Shipped","fieldAPIName":"SVMXDEV__Date_Shipped__c"},{"fieldLabel":"Asset Tag","fieldAPIName":"SVMXDEV__Asset_Tag__c"},{"fieldLabel":"Distributor Contact","fieldAPIName":"SVMXDEV__Distributor_Contact__c"},{"fieldLabel":"Created By ID","fieldAPIName":"CreatedById"},{"fieldLabel":"Last Activity Date","fieldAPIName":"LastActivityDate"},{"fieldLabel":"Service Contract Start Date","fieldAPIName":"SVMXDEV__Service_Contract_Start_Date__c"},{"fieldLabel":"Warranty","fieldAPIName":"SVMXDEV__Warranty__c"},{"fieldLabel":"Deleted","fieldAPIName":"IsDeleted"},{"fieldLabel":"Country","fieldAPIName":"SVMXDEV__Country__c"},{"fieldLabel":"System Modstamp","fieldAPIName":"SystemModstamp"},{"fieldLabel":"Parent","fieldAPIName":"SVMXDEV__Parent__c"},{"fieldLabel":"Product Name","fieldAPIName":"SVMXDEV__Product_Name__c"},{"fieldLabel":"Service Contract Line","fieldAPIName":"SVMXDEV__Service_Contract_Line__c"},{"fieldLabel":"Latitude","fieldAPIName":"SVMXDEV__Latitude__c"},{"fieldLabel":"Preferred Technician","fieldAPIName":"SVMXDEV__Preferred_Technician__c"},{"fieldLabel":"Date Installed","fieldAPIName":"SVMXDEV__Date_Installed__c"},{"fieldLabel":"Created Date","fieldAPIName":"CreatedDate"},{"fieldLabel":"Owner ID","fieldAPIName":"OwnerId"},{"fieldLabel":"Last Viewed Date","fieldAPIName":"LastViewedDate"},{"fieldLabel":"IsSwapped","fieldAPIName":"SVMXDEV__IsSwapped__c"},{"fieldLabel":"Business Hours (Do Not Use)","fieldAPIName":"SVMXDEV__Business_Hours__c"},{"fieldLabel":"Last Modified By ID","fieldAPIName":"LastModifiedById"},{"fieldLabel":"Sub Location","fieldAPIName":"SVMXDEV__Sub_Location__c"},{"fieldLabel":"Warranty Exchange Type","fieldAPIName":"SVMXDEV__Warranty_Exchange_Type__c"},{"fieldLabel":"Date Ordered","fieldAPIName":"SVMXDEV__Date_Ordered__c"},{"fieldLabel":"Distributor Account","fieldAPIName":"SVMXDEV__Distributor_Company__c"},{"fieldLabel":"Account","fieldAPIName":"SVMXDEV__Company__c"},{"fieldLabel":"Top-Level","fieldAPIName":"SVMXDEV__Top_Level__c"},{"fieldLabel":"Last Modified Date","fieldAPIName":"LastModifiedDate"},{"fieldLabel":"Record ID","fieldAPIName":"Id"},{"fieldLabel":"Service Contract Exchange Type","fieldAPIName":"SVMXDEV__Service_Contract_Exchange_Type__c"},{"fieldLabel":"Last Referenced Date","fieldAPIName":"LastReferencedDate"},{"fieldLabel":"Service Contract End Date","fieldAPIName":"SVMXDEV__Service_Contract_End_Date__c"},{"fieldLabel":"State","fieldAPIName":"SVMXDEV__State__c"},{"fieldLabel":"Longitude","fieldAPIName":"SVMXDEV__Longitude__c"},{"fieldLabel":"Street","fieldAPIName":"SVMXDEV__Street__c"},{"fieldLabel":"Installed Product ID","fieldAPIName":"Name"},{"fieldLabel":"Location","fieldAPIName":"SVMXDEV__Site__c"},{"fieldLabel":"Access Hours","fieldAPIName":"SVMXDEV__Access_Hours__c"},{"fieldLabel":"Zip","fieldAPIName":"SVMXDEV__Zip__c"},{"fieldLabel":"Contact","fieldAPIName":"SVMXDEV__Contact__c"},{"fieldLabel":"Warranty Start Date","fieldAPIName":"SVMXDEV__Warranty_Start_Date__c"},{"fieldLabel":"Alternate Account","fieldAPIName":"SVMXDEV__Alternate_Company__c"},{"fieldLabel":"Installation Notes","fieldAPIName":"SVMXDEV__Installation_Notes__c"},{"fieldLabel":"Product","fieldAPIName":"SVMXDEV__Product__c"},{"fieldLabel":"Sales Order Number","fieldAPIName":"SVMXDEV__Sales_Order_Number__c"},{"fieldLabel":"Service Contract","fieldAPIName":"SVMXDEV__Service_Contract__c"},{"fieldLabel":"Serial/Lot Number","fieldAPIName":"SVMXDEV__Serial_Lot_Number__c"},{"fieldLabel":"ProductIQ Template","fieldAPIName":"SVMXDEV__ProductIQTemplate__c"},{"fieldLabel":"City","fieldAPIName":"SVMXDEV__City__c"},{"fieldLabel":"Warranty End Date","fieldAPIName":"SVMXDEV__Warranty_End_Date__c"}]}],"installigenceLogos":[{"uniqueName":"Default","name":"Default","logoId":"015F0000004DdLHIA0"},{"uniqueName":"Electric_Solutions","name":"Electric Solutions","logoId":"015F0000004DionIAC"},{"uniqueName":"Energy_Efficiency","name":"Energy Efficiency","logoId":"015F0000004DiosIAC"},{"uniqueName":"Multitech","name":"Multitech","logoId":"015F0000004DioxIAC"},{"uniqueName":"Residential_Electric_Unit","name":"Residential Electric Unit","logoId":"015F0000004Dip2IAC"},{"uniqueName":"Smart_Technology","name":"Smart Technology","logoId":"015F0000004Dip7IAC"}],"ibValueMaps":[{"valueMapName":"Deinstall_PRIQ","id":"a12F00000047FPxIAM"},{"valueMapName":"Installed_PRIQ","id":"a12F00000047PFSIA2"},{"valueMapName":"InTransit_PRIQ","id":"a12F00000047IfCIAU"},{"valueMapName":"KKG_Mapps_Ins_to_Ins","id":"a12F0000003Ap9kIAC"},{"valueMapName":"MAP043V","id":"a12F0000002KDk0IAG"},{"valueMapName":"MAP043V2","id":"a12F000000460PQIAY"}],"ibTemplates":[{"templateName":"ProductIQ Template Tue Feb 03 2015 12:21:35 GMT+0530 (India Standard Time)","templateId":"ProductIQ_Template_1422946296","template":{"type":null,"text":null,"templateDetails":null,"product":null,"children":[{"type":"root","text":"ProductIQ Template Tue Feb 03 2015 12:21:35 GMT+0530 (India Standard Time)","templateDetails":{"templateName":"ProductIQ Template Tue Feb 03 2015 12:21:35 GMT+0530 (India Standard Time)","templateId":"ProductIQ_Template_1422946296","subLocationText":"","locationText":"","ibText":""},"product":null,"children":[{"type":"product","text":"prodPR1","templateDetails":null,"product":{"productId":"01tF0000003sbI7IAI","productIcon":"Electric_Solutions","productDefaultValues":"MAP043V","productConfiguration":[],"product":"prodPR1","oldProductValueMap":"MAP043V","newProductValueMap":"MAP043V2"},"children":null}]}]},"sfdcId":null,"mappings":null}]}
            responder.result(result); */           
            InstalligenceSetupJsr.JsrGetSetupMetadata(requestData, function(result, evt){				
                responder.result(result);
            }, this);
        }

    }, {});
	
	installigenceadminoperations.Class("SaveSetupData", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },

        performAsync: function(request, responder){
        	var requestData = {
        			profiles: request.profiles,
        			templates: request.ibTemplates,
        			delTemplateIds: request.delTemplateIds
            };
        	/*var result = {};
        	//result = {"profiles":[{"profileName":"US Technician","profileId":"ustechnician","filters":[{"name":"Installed and In Warranty","isGlobal":true,"expression":{"value":null,"operator":null,"field":null,"exprType":null,"condition":null,"children":null}},{"name":"Transit Return","isGlobal":false,"expression":{"value":null,"operator":null,"field":null,"exprType":null,"condition":null,"children":null}}],"actions":[{"parentProfileId":null,"name":"Tech1","isGlobal":false,"actionType":"Field Map","action":"MAP001"}]},{"profileName":"US Manager","profileId":"ustechmanager","filters":[{"name":"Installed and In Warranty","isGlobal":true,"expression":{"value":null,"operator":null,"field":null,"exprType":null,"condition":null,"children":null}},{"name":"Transit Return","isGlobal":false,"expression":{"value":null,"operator":null,"field":null,"exprType":null,"condition":null,"children":null}}],"actions":[{"parentProfileId":null,"name":"Tech1","isGlobal":false,"actionType":"Field Map","action":"MAP001"}]}]};
        	result = {"profiles":[{"profileName":"US Technician","profileId":"ustechnician","filters":[{"name":"vvb","isGlobal":null,"expression":{"value":null,"operator":null,"field":null,"exprType":null,"condition":null,"children":[{"value":"","operator":"vvb","field":"","exprType":"root","condition":"","children":[{"value":"","operator":"And","field":"","exprType":"operatorroot","condition":"","children":[{"value":"23","operator":"","field":"Field 2 Label","exprType":"expression","condition":"Includes","children":null}]}]}]}},{"name":"vvvg","isGlobal":null,"expression":{"value":null,"operator":null,"field":null,"exprType":null,"condition":null,"children":[{"value":"","operator":"vvvg","field":"","exprType":"root","condition":"","children":[{"value":"","operator":"And","field":"","exprType":"operatorroot","condition":"","children":null}]}]}}],"actions":[]},{"profileName":"US Manager","profileId":"ustechmanager","filters":[],"actions":[]}],
        	"templates":[{"templateName":"--None--","template":null},{"templateName":"Elevator - BUL1","template":{"type":"root","text":"Template Name","product":null,"children":[{"type":"product","text":"simultaneous Inventory Update","product":{"productIcon":null,"productDefaultValues":null,"productConfiguration":[],"product":"simultaneous Inventory Update","oldProductValueMap":null,"newProductValueMap":null},"children":[{"type":"product","text":"Laptop","product":{"productIcon":null,"productDefaultValues":null,"productConfiguration":null,"product":null,"oldProductValueMap":null,"newProductValueMap":null},"children":null}]}]}},{"templateName":"Elevator - BUL2","template":{"type":"root","text":"Template Name","product":null,"children":null}}]};
        	responder.result(result);*/
        	
        	InstalligenceSetupJsr.JsrSaveSetupData(requestData, function(result, evt){				
                responder.result(result);
            }, this);
        }

    }, {});	
	
	installigenceadminoperations.Class("GetTemplateFromIB", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },

        performAsync: function(request, responder){
        	var requestData = {
        			InstalledProductId: request.topLevelIB
            };
        	var result = {};
        	
        	InstalligenceSetupJsr.JsrGetTemplateFromIB(requestData, function(result, evt){				
                responder.result(result);
            }, this);
        }

    }, {});	
	
	installigenceadminoperations.Class("GetTopLevelIBs", com.servicemax.client.mvc.api.Operation, {

        __constructor: function(){
            this.__base();
        },

        performAsync: function(request, responder){
        	
        	var module = Module.instance;
            Module.instance.createServiceRequest({handler : function(sRequest){
				sRequest.bind("REQUEST_COMPLETED", function(evt){

					if(module.checkResponseStatus("GetTopLevelIBs", evt.data, false, this) == true){
						responder.result(evt.data.records);
					}
				}, this);
				
				sRequest.bind("REQUEST_ERROR", function(evt){

					if(module.checkResponseStatus("GetTopLevelIBs", evt.data, false, this) == true){
						responder.result([]);//{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003sbIbIAI"},"Id":"01tF0000003sbIbIAI","Name":"prodPR1"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003sZoWIAU"},"Id":"01tF0000003sZoWIAU","Name":"Laptop"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003sbI7IAI"},"Id":"01tF0000003sbI7IAI","Name":"prodPR1"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003sbIWIAY"},"Id":"01tF0000003sbIWIAY","Name":"prodPR1"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003sbIRIAY"},"Id":"01tF0000003sbIRIAY","Name":"prodPR1"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003t6XtIAI"},"Id":"01tF0000003t6XtIAI","Name":"Test's Prod"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003tABvIAM"},"Id":"01tF0000003tABvIAM","Name":"Charger"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003sbICIAY"},"Id":"01tF0000003sbICIAY","Name":"prodPR1"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003t1igIAA"},"Id":"01tF0000003t1igIAA","Name":"SmartPhone"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003sREKIA2"},"Id":"01tF0000003sREKIA2","Name":"saProd1"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003tAC0IAM"},"Id":"01tF0000003tAC0IAM","Name":"Battery"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003tABlIAM"},"Id":"01tF0000003tABlIAM","Name":"Laptopset"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003t3NmIAI"},"Id":"01tF0000003t3NmIAI","Name":"OptiPlex 320"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003sdRMIAY"},"Id":"01tF0000003sdRMIAY","Name":"newProductforINVT"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003sSJwIAM"},"Id":"01tF0000003sSJwIAM","Name":"INVT_Product"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003tABqIAM"},"Id":"01tF0000003tABqIAM","Name":"Laptop"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003Ono6IAC"},"Id":"01tF0000003Ono6IAC","Name":"GenWatt Diesel 200kW"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003Ono7IAC"},"Id":"01tF0000003Ono7IAC","Name":"Coffee beans"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003Ono8IAC"},"Id":"01tF0000003Ono8IAC","Name":"Installation: Industrial - High"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003Ono9IAC"},"Id":"01tF0000003Ono9IAC","Name":"SLA: Silver"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoAIAS"},"Id":"01tF0000003OnoAIAS","Name":"GenWatt Propane 500kW"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoBIAS"},"Id":"01tF0000003OnoBIAS","Name":"SLA: Platinum"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoCIAS"},"Id":"01tF0000003OnoCIAS","Name":"GenWatt Propane 100kW"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoDIAS"},"Id":"01tF0000003OnoDIAS","Name":"GenWatt Propane 1500kW"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoEIAS"},"Id":"01tF0000003OnoEIAS","Name":"Coffee machine Filter"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoFIAS"},"Id":"01tF0000003OnoFIAS","Name":"SLA: Bronze"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoGIAS"},"Id":"01tF0000003OnoGIAS","Name":"GenWatt Gasoline 750kW"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoHIAS"},"Id":"01tF0000003OnoHIAS","Name":"Installation: Portable"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoIIAS"},"Id":"01tF0000003OnoIIAS","Name":"SLA: Gold"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoJIAS"},"Id":"01tF0000003OnoJIAS","Name":"GenWatt Gasoline 300kW"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoKIAS"},"Id":"01tF0000003OnoKIAS","Name":"Installation: Industrial - Low"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoLIAS"},"Id":"01tF0000003OnoLIAS","Name":"GenWatt Gasoline 2000kW"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003OnoMIAS"},"Id":"01tF0000003OnoMIAS","Name":"Installation: Industrial - Medium"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003sW2RIAU"},"Id":"01tF0000003sW2RIAU","Name":"InvSerial"},{"attributes":{"type":"Product2","url":"/services/data/v24.0/sobjects/Product2/01tF0000003sW2WIAU"},"Id":"01tF0000003sW2WIAU","Name":"InvNonSerial"}]);
					}
				}, this);
				
				var query = encodeURI("select id, Name from "+ SVMX.OrgNamespace + "__Installed_Product__c where " + SVMX.OrgNamespace + "__Top_Level__c = ''");
				
				sRequest.callApiAsync({url : "query?q=" + query});
			}, context : this}, this);  
        	
        }

    }, {});	

};
})();

// end of file