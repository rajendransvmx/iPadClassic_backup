/**
 * Expression engine for evaling customer expressions and applying data values to the expression.
 * @author Michael Kantor, Indresh MS
 * @class com.servicemax.client.runtime.jsee.expression
 * @singleton
 *
 * @copyright 2013 ServiceMax, Inc
 */

(function(){
	
	/**
	 * The expression engine implementation class
	 */
	var JSEE = function(){
				function $LC (a) {
					return (typeof a === "string") ? a.toLowerCase() : a;
				}

				/* Math Functions */
				function $ADD(a, b){ return a + b; };
				function $SUB(a ,b){ return a - b; };

				/* Comparison Functions */

				// isnull/isnotnull: null, undefined and "" are all treated as null values.
				// Status: Should work for any type of field.
				function $ISNULL(a){ if(a || a === 0 || a === false) return false; else return true; };
				function $ISNOTNULL(a){ if(a || a === 0 || a === false) return true; else return false; };
				
				// EQ/NE: Returns whether values are equal or not equal
				// Status: Should work for strings, numbers, dates, booleans. String comparisons are case-insensitive
				//         Should fail for Objects (are there any?)
				function $EQ(a, b, allowNull) {
                    if (!allowNull && a !== b && ($ISNULL(a) || $ISNULL(b))) return CONSTANTS.INVALID;
					if (a instanceof Date) a = a.getTime();
					if (b instanceof Date) b = b.getTime();
					return $LC(a) === $LC(b);
				};
				function $NE(a, b)  {
				    // NE is never invalid; comparing null NE xxx should always return false unless xxx is "" or null
				    if ($ISNULL(a) && $ISNULL(b)) return false;
				    var result = $EQ(a,b, true);
				    return !result;
				};

				// GT/LT/GE/LE: Returns values greater than or less than.  Does case-insenstive comparison.
				// Status: Tested for Strings, Numbers and Dates though Date values must be entered as yyyy-mm-dd or "2013-04-13 00:00:00"
				// Note that because this is ultimately a string comparison, the following date comparisons give the following results:
				// "2013-04-13 00:00:00" > "2013-04-13" > true
				// "2013-04-13 00:00:00" > "2013-04-13 01" > false
				function $GT(a, b) {
                    if ($ISNULL(a) || $ISNULL(b)) return CONSTANTS.INVALID;
				    return $LC(a) > $LC(b);
				};
				function $LT(a, b) {
                    if ($ISNULL(a) || $ISNULL(b)) return CONSTANTS.INVALID;
				    return $LC(a) < $LC(b);
				};
				function $GE(a, b) {
                    if ($ISNULL(a) || $ISNULL(b)) return CONSTANTS.INVALID;
				    return $LC(a) >= $LC(b);
				};
				function $LE(a, b) {
                    if ($ISNULL(a) || $ISNULL(b)) return CONSTANTS.INVALID;
				    return $LC(a) <= $LC(b);
				};


				// Substring Tests
				// Status: Tested on Strings and Numbers.  Should work on anyting except Objects.
				function $STARTS(a,b) { 
                    if ($ISNULL(a) || $ISNULL(b)) return CONSTANTS.INVALID;
				    return String(a).toLowerCase().indexOf($LC(b)) === 0;
				};
				function $CONTAINS(a, b) { 
                    if ($ISNULL(a) || $ISNULL(b)) return CONSTANTS.INVALID;
				    return String(a).toLowerCase().indexOf($LC(b)) !== -1;
				};
				function $NOTCONTAINS(a, b) { 
                    // NOTCONTAINS is never invalid; NULL values can be safely used in a NOTCONTAINS
                    // "hello" NOTCONTAINS null is true
                    // null NOTCONTAINS "hello" is also true
                    // An expression testing NOTCONTAINS is almost always going to be satisfied with that response
				    return String(a).toLowerCase().indexOf($LC(b)) === -1;
				};



				// Array Tests (INCLUDE == $IN/EXCLUDE == $NOTIN).  Because the input is a string of the form "x;y;z", the second parameter b must be turned to string
				// Does case insensitive string comparison
				// If a is not a list of values, it will still be turned into an array of one element
				// If a is not a string it will be turned into a string 
				function $IN(inList,inValue) {
                    if ($ISNULL(inValue) || $ISNULL(inList)) return CONSTANTS.INVALID;		
					var tmpArray = String(inList).toLowerCase().split(/[,;]/);
					return SVMX.array.indexOf(tmpArray, String(inValue).toLowerCase()) !== -1;
				};
				function $NOTIN(inList,inValue) {
				    var result = $IN(inList,inValue);
				    if (result === 0) return CONSTANTS.INVALID;
				    return !result;
				};			


                function $NUMBER(inValue) {
                    if ($ISNULL(inValue)) return null; // so that expressions using this can return -1 instead of true/false
                    return Number(inValue);
                }
                
				// Sometimes a boolean is true/false
				// Sometimes a boolean is "true"/"false"
				// And the rest of the time a boolean is just a truthiness 0/1, ""/"has text", null, undefined, etc.
				function $BOOLEAN(inValue) {
					if (!inValue) return false;
					var value = String(inValue).toLowerCase();
					
					// Only one value gets past the first "if" statement that means false.
					if (value === "false") return false;
					return true;
				}

				// Date methods.  
				function $DATE(inValue) {
				    if ($ISNULL(inValue)) return null;
					return com.servicemax.client.lib.datetimeutils.DatetimeUtil.getDateObjFromDataModel(inValue);
				}

				/* DATE COMPARISON FUNCS: 
				 * If these are called, we aren't doing a datetime equality test, only a date equality test
				 * that must ignore any time components for an accurate comparison.
				 * NOTE: Never modify the input date object which may be reused elsewhere; always copy the date.
				 */
				function $DATEEQ(a,b) {
                    if (!a || !b) return CONSTANTS.INVALID;
					a = new Date(a); 
					b = new Date(b);
					a.setHours(0,0,0,0);
					b.setHours(0,0,0,0);
					return a.getTime() === b.getTime();
				}
				function $DATENE(a,b) {
                    if (!a || !b) return CONSTANTS.INVALID;
					return !$DATEEQ(a,b);
				}
				function $DATEGT(a,b) {
                    if (!a || !b) return CONSTANTS.INVALID;
					a = new Date(a); 
					b = new Date(b);
					a.setHours(0,0,0,0);
					b.setHours(0,0,0,0);
					return a.getTime() > b.getTime();
				}
				function $DATEGE(a,b) {
                    if (!a || !b) return CONSTANTS.INVALID;
					a = new Date(a); 
					b = new Date(b);
					a.setHours(0,0,0,0);
					b.setHours(0,0,0,0);
					return a.getTime() >= b.getTime();
				}
				function $DATELT(a,b) {
                    if (!a || !b) return CONSTANTS.INVALID;
					a = new Date(a); 
					b = new Date(b);
					a.setHours(0,0,0,0);
					b.setHours(0,0,0,0);
					return a.getTime() < b.getTime();
				}
				function $DATELE(a,b) {
                    if (!a || !b) return CONSTANTS.INVALID;
					a = new Date(a); 
					b = new Date(b);
					a.setHours(0,0,0,0);
					b.setHours(0,0,0,0);
					return a.getTime() <= b.getTime();
				}
				
				/* These date methods get values for comparison against Dates, not Datetimes
				 * Use the comparison functions above if comparing them to datetimes.
				 */
				function $DATETODAY() {
					return com.servicemax.client.lib.datetimeutils.DatetimeUtil.getDateToday();

				};
				function $DATETOMORROW() {
					return com.servicemax.client.lib.datetimeutils.DatetimeUtil.getDateTomorrow();					
				};

				function $DATEYESTERDAY() {
					return com.servicemax.client.lib.datetimeutils.DatetimeUtil.getDateYesterday();					
				};

				/* Array Functions: UNTESTED */
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
				
				/* MICHAEL: I have not reviewed this; was copied from prior version; recommend SVMX.string.replace instead */
				function $FORMAT(){
					if(arguments.length == 0 ) return "";
					
					var formatted = arguments[0];	// first parameter is the string to be formated
					
				    for (var i = 1; i < arguments.length; i++) {
				        var regexp = new RegExp('\\{'+ (i - 1) +'\\}', 'gi');
				        formatted = formatted.replace(regexp, arguments[i]);
				    }
				    return formatted;
				}


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
		this.evalExpressions = function(exprs, context, callback, callbackContext, async){
				var bReturned = false, results = [];
				
				// always assumes that this is invoked as part of asynchronous calls
				function $RETURN(value){
					
					// it is not allowed to return twice in the same expression
					if(bReturned) throw new Error("Attempted to RETURN twice in the same expression!");
					
					bReturned = true;
					callback.call(callbackContext, value);
				}


			(function (exprs, context, callback, callbackContext, async){
				
				context = SVMX.toObject(context);

				var scopeExpr = [];
				for (var key in context) {
					if (context.hasOwnProperty(key)) {
						scopeExpr.push("var " + key + " = context." + key + ";");							
					}
				}

				eval(scopeExpr.join("\n"));  // Set all fields to be in this function scope; the next eval will have access to this scope and these variables
				// If expression defines vars, don't let them affect other expressions; localize their context with an inner function
				SVMX.array.forEach(exprs, function(expr, i) {
					//SVMX.getLoggingService().getLogger("SVMX-expressions").info("EXPR:" + expr);
					results[i] = eval(expr);
					logger.info(expr + " = " + results[i]);
				});
			})(exprs, context, callback, callbackContext, async);
			
			// invoke the call back immediately if this is an asynchronous call
			// If its a synchronous call, then just return the value
			if(!async && callback){
				callback.call(callbackContext, results);
			}		
			
			// return the result anyways
			return results;
		};
	};
	
	var expressionEngine = new JSEE();
	var logger = SVMX.getLoggingService().getLogger("SVMX-expressions");

	/**
	 * @param {String|String[]} exprs One or an array of string expressions to be evaluated "a + b" or ["a + b", "a - b"]
	 * @param {Object} context Data values to be available to the expression {a: 5, b: 10}
	 * @param {null|Function} callback If async is true, then results are provided to this callback instead of simply returning a value
	 * @param {Object} callbackContext If async is true, callbackContext will be the "this" context for the callback function
	 * @param {Boolean} async If assync is false, return the value, if true, pass value to callback
	 */

	SVMX.executeExpressions = function(exprs, context, callback, callbackContext, async){
		try {
			var ret = expressionEngine.evalExpressions($.isArray(exprs) ? exprs : [exprs], context, callback, callbackContext, async);
		} catch(e) {
			logger.error("executeExpression: error in expression: " + exprs);
		}
		return $.isArray(exprs) ? ret : ret[0];
	};
    
    
    var CONSTANTS = {
        INVALID : 0
    };
    
    SVMX.executeExpressionsResultInvalid = function(result) {return result === CONSTANTS.INVALID;};
})();

// end of file