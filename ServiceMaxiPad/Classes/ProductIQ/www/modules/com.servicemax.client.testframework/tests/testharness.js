/**
 * 
 *
 */
var harness = null;

QUnit.module("TestHarness", {
    setup: function() {
        //initialize code   
        harness = SVMX.Test;
    },
    teardown: function() {
        //cleanup code
        harness = null;
    }
});

test("self check", function() {
    deepEqual(SVMX.Test, harness, "test harness exist")     
});

