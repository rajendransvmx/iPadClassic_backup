
/*************************************** 19-04-13 **************************************/
/******************************** Author Shravya Shridhar *********************************************/

(function(){
 
 if(window.$COMM == undefined || window.$COMM == null) window.$COMM = {};
 
 var STANDARD_STRING = "://params?";
 var callBackfunctionsHolder = [];
 var requestHolders = [];
 var customIndex = 0;
 
 
 /******************************** FUNCTIONS FOR THE INTERACTION WITH IOS *********************************************/
 $COMM.requestDataForType = function(requestType,paramsString,callbackFunction ){
 
 var lEventName = requestType.toLowerCase();
 
 if(callbackFunction != null) {
 callBackfunctionsHolder[lEventName] = callbackFunction;
 }
 
 var reqestObject = {ename:lEventName,param:paramsString,callBk:callbackFunction};
 requestHolders.push(reqestObject);
 
 if(customIndex == 0){
 
 customIndex++;
 var redirectURL = requestType+STANDARD_STRING+paramsString;
 redirectToCustomUrlGiven(redirectURL);
 var requestObject = requestHolders.shift();
 setTimeout(function(){ callMeToContinue(); },100);
 }
 
 }
 
/* Below function used to redirect the page to fake url to comunicate with client*/
 function redirectToCustomUrlGiven(customUrl,data){
 if(customUrl.length > 0){
 
 window.location.href = customUrl;
 }
 }
 
 function  callMeToContinue(){
 
 if(requestHolders.length <= 0){
 customIndex = 0;
 
 return;
 }
 var requestObject = requestHolders.shift();
 var requestType = requestObject.ename;
 var paramsString = requestObject.param;
 var redirectURL = requestType+STANDARD_STRING+paramsString;
 redirectToCustomUrlGiven(redirectURL);
 if(requestHolders.length > 0){
 setTimeout(function(){ callMeToContinue(); },100);
 }
 else {
 
 customIndex = 0;
 }
 }
 
 /* Function to receive the data */
 $COMM.responseReceivedForEventName = function(eventName,contextData){
 /* Change the event name to lowercase*/
 var lEventName = eventName.toLowerCase();
 var callBack = callBackfunctionsHolder[lEventName];
 var returnedData =  callBack(contextData);
 return returnedData;
 }
 
 
 $COMM.printLog = function(msg){
 
 //  $COMM.requestDataForType("console",msg,null);
 }
 
 })();