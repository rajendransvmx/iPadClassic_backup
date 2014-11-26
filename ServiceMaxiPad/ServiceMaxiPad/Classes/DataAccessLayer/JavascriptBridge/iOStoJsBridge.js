
/*************************************** 14-02-13 **************************************/
/******************************** Author Shravya Shridhar *********************************************/


var context = {};

(function(){if(window.$EXPR == undefined || window.$EXPR == null) window.$EXPR = {};
 
 /////////////////////////////// CORE ///////////////////////////
 var orgNameSpace = iPAD_GLOBAL_NAME_SPACE;
 var STANDARD_STRING = "://params?";
 var callBackfunctionsHolder = {};
 var someExpression = null;
 var someCallBackFunctions = null;
 var finalResult = null;

 /**
  * The core API method to evaluate the JS expression
  *
  * @param expression String the expression that needs to be evaluated
  * @param context Object the contextual data that this expression works on
  * @param callId String the unique identifier assigned to a particular call. This serves as a index to the call back function
  */
var SVMXEvalExpression = function(expression, context, callId){
 // simulate the asynchronous nature by executing the rest of the method on a timeout
            
            
			var callbackContext = {
                    callId : callId,
            handler : function(result){
                            finalResult = result;
                        }
			};
			
			try{
                    
                    $EXPR.executeExpression(
                    expression, context, callbackContext.handler, callbackContext, true);
                    

                    return finalResult;
			}
            catch(e){
                    $EXPR.Logger.error("Error while performing EVAL! Please check for syntax error in the JS snippet! =>" + e);
            }
            
 };

 

/******************************** FUNCTIONS FOR THE INTERACTION WITH IOS *********************************************/
 
 $EXPR.initializeWithExpression  = function(expression){
 
        SVMXEvalExpression(expression,context,"getPrice");
       
 }

 
 function requestDataForType(requestType,paramsString){
 
            var redirectURL = requestType+STANDARD_STRING+paramsString;
 redirectToCustomUrlGiven(redirectURL);

 }
 
/* Below function used to redirect the page to fake url to comunicate with client*/
function redirectToCustomUrlGiven(customUrl,data){
        if(customUrl.length > 0){
            window.location.href = customUrl;
        }
 }
 
 
$EXPR.responseReceivedForEventName = function(eventName,contextData){
    /* Change the event name to lowercase*/
    var lEventName = eventName.toLowerCase();
    var targetData = contextData.target;
    var pricebookInfo = contextData.data;
 
   
    context.sfmProcessId = targetData.sfmProcessId;
    context.headerRecord = targetData.headerRecord;
    context.detailRecords = targetData.detailRecords;
 
    var finalData =  someCallBackFunctions(pricebookInfo);
    var jsonString = JSON.stringify(finalResult);
    return jsonString;
}
 
 
/******************************** TEMPORARY *********************************************/
 window.SVMXInitExpressionEngine = function(params){
        orgNameSpace = iPAD_GLOBAL_NAME_SPACE;
 }

 
 // query the flash object instance based on the embedding broswer type
 function getAppInstance(name){
        alert("getAppInstance");
 
 }
 

 
/******************************** FUNCTIONS WHICH WILL BE CALLED BY CODE SNIPPETS *********************************************/
 $EXPR.getOrgNamespace = function(){
       
        var ons = getOrgNameSpace(orgNameSpace);
    // strip off the trailing /
        if(ons != "") ons = ons.substring(0, ons.length - 1);
 
        return ons;
 };
 
$EXPR.getPricingDefinition = function(context, callback){
   
   // callBackfunctionsHolder.pricebook = callback;
    someCallBackFunctions = callback;
    /* Request for work order */
    requestDataForType("pricebook","workorder");
 
 }
 
 $EXPR.showMessage = function(someArg){
 var text = someArg.text;
 var type = someArg.type;
 var handler = someArg.handler;
 var buttonsArray = someArg.buttons;
 
    if(text != null){
        requestDataForType("showMessage",'msg='+text);
    }
    if (handler != null){
        handler(null);
    }
 return;
}
 
 $EXPR.printLog = function(msg){

 if(msg == null){
 return;
 }
    msg = msg.replace("=>",":");
    requestDataForType("console",'msg='+msg);
 }
 
/******************************** UTILITY and UNUSED FUNCTIONS *********************************************/
 function ListOfValueMap(key){
        this.key = key;
        this.allValues = {};
        this.addToValues = function(value){
                if(!value) return;
                this.allValues[value] = value;
        }
 
        this.getStringAsXML = function(){
                var template = "<valueMap><key>{0}</key>{1}</valueMap>";
                var valuesTemplate = "<values>{0}</values>";
                var i, values = "", ret = "";
                for(i in this.allValues){
                values += format(valuesTemplate, this.allValues[i]);
                }
                ret = format(template, this.key, values);
                return ret;
        }
 }
 
 function SingleValueMap(key, value){
        this.key = key;
        this.value = value;
 
        this.getStringAsXML = function(){
            var template = "<valueMap><key>{0}</key><value>{1}</value></valueMap>";
            ret = format(template, this.key, this.value);
            return ret;
        }
 }
 
 function format(){
        if(arguments.length == 0 ) return "";
 
        var formatted = arguments[0];	// first parameter is the string to be formated
    
        for (var i = 1; i < arguments.length; i++) {
                var regexp = new RegExp('\\{'+ (i - 1) +'\\}', 'gi');
            formatted = formatted.replace(regexp, arguments[i]);
        }
 return formatted;
 }
 
 function getItemForDetailRecordKey(key, record){
 
        //add ORGNAMESPACE__ only if the key ends with __c
                if(key.indexOf("__c", key.length - "__c".length) !== -1)
                    key = orgNameSpace + "__" + key;
 
            var length = record.length, k, ret = "";
            for(k = 0; k < length; k++){
                var fld = record[k];
                if(fld.key == key){
                        ret = fld;
                            break;
                }
            }
            return ret;
}
 
function getOrgNameSpace(orgNameSpace){
            if(orgNameSpace != null && orgNameSpace != '') return orgNameSpace + "/";
        else return "";
 }

 })();




