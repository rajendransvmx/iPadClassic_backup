/**
 * This is the core implementation of the expression engine which is consumer neutral
 * 
 * @author Indresh MS
 */

(function(){
	if(window.$EXPR == undefined || window.$EXPR == null) window.$EXPR = {};

	// set up logging console
	try{
		if( !window.console ) {
			window.console = {
					log : function() {},
					error : function() {},
					info : function() {},
					warn : function() {}
			};
		}
	}catch(e) { }
	
    /**
	 * The expression engine implementation class
	 */
	var JSEE = function(){
		
		/**
		 * The core internal API method to evaluate the JS expression
		 * !!! Note the right now, this method works on single context. In future, it may 
		 * !!! support multiple contexts via context roots mechanism ($D for data for example) 
		 * 
		 * @param expr String the expression that needs to be evaluated
		 * @param context Object the contextual data that this expression works on
		 * @param callback Function the function to be invoked to present the result
		 * @param callbackContext Object the object on which the callback function exists
		 * @param async Boolean true if the expression results in an asynchronous behavior, false otherwise
		 */
		this.evalExpression = function(expr, context, callback, callbackContext, async){
			var result = null, bReturned = false;;
			(function (expr, context, callback, callbackContext, async){
				
				function $ADD(a, b){ return a + b; };
				function $SUB(a ,b){ return a - b; };
				function $ISNULL(a){ if(a) return true; else return false; };
				function $BOOL(a){ return !!a; };
				
				function $SORT(items, fieldOrFunc){
					// right now, only field name is supported
					if(typeof(fieldOrFunc) != 'string') return;
					
					var i, l = items.length;
					
					if(l < 2) return items;
					
					for(i = 0; i < (l - 1);){
						var k = 0;
						for(; k < (l - 1); k++){
							if(items[k][fieldOrFunc] > items[k+1][fieldOrFunc]){
								var temp   = items[k];
								items[k]   = items[k+1];
								items[k+1] = temp; 
							}
						}
						l--;
					}
					return items;
				};
				
				// always assumes that this is invoked as part of asynchronous calls
				function $RETURN(value){
          
					// it is not allowed to return twice in the same expression
					if(bReturned) throw new Error("Attempted to RETURN twice in the same expression!");
					
					bReturned = true;
					callback.call(callbackContext, value);
				}
				
				function $FORMAT(){
                     var argumentLength = arguments.length;
                     
                     if(argumentLength == 0 ) return "";
                     
                     // first parameter is the string to be formatted
                     var toBeFormatted = arguments[0];
                     
                     // loop thru the arguments and create regular expression
                     for (var count = 1; count < argumentLength; count++) {
                     
                         //build regular expression
                         var regularExpression = new RegExp('\\{'+ (count - 1) +'\\}', 'gi');
                         
                         //replace argument with the regular expression
                         var formattedResult = toBeFormatted.replace(regularExpression, arguments[count]);
                     }
                     
                     return formattedResult;

				}
				
				context = $EXPR.toObject(context);
             
				result = eval(expr);
             
			})(expr, context, callback, callbackContext, async);
			
			// invoke the call back immediately if this is not an asynchronous call
			if(!async){
				callback.call(callbackContext, result);
			}		
			
			// return the result anyways
			return result;
		};
	};
	
	/**
	 * The external API method to be consumed by the respective bridges
	 */
	$EXPR.executeExpression = function(expr, context, callback, callbackContext, async){
		var jsel = new JSEE();;
		var ret = jsel.evalExpression(expr, context, callback, callbackContext, async);
		return ret;	
	};
	
	$EXPR.toJSON = function(data){
		if(data){
			return $.toJSON(data);
		}
		return null;
	};
	
	$EXPR.toObject = function(data){
		if(typeof(data) == 'string')
			return $.secureEvalJSON(data);
		else
			return data;
	};
	
	$EXPR.ajax = function(options){
		return $.ajax(options);
	};
	
	$EXPR.Logger = {
		log : function(msg){
                $EXPR.printLog(msg);
		},
		
		error : function(msg){
			 $EXPR.printLog(msg);
		},
		
		warn : function(msg){
			 $EXPR.printLog(msg);
		},
		
		debug : function(msg){
			 $EXPR.printLog(msg);
		},
		
		info : function(msg){
			 $EXPR.printLog(msg);
		},
		
		message : function(msg){
			 $EXPR.printLog(msg);
		}
	};
})();


// end of file
