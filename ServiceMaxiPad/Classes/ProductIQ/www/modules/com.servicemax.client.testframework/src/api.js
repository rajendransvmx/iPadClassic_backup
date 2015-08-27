/**
 * This file needs a description
 * @class com.servicemax.client.testframework.api
 * @author Boonchanh Oupaxay
 *
 * @copyright 2013 ServiceMax, Inc.
 */
;(function($) {
    "use strict";

    var testHarnessApi = SVMX.Package("com.servicemax.client.testframework.api");

testHarnessApi.init = function(){
    var currentModule = "";
    var config = {
        header: {
            size: "11",
            color: "dodgerblue"
        }
    }

    /**
     * @class   UnitTestHarness
     * Unit testing harness API
     *
     * @extends com.servicemax.client.lib.api.Object
     */
    testHarnessApi.Class("TestHarness", com.servicemax.client.lib.api.Object, {
        __parent: null,
        __logger: null,
        __runners: null,
        __cssheader: null,
        __constructor : function(){
            this.__parent = com.servicemax.client.testframework.impl.Module.instance;
            this.__logger = this.__parent.getLogger();
            this.__runners = [];
            this.__cssheader = "color:" + config.header.color + "; font-size: " + config.header.size + "pt";

            //expose the harness
            SVMX["Test"] = this;
        },
        /*
         *
         * Usage help
         *
         */
        __printRunUsage: function(header) {
            var header = header || "Usage: run()";

            console.group("%c" + header, this.__cssheader);
            console.log("-- empty:                                      execute all available test runners.");
            console.groupEnd();
        },

        __printAddUsage: function(header) {
            var header = header || "Usage: add(runner)";

            console.group("%c"+header, this.__cssheader);
            console.log("-- test runner:                                add a test runner to the harness.");
            console.groupEnd();
        },

        /**
         * add a test runner
         *
         */
        add: function(runner) {
            var hash = {
                UnitTest: "Unit"
            };

            if (!!hash[runner.getClassName()]) {
                if (!SVMX.Test[hash[runner.getClassName()]]) {
                    runner.init();
                    SVMX.Test[hash[runner.getClassName()]] = runner;
                    this.__runners.push(runner);
                }
            }

            return this;
        },

        /**
         * This will run all test
         *
         */
        run: function() {
            for (var i=0; i < this.__runners.length; i++) {
                this.__runners[i].run();
            }
        },

        help: function() {
            var header = "TestHarness Methods\n";

            console.group("%c" + header, this.__cssheader);
            this.__printRunUsage("Method: run()");
            this.__printAddUsage("Method: add(runner)");
            console.groupEnd();

            return ":)";

        }
    });

    /**
     * @class   UnitTestHarness
     * Unit testing harness API
     *
     * @extends com.servicemax.client.lib.api.Object
     */
    testHarnessApi.Class("UnitTest", com.servicemax.client.lib.api.Object, {
        __parent: null,
        __logger: null,
        __host: null,
        __ui: null,
        __testfiles: null,  //test files as describe via module manifest
        __ran: null,        //run status
        __config: null,     //store QUnit config
        __cssheader: null,

        __constructor : function(ui){
            this.__parent = com.servicemax.client.testframework.impl.Module.instance;
            this.__logger = this.__parent.getLogger();

            this.__config = {};
            this.__testfiles = [];
            this.__host = false;
            this.__cssheader = "color:" + config.header.color + "; font-size: " + config.header.size + "pt";

            this.__reset()
                .config({
                    testTimeout: 10000,
                    reorder: false,
                    hidepassed: false
                });
        },

        // Private Methods

        /*
         * Resets the test harness
         *
         * @param       {String}
         *
         * @return      {Object}        this
         */
        __reset: function(type) {
            switch(type) {
                case "qunit": //qunit only
                    this.__resetQunit();
                    break;

                case "harness": //class related config
                    this.__resetHarness();
                    break;

                default: //reset all
                    this.__resetQunit()
                        .__resetHarness();
            }

            return this;
        },

        /*
         * Reset the Qunit config
         *
         * @return      {Object}        this
         */
        __resetQunit: function() {
            QUnit.init();

            //config
            QUnit.config.autostart = false;
            QUnit.config.autoload = false;
            QUnit.config.autorun = false;


            QUnit.config.stats = {
                all: 0,
                bad: 0
            };

            QUnit.config.testCollection = {
                "assertions": []
            };

            QUnit.jUnitReport = function(report) {
              if (typeof window.callPhantom === 'function') {
                window.callPhantom({ report: report.xml });
              }
            };

            return this;
        },

        /*
         * Reset the class config
         *
         * @return      {Object}        this
         */
        __resetHarness: function() {
            this.__ran = false;

            return this;
        },

        /*
         * Qunit configurations
         *
         * @return      {Object}        this
         */
        __configQunit: function(){
            this.__configQunitModuleStart()
                .__configQunitModuleStop()
                .__configQunitTestDone()
                .__configQunitDone()
                .__configQunitLog();

            return this;
        },

        /*
         * Qunit moduleStart handler; manage the Qunit test module names
         *
         * @return      {Object}        this
         */
        __configQunitModuleStart: function(){
            var css = this.__cssheader;
            QUnit.moduleStart(function(details) {
                var newModuleName = details.name;
                if (currentModule != newModuleName) {
                    currentModule = newModuleName;
                    console.group( "%c" + currentModule , css);
                }
            });

            return this;
        },

        /*
         * Qunit moduleStart handler; manage the Qunit test module names
         *
         * @return      {Object}        this
         */
        __configQunitModuleStop: function(){
            QUnit.moduleDone(function(details) {
                var newModuleName = details.name;
                if (currentModule == newModuleName) {
                    console.groupEnd();
                }
            });

            return this;
        },

        /*
         * Qunit done handler; prints the final results
         *
         * @return      {Object}        this
         */
        __configQunitDone: function(){
            QUnit.done(SVMX.proxy(this, function(){
                return function(details) {
                    // stop `asyncTest()` from erroneously calling `done()` twice in
                    // environments w/o timeouts
                    if (this.__ran) {
                      return;
                    }
                    this.__ran = true;

                    console.log("");
                    console.group("%cUnit Test Summary - Finished in " + details.runtime + " milliseconds.", this.__cssheader);
                    console.debug("%c   PASS: " + details.passed, "color: green; font-weight:bold;");
                    console.debug("%c   FAIL: " + details.failed, "color: red; font-weight:bold;");
                    console.log("%c  TOTAL: " + details.total, "color: black; font-weight:bold;");
                    console.groupEnd();

                    if (typeof window.callPhantom === 'function') {
                      window.callPhantom({ failed: details.failed });
                    }
                };
            }()));

            return this;
        },

        /*
         * Qunit testDone handler; prints test results
         *
         * @return      {Object}        this
         */
        __configQunitTestDone: function(){
            QUnit.testDone(SVMX.proxy(this,function(details) {
                var assertions = QUnit.config.testCollection.assertions;
                var testName = details.name;

                if (details.failed > 0) {
                    this.__printTestDone(assertions, "FAIL", testName);
                } else {
                    if (!QUnit.config.hidepassed) {
                        this.__printTestDone(assertions, "PASS", testName);
                    }
                }

                assertions.length = 0;
            }));

            return this;
        },

        /*
         * Helper method for the testDone handler; prints the test results
         *
         * @param       {String}        status
         * @param       {String}        testname
         *
         * @return      {Object}        this
         */
        __printTestDone: function(assertions, status, testname) {

            if (status == "FAIL") {
                this.__printErrorTestDone( assertions, status, testname );
            } else {
                this.__printDebugTestDone( assertions, status, testname );
            }

            return this;
        },

        /*
         *  3 Helper method for the testDone handler;
         *  error, info, debug
         *  it's really used to color code in the console
         *
         * @param       {Object}        assertions
         * @param       {String}        status
         * @param       {String}        testname
         *
         */
        __printErrorTestDone: function(assertions, status, testname) {
            var css = "color: red; font-weight:bold;"
            console.group("%c" + status + " - "+ testname, css);
            assertions.forEach(function(value) {
                var temparr = value.split("|");
                if ($.trim(temparr[0]) == "FAIL") {
                    console.error(value);
                } else {
                    if (!QUnit.config.hidepassed) {
                        console.debug("     " + value);
                    }
                }
            });
            console.groupEnd();
        },

        __printInfoTestDone: function(assertions, status, testname) {
            console.groupCollapsed("%c" + status + " - "+ testname, "color: dodgerblue; font-weight:bold;");
            assertions.forEach(function(value) {
                console.info("    " + value);
            });
            console.groupEnd();
        },

        __printDebugTestDone: function(assertions, status, testname) {
            console.groupCollapsed("%c" + status + " - "+ testname, "color: green; font-weight:bold;");
            assertions.forEach(function(value) {
                console.debug("    " + value);
            });
            console.groupEnd();
        },

        /*
         * Qunit log handler; aggregate the test results
         *
         * @return      {Object}        this
         */
        __configQunitLog: function(){
            QUnit.log(function(details) {
                var expected = details.expected;
                var result = details.result;
                var type = (typeof expected != "undefined") ? "EQ" : "OK";

                var assertion = [
                    result ? "PASS" : "FAIL",
                    type,
                    details.message || "ok"
                ];

                if (!result && type == "EQ") {

                    var expectstr = (SVMX.typeOf(expected) == "Object") ? JSON.stringify(expected): expected;
                    var actualstr = (SVMX.typeOf(expected) == "Object") ? JSON.stringify(details.actual): details.actual;

                    assertion.push("\nExpected: " + expectstr + ", \n  Actual: " + actualstr);
                }

                QUnit.config.testCollection.assertions.push(assertion.join(" | "));
            });

            return this;
        },

        /*
         * Process the module collection to get the test files
         *
         * @return      {Object}        this
         */
        __getTestList: function(){
            var client = SVMX.getClient();
            var modules = client.__moduleId2Modules;

            for (var item in modules) {
                var collection = modules[item].tests;

                if (!!collection.length) {
                    this.__processRawTestList(collection, item);
                }
            }

            return this;
        },

        /*
         * Process and store the test files within the module manifest
         *
         * @param       {Object}        collection
         * @param       {String}        module
         *
         * @return      {Object}        this
         */
        __processRawTestList: function(collection, module) {
            var baselocation = "modules/" + module + "/tests/";

            for (var i = 0; i < collection.length; i++) {
                var itemtype = SVMX.typeOf(collection[i]).toLowerCase();
                var testfile = "";
                var modulename = module;

                switch(itemtype) {
                    case "object":
                        testfile = collection[i].module + "/tests/" + collection[i].name;
                        modulename = collection[i].module;
                        break;

                    case "string":
                        testfile = baselocation + collection[i];
                        break;

                    default:
                }

                //add to test list
                this.__addFileToModuleList(modulename, {
                    filepath: testfile,
                    status: "not loaded",
                    details: ""
                });
            }

            return this;
        },


        /*
         * Adds the files to the proper module list
         *
         *
         */
        __addFileToModuleList: function(modulename, fileobject) {
            var reference =  this.__testfiles;
            var module = null;

            for (var item in reference) {
                if (reference[item].key == modulename) {
                    module = reference[item];
                    break;
                }
            }

            if (!module) {
                module = {
                    key: modulename,
                    tests: []
                }

                this.__testfiles.push(module);
            }

            module.tests.push(fileobject);

            return this;
        },

        /*
         * Given a module name it returns a collection of unit test files
         *
         * @param       {String}        name
         *
         * @return      {Array}        list of test files
         */
        __getTestSetByModuleId: function(name) {
            var collection = this.__testfiles;
            var list = [];

            for (var item in collection) {
                var module = collection[item];
                var key = module.key;

                if (key == name) { //get the test set
                    for (var i=0; i < module.tests.length; i++ ) {
                        //check if it has been check with an error before
                        if (module.tests[i].status != "error") {
                            list.push(module.tests[i].filepath);
                        }
                    }
                    //done we found the module
                    break;
                }
            }

            return list;
        },

        /*
         * Given a file path and name it returns a collection of unit test files
         *
         * @param       {String}        names
         *
         * @return      {String}        test files
         */
        __getTestFileByName: function(name) {
            var collection = this.__testfiles;

            for (var item in collection) {
                var module = collection[item];

                for (var i=0; i < module.tests.length; i++ ) {
                    if ((module.tests[i].filepath == name) && (module.tests[i].status != "error")) {
                        return module.tests[i].filepath;
                    }
                }
            }

            return "";
        },

        /*
         * Loads the module test files
         *
         * @param       (String|Array)      arg         string name or array list of names
         *
         * @return      (Deferred)
         */
        __loadTest: function(arg) {
            var files = [];
            switch(arguments.length) {
                case 1: //load specific test modules/files
                    files = this.__parseFileToLoad(arg);
                    break;

                default: //load all tests
                    var collection = this.__testfiles;

                    if (!collection.length) {
                        return $.when(1);
                    }

                    for (var item in collection) {
                        var module = collection[item];

                        for (var i=0; i < module.tests.length; i++ ) {
                            if (module.tests[i].status != "error") {
                                files.push(module.tests[i].filepath);
                            }
                        }
                    }
            }

            return this.__assembleTestFiles(files);
        },

        /*
         * loads the test module files
         *
         */
        __parseFileToLoad: function(arg) {
            var files = [];

            switch(SVMX.typeOf(arg).toLowerCase()) {
                case "array":
                    for (var i=0; i < arg.length; i++) {
                        if (this.__isFile(arg[i])) {
                            var file = this.__getTestFileByName(arg[i]);
                            if (!!file) {
                                files.push(file);
                            }
                        } else {
                            $.merge(files, this.__getTestSetByModuleId(arg[i]));
                        }
                    }
                    break;

                case "string":
                    if (this.__isFile(arg)) {
                        var file = this.__getTestFileByName(arg);
                        if (!!file) {
                            files.push(file);
                        }
                    } else {
                        files = this.__getTestSetByModuleId(arg);
                    }
                    break;

                default:
            }

            return files;
        },


        /*
         * Determines if the given string is a file request
         *
         * @param       {String}        arg
         *
         * @returns     {Boolean}
         */
        __isFile: function(arg) {
            var files = [];
            var temparr = arg.split("/");
            var len = temparr.length - 1;
            var content = temparr[len];
            var contentarr = content.split(".");

            return ((contentarr.length == 2) && (contentarr[1] == "js"));
        },

        /*
         * build a collection of file fetches
         *
         * @param       {Object}       files
         *
         * @return      (Deferred)
         */
        __assembleTestFiles: function(files) {
            var deferreds = [];
            var that = this;

            if (!$.isArray(files)) {
                files = [files];
            }

            $.each(files, function(idx, filepath) {
                deferreds.push( com.servicemax.client.testframework.impl.Module.fetchScriptFile(filepath) );
            });

            return SVMX.when(deferreds);
        },

        /*
         * Update the class collection of test files
         *
         * @param       {String}        filepath
         * @param       {String}        status
         * @param       {String}        details
         *
         * @return      {Object}        this
         */
        __updateTestFileStatus: function(filepath, status, details) {
            var collection = this.__testfiles;

            for (var item in collection) {
                var module = collection[item];

                for (var i=0; i < module.tests.length; i++) {
                    //update the file object
                    if (module.tests[i].filepath == filepath) {
                        module.tests[i].status = status;
                        module.tests[i].details = details;
                    }
                }
            }

            return this;
        },

        /*
         * Execute the Qunit test
         *
         */
        __runQunit: function(){
            var datetime = new Date();
            QUnit.config.started = datetime.getTime();
            QUnit.config.semaphore = 1;

            QUnit.load();
            QUnit.start();
        },

        /*
         *
         * Usage help
         *
         */
        __printRunUsage: function(header) {
            var header = header || "Usage: run(argument)";
            var css = "color:dodgerblue; font-size: 10pt";

            console.group("%c" + header, css);
            console.debug("-- empty:                                      execute all available test files.");
            console.debug("-- \"module1/testfile1\":                        execute a specific test module or test file.");
            console.debug("-- [\"module1/testfile1\", \"module2/testfile2\"]: execute specific test modules and/or test files.");
            console.groupEnd();
        },

        __printTestFilesUsage: function(header) {
            var header = header || "Usage: files(argument)";
            var css = "color:dodgerblue; font-size: 10pt";

            console.group("%c" + header, css);
            console.debug("-- empty:                                      returns all test files {missing and available} as a list.");
            console.debug("-- \"available\":                                returns all available test files as a list.");
            console.debug("-- \"module name\":                              returns test files that are in the module manifest.");
            console.debug("-- [\"module1\", \"module2\"]:                     returns test files that are in the given module list.");
            console.groupEnd();

        },

        __printTestModulesUsage: function(header) {
            var header = header || "Usage: modules()";
            var css = "color:dodgerblue; font-size: 10pt";

            console.group("%c" + header, css);
            console.debug("-- empty:                                      returns all test modules that are in the manifest.");
            console.groupEnd();
        },

        __printSetConfigUsage: function(header) {
            var header = header || "Usage: config({options})";
            var css = "color:dodgerblue; font-size: 10pt";

            console.group("%c" + header, css);
            console.debug("-- testTimeout:                                number;  default = 10000;  ajax test timeout.");
            console.debug("-- reorder:                                    boolean; default = false;  keeps the test sequence.");
            console.debug("-- hidepassed:                                 boolean; default = false;  hided the passed test.");
            console.groupEnd();
        },

        __printConfigUsage: function(header) {
            var header = header || "Usage: config()";
            var css = "color:dodgerblue; font-size: 10pt";

            console.group("%c" + header, css);
            console.debug("-- empty:                                      returns the test harness configuration options.");
            console.groupEnd();
        },

        __setHarnessConfigurations: function(options) {
            //allowed Qunit settings
            var hash = {
                testTimeout: "number",
                reorder: "boolean",
                hidepassed: "boolean"
            };

            //set the correct Qunit config property, stored in class config for display
            for (var item in options) {
                var type = hash[item];

                if (!!type) {
                    var valueType = SVMX.typeOf(options[item]).toLowerCase();

                    //check the value type before assigning
                    if (hash[item] == valueType) {
                        QUnit.config[item] = options[item];
                        this.__config[item] = options[item];
                    }
                }
            }

            return this;
        },

        // Public Methods

        /**
         * Returns a list of modules with "tests" defined in their manifest
         *
         * @return      {Array}         list
         */
        modules: function() {
            var reference = this.__testfiles;
            var list = [];

            for (var item in reference){
                list.push(reference[item].key);
            }

            return list;
        },

        /**
         * Returns a list of test for modules with defined tests in their manifest
         *
         * @param       {String}        arg         optional; "missing" or "available", module name
         *
         * @return      {Array}         list
         */
        files: function(arg) {
            if (arguments.length < 2) {
                var list = [];
                var hash = {
                    missing: "error",
                    available: "success"
                };

                if (!!arg && !hash[arg]) {//handle module files
                    if (SVMX.typeOf(arg).toLowerCase() == "array") { //module collection files
                        for (var i=0; i < arg.length; i++) {
                            $.merge(list, this.__getTestSetByModuleId(arg[i]));
                        }
                    } else {//one module file set
                        if (!this.__isFile(arg)) {
                            list = this.__getTestSetByModuleId(arg);
                        }
                    }
                } else { //get all files
                    var collection = this.__testfiles;

                    for (var item in collection){
                        var module = collection[item];

                        for (var i=0; i < module.tests.length; i++) {
                            if (!hash[arg] || (hash[arg] == module.tests[i].status)) {
                                list.push(module.tests[i].filepath);
                            }
                        }
                    }
                }

                return list;
            } else {
                this.__logger.error("Invalid Input!");
                console.debug(this.__printTestFilesUsage());
            }
        },

        /**
         * This gets called by the parent module from impl.js.
          1) It initilizes QUnit for console operations
          2) Gets the test file list from the module manifest
          3) Loads the test files, then updates the local file status
         *
         * @return      {Object}        this
         */
        init: function(){
            this.__configQunit()
            .__getTestList()
            .__loadTest()
            .then(SVMX.proxy(this, function(){
                //update the the test collection file status
                var collection = arguments;
                for (var item in collection){
                    var module = collection[item];
                    var filepath = module[0];
                    var status = module[1][1];
                    var details = module[1][0].statusText;

                    this.__updateTestFileStatus(filepath, status, details);
                }

                //reset QUnit
                this.__resetQunit();
            }));

            if (typeof window.callPhantom === 'function') {
              window.callPhantom({ init: true });
            }

            return this;
        },

        /**
         * Executes the test harness to run test by modules
         *
         * @param       {String/Array["String"]}        arg; can be a string name of a module or collection of a module names
         */
        run: function(arg) {
            this.__reset();

            switch(arguments.length) {
                case 0: //run all available test within the modules
                    this.__loadTest()
                    .then(SVMX.proxy(this, "__runQunit"));
                    break;

                case 1: //run all module tests based on module name or a collection of names
                    if (!arg.length)  {
                        this.__logger.error("Invalid Input!");
                        console.debug(this.__printRunUsage());
                    } else {
                        this.__loadTest(arg)
                        .then(SVMX.proxy(this, "__runQunit"));
                    }
                    break;

                default:
                    this.__logger.error("Invalid Input!");
                    console.debug(this.__printRunUsage());
            }
        },


        /**
         * This method handles the set and get routines
         * for the test harness configuration.
         *
         * @param       {Empty|Object}        options
         *
         * @return      {Object}            test harness | configuration object
         */
        config: function(options) {
            //check what type or request set or get
            if (!options) {
                return this.__config;
            } else { //set the config
                return this.__setHarnessConfigurations(options);
            }
        },

        /**
         * Prints the options and commmands
         *
         */
        help: function(arg) {
            var header = "UnitTestHarness Methods";
            var css = "color:dodgerblue; font-size: 12pt";

            console.group("%c" + header, css);
            this.__printRunUsage("Method: run()");
            this.__printSetConfigUsage("Method: config({options})");
            this.__printTestModulesUsage("Method: modules()");
            this.__printTestFilesUsage("Method: files(argument)");
            console.groupEnd();

            return ":)";
        }

    }, {

    });
}
})(jQuery);
