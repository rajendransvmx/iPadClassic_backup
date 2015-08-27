/**
 * 
 */

(function(){
	
	var documentsImpl = SVMX.Package("com.servicemax.client.installigence.documents");

documentsImpl.init = function(){
	
	Ext.define("com.servicemax.client.installigence.documents.Documents", {
        extend: "com.servicemax.client.installigence.ui.components.SVMXPanel",
        alias: 'widget.installigence.documents',
        
        constructor: function(config) {	
        	config = Ext.apply({
        		title: 'Documents',
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
					src: 'modules/com.servicemax.client.installigence.ui.components/resources/extjsthemes/installigence/images/custom/dummy1.jpg'
				}]
            }, config || {});
            this.callParent([config]);
        }
    });
	
};

})();

// end of file