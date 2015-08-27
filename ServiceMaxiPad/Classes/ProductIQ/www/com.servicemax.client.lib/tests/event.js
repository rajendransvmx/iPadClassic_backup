/*
 * QUnit Test Setup
 *  
 * module:          group related unit test 
 * setup/teardown:  test setup/cleanup 
 */ 
/*********************************/    
//Event class  
var event = null;
QUnit.module("Event", {
    setup: function() {
        //initialize code
        var type = "com.servicemax.client.lib.api.Event",
            target = this,
            data =  {
                request : {}, 
			    responder : {}
            };
        
        event = SVMX.create('com.servicemax.client.lib.api.Event', type, target, data);
    },
    teardown: function() {
        //cleanup code
        event = null;
    }
});

/*
 * properties
 */
test("Properties", function() {
    var type = "com.servicemax.client.lib.api.Event",
        target = this,
        data =  {
            request : {}, 
			responder : {}
        },
        error = {
            error:{},
            message:{}
        }; 
        
    //good 
    equal(event.type, type, "type = com.servicemax.client.lib.api.Event; equal succeeds"); 
    equal(event.target, target, "target = this; equal succeeds"); 
    deepEqual(event.data, data, "data = {request:{},responder:{}}; equal succeeds"); 
    
    //bad
    notEqual(event.type, "blah", "type != blah; not equal succeeds"); 
    notEqual(event.target, window, "target != window; not equal succeeds"); 
    notDeepEqual(event.data, error, "data != {error:{}, message:{}}; not equal succeeds"); 
    
}); 
