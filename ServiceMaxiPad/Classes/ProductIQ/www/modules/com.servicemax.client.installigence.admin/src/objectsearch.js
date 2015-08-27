/**
 * 
 */
(function(){
	
	var objSearchImpl = SVMX.Package("com.servicemax.client.installigence.admin.objectsearch");

objSearchImpl.init = function(){
	
	objSearchImpl.Class("ObjectSearch", com.servicemax.client.lib.api.Object, {
		__d : null, __inited : false, __config : null,
		__objectInfo : null, __store : null, __grid : null, __win : null,
		
		__constructor : function(config){
			this.__inited = false;
			this.__config = config;
		},
		
		find : function(){
			this.__d = $.Deferred();
			
			this.__showUI();
			
			return this.__d;
		},
		
		__init : function(){
			
		},
		
		__initComplete : function(){
			this.__inited = true;
			this.__showUI();
		},
		
		__find : function(params){
			SVMX.getCurrentApplication().blockUI();
			var evt = SVMX.create("com.servicemax.client.lib.api.Event",
					"INSTALLIGENCEADMIN." + this.__config.mvcEvent, this, 
					{request : { context : this, handler : this.__findComplete, text : params.text}});
			SVMX.getCurrentApplication().getEventBus().triggerEvent(evt);
		},
		
		__findComplete : function(data){
			this.__store.loadData(data);
			SVMX.getCurrentApplication().unblockUI();
		},
		
		__showUI : function(){
			// prepare UI
			this.__win = this.__getUI();
			this.__win.show(this.__config.sourceComponent);
			
			this.__find({});
		},
		
		__tryResolve : function(){
			var selectedRecords = this.__grid.getSelectionModel().getSelection();
        	if(selectedRecords.length == 0) return;
        	
        	var recs = [], i, l = selectedRecords.length;
        	for(i = 0; i < l; i++){
        		recs.push(selectedRecords[i].data);
        	}
        	
        	this.__d.resolve(recs);
        	this.__win.close();
		},
		
		__getUI : function(){
			
			var cols = this.__config.columns, i, l = cols.length, me = this;
			var objectDescribe = this.__config.objectDescribe, objectFields = this.__config.objectDescribe.fields;
			// store
			var fields = [];
			for(i = 0; i < l; i++){ fields.push(cols[i].name); }
			var store = SVMX.create('com.servicemax.client.ui.components.composites.impl.SVMXStore', {fields:fields, data:[]});
			
			//grid
			var gridColumns = [], c, j;
			for(i = 0; i < l; i++){
				c = cols[i];
				for(j = 0; j < objectFields.length; j++) {
					if(objectFields[j].fieldAPIName === c.name) {
						gridColumns.push({ text : objectFields[j].fieldLabel, dataIndex : c.name, flex : 1 });
					}
				}
								
			}

			var grid = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXGrid', {
        	    store: store,
        	    selModel: {selType : 'checkboxmodel', checkOnly : true, mode : 'SINGLE'},
        	    columns: gridColumns, flex : 1, width: "100%"
        	});
			
			// searchText
        	var searchText = SVMX.create("com.servicemax.client.installigence.ui.components.SVMXTextField", {
        		width: '70%', emptyText : 'Search', enableKeyEvents : true,
        		listeners : {
        			keyup : function(that, e, opts) {
        				if(e.getKey() == e.ENTER){
        					me.__find({ text : searchText.getValue()});
        				}
        			}
        		}
        	});
        	
			// window
			var win = SVMX.create("com.servicemax.client.ui.components.controls.impl.SVMXWindow", {
				layout : {type : "vbox"}, height : 400, width : 700, title : objectDescribe.objectLabel,
				dockedItems : [
				    {
				    	dock: 'top', xtype: 'toolbar', margin: '0',
				    	items : [
				    	    searchText,
					       	{ xtype: 'button', text: "Go", handler : function(){
					       		me.__find({ text : searchText.getValue()});
					       	}}
				    	]
				    }
				],
				maximizable : true, items : [grid], modal : true,
				buttons : [
				    {text : $TR.CREATE, handler : function(){ me.__tryResolve(); }},
				    {text : $TR.CANCEL, handler : function(){ win.close(); }}
				]
			});
			
			this.__store = store;
			this.__grid = grid;
			return win;
		}
	}, {});
};

})();