/**
 * @class SVMX
 * @singleton
 *
 * @author Unknown
 * @copyright ServiceMax, Inc
 * @since The minimum version where this file is supported
 */
;(function ($) {
    var packageCount = 0;
    var classCount = 0;

    var SVMX = {

        /**
         * Creates a package given a unique name
         *
         * + ie: creates a package com.servicemax.client.lib.api and add a Module class
         *
            var libApi = SVMX.Package("com.servicemax.client.lib.api");

            libApi.Class("Module", com.servicemax.client.lib.api.ModuleActivator, {
                __constructor : function(){

                }
            });
         *
         * @method
         * @param   {String}    name
         *
         * @return  {Object}    package object
         *
         */
        Package: function (name) {
            var arr = name.split(".");
            var fn = (window || this);
            for (var i = 0, len = arr.length; i < len; i++) {
                if (!fn[arr[i]]) fn[arr[i]] = {};

                fn = fn[arr[i]];
            }

            fn.name = name;

            // to create class declaration
            fn.Class = function (name, baseCls, instanceProps, staticProps) {

                var cls = $.inherit(baseCls, instanceProps, staticProps);
                cls.__className = name;
                this[name] = cls;
                cls.name = this.name + ":" + name;
                classCount++;
                return cls;
            };

            packageCount++;

            return fn;
        }
    };

    /**
     *
     *
     * @method
     * @return  {Number}    package count
     */
    SVMX.getPackageCount = function () {
        return packageCount;
    };

    /**
     *
     *
     * @method
     * @return  {Number}    class count
     */
    SVMX.getClassCount = function () {
        return classCount;
    };

    SVMX.destroy =  function(inObject) {
    	if (inObject && typeof inObject == "object") {
    	    SVMX.forEachProperty(inObject, function(inKey) {
    	   	   delete inObject[inKey];
    	    });
    	    inObject.isDestroyed = true;
    	}
    };

    SVMX.delayedDestroy =  function(inObject) {
    	window.setTimeout(function() {
    	    SVMX.destroy(inObject);
    	}, 1000);
    };

    /**
     *
     *
     * @method
     * @param   {String}    str
     * @param   {String}    suffix
     *
     * @return  {Boolean} Defaults to returning true
     */
    SVMX.stringEndsWith = function (str, suffix) {
        var ret = false;
        if (str && str.length > 0) {
            ret = (str.indexOf(suffix, str.length - suffix.length) !== -1);
        }
        return ret;
    };

    SVMX.string = {};
    SVMX.string.capitalize = function (str) {
        return str[0].toUpperCase() + str.substring(1);
    };

    SVMX.string.camelCase = function (str) {
        return str.replace(/_[a-zA-Z]/g, function (inStr) {
            return inStr.substring(1).toUpperCase();
        });
    };

    // "Showing message {{current}} of {{total}}"
    SVMX.string.substitute = function (inString, inObject) {
        if (!inObject) inObject = {};
        return String(inString).replace(/\{\{.*?\}\}/g, function (inTerm) {
            inTerm = inTerm.substring(2, inTerm.length - 2);
            return inObject[inTerm] === undefined || inObject[inTerm] === null ? "" : inObject[inTerm];
        });
    };

    SVMX.forEachProperty = function (inObject, inFunc, inContext) {
        if (inContext) inFunc = SVMX.proxy(inContext, inFunc);
        for (key in inObject) {
            if (inObject.hasOwnProperty(key)) {
                inFunc(key, inObject[key]);
            }
        }
    };

    SVMX.isPlatform = function (plaformName) {
        var ret = true;
        try {
            ret = navigator.platform.slice(0, plaformName.length) == plaformName;
        } catch (e) {
            SVMX.getLoggingService().getLogger().error("Cannot detect the platform! " + e);
        }
        return ret;
    };

    SVMX.cloneObject = function (obj) {
        return SVMX.toObject(SVMX.toJSON(obj));
    };

    SVMX.write = function (content) {
        document.write(content);
    };

    SVMX.meta = function (name, content) {
        SVMX.write('<meta name="' + name + '" content="' + content + '">');
    };

    SVMX.getProfilingService = function () {
        return com.servicemax.client.lib.services.ProfilingService.getInstance();
    };

    SVMX.getLoggingService = function () {
        return com.servicemax.client.lib.services.LoggingService.getInstance();
    };

    SVMX.getClient = function () {
        return com.servicemax.client.lib.core.Client.getInstance();
    };

    SVMX.getCurrentApplication = function () {
        return com.servicemax.client.lib.api.AbstractApplication.currentApp;
    };

    var __GUID__ = 0;
    SVMX.generateGUID = function () {
        // TODO: need a better way to generate GUIDs.
        return ++__GUID__;
    };

    var __SVMX_CREATE_HELPERS__ = [];
    SVMX.registerCreateHelper = function (helper) {
        __SVMX_CREATE_HELPERS__.push(helper);
    };

    SVMX.getCreateHelper = function (fullClassName) {
        var i, l = __SVMX_CREATE_HELPERS__.length;
        for (i = 0; i < l; i++) {
            var helper = __SVMX_CREATE_HELPERS__[i];
            if (helper.canCreate(fullClassName)) {
                return helper;
            }
        }

        return null;
    };

    SVMX.getClass = function (className, failSilently) {
        try {
            var arr = className.split(".");
            var fn = window;
            for (var i = 0, len = arr.length; i < len; i++) {
                if (failSilently && !fn) return;
                fn = fn[arr[i]];
            }

            if (typeof fn !== "function" && !failSilently) {
                SVMX.getLoggingService().getLogger().error("Cannot find definition for class : " + className);
            }
            return fn;
        } catch (e) {
            if (!failSilently) {
                SVMX.getLoggingService().getLogger().error("Error while resolving class <" + className + "> :" + e);
                throw e;
            }
        }
    };

    SVMX.create = function () {
        var fullClassName = '';
        try {
            if (arguments.length < 1) return null; // TODO log error

            fullClassName = arguments[0];

            var helper = SVMX.getCreateHelper(fullClassName);
            if (helper != null) {
                return helper.doCreate.apply(helper, arguments);
            } else {
                var i, l = arguments.length,
                    argsStr = "";
                for (i = 1; i < l; i++) {
                    argsStr += "arguments[" + i + "],";
                }

                if (argsStr.length > 0)
                    argsStr = argsStr.substring(0, argsStr.length - 1);

                var cls = SVMX.getClass(fullClassName);
                var clsObj = eval("new cls(" + argsStr + ")");

                return clsObj;
            }
        } catch (e) {
            SVMX.getLoggingService().getLogger().error("Error while creating class <" + fullClassName + " > : " + e);
            throw e;
        }
    };


    /**
     *
     * @method
     * @params value
     * @returns Class name
     * @description
     * While we Could use javascript's typeof x == "object" to test a value, there are three problems:
     * 1. javascript says that typeof null == "object" which
     * is almost never a usable result.  null and undefined return "" which allows us to write:
     *
     *  if (SVMX.typeOf(x)) {
     *      ...
     *  }
     *
     * 2. typeof does not respect classes; an instance of Date is "object" but except for anonymous objects, its usually more useful to get back "date"
     * 3. typeof [5] is "object"; knowing that its an Array is usually a lot more useful.
     *
     * LIMITATIONS: This method must be enhanced if we add new object systems
     * NOTES: The value returned starts with Uppercase if its an object "Object", "Number" or lower case if its a literal "number".
     *
       typeOf({a: 4}); //"Object"
       toType([1, 2, 3]); //"Array"
       (function() {console.log(typeOf(arguments))})(); //arguments
       typeOf(new ReferenceError); //"Error"
       typeOf(new Date); //"Date"
       typeOf(/a-z/); //"RegExp"
       typeOf(Math); //"Math"
       typeOf(JSON); //"JSON"
       typeOf(4); // "number"
       typeOf(new Number(4)); //"Number"
       typeOf("abc"); // "string"
       typeOf(new String("abc")); //"String"
       typeOf(new Boolean(true)); //"boolean"
       typeof(document.body); // "HtmlBodyElement"
       typeof(new Ext.Button()) // "Ext.button.Button"
       typeof(SVMX.getCurrentApplication()); // "Application"
     *
     * @param       value           any type of value
     *
     * @return      {String}        the object or literal type as a string
     */
    SVMX.typeOf = function(value) {
        if (value === null) {
            return "";
        } else if (value === undefined) {
            return "";
        } else if (typeof value == "object") {
            if (value.getClassName) return value.getClassName();
            else return  ({}).toString.call(value).match(/\s([a-zA-Z]+)/)[1];
        } else {
            return typeof value;
        }
    };


    /**
     * @public
     * @method
     * @params value
     * @param {[string]} typeList
     * @returns boolean
     * @description
     * Use the SVMX.typeOf method to test if this value is one of a set of types
     *
     *  if (SVMX.isTypeOf(x, ["number", "string", "Date"])) {
     *      ...
     *  }
     *
     */
    SVMX.isTypeOf = function(value, typeList) {
        return SVMX.array.contains(typeList, function(oneType) {
            return SVMX.typeOf(value) === oneType;
        });
    };


    SVMX.isObject = function(value) {
        if (value === null || value === undefined) return false;
        return typeof value == "object";
    };

    /**
     * @public
     * @method
     * @param  {Object}            inScope         Object that will be "this" within the function
     * @param  {Function|String}   inFunction      A function or the name of a function that exists within inScope
     * @param  {[arg1,arg2,arg3]}  arguments       Zero or more arguments that will be passed in when the function is called
     *
     * @return {Function}     a function that when called will have inScope as the "this" object.
     *
     * @description
     * Calls jQuery.proxy which is documented at http://api.jquery.com/jQuery.proxy/ but changes the arguments
     * so that the arguments do not vary in order
     */
    SVMX.proxy = function () {
        var context = arguments[0];
        var func = arguments[1];
        if (typeof (func) !== "string") {
            var tmp = arguments[0];
            arguments[0] = arguments[1];
            arguments[1] = tmp;
        }
        return jQuery.proxy.apply(window, arguments);
    };

    // Move this into utils/timer.js when it becomes big enough
    SVMX.timer = {
        doLater: function (inFunc, inContext) {
            var f = inContext ? SVMX.proxy(inContext, inFunc) : inFunc;
            window.setTimeout(f, 1);
        },

        /* Invokation:
         * SVMX.timer.job("myTimer", 100, this, function() {...}); // function executes with this as context
         * SVMX.timer.job("myTimer", 50, function() {}); // cancels previous timer and runs function with window context
         */
        job: function (inName, inDelay, inJob1, inJob2) {
            var inJob;
            if (inJob1 && inJob2) {
                inJob = SVMX.proxy(inJob1, inJob2);
            } else if (inJob2) {
                inJob = inJob2;
            } else {
                inJob = inJob1;
            }
            SVMX.timer.cancelJob(inName);
            var job = function () {
                delete SVMX.timer._jobs[inName];
                inJob();
            }
            SVMX.timer._jobs[inName] = setTimeout(job, inDelay);
        },
        cancelJob: function (inName) {
            clearTimeout(SVMX.timer._jobs[inName]);
            delete SVMX.timer._jobs[inName];
        },
        hasJob: function (inName) {
            return Boolean(SVMX, timer._jobs[inName]);
        },
        _jobs: {}
    };
    SVMX.doLater = SVMX.timer.doLater; // shortcut

    SVMX.ajax = function (options) {
        return $.ajax(options);
    };

    SVMX.openInBrowserWindow = function (url) {
        window.open(url, "_blank");
    };

    SVMX.setWindowTitle = function (title) {
        window.document.title = title || "";
    };

    SVMX.reloadPage = function () {
        window.location.reload();
    };

    SVMX.navigateTo = function (url) {
        window.location.href = url;
    };

    SVMX.navigateTopTo = function(url) {
        top.location.href = url;
    };

    SVMX.getInnerWidth = function (){
    	var width = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
    	return width;
    };

    SVMX.onWindowResize = function (callback, context) {
    	var innerWidth =  SVMX.getInnerWidth();
        $(window).resize(function(evt) {
            var size = {
                height:window.innerHeight,
                width: innerWidth
            };
            SVMX.timer.job("windowResize", 50, function () {
                callback.call(context, size);
            });
        });
    };
    
    SVMX.getWindowInnerHeight = function(){
    	return window.innerHeight;
    };
    
    var bCachingEnabled = null;
    SVMX.isCachingEnabled = function () {

        if (bCachingEnabled === null) {
            var isEnabled = SVMX.getClient().getApplicationParameter("enable-cache");

            // configuration takes the highest precedence. if it is enabled in the configuration,
            // only then check is it is disabled/enabled via URL

            if (isEnabled != undefined && isEnabled != null && isEnabled === true) {
                isEnabled = SVMX.getUrlParameter("enable-cache");
                if (isEnabled != undefined && isEnabled != null && isEnabled === "false") {
                    isEnabled = false;
                } else {
                    isEnabled = true;
                }
            } else {
                isEnabled = false;
            }

            bCachingEnabled = isEnabled;
        }

        return bCachingEnabled;
    };

    var bLoggingEnabled = null;
    SVMX.isLoggingEnabled = function () {

        if (bLoggingEnabled === null) {
            var isEnabled = SVMX.getClient().getApplicationParameter("enable-log");

            // configuration takes the highest precedence. if it is enabled in the configuration,
            // only then check is it is disabled/enabled via URL

            if (isEnabled != undefined && isEnabled != null && isEnabled === true) {
                isEnabled = SVMX.getUrlParameter("enable-log");
                if (isEnabled != undefined && isEnabled != null && isEnabled === "false") {
                    isEnabled = false;
                } else {
                    isEnabled = true;
                }
            } else {
                isEnabled = false;
            }

            bLoggingEnabled = isEnabled;
        }

        return bLoggingEnabled;
    };

    var __SVMX_URL_PARAMS__ = null;
    SVMX.getUrlParameter = function (name) {
        if (__SVMX_URL_PARAMS__ == null) {
            __SVMX_URL_PARAMS__ = {};
            var Url = document.URL;
            var paramValues = Url.slice(Url.indexOf("?") + 1).split("&");

            for (var i = 0; i < paramValues.length; i++) {
                var val = paramValues[i].split("=");
                __SVMX_URL_PARAMS__[val[0]] = val[1];
            }
        }
        var ret = __SVMX_URL_PARAMS__[name];
        if (ret != null) {
            ret = decodeURIComponent(ret);

            // decodeURIComponent does not decode +!
            ret = ret.split("+").join(" ");
        }
        return ret;
    };

    SVMX.toJSON = function (data) {
        if (data) {
            return $.toJSON(data);
        }
        return null;
    };

    SVMX.stringToXML = function(data){
        if (data) {
            return $.parseXML(data);
        }
        return null;
    };

    // do not call with indent; just SVMX.prettyPrint(myObj)
    SVMX.prettyPrint = function (data, indent) {
        indent = indent || 0;

        function doIndent(indent) {
            return new Array(indent).join("    ");
        }
        var result = "";
        if ($.isArray(data)) {
            result += "[\n"
            for (var i = 0; i < data.length; i++) {
                result += doIndent(indent + 1) + i + ". " + SVMX.prettyPrint(data[i], indent + 1);
                if (i < data.length - 1) result += ",";
                result += "\n";
            }
            result += doIndent(indent) + "]"
        } else if (typeof data === "object" && data !== null) {
            result += "{\n";
            SVMX.forEachProperty(data, function (inKey, inValue) {
                result += doIndent(indent + 1) + inKey + ": " + SVMX.prettyPrint(inValue, indent + 1) + ",\n";
            });
            result += doIndent(indent) + "}";
        } else {
            result += data;
        }
        return result;
    };

    SVMX.dump = function (data) {
        console.log(SVMX.prettyPrint(data));
    };

    SVMX.toObject = function (data) {
        var ret = data;

        if (typeof (data) == 'string' && data.match(/^\s*\"|\'|\{|\[/)) {
            try {
                ret = $.secureEvalJSON(data);
            } catch (e) {
                SVMX.getLoggingService().getLogger().error("SVMX.toObject() failed! " + "length = " + data.length + " " + data.substring(0, 100) + " " + e);
            }
        }

        return ret;
    };

    SVMX.toggleClass = function (selector, cssClass) {
        $(selector).toggleClass(cssClass);
    };

    SVMX.sort = function (items, fieldOrFunc) {
        // right now, only field name is supported
        if (typeof (fieldOrFunc) != 'string') return;

        var i, l = items.length;

        if (l < 2) return items;

        for (i = 0; i < (l - 1);) {
            var k = 0;
            for (; k < (l - 1); k++) {
                if (items[k][fieldOrFunc] > items[k + 1][fieldOrFunc]) {
                    var temp = items[k];
                    items[k] = items[k + 1];
                    items[k + 1] = temp;
                }
            }
            l--;
        }
        return items;
    };

    ////////////////// jQuery.Deffered Utilities ////////////
    // Utility for turning an array of deferreds into a single
    // deferred that evaluates when all deferreds are complete
    SVMX.when = function (arrayOfDeferred) {
        var args = "";
        for (var i = 0; i < arrayOfDeferred.length; i++) {
            if (i > 0) args += ",";
            args += "arrayOfDeferred[" + i + "]"
        }
        return eval("$.when(" + args + ")");
    };

    SVMX.Deferred = null; // This is actually set in core.js, but is placed here so it will be documented as part of utils.js


    /**
     * @param {Object} inParams A hash of arguments
     * @param {[any]} inParams.data An array of data to process
     * @param {function} inParams.process A function that will be called on each item of data; must return AND resolve an SVMX.Deferred
     * @param {any} inParams.process.item The only input to your process is the next item of data from inParams.data
     * @param {function} [inParams.onSuccess] A function to call once All of your data has been processed and all Deferreds resolved
     * @param {function} [inParams.onError] A function to call if any of your Deferreds are rejected/fail.  This will be called each time a defered fails.
     * @param {boolean} inParams.onError.returns Return true to abort all further execution of your data; returns false/undefined to continue processing
     * @param {int} [inParallelProcessCount=1] The number of parallel threads of execution to allow; if greater than 1, will allow more than one item in inArray to be processed at a time.  Each in its own thread.
     *
     * executeUntilDone takes an array of data and a process to execute and will execute one item of data at a time, and only start processing the
     * next itme of data when previous item has been fully processed.  To allow for asynchronous completion of processing each item
     * of data, inProcess must return an SVMX.Deferred, and will resolve it when its finished.
     *
     *   SVMX.executeUntilDone({
     *      data: [1,3,5,7],
     *      inParallelProcessCount: 1
     *      process: function(item) {
     *          var d = new SVMX.Deferred();
     *          window.setTimeout(function() {
     *              alert(item);
     *              d.resolve();
     *          }, 1000);
     *          return d;
     *      },
     *      onSuccess: function() {
     *          alert("All values processed");
     *      },
     *      onError: function(e) {
     *          alert("Error processing value: " + e);
     *      }
     *   });
     *
     * @todo Need to have a way to aggregate results and feed them into the onSuccess handler. mydeferred.resolve(value) should
     *       be a valid way to accumulate results.
     */
    SVMX.executeUntilDone = function(inParams) {
        var mainDeferred = new $.Deferred();
        var dataToProcess = {};
        var abort = false;
        var executeUntilDone = function(inProcessName, inProcess) {
            if (abort) return;
            var item = dataToProcess[inProcessName].shift();
            if (item) {
                var d = inParams.process(item);
                d.done(function() {
                    executeUntilDone(inProcessName, inProcess);
                });
                d.fail(function(e) {
                    if (inParams.onError) abort = inParams.onError(e);
                    if (!abort) {
                        executeUntilDone(inProcessName, inProcess);
                    } else {
                        mainDeferred.fail(e);
                    }

                });
            } else {
                delete dataToProcess[inProcessName];
                var count = 0;
                SVMX.forEachProperty(dataToProcess, function(inKey,inValue) {count++;});
                if (count === 0 && inParams.onSuccess) {
                    inParams.onSuccess();
                    mainDeferred.resolve();
                }
            }
        };

        if (!inParams.inParallelProcessCount) inParams.inParallelProcessCount = 1;

        for (var i = 0; i < inParams.inParallelProcessCount; i++) {
            dataToProcess["process" + i] = [];
        }
        for (i = 0; i < inParams.data.length; i++) {
            dataToProcess["process" + (i % inParams.inParallelProcessCount)].push(inParams.data[i]);
        }

        var hasRun = false;
        for (i = 0; i < inParams.inParallelProcessCount; i++) {
            executeUntilDone("process" + i, inParams.inProcess);
            hasRun = true;
        }
        if (!hasRun) mainDeferred.resolve();
        return mainDeferred;
    };



    // Callback must return and resolve/fail a Deferred
    SVMX.__serializedTasks = [];
    SVMX.serializeTasks = function(task) {
        if (SVMX.__serializedTasks.length > 0) {
            SVMX.__serializedTasks.push(callback);
        } else {
            var d = callback();
            d.resolve(SVMX.__serializeNext);
        }
    };

    SVMX.__serializeNext = function() {
        if (SVMX.__serializeTasks.length == 0) return;
        var task = SVMX.__serializedTasks.pop();
        var d = task();
        d.resolve(SVMX.__serializeNext);
    };

    // !!!!!! DEPRECATED !!!!
    SVMX.loadCss = function (path) {

        $.ajax({
            type: 'GET',
            url: path,
            dataType: 'css',
            async: false,
            success: function () {},
            error: function (jqXhr, status, e) {}
        });

        if (document.createStyleSheet) {
            document.createStyleSheet(path);
        } else {
            $("head").append($("<link rel='stylesheet' href='" + path + "' type='text/css' media='screen' />"));
        }
    };

    SVMX.requireStyleSheet = function (url, callback, context, options) {
        if (!$.isArray(url)) {
            url = [url];
        }

        var counter = 0;
        var prefix = options.prefix ? options.prefix : "";
        $.each(url, function () {

            var head = document.getElementsByTagName('head')[0],
                link = document.createElement('link');
            link.setAttribute('href', prefix + this);
            link.setAttribute('rel', 'stylesheet');
            link.setAttribute('type', 'text/css');

            var sheet, cssRules, interval_id = 0,
                attempt = 0;
            if ('sheet' in link) {
                sheet = 'sheet';
                cssRules = 'cssRules';
            } else {
                sheet = 'styleSheet';
                cssRules = 'rules';
            }

            interval_id = setInterval(function () {
              SVMX.getLoggingService().getLogger().debug("requireStyleSheet::setInterval()");
                attempt++;
                if (attempt > 200) {

                    // could not load...
                    clearInterval(interval_id);
                    SVMX.getLoggingService().getLogger().debug("Timeout! clearing interval with id => " + interval_id);
                    head.removeChild(link);
                    if (++counter == url.length) {
                        callback.apply(context);
                    }
                } else {

                    try {
                        if (link[sheet] && link[sheet][cssRules].length) {

                            clearInterval(interval_id);
                            SVMX.getLoggingService().getLogger().debug("clearing interval with id => " + interval_id);
                            if (++counter == url.length) {
                                callback.apply(context);
                            }
                        }
                    } catch (e) {
                        // !!! Important to note that loading style sheets is the last call before the application starts
                        // any un-caught errors in the application may end up here.
                        SVMX.getLoggingService().getLogger().error("There was an error! =>" + e);
                    }
                }
            }, 100);

            head.appendChild(link);
        });
    };

    /**
     * Loads a script file and executes the proper callback depend on a success or error
     *
     * @method
     * @param   {String/Array}      url     overloaded to handle string or array of {name:"", location:""} object
     * @param   {Function}          callback
     * @param   {Function}          errback
     * @param   {Oject}             context
     * @param   {Oject}             options
     * @params  {Deferred}          defer
     */
    SVMX.requireScript = function (url, callback, errback, context, options, defer) {
        if (!$.isArray(url)) {
            url = [url];
        }

        if (url.length == 0) {
            return;
        }

        var loadVersion = SVMX.getClient().getLoadVersion();

        // some JS files have only one version. For example language files from ExtJS
        if (options && options.ignoreLoadVersion) {
            loadVersion = "debug";
        }

        if (loadVersion == "micro") url = ["__all__-min.js"];

        var counter = 0;
        var cache = SVMX.isCachingEnabled();

        $.each(url, function (idx, item) {
            var prefix = "";
            var async = (options.async != undefined) ? options.async : true;
            var scriptToLoad = "";

            //check the type first
            if (typeof item == "string") {
                prefix = options.prefix ? options.prefix : "";
                scriptToLoad = item;
            } else if (typeof item == "object") {
                prefix = item.location ? item.location : "";
                scriptToLoad = item.name;
            }

            if (loadVersion == "min") {
                scriptToLoad = scriptToLoad.substring(0, scriptToLoad.length - 3) + "-min.js";
            }

            $.ajax({
                cache: cache,
                type: 'GET',
                url: prefix + scriptToLoad,
                dataType: 'text',
                async: async,
                success: function (status, statusText, responses, responseHeaders) {
                    // sourceMap tells the debugger what path this code is associated with,
                    // letting users both open it in the debugger, and also (if used differently from below where I simplify the path)
                    // letting users go from minified code to source code
                    var code = responses.responseText + "\r\n//@ sourceURL=/" + String(prefix).replace(/^.*client\./,"") + scriptToLoad;
                    try {
                        jQuery.globalEval(code);
                    } catch(e) {
                        SVMX.getLoggingService().getLogger().error("Error compiling => " + prefix + scriptToLoad + " =>" + e);
                        if (errback) errback(new Error(scriptToLoad + " Failed to compile"));
                        return; // DO NOT CONTINUE LOADING FRAMEWORK
                    }
                    if (++counter == url.length) {
                        if (defer) {
                            defer.resolve();
                        }
                        callback.apply(context);
                    }
                },
                error: function (jqXhr, status, e) {
                    SVMX.getLoggingService().getLogger().error("Error while loading => " + prefix + scriptToLoad + " =>" + e);
                    if (defer) {
                        defer.reject(jqXhr);
                    }
                    if (errback) errback(new Error(scriptToLoad + " Failed to load"));
                    throw e;
                    //debugger;
                }
            });
        });
    };

    SVMX.requireTemplate = function (url, callback, context, options) {

        if (!$.isArray(url)) {
            url = [url];
        }

        var counter = 0;
        var prefix = options.prefix ? options.prefix : "";
        var templateList = [];

        $.each(url, function () {
            var async = (options.async != undefined) ? options.async : true;
            var name = this.toString();
            $.ajax({
                type: 'GET',
                url: prefix + this,
                dataType: 'text',
                async: async,
                success: function (data, status, jqXhr) {
                    templateList[templateList.length] = {
                        name: name,
                        data: data
                    };
                    if (++counter == url.length) {
                        callback.call(context, templateList);
                    }
                },
                error: function (jqXhr, status, e) {
                    // YUI Compressor cribs
                    //debugger;
                }
            });
        });
    };

    SVMX.getDisplayRootId = function () {

        // TODO : Could be in application definition??
        return "client_display_root";
    };

    var __allClientProperties = {};
    SVMX.getClientProperty = function (name) {
        return __allClientProperties[name];
    };

    SVMX.setClientProperty = function (name, value) {
        __allClientProperties[name] = value;
    };

    ////////////////// XML handling ////////////
    SVMX.toXML = function (data, rootElementName) {

        function format() {
            if (arguments.length == 0) return "";

            var formatted = arguments[0];

            for (var i = 1; i < arguments.length; i++) {
                var regexp = new RegExp('\\{' + (i - 1) + '\\}', 'gi');
                formatted = formatted.replace(regexp, arguments[i]);
            }
            return formatted;
        }

        function getElement(name, value) {
            var ret = "";
            if (value != null && value != undefined) {
                if (value instanceof Array) {
                    ret += getArrayElement(name, value);
                } else if (typeof (value) == 'object') {
                    ret += getObjectElement(name, value);
                } else {
                    ret += getSimpleElement(name, value);
                }
            }
            return ret;
        }

        function getArrayElement(name, value) {
            var ret = "",
                i, l = value.length,
                xml;
            for (var i = 0; i < l; i++) {
                var arrayItem = value[i];
                ret += getElement(name, arrayItem);
            }
            return ret;
        }

        function getSimpleElement(name, value) {
            // escape all the special characters
            if (value && typeof (value) == 'string') {
                value = value.split("&").join("&amp;");
                value = value.split("<").join("&lt;");
                value = value.split(">").join("&gt;");
                value = value.split('"').join("&quot;");
                value = value.split("'").join("&#39;");
            }
            // end escape special characters

            return format("<{0}>{1}</{0}>", name, value);
        }

        function getObjectElement(name, value) {
            var ret = "";
            for (var itemName in value) {
                var itemValue = value[itemName];
                ret += getElement(itemName, itemValue);
            }

            if (name)
                ret = format("<{0}>{1}</{0}>", name, ret);
            return ret;
        }

        if (typeof (data) == 'string') return data;

        var xml = getObjectElement(rootElementName, data);
        return xml;
    };

    SVMX.xmlToJson = function (xml) {
        var attr, child, attrs = xml.attributes,
            children = xml.childNodes,
            key = xml.nodeType,
            obj = {}, i = -1;

        if (key == 1 && attrs.length) {
            i = -1;
        } else if (key == 3) {
            obj = xml.nodeValue;
        }

        while (child = children.item(++i)) {
            key = child.nodeName;
            key = key.indexOf(":") != -1 ? key.split(":")[1] : key;

            if (obj.hasOwnProperty(key)) {
                if (obj.toString.call(obj[key]) != '[object Array]') {
                    obj[key] = [obj[key]];
                }
                obj[key].push(SVMX.xmlToJson(child));
            } else {
                obj[key] = SVMX.xmlToJson(child);
            }
        }

        // correct all text nodes
        for (var name in obj) {
            var objItem = obj[name];
            if (objItem && typeof (objItem) == 'object') {
                if (objItem.hasOwnProperty("#text")) {
                    obj[name] = objItem["#text"];

                    // also correct the boolean values
                    if (obj[name] === "false") obj[name] = false;
                    else if (obj[name] === "true") obj[name] = true;
                    // end boolean correction
                }
            }
        }
        // end correction

        return obj;
    };

    ////////////////// End - XML handling /////

    window["SVMX"] = SVMX;
})(jQuery);

// end of file