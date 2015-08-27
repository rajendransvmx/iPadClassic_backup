/**
 * Service facade provides a concrete interface for interacting with native services
 * @author Eric Ingram
 * @class com.servicemax.client.offline.sal.model.nativeservice
 *
 * @copyright 2013 ServiceMax, Inc.
 */
(function(){

	var nativeImpl = SVMX.Package("com.servicemax.client.installigence.offline.sal.model.nativeservice");

nativeImpl.init = function(){

	nativeImpl.Class("Facade", com.servicemax.client.lib.api.Object, {}, {
		__logger : SVMX.getLoggingService().getLogger("NATIVE-SERVICE-FACADE-IMPL"),
		__nativeService : com.servicemax.client.nativeservice,

		createRequest : function(className, callback){
			var request = SVMX.create("window.com.servicemax.client.installigence.offline.sal.model.nativeservice."+className, this);
			if(callback && callback.handler){
				callback.handler.call(callback.handler.context, request);
			}else if (!callback) {
				return request;
			}
		},

		createHTTPRequest : function(callback){
			return this.createRequest("HTTPRequest", callback);
		},

		createSQLRequest : function(callback){
			return this.createRequest("SQLRequest", callback);
		},

		createInstallationsRequest : function(callback){
			return this.createRequest("InstallationsRequest", callback);
		},

		createSignatureCaptureRequest : function(callback){
			return this.createRequest("SignatureCaptureRequest", callback);
		},

		createPDFRequest : function(callback){
			return this.createRequest("GeneratePDFRequest", callback);
		},

		createTraceRequest : function(callback){
			return this.createRequest("TraceRequest", callback);
		},

		createFileRequest : function(callback){
			return this.createRequest("FileRequest", callback);
		},

		createReportRequest : function(callback){
			return this.createRequest("ReportRequest", callback);
		},

		createUploadRequest : function(callback){
			return this.createRequest("UploadRequest", callback);
		},

        createConnectivityRequest : function(callback){
            return this.createRequest("ConnectivityRequest", callback);
        },

        createLoginInfoRequest : function(callback){
            return this.createRequest("LoginInfoRequest", callback);
        },

        createSignOutRequest : function(callback){
            return this.createRequest("SignOutRequest", callback);
        },

        createExitRequest : function(callback){
            return this.createRequest("ExitRequest", callback);
        },

        createSMSRequest : function(callback){
            return this.createRequest("SMSRequest", callback);
        },

        createTELRequest : function(callback){
            return this.createRequest("TELRequest", callback);
        },

        createGEORequest : function(callback){
            return this.createRequest("GEORequest", callback);
        },

        createBrowserRequest : function(callback){
            return this.createRequest("BrowserRequest", callback);
        },

        createCheckExternalRequest : function(callback){
            return this.createRequest("CheckExternalRequest", callback);
        },

        createSendExternalRequest : function(callback){
            return this.createRequest("SendExternalRequest", callback);
        },

        createSetExternalHandlerRequest : function(callback){
            return this.createRequest("SetExternalHandlerRequest", callback);
        },
        
        createDataAccessAPIRequest : function(callback){
            return this.createRequest("DataAccessAPIRequest", callback);
        },

        createCheckExternalRequest : function(callback){
            return this.createRequest("CheckExternalRequest", callback);
        },

        createSendExternalRequest : function(callback){
            return this.createRequest("SendExternalRequest", callback);
        },

        createSetExternalHandlerRequest : function(callback){
            return this.createRequest("SetExternalHandlerRequest", callback);
        },

        createApplicationFocusRequest : function(callback){
            return this.createRequest("ApplicationFocusRequest", callback);
        },

		execute : function(request, command){
			if(!this.__nativeService.Client){
				this.__logger.error('Native client interface is not available');
				return;
			}

            command.parameters = command.parameters || {};
			if (command.parameters.async === undefined) {
			     command.parameters.async = true;
			}

			command.callback = {
				handler : function(response){
					response.parameters = command.parameters;
					this._executeResponse(request, response);
				},
				context : this
			};

            if(SVMX.getClient().getApplicationParameter("sal-native-testing")){
                this._executeResponse(request, {test: true});
            }else{
            	try{
                    this.__nativeService.Client.execute(command);
    			}catch(err){
    				this.__logger.error(err+'. Unable to call native async method: '+command.type);
    				this._executeResponse(request, err);
    			}
            }
		},

		_executeResponse : function(request, response){
			if(request){
			    if (response instanceof Error) {
			        request._executeError({
			            data: response.toString()
			        });
				} else if(response && !(!response.success || response.success === "false")){
					request._executeSuccess(response);
				}else{
					request._executeError(response);
				}
			}
		}
	});

	/**
	 * Native service request base class
	 */
	nativeImpl.Class("ServiceRequest", com.servicemax.client.lib.api.EventDispatcher, {
		__parent : null, __command : null,

		__constructor : function(parent, uniqueId){
			this.__parent = parent;
			this.__base();
		},

		execute : function(command){
			this.__parent.execute(this, command);
		},

		_executeSuccess : function(response){
			var evtObj = new nativeImpl.ServiceRequestEvent("REQUEST_COMPLETED", this, response);
			this.triggerEvent(evtObj);
		},

		_executeError : function(response){
			var evtObj = new nativeImpl.ServiceRequestEvent("REQUEST_ERROR", this, response);
			this.triggerEvent(evtObj);
		}
	}, {});

    /**
     * Native sign out service request
     */
    nativeImpl.Class("SignOutRequest", nativeImpl.ServiceRequest, {
        execute : function(params){
            var command = {
                type : nativeImpl.AbstractClient.SIGNOUT,
                parameters : {}
            };
            return this.__base(command);
        }
    }, {});

    /**
     * Native exit service request
     */
    nativeImpl.Class("ExitRequest", nativeImpl.ServiceRequest, {
        execute : function(params){
            var command = {
                type : nativeImpl.AbstractClient.EXIT,
                parameters : {}
            };
            return this.__base(command);
        }
    }, {});

    /**
     * Native SMS service request
     */
    nativeImpl.Class("SMSRequest", nativeImpl.ServiceRequest, {
        execute : function(params){
            var command = {
                type : nativeImpl.AbstractClient.SMS,
                parameters : {
                    phone   : params.phone || "",
                    message : params.message || ""
                }
            };
            return this.__base(command);
        }
    }, {});

    /**
     * Native Telephone service request
     */
    nativeImpl.Class("TELRequest", nativeImpl.ServiceRequest, {
        execute : function(params){
            var command = {
                type : nativeImpl.AbstractClient.TEL,
                parameters : {
                    phone   : params.phone || ""
                }
            };
            return this.__base(command);
        }
    }, {});

    /**
     * Native Geo/Map service request
     */
    nativeImpl.Class("GEORequest", nativeImpl.ServiceRequest, {
        execute : function(params){
            var command = {
                type : nativeImpl.AbstractClient.GEO,
                parameters : {
                    street  : params.street || "",
                    city    : params.city || "",
                    state   : params.state || "",
                    zipcode : params.zipcode || "",
                    latitude : params.latitude || "0",
                    longitude : params.longitude || "0"
                }
            };
            return this.__base(command);
        }
    }, {});

    /**
     * Native Browser service request.
     * Used by mobile devices to open a browser. To be used when an anchor's
     * target attribute cannot be expected to open a new window.
     */
    nativeImpl.Class("BrowserRequest", nativeImpl.ServiceRequest, {
        execute : function(params){
            var command = {
                type : nativeImpl.AbstractClient.BROWSER,
                parameters : {
                    link  : params.link || ""
                }
            };
            return this.__base(command);
        }
    }, {});

	/**
	 * Native HTTP service request
	 */
	nativeImpl.Class("HTTPRequest", nativeImpl.ServiceRequest, {
		execute : function(params){
			var command = {
				type : nativeImpl.AbstractClient.HTTP,
				parameters : {
					url : params.uri || params.url,
					method : params.method || "GET",
					headers : params.headers || {},
					data : params.data
				}
			};
			if(params.upload){
				command.parameters.upload = params.upload;
			}
			if(params.download){
				command.parameters.download = params.download;
			}
			if(!command.parameters.headers["Content-Type"]){
				command.parameters.headers["Content-Type"] = "application/json";
			}
			if(command.parameters.headers["Content-Type"] == "application/json"){
				command.parameters.data = SVMX.toJSON(command.parameters.data);
			}
			this.__command = command;
			return this.__base(this.__command);
		},
		_executeSuccess : function(response){
			var commandHeaders = this.__command.parameters.headers;
			if (commandHeaders && commandHeaders["Content-Type"] == "application/json"){
				if(typeof response.data == "string" && response.data != "Success"){
					// check for spliced errors from the server
					var serverError = '[{"message":"An unexpected error occurred.","errorCode":"UNKNOWN_EXCEPTION"}]';
					if(response.data.substring(response.data.length-(serverError.length)) === serverError){
						response.data = serverError;
						this._executeError(response);
						return;
					}
					var origData = response.data;
					try{ response.data = SVMX.toObject(response.data.replace(/(\r|\n)+/g, "&#10;")); }
					catch(err){ response.data = origData; }
				}
			}
			this.__base(response);
		}
	}, {});

	/**
	 * Native SQL service request
	 */
	nativeImpl.Class("SQLRequest", nativeImpl.ServiceRequest, {
		execute : function(params){
			if (params.queryParams) params.query = SVMX.string.substitute(params.query,params.queryParams);
			var command = {
				type : nativeImpl.AbstractClient.SQL,
				parameters : {
					query : params.query,
					async : params.async,
					count : "count" in params ? params.count + 1 : 0
				}
			};
			return this.__base(command);
		},
		_executeSuccess : function(response){
			var origData = response.data;
			try{
				if (typeof response.data === "string" && response.parameters.query.match(/^\s*SELECT/i)) {
					response.data =  SVMX.toObject(response.data.replace(/(\r|\n)+/g, "&#10;"));
				}
			}
			catch(err){ response.data = origData; }
			try {
				this.__base(response);
			} catch(e) {
                /*
                 * We need to consider revising the error handling at some point.
                 * This can cause some modules to hang ie SFMSearch
                 */

                SVMX.getLoggingService().getLogger("NATIVE-SERVICE-FACADE-IMPL")
				.error("Error in event handler: " + e + "(" + response.parameters.query + ")");
			}
		}
	}, {});

	/**
	 * Installation related data operation request
	 */
	nativeImpl.Class("InstallationsRequest", nativeImpl.ServiceRequest, {
		execute : function(params){
			var command = {
				type : nativeImpl.AbstractClient.INSTALLATIONS,
				parameters : {
					operation : params
				}
			};
			return this.__base(command);
		}
	}, {});

	/**
	 * Native generate pdf request
	 */
	nativeImpl.Class("GeneratePDFRequest", nativeImpl.ServiceRequest, {
		execute : function(params){
			var command = {
				type : nativeImpl.AbstractClient.GENERATEPDF,
				parameters : {
					operation : params,
					recordId : params.recordId,
					processId : params.processId,
					htmlContent : params.htmlContent,
					sourceRecord: params.sourceRecord,
					callback: params.callback,
					context: params.context
				}
			};
			return this.__base(command);
		}
	}, {});

	/**
	 * Native signature capture request
	 */
	nativeImpl.Class("SignatureCaptureRequest", nativeImpl.ServiceRequest, {
		execute : function(params){

			var command = {
				type : nativeImpl.AbstractClient.SIGNATURECAPTURE,
				parameters : {
					operation : params,
					recordId : params.recordId,
					processId : params.processId,
					uniqueName : params.uniqueName
				}
			};
			return this.__base(command);
		}
	}, {});

	/**
	 * Native file service request
	 */
	nativeImpl.Class("FileRequest", nativeImpl.ServiceRequest, {
		execute : function(params){
			var command = {
				type : nativeImpl.AbstractClient.FILE,
				parameters : params
			};
			var validOperations = [
				"READ", "WRITE", "APPEND", "COPY", "DELETE", "EXECUTE", "SELECT", "INFO"
			];
			if(params.operation && validOperations.indexOf(params.operation.toUpperCase()) === -1){
				throw "File operation not supported: "+params.operation;
			}
			return this.__base(command);
		}
	}, {});

	/**
	 * Native trace service request
	 */
	nativeImpl.Class("TraceRequest", nativeImpl.ServiceRequest, {
		execute : function(params){
			var command = {
				type : nativeImpl.AbstractClient.TRACE,
				parameters : {
					message : params.message
				}
			};
			return this.__base(command);
		}
	}, {});

	/**
	 * Native output doc report request
	 */
	nativeImpl.Class("ReportRequest", nativeImpl.ServiceRequest, {
		execute : function(params){
			var command = {
				type : nativeImpl.AbstractClient.REPORT,
				parameters : {
					recId : params.recId,
					processId : params.processId
				}
			};
			return this.__base(command);
		}
	}, {});

	/**
	 * Native download attachment request
	 */
	nativeImpl.Class("DownloadRequest", nativeImpl.ServiceRequest, {
		execute : function(params){
			var command = {
				type : nativeImpl.AbstractClient.DOWNLOAD,
				parameters : {
                    sourceObject : params.sourceObject,
					recordId : params.recordId,
					file : params.file
				}
			};
			return this.__base(command);
		}
	}, {});

	/**
	 * Native upload attachment request
	 */
	nativeImpl.Class("UploadRequest", nativeImpl.ServiceRequest, {
		execute : function(params){
			var command = {
				type : nativeImpl.AbstractClient.UPLOAD,
				parameters : {
					parentId : params.parentId,
					file : params.file,
                    name : params.name
				}
			};
			return this.__base(command);
		}
	}, {});
	
	/**
     * Native Data Access API service request
     */
    nativeImpl.Class("DataAccessAPIRequest", nativeImpl.ServiceRequest, {
        execute : function(params){
            var command = {
                type : nativeImpl.AbstractClient.DATAACCESSAPI,
                method: params.method,
                parameters : {                	
                	objectName : params.objectName,
            		fields : params.fields,
            		criteria : params.criteria,
            		records : params.records,
            		userName : params.userName,
            		recordIds : params.recordIds,
            		query : params.query
                }
            };
            return this.__base(command);
        }
    }, {});

    /**
     * Native connectivty check request
     */
    nativeImpl.Class("ConnectivityRequest", nativeImpl.ServiceRequest, {
        execute : function(params){
            var command = {
                type : nativeImpl.AbstractClient.CONNECTIVITY,
                parameters : {}
            };
            return this.__base(command);
        }
    }, {});

    /**
     * Native login info request
     */
    nativeImpl.Class("LoginInfoRequest", nativeImpl.ServiceRequest, {
        execute : function(params){
            var command = {
                type : nativeImpl.AbstractClient.LOGININFO,
                parameters : {}
            };
            return this.__base(command);
        }
    }, {});
    
    /**
     * Check if a specified external application is installed.
     * This only checks for special applications like the one used
     * for Installed Base.
     */
    nativeImpl.Class("CheckExternalRequest", nativeImpl.ServiceRequest, {

        execute : function(params){
            var command = {
                type : nativeImpl.AbstractClient.CHECKEXTERNAL,
                parameters : {
                    AppName : params.appName || ""
                }
            };
            return this.__base(command);
        }
    }, {});


    /**
     * Send External Request to a specified external application.
     *
     */
    nativeImpl.Class("SendExternalRequest", nativeImpl.ServiceRequest, {

        execute : function(params){
            var command = {
                type : nativeImpl.AbstractClient.SENDEXTERNAL,
                parameters : {
                    AppName : params.appName || "",
                    externalRequest : params.externalRequest || ""
                }
            };
            return this.__base(command);
        }
    }, {});


    /**
     * Send External Request to a specified external application.
     *
     */
    nativeImpl.Class("SetExternalHandlerRequest", nativeImpl.ServiceRequest, {

        execute : function(params){
            var command = {
                type : nativeImpl.AbstractClient.SETEXTERNALHANDLER,
                parameters : {
                    handler : params.handler || ""
                }
            };
            return this.__base(command);
        }
    }, {});
    
    /**
     * Send External Request to a specified external application.
     *
     */
    nativeImpl.Class("ApplicationFocusRequest", nativeImpl.ServiceRequest, {

        execute : function(params){
            var command = {
                type : nativeImpl.AbstractClient.APPLICATIONFOCUS,
                parameters : {
                    handler : params.handler || ""
                }
            };
            return this.__base(command);
        }
    }, {});

	/**
	 * Supported event types:
	 * 01. REQUEST_COMPLETED
	 * 02. REQUEST_ERROR
	 */
	nativeImpl.Class("ServiceRequestEvent", com.servicemax.client.lib.api.Event, {
		__constructor : function(type, target, data){
			this.__base(type, target, data);
		}
	}, {});	

	/**
	 * Native service file wrapper class
	 * This class represents a file or folder; or more generally, a resource
	 */
	nativeImpl.Class("File", com.servicemax.client.lib.api.Object, {
		__path: null,
		__request: null,
		__requestQueue: null,
		__constructor : function(path){
			this.__path = path;
			this.__request = com.servicemax.client.offline.sal.model.nativeservice.Facade.createFileRequest();
			this.__request.bind("REQUEST_COMPLETED", this.__onResult, this);
			this.__request.bind("REQUEST_ERROR", this.__onError, this);
			this.__requestQueue = [];
		},

		/**
		 * Returns the path of the file.  This is considered a readonly property; to get a new path create a new File instance.
		 * @method
		 */
		getPath : function() {
		    return this.__path;
		},

		/**
		 * Return the name of the file
		 * @method
		 */
		getName : function() {
		    var path = this.__path;
		    path = path.replace(/\\/g,"/"); // change any DOS paths to unix paths to keep things simple.
		    return path.match(/([^\/]*)$/)[1];
		},

        getParentFolder : function() {
            var path = this.__path;
            path = path.replace(/\/.*?$/,"");
            return new nativeImpl.File(path);
        },

		/* Only one request is allowed to execute at a time.
		 * If more come in, queue them up to execute later.
		 * If the developer wants to cancel something that is queued up,
		 * they can call cancel();
		 */
        __executeRequest : function(params, callback) {
            var d = new $.Deferred();
            this.__requestQueue.push({
                deferred: d,
                request: params
            });
            if (callback) d.done(callback);
            if (this.__requestQueue.length === 1) this.__executeNextRequest();
            return d;
        },

        __executeNextRequest : function() {
            if (this.__requestQueue.length === 0) return;
            var request = this.__requestQueue[0];
            var d = request.deferred;
            var params = request.request;
            SVMX.getLoggingService().getLogger("com.servicemax.client.offline.sal.model.nativeservice.File")
            .info("FILE OP:" + params.operation + " ON " + params.file);
            this.__request.execute(params);
        },
        __onResult : function(evt) {
            var request = this.__requestQueue.shift();
            var d = request.deferred;
            d.resolve(evt.data.success, evt.data.data);
            this.__executeNextRequest();
        },
        __onError : function(evt) {
            var request = this.__requestQueue.shift();
            if (request) {
                var d = request.deferred;
                var params = request.request;
                SVMX.getLoggingService().getLogger("com.servicemax.client.offline.sal.model.nativeservice.File")
                                        .error("File Error Op=" + params.operation + " returned " + evt.data.data + " for " + this.getPath());
                d.resolve(false, evt.data.data);
                this.__executeNextRequest();
            }
        },

        /**
         * If you have queued up a few requests or no longer care about the results of the current request
         * you can clear all requests using cancel(); all deferreds will be triggered with isSuccess = false.
         * @method
         */
        cancel : function() {
            // user's deferred handlers may manipulate requestQueue so isolate it from changes
            var queue = this.__requestQueue;
            this.__requestQueue = [];

            for (var i = 0; i < queue.length; i++) {
                queue.deferred.resolve({success: false, data: "Canceled by cancelRequest Call"});
            }
        },

        /**
         * Reads the contents of a file and returns the contents to the caller.
         * @example
         var file = new com.servicemax.client.offline.sal.model.nativeservice.File("myfolder/myfile.txt");

         // Using callbacks
         file.read(function(isSuccess, data) {
             if (isSuccess) {
                 alert("File contents are " + data);
             }
         }));

         // Using Deferreds
         file.read().then(function(isSuccess, data) {
             if (isSuccess) {
                 alert("File contents are " + data);
             }
         });
         * @param {function} callback The callback function takes two inputs: isSuccess, and inData.  inData is your file contents and inSuccess is a boolean.
         */
		read : function(callback) {
		    return this.__executeRequest({
		        operation: "READ",
		        file: this.__path
		    }, callback);
		},

        /**
         * Determines if the file exists
         *
         * @note
         * * TODO Currently exists returns false if the file exists but is empty; we need a REAL exists method
         * * isSuccess response can be ignored.
         *
         * @example
         var file = new com.servicemax.client.offline.sal.model.nativeservice.File("myfolder/myfile.txt");

         // Using callbacks
         file.exists(function(isSuccess, exists) {
            alert("File exists: " + exists);
         }));

         // Using Deferreds
         file.read().then(function(isSuccess, exists) {
            alert("File exists: " + exists);
         });

         // Using chained Deferreds
         file.exists()
         .then(function(result, exists) {
            if (exists) {
                return f1.read();
            }
          })
          .then(function(inSuccess, inData) {
              if (isSuccess) {
                  alert("File contains " + inData);
              }
           })
         * @param {function} callback The callback function takes two inputs: isSuccess, and exists.  inData is your file contents and inSuccess is a boolean.
         */
		exists : function(callback) {
            var d = new $.Deferred();
            this.read().then(function(isSuccess, data) {
		        d.resolve(true, isSuccess && data !== "") ;
		    });
		    d.done(callback);
		    return d;
		},

		/**
         * Write the specified contents to this file
         *
         * @example
         var file = new com.servicemax.client.offline.sal.model.nativeservice.File("myfolder/myfile.txt");

         // Using callbacks
         file.write("Hello World", function(isSuccess, resultMsg) {
            alert("File written: " + isSuccess);
         }));

         // Using Deferreds
         file.write("Hello World")
         .then(function(isSuccess, resultMsg) {
            return file.read();
         })
         .then(function(isSuccess, inData) {
             if (isSuccess) {
                alert("File now contains " + inData);
             } else {
                alert("Failed to write file: " + inData);
             }
         })
         * @param {string} data The data to write to the file
         * @param {function} callback The callback function takes two inputs: isSuccess, and resultMsg
         */
		write : function(data, callback) {
		    return this.__executeRequest({
		        operation: "WRITE",
		        file: this.__path,
		        data: data
		    }, callback);
		},

		/**
         * Appends the specified contents to this file
         *
         * @example
         var file = new com.servicemax.client.offline.sal.model.nativeservice.File("myfolder/myfile.txt");

         // Using callbacks
         file.append("Hello World", function(isSuccess, resultMsg) {
            alert("File written: " + isSuccess);
         }));

         // Using Deferreds
         file.append("Hello World")
         .then(function(isSuccess, resultMsg) {
            return file.read();
         })
         .then(function(isSuccess, inData) {
             if (isSuccess) {
                alert("File now contains " + inData);
             } else {
                alert("Failed to append to file: " + inData);
             }
         })
         * @param {string} data The data to append to the file
         * @param {function} callback The callback function takes two inputs: isSuccess, and resultMsg
         */
		append : function(data, callback) {
		    return this.__executeRequest({
		        operation: "APPEND",
		        file: this.__path,
		        data: data
		    }, callback);

		},

		/**
         * Delete the file from the file system represented by this File instance
         *
         * @example
         var file = new com.servicemax.client.offline.sal.model.nativeservice.File("myfolder/myfile.txt");

         // Using callbacks
         file.deleteFile(function(isSuccess, resultMsg) {
            alert("File Deleted: " + isSuccess);
         }));

         // Using Deferreds
         file.delete()
         .then(function(isSuccess, resultMsg) {
            return file.exists();
         })
         .then(function(isSuccess, inExists) {
             if (isSuccess) {
                alert("File no longer exists");
             } else {
                alert("Failed to delete file");
             }
         })
         * @param {function} callback The callback function takes two inputs: isSuccess, and resultMsg
         */
		deleteFile : function(callback) {
		    return this.__executeRequest({
		        operation: "DELETE",
		        file: this.__path
		    }, callback);
		},


		/**
         * Tell the operating system to open this file using its preferred handler for that file type.
         *
         * @example
         var file = new com.servicemax.client.offline.sal.model.nativeservice.File("myfolder/myfile.txt");

         // Using callbacks
         file.execute(function(isSuccess, resultMsg) {
            alert("File is openned for viewing/editing in a third party app: " + isSuccess);
         }));

         // Using Deferreds
         file.delete()
         .then(function(isSuccess, resultMsg) {
            alert("File is openned for viewing/editing in a third party app: " + isSuccess);
         })
         * @param {function} callback The callback function takes two inputs: isSuccess, and resultMsg
         */
		execute : function(callback) {
		    return this.__executeRequest({
		        operation: "EXECUTE",
                file: this.__path.replace(/\//g, "\\") // This string replace required for Windows XP only
		    }, callback);
		},

		/**
         * Copy this file to a new path.
         *
         * @example
         var file = new com.servicemax.client.offline.sal.model.nativeservice.File("myfolder/myfile.txt");

         // Using callbacks
         file.copy("test/path/file.txt", function(isSuccess, resultMsg) {
            alert("File copied: " + isSuccess);
         }));

         // Using Deferreds. Takes either path or file object as input
         var file2 = new com.servicemax.client.offline.sal.model.nativeservice.File("test/path/file.txt");
         file.copy(file2)
         .then(function(isSuccess, resultMsg) {
            return file2.append("Hello World");
         })
         .then(function(isSuccess, inData) {
             if (isSuccess) {
                alert("New copy created with appended data ");
             } else {
                alert("Failed to append to file: " + inData);
             }
         })
         * @param {string|File} dest The path string or a File object representing the desired location
         * @param {function} callback The callback function takes two inputs: isSuccess, and resultMsg
         *
         * @note From the .Net team:
         * By default the destination is set to UploadDirectory configured in AppSettings.config
         * or if a destinationPath is provided, the destination is resolved to
         * "C:\ProgramData\ServiceMax\ServiceMax Mobile for Laptops\<destinationPathProvided>"
         */
		copy : function(dest, callback) {
            var file = dest instanceof nativeImpl.File ? dest : new nativeImpl.File(dest);
		    return this.__executeRequest({
		        operation: "COPY",
		        file: this.__path,
		        targetPath: file.getParentFolder().getPath(),
                targetFile: file.getName()
		    }, callback);
		},

		/**
         * Move this file to a new path.  Side effect is to update the path and name of this File instance
         *
         * @example
         var file = new com.servicemax.client.offline.sal.model.nativeservice.File("myfolder/myfile.txt");

         // Using callbacks
         file.move("test/path/file.txt", function(isSuccess, resultMsg) {
            alert("File moved: " + isSuccess);
         }));

         // Using Deferreds. Takes either path or file object as input
         var file2 = new com.servicemax.client.offline.sal.model.nativeservice.File("test/path/file.txt");
         file.move(file2)
         .then(function(isSuccess, resultMsg) {
            return file2.append("Hello World");
         })
         .then(function(isSuccess, inData) {
             if (isSuccess) {
                alert("File moved and modified");
             } else {
                alert("Failed to move or append to file: " + inData);
             }
         })
         * @param {string|File} dest The path string or a File object representing the desired location
         * @param {function} callback The callback function takes two inputs: isSuccess, and resultMsg
         */
		move : function(dest, callback) {
		    var d = new $.Deferred();
		    this.copy(dest)
            .then(SVMX.proxy(this, function(isSuccess) {
                if (isSuccess) {
                    return this.deleteFile();
                } else {
                    d.resolve(false, "");
                }
             }))
             .then(SVMX.proxy(this, function(isSuccess) {
                this.__path = dest instanceof nativeImpl.File ? dest.getPath() : dest;
                d.resolve(status);
             }));
             return d;
		},


        /**
         * Get info about the file
         *
         * @example
         var file = new com.servicemax.client.offline.sal.model.nativeservice.File("myfolder/myfile.txt");

         // Using callbacks, you can access the result
         file.info("test/path/file.txt", function(isSuccess, data) {
            alert("File size is: " + data.size);
         }));

         // Using Deferreds.
         file.move(file2)
         .then(function(isSuccess, resultMsg) {
            alert("File size is: " + data.size);
         });
         * @param {boolean} isSuccess
         * @param {Object} data
         * @param {String} data.path
         * @param {Number} data.size
         * @param {boolean} data.readonly
         * @param {String} data.createdDate
         * @param {String} data.modifiedDate
         * @param {String} fileExtension
         * @param {String} path Contains resolved version of your input path with {} chars removed
         */

        info : function(callback) {
            var d = new $.Deferred();
            this.__executeRequest({
                operation: "INFO",
                file: this.__path
            }, function(inSuccess, inData) {
                if (inSuccess) {
                    var data = {
                        size: inData.FileSizeInBytes,
                        path: inData.FilePath,
                        readonly: inData.IsReadOnly.toLowerCase() == "true",
                        createdDate: inData.CreatedDateTime,
                        modifiedDate: inData.LastModifiedDateTime,
                        fileExtension: inData.FileExtension,
                        filePath: inData.FilePath
                    };
                    if (callback) callback(inSuccess, data);
                    d.resolve(inSuccess, data);
                } else {
                    d.reject(inData);
                }
            });
            return d;
        }
	}, {});

	/**
	 * Native service AbstractClient
	 */
	nativeImpl.Class("AbstractClient", com.servicemax.client.lib.api.Object, {}, {
		/*
		 * {	type 		: AbstractClient.<constant>
		 * 		parameters 	: {}
		 * 		callback	: {handler : function(response){}, context : <context object, typically 'this'>}
		 * }
		 */
		execute : function(params){
			// do nothing. it is expected that the subclasses will provide the implementation
		},

		HTTP : "HTTP",
		SQL : "SQL",
		FILE : "FILE",
		TRACE : "TRACE",
		REPORT : "REPORT",
		UPLOAD : "UPLOAD",
		DOWNLOAD : "DOWNLOAD",
        LOGININFO : "LOGININFO",
        INSTALLATIONS : "INSTALLATIONS",
        SIGNATURECAPTURE : "SIGNATURECAPTURE",
        CONNECTIVITY : "CONNECTIVITY",
        GENERATEPDF : "GENERATEPDF",
        SIGNOUT : "SIGNOUT",
        EXIT : "EXIT",
        SMS : "SMS",
        TEL : "TEL",
        GEO : "GEO",
        BROWSER : "BROWSER",
        SENDEXTERNAL : "SENDEXTERNAL",
        CHECKEXTERNAL : "CHECKEXTERNAL",
        SETEXTERNALHANDLER : "SETEXTERNALHANDLER",
        DATAACCESSAPI : "DATAACCESSAPI",
        APPLICATIONFOCUS : "APPLICATIONFOCUS"


	});

};
})();

