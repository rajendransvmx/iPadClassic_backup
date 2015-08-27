/*
 * QUnit Test Setup
 *  
 * module:          group related unit test 
 * setup/teardown:  test setup/cleanup 
 */ 
/*********************************/    
//Object class  
var object = null;
QUnit.module("Object", {
    setup: function() {
        //initialize code
        object = SVMX.create('com.servicemax.client.lib.api.Object');
    },
    teardown: function() {
        //cleanup code
        object = null;
    }
});

/*
 * testing base Object public methods
 */
test("getClassName()", function() {  
    //fail
    //equal("String", "Object", "Object = Object; equal succeeds"); 
        
    //good 
    equal(object.getClassName(), "Object", "Object = Object; equal succeeds"); 
    
    //bad
    notEqual(object.getClassName(), "Objects", "Object != Objects; not equal succeeds");        
});

test("toString()", function() {   
    //good 
    equal(object.toString(), "Object", "Object = Object; equal succeeds"); 
    
    //bad
    notEqual(object.toString(), "Objects", "Object != Objects; not equal succeeds");
});

