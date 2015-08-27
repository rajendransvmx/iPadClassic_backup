/**
 * 
 */

(function(){
	
	var configurationImpl = SVMX.Package("com.servicemax.client.installigence.configuration");

configurationImpl.init = function(){
	
	Ext.define("com.servicemax.client.installigence.configuration.Configuration", {
        extend: "com.servicemax.client.installigence.ui.components.SVMXFormPanel",
        alias: 'widget.installigence.configuration',
        
        constructor: function(config) {	
        	config = Ext.apply({
        		title: 'Configuration',
        		titleAlign: 'center',
        		ui: 'svmx-white-panel',
        		listeners: {
					collapse: function () {
					   this.up().doLayout();
					},
					expand: function () {
						this.up().doLayout();
					}
				},
				layout: 'anchor',
				defaults: {
					anchor: '100%',
					padding: '10',
					labelAlign: 'right'
				},
				defaultType: 'textfield',
				items: [{
					fieldLabel: 'Throughput',
					name: 'throughput'
				},{
					fieldLabel: 'Oil Level',
					name: 'oillevel'
				}]
            }, config || {});
            this.callParent([config]);
        }
    });
	
};

})();

// end of file