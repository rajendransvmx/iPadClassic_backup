(function ($) {

    var libCore = SVMX.Package("com.servicemax.client.lib.core");

    /**
     * load progress event class
     *
     * @class           com.servicemax.client.lib.core.LoadProgressEvent
     * @extends         com.servicemax.client.lib.api.Event
     *
     */
    libCore.Class("LoadProgressEvent", com.servicemax.client.lib.api.Event, {

        __constructor: function (type, target, data) {
            this.__base(type, target, data);
        }
    }, {});

    /**
     * load progress event dispatcher class
     *
     * @class           com.servicemax.client.lib.core.LoadProgressMonitor
     * @extends         com.servicemax.client.lib.api.EventDispatcher
     */

    libCore.Class("LoadProgressMonitor", com.servicemax.client.lib.api.EventDispatcher, {

        totalSteps: 0,
        currentStep: 0,

        __constructor: function (type, target, data) {
            this.__base(type, target, data);
        },

        start: function (options) {
            this.totalSteps = options.totalSteps;
            this.currentStep = 1;
            var lpe = new libCore.LoadProgressEvent("LOAD_STARTED", this, options.params);
            this.triggerEvent(lpe);
        },

        finishStep: function (params) {
            var lpe = new libCore.LoadProgressEvent("STEP_FINISHED", this, params);
            this.triggerEvent(lpe);
            this.currentStep++;
        },

        finish: function () {
            var lpe = new libCore.LoadProgressEvent("LOAD_FINISHED", this);
            this.triggerEvent(lpe);
        }
    }, {});

    /**
     * The module loader event class
     *
     * @class           com.servicemax.client.lib.core.ModuleLoaderEvent
     * @extends         com.servicemax.client.lib.api.Event
     *
     * @note
     * Supported events : <br>
     * 01. LOAD_COMPLETE  <br>
     * 02. LOAD_ERROR     <br>
     */
    libCore.Class("ModuleLoaderEvent", com.servicemax.client.lib.api.Event, {

        __constructor: function (type, target, data) {
            this.__base(type, target, data);
        }
    }, {});


    /**
     * The module loader class
     *
     * @class           com.servicemax.client.lib.core.ModuleLoader
     * @extends         com.servicemax.client.lib.api.EventDispatcher
     *
     */
    libCore.Class("ModuleLoader", com.servicemax.client.lib.api.EventDispatcher, {

        __options: null,
        module: null,
        __logger: null,
        templateList: null,

        __constructor: function (options) {
            this.__base();
            this.__options = options;
            this.__logger = SVMX.getLoggingService().getLogger("MODULE-LOADER");
        },

        loadAsync: function () {

            if (this.__options.manifestOnly) {
                return this.__loadManifest();
            } else {
                return this.__loadModuleScripts();
            }
        },

        getOptions: function () {
            return this.__options;
        },

        /**
         *
         * @private
         *
         * @return          deferred
         */
        __loadManifest: function () {
            // generate the right url
            var codebase = this.__getCodeBase(),
                cache = SVMX.isCachingEnabled();

            var url = codebase + "/" + "manifest/module.json";

            return $.ajax({
                cache: cache,
                type: "GET",
                dataType: "json",
                url: url,
                context: this,
                async: true,
                success: function (data, status, jqXhr) {
                    this.__loadManifestSuccess(data, status);
                },
                error: function (jqXhr, status, e) {
                    this.__loadManifestError(jqXhr, status, e);
                }
            });
        },

        __loadManifestSuccess: function (data, status) {
            var rle = new libCore.ModuleLoaderEvent("LOAD_COMPLETE", this, data);
            this.triggerEvent(rle);
        },

        __loadManifestError: function (jqXhr, status, e) {
            this.__logger.error("Cannot load manifest for " + this.__options.id + ", XHR Status = " + status);
            var rle = new libCore.ModuleLoaderEvent("LOAD_ERROR", this);
            this.triggerEvent(rle);
        },

        __getCodeBase: function () {
            var codebase = this.__options.codebase;

            if (codebase != null) {
                if (codebase.charAt(codebase.length - 1) != '/') codebase += "/";
            } else {
                codebase = "";
            }

            codebase += this.__options.id;
            return codebase;
        },

        __loadModuleScripts: function () {
            var defer = SVMX.Deferred();

            // generate the right url prefix
            var codebase = this.__getCodeBase();
            var prefix = codebase + "/" + "src/";

            SVMX.requireScript(this.__options.module.scripts, this.__loadModuleScriptsComplete,
				SVMX.proxy(this, "__loadModuleError"),
                this, {
                    async: true,
                    prefix: prefix
                },
                defer);

            return defer;
        },

        __loadModuleError: function (inError) {
            this.__logger.error(inError);
            var rle = new libCore.ModuleLoaderEvent("LOAD_ERROR", this);
            this.triggerEvent(rle);
        },

        __loadModuleScriptsComplete: function () {
            // TODO : generate the list of SUCCESS and ERROR load list

            this.__loadModuleTemplates();
        },

        __loadModuleTemplates: function () {
            // generate the right url prefix
            if (this.__options.module.templates && this.__options.module.templates.length > 0) {
                var codebase = this.__getCodeBase();
                var prefix = codebase + "/" + "resources/templates/";

                SVMX.requireTemplate(this.__options.module.templates, this.__loadModuleTemplatesComplete,
                    this, {
                        async: true,
                        prefix: prefix
                    });
            } else {
                this.__loadModuleTemplatesComplete();
            }
        },

        __loadModuleTemplatesComplete: function (templateList) {
            // TODO : generate the list of SUCCESS and ERROR load list
            this.templateList = templateList;
            var rle = new libCore.ModuleLoaderEvent("LOAD_COMPLETE", this);
            this.triggerEvent(rle);
        }

    }, {});

    /**
     * The module class
     *
     * @class           com.servicemax.client.lib.core.Module
     * @extends         com.servicemax.client.lib.api.Object
     */
    libCore.Class("Module", com.servicemax.client.lib.api.Object, {
        dependencies: null,
        declarations: null,
        definitions: null,
        scripts: null,
        services: null,
        tests: null,
        version: null,
        id: null,
        name: null,
        description: null,
        client: null,
        codebase: null,
        loadAtStartup: false,
        activatorClass: null,
        __activator: null,
        templates: null,
        loadedTemplates: null,

        // cache the definition, temporarily
        def: null,

        __constructor: function (client, def, options) {

            this.client = client;

            this.dependencies = [];
            this.declarations = [];
            this.definitions = [];
            this.services = [];

            // extract the relevant information
            this.id = def.id;
            this.version = def.version;
            this.name = def.name;
            this.description = def.description;
            this.def = def; // remove this
            this.scripts = def.scripts;
            this.tests = def.tests ? def.tests:[];
            this.activatorClass = def["module-activator"];
            this.loadAtStartup = def["load-at-startup"];
            this.codebase = options.codebase;
            this.templates = def.templates;

            this.__extractDependencies();
            this.__extractDeclaredInterfaces();
            this.__extractInterfaceImplementations();
            this.__extractServices();

            // register interfaces
            var i = 0;
            for (i = 0; i < this.declarations.length; i++) {
                client.registerDeclaration(this.declarations[i]);
            }
        },

        setLoadedTemplates: function (loadedTemplates) {
            this.loadedTemplates = loadedTemplates;
        },

        getTemplate: function (name) {
            if (!this.loadedTemplates) return null;

            for (var i = 0; i < this.loadedTemplates.length; i++) {
                if (name == this.loadedTemplates[i].name)
                    return this.loadedTemplates[i].data;
            }

            return null;
        },

        createActivator: function () {

            // create the module activator instance
            var maClass = SVMX.getClass(this.activatorClass);
            this.__activator = new maClass();
            this.__activator.setModule(this);
        },

        beforeInitialize: function () {
            this.__activator.beforeInitialize();
        },

        initialize: function () {
            this.__activator.initialize();
        },

        afterInitialize: function () {
            this.__activator.afterInitialize();
        },

        resolveDefinitions: function () {

            for (var i = 0; i < this.definitions.length; i++) {
                var ret = this.client.registerDefinition(this.definitions[i]);

                // cannot resolve one of the definitions! just return without proceeding further
                if (ret == false) return ret;
            }
            return true;
        },

        resolveServices: function () {
            for (var i = 0; i < this.services.length; i++) {
                var ret = this.client.registerService(this.services[i]);

                // cannot resolve one of the services! just return without proceeding further
                if (ret == false) return ret;
            }
            return true;
        },

        __extractServices: function () {
            var services = this.def.services,
                length = services.length;
            for (var i = 0; i < length; i++) {
                var service = new libCore.Service(this, services[i]);
                this.services[i] = service;
            }
        },

        __extractDependencies: function () {
            var depends = this.def.depends,
                length = depends.length;
            for (var i = 0; i < length; i++) {
                var dependency = new libCore.Dependency(this, depends[i]);
                this.dependencies[i] = dependency;
            }
        },

        __extractDeclaredInterfaces: function () {
            var declares = this.def.declares,
                length = declares.length;
            for (var i = 0; i < length; i++) {
                var declaration = new libCore.DeclaredInterface(this, declares[i]);
                this.declarations[i] = declaration;
            }
        },

        __extractInterfaceImplementations: function () {
            var defines = this.def.defines,
                length = defines.length;
            for (var i = 0; i < length; i++) {
                var definition = new libCore.InterfaceDefinition(this, defines[i]);
                this.definitions[i] = definition;
            }
        },

        getResourceUrl: function (path) {
            var url = this.__getCodeBase() + "/" + "resources/" + path;
            return url;
        },

        __getCodeBase: function () {
            var codebase = this.codebase;

            if (codebase != null) {
                if (codebase.charAt(codebase.length - 1) != '/') codebase += "/";
            } else {
                codebase = "";
            }

            codebase += this.id;
            return codebase;
        }
    }, {});

    /**
     * The class representing a single "declares" entity
     *
     * @class           com.servicemax.client.lib.core.DeclaredInterface
     * @extends         com.servicemax.client.lib.api.Object
     *
     */
    libCore.Class("DeclaredInterface", com.servicemax.client.lib.api.Object, {

        id: null,
        description: null,
        module: null,

        __constructor: function (module, def) {
            this.id = def.id;
            this.description = def.description;
            this.module = module;
        }
    }, {});

    /**
     * The class representing a single "defines" entity
     *
     * @class           com.servicemax.client.lib.core.InterfaceDefinition
     * @extends         com.servicemax.client.lib.api.Object
     */
    libCore.Class("InterfaceDefinition", com.servicemax.client.lib.api.Object, {
        type: null,
        id: null,
        config: null,
        module: null,
        __constructor: function (module, def) {
            this.type = def.type;
            this.id = def.id;
            this.config = def.config;
            this.module = module;
        },

        createInstanceAsync: function (name, options) {

            // TODO : load the module if it is already not loaded
            this.__createInstanceAsyncInternal(name, options);
        },

        __createInstanceAsyncInternal: function (name, options) {
            var cls = SVMX.getClass(name);
            var obj = new cls();
            options.handler.call(options.context, obj);

        },

        getResourceUrl: function (path) {
            return this.module.getResourceUrl(path);
        }

    }, {});

    /**
     * The class representing a single "depends" entity
     *
     * @class           com.servicemax.client.lib.core.Dependency
     * @extends         com.servicemax.client.lib.api.Object
     */
    libCore.Class("Dependency", com.servicemax.client.lib.api.Object, {
        id: null,
        version: null,
        module: null,

        __constructor: function (module, def) {
            this.id = def.id;
            this.version = def.version;
            this.module = module;
        }
    }, {});

    /**
     *
     *
     * @class           com.servicemax.client.lib.core.ModuleResourceLoader
     * @extends         com.servicemax.client.lib.aervices.ResourceLoader
     */

    libCore.Class("ModuleResourceLoader", com.servicemax.client.lib.services.ResourceLoader, {

        __module: null,
        __constructor: function (m) {
            this.__base();
            this.__module = m;
        },

        loadAsync: function (options) {
            options.url = this.__getCodeBase() + "/" + "resources/" + options.url;
            return this.__base(options);
        },

        __getCodeBase: function () {
            var codebase = this.__module.getModule().codebase;

            if (codebase != null) {
                if (codebase.charAt(codebase.length - 1) != '/') codebase += "/";
            } else {
                codebase = "";
            }

            codebase += this.__module.getModule().id;
            return codebase;
        },

        getResourceUrl: function (url) {
            return this.__getCodeBase() + "/" + "resources/" + url;
        }

    }, {});

    /**
     * The class representing a single "service" entity
     *
     * @class           com.servicemax.client.lib.core.Service
     * @extends         com.servicemax.client.lib.api.Object
     */
    libCore.Class("Service", com.servicemax.client.lib.api.Object, {
        id: null,
        module: null,
        __serviceClassName: null,
        __serviceInstance: null,

        __constructor: function (module, serviceDef) {
            this.id = serviceDef.id;
            this.__serviceClassName = serviceDef["class-name"];
            this.module = module;
        },

        // !!! Use this only when you are completely sure that service is loaded!
        getInstance: function () {
            if (this.__serviceInstance == null) {
                var serviceClass = SVMX.getClass(this.__serviceClassName);
                this.__serviceInstance = new serviceClass();
            }
            return this.__serviceInstance;
        },

        getInstanceAsync: function (options) {

            // There can be one instance per service type

            // TODO : load the module if it is already not loaded
            this.__getInstanceAsyncInternal(options);
        },

        __getInstanceAsyncInternal: function (options) {
            if (this.__serviceInstance == null) {
                var serviceClass = SVMX.getClass(this.__serviceClassName);
                this.__serviceInstance = new serviceClass();
            }

            options.handler.call(options.context, this.__serviceInstance);
        }
    }, {});

    /**
     * The client event class
     *
     * @class           com.servicemax.client.lib.core.ClientEvent
     * @extends         com.servicemax.client.lib.api.Event
     * @note
     * Supported events :
     * 01. READY
     *
     */

    libCore.Class("ClientEvent", com.servicemax.client.lib.api.Event, {

        __constructor: function (type, target, data) {
            this.__base(type, target, data);
        }
    }, {});

    /**
     * The core Client API.
     *
     * @class           com.servicemax.client.lib.core.Client
     * @extends         com.servicemax.client.lib.api.EventDispatcher
     *
     */
    libCore.Class("Client", com.servicemax.client.lib.api.EventDispatcher, {

        __moduleId2Modules: null,
        __serviceId2Services: null,
        __declarationId2Declarations: null,
        __declarationId2Definitions: null,
        __logger: null,
        __appParams: null,
        __progressMonitor: null,
        __loadVersion: "debug",
        __applicationTitle: null,

        __constructor: function () {

            if (libCore.Client.__instance != null) return libCore.Client.__instance;

            this.__base();
            this.__moduleId2Modules = {};
            this.__declarationId2Definitions = {};
            this.__declarationId2Declarations = {};
            this.__serviceId2Services = {};
            this.__appParams = {};

            this.__progressMonitor = new libCore.LoadProgressMonitor();
            this.__logger = SVMX.getLoggingService().getLogger();
            this.__profiler = SVMX.getProfilingService();

            // set up the static client references
            libCore.Client.__instance = this;
        },

        run: function (options) {
            // Replaces jQuery's parseJson method with one that tolerates comments in the config file.
            jQuery.ajaxSettings.converters["text json"] =  this.__parseJSON;

            // Provides for an SVMX.Deferred object
            SVMX.Deferred = $.Deferred;

            if (options.loadVersion != undefined && options.loadVersion != null) {
                this.__loadVersion = options.loadVersion;
            }

            if (options.configType == "remote") {
                this.__runWithRemoteConfig(options.data);
            } else if (options.configType == "local") {
                this.__runWithLocalConfig(options.data);
            } else {
                throw new Error("Unknown config type!");
            }
        },

        // Copied from jquery-min.js, as you can tell from the variable names.  This method adds
        // better tolerance for comments on the json files.
        __parseJSON: function(b) {
            var w = /^[\],:{}\s]*$/,
                x = /(?:^|:|,)(?:\s*\[)+/g,
                y = /\\(?:["\\\/bfnrt]|u[\da-fA-F]{4})/g,
                z = /"[^"\\\r\n]*"|true|false|null|-?(?:\d\d*\.|)\d+(?:[eE][\-+]?\d+|)/g;
            if (!b || typeof b != "string")
                return null;
            b = jQuery.trim(b);
            try {

                /* The window.JSON.parse method is the method with best performance, but throws
                 * errors if there are comments; so don't run this if comment-like structures
                 * appear.  Uses weak indexOf test rather than regex for performance reasons
                 */
                if (window.JSON && window.JSON.parse && b.indexOf("/*") == -1) {
                    return window.JSON.parse(b);
                }
            } catch(e) {}

            /* This test came from jQuery's code.  Full rationale unknown, but sanity-checks the json,
             * perhaps to verify that executing this function has no side-effects and can't be used
             * as part of an attack.  Test for comments was added by ServiceMax.  Will still fail on
             * json such as {hey: 5}; still must be {"hey": 5}
             */
            if (w.test(b.replace(y, "@").replace(z, "]").replace(x, "").replace(/\/\*.*?\*\//g,""))) {
                try {
                    return (new Function("return " + b))();
                } catch(e) {}
            }
            throw new Error("Invalid JSON: " + b);
        },

        getModuleForId: function (id) {
            return this.__moduleId2Modules[id];
        },

        getApplicationTitle: function () {
            return this.__applicationTitle;
        },

        getLoadVersion: function () {
            return this.__loadVersion;
        },

        getApplicationParameter: function (name) {
            return this.__appParams[name];
        },

        addApplicationParameter: function (name, value) {
            // TODO: Do not allow to add a new param if it is already added
            this.__appParams[name] = value;
        },

        getPlatformParameter: function (name) {
            // TODO:
        },

        getProgressMonitor: function () {
            return this.__progressMonitor;
        },

        __runWithRemoteConfig: function (url) {
            // load the config
            var loader = com.servicemax.client.lib.services
                .ResourceLoaderService.getInstance().createResourceLoader();

            loader.bind("LOAD_COMPLETE", this.__configLoadSuccess, this);
            loader.bind("LOAD_ERROR", this.__configLoadError, this);

            var profiler = this.__profiler;
			var profileName = url;
            var profileAction = "load";
            var profileType = "config";
            
            profiler.begin(profileName, profileType, profileAction);
            loader.loadAsync({
                url: url,
                responseType: "json",
                cache: false
            }).always(function(){
                profiler.end(profileName, profileType, profileAction);
            })
        },

        __configLoadSuccess: function (rle) {
            this.__run(rle.data);
        },

        __configLoadError: function (rle) {
            // YUI Compressor cribs
        },

        __runWithLocalConfig: function (config) {
            this.__run(config);
        },

        __run: function (config) {
            // at this point configuration is success fully loaded
            // extract application parameters
            var params = config["app-config"];
            //console.log( config.modules )
            for (var param in params) {
                this.__appParams[param] = params[param];
            }

    	    var logSettings = this.getApplicationParameter("svmx-logging-preferences");
    	    if (logSettings) SVMX.getLoggingService().setTargetSettings(logSettings);

            // application title from configuration
            this.__applicationTitle = config.title;

            // create the minisplash instance
            SVMX.create("com.servicemax.client.lib.core.MiniSplash", this.__progressMonitor, config);

            // TODO : TRANSLATION
            // +1 for status update of manifests loading
            this.__progressMonitor.start({
                totalSteps: config.modules.length + 1,
                params: {
                    stepTitle: "Starting module load"
                }
            });

            // extract platform parameters
            // TODO:

            // load the manifests first
            this.__loadModuleManifests(config.modules);
        },

        __loadModulesContext: 0,
        __allDependencies: null,
        __loadManifestTriggeredFor: null,
        __loadModuleManifests: function (moduleList) {
            // load state management
            this.__loadModulesContext = 0;
            this.__loadManifestTriggeredFor = {};
            // end load state management

            var i = 0,
                count = moduleList.length;
            for (i = 0; i < count; i++) {
                var m = moduleList[i];
                var options = {
                    manifestOnly: true,
                    id: m.id,
                    codebase: m.codebase
                };

                this.__loadModuleManifest(options);
            }

        },

        __loadModuleManifest: function (options) {
            // check if load is already triggered, if yes, then return
            if (this.__loadManifestTriggeredFor[options.id] != undefined) return;

            this.__loadModulesContext++;
            this.__loadManifestTriggeredFor[options.id] = options.id;

            var ml = new libCore.ModuleLoader(options);

            ml.bind("LOAD_COMPLETE", this.__loadModuleManifestSuccess, this);
            ml.bind(
                "LOAD_ERROR",
                SVMX.proxy(this, "__loadModuleManifestError", options),
                this
            );

            var profiler = this.__profiler;
            var profileName = options.id;
            var profileAction = "load";
            var profileType = "manifest";

            profiler.begin(profileName, profileType, profileAction);
            ml.loadAsync()
                .always(function(){
                    profiler.end(profileName, profileType, profileAction);
                });
        },

        __loadModuleManifestSuccess: function (evt) {
            // create a module instance for this module
            var m = new libCore.Module(this, evt.data, evt.target.getOptions());
            this.__logger.info("Loaded Module " + m.id);

            // register the module
            this.__moduleId2Modules[m.id] = m;

            // for each of the dependencies, trigger the load
            // var dependencies = m.dependencies, count = dependencies.length;
            // for(var i = 0; i < count; i++){
            //	 var d = dependencies[i];

            // assume the code base of the dependent
            // !!!! will not work for vf pages since the "codebase" has to be got from VF macros !!!
            // }
            // end dependency load

            // check if all the modules are loaded
            this.__loadModulesContext--;
            if (this.__loadModulesContext == 0) {
                this.__loadModuleManifestsComplete();
            }
        },

        __loadModuleManifestError: function (options, evt) {
            // YUI Compressor cribs
            this.__logger.error("loadModuleManifestError: " + options.id + " failed to load");
        },

        __loadModuleManifestsComplete: function () {
            this.__progressMonitor.finishStep({
                stepTitle: "All module manifests loaded"
            });
            this.__logger.info("all module manifest are loaded!");

            // resolve the interfaces and their implementations
            if (!this.__resolveDefinitions()) {
                this.__logger.error("There was an error during definitions resolution! Client cannot proceed.");
                return;
            }

            // resolve service definitions
            if (!this.__resolveServices()) {
                this.__logger.error("There was an error during services resolution! Client cannot proceed.");
                return;
            }

            // start calculating the dependency. following are the entry point interfaces for which
            // the chain should be created.
            // 01. com.servicemax.client.runtime.application

            // right now load all the module as defined in the application configuration
            // TODO : Enable lazy loading
            this.__loadModules();
        },

        __loadModuleTriggeredFor: null,
        __loadModules: function () {
            // load state management
            this.__loadModulesContext = 0;
            this.__loadModuleTriggeredFor = {};
            // end load state management

            for (var mid in this.__moduleId2Modules) {
                var m = this.__moduleId2Modules[mid];
                this.__loadModule(m);
            }

        },

        __loadModule: function (module) {
            // check if load is already triggered, if yes, then return
            if (this.__loadModuleTriggeredFor[module.id] != undefined) return;

            this.__loadModulesContext++;
            this.__loadModuleTriggeredFor[module.id] = module.id;

            var options = {
                manifestOnly: false,
                id: module.id,
                codebase: module.codebase,
                module: module
            };
            var ml = new libCore.ModuleLoader(options);
            ml.bind("LOAD_COMPLETE", this.__loadModuleSuccess, this);
            ml.bind("LOAD_ERROR", this.__loadModuleError, module);

            var profiler = this.__profiler;
			var profileName = module.id;
            var profileAction = "load";
            var profileType = "module";

            profiler.begin(profileName, profileType, profileAction);
            ml.loadAsync()
				.always(function(){
                    profiler.end(profileName, profileType, profileAction);
                });


        },

        __loadModuleSuccess: function (evt) {
            var module = evt.target.getOptions().module;

            this.__progressMonitor.finishStep({
                stepTitle: "Module loaded: " + module.id
            });

            this.__logger.info(module.id + " successfully loaded");

            // set up the loaded templates
            module.setLoadedTemplates(evt.target.templateList);

            // create the activator
            module.createActivator();

            // check if all the modules are loaded
            this.__loadModulesContext--;

            if (this.__loadModulesContext == 0)
                this.__loadModulesComplete();
        },

        __loadModuleError: function (options, evt) {
            // YUI Compressor cribs
        },

        __loadModulesComplete: function () {
            this.__logger.info("all modules now loaded are loaded!");

            // pre-initialize all the modules
            for (var mid in this.__moduleId2Modules) {
                var m = this.__moduleId2Modules[mid];
                try {
                    m.beforeInitialize();
                } catch (e) {
                    this.__logger.error("Error during beforeInitialize() of =>" + mid);
                    throw e;
                }
            }

            // initialize all the modules
            for (var mid in this.__moduleId2Modules) {
                var m = this.__moduleId2Modules[mid];
                try {
                    m.initialize();
                } catch (e) {
                    this.__logger.error("Error during initialize() of =>" + mid);
                    throw e;
                }
            }

            // post initialize all the modules
            for (var mid in this.__moduleId2Modules) {
                var m = this.__moduleId2Modules[mid];
                try {
                    m.afterInitialize();
                } catch (e) {
                    this.__logger.error("Error during afterInitialize() of =>" + mid);
                    throw e;
                }
            }
            com.servicemax.client.lib.api.ExtensionRunner.run(this, "com.servicemax.client.onFrameworkLoad")
                .then(SVMX.proxy(this, function () {
                    // finally, the client is ready to run, dispatch the ready event
                    var ce = SVMX.create("com.servicemax.client.lib.core.ClientEvent", "READY", this);

                    this.triggerEvent(ce);
                }));
        },

        __resolveDefinitions: function () {
            for (var mid in this.__moduleId2Modules) {
                var ret = this.__moduleId2Modules[mid].resolveDefinitions();
                if (!ret) return false;
            }
            return true;
        },

        __resolveServices: function () {
            for (var mid in this.__moduleId2Modules) {
                var ret = this.__moduleId2Modules[mid].resolveServices();
                if (!ret) return false;
            }
            return true;
        },

        getDeclarationRegistry: function () {
            return this;
        },

        getServiceRegistry: function () {
            return this;
        },

        getDeclaration: function (name) {
            if (this.__declarationId2Declarations[name] == undefined) {
                // unknown declaration name
                this.__logger.warning("Cannot find declaration <" + name + ">!");
                return null;
            }
            return this.__declarationId2Declarations[name];
        },

        getDefinitionsFor: function (declaration) {
            var id = "";

            if (typeof (declaration) == 'string')
                id = declaration;
            else
                id = declaration.id;

            return this.__declarationId2Definitions[id];
        },

        forEachDefinition: function(name, callback) {
            var declaration = this.getDeclaration(name);
            var definitions = this.getDefinitionsFor(declaration);
            SVMX.array.forEach(definitions, callback);
        },

        registerDeclaration: function (declaration) {
            var id = declaration.id;
            if (this.__declarationId2Declarations[id] != undefined) {

                // someone else has already registered the declaration!!
                var preModuleId = this.__declarationId2Declarations[id].module.id;
                var thisModuleId = declaration.module.id;
                this.__logger.error("Module " + thisModuleId + " is trying to declare the interface <" + declaration.id + "> which is already declared by " + preModuleId + ". Please rectify!");
                return false;
            }

            this.__declarationId2Declarations[id] = declaration;
            this.__declarationId2Definitions[id] = [];
            return true;
        },

        registerDefinition: function (definition) {
            var type = definition.type;
            if (this.__declarationId2Definitions[type] == undefined) {

                // trying to define an unknown declaration!
                this.__logger.error("Module " + definition.module.id + " is trying to define an interface  <" + type + "> which is not declared. Please rectify!");
                return false;
            }

            var defs = this.__declarationId2Definitions[type];
            defs[defs.length] = definition;
            return true;
        },

        iterateOverDefinitionsForDeclaration: function (declarationName, callback) {
            var declaration = this.getDeclaration(declarationName);
            if (!declaration) return;
            var definitions = client.getDefinitionsFor(declaration);
            SVMX.array.forEach(definitions, callback);
        },

        registerService: function (service) {
            var id = service.id;
            if (this.__serviceId2Services[id] != undefined) {

                // trying to register a particlar service more than once!
                var preModuleId = this.__serviceId2Services[id].module.id;
                var thisModuleId = service.module.id;
                this.__logger.error("Module " + thisModuleId + " is trying to register the service <" + id + "> which is already declared by " + preModuleId + ". Please rectify!");
                return false;
            }
            this.__serviceId2Services[id] = service;
            return true;
        },

        //////// BEGIN - Service Registry //////////
        getServiceInstanceAsync: function (name, options) {
            var servDef = this.getService(name);
            if (servDef) {
                servDef.getInstanceAsync({
                    handler: function (service) {
                        if (options.context) options.handler.call(options.context, service);
                        else options.handler(service);
                    },
                    context: this
                });
            } else {
                if (options.context) options.handler.call(options.context, null);
                else options.handler(null);
            }
        },

        getService: function (name) {
            //            console.log(name, this.__serviceId2Services)
            if (this.__serviceId2Services[name] == undefined) {
                this.__logger.error("Cannot find service -> " + name);
                return null;
            }

            return this.__serviceId2Services[name];
        },

        getServiceInstance : function (name) {
            var serviceDef = this.getService(name);
            if (serviceDef) {
                return serviceDef.getInstance();
            }
        }
        ///////// END - Service Registry /////////

    }, {
        __instance: null,
        getInstance: function () {
            if (libCore.Client.__instance == null) {
                libCore.Client.__instance = new libCore.Client();
            }
            return libCore.Client.__instance;
        }
    });

    /**
     * The default mini splash scren.
     *
     * @class           com.servicemax.client.lib.core.MiniSplash
     * @extends         com.servicemax.client.lib.api.Object
     *
     * @note
     * !! Not the right file to be in. Find a better place
     *
     */
    libCore.Class("MiniSplash", com.servicemax.client.lib.api.Object, {
        __pm: null,
        __outerNode: null,
        __spinner: null,
        __ms: null,
        _width: "100%",
        _height: "20px",
        __text: "",

        __constructor: function (pm, config) {
            var loadingId = libCore.MiniSplash.loadingDivId;
            libCore.MiniSplash.loadingDivId++;
            var body = $("body");

            pm.bind("LOAD_STARTED", this.handleLoadStarted, this);
            pm.bind("STEP_FINISHED", this.handleFinishStep, this);
            pm.bind("LOAD_FINISHED", this.handleFinish, this);

            this.__pm = pm;
            var bootSpinner = config && config['app-config']['svmx-enable-bootstrap-spinner'];
            var url = window["__SVMX_CLIENT_LIB_PATH__"] || "";
            url += (url && !url.match(/\/$/) ? "/" : "") + "resources/images/loadingAnim.gif";
            body.append("<div class='loading_div' id='loading_div" + loadingId + "'>" +
                (bootSpinner ? '' : "<img style='padding-left:5px; float:right' src='" + url + "'/>") +
                "<span style='float:right; margin:2px 0 0 0; padding:0' class='loading_span'></span>" +
                "</div>");
            this.__ms = $("#loading_div" + loadingId + " .loading_span");
            this.__outerNode = $("#loading_div" + loadingId);
            var stylesToAdd = {
                width: this._width,
                minHeight: this._height,
                bottom: 0,
                left: 0,
                fontFamily: "tahoma, arial, verdana, sans-serif",
                textAlign: "right",
                fontSize: "12px",
                color: "#000",
                borderTop: "solid 1px #c7c7c7",
                padding: "1px 10px",
                display: "none",
                position: "absolute",
                boxSizing: "border-box",
                background: "#e0dfdf"
            };

            this.__outerNode.css(stylesToAdd);
            if (bootSpinner) {
                // Add spinner for extra visual effect
                body.append('<div id="spinner" style="position: absolute; top: 50%; left: 50%; width: 50%; height: 50%"></div>');
                this.__spinner = $('#spinner').get(0);
                new Spinner({
                    lines: 13, length: 20, width: 10, radius: 30, corners: 1, rotate: 0,
                    direction: 1, speed: 1,trail: 60, shadow: false,  hwaccel: false,
                    color: '#888888', className: 'spinner', top: '-100%', left: '-60%'
                }).spin(this.__spinner);
            }

            // Cache the function so we can disconnect it later
            // Note that SVMX.proxy insures that every MiniSplash gets
            // a unique copy of this function for safe disconnecting.
            this.__disconnectFunc = SVMX.proxy(this, "__onScroll");
            $(window).on("scroll", this.__disconnectFunc);
        },
        __onScroll: function () {
            if (this.__outerNode) {
                this.__outerNode.css("bottom", -$("body")[0].scrollTop);
            }
        },
        __setText: function (value) {
            this.__text = value;
            this.__ms.text(this.__text);
        },

        handleLoadStarted: function (e) {
            this.__outerNode.show();
            this.__setText(e.data.stepTitle);
        },

        handleFinishStep: function (e) {
            this.__setText(e.data.stepTitle);
        },

        handleFinish: function (e) {
            var me = this;
            this.__ms.text("Loading done");
            me.__pm.unbind("LOAD_STARTED", this.handleLoadStarted, this);
            me.__pm.unbind("STEP_FINISHED", this.handleFinishStep, this);
            me.__pm.unbind("LOAD_FINISHED", this.handleFinish, this);

            if (this.__spinner) {
                this.__spinner.remove();
            }
            this.__outerNode.animate({
                opacity: 0
            }, 400, null, function () {
                me.__outerNode.remove();
                me.__ms = null;
                me.__outerNode = null;
                me.__pm = null;
                if (me.__disconnectFunc) {
                    $(window).off("scroll", me.__disconnectFunc);
                }
            });
        }
    }, {
        /* Using animation means asynchronous events.  Asynchronous events means that
         * there can be multiple instances of this class at the same time, and
         * multiple domNodes called "loading_div".  Every instance of this class
         * needs a dom node with a unique id.
         */
        loadingDivId: 0
    });

})(jQuery);
// end of file