var HTTP = {};
(function(){
	
	HTTP.sendRequest = function(params){
		var headers = {"Authorization" : "OAuth " + ___sessionId};
		for(var i = 0; i < params.headers.length; i++){
			headers[params.headers[i].Header] = params.headers[i].Value;
		}
	
		var url = ___system + params.uri;
		var context = params.context || window;
	
		$.ajax({
			url : url,
			type : params.method,
			dataType : "text",
			headers : headers,
			data : params.data,
			success : function(data, textStatus, jqXHR){
			   var allHeaders = jqXHR.getAllResponseHeaders().split("\r\n");
			   var responseHeaders = [], h;
			   for(var i = 0; i < allHeaders.length; i++){
					h = allHeaders[i].split(":");
					responseHeaders.push({Header : h[0], Value : h[1]});
			   }
			   console.log("^^^^^ " + data.length);
			   params.onSuccess.call(context, data, responseHeaders, jqXHR.statusCode());
			},
			error : function(jqXHR, textStatus, errorThrown){
			   params.onError.call(context, errorThrown);
			}
		});
	}
})();