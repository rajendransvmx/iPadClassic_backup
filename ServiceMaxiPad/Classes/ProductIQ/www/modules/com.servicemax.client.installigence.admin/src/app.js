
(function(){
	var appImpl = SVMX.Package("com.servicemax.client.installigence.admin.app");
	
	appImpl.Class("Application", com.servicemax.client.lib.api.AbstractApplication,{
		__eventBus : null,
		
		__constructor : function(){

		},
		
		beforeRun: function (options) {
			var ni = SVMX.getClient().getServiceRegistry().getService("com.servicemax.client.niservice").getInstance();
			 
        	this.__eventBus = SVMX.create("com.servicemax.client.installigence.admin.impl.InstalligenceAdminEventBus", {});
        	// create the named default controller
			ni.createNamedInstanceAsync("CONTROLLER",{ handler : function(controller){

				// now create the named default model
				ni.createNamedInstanceAsync("MODEL",{ handler : function(model){
					controller.setModel(model);
				}, context : this});

			}, context : this, additionalParams : { eventBus : this.__eventBus }});
			
			options.handler.call(options.context);
        },
        
        getEventBus : function(){
        	return this.__eventBus;
        },
        
		run : function(){	
			var me = this;
			me.getSetupMetadata();
		},
        
        getSetupMetadata: function() {
	       	var me = this;
	       	var evt = SVMX.create("com.servicemax.client.lib.api.Event",
							"INSTALLIGENCEADMIN.GET_SETUP_METADATA", me,
							{request : { context : me}});
	       	
	       	SVMX.getCurrentApplication().getEventBus().triggerEvent(evt);
        },

        showQuickMessage : function(type, message, callback){
            type = type.toLowerCase();
            if(type === "confirm"){
                typeMessage = $TR.MESSAGE_CONFIRM;
                Ext.Msg.confirm(typeMessage, message, callback);
            }else{
                switch(type){
                    case "success":
                        typeMessage = $TR.MESSAGE_SUCCESS;
                        break;
                    case "error":
                        typeMessage = $TR.MESSAGE_ERROR;
                        break;
                    case "info":
                    // TODO: add more types as needed
                    default:
                        typeMessage = $TR.MESSAGE_INFO;
                        break;
                }
                Ext.Msg.alert(typeMessage, message);
            }
        },
        
        onGetSetupMetadataComplete: function(metadata) {
        	
        	var sforceObjectDescribes = metadata.sforceObjectDescribes;
        	
        	for(var iObjectCount = 0; iObjectCount < sforceObjectDescribes.length; iObjectCount++) {
        		metadata[sforceObjectDescribes[iObjectCount].objectAPIName] = sforceObjectDescribes[iObjectCount];
        	}
        	metadata.context = this;
        	this.__processTranslations(metadata.translations);
        	var instAdmin = SVMX.create('com.servicemax.client.installigence.admin.root.RootPanel',{
				collapsible : false,
				titleAlign: 'center', 
    			frame: 'true',
    			style: 'margin:10px',
    			layout: {
    				padding: '0'
    			},
        		metadata: metadata
            });
	       	/*var me = this;
	       	var svmxProfiles = metadata.svmxProfiles;
	       	var ibValueMappings = metadata.ibValueMaps;
	       	if(svmxProfiles !== undefined)
	       		me.profiles.loadData(svmxProfiles);
	       	if(ibValueMappings !== undefined)
	       		me.actionSearchGrid.ibFieldMappingsComboBox.getStore().loadData(ibValueMappings);*/
        	
        },
        
        __processTranslations: function(translationsArr) {
        	
        	var i, ilength = translationsArr.length;
        	var translations = {};
        	for(i = 0; i < ilength; i++) {
        		translations[translationsArr[i].Key] = translationsArr[i].Text;
        	}
        	window.$TR = translations;        	
        },
        
        blockUI : function(){
        	var opts = {
        			  lines: 25, // The number of lines to draw
        			  length: 25, // The length of each line
        			  width: 5, // The line thickness
        			  radius: 30, // The radius of the inner circle
        			  corners: 1, // Corner roundness (0..1)
        			  rotate: 0, // The rotation offset
        			  direction: 1, // 1: clockwise, -1: counterclockwise
        			  color: '#ffa384', // #rgb or #rrggbb or array of colors
        			  speed: 3, // Rounds per second
        			  trail: 60, // Afterglow percentage
        			  shadow: false, // Whether to render a shadow
        			  hwaccel: false, // Whether to use hardware acceleration
        			  className: 'spinner', // The CSS class to assign to the spinner
        			  zIndex: 2e9 // The z-index (defaults to 2000000000)
        			};
        			
        	this.__spinner = new Spinner(opts).spin($("#" + SVMX.getDisplayRootId())[0]);
        },
        
        unblockUI : function(){
        	this.__spinner.stop();
        }
	});	
	
})();