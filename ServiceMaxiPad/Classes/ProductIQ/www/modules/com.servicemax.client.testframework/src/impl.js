/**
 * This file needs a description
 *
 * @class com.servicemax.client.testframework.impl
 * @author Boonchanh Oupaxay
 *
 * @copyright 2013 ServiceMax, Inc.
 */
;(function($){
    "use strict";

	var unitTest = SVMX.Package("com.servicemax.client.testframework.impl");

    /**
     * This file needs a description
     *
     * @class com.servicemax.client.testframework.impl.Module
     * @extend com.servicemax.client.lib.api.ModuleActivator
     * @singleton
     */
   	unitTest.Class("Module", com.servicemax.client.lib.api.ModuleActivator, {

		__constructor : function(){
            this.__base();
			this._logger = SVMX.getLoggingService().getLogger("UNIT-TEST-IMPL");

            unitTest.Module.instance = this;

            // register with the READY client event
			SVMX.getClient().bind("READY", this.__onClientReady, this);
		},

        /*
         * Handles the client ready state
         *
         * 1) check for QUnit, load if needed
         * 2) initialize the api package
         *
         * @param       (Event)     event
         */
        __onClientReady : function(event){
            if (typeof QUnit != "undefined") {
                com.servicemax.client.testframework.api.init();
                //TODO: next version
                //com.servicemax.client.testframework.ui.api.init();
                this.__init();
            } else {
                //TODO: is there a global base path
                //var filepath = "modules/com.servicemax.client.testframework/resources/jquery.qunit-1.11.0.js";
                var filepath = ["jquery.qunit-1.12.0.js", "sinon-1.8.2.js", "plugins/sinon/sinon-qunit-1.0.0.js", "plugins/qunit-reporter-junit/qunit-reporter-junit.js"];
                var prefix = "modules/com.servicemax.client.testframework/resources/";

                SVMX.requireScript(filepath,
                    SVMX.proxy(this, function(){
                        com.servicemax.client.testframework.api.init();
                        //TODO: next version
                        //com.servicemax.client.testframework.ui.api.init();
                        this.__init();
                    }),
                    SVMX.proxy(this, function(){
                        this._logger.error("Error loading QUnit...");
                    }), this, {
                        async: false,
                        prefix: prefix
                    }
                );
            }
		},

        /*
         * Initialize the test harness
         *
         */
        __init: function() {
            //TODO: next version
            //var ui = SVMX.create("com.servicemax.client.testframework.ui.api.UnitTestBrowserHarness", this);
            var TestHarness = new com.servicemax.client.testframework.api.TestHarness();
            var UnitTestModule = new com.servicemax.client.testframework.api.UnitTest();
            //var FunctionalTestModule = new com.servicemax.client.testframework.api.FunctionalTest();

            TestHarness.add(UnitTestModule);

            this._logger.info("Test harness is ready...");
        },

        /*
         * initialize methods; gets called by the client object
         */
		beforeInitialize : function(){},
		initialize : function(){},
		afterInitialize : function(){}
	}, {
        /**
         * Reference to the module
         * @property
         */
		instance: null,

        /**
         * Fetch a script file and returns either an error or success response as a resolve deferred
         *
         * @method
         * @param       {String}        filepath
         * @param       {Boolean}       cache;
         *
         * @return      {Deferred}      contains (filepath, arguments)
         */
        fetchScriptFile: function(filepath, cache) {
            var defer = $.Deferred();

            $.ajax({
                cache: cache ? cache:false,
                type: "GET",
                dataType: "script",
                url: filepath,
                complete: function(result, status){
                    if (status !== 'success') {
                        var logger = SVMX.getLoggingService().getLogger("UNIT-TEST-IMPL");
                        logger.error('Unable to parse unit test script: '+filepath);
                    }
                    defer.resolve(result, status);
                }
            });

            return defer;
        }
	});

})(jQuery);
