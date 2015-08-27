/*
 * QUnit Test Setup
 *  
 * module:          group related unit test 
 * setup/teardown:  test setup/cleanup 
 */ 
/*********************************/    
//Event Dispatcher class  
var eventDispatcher = null;
QUnit.module("EventDispatcher", {
    setup: function() {     
        //initialize code
        eventDispatcher = SVMX.create('com.servicemax.client.lib.api.EventDispatcher');
    },
    teardown: function() {
        //cleanup code
        eventDispatcher = null;
    }
});

/*
 *
 */
test("Properties", function() {
    var handlers = [];
    //good 
    deepEqual(eventDispatcher.eventHandlers, handlers, "eventHandlers = []; equal succeeds");  
});   

/*
 *
 */
asyncTest("Public Methods", function() {
    //asserts to expect
    expect( 4 );
    var data = {
        request : {}, 
		responder : {}
    }; 
    var evt = SVMX.create("com.servicemax.client.lib.api.Event", "READY", this, data);
    var handler = function(event) {
        ok(true, "bind(); READY event callback succeeds");
        start();
    }; 
    
    //bind 
    eventDispatcher.bind("READY", handler, this);
    equal(eventDispatcher.eventHandlers.length, 1, "bind event; eventHandlers.length = 1; equal succeeds"); 
    
    //triggerEvent
    eventDispatcher.triggerEvent( evt );
    ok(true, "triggerEvent(); trigger initilization succeeds");
    
    //unbind
    eventDispatcher.unbind("READY", handler);
    equal(eventDispatcher.eventHandlers.length, 0, "unbind event; eventHandlers.length = 0; equal succeeds"); 
    
});
