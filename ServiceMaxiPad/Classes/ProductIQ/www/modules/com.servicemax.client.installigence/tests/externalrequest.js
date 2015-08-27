
var app = SVMX.getCurrentApplication();

QUnit.module("ExternalRequestValidator", {
    setup: function() {
        //initialize code
    },
    teardown: function() {
        //cleanup code
        app.updateDependentRecords.restore();
        app.errorFromMFL.restore();
    }
});

test("External Response Validator", function(){
	var data = {};
	var client = SVMX.getClient();
	var noErrorCovered = false;
	var errorCovered = false;

	sinon.stub(app, "updateDependentRecords", function(){
		noErrorCovered = true;
	});
	
	sinon.stub(app, "errorFromMFL", function(){
		errorCovered = true;
	});

	data.action = "SYNC";
	data.operation = "INSERT_LOCAL_RECORDS";
	data.type = "RESPONSE";
	data.data = {};
	data.data.mapRecordIds = {};

	//var evt = SVMX.create("com.servicemax.client.lib.api.Event", "EXTERNAL_MESSAGE", {data:  data});
	//debugger;
	//client.triggerEvent(evt);
	app.externalMessage(data);
	equal(noErrorCovered, true, "MFL returened without any error");

	data.data.error = "Error from MFL";
	app.externalMessage(data);
	//jsonData = JSON.stringify(data);
	//client.triggerEvent("EXTERNAL_MESSAGE", jsonData);

	equal(errorCovered, true, "MFL returned with Error");
});
