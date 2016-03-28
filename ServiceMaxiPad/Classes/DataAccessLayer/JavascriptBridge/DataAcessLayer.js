
/*************************************** 19-04-13 **************************************/
/******************************** Author Shravya Shridhar *********************************************/

(function(){
 
 if(window.$DAL == undefined || window.$DAL == null) window.$DAL = {};
 
 
 var functionMapper = {executeQuery:'1',objectSchema:'2',objectList:'3',InsertQuery:'4',UpdateQuery:'5',DeleteQuery:'6',SOQLQuery:'7',SubmitQuery:'8',DescribeObject:'9'};
 var DADelegates = [];
 
 
/* Returns the result */
 $DAL.executeQuery = function(objectName, fieldNames, criteriaArray, advancedExpression, orderBy, callbackFunction){
 
 
 if(objectName != null) {
 
 DADelegates[objectName] = callbackFunction;
 
 var requestObject =  formRequestobject(objectName, fieldNames, criteriaArray, advancedExpression, orderBy);
 
 var requestType = "DARequest"+functionMapper.executeQuery;
 var finalParamString = JSON.stringify(requestObject);
 
 $COMM.requestDataForType(requestType,finalParamString,function(contextData) {
                          
                          var objectname = contextData.objectName;
                          var callBk = DADelegates[objectname];
                          setTimeout(function(){ callbackFunction(contextData);},1);
                          
                          });
 
 }
 }
 
 
 $DAL.getDBObjectFieldsOfTable = function(objectName,callbackFunction){
 if(objectName != null) {
 var requestObject =  formRequestobject(objectName,null,null,null,null);
 var finalParamString = getJsonString(requestObject);
 var requestType = "DARequest"+functionMapper.objectSchema;
 
 DADelegates[objectName] = callbackFunction;
 
 $COMM.requestDataForType(requestType,finalParamString,function(contextData) {
                          
                          var objectname = contextData.objectName;
                          var callBk = DADelegates[objectname];
                          setTimeout(function(){ callbackFunction(contextData);},1);
                          });
 
 }
 }
 
 
 $DAL.insertQuery = function(objectName, fieldsArray, callbackFunction){
 
 if(objectName != null) {
 DADelegates[objectName] = callbackFunction;
 var requestObject =  formRequestobject(objectName, fieldsArray, null, null, null);
 var requestType = "DARequest"+functionMapper.InsertQuery;
 var finalParamString = JSON.stringify(requestObject);
 $COMM.requestDataForType(requestType,finalParamString,function(contextData) {
                          setTimeout(function(){ callbackFunction(contextData);},1);
                          });
 
 }
 }
 
 $DAL.executeUpdateQuery = function(objectName, fieldsArray, criteriaArray, advancedExpression, callbackFunction){
 
 if(objectName != null && fieldsArray != null) {
 
 DADelegates[objectName] = callbackFunction;
 
 var requestObject =  formRequestobject(objectName, fieldsArray, criteriaArray, advancedExpression, null);
 var requestType = "DARequest"+functionMapper.UpdateQuery;
 var finalParamString = JSON.stringify(requestObject);
 
 $COMM.requestDataForType(requestType,finalParamString,function(contextData) {
                          
                          var objectname = contextData.objectName;
                          var callBk = DADelegates[objectname];
                          setTimeout(function(){ callbackFunction(contextData);},1);
                          
                          });
 
 }
 }
 
 $DAL.executeDeleteQuery = function(objectName, criteriaArray, advancedExpression, callbackFunction){
 
 if(objectName != null) {
 
 DADelegates[objectName] = callbackFunction;
 
 var requestObject =  formRequestobject(objectName, null, criteriaArray, advancedExpression, null);
 var requestType = "DARequest"+functionMapper.DeleteQuery;
 var finalParamString = JSON.stringify(requestObject);
 
 $COMM.requestDataForType(requestType,finalParamString,function(contextData) {
                          
                          var objectname = contextData.objectName;
                          var callBk = DADelegates[objectname];
                          setTimeout(function(){ callbackFunction(contextData);},1);
                          
                          });
 
 }
 }
 
 $DAL.getDBObjects = function(callbackFunction){
 
 
 var requestType = "DARequest"+functionMapper.objectList;
 $COMM.requestDataForType(requestType,null,function(contextData) {
                          
                          setTimeout(function(){ callbackFunction(contextData);},1);
                          });
 
 
 }
 
 // 012895 - opdoc sort order fix - added sortOder, innerJoin params
 $DAL.parseSoqlJSOnObject = function(objectName, fieldNames, criteriaArray, advancedExpression,jsonQuery, sortOder, innerJoin,callbackFunction){
 
 var temp_orderBy = (sortOder)?sortOder:null;
 
 var requestType = "DARequest"+functionMapper.SOQLQuery;
 var requestObject =  formRequestobject(objectName, fieldNames, criteriaArray, advancedExpression, temp_orderBy);
 requestObject.jsonSoql = jsonQuery;
 requestObject.innerJoin = innerJoin;
 var finalParamString = JSON.stringify(requestObject);
 $COMM.requestDataForType(requestType,finalParamString,function(contextData) {
                          
                          setTimeout(function(){ callbackFunction(contextData);},1);
                          });
 
 
 }
 
 $DAL.submitQuery = function(query, callbackFunction){
 if(query == null || query.length <= 0) {
 return;
 }
 var requestType = "DARequest"+functionMapper.SubmitQuery;
 var requestObject = {};
 requestObject.jsonSoql = query;
 var finalParamString = JSON.stringify(requestObject);
 $COMM.requestDataForType(requestType,finalParamString,function(contextData) {
                          
                          setTimeout(function(){ callbackFunction(contextData);},1);
                          });
 }
 
 
 $DAL.describeObject = function(objectName, callbackFunction){
 if(objectName == null || objectName.length <= 0) {
 return;
 }
 var requestType = "DARequest"+functionMapper.DescribeObject;
 var requestObject =  formRequestobject(objectName, null, null, null, null);
 
 var finalParamString = JSON.stringify(requestObject);
 $COMM.requestDataForType(requestType,finalParamString,function(contextData) {
                          
                          setTimeout(function(){ callbackFunction(contextData);},1);
                          });
 }
 
 
 /* Utility functions */
 function formRequestobject(objectName, fieldsArray, criteriaArray, advancedExpression, orderBy) {
 
 var requestObject = {};
 requestObject.objectName = objectName;
 requestObject.fieldNames = fieldsArray;
 requestObject.criteria  = criteriaArray;
 requestObject.advancedExpression = advancedExpression;
 requestObject.orderBy  = orderBy;
 
 return requestObject;
 }
 
 
 function getJsonString(jsonObject){
 var finalParamString = JSON.stringify(jsonObject);
 return finalParamString;
 }
 
 })();


