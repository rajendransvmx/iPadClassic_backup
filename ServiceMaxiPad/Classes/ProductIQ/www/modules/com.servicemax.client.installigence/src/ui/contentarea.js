/**
 * 
 */

(function(){
	
	var contentareaImpl = SVMX.Package("com.servicemax.client.installigence.contentarea");

contentareaImpl.init = function(){
	
	/**
	 * EVENTS:
	 * 01. node_selected
	 */
	Ext.define("com.servicemax.client.installigence.contentarea.ContentArea", {
        extend: "com.servicemax.client.installigence.ui.components.SVMXPanel",
        alias: 'widget.installigence.contentarea',
        __ibtree : null, __record : null, __meta : null,
        
        constructor: function(config) {
        	
        	this.__meta = config.meta;
        	var ibtree = SVMX.create("com.servicemax.client.installigence.ibtree.IBTree", {
    			width: '33%', margin: '0 7', meta : config.meta
    		});
        	
        	ibtree.on("node_selected", function(nodes){
        		this.fireEvent("node_selected", nodes);
        	}, this);
        	
    		/*var documents = SVMX.create("com.servicemax.client.installigence.documents.Documents", {
    			flex: 1, margin: '2 3 0 0', collapsible:true, collapseDirection:'left'
    		});
    		
    		var topography = SVMX.create("com.servicemax.client.installigence.topography.Topography", {
    			flex: 1, margin: '2 7 0 4', collapsible:true, collapseDirection:'right'
    		});
    		
    		var configuration = SVMX.create("com.servicemax.client.installigence.configuration.Configuration", { 
    			flex: 1, margin: '0 7 0 2', collapsible:true, collapseDirection:'right'
    		});*/
    		
    		var record = SVMX.create("com.servicemax.client.installigence.record.Record", {
    			flex: 1, margin: '0 5 0 0', style: 'paddding: 10px',
    			tree : ibtree, meta : this.__meta
    		});
    		
        	config = Ext.apply({
        		cls: 'mid-panels-container',
				style: 'border-width: 0 !important',
				layout: {
					type: 'hbox',
					align: 'stretch'
				},
				items:[
				       {
						xtype: 'container', width: '100%',
						layout: { type: 'vbox', align: 'stretch' },
						items: [{
							xtype: 'container', flex: 1,
							layout: { type: 'hbox', align: 'stretch' },
							items: [ibtree, record, /*configuration*/]
						}/*,{
							xtype: 'container', flex: 1,
							layout: { type: 'hbox', align: 'stretch' },
							items: [documents, topography]
						}*/]
					}
				]
            }, config || {});
        	
        	this.__ibtree = ibtree;
            this.__record = record;
        	this.setup();
            this.callParent([config]);
        },
        
        addToTree : function(children, parent, type){
            this.__ibtree.addToTree(children, parent, type);
        },

        addClonedToTree : function(record, cloned, type, cascade){
            this.__ibtree.addClonedToTree(record, cloned, type, cascade);
        },

        deleteFromTree : function(node){
            this.__ibtree.deleteFromTree(node);
        },
        
        refreshContent : function(params){
        	this.__ibtree.refreshContent(params);
        },

        refreshRecord : function(){
            this.__record.refreshData();
        },

        selectTreeNode : function(recordId){
            this.__ibtree.selectTreeNode(recordId);
        },
        
        setup : function() {
            this.__meta.bind("MODEL.UPDATE", function(evt){
                this.refresh();
            }, this);
        },
        
        refresh : function() {
        	var me = this;
        }       
        
    });
	
};

})();

// end of file