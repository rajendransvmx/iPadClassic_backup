(function ($) {

    var libApi = SVMX.Package("com.servicemax.client.lib.api");

    /**
     * @class          com.servicemax.client.lib.api.Object
     * @description    Base class for all the client side classes
     */
    libApi.Class("Object", {

        __constructor: function () {},

        /**
         * @method
         * @return    {String}    class name or "unknown"
         */
        getClassName: function () {
            return this.constructor.__className || "unknown";
        },

        /**
         * The toString() method overrides the native toString method, and allows us to represent objects
         * within the debugger for easy interpretation.  Main use case: Identifying the type of an object
         * and especially, managing an array or hash of objects and knowing what the contents are.
         *
         * @public
         * @param    {String}    description
         *
         * @return    {String}    short class name  + description
         *
         * @note
         * While FireFox automatically represents all objects in its debugger using toString(), WebKit
         * does not; use instead the watch panel and add "this.toString()".
         * <br>
         * Individual classes can override toString and pass a description up to the parent method.
         * <br>
         * toString method for Sencha objects is set in com.servicemax.client.ui.components.impl
         */
        toString: function (description) {
            var shortClassName = this.getClassName().replace(/^com\.servicemax\.client\./, "client.");
            description = description ? " " + description : "";
            return shortClassName + (description ? " (" + description + ")" : "");
        }
    }, {});

    /**
     * @class           com.servicemax.client.lib.api.Event
     * @extends         com.servicemax.client.lib.api.Object
     *
     *
     * @param  {String}   type      some description
     * @param  {Object}   target    some description
     * @param  {Object}   data      some description
     *
     * @description     The event base class
     */
    libApi.Class("Event", com.servicemax.client.lib.api.Object, {
        /**
         * event type name
         *
         * @property
         * @type {String}
         * @default null
         * @description asdfasdf
         */
        type: null,
        /**
         * event target object
         *
         * @property
         * @type {Object}
         * @default null
         */
        target: null,
        /**
         * event data object
         *
         * @property
         * @type {Object}
         * @default null
         */
        data: null,
        __constructor: function (type, target, data) {
            this.type = type;
            this.target = target;
            this.data = data;
        }

    }, {});

    /**
     * @class           com.servicemax.client.lib.api.EventDispatcher
     * @extends         com.servicemax.client.lib.api.Object
     *
     *
     * @note
     *
     *
     * @description
     * Base classes for all those classes which want to be an event source
     */
    libApi.Class("EventDispatcher", libApi.Object, {
        /**
         * collection of event handlers
         *
         * @property
         * @type {Array}
         * @default []
         */
        eventHandlers: [],
        __constructor: function () {
            this.eventHandlers = [];
        },

        /**
         * adds the type, handler, and context into the event collection as an object
         *
         * @public
         * @method
         * @param   {String}        type        event type
         * @param   {Function}      handler     event handling function
         * @param   {Object}        context     object to reference event to
         *
         */
        bind: function (type, handler, context) {
            this.eventHandlers[this.eventHandlers.length] = {
                type: type,
                handler: handler,
                context: context
            };
        },
        /**
         * removes the event handler object from the collection given the type, handler, and context
         *
         * @public
         * @method
         * @param   {String}        type        event type
         * @param   {Function}      handler     event handling function
         * @param   {Object}        context     object to reference event to
         *
         *
         */
        unbind: function (type, handler, context) {
            for (var i = 0; i < this.eventHandlers.length; i++) {
                if (this.eventHandlers[i].handler == handler && this.eventHandlers[i].type == type) {
                    this.eventHandlers.splice(i, 1);
                }
            }
        },

	    unbindContext: function(context) {
            this.eventHandlers = SVMX.array.filter(this.eventHandlers, function(eh) {
                return eh.context != context;
            });
        },

        /**
         * triggers the event handler based on a given event object
         *
         * @public
         * @method
         * @param   {Event}    e   event type
         */
        triggerEvent: function (e) {
            var events = SVMX.array.filter(this.eventHandlers, function(eventHandler) {
                return eventHandler.type == e.type;
            });
            for (var i = 0; i < events.length; i++) {
                if (events[i].context) {
                    //bind arguments
                    events[i].handler.call(events[i].context, e);
                } else {
                    //Event type
                    events[i].handler(e);
                }
            }
        }

    }, {});

    /**
     * @class           com.servicemax.client.lib.api.ModuleActivator
     * @extends         com.servicemax.client.lib.api.Object
     *
     *
     * @description
     * The base module API, which is an entry point to all the modules. All the modules should implement
     * a class by deriving from this class.
     */
    libApi.Class("ModuleActivator", libApi.Object, {
        _logger: null,
        _module: null,
        __constructor: function () {},

        /**
         * before module initialization code goes here
         *
         * @public
         * @method
         */
        beforeInitialize: function () {},
        /**
         * module initialization code goes here
         *
         * @public
         * @method
         */
        initialize: function () {},
        /**
         * after module initialization code goes here
         *
         * @public
         * @method
         */
        afterInitialize: function () {},

        /**
         * sets the module to a given value
         *
         * @public
         * @method
         * @param   {Module}    value   module object
         */
        setModule: function (value) {
            this._module = value;
        },
        /**
         * get the module object
         *
         * @public
         * @method
         *
         * @return  {Module}
         */
        getModule: function () {
            return this._module;
        },
        /**
         * gets logger object
         *
         * @public
         * @method
         *
         * @return  {Logger}
         */
        getLogger: function () {
            return this._logger;
        },
        /**
         * returns the url given a path
         *
         * @public
         * @method
         * @param   {String}    path
         *
         * @return   {String}    resource url
         */
        getResourceUrl: function (path) {
            return this._module.getResourceUrl(path);
        }
    }, {});

    /**
     * @class           com.servicemax.client.lib.api.AbstractApplication
     * @extends         com.servicemax.client.lib.api.EventDispatcher
     *
     * @description     The application API
     */
    libApi.Class("AbstractApplication", libApi.EventDispatcher, {

        __constructor: function () {
            this.__base();
        },
        /**
         * returns the url given a path
         *
         * @public
         * @method
         * @param   {Object} options
         */
        beforeRun: function (options) {
            options.handler.call(options.context);
        },
        /**
         * abstract method
         *
         * @public
         * @method
         */
        run: function () {}

    }, {
        /**
         * handle for the current application
         *
         * @property
         * @type {String}
         * @default null
         */
        currentApp: null
    });

    //////////////////////////////////////////

    // Set of utility classes which helps in inter-class communication (based on design patterns).
    // The candidate who can use these classes include;
    //     01. MVC implementations
    //     02. Call back handlers

    /**
     * @class           com.servicemax.client.lib.api.AbstractCommand
     * @extends         com.servicemax.client.lib.api.Object
     *
     *
     * @description     The command class
     */
    libApi.Class("AbstractCommand", libApi.Object, {
        __constructor: function () {},
        executeAsync: function (request, responder) {}

    }, {});

    /**
     * @class           com.servicemax.client.lib.api.AbstractOperation
     * @extends         com.servicemax.client.lib.api.Object
     *
     * @description     The operation class
     */
    libApi.Class("AbstractOperation", libApi.Object, {
        __constructor: function () {},
        performAsync: function (request, responder) {}

    }, {});

    /**
     * @class           com.servicemax.client.lib.api.AbstractResponder
     * @extends         com.servicemax.client.lib.api.Object
     *
     * @description     The responder class
     */

    libApi.Class("AbstractResponder", libApi.Object, {
        __constructor: function () {},
        result: function (data) {},
        fault: function (data) {}
    }, {});

    /**
     * @class           com.servicemax.client.lib.api.AbstractExtension
     * @extends         com.servicemax.client.lib.api.Object
     *
     * @description     Generic extension class
     */
    libApi.Class("AbstractExtension", com.servicemax.client.lib.api.Object, {
        perform: function (caller) {}
    }, {});

    /**
     * @class           com.servicemax.client.lib.api.ExtensionRunner
     * @extends         com.servicemax.client.lib.api.Object
     *
     * @description
     * Create an instance of this to quickly/easily run all extensions of the given
     * name.
     *
     * @note
     * Will execute extensions serially.
     * <br>TODO: some extensions that
     * make web reqeusts may want to specify execution in parallel.
     *
     * <br>TODO: Any extension that does not depend upon other extensions shoul be run
     * in parallel instead of serially.
     *
     *
     * @param   (Object)    caller
     * @param   (Object)    extensionName
     */
    libApi.Class("ExtensionRunner", com.servicemax.client.lib.api.Object, {
            /**
             * calling object
             *
             * @property    caller
             * @type {Object}
             * @default null
             */

            /**
             * name of extension
             *
             * @property    extensionName
             * @type {String}
             * @default null
             */

            __caller: null,
            __extensionName: null,
            __constructor: function (caller, extensionName) {
                this.__caller = caller;
                this.__extensionName = extensionName;
            },
            /**
             *
             *
             * @public
             * @method
             *
             * @return  (Object)       Deferred object
             */
            perform: function (inParams) {
                var logger = SVMX.getLoggingService().getLogger("EXTENSION-RUNNER");
                var done = function () {
                    var d = new $.Deferred();
                    d.resolve();
                    return d;
                };

                var client = SVMX.getClient();
                // TODO: should extensions only be called after a particular sync type is called?
                var declaration = client.getDeclaration("com.servicemax.client.extension");
                if (!declaration) return done();
                var definitions = client.getDefinitionsFor(declaration);
                var extensionName = this.__extensionName;
                definitions = SVMX.array.filter(definitions, function (def) {
                    return def.config["event"] === extensionName;
                });
                logger.info("Running " + extensionName + " with " + definitions.length + " extensions");
                if (definitions.length === 0) return done();

                var deferreds = [];

                for (var i = 0; i < definitions.length; i++) {
                    var definition = definitions[i];
                    var extClassName = definition.config['class-name'];
                    var extClass = SVMX.create(extClassName);

                    // NOTE: try/catch block can't catch async errors;
                    // The Extension must use its callback in an error handler!
                    try {
                        deferreds.push(extClass.perform(this.__caller, inParams));
                    } catch (e) {}
                }

                var result = SVMX.when(deferreds);
                result.done(function() {
                    logger.info("Running " + extensionName + " completed");
                });
                result.fail(function() {
                    logger.error("Running " + extensionName + " failed");
                });

                return result;
            }
        },
        // STATIC METHODS
        {
            /**
             * @static
             * @public
             * @method
             * @param   {Object}    inCaller
             * @param   {Object}    inName
             *
             * @return  (Object)
             */
            run: function (inCaller, inName, inParams) {
                var extensionRunner = new com.servicemax.client.lib.api.ExtensionRunner(inCaller, inName);
                return extensionRunner.perform(inParams);
            }
        });
    //////////////// end of utility classes ////////////////

})(jQuery);

// end of file