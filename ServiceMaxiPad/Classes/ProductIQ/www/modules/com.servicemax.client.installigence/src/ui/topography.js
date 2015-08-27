/**
 * 
 */

(function(){
	
	var topographyImpl = SVMX.Package("com.servicemax.client.installigence.topography");

topographyImpl.init = function(){
	
	Ext.define("com.servicemax.client.installigence.topography.Topography", {
        extend: "com.servicemax.client.installigence.ui.components.SVMXPanel",
        alias: 'widget.installigence.topography',
        
        constructor: function(config) {	
        	config = Ext.apply({
        		title: 'Topography',
				cls: 'image-holder',
				listeners: {
					collapse: function () {
					   this.up().doLayout();
					},
					expand: function () {
					   this.up().doLayout();
					}
				},
				items:[{
					xtype: 'image',								
					src: 'modules/com.servicemax.client.installigence.ui.components/resources/extjsthemes/installigence/images/custom/dummy2.jpg'
				}]
            }, config || {});
            this.callParent([config]);
        }
    });
	
};

})();

// end of file