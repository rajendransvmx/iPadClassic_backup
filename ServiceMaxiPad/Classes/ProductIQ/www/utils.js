var UTILS = {

	init : function(cb){
		___cb = cb;
		BRIDGE.invoke("Utils", "respondWithLoginDetails", {callback : "utilsLoginDetailsCallbackHandler"});
	}
};

function utilsLoginDetailsCallbackHandler(details){
	___cb(details);
}