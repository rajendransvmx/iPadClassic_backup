                                   /**
 * 
 *
 */
var unitrunner = null;
var defaultconfig = null; 

QUnit.module("UnitTestHarness", {
    setup: function() {
        //initialize code   
        unitrunner = SVMX.Test.Unit;
        defaultconfig = unitrunner.config();
    },
    teardown: function() {
        //cleanup code
        unitrunner.config(defaultconfig);
        unitrunner = null;
        defaultconfig = null;
    }
});

test("files()", function() {
    var list = unitrunner.files();
      
    var spy1 = this.spy();
    
    spy1($.isArray(), "method")
    
    ok(spy1.called, "spy was called!");
    
    equal($.isArray(list), true, "list is an array")     
});

test("modules()", function() {  
    var list = unitrunner.modules();
    equal($.isArray(list), true, "list is an array")     
});

test("config()", function() {  
    var options = {
        testTimeout: 5000,
        reorder: true,
        hidepassed: false
    };
      
    //check the changed config 
    deepEqual(unitrunner.config(), defaultconfig, "check default configuration");  
    
    //change the config
    unitrunner.config(options);
    ok(true, "method to set the config was called")
    //check the changed config 
    deepEqual(unitrunner.config(), options, "configuration change was verified");  
    
    //pass invalid options
    var badconfig = {
        shoe: "yes"
    };
    unitrunner.config(badconfig);
    ok(true, "method to set the config with bad config attributes");
    
    //check the changed config 
    deepEqual(unitrunner.config(), options, "invalid configuration was not allowed");  
});

          