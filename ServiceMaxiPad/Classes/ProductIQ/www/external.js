(function(){
	window.external = {};
	var ext = window.external;
	
	ext.execute = function(paramStr){
		var req = SVMX.toObject(paramStr);
		if(req.Type == "SQL"){
			executeSQL(req);
		}else if(req.Type == "HTTP"){
			executeHTTP(req);
		}else if(req.Type == "EXTERNALAPP"){
			executeExternalApp(req);
		}else{
			//alert(SVMX.toJSON(req));
		}
	};

	function executeExternalApp(req){
		if(req.MethodName == "APPINFO"){
			setTimeout(function(){
				var request = {
					RequestId : req.RequestId,
					MethodName : req.MethodName,
					Type : req.Type,
					jsCallback : req.jsCallback
				};

				var response = {
					Status : true,
					RequestId : req.RequestId,
					MethodName : req.MethodName,
					Type : req.Type,
					CurrentPage : 1,
					TotalPages : 1,
					Result : SVMX.toJSON([{Installed : false}])
				};

				respond(request, response);
			}, 10);
		}else{
			//alert(SVMX.toJSON(req));
		}
	}

	function executeHTTP2(req){
		var res = {};
		var p = SVMX.toObject(req.ParameterString), uri = p.Uri, data = p.RequestBody, method = p.RequestMethod;
		var headers = SVMX.toObject(p.HttpRequestHeaders) || [];
	
		HTTP.sendRequest({
			uri : uri,
			method : method,
			data : data,
			headers : headers,
			onSuccess : function(data, headers, code){
				res.Status = true;
				var response = {ResponseHeaders : headers, ResponseBody : data, StatusCode : code};
				res.Result = SVMX.toJSON(response);
				res.CurrentPage = res.TotalPages = 1;
				respond(req, res);
			},
			onError : function(message){
				res.Status = false;
				res.Result = message;
				respond(req, res);
			}
		});
	}

	function executeHTTP(req){
		var p = SVMX.toObject(req.ParameterString), uri = p.Uri, body = p.RequestBody ? SVMX.toJSON(p.RequestBody) : "{}", method = p.RequestMethod;
		var r = {type : req.Type, requestId : req.RequestId, methodName : req.MethodName, 
					uri : uri, body : body, method : method, nativeCallbackHandler : "nativeCallbackHandlerHTTP", jsCallback : req.jsCallback};
		BRIDGE.invoke("HTTP", "callServer", r);
	}

	window.nativeCallbackHandlerHTTP = function(resp){
		resp = SVMX.toObject(resp);
		var request = {
			RequestId : resp.requestId,
			MethodName : resp.methodName,
			Type : resp.type,
			jsCallback : resp.jsCallback
		};

		var response = {
			Status : true,
			RequestId : resp.requestId,
			MethodName : resp.methodName,
			Type : resp.type,
			CurrentPage : 1,
			TotalPages : 1,
			Result : SVMX.toJSON({ResponseBody : resp.responseText, StatusCode : 200})
		};
		respond(request, response);
	}

	function executeSQL(req){
		console.log(req.ParameterString);
		var query = SVMX.toObject(req.ParameterString).SQL;
		var r = {type : req.Type, requestId : req.RequestId, methodName : req.MethodName, 
					query : query, nativeCallbackHandler : "nativeCallbackHandlerSQL", jsCallback : req.jsCallback};
		INFO(r.query);
		BRIDGE.invoke("DB", "executeQuery", r);
	}

	window.nativeCallbackHandlerSQL = function(resp){
		resp = SVMX.toObject(resp);
		var request = {
			RequestId : resp.requestId,
			MethodName : resp.methodName,
			Type : resp.type,
			jsCallback : resp.jsCallback
		};

		var response = {
			Status : true,
			RequestId : resp.requestId,
			MethodName : resp.methodName,
			Type : resp.type,
			CurrentPage : 1,
			TotalPages : 1,
			Result : SVMX.toJSON(resp.rows)
		};

		respond(request, response);
	};
	
	function respond(req, res){
		res.RequestId = req.RequestId;
		res.Type = req.Type;
		res.MethodName = req.MethodName;
		window[req.jsCallback](res);
	}
	
	function INFO(msg){
		SVMX.getLoggingService().getLogger("MOBILE-NATIVE-SERVICE").info(msg);
	}
	
	function ERROR(msg){
		SVMX.getLoggingService().getLogger("MOBILE-NATIVE-SERVICE").error(msg);
	}
})();