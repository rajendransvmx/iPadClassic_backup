/**
 * This file needs a description
 * @class com.servicemax.client.runtime.impl
 * @singleton
 * @author unknown
 *
 * @copyright 2013 ServiceMax, Inc.
 */
(function(){

	var runtimeImpl = SVMX.Package("com.servicemax.client.runtime.impl");

	runtimeImpl.Class("Module", com.servicemax.client.lib.api.ModuleActivator, {

		__runtime : null, __displayRoot : null,

		__constructor : function(){
			this.__base();
			this._logger = SVMX.getLoggingService().getLogger("CLIENT-RUNTIME");

			this.__runtime = new runtimeImpl.Runtime(this);

			// register with the READY client event
			SVMX.getClient().bind("READY", this.__onClientReady, this);

		},

		beforeInitialize : function(){

		},

		initialize : function(){

		},

		afterInitialize : function(){
			var serv = SVMX.getClient().getServiceRegistry()
								.getService("com.servicemax.client.preferences").getInstance();
			serv.addPreferenceKey(com.servicemax.client.runtime.constants.Constants.PREF_KEY_THEME);
		},

		__onClientReady : function(evt){
			this._logger.info("Client ready to run!");
			this.__runtime.start();
		}

	}, {});

	/**
	 * The platform runtime
	 */
	runtimeImpl.Class("Runtime", com.servicemax.client.lib.api.Object, {
		__parent : null, __logger : null, __app : null,

		__constructor : function(parent){
			this.__parent = parent;
			this.__logger = parent.getLogger();
		},

		start : function(){

			var client = SVMX.getClient(), declaration = null, definitions = null;

			// first load all the CSS definitions. This will optimize the runtime for DOM construction
			var currentTheme = "CLASSIC";

			// check if there is a url parameter specifying a theme. if yes, then load that theme
			var themeFromUrl = SVMX.getUrlParameter("theme");
			if(themeFromUrl != undefined && themeFromUrl != ''){
				currentTheme = themeFromUrl;
			}else{
				// check if we can get the current theme from preference
				try{
					var serv = SVMX.getClient().getServiceRegistry()
									.getService("com.servicemax.client.preferences").getInstance(),
					key = com.servicemax.client.runtime.constants.Constants.PREF_KEY_THEME;

					var pref = serv.getPreference(key);
					if(pref){
						currentTheme = pref;
					}
				}catch(e){
					// could not find preferences. this could typically happen when a cache service is
					// present. just continue...
					this.__logger.warn("Could not load preferences. => " + e);
				}
			}

			function afterCssLoad(){
				this.__logger.info("Theme <" + currentTheme + ">loaded successfully");

				// get the interface definition for runtime application interface.
				// there can exist only one such definition. however, one can define
				// multiple runnable applications and specify which one to run in the application
				// configuration

				declaration = client.getDeclaration("com.servicemax.client.runtime.application");
				definitions = client.getDefinitionsFor(declaration);

				if(definitions.length == 0){
					this.__logger.error("Cannot find an application extension!");
					return;
				}

				//if there are more than one, pick up the first one.
				// !!! More than one is not a use case
				var definition = definitions[0], appConfig = definition.config.application;

				// now get which runtime application to run from the application configuration
				// it is possible that one can set application id from the url. if it is not available, then look into
				// what is available in the application parameters from config.json, ...

				var appId = '';

				appId = SVMX.getUrlParameter("application-id");
				if(appId == null || appId == ''){
					appId = client.getApplicationParameter("application-id");
				}

				if(!appId){
					this.__logger.error("Your application configuration does not specify an application id. Please rectify");
					return;
				}

				if(appConfig instanceof Array){
					for(var acIndex =0;  acIndex < appConfig.length; acIndex++){
						var ac = appConfig[acIndex];
						if(ac.id == appId){
							appConfig = ac;
							break;
						}
					}

					// invalid application id
					if(acIndex == appConfig.length){
						appConfig = {id : "__INVALID_APP_ID__"};
					}
				}

				if(appConfig.id != appId){
					this.__logger.error("Cannot find the application " + appId + " in any of the definitions. Please rectify");
					return;
				}

				// create the runnable instance
				var appClassName = appConfig["class-name"];
				this.__app = SVMX.create(appClassName);

				this.__logger.info("Running application <" + appId + "> with class <" + appClassName + ">");

				// set up the static instance
				com.servicemax.client.lib.api.AbstractApplication.currentApp = this.__app;

				// preinitialize the application
				this.__app.beforeRun({handler : this.__beforeRunCompleted, context : this});

				// trigger the application created event
				var ce = SVMX.create("com.servicemax.client.lib.core.ClientEvent", "APPLICATION_CREATED", this);
				SVMX.getClient().triggerEvent(ce);

			}

			// load the theme
			var themeService = SVMX.getClient().getServiceRegistry().getService("com.servicemax.client.themeservice").getInstance();
			themeService.loadTheme(currentTheme, afterCssLoad, this);
		},

		__beforeRunCompleted : function(){

			// end the load monitor
			SVMX.getClient().getProgressMonitor().finish();

			// now run the app
			this.__app.run();
		}
	},{});


	runtimeImpl.Class("ThemeService", com.servicemax.client.lib.api.Object,{
		__logger : null, __themeProperties : null, __currentTheme : null,
		__constructor : function(){
			if(runtimeImpl.ThemeService.__instance != null) return runtimeImpl.ThemeService.__instance;

			runtimeImpl.ThemeService.__instance = this;
			this.__themeProperties = {};
			this.__logger = SVMX.getLoggingService().getLogger("THEME-SERVICE");
		},

		getThemeProperties : function(){
			return this.__themeProperties;
		},

		getThemeProperty : function(propName){
			var allProps = this.getThemeProperties(), ret = null;
			for(var name in allProps){
				if(name == propName){
					ret = allProps[name]
					break;
				}
			}
			return ret;
		},

		__extractThemeProperties : function(props){
			var allProps = this.getThemeProperties();
			for(var name in props){
				allProps[name] = props[name];
			}
		},

		getAvailableThemes : function(){
			var client = SVMX.getClient(), declaration = null, definitions = null, ret = {};

			declaration = client.getDeclaration("com.servicemax.client.runtime.uitheme");
			definitions = client.getDefinitionsFor(declaration);
			if(definitions.length > 0){
				var i, count = definitions.length;
				for(i = 0; i < count; i++){
					var def = definitions[i], themeDefs = def.config["theme-defs"];

					// if a theme definition is present
					if(themeDefs){
						var j , themeDefCount = themeDefs.length;
						for(j = 0; j < themeDefCount; j++){
							var themeDef = themeDefs[j];
							ret[themeDef.type] = ret[themeDef.type] ? ret[themeDef.type] : { properties : {}};
							if(themeDef.properties) {
								for(var name in themeDef.properties)
								ret[themeDef.type].properties[name] = themeDef.properties[name];
							}
						}
					}
				}
			}
			return ret;
		},

		getCurrentTheme : function(){
			return this.__currentTheme;
		},

		loadTheme : function(type, handler, context, loadLater){
			this.__currentTheme = type;

			if(loadLater){
				this.__logger.info("Will load the theme later => " + type);
				handler.call(context);
				return;
			}

			this.__logger.info("Loading theme => " + type);
			var client = SVMX.getClient(), declaration = null, definitions = null, allUrls = [];

			declaration = client.getDeclaration("com.servicemax.client.runtime.uitheme");
			definitions = client.getDefinitionsFor(declaration);
			if(definitions.length > 0){
				var i, count = definitions.length;
				for(i = 0; i < count; i++){
					var def = definitions[i], themeDefs = def.config["theme-defs"];

					// if a theme definition is present
					if(themeDefs){
						var j , themeDefCount = themeDefs.length;
						for(j = 0; j < themeDefCount; j++){
							var themeDef = themeDefs[j];
							if(themeDef.type == type){

								// see if this definition applies only to certain platform
								if(themeDef["valid-platforms"]){
									var validPlatforms = themeDef["valid-platforms"];

									// right now support only one platform
									if(!SVMX.isPlatform(validPlatforms)) continue;

								}

								if(themeDef.properties){
									this.__extractThemeProperties(themeDef.properties);
								}

								if(themeDef.path){
									var url = def.getResourceUrl(themeDef.path);
									allUrls[allUrls.length] = url;
								}
							}
						}
					}
				}
			}

			if(allUrls.length > 0){
				SVMX.requireStyleSheet(allUrls, handler, context, {});
			}else{
				handler.call(context);
			}
		}

	}, {
		__instance : null
	});

	runtimeImpl.Class("NamedInstanceService", com.servicemax.client.lib.api.Object, {
		__logger : null,
		__allInstanceDefinitions : null,

		__constructor : function(){
			if(runtimeImpl.NamedInstanceService.__instance != null) return runtimeImpl.NamedInstanceService.__instance;

			runtimeImpl.NamedInstanceService.__instance = this;

			this.__logger = SVMX.getLoggingService().getLogger("NAMEDINSTANCE-SERVICE");
			this.__allInstanceDefinitions = {};

			// initialize the service
			var client = SVMX.getClient(), declaration = null, definitions = null;

			declaration = client.getDeclaration("com.servicemax.client.runtime.namedinstance");
			definitions = client.getDefinitionsFor(declaration);

			if(definitions != null){
				var i, count = definitions.length;

				// get all the instance definitions first
				for(i = 0; i < count; i++){
					var def = definitions[i], config = def.config;

					if(config.define){
						this.__allInstanceDefinitions[config.define.name] = {definition : def, data : []};
					}
				}

				// now get all the configurations
				for(i = 0; i < count; i++){
					var def = definitions[i], config = def.config;

					if(config.configure){
						var def = this.__allInstanceDefinitions[config.configure.name];
						def.data[def.data.length] = {definition : def, data : config.configure.data};
					}
				}
			}
		},

		createNamedInstanceAsync : function(name, options){

			// TODO : Load the module if it is not already loaded
			this.__createdNamedInstanceAsyncInternal(name, options);
		},

		__createdNamedInstanceAsyncInternal : function(name, options){

			var namedInstanceDef = this.__allInstanceDefinitions[name];
			var className = namedInstanceDef.definition.config.define.type;
			var cls = SVMX.getClass(className);
			var namedInstance = new cls();
			namedInstance.initialize(name, namedInstanceDef.data, options.additionalParams);
			options.handler.call(options.context, namedInstance);
		}

	}, {
		__instance : null
	});

	runtimeImpl.Class("Preferences", com.servicemax.client.lib.api.Object, {
		__preferenceKeys : null,
		__constructor : function(){ this.__preferenceKeys = {}; },

		addPreferenceKey : function(key){
			key = this.__getKey(key);
			this.__preferenceKeys[key] = key;
		},

		getPreferenceKeys : function(){
			return SVMX.cloneObject(this.__preferenceKeys);
		},

		getPreference : function(key){
			var value;

			// This is under the assumption that the cache service is already loaded
			var servDef = SVMX.getClient().getServiceRegistry()
							.getService("com.servicemax.client.cache");
			if (servDef) {
			    var serv = servDef.getInstance();
    			key = this.__getKey(key);
    			value = serv.getItem(key);
    		} else {
			     SVMX.getLoggingService().getLogger("CLIENT-RUNTIME").warning("No com.servicemax.client.cache has been registered");
			}
			return value;
		},

		setPreference : function(key, value){
			// This is under the assumption that the cache service is already loaded
			var servDef = SVMX.getClient().getServiceRegistry()
							.getService("com.servicemax.client.cache");
            if (servDef) {
                var serv = servDef.getInstance();
    			key = this.__getKey(key);
    			serv.setItem(key, value);
			} else {
			    SVMX.getLoggingService().getLogger("CLIENT-RUNTIME").warning("No com.servicemax.client.cache has been registered");
			}
		},

		__getKey : function(key){
			return "SVMX-CLIENT-UPREF-" + key;
		}
	}, {});
})();