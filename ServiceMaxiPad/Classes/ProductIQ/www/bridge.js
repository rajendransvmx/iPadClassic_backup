(function(){

    var b = {
    	invoke : function(cls, method, params){
    		params = params || {};
    		var p = encodeURIComponent(JSON.stringify(params));

    		var iframe = document.createElement("IFRAME");
		  	iframe.setAttribute("src", "native-call://" + cls + "/" + method + "/" + p);
		  	document.documentElement.appendChild(iframe);
		  	iframe.parentNode.removeChild(iframe);
		  	iframe = null;
    	}
    };

window.BRIDGE = b;
})();