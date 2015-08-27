(function ($) {

    var libServices = SVMX.Package("com.servicemax.client.lib.services");

    /**
     *
     * @class           com.servicemax.client.lib.services.ProfilingService
     * @extends         com.servicemax.client.lib.api.EventDispatcher
     */
    libServices.Class("ProfilingService", com.servicemax.client.lib.api.EventDispatcher, {
        __performance: null,
        __timingHash: null,
        __serverEntries: null,
        __defaultEvents: null,
        __supportedBrowser: false,
        __constructor: function (type, target, data) {
                //checking the static reference
                if (libServices.ProfilingService.__instance != null)
                    return libServices.ProfilingService.__instance;

                // There should only be a single ProfilingService class; set this static property to insure that this instance is that one.
                libServices.ProfilingService.__instance = this;
                this.__base(type, target, data);

                this.__supportedBrowser = this.__checkBrowser();

                this.__performance = window.performance;
                this.__serverEntries = [];

                // make this a config later
                this.__defaultEvents = {
                    "REFRESH_CONTENT": true,
                    "DATA_UPDATED": true
                };
                this.__timingHash = {
                    "redirect": {
                        begin: "redirectStart",
                        end: "redirectEnd"
                    },
                    "cache": {
                        begin: "fetchStart",
                        end: "domainLookupStart"
                    },
                    "dns": {
                        begin: "domainLookupStart",
                        end: "domainLookupEnd"
                    },
                    "tcp": {
                        begin: "connectStart",
                        end: "connectEnd"
                    },
                    "request": {
                        begin: "requestStart",
                        end: "responseEnd"
                    },
                    "response": {
                        begin: "responseStart",
                        end: "responseEnd"
                    },
                    "unload": {
                        begin: "unloadStart",
                        end: "unloadEnd"
                    },
                    "dom": {
                        begin: "domLoading",
                        end: "domComplete"
                    },
                    "content": {
                        begin: "domContentLoadedEventStart",
                        end: "domContentLoadedEventEnd"
                    },
                    "load" : {
                        begin: "loadEventStart",
                        end: "loadEventEnd"
                    },
                    "total" : {
                        begin: "navigationStart",
                        end: "loadEventEnd"
                    }
                };
        },

        /**
         * Check if on a supported browser
         * @returns {boolean}
         * @private
         */
        __checkBrowser: function() {
            var acceptable = false;
            //We will check inclusion rather than exclusion since it is a smaller set
            var browser = this.__getBrowser().toLowerCase();
            var version = this.__getBrowserVersion().toLowerCase();

            switch(browser) {
                case 'chrome':
                    acceptable = true;
                    break;
                case 'firefox':
                    acceptable = true;
                    break;
                case 'ie':
                    if (!isNaN(version) && version != "") {
                        version = parseInt(version);
                        acceptable = (version > 8);
                    }
                    break;
            }

            return acceptable;
        },


        /**
         * Check browser type
         * @returns {String}
         * @private
         */
        __getBrowser: function(){
            var ua=navigator.userAgent,tem,M=ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];
            if(/trident/i.test(M[1])){
                tem=/\brv[ :]+(\d+)/g.exec(ua) || [];
                //return 'IE '+(tem[1]||'');
                return 'IE'; //We do not care about the version
            }
            if(M[1]==='Chrome'){
                tem=ua.match(/\bOPR\/(\d+)/)
                if(tem!=null)   {
                    return 'Opera '+tem[1];
                }
            }

            M=M[2]? [M[1], M[2]]: [navigator.appName, navigator.appVersion, '-?'];

            if((tem=ua.match(/version\/(\d+)/i))!=null) {
                M.splice(1,1,tem[1]);
            }

            return M[0];
        },

        /**
         * Check the browser version
         * @returns {String}
         * @private
         */
        __getBrowserVersion: function(){
            var ua=navigator.userAgent,tem,M=ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];
            if(/trident/i.test(M[1])){
                tem=/\brv[ :]+(\d+)/g.exec(ua) || [];
                //return 'IE ' + (tem[1] || '');
                return (tem[1] || '0'); //We do not care about older versions
            }
            if(M[1]==='Chrome'){
                tem=ua.match(/\bOPR\/(\d+)/)
                if(tem!=null)   {
                    return 'Opera '+tem[1];
                }
            }

            M=M[2]? [M[1], M[2]]: [navigator.appName, navigator.appVersion, '-?'];

            if((tem=ua.match(/version\/(\d+)/i))!=null) {
                M.splice(1,1,tem[1]);
            }

            return M[1];
        },

        /**
         * Decodes the key type the index
         * @param idx
         * @returns {*}
         * @private
         */
        __findEntryKeyType: function(idx){
            idx = idx || 0;
            var keys = ["PerformanceMeasure", "PerformanceEntry"];
            var type = this.__findEntryTypeKeyByName(keys[idx]);

            if (type.length > 0){
                return type
            }

            return this.__findEntryKeyType(++idx);
        },

        /**
         *
         * @param key
         * @param idx
         * @returns {Array}
         * @private
         */
        __getMeasureDataBy: function(key, idx){
            var results = [];
            var type = this.__findEntryKeyType();
            var entries = this.getEntriesByType(type);
            var item = null;
            var val = "";

            for (var i = 0; i<entries.length; i++){
                item = entries[i].name.split("_");
                if (item.length > 0) {
                    val = item[idx];

                    if (idx > 1) {
                        item.shift();
                        item.shift();
                        val = item.join("_");
                    }

                    if (idx == -1) {
                        val = item[0] + "_" + item[1];
                    }

                    if (val == key) {
                        results.push(entries[i]);
                    }
                }
            }

            return results;
        },

        /**
         *
         * @param results
         * @param obj
         * @returns {boolean}
         * @private
         */
        __isEntryTypeObject: function(results, obj) {
            for (var i=0; i<results.length; i++){
                if ((results[i].action == obj.action) && (results[i].type == obj.type)){
                    return true;
                }
            }
            return false;
        },

        /**
         *
         * @param results
         * @param val
         * @returns {boolean}
         * @private
         */
        __isEntryTypes: function(results, val) {
            for (var i=0; i<results.length;i++){
                if (results[i].name == val){
                    return true;
                }
            }
            return false;
        },

        /**
         *
         * @param key
         * @returns {*}
         * @private
         */
        __findEntryTypeKeyByName: function(key) {
            var types = this.getEntryTypes();
            for (var i=0;i< types.length; i++) {
                if (types[i].name == key) {
                    return types[i].entry;
                }
            }
            return "";
        },

        /**
         *
         * @param name
         * @returns {*}
         * @private
         */
        __parseMeasurementName: function(name) {
            var tmpArray = name.split("_");
            //validate structure
            if (tmpArray.length != 3) {
                return {};
            }

            var action = tmpArray[0];
            var type = tmpArray[1];
            var name = tmpArray[2];

            if (tmpArray.length > 3){
                tmpArray.shift();
                tmpArray.shift();
                name = tmpArray.join("_");
            }

            return {
                action: action,
                type: type,
                name: name
            };
        },

        /**
         *
         * @param key
         * @param val
         * @returns {Array}
         * @private
         */
        __getServerEntriesBy: function(key, val){
            var validCheck = {
                reqtype: true,
                entryType: true,
                name: true,
                description: true,
                endtime: true,
                begintime: true
            };

            var results = [];

            if (!validCheck[key]) {
                return results;
            }

            var list = this.__serverEntries;
            for (var i=0; i < list.length; i++) {
                var item = list[i];
                if (val == item[key]) {
                    results.push(item);
                }
            }

            return results;
        },

        /**
         *
         * @param type
         * @param context
         * @param handlerObj
         */
        raiseEvent: function(type, context, handlerObj) {
            if (this.__defaultEvents[type]) {
                var className = "com.servicemax.client.lib.api.Event";
                var lcontext = context || undefined;
                var lhandler = handlerObj || {request:{},responder:{}};
                var evt = SVMX.create(className, type, lcontext, lhandler);

                this.triggerEvent(evt);
            }
        },

        /**
         *
         * @returns {null}
         */
        getDefaultEvents : function() {
            return this.__defaultEvents;
        },

        /**
         *
         * @returns {null}
         */
        getTimingOptions: function() {
            return this.__timingHash;
        },

        /**
         *
         * @returns {null}
         */
        getNativeProfiler: function() {
            return this.__performance;
        },

        /**
         *
         * @returns {null}
         */
        getNativeProfiler: function() {
            return this.__performance;
        },

        /**
         *
         * @returns {Array}
         */
        getEntryTypes: function(){
            var results = [];
            var entries = this.getEntries();
            var i = 0;
            var type = null;

            for (;i<entries.length;i++){
                if (i == 0) {
                    type = {
                        name: SVMX.typeOf(entries[i]),
                        entry: entries[i].entryType
                    }
                    results.push(type);
                }else{
                    type = {
                        name: SVMX.typeOf(entries[i]),
                        entry: entries[i].entryType
                    }

                    if (!this.__isEntryTypes(results, type.name)){
                        results.push(type);
                    }
                }
            }

            return results;
        },

        /**
         *
         */
        getMeasureEntryTypes: function(){
            var results = [];
            var type = this.__findEntryKeyType();
            var entries = this.getEntriesByType(type);
            var nameObject = null;

            for (var i = 0; i<entries.length; i++){
                nameObject = this.__parseMeasurementName(entries[i].name);
                if (!nameObject.name){
                    continue;
                }

                delete nameObject.name;
                if (i == 0) {
                    results.push(nameObject);
                }else{
                    if (!this.__isEntryTypeObject(results, nameObject)){
                        results.push(nameObject);
                    }
                }
            }

            return results;
        },

        getMeasureDataByType: function(type){
            return this.__getMeasureDataBy(type, 1);
        },

        getMeasureDataByAction: function(action){
            return this.__getMeasureDataBy(action, 0);
        },

        getMeasureDataByName: function(name){
            return this.__getMeasureDataBy(name, 2);
        },

        getMeasureDataByText: function(text){
            return this.__getMeasureDataBy(text, -1);
        },

        /**
         * Gets the time differences for all of the timing intervals
         *
         * @returns {Array}
         */
        getTimes: function() {
            var results = [];
            var hash = this.__timingHash;
            var timing = this.__performance.timing;

            for (var idx in hash) {
                var timeObj = {};
                var item =  hash[idx];
                var diff =  timing[item.end] - timing[item.begin];

                timeObj["name"] = idx;
                timeObj["duration"] =  diff;

                results.push(timeObj);
            }

            return results;
        },

        /**
         * Gets the time difference by the timing name
         *
         * @param type
         * @returns {number}
         */
        getTimesByType: function(type) {
            var request = this.__timingHash[type];
            if (!request){
                return 0;
            }

            var timing = this.__performance.timing;
            var diff =  timing[request.end] - timing[request.begin];

            return (diff < 0)? 0: diff;
        },

        /**
         * Gets the performance entries as a collection
         *
         * @returns {*|PerformanceEntry[]}
         */
        getEntries: function() {
            var results = [];
            results = $.merge($.merge(results, this.__performance.getEntries()), this.__serverEntries);
            return results;
        },

        /**
         * Gets the performance entries as a collection by name
         *
         * @param name
         * @returns {*|PerformanceEntry[]}
         */
        getEntriesByName: function(name) {
            var results = this.__getServerEntriesBy("name", name);
            $.merge(results, this.__performance.getEntriesByName(name));
            return results;
        },

        /**
         * Gets the performance entries as a collection by type
         *
         * @param type
         * @returns {*|PerformanceEntry[]}
         */
        getEntriesByType: function(type) {
            //reqtype
            var results = this.__getServerEntriesBy("entryType", type);;
            $.merge(results, this.__performance.getEntriesByType(type));
            return results;
        },

        /**
         * Gets the performance measurements entries as a collection by name
         *
         * @param name
         * @returns {Array}
         */
        getMeasurementByName: function(name) {
            //name = name.replace(/\./g, "_");

            var measurements = this.getEntriesByType("measure");
            var results = [];
            var i = 0;
            for (; i<measurements.length; i++) {
                if (measurements[i].name === name) {
                    results.push(measurements[i]);
                }
            }
            return results;
        },
        /**
         * Wrapper to begin a mark
         *
         * @param name
         * @param type
         * @param action
         * @returns {*}
         */
        begin : function(name, type, action) {
            //this is required
            if (!name) {
                return false;
            }
            //validate
            if (SVMX.typeOf(name) != "string") {
                return false;
            }

            action = (SVMX.typeOf(action) != "string") ? "nonspecAction" : action;
            type = (SVMX.typeOf(type) != "string") ? "nonspecType" : type;
            var marker =  [action, type, name].join("_");

            return this.mark(marker, "begin");
        },

        /**
         * Wrapper to end a mark, measure, and clear the mark
         *
         * @param name
         * @param type
         * @param action
         * @returns {*}
         */
        end : function(name, type, action) {
            //this is required
            if (!name) {
                return false;
            }
            //validate
            if (SVMX.typeOf(name) != "string") {
                return false;
            }
            action = (SVMX.typeOf(action) != "string") ? "nonspecAction" : action;
            type = (SVMX.typeOf(type) != "string") ? "nonspecType" : type;
            var marker =  [action, type, name].join("_");

            //check if there was a begin first
            if (this.getEntriesByName(marker + "_begin").length > 0) {
                return this.mark(marker, "end", true, true);
            }
            return this;
        },
        /**
         * Create a marker entry in the performance collection
         *
         * @param (String) name
         * @param (String) type     {optional}
         * @param (Boolean) measure  {optional}
         * @param (Boolean) clear {optional}
         * @returns {*}
         */
        mark: function(name, type, measure, clear){
            //name = name.replace(/\./g, "_");
            var validType = {
                begin: "begin",
                end: "end"
            };
            //1 end marker
            var val = !!validType[type] ? (name + "_" + validType[type]) : name;
            this.__performance.mark(val);

            //2 calculate the interval
            if (!!measure) {
                this.measure(name);
            }

            //3 clear marks
            if (!!clear) {
                this.clearMarks(name);
            }
            return this;
        },

        /**
         * Create a measurement entry in the performance collection.
         * Takes the mark name and defaults to begin and end times for the diff
         * if either begin or end marks are provided it'll use that
         *
         * @param name
         * @param begin
         * @param end
         * @returns {*}
         */
        measure: function(name, begin, end){
            /*
            name = name.replace(/\./g, "_");
            begin = begin.replace(/\./g, "_");
            end = end.replace(/\./g, "_");
            */

            var vbegin = !!begin ? begin: name + "_begin";
            var vend = !!end ? end: name + "_end";

            this.__performance.measure(name, vbegin, vend);

            //return this.__performance.getEntriesByName(name);

            return this;
        },

        /**
         * Clears the mark set by name or all marks from the performance collection
         * set: mark name plus begin & end times
         *
         * @param name {optional}
         * @returns {*}
         */
        clearMarks: function(name){
            //name = name.replace(/\./g, "_");
            this.__performance.clearMarks(name);

            //only if there is a name
            if (!!name) {
                var vbegin = name + "_begin";
                var vend = name + "_end";

                this.__performance.clearMarks(vbegin);
                this.__performance.clearMarks(vend);
            }

            return this;
        },

        /**
         * Clears the measure by name or all measurements from the performance collection
         *
         * @param name
         * @returns {*}
         */
        clearMeasure: function(name){
            //name = name.replace(/\./g, "_");

            this.__performance.clearMeasure(name);

            return this;
        },

        exportToFile: function(){

        },

        addServerEntry: function(entry) {
            //check the entry
            if (SVMX.typeOf(entry) == "Object" && this.__supportedBrowser) {
                var validCheck = {
                    reqtype: true,
                    name: true,
                    description: true,
                    endtime: true,
                    begintime: true
                };

                for(var idx in entry){
                    if (!validCheck[idx]) {
                        return false;
                    }
                }

                //add
                this.__serverEntries.push(this.__processServerEntryData(entry));
            }
        },

        __processServerEntryData: function(entry){
            var item = {
                rawdata: entry
            };
            var fieldSwap = {
                reqtype: "entryType",
                name: "name",
                begintime: "startTime"
            };
            var str = "";

            for(var idx in entry){
                if (!!fieldSwap[idx]) {
                    key = fieldSwap[idx];
                    str = entry[idx];
                    if (idx == "reqtype") {
                        str = str.toLowerCase();
                    }
                    item[key] = str;
                }
            }

            var end = this.__convertToDateTimeObject(entry.endtime);
            var begin = this.__convertToDateTimeObject(entry.begintime);

            item["duration"] = Math.abs(end - begin);
            item["startTime"] = begin.getTime() - performance.timing.navigationStart;
            return item;
        },

        __convertToDateTimeObject: function(dtime){
            var dt = this.__extractDateTime(dtime);
            return new Date(dt.Y, dt.M, dt.D, dt.hh, dt.mm, dt.ss, dt.ms);
        },

        __extractDateTime: function(dtime){
            var dateTime = dtime.split("T");
            var result = {
                date: dateTime[0],
                time: dateTime[1]
            }

            $.extend(result, this.__extractDate(result.date), this.__extractTime(result.time));

            return result;
        },

        __extractDate: function(day){
            var val = day.split("-");

            return {
                Y: (val[0] * 1),
                M: (val[1] * 1),
                D: (val[2] * 1)
            };
        },

        __extractTime: function(time){
            //There are cases when it is ': '
            var val = time.split(": ");
            if (val.length == 1) {
                val = time.split(":");
            }
            var sub = val[2].split(".");

            return {
                hh: (val[0] * 1),
                mm: (val[1] * 1),
                ss: (sub[0] * 1),
                ms: (sub[1].substr(0, sub[1].length-1) * 1)
            };
        },

        clearServerEntries: function() {
            this.__serverEntries.length = 0;
            //libServices.ProfilingService.__entries = [];
        }

    }, {
        __instance: null,
        //__entries: [],

        /**
         *
         * @returns {*}
         */
        getInstance: function() {
            var ret = null;

            if (libServices.ProfilingService.__instance == null) {
                ret = new libServices.ProfilingService();
            } else {
                ret = libServices.ProfilingService.__instance;
            }

            return ret;
        }
        /*
        addEntry: function (marker) {
            libServices.ProfilingService.__entries.push(marker);
        },
        clearManualEntries: function() {
            libServices.ProfilingService.__entries = [];
        }*/
    });

    ////////////////////////////////// LOGGING /////////////////////////////

    /**
     * The central logging service.  Note that logTargetSettings are not available while loading modules; they only become available once Client.__run is called.
     *
     * @class           com.servicemax.client.lib.services.LoggingService
     * @extends         com.servicemax.client.lib.api.Object
     *
     */
    libServices.Class("LoggingService", com.servicemax.client.lib.api.Object, {
        __loggers: null,
        __uncreatedLoggers: null,
        __logTargetSettings: null,

        __constructor: function () {
            if (libServices.LoggingService.__instance != null)
                return libServices.LoggingService.__instance;

        // There should only be a single LoggingService class; set this static property to insure that this instance is that one.
            libServices.LoggingService.__instance = this;

            // no special characters allowed for the logger source
            this.__loggers = {};
        },

        setTargetSettings: function(targetSettings) {
            libServices.LoggingService.clearTargets();
            this.generateLogTargets(targetSettings.targets);

            var settings;
            this.__logTargetSettings = targetSettings.loggers;
            for (var source in this.__loggers) {
                var targetSettings = this.getLoggerSettings(source);
                this.__loggers[source].setTargetSettings(targetSettings);
            }
        },

        generateMissingLogTargets : function(targets) {
            if (this.__uncreatedLoggers) this.generateLogTargets(this.__uncreatedLoggers);
        },

        generateLogTargets: function(targets) {
            this.__uncreatedLoggers = {};
            var hasError = false;
            var sTargets = libServices.LoggingService.__targets;
            SVMX.forEachProperty(targets, function(targetName, targetDef) {
                if (!SVMX.array.contains(this.__targets, function(target) {
                    return target.targetName == targetName;
                })) {
                    var className = targetDef["class-name"];
                    var cls = SVMX.getClass(className, true);
                    if (!cls) {
                        this.__uncreatedLoggers[targetName] = targetDef;
                        hasError = true;
                    } else {
                        targetDef.options.targetName = targetName;
                        SVMX.create(className, targetDef.options);
                    }
                }
            }, this);
            if (!hasError) this.__uncreatedLoggers = null;
        },


        // Settings for this source take precedence
        // settings for DEFAULT take secondary precedence
        // "BrowserConsoleLogTarget": "DEBUG" is the default if no other setting is provided for BrowserConsoleLogTarget
            getLoggerSettings: function(source) {
                if (this.__logTargetSettings) {
                    return $.extend({}, this.__logTargetSettings.DEFAULT || {}, this.__logTargetSettings[source] || {});
                } else {
                    var targets = this.getTargets();
                    var result = {};
                    for (var i = 0; i < targets.length; i++) {
                        result[targets[i].targetName] = targets[i].defaultLogLevel;
                    }
                    return result;
                }
            },

        // Find or create the named Logger
            getLogger: function(source) {
                var ret = null;

                if (source == undefined || source == null) source = "SVMXCONSOLECORE";

                if (this.__loggers[source] == undefined) {
                    var targetSettings = this.getLoggerSettings(source);
                    ret = new libServices.Logger(this, source, targetSettings);
                    this.__loggers[source] = ret;
                } else {
                    ret = this.__loggers[source];
                }
                return ret;
            },


            getTargets: function(optionalTargetNames) {
                var ret = [];
                var targets = libServices.LoggingService.__targets;
                if (optionalTargetNames) {
                    for (var i = 0; i < targets.length; i++) {
                        if (optionalTargetNames[targets[i].targetName]) {
                            ret.push(targets[i]);
                        }
                    }
                } else {
                    for (var i = 0; i < targets.length; i++) {
                        if (targets[i].isDefaultTarget) {
                            ret.push(targets[i]);
                        }
                    }
                }
                return ret;
            }

        }, {
            __targets: [],
            __instance: null,
            getInstance: function (optionalLogSettings) {
                var ret = null;
                if (libServices.LoggingService.__instance == null) {
                    ret = new libServices.LoggingService(optionalLogSettings);
                } else {
                    ret = libServices.LoggingService.__instance;
                }
                return ret;
            },

            // Register a new log target
            registerTarget: function (target, options) {
                // Do not allow multiple log targets of the same name; only allow the last one created to exist
                SVMX.array.remove(libServices.LoggingService.__targets, function(tmptarget) {return target.targetName == tmptarget.targetName;}, true);

                libServices.LoggingService.__targets.push(target);
                SVMX.timer.job("generateMissingLogTargets", 10, function() {
                    libServices.LoggingService.getInstance().generateMissingLogTargets();
                });
            },
            clearTargets: function() {
                libServices.LoggingService.__targets = [];
            }
        }
    );


    /**
     * Log target API
     *
     * @class           com.servicemax.client.lib.services.AbstractLogTarget
     * @extends         com.servicemax.client.lib.api.Object
     *
     * @param   {Object}    options
     *
     */
    libServices.Class("AbstractLogTarget", com.servicemax.client.lib.api.Object, {
        /**
         * @property {string}
         * Name of the log target, "Browser", "Database", etc...
         * If svmx-logging-preferences is in use then all targetNames come from that setting.
         * Otherwise, target names can be assigned as part of the subclass definition.
         * The target name simply identifies this logger instance.
         */
        targetName: "",

        /**
         * @property {boolean}
         * If true, then this logging target will be used to log if there is no svmx-logging-preferences setting
         * ANY use of svmx-logging-preferences will cause those settings and not this property to determine who
         * logs what.
         */
        isDefaultTarget: false,

        /**
         * @property {string}
         * One of ERROR, DEBUG, INFO, WARNING or NONE.
         * This value is only used if isDefaultTarget is true AND there is no svmx-logging-preferences setting.
         * Indicates the log level that will be logged.
         */
        defaultLogLevel: "ERROR",
        __constructor: function (options) {
            if (!options) options = {};
            this.targetName = options.targetName;

            // register with the logging service
            libServices.LoggingService.registerTarget(this);
        },

        log: function (message, options) {}

    }, {});


    /**
     * Default logging target. Logs to the browser console.
     *
     * @class           com.servicemax.client.lib.services.BrowserConsoleLogTarget
     * @extends         com.servicemax.client.lib.services.AbstractLogTarget
     *
     */
    libServices.Class("BrowserConsoleLogTarget", libServices.AbstractLogTarget, {
        isDefaultTarget: true,
        defaultLogLevel: "DEBUG",

        __constructor: function (options) {
            if (!options) options = {targetName: "Browser"};
            this.__base(options);
        },

        log: function (message, options) {
            var console = window.console;
            if (!console) return;

            var type = options.type;

            if (message instanceof Error) {
                message = message.stack ? message.stack.toString() : message.toString();
            }

            var msg = options.timeStamp + ": " + options.source + " " + message;

            if (type == "INFO" || type == "CRITICAL") console.info(msg);
            else if (type == "ERROR") console.error(msg);
            else if (type == "WARNING") console.warn(msg);
            else if (type == "DEBUG") {
                if (console.debug) {
                    console.debug(msg);
                } else {
                    console.info("DEBUG=>INFO " + msg);
                }
            } else console.log(msg);
        }
    }, {});

    // As this is our Default Log Target until svmx-logging-preferences has specified otherwise, we need to create an instance of it.
    // Normally, Log Targets are created by the svmx-logging-preferences settings.
    new libServices.BrowserConsoleLogTarget({targetName: "Browser"});



    /**
     * The AlertLogTarget will present logged messages in the form of an obnoxious alert dialog.
     * Useful for really glaring errors that you want to be notified of without having to insert
     * alert code that might get checked in and irritate the rest of the developers (and perhaps users).
     * This log target was primarily added as an easy way of testing the Logging Targets, and
     * is not expected to receive much use.
     *
     * @class           com.servicemax.client.lib.services.AlertLogTarget
     * @extends         com.servicemax.client.lib.services.AbstractLogTarget
     *
     */
    libServices.Class("AlertLogTarget", libServices.AbstractLogTarget, {

        __constructor: function (options) {
            this.__base(options);
        },

        log: function (message, options) {
            var console = window.console;
            if (!console) return;

            var type = options.type;

            if (message instanceof Error) {
                message = message.stack ? message.stack.toString() : message.toString();
            }

            var msg = options.timeStamp + ": " + options.source + " " + message;
        alert(type + ": "+ msg);
        }

    }, {});



    /**
     * The logger API;
     *
     * This Logger class is really a Log Dispatcher that routes messages to the proper AbstractLogTarget subclass
     *
     * @class           com.servicemax.client.lib.services.Logger
     * @extends         com.servicemax.client.lib.api.Object
     *
     */
    libServices.Class("Logger", com.servicemax.client.lib.api.Object, {

    // LoggingService instance
        __parent: null,

    // Name of this logger "sfm-expressions"
        __source: "",

    // {targetName1: "ERROR", targetName2: "INFO", etc...}
    __targetSettings: null,

        __constructor: function (parent, source, targetSettings) {
            this.__parent = parent;
            this.__source = source;
        this.setTargetSettings(targetSettings);
        },

    /**
     * This method is currently called from core.js's run method, and is not expected to be
     * called from any other external point.
     *
     * @param {Object} A hash of settings: {targetName1: "ERROR", targetName2: "INFO", etc...}
     */
    setTargetSettings: function(targetSettings) {
        this.__targetSettings = targetSettings;
    },

        __shouldSkipLogging: function (type, target) {
            var ret = false,
                preferenceMap = {
                    "DEBUG": 5,
                    "INFO": 4,
                    "WARNING": 3,
                    "ERROR": 2,
            "CRITICAL": 1,
            "NONE": 0
                };
        var targetSetting = this.__targetSettings[target];
        if (!targetSetting) return true;

        var targetLevel = preferenceMap[targetSetting];
        var requestLevel = preferenceMap[type];

            if (targetLevel < requestLevel) {
                ret = true;
            }

            return ret;
        },

        getTimestamp: function () {
            return com.servicemax.client.lib.datetimeutils ? com.servicemax.client.lib.datetimeutils.DatetimeUtil.macroDrivenDatetime("Now") : new Date().toString();
        },

    /**
     * Logs the specified message at the "info" log level
     */
        info: function (message) {
            var t = this.__parent.getTargets(this.__targetSettings),
                stringObj = this.getTimestamp();

            for (var i = 0; i < t.length; i++) {
        if (!this.__shouldSkipLogging("INFO", t[i].targetName)) {
                    t[i].log(message, {
            type: "INFO",
            source: this.__source,
            timeStamp: stringObj
                    });
        }
            }
        },

    /**
     * Logs the specified message at the "debug" log level
     */
        debug: function (message) {
            var t = this.__parent.getTargets(this.__targetSettings),
                stringObj = this.getTimestamp();

            for (var i = 0; i < t.length; i++) {
        if (!this.__shouldSkipLogging("DEBUG", t[i].targetName)) {
                    t[i].log(message, {
            type: "DEBUG",
            source: this.__source,
            timeStamp: stringObj
                    });
        }
            }
        },

    /**
     * Logs the specified message at the "error" log level
     */
        error: function (message) {
            var t = this.__parent.getTargets(this.__targetSettings),
                stringObj = this.getTimestamp();

            for (var i = 0; i < t.length; i++) {
        if (!this.__shouldSkipLogging("ERROR", t[i].targetName)) {
                    t[i].log(message, {
            type: "ERROR",
            source: this.__source,
            timeStamp: stringObj
                    });
        }
            }
        },

    /**
     * Logs the specified message at the "warning" log level
     */
        warning: function (message) {
            var t = this.__parent.getTargets(this.__targetSettings),
                stringObj = this.getTimestamp();

            for (var i = 0; i < t.length; i++) {
        if (!this.__shouldSkipLogging("WARNING", t[i].targetName)) {
                    t[i].log(message, {
            type: "WARNING",
            source: this.__source,
            timeStamp: stringObj
                    });
        }
            }
        },

    /**
     * Same as warning
     */
        warn: function (message) {
            this.warning(message);
        },

    /**
     * Logs the specified message at the "critical" log level (not sure how well supported this is, and does not appear to get much use)
     */
        critical: function (message) {
            var t = this.__parent.getTargets(this.__targetSettings),
                stringObj = this.getTimestamp();

            for (var i = 0; i < t.length; i++) {
        if (!this.__shouldSkipLogging("CRITICAL", t[i].targetName)) {
                    t[i].log(message, {
            type: "CRITICAL",
            source: this.__source,
            timeStamp: stringObj
                    });
        }
            }
        }

    }, {});

    ////////////////////////////////// END - LOGGING /////////////////////////////

    ////////////////////////////////// RESOURCE LOADING //////////////////////////

    /**
     *
     * @class           com.servicemax.client.lib.services.ResourceLoaderEvent
     * @extends         com.servicemax.client.lib.api.Event
     */
    libServices.Class("ResourceLoaderEvent", com.servicemax.client.lib.api.Event, {
        __constructor: function (type, target, data) {
            this.__base(type, target, data);
        }
    }, {});

    /**
     *
     * @class           com.servicemax.client.lib.services.ResourceLoader
     * @extends         com.servicemax.client.lib.api.EventDispatcher
     *
     * @note
     * Supported events
     *<br> 01. LOAD_COMPLETE
     *<br> 02. LOAD_ERROR
     */
    libServices.Class("ResourceLoader", com.servicemax.client.lib.api.EventDispatcher, {

        __constructor: function () {
            this.__base();
        },

        loadAsync: function (options) {
            return $.ajax({
                type: "GET",
                dataType: options.responseType,
                data: options.data,
                cache: options.cache,
                url: options.url,
                context: this,
                async: true,
                success: function (data, status, jqXhr) {
                    this._loadSuccess(data, status);
                },
                error: function (jqXhr, status, e) {
                    this._loadError(jqXhr, status, e);
                }
            });
        },

        _loadSuccess: function (data, status) {
            var rle = new libServices.ResourceLoaderEvent("LOAD_COMPLETE", this, data);
            this.triggerEvent(rle);
        },

        _loadError: function (jqXhr, status, e) {
            var rle = new libServices.ResourceLoaderEvent("LOAD_ERROR", this);
            this.triggerEvent(rle);
        }
    }, {});

    /**
     *
     * @class           com.servicemax.client.lib.services.ResourceLoaderService
     * @extends         com.servicemax.client.lib.api.Object
     *
     */
    libServices.Class("ResourceLoaderService", com.servicemax.client.lib.api.Object, {

        __constructor: function () {
            if (libServices.ResourceLoaderService.__instance != null)
                return libServices.ResourceLoaderService.__instance;

            libServices.ResourceLoaderService.__instance = this;
        },

        createResourceLoader: function () {
            // TODO: should create appropriate loader types -> local (for devices), remote (http for PCs)
            return new libServices.ResourceLoader();
        }

    }, {
        __instance: null,

        getInstance: function () {
            var ret = null;
            if (libServices.ResourceLoaderService.__instance == null) {
                ret = new libServices.ResourceLoaderService();
            } else {
                ret = libServices.ResourceLoaderService.__instance;
            }
            return ret;
        }
    });

    ////////////////////////////////// END - RESOURCE LOADING ////////////////////

})(jQuery);

// end of file