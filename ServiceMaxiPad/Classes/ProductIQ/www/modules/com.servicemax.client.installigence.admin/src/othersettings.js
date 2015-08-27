(function(){
	var setupOtherSettings = SVMX.Package("com.servicemax.client.installigence.admin.othersettings");

setupOtherSettings.init = function() {
		Ext.define("com.servicemax.client.installigence.admin.OtherSettings", {
	        extend: "com.servicemax.client.installigence.ui.components.SVMXPanel",
	        
	       constructor: function(config) {
	    	   
	    	   var automaticSwapProperty = SVMX.create("com.servicemax.client.installigence.ui.components.Checkbox", {
	    		   boxLabel: $TR.OTHER_SET_SWAP_TEXT,
	    		   style: 'margin: 3px 0'					
	    	   });
	    	   config = config || {};
	    	   config.items = [];
	    	   config.items.push(automaticSwapProperty);
	    	   config.title = $TR.OTHERSETTINGS;
	    	   this.callParent([config]);
	       }
		});
	}
})();