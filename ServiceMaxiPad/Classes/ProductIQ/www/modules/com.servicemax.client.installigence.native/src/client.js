/**
 * Reference implementation for native interface
 * @class com.servicemax.client.nativeservice
 * @singleton
 * @author Swaminathan.S.R
 *
 * @copyright 2013 ServiceMax, Inc.
 */
(function(){

	var nativeImpl = SVMX.Package("com.servicemax.client.nativeservice");
	var callRegistry = {}, callId = 0;
	var pagedResponseRegistry = {};

nativeImpl.init = function(){

	nativeImpl.Class("Client", com.servicemax.client.installigence.offline.sal.model.nativeservice.AbstractClient, {}, {

		execute : function(params){

			var cid = "id" + ++callId;

				var dataParams = new Object();
				var type;
				var methodName;

				switch (params.type)
				{
					case "DOWNLOAD":

						type = "HTTP";
						params.operation = "DOWNLOAD";
						dataParams.SourceObject = params.parameters.sourceObject;
						dataParams.RecordId = params.parameters.recordId;
						dataParams.FileName = params.parameters.file;
						break;

					case "UPLOAD":

						type = "HTTP";
						params.operation = "UPLOAD";
						dataParams.ParentId = params.parameters.parentId;
						dataParams.FilePath = params.parameters.file;
                        dataParams.FileName = params.parameters.name;
						break;

					case "HTTP":
						type = "HTTP";

						switch(params.operation)
						{
							default:
										dataParams.Uri = params.parameters.url;
									// TODO: Evaluate optimizing the conversions reqd on the request body. 	//presently there are totally 3 //  // conversions
									if (typeof (params.parameters.data) === "object")
									{
										dataParams.RequestBody = SVMX.toJSON(params.parameters.data);
									}
									else {
										dataParams.RequestBody = params.parameters.data;
									}


									dataParams.RequestMethod = params.parameters.method;

									var headerCollection = new Array();
									var index = 0;

									for (prop in params.parameters.headers) {
										headerCollection[index] = new Object();
										headerCollection[index].Header = prop;
										headerCollection[index].Value = params.parameters.headers[prop];
										++index;
									}

									dataParams.HttpRequestHeaders = SVMX.toJSON(headerCollection);
									break;

								}
						break;
					case "SQL":
						type = "SQL";
						dataParams.SQL = params.parameters.query;

						// INDRESH: Quick fix until the db sync issues are solved.
						//params.parameters.async = false;
						break;
					case "TRACE":
						type = "LOG";
						params.operation = "TRACE";
						dataParams.Message = params.parameters.message;
						break;
					case "REPORT":
						type = "GENERATEREPORT";
						params.operation = "DEFAULT";
						dataParams.RecordId = params.parameters.recId;
						dataParams.TemplateName = params.parameters.processId;
						break;
					case "LOG":
						type = "LOG";
						params.operation = "LOG";
						break;
					case "CONNECTIVITY":
						type = "CHECKCONNECTIVITY";
						break;
                    case "LOGININFO":
						type = "MISC";
						params.operation = "LOGININFO";
						break;
					case "SIGNOUT":
						type = "MISC";
						params.operation = "SIGNOUT";
						break;
					case "EXIT":
						type = "MISC";
						params.operation = "EXIT";
						break;
					case "SMS":
						type = "MISC";
						params.operation = "SMS";
						dataParams.phone = params.parameters.phone;
						dataParams.message = params.parameters.message;
						break;
					case "TEL":
						type = "MISC";
						params.operation = "TEL";
						dataParams.phone = params.parameters.phone;
						break;
					case "GEO":
						type = "MISC";
						params.operation = "GEO";
						dataParams.street = params.parameters.street;
						dataParams.city = params.parameters.city;
						dataParams.state = params.parameters.state;
						dataParams.zipcode = params.parameters.zipcode;
						dataParams.latitude = params.parameters.latitude;
						dataParams.longitude = params.parameters.longitude;
						break;
					case "BROWSER":
						type = "MISC";
						params.operation = "BROWSER";
						dataParams.link = params.parameters.link;
						break;
					case "FILE":
						type = "FILEIO";

						switch(params.parameters.operation.toUpperCase())
						{
							case "READ":
								params.operation = "READTEXTFILE";
								dataParams.FileName = params.parameters.file;
								break;

							case "WRITE":
								params.operation = "WRITE";
								dataParams.WriteContent = params.parameters.data;
								dataParams.FileName = params.parameters.file;
								break;

							case "APPEND":
								params.operation = "WRITELINE";
								dataParams.WriteContent = params.parameters.data;
								dataParams.FileName = params.parameters.file;
								break;

							case "COPY":
								params.operation = "COPYFILE";
								dataParams.FilePath = params.parameters.file;
								dataParams.TargetFileName = params.parameters.targetFile;
								dataParams.DestinationPath = params.parameters.targetPath;
								break;

							case "DELETE":
								params.operation = "DELETEFILE";
								dataParams.FilePath = params.parameters.file;
								break;

							case "EXECUTE":
								params.operation = "OPENFILE";
								dataParams.FilePath = params.parameters.file;
								break;

							case "INFO":
								params.operation = "FILEINFO";
								dataParams.FilePath = params.parameters.file;
								break;

							case "SELECT":
								params.operation = "BROWSEANDCOPYFILE";
								dataParams.MultiSelect = params.parameters.multiSelect;
								dataParams.DestinationPath = params.parameters.targetPath;
								break;
						}
						break;
					case "INSTALLATIONS":
						type = "MISC";
						params.operation = "GETDOWNLOADFOLDERPATH";
						break;
					case "SIGNATURECAPTURE":
						type = "SIGNATURECAPTURE";
						params.operation = "DEFAULT";
						dataParams.recordId = params.parameters.recordId;
						dataParams.processId = params.parameters.processId;
						dataParams.uniqueName = params.parameters.uniqueName;
						break;
					case "GENERATEPDF":
						type = "MISC";
						params.operation = "GENERATEPDF";
						dataParams.recordId = params.parameters.recordId;
						dataParams.processId = params.parameters.processId;
						dataParams.sourceRecord = params.parameters.sourceRecord;
						dataParams.htmlContent = params.parameters.htmlContent;
						break;
					case "CHECKEXTERNAL":
						type = "EXTERNALAPP";
						params.operation = "APPINFO";
						dataParams.AppName = params.parameters.AppName;
						break;
					case "SENDEXTERNAL":
						type = "EXTERNALAPP";
						params.operation = "SENDMESSAGE";
						dataParams.AppName = params.parameters.AppName;
						dataParams.externalRequest = params.parameters.externalRequest;
						break;
					case "SETEXTERNALHANDLER":
						type = "SETMESSAGEHANDLER";
						params.operation = "SETMESSAGEHANDLER";
						dataParams.handler = params.parameters.handler;
						break;
					case "DATAACCESSAPI":
						type = "DATAACCESSAPI";
						params.operation = params.method;
						dataParams.objectName = params.parameters.objectName;
						dataParams.fields = params.parameters.fields;
						dataParams.criteria = params.parameters.criteria;
						dataParams.userName = params.parameters.userName;
						dataParams.records = params.parameters.records;
						dataParams.query = params.parameters.query;
						dataParams.handler = params.parameters.handler;
						dataParams.recordIds = params.parameters.recordIds;
						break;
					case "APPLICATIONFOCUS":
						type = "APPLICATIONFOCUS";
						params.operation = "APPLICATIONFOCUS";
						dataParams.handler = params.parameters.handler;
						break;
					default:
						throw "Type not supported.";
				}

				if (params.operation)
				{
					switch (params.operation)
					{
						case  "":
							methodName = "default";
						default:
							methodName = params.operation;
					}
				}
				else
				{
					methodName = "default";
				}
				callRegistry[cid] = params.callback;

				var inputCommand = new Object();
				inputCommand.MethodName = methodName;
				inputCommand.Type = type;
				inputCommand.RequestId = cid;
				inputCommand.IsAsync = params.parameters.async;

				var date = new Date();
				inputCommand.OriginateTime = date.getTime();
				if (params.parameters.async)
				{
					inputCommand.IsAsync = params.parameters.async;
				}
				else
				{
					inputCommand.IsAsync = false;
				}
				inputCommand.jsCallback = "nativeCallback";

				inputCommand.ParameterString = SVMX.toJSON(dataParams);

		inputCommand.TotalPages = 1;
		inputCommand.CurrentPage = 1;
		// Swami : defect#8634 fix
		// check the length of request
		// if > 1 MB, loop it. identify the # loop counters
		// call the execute method as many number of times, with diff current page# and same total Pages
		// In the native side these requests would be stitched to form the full request, to be executed.
		var tempParameterString = inputCommand.ParameterString;
		var lenLimit = 100000;
		if (inputCommand.ParameterString.length > lenLimit)
		//if (1==0)
		{
			//alert('in len exceed chk');
			//page the req
			totalPages = Math.ceil(inputCommand.ParameterString.length /lenLimit);
			inputCommand.TotalPages = totalPages;
			var counter = 0;
			for (counter=0; counter < totalPages; counter ++){
				inputCommand.CurrentPage = counter+1;
				inputCommand.ParameterString = tempParameterString.substr(counter*lenLimit, lenLimit)
				retVal = window.external.execute(JSON.stringify(inputCommand));
			}
		}
		else{
			retVal = window.external.execute(JSON.stringify(inputCommand));
		}

/*				try
				{
					retVal = window.external.execute(SVMX.toJSON(inputCommand));
				}
				catch (err) { throw err; }
*/
				return retVal;
		},

		nativeCallback : function(response){
			//response = response.toArray();
			response = SVMX.toObject(response);

			var cid = response.RequestId;
			var callInfo = callRegistry[cid];

			var inputCommand = new Object();
			inputCommand.RequestId = response.RequestId;
			inputCommand.Type = 'LOG' ;
			inputCommand.MethodName= 'LOG';
			inputCommand.IsAsync = 'true';
			inputCommand.TotalPages = '1';
			var logging = new Object();
			logging.LogLevel = 'DEBUG';
			logging.Source = 'JS';
			logging.CorrelationId = response.RequestId;
			logging.Message = 'Response received in JS callback with response status: ' + response.Status + ' for Page: ' + response.CurrentPage + ' of Total Pages: ' + response.TotalPages;
			inputCommand.ParameterString = SVMX.toJSON(logging);
			window.external.execute(SVMX.toJSON(inputCommand));

            //console.log ("Response received for cid:" + cid);
			//console.log ("callback handler for cid:" + callInfo.handler);

		var pagedResponseIndex;
		//alert("callback invoked");
		var currentPage = response.CurrentPage;
		var totalPages = response.TotalPages;
        //console.log ("Response received for cid:" + cid);
		//console.log ("currentPage.totalPages:" + currentPage + "." + totalPages);


			if (currentPage == totalPages){
			//condition for last page or single page response
			// get all the page recs
			//then process response and fire callback.
			pagedResponseIndex = cid + "." + currentPage;
			//console.log ("Response received for cid.pid:" + pagedResponseIndex);
			pagedResponseRegistry[pagedResponseIndex] = response.Result;

			//console.log ("last page has come for req:" + cid);
			//now get all the page responses
			var pageCounter = 1;
			var consPageResponse = "";
			for (pageCounter = 1; pageCounter < totalPages+1; pageCounter++){
			//console.log ("inside consolidation..");
			//console.log (cid + "." + pageCounter + ">>>>" + pagedResponseRegistry[cid + "." + pageCounter]);
				consPageResponse = consPageResponse + pagedResponseRegistry[cid + "." + pageCounter];
			        delete pagedResponseRegistry[cid + "." + pageCounter];
			//console.log ("consPageResponse>>>>" + consPageResponse);
			}
			//console.log ("paged Response already received>> " + pagedResponseRegistry["id1.1"]);
			//console.log ("paged Response currently received>> " + response.Result);
			//console.log ("final response>>>>" + consPageResponse);
			response.Result = consPageResponse;
			//document.getElementById("txtResponse").value =
			}
			else{
				//condition for intermediate pages
				//put the response in memory
				//console.log (currentPage + "st page has come");
				pagedResponseIndex = cid + "." + currentPage;
				//console.log ("Response received for cid.pid:" + pagedResponseIndex);
				pagedResponseRegistry[pagedResponseIndex] = response.Result;
				// exit the function
				return 1;
			}




		//console.log ("This msg should come only for the last page.");
		if (currentPage != totalPages){
			return;
		}
		//alert("continuing with resp processing..after consolidating page data");


			// The structure of the response array is as follows:
			// response[0] = type; response[1]= methodname; response[2]=3 props: response string, status code,  esponse headers
			// response[3]=cid;
			// response[4]=success status in boolean


            var interimResp = response.Result;
            var finalResp = new Object(), respHeaderColl;
            finalResp.success = response.Status;

            switch (response.Type)
            {
                case "HTTP":

					switch(response.MethodName)
					{
						default:
							finalResp.headers = new Object();
					       	if(response.Status !== false && response.MethodName != "DOWNLOAD"){
					       		interimResp = SVMX.toObject(interimResp);
					       		respHeaderColl = SVMX.toObject(interimResp.ResponseHeaders);

					       		for (hdr in respHeaderColl) {
					       			finalResp.headers[respHeaderColl[hdr].Header] = respHeaderColl[hdr].Value;
					       		}

					       		finalResp.data = interimResp.ResponseBody;
					       		finalResp.status = interimResp.StatusCode;
					       	}else{
					       		finalResp.data = interimResp;
					       	}
							break;
					}
					if (response.MethodName == "UPLOAD")
					{
						finalResp.data = SVMX.toObject(finalResp.data);
					}

                    break;

                case "SQL":
                    finalResp.data = interimResp || [];
                    finalResp.success = response.Status;
                    break;
				case "GENERATEREPORT":
                    finalResp.fileLocation = interimResp || [];
                    finalResp.success = response.Status;
                    break;
				case "SIGNATURECAPTURE":
                    finalResp.fileLocation = interimResp || [];
                    finalResp.success = response.Status;
                    break;
				case "CHECKCONNECTIVITY":
					finalResp.data = response.Result;
					finalResp.success = response.Status;
					break;
                case "MISC":
                    if (response.MethodName == "GENERATEAPIKEY") {
                        var TS = SVMX.getClient().getServiceRegistry().getServiceInstance("com.servicemax.client.translation");
                        var buttonLabelText = TS.T("IPAD.IPAD011_TAG014", "Copy to Clipboard");
                        var messageBoxTitle = TS.T("ContainerTags.TAG0013", "API Access Key");
                        var messageBox = SVMX.getCurrentApplication().getApplicationMessageUIHandler();

                        messageBox.showMessage({
                            title: messageBoxTitle,
                            type: "CUSTOM",
                            text: '<span style="text-align: center;">' + response.Result+ '</span>',
                            closable: true,
                            buttons: [{
                                text: buttonLabelText,
                                handler: function () {
								    var text_val = response.Result.toString();
                                    var copyDiv = document.createElement('div');

                                    copyDiv.contentEditable = true;
                                    document.body.appendChild(copyDiv);
                                    copyDiv.innerHTML = text_val;
                                    copyDiv.unselectable = "off";
                                    copyDiv.focus();

                                    document.execCommand('SelectAll');
                                    document.execCommand("Copy", false, null);
                                    document.body.removeChild(copyDiv);

                                }

                            }]
                        });
                    }
                    else {
                    }
                    interimResp = SVMX.toObject(interimResp);
                    finalResp.data =  interimResp && interimResp[0];
                    finalResp.success = response.Status;
					break;
				case "FILEIO":
					switch(response.MethodName) {
						case "BROWSEANDCOPYFILE":
							finalResp.data = SVMX.toObject(response.Result);
							break;
						case "FILEINFO":
							var result = response.Result.replace(/\\/g, "/");
							finalResp.data = SVMX.toObject(result);
							break;
						default:
							finalResp.data = response.Result;
					}
					finalResp.success = response.Status;
					break;
				case 'DATAACCESSAPI':
				case 'EXTERNALAPP':
				case 'SETMESSAGEHANDLER':
				case 'APPLICATIONFOCUS':	
					finalResp.data = response.Result;
					finalResp.success = response.Status;
					break;
				default:
                    break;
            }
			// get second obj's struc.
			// For resp header do reverse of what hpns in req;
			// actual response shud be in wellformed json string
			// status code should be in number
			try{
				//console.log ("callback to be fired for cid:" + cid);
			    callInfo && callInfo.handler.call(callInfo.context, finalResp);
				//console.log ("callback fired for cid:" + cid);
			}
			catch (err) {
			    //alert('Error in com.servicemax.client.nativeservice.laptop callback function.: ' + err.message);
			}
			callRegistry[cid] = null;
			//delete callRegistry[cid];
		}
	});

		// global native client callback handler
	window.nativeCallback = function(response){
	    nativeImpl.Client.nativeCallback(response);

	};

	if (SVMX._debugDiv) {
 		var logCache = SVMX._debugDiv.innerHTML.split(/\<BR\/?\>/i);

		SVMX.array.forEach(logCache, function(log) {
			com.servicemax.client.nativeservice.Client.execute({
				type : com.servicemax.client.offline.sal.model.nativeservice.AbstractClient.TRACE,
				parameters : { message : log},
				callback : { handler : function(response){}, context : {}}
			});
		});
		document.body.removeChild(SVMX._debugDiv);
		delete SVMX._debugDiv;
	}
}
})();

// end of file