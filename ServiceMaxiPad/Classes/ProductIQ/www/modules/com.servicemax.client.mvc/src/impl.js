/**
 * # Package #
 * This package provides the Controller and Model classes, which are used as part of our MVC framework.
 *
 * @class com.servicemax.client.mvc.impl
 * @singleton
 * @author Indresh
 *
 * @copyright 2013 ServiceMax, Inc.
 */



(function(){

    var mvcImpl = SVMX.Package("com.servicemax.client.mvc.impl");

    mvcImpl.Class("Module", com.servicemax.client.lib.api.ModuleActivator, {
        __constructor : function(){
            this.__base();
        },

        beforeInitialize : function(){
            mvcImpl.init();
        },

        initialize : function(){

        },

        afterInitialize : function(){

        }
    }, {});

mvcImpl.init = function(){

    /**
     * The Controller class is a NamedInstance which provides controller-like behaviors to a class that uses it.
     * The role of the Controller is to wire events between a module's controller (currently engine.js but perhaps will be renamed to controller.js)
     * and the module's commands.js file where commands are executed.
     *
     * It does this by taking the list of all events that have been registered via manifest.json, taking the eventBus of the Module's controller/engine
     * and subscribing/binding to all of these registered events that come through this eventBus.
     *
     * Events are configured in module.json as:
     *
     *     {
     *           "type" : "com.servicemax.client.runtime.namedinstance",
     *           "config" : {
     *               "configure" : { "name" : "CONTROLLER", "data" : [
     *                   {"event" : "SFMDELIVERY.GET_PAGELAYOUT", "command" : "com.servicemax.client.sfmdelivery.commands.GetPageLayout"}
     *               ]
     *           }
     *     }
     *
     * On triggering an event, the class specified by the "command" in the config above is created, and its executeAsync() method is called
     *
     * @class com.servicemax.client.mvc.impl.Controller
     * @extends com.servicemax.client.runtime.api.AbstractNamedInstance
     */
    mvcImpl.Class("Controller", com.servicemax.client.runtime.api.AbstractNamedInstance, {
        __eventId2EventMap : null, _model : null, __logger : null, __eventBus : null,

        __constructor : function(){

        },

        /**
         * @method
         * @protected
         * Initialize the Controller
         *
         * The initialize method is part of the namedInstance lifecycle, and should only ever be called by NamedInstanceService.
         * Its main activity is to bind all configured events to trigger this object's eventHandler method.
         */
        initialize : function(name, data, params){
            this.__logger = SVMX.getLoggingService().getLogger("MVC-CONTROLLER(" + name +")");
            this.__eventId2EventMap = {};
            var eventBus = params.eventBus; this.__eventBus = params.eventBus;
            var i, count = data.length;
            for(i = 0; i < count; i++){
                var d = data[i];
                var eventMap = d.data, eventCount = eventMap.length, j;
                for(j = 0; j < eventCount; j++){
                    var mapping = eventMap[j];
                    this.__eventId2EventMap[mapping.event] = { data : d, mapping : mapping };
                    eventBus.bind(mapping.event, this.eventHandler, this);
                }
            }
        },

        /**
         * @method
         * @protected
         * Executes the configured event.
         *
         * The eventHandler method was passed in via initialize's bind method, and should only be called via a triggerEvent() call.
         * This method instantiates and executes the configured Command class when an event is triggered.
         */
        eventHandler : function(evt){
            try{
                var eventInfo = this.__eventId2EventMap[evt.type];
                var commandClassName = eventInfo.mapping.command;

                //TODO : Load the module if it is already not loaded

                var commandClass = SVMX.getClass(commandClassName);
                var cmd = new commandClass();
                cmd.setController(this);
                cmd.setEventBus(this.__eventBus);

                var request = evt.data.request;
                var responder = evt.data.responder;
                this.__logger.info("Executing command => " + evt.type);
                cmd.executeAsync(request, responder);
            }catch(e){
                this.__logger.error(e);
                throw e;
            }
        },

        /**
         * @method
         * Set the model that will be used in executing events
         *
         * The commands that are executed are typically executed using sal.model or offline.sal.model, or some other configured model.
         * The knowledge of who provides the operations needed by many commands is managed by the mvc.Model class.
         * This method is called by the module's engine.js/controller.js file.
         *
         * @param {com.servicemax.client.mvc.impl.Model} model
         */
        setModel : function(value){
            this._model = value;
        },

        /**
         * @method
         * Retrieve the model
         *
         * @param {com.servicemax.client.mvc.impl.Model} model
         */
        getModel : function(){ return this._model; }

    }, {});



    /**
     * The Model class is a NamedInstance which provides controller-like behaviors to a class that uses it.
     * The role of the Model is to wire events between a module's commands (i.e. commands.js)
     * and the the Operation class/module that implements that operation.
     * This allows us to configure what gets executed when a command needs to interact with the server/database (via module.json file)
     * and allows us to configure whether its using the database OR the server (by including the module whose module.json file that defines the operations)
     *
     * It does this by taking the list of all events that have been registered via manifest.json, taking the eventBus of the Module's controller/engine
     * and subscribing/binding to all of these registered events that come through this eventBus.
     *
     * Events are configured in module.json as:
     *
     *
        {
            "type" : "com.servicemax.client.runtime.namedinstance",
            "config" : {
                "configure" : { "name" : "MODEL", "data" : [
                        {"operationId" : "SFMDELIVERY.GET_PAGELAYOUT", "operation" : "com.servicemax.client.offline.sal.model.sfmdelivery.operations.GetPageLayout"}
                ]}
            }
        }
     *
     * When a Command wants to execute an operation, it then executes:
     *
     *     this.__controller.getModel().executeOperationAsync(request, responder, options, this.getEventBus());
     *
     * Which then routes the requested operation to the appropriate Operation instance according to the config shown above.
     *
     * @class com.servicemax.client.mvc.impl.Model
     * @extends com.servicemax.client.runtime.api.AbstractNamedInstance
     */
    mvcImpl.Class("Model", com.servicemax.client.runtime.api.AbstractNamedInstance, {

        __operationId2OperationMap : null, __logger : null,

        __constructor : function(){},

        /**
         * @method
         * @protected
         * Initialize the Model
         *
         * The initialize method is part of the namedInstance lifecycle, and should only ever be called by NamedInstanceService.
         * Its main activity is to bind all configured events to trigger this object's eventHandler method.
         */
        initialize : function(name, data, params){
            this.__logger = SVMX.getLoggingService().getLogger("MVC-MODEL(" + name +")");
            this.__operationId2OperationMap = {};
            var i, count = data.length;
            for(i = 0; i < count; i++){
                var d = data[i];
                var opMap = d.data, opCount = opMap.length, j;
                for(j = 0; j < opCount; j++){
                    var mapping = opMap[j];
                    this.__operationId2OperationMap[mapping.operationId] = { data : d, mapping : mapping };
                }
            }
        },

        /**
         * @method
         * Execute the requested Operation.
         *
         * @param request
         * @param responder
         * @param options = { operationId : "" }
         */
        executeOperationAsync : function(request, responder, options, eventBus){
            try{
                var operationInfo = this.__operationId2OperationMap[options.operationId];

                // Operation is not supported for the current application.  See LookupItemSelected operation for offline sal model vs online model for example.
                if (!operationInfo) return;

                var operationClassName = operationInfo.mapping.operation;

                //TODO : Load the module if it is already not loaded

                var operationClass = SVMX.getClass(operationClassName);
                var op = new operationClass();
                op.setEventBus(eventBus);
                op.performAsync(request, responder);
            }catch(e){
                this.__logger.error(e);
                throw e;
            }
        }

    }, {});

mvcImpl.Class("View", com.servicemax.client.runtime.api.AbstractNamedInstance, {
        __viewConfig: null,
        __logger: null,
        __eventBus: null,

        __constructor : function(){},

        /**
         * @method
         * @protected
         * Initialize the View
         * @param {String} name Should always be "VIEW"
         * @param {Object} data All the data configured in all of the module.json files
         * @param {Object} params All the data passed from the createNamedInstanceAsync call
         *
         * The initialize method is part of the namedInstance lifecycle, and should only ever be called by NamedInstanceService.
         * Its main activity is to bind all configured events to trigger this object's eventHandler method.
         */
        initialize : function(name, data, params){
            this.__logger = SVMX.getLoggingService().getLogger("MVC-VIEW(" + name +")");
            this.__viewConfig = {};
            if (!params) params = {};
            this.__eventBus = params.eventBus;
            SVMX.array.forEach(data, function(dataSet) {
                SVMX.array.forEach(dataSet.data, function(item) {
                    var componentId = item["component-id"];
                    this.__viewConfig[componentId] = item["class-name"];
                }, this);
            }, this);
        },

        /**
         * @method
         * Create an instance of the specified component
         *
         * @param {String} componentId An id of a component "ROOTCONTAINER". Ids defined in module.json, and provided by each implementation of the UI
         * @param {Object} params Any parameters to pass into the constructor.
         */
        createComponent : function(componentId, params){
            try{
                var className = this.__viewConfig[componentId];
                if (!params) params = {};
                params.__view = this;

                // As of stateManager/android refactoring, this is no longer Required to return an object
                if (className && SVMX.getClass(className,true)) {
                    return SVMX.create(className, params);
                }
            }catch(e){
                this.__logger.error("Error creating " + componentId + ": " + e);
                throw e;
            }
        },

        /* Should share the deliveryEngine's event bus so that the view module can easily trigger events on it */
        triggerEvent : function(e) {
            this.__eventBus.triggerEvent(e);
        }

    }, {});
};
})();

// end of file