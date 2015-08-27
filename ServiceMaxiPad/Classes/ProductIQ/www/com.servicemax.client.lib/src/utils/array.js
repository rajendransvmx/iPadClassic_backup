/**
 * @class SVMX.array  
 * @singleton  
 *   
 * @author Michael Kantor
 * @copyright ServiceMax, Inc
 * @since The minimum version where this file is supported
 *
 * All examples use the following array:
 *
    var arr = [
        {
            firstName: "Michael", 
            lastName: "Kantor"
        }, 
        {
            firstName: "Timothy", 
            lastName: "Ashton"
        }, 
        {   
            firstName: "Eric", 
            lastName: "Ingram"
        }, 
        {
            firstName: "Vinod", 
            lastName: "Kumar"
        }];
 */
(function ($) {

    SVMX.array = {

        /** 
         * Returns the matching index in the array.
         *
         * The indexOf method lets you search by value or search using a custom function.
         * The inValue parameter can be either a search function or value.
         *
         * + You can NOT search an array of functions for a matching function.
         * 
         *      SVMX.array.indexOf(arr, arr[3]); 
         *      -> 3
         *    
         *      SVMX.array.indexOf(arr, function(inItem) {
         *          return inItem.firstName == "Michael"
         *      }); 
         *      -> 0
         *
         * @method
         * @param {Object[]/string[]/number[]} inArray Array of objects or literals to search
         * @param {Function} inValue inValue can be a function or value.  If its a value, then we search for an exact match to this value.  Value to search for.  If value is a function, its treated as a callback
         *
         * that is used to evaluate whether an item is a match. Callback is function(inItem, inIndex)
         * @param {Mixed} inValue.inItem Current value to be tested by your callback function
         * @param {number} [inValue.inIndex] Current index in the array that you are testing
         * @param {boolean} inValue.return True if inItem matches your search criteria
         * @param {Object} [inContext] If a callback is provided, this can provide the function's "this" value.
         *          
         * @return {Number} -1 if not found, or the index of the element found.
         *
         */
        indexOf: function (inArray, inValue, inContext) {
            if (!inArray || !inArray.length) return -1;
            var isFunc = typeof inValue === "function";
            if (isFunc && inContext) inValue = SVMX.proxy(inContext, inValue);

            if (Array.prototype.indexOf && !isFunc) {
                return inArray.indexOf(inValue);
            } else {
                for (var i = 0; i < inArray.length; i++) {
                    if (isFunc) {
                        if (inValue(inArray[i], i)) return i;
                    } else if (inValue === inArray[i]) return i;
                }
            }
            return -1;
        },

        /** 
         * This is the same as indexOf but returns the matching element instead of its index
         *
         * The get method lets you search by value or search using a custom function.
         *
         * + You can NOT search an array of functions for a matching function.
         * 
            SVMX.array.get(arr, function(inItem) {
                return inItem.firstName == "Michael"
            }); 
            -> {firstName: "Michael", lastName: "Kantor"}
         *
         * @method
         * @param {Object[]/string[]/number[]} inArray Array of objects or literals to search
         * @param {Function} inCallback Determines if the value is the one we are looking for
         * @param {Mixed} inCallback.inItem Current value to be tested by your callback function
         * @param {number} [inCallback.inIndex] Current index in the array that you are testing
         * @param {boolean} inCallback.return True if inItem matches your search criteria
         * @param {Object} [inContext] Set's the context (value of the this object) in the callback function
         *          
         * @return {Mixed} Returns whatever matching elements were found or null if nothing is found
         *
         */        
         get: function (inArray, inValue, inContext) {
            var index = SVMX.array.indexOf(inArray, inValue, inContext);
            if (index == -1) return null;
            return inArray[index];
        },

        /** 
         * This is the same as calling SVMX.array.indexOf(array, inValue) != -1 but is more concise for if and loop condition expressions.
         *
            if (SVMX.array.contains(arr, arr[3])) {
                ...
            }
         * @method
         * @param {Object[]/string[]/number[]} inArray Array of objects or literals to search
         * @param {Function} inValue inValue can be a function or value.  If its a value, then we search for an exact match to this value.  Value to search for.  If value is a function, its treated as a callback
         * that is used to evaluate whether an item is a match. Callback is function(inItem, inIndex)
         * @param {Mixed} inValue.inItem Current value to be tested by your callback function
         * @param {number} [inValue.inIndex] Current index in the array that you are testing
         * @param {boolean} inValue.return True if inItem matches your search criteria
         * @param {Object} [inContext] If a callback is provided, this can provide the function's "this" value.
         *          
         * @return {Boolean} Returns true if inValue exists in inArray.
         */
        contains: function (inArray, inValue, inContext) {
            return SVMX.array.indexOf(inArray, inValue, inContext) != -1;
        },

        /** 
         * Maps one array to a second array.  Useful for transposing values, or extracting a field from every object
         * in an array and storing it in a new array.  Callbacks are of the form function(inItem, inIndex)
         *
            var firstNames = SVMX.array.map(arr, function(inItem) {
                return inItem.firstName
            }); 
            -> ["Michael", "Timothy", "Eric", "Vinod"]
         *
         * @method
         * @param {Mixed[]} inArray Array of objects or values
         * @param {Function} inCallback Callback that takes as input an array element and returns a value for the new array
         * @param {Mixed} inCallback.inItem An element of the array
         * @param {Mixed} inCallback.return Any value
         * @param {Object} [inContext] Optional context for inCallback
         *
         * @return {Mixed[]} a new array
         */
        map: function (inArray, inCallback, inContext) {
            if (inContext) inCallback = SVMX.proxy(inContext, inCallback);
            return $.map(inArray, inCallback);
        },

        /** 
         * Returns a new array with the desired elements from the original array
         *
            var haveLongNames = SVMX.array.filter(arr, function(inItem) {
                return inItem.firstName.length > 5
            }); 
            -> [{firstName: "Michael", lastName: "Kantor"}, {firstName: "Timothy", lastName: "Ashton"}]
         *
         * @method
         * @param {Mixed[]} inArray Array of objects or values
         * @param {Function} inCallback Callback that takes as input an array element for each one returns true/false
         * @param {Mixed} inCallback.inItem An element of the array
         * @param {boolean} inCallback.return True if this element should be in the new array
         * @param {Object} [inContext] Optional context for inCallback
         *
         * @return {Mixed[]} a new array
         */
        filter: function (inArray, inCallback, inContext) {
            if (inContext) inCallback = SVMX.proxy(inContext, inCallback);
            return $.grep(inArray, inCallback);
        },


        /** 
         * Used to test if something is true for every element of an array.  Callbacks are of the form function(inItem, inIndex)
         *
            if (SVMX.array.every(arr, function(inItem) {return inItem.firstName.length > 5;})) {
                alert("They are all true");
            }
         *
         * @method
         * @param {Mixed[]} inArray Array of objects or values
         * @param {Function} inCallback Callback that takes as input an array element and returns a boolean
         * @param {Mixed} inCallback.inItem An item of the array
         * @param {number} inCallback.inIndex The index in the array of inItem
         * @param {boolean} inCallback.return Returns true if the element matches the condition; returns false to make the entire every() call return false
         * @param {Object} [inContext] Optional context for inCallback
         * @return {boolean} If inCallback returns false for any element of inArray, returns false, else returns true
         */
        every: function (inArray, inCallback, inContext) {
            if (!inArray || !inArray.length) return false;
            if (inContext) inCallback = SVMX.proxy(inContext, inCallback);
            for (var i = 0; i < inArray.length; i++)
                if (!inCallback(inArray[i], i)) return false;
            return true;
        },

        /** 
         * Used to iterate over every element of an array and call a function on each element.
         * Its a good way to localize the scope for handling of each item.  Callbacks are of the form function(inItem, inIndex)
         *
            SVMX.array.forEach(arr, function(inItem) {
                console.log(inItem.firstName);
            });
         * @method
         * @param {Array} inArray The array to iterate over
         * @param {Function} inCallback Function to call on each item; of the forum function(inItem, inIndex)
         * @param {Object} [inContext] Optional context for inCallback
         * @param {null|Object} inContext Execute inCallback with inContext as the "this" value.
         *
         * @note If callback returns false, forEach exits.  Treat this as your loop s"break".
         */
        forEach: function (inArray, inCallback, inContext) {
            if (inContext) inCallback = SVMX.proxy(inContext, inCallback);
            for (var i = 0; i < inArray.length; i++) {
                var result = inCallback(inArray[i], i);
                if (result === false) return;
            }
        },

        /** 
         * I find this easier to remember than splice...
         *
             SVMX.array.insert(arr, {firstName: "Indresh", lastname: ""}, 0); 
            -> Indresh is first element in list
         * @method
         * @param {Array} inArray Array to modify
         * @param {Value} inElement Value to insert
         * @param {Number} inIndex Position to insert the new value
         */
        insert: function (inArray, inElement, inIndex) {
            inArray.splice(inIndex, 0, inElement);
        },

        /** 
         * I find this easier to remember than splice...
         *
         *           
            SVMX.array.removeElementAt(arr,0);  
            -> Indresh is removed from the array
         *
         * @method
         * @param {Array} inArray Array to modify
         * @param {Number} inIndex Position to remove the value from
         */
        removeElementAt: function (inArray, inIndex) {
            inArray.splice(inIndex, 1);
        },

        /** 
         * More general remove method lets you remove an element by passing in the element (note must be the exact element), 
         * or passing in a callback function to find all elements to remove.
         *
             SVMX.array.remove(arr, arr[0]); 
            -> Michael is removed from the array
            
            SVMX.array.remove(arr, function(inItem) {return inItem.firstName.length > 5;}, true) 
            -> Removes all elements where first name is longer than 5 characters
         *
         * @method
         * @param {Array} inArray Array to modify
         * @param {Function|Value} inValue If its a function, then its treated a
         *                         callback of the form function(inItem, inIndex)
         *                         and if it returns a truthy value, element is removed.
         *                         If its a value, remove the first occurance of that value
         * @param {Boolean} removeAll Defaults to false; if true then will iterate over every
         *                  item in your very long array and find and remove all matches.
         *
         */
        remove: function (inArray, inValue, removeAll) {
            var isFunc = typeof inValue === "function";
            for (var i = inArray.length - 1; i >= 0; i--) {
                var value = inArray[i];
                var isMatch = isFunc ? inValue(value, i) : value === inValue;
                if (isMatch) {
                    SVMX.array.removeElementAt(inArray, i);
                    if (!removeAll) return value;
                }
            }
        }
    };
})(jQuery);