/**
 * This file needs a description
 * @class com.servicemax.client.sal.impl
 * @singleton
 * @author unknown
 *
 * @copyright 2013 ServiceMax, Inc.
 */

(function(){

	var salServiceImpl = SVMX.Package("com.servicemax.client.sal.impl");

	salServiceImpl.Class("Module", com.servicemax.client.lib.api.ModuleActivator, {

		__logger : null,
		__constructor : function(){
			this.__base();
			this.__logger = SVMX.getLoggingService().getLogger("SAL-SERVICE");
		},

		beforeInitialize : function(){ },
		initialize : function(){ },
		afterInitialize : function(){ }

	}, {});

	salServiceImpl.Class("RuntimeMode", com.servicemax.client.lib.api.Object, {
		appInstance : "",
		url : "/services/data/", apexRestUrl : "/services/apexrest/",
		soapUrl : "/services/Soap/u/", apexSoapUrl : "/services/Soap/class/",

		__constructor : function(){},
		init : function(){},
		getUrl : function(url, apiVersion){},
		getApexRestUrl : function(url){},
		adjustHeaders : function(headers, params, apiVersion){},
		adjustApexRestHeaders : function(headers, params){},

		adjustSoapHeaders : function(headers, params, apiVersion){},
		adjustApexSoapHeaders : function(headers, params){},

		getSoapUrl : function(url, apiVersion){},
		getApexSoapUrl : function(url){}
	}, {});

	salServiceImpl.Class("VFRuntimeMode", salServiceImpl.RuntimeMode, {
		__constructor : function(){},
		proxyUrl : "/services/proxy/",

		init : function(){
			var baseUrl = SVMX.getClient().getApplicationParameter("svmx-base-url");
			if (baseUrl) {
				if (baseUrl.indexOf("/") != 0) {
					baseUrl = "/" + baseUrl;
				}
			} else {
				baseUrl = "";
			}
			this.soapUrl = baseUrl + this.soapUrl;
			this.url = baseUrl + this.url;
			this.proxyUrl = baseUrl + this.proxyUrl;
			this.apexSoapUrl = baseUrl + this.apexSoapUrl;
			this.apexRestUrl = baseUrl + this.apexRestUrl;

			var urlArray = location.hostname.split(".");
	        this.appInstance = (urlArray.length == 3 ? urlArray[0] : urlArray[1])
	        	+ (urlArray.length == 6 ? '.' + urlArray[3] : '');     // 5 in cases like pre release
		},

		getUrl : function(url, apiVersion){ return this.proxyUrl; },

		getApexRestUrl : function(url){ return this.proxyUrl; },

		adjustHeaders : function(headers, params, apiVersion){
			headers["SalesforceProxy-Endpoint"] =
					"https://" + this.appInstance + ".salesforce.com" + this.url + apiVersion + "/" + params.url;
		},

		adjustApexRestHeaders : function(headers, params){
			headers["SalesforceProxy-Endpoint"] =
					"https://" + this.appInstance + ".salesforce.com" + this.apexRestUrl + params.url;
		},

		adjustSoapHeaders : function(headers, params, apiVersion){},
		adjustApexSoapHeaders : function(headers, params){},

		getSoapUrl : function(url, apiVersion){ return this.soapUrl + apiVersion + "/" + url; },
		getApexSoapUrl : function(url){ return this.apexSoapUrl + url; }

	}, {});

	salServiceImpl.Class("SARuntimeMode", salServiceImpl.RuntimeMode, {
		__constructor : function(){},
		init : function(){},

		getUrl : function(url, apiVersion){
			return this.__getInstanceUrl() + this.url + url;
		},

		getApexRestUrl : function(url){
			return this.__getInstanceUrl() + this.apexRestUrl + url;
		},

		__getInstanceUrl : function(){
			return SVMX.getClient().getApplicationParameter("api-instance-url");
		},

		//!!!! TODO:
		adjustSoapHeaders : function(headers, params, apiVersion){},
		adjustApexSoapHeaders : function(headers, params){},

		getSoapUrl : function(url, apiVersion){ },
		getApexSoapUrl : function(url){ }
		//!!!!

	}, {});

	salServiceImpl.Class("RPRuntimeMode",salServiceImpl.RuntimeMode, {
		__constructor : function(){},

		init : function(){ },

		getUrl : function(url, apiVersion){ return this.url + apiVersion + "/" + url; },

		getApexRestUrl : function(url){ return this.apexRestUrl + url; },

		adjustHeaders : function(headers, params, apiVersion){},

		adjustApexRestHeaders : function(headers, params){},

		adjustSoapHeaders : function(headers, params, apiVersion){},
		adjustApexSoapHeaders : function(headers, params){},

		getSoapUrl : function(url, apiVersion){ return this.soapUrl + apiVersion + "/" + url; },
		getApexSoapUrl : function(url){ return this.apexSoapUrl + url; }
	}, {});

	/**
	 * The SAL initializer
	 */
	salServiceImpl.Class("SAL", com.servicemax.client.lib.api.Object , {}, {

		initialized : false,
		rtMode : null,

		init : function(){

			if(salServiceImpl.SAL.initialized) return; salServiceImpl.SAL.initialized = true;

	        var runtimeMode = SVMX.getClient().getApplicationParameter("sal-service-runtime-mode");
	        var rtMode = null;

	        if(runtimeMode == "VISUAL_FORCE"){
	        	rtMode = new salServiceImpl.VFRuntimeMode();
	        }else if(runtimeMode == "STAND_ALONE"){
	        	rtMode = new salServiceImpl.SARuntimeMode();
	        }else if(runtimeMode == "REMOTE_PROXY"){
	        	rtMode = new salServiceImpl.RPRuntimeMode();
	        }else throw new Error("Please specify a runtime mode!");

	        rtMode.init();
	        salServiceImpl.SAL.rtMode = rtMode;
		}
	});

	/**
	 * Supported event types:
	 * 01. REQUEST_COMPLETED
	 * 02. REQUEST_ERROR
	 */
	salServiceImpl.Class("RestRequestEvent", com.servicemax.client.lib.api.Event, {

		__constructor : function(type, target, data){
			this.__base(type, target, data);
		}
	}, {});

	/**
	 * Supported event types:
	 * 01. REQUEST_COMPLETED
	 * 02. REQUEST_ERROR
	 */
	salServiceImpl.Class("SoapRequestEvent", com.servicemax.client.lib.api.Event, {

		__constructor : function(type, target, data){
			this.__base(type, target, data);
		}
	}, {});

	salServiceImpl.Class("RestRequest", com.servicemax.client.lib.api.EventDispatcher, {
		_options : null, _baseURL : "",

		__constructor : function (options){
			this.__base();
			this._options = options;
		},

		callAsync : function(params){
			if(!params) params = {};
			if(!params.headers) params.headers = {};

			// overriding parameters
			var async = true;
			if(params.async != undefined) async = params.async;
			// end

			this._appendAuthToken(params.headers);

			var url = this._getUrl(params.url);
			var method = params.method ? params.method : "GET";  // default
			var responseType = params.responseType ? params.responseType : "json";  // default

			this._adjustEndpoint(params.headers, params);

			var d = "";
			if(params.data){
				if(typeof(params.data) == 'string')
					d = params.data;
				else{
					d = SVMX.toJSON(params.data);

					// do this only if it is an object
					if(method == "GET"){
						d = "getParams=" + d;
					}
				}
			}

			return SVMX.ajax({type: method,
					contentType : params.contentType ? params.contentType : "application/json", 	// default
					dataType: responseType,															// default
					data: d, url: url,
				 	context: this, async: async, headers : params.headers,
					success: function(data, status, jqXhr) {
								var d = data;
								if(responseType == "json") d = SVMX.toObject(data);

								this._callAsyncSuccess(d, status);
					},
					error : function(jqXhr, status, e){this._callAsyncError(jqXhr, status, e);}});
		},

		_callAsyncSuccess : function(data, status, jqXhr){
			data = this._processDataOnLoad(data);
			var evtObj = new salServiceImpl.RestRequestEvent("REQUEST_COMPLETED", this, data);
			this.triggerEvent(evtObj);
		},

		_appendAuthToken : function(headers){
			headers["Authorization"] = "OAuth " + this._options.sessionId;
		},

		_adjustEndpoint : function(headers, params){
			salServiceImpl.SAL.rtMode.adjustHeaders(params.headers, params, this._options.apiVersion);
		},

		_getUrl : function(url){
			return salServiceImpl.SAL.rtMode.getUrl(url, this._options.apiVersion);
		},

		_callAsyncError : function(jqXhr, status, e){

			// YUI Compressor cribs
			//debugger;

			var evtObj = new salServiceImpl.RestRequestEvent("REQUEST_ERROR", this, {e:e, status : status, xhr : jqXhr});
			this.triggerEvent(evtObj);
		},

		_processDataOnLoad : function(data){
			return data;
		}

	},
	{});

	salServiceImpl.Class("ApexRestRequest", salServiceImpl.RestRequest, {

		__constructor : function(options){
			this.__base(options);
		},

		_adjustEndpoint : function(headers, params){
			salServiceImpl.SAL.rtMode.adjustApexRestHeaders(params.headers, params);
		},

		_getUrl : function(url){
			return salServiceImpl.SAL.rtMode.getApexRestUrl(url);
		}

	}, {});

	salServiceImpl.Class("SoapRequest", com.servicemax.client.lib.api.EventDispatcher, {
		_options : null, _baseURL : "", _requestTemplate : "",

		__constructor : function (options){
			this.__base();
			this._options = options;

			this._requestTemplate = 	  "<se:Envelope xmlns:se=\"http://schemas.xmlsoap.org/soap/envelope/\">"
										+ 	"<se:Header xmlns:sfns=\"urn:partner.soap.sforce.com\">"
										+		"<sfns:SessionHeader><sessionId>{0}</sessionId></sfns:SessionHeader>"
										+	"</se:Header>"
										+	"<se:Body>"
										+		"<{1} xmlns=\"urn:partner.soap.sforce.com\" xmlns:ns1=\"sobject.partner.soap.sforce.com\">"
										+			"{2}"
										+		"</{1}>"
										+	"</se:Body>"
										+ "</se:Envelope>";
		},

		callAsync : function(params){
			if(!params) params = {};
			if(!params.headers) params.headers = {};

			// overriding parameters
			var async = true;
			if(params.async != undefined) async = params.async;
			// end

			this._setupHeaders(params.headers, params);
			var url = this._getUrl(params.url), method = "POST",
						responseType = "xml", data = this._getData(params.data, params), contentType = "text/xml";

			SVMX.ajax({type: method, contentType : contentType, dataType: responseType,
					data: data, url: url, context: this, async: async, headers : params.headers,
					success: function(data, status, jqXhr) {
								this._callAsyncSuccess(data, status);
					},
					error : function(jqXhr, status, e){this._callAsyncError(jqXhr, status, e);}});
		},

		_callAsyncSuccess : function(data, status, jqXhr){
			data = this._processDataOnLoad(data);
			var evtObj = new salServiceImpl.SoapRequestEvent("REQUEST_COMPLETED", this, data);
			this.triggerEvent(evtObj);
		},

		_getUrl : function(url){
			return salServiceImpl.SAL.rtMode.getSoapUrl(url, this._options.apiVersion);
		},

		_getData : function(data, params){
			data = SVMX.toXML(data);
			data = this._format(this._requestTemplate, this._options.sessionId,
                    params.methodName,
                    data
                    );
			return data;
		},

		_getOrgNamespace : function(orgNameSpace){
			if(orgNameSpace != null && orgNameSpace != '') return orgNameSpace + "/";
			else return "";
		},

		_format : function(){
			if(arguments.length == 0 ) return "";

			var formatted = arguments[0];	// first parameter is the string to be formated

		    for (var i = 1; i < arguments.length; i++) {
		        var regexp = new RegExp('\\{'+ (i - 1) +'\\}', 'gi');
		        formatted = formatted.replace(regexp, arguments[i]);
		    }
		    return formatted;
		},

		_callAsyncError : function(jqXhr, status, e){
			var evtObj = new salServiceImpl.RestRequestEvent("REQUEST_ERROR", this, {e:e, status : status, xhr : jqXhr});
			this.triggerEvent(evtObj);
		},

		_setupHeaders : function(headers, params){
			headers["SOAPAction"] = params.methodName;
		},

		_processDataOnLoad : function(data){
			return data;
		}

	},{});

	salServiceImpl.Class("ApexSoapRequest", salServiceImpl.SoapRequest, {

		__constructor : function(options){
			this.__base(options);
			this._requestTemplate = 	"<se:Envelope xmlns:se=\"http://schemas.xmlsoap.org/soap/envelope/\">"
 											+ "<se:Header xmlns:sfns=\"http://soap.sforce.com/schemas/package/{0}{1}\">"
 												+ "<sfns:SessionHeader><sessionId>{2}</sessionId></sfns:SessionHeader>"
 											+ "</se:Header>"
 											+ "<se:Body><{3} xmlns=\"http://soap.sforce.com/schemas/package/{0}{1}\">"
 												+ "<request>{4}</request>"
 											+ "</{3}></se:Body>"
 										+ "</se:Envelope>";
		},

		_getUrl : function(url){
			return salServiceImpl.SAL.rtMode.getApexSoapUrl(url);
		},

		_getData : function(data, params){
			data = SVMX.toXML(data);

			data = this._format(this._requestTemplate, this._getOrgNamespace(this._options.nameSpace),
					this._options.endPoint,
					this._options.sessionId,
                    params.methodName,
                    data
                    );

			return data;
		},

		_processDataOnLoad : function(data){
			return data;
		}
	}, {});

	/**
	 * Supported event types:
	 * 01. REQUEST_COMPLETED
	 * 02. REQUEST_ERROR
	 */
	salServiceImpl.Class("ServiceEvent", com.servicemax.client.lib.api.Event, {

		__constructor : function(type, target, data){
			this.__base(type, target, data);
		}
	}, {});

	/**
	 * The base class for all the service types
	 */
	salServiceImpl.Class("ServiceBase", com.servicemax.client.lib.api.EventDispatcher, {
		_parent : null,
        _profiler: null,

		__constructor : function(parent){
			this.__base();
			this._parent = parent;
            this._profiler = SVMX.getProfilingService();
		},

		callMethod : function(params){
			// should be overridden in the corresponding service implementations
		},

		callMethodAsync : function(params){
			// should be overridden in the corresponding service implementations
		},

		callApiAsync : function(params){
			// should be overridden in the corresponding service implementations
		}

	}, {});

	/**
	 * The REST service class
	 */
	salServiceImpl.Class("RestService", salServiceImpl.ServiceBase, {

		apiVersion : "",

		__constructor : function(parent){

			// initialize SAL
			salServiceImpl.SAL.init();

			this.__base(parent);
			this.apiVersion = "v24.0"; //TODO : Pick up from the configuration
		},

		callApiAsync : function(params){
            var profiler = this._profiler;
            var profileName = params.methodName;
            var profileAction = "fetch";
            var profileType = this.getClassName()+"APIAsync";

            var rr = new salServiceImpl.RestRequest({
                sessionId: this._parent.params.sessionId,
                apiVersion: this.apiVersion
            });

            rr.bind("REQUEST_COMPLETED", this._callMethodAsyncSuccess, this);
            rr.bind("REQUEST_ERROR", this._callMethodAsyncError, this);

            profiler.begin(profileName, profileType, profileAction);
            rr.callAsync({
                url: params.url,
                method: "GET",
                data: params.data,
                responseType: params.responseType
            })
            .always(function(){   
                profiler.end(profileName, profileType, profileAction);
            })
            .then(function(){
                profiler.raiseEvent("REFRESH_CONTENT");
            });
		},

		callMethod : function(params){
			params.async = false;
			this.callMethodAsync(params);
		},

		callMethodAsync : function(params){
            var profiler = this._profiler;
            var profileName = params.methodName;
            var profileAction = "fetch";
            var profileType = this.getClassName()+"MethodAsync";

            var nameSpace = this._parent.params.nameSpace != undefined ? this._parent.params.nameSpace : "SVMXC";
            var endPoint = this._parent.params.endPoint != undefined ? this._parent.params.endPoint : "NO_END_POINT";
            var methodName = params.methodName;
            var svmxServiceVersion = this._parent.params.svmxServiceVersion;

            var url = nameSpace + "/svmx/rest/" + endPoint + "/" + methodName + "/" + svmxServiceVersion + "/";

            // overriding parameters
            var async = true;
            if (params.async != undefined) async = params.async;
            // end

            var rr = new salServiceImpl.ApexRestRequest({
                sessionId: this._parent.params.sessionId,
                apiVersion: this.apiVersion
            });
            rr.bind("REQUEST_COMPLETED", this._callMethodAsyncSuccess, this);
            rr.bind("REQUEST_ERROR", this._callMethodAsyncError, this);

            profiler.begin(profileName, profileType, profileAction);
            rr.callAsync({
                url: url,
                method: this.__getHttpMethodType(methodName),
                data: params.data,
                async: async
            })
            .always(function(){
                //mark the end time
               profiler.end(profileName, profileType, profileAction);
            })
            .then(function(){  
                profiler.raiseEvent("REFRESH_CONTENT");
            });
		},

		__getHttpMethodType : function(methodName){
			// calculate the http method
			// for GET    ->  get,    retrieve, obtain, query
			// for POST   ->  post,   submit,   create, modify, update, alter
			// for DELETE ->  delete, remove
			var method = "";
			if(this.__findIn(methodName, ["get", "retrieve", "obtain", "query"], 0))
				//method = "GET"; //TODO: Not yet working on server!!!
				  method = "POST";
			else if(this.__findIn(methodName, ["post", "submit", "create", "modify", "update", "alter", "save", "add"], 0))
				method = "POST";
			else
				throw new Error("Unsupported method type");

			return method;
		},

		__findIn : function(strItem, strList, atIndex){
			var len = strList.length;
			for(var i = 0; i < len; i++){
				if(strItem.indexOf(strList[i]) == atIndex)
					return true;
			}
			return false;
		},

		_callMethodAsyncSuccess : function(evt){
			var evtObj = new salServiceImpl.ServiceEvent("REQUEST_COMPLETED", this, evt.data);
			this.triggerEvent(evtObj);
		},

		_callMethodAsyncError : function(evt){
			var evtObj = new salServiceImpl.ServiceEvent("REQUEST_ERROR", this, evt.data);
			this.triggerEvent(evtObj);
		}

	}, {});

	/**
	 * The Local service class
	 * TODO:
	 */
	salServiceImpl.Class("LocalService", salServiceImpl.ServiceBase, {}, {});

	/**
	 * The SOAP service class
	 * TODO:
	 */
	salServiceImpl.Class("SoapService", salServiceImpl.ServiceBase, {
		apiVersion : "",

		__constructor : function(parent){

			// initialize SAL
			salServiceImpl.SAL.init();

			this.__base(parent);
			this.apiVersion = "9.0"; //TODO : Pick up from the configuration
		},

		callMethodAsync : function(params){
			var nameSpace = this._parent.params.nameSpace !== undefined ? this._parent.params.nameSpace : "SVMXC";
			var endPoint = this._parent.params.endPoint != undefined ? this._parent.params.endPoint : "NO_END_POINT";
			var methodName = params.methodName;

			var url = this.__getOrgNamespace(nameSpace) + endPoint;

			var sr = new salServiceImpl.ApexSoapRequest({sessionId :this._parent.params.sessionId,
				apiVersion : this.apiVersion, endPoint : endPoint, nameSpace : nameSpace});
			sr.bind("REQUEST_COMPLETED", this._callMethodAsyncSuccess, this);
			sr.bind("REQUEST_ERROR", this._callMethodAsyncError, this);
			sr.callAsync({url : url, methodName : methodName, data : params.data});
		},

		callApiSync : function(params){
			var metadataApiVersion = "19";

			var sr = new salServiceImpl.SoapRequest({sessionId :this._parent.params.sessionId,
				apiVersion : metadataApiVersion});
			sr.bind("REQUEST_COMPLETED", this._callMethodAsyncSuccess, this);
			sr.bind("REQUEST_ERROR", this._callMethodAsyncError, this);
			sr.callAsync({url : "", methodName : params.methodName, data : params.data});
		},

		__getOrgNamespace : function(orgNameSpace){
			if(orgNameSpace != null && orgNameSpace != '') return orgNameSpace + "/";
			else return "";
		},

		_callMethodAsyncSuccess : function(evt){
			var evtObj = new salServiceImpl.ServiceEvent("REQUEST_COMPLETED", this, evt.data);
			this.triggerEvent(evtObj);
		},

		_callMethodAsyncError : function(evt){
			var evtObj = new salServiceImpl.ServiceEvent("REQUEST_ERROR", this, evt.data);
			this.triggerEvent(evtObj);
		}
	}, {});

	/**
	 * The REST service manager class
	 */
	salServiceImpl.Class("RestServiceManager", com.servicemax.client.lib.api.Object, {
		params : null,

		__constructor : function(params){
			this.params = params;
		},

		createService : function(){
			return SVMX.create("com.servicemax.client.sal.impl.RestService", this);
		}
	}, {});

	/**
	 * The SOAP service manager class
	 */
	salServiceImpl.Class("SoapServiceManager", com.servicemax.client.lib.api.Object, {
		params : null,

		__constructor : function(params){
			this.params = params;
		},

		createService : function(){
			return new salServiceImpl.SoapService(this);
		}
	}, {});

	/**
	 * The service manager factory
	 */
	salServiceImpl.Class("ServiceManagerFactory", com.servicemax.client.lib.api.Object, {

		__constructor : function(){

		},

		createServiceManager : function(params){
			if(!params) params = {};

			// serviceMax Service API Version
			params.svmxServiceVersion = SVMX.getClient().getApplicationParameter("svmx-api-version");

			// sfdc session id
			params.sessionId = SVMX.getClient().getApplicationParameter("session-id");

			if(params.type == "SOAP")
				return new salServiceImpl.SoapServiceManager(params);
			else
				return new salServiceImpl.RestServiceManager(params);
		}

	}, { });

})();

// end of file