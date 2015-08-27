/**
 * 
 */

(function(){
    
    var findandgetImpl = SVMX.Package("com.servicemax.client.installigence.findandget");

findandgetImpl.init = function(){
    
    Ext.define("com.servicemax.client.installigence.findandget.FindAndGet", {
        extend: "com.servicemax.client.installigence.ui.components.SVMXPanel",
        alias: 'widget.installigence.findandget',
        meta : null, root: null, grid : null, __params : null, __searchStatus : null, __inited : null, 
        __config : null, __fieldsMap : null, __objectInfo : null, __config : null, __store : null,
        
        constructor: function(config) { 
        	
        	this.__inited = false;
			
            this.meta = config.meta;
            this.root = config.root;
            var me = this;
            this.__init();           
            this.meta.bind("MODEL.UPDATE", function(evt){
            	this.__initComplete();
            }, this);
            config = Ext.apply({
                title: '<span class="title-text">' + $TR.FIND_AND_GET +'</span>',
                titleAlign: 'center', 
                frame: 'true',
                collapsible : false,
                style: 'margin:10px',
                height : SVMX.getWindowInnerHeight() - 40,
                toolPosition: 0,
                tools: [{
                    type:'backbtn',
                    cls: 'svmx-back-btn',
                    handler: function(e, el, owner, tool){          
                        me.__handeNavigateBack();       
                    }
                }],
                layout: "fit",
                items : this.__getUI(),
                dockedItems : this.__getDockedUI()
            }, config || {});
            this.callParent([config]);            
        },
		
		__init : function(){
			var syncService = SVMX.getClient().getServiceRegistry()
    		.getService("com.servicemax.client.installigence.sync").getInstance(), me = this;
			syncService.getSObjectInfo(SVMX.getCustomObjectName("Installed_Product"))
			.done(function(info){
				me.__objectInfo = info;
				me.__fieldsMap = {};
				var i = 0,l = info ? info.fields.length : 0;
				for(i = 0; i < l; i++){
					if(info.fields[i].name == "Id") info.fields[i].label = "Id";
					me.__fieldsMap[info.fields[i].name] = info.fields[i]
				}				
				me.__initComplete();
			});
		},
		
		__getDisplayColumns : function(){
			var columns = [];
			var displayColumns = this.meta.ibDisplayFields && this.meta.ibDisplayFields.length > 0 ? this.meta.ibDisplayFields : [{name: "Name", priority: "1"}];			
			if(this.__fieldsMap && this.__fieldsMap["Name"]){
				var i = 0, l = displayColumns.length;
				for(i = 0; i < l; i++){
					columns.push(this.__fieldsMap[displayColumns[i].name].label);
				}
			}else
				columns.push($TR.INSTALLED_PRODUCT_ID_LABEL);
			if(columns.indexOf("Id") < 0){
				columns.push("Id");
			}
			return columns;
		},
		
		__getAPIColumns : function(){
			var dispcolumns = 
					this.meta.ibDisplayFields && this.meta.ibDisplayFields.length > 0 ? this.meta.ibDisplayFields : [{name: "Name", priority: "1"}];			
			var columns = [],i , l = dispcolumns.length;
			for(i = 0; i < l ; i++){
				columns.push(dispcolumns[i].name);
			}
			if(columns.indexOf("Id") < 0){
				columns.push("Id");
			}
			return columns;
		},
		
		__getSearchColumns : function(){
			var searcolumns = 
				this.meta.ibSearchFields && this.meta.ibSearchFields.length > 0 ? this.meta.ibSearchFields : [{name: "Name", priority: "1"}];			
			var columns = [],i , l = searcolumns.length;
			for(i = 0; i < l ; i++){
				columns.push(searcolumns[i].name);
			}
			return columns;
		},		
		
		__initComplete : function(){
			this.__inited = true;
			var dispcolumns = this.__getDisplayColumns();
            var store = SVMX.create('com.servicemax.client.ui.components.composites.impl.SVMXStore', {
                fields: dispcolumns,
                data:[]
            });
            this.__store.fields = dispcolumns;
            var i = 0, l = dispcolumns.length, columns = [];
            for(i = 0; i < l; i++){
            	if(dispcolumns[i] == "Id") continue;
            	columns.push({text: dispcolumns[i],  dataIndex: dispcolumns[i], flex: 1 });
            }
            this.grid.columns = columns; 
            this.grid.reconfigure(this.__store, columns);
		},
        
        __getDockedUI : function(){
            var me = this;
            
            // search
            var searchText = SVMX.create("com.servicemax.client.installigence.ui.components.SVMXTextField", {
                width: '25%', emptyText : $TR.SEARCH, enableKeyEvents : true,
                listeners : {
                    keyup : function(that, e, opts) {
                        if(e.getKey() == e.ENTER){
                            me.find(this.getValue(), findBtn.actionId);
                        }
                    }
                }
            });
            
            // find button
            var findBtn = null;
            findBtn = SVMX.create('Ext.button.Split', {
                text: $TR.FIND_BY_IB, actionId : "FIND_BY_IB", 
                handler: function() {
                    me.find(searchText.getValue(), this.actionId);
                },
                __update : function(item){
                    this.setText(item.text);
                    this.actionId = item.actionId;
                    this.handler();
                },
                menu: SVMX.create('com.servicemax.client.installigence.ui.components.Menu', {
                    showSeparator : false,
                    items: [
                        {actionId : "FIND_BY_IB", text: $TR.FIND_BY_IB, handler: function(item){  findBtn.__update(item); }},
                        {actionId : "FIND_BY_TEMPLATE", disabled : true, text: $TR.FIND_BY_TEMPLATE, handler: function(item){  findBtn.__update(item); }},
                        {actionId : "FIND_BY_PRODUCT", disabled : true, text: $TR.FIND_BY_PRODUCT, handler: function(item){  findBtn.__update(item); }}
                    ]
                })
            });
            
            this.__searchStatus = SVMX.create("com.servicemax.client.installigence.ui.components.SVMXDisplayField", {});
            
            var items = 
            [
                {dock: 'top', xtype: 'toolbar', margin: '0',
                items:[ 
                        searchText,
                        findBtn,
                        this.__searchStatus,
                        '->',
                        { xtype: 'button', text: $TR.GET, handler : function(){
                            me.getIBs();
                        }}
                ]}
            ];
            
            return items;
        },
        
        findLMIBs : function(){
            this.root.blockUI();
            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                    "INSTALLIGENCE.GET_LM_TOP_LEVEL_IBS", this, {request : { context : this, ids: [], params : this.__params}});
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
        },
        
        onGetLMTopLevelIBsComplete : function(results){
            this.root.unblockUI();
            var actionId = "FIND_BY_IB";
            if(results.length > 0){
                this.find("", actionId, results, true);
            }else if(this.__findingLMIBs){
                this.getIBs();
            }
        },      
        
        getIBs : function(){
            var selectedRecords = this.grid.getSelectionModel().getSelection();
            // Should continue to sync if findingLMIBs, even with no IBs
            if(!this.__findingLMIBs && selectedRecords.length == 0) return;
            
            var ids = [], i, l = selectedRecords.length;
            for(i = 0; i < l; i++){
                ids.push(selectedRecords[i].getData().Id);
            }
            
            this.root.blockUI();
            var syncService = SVMX.getClient().getServiceRegistry()
                .getService("com.servicemax.client.installigence.sync").getInstance();
            
            var p = {
                IBs : ids,
                type : this.__params ? this.__params.syncType : "ib"
            };
            
            syncService.start(p);
        },

        resetLocalIBs : function(){
            this.root.blockUI();
            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                    "INSTALLIGENCE.GET_TOP_LEVEL_IBS", this, {request : { context : this}});
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);    
        },

        onGetTopLevelIBsComplete : function(data){
            var ids = [];
            for(var i = 0; i < data.ibs.length; i++){
                var id = data.ibs[i].Id;
                if (id.indexOf('transient-') === 0) continue;
                ids.push(id);
            }
            var p = {
                IBs : ids,
                type : "reset"
            };
            var syncService = SVMX.getClient().getServiceRegistry()
                .getService("com.servicemax.client.installigence.sync").getInstance();
            syncService.start(p);
        },
        
        handleFocus : function(params){
            var me = this;
            this.__params = params;
            this.grid.getStore().loadData([]);
            this.__searchStatus.setValue("");
            if(params && (params.syncType === "initial" || params.syncType === "reset")){
                this.__checkLaptopMobileExists()
                .done(function(exists){
                    if(exists){
                        // Trigger auto start if LM exists
                        me.__findingLMIBs = true;
                    }
                    me.findLMIBs();
                });
            }
        },

        __checkLaptopMobileExists : function(){
            var d = SVMX.Deferred();
            var request = {
                appName : "LaptopMobile"
            };
            var req = com.servicemax.client.installigence.offline.sal.model.nativeservice.Facade.createCheckExternalRequest();
            req.bind("REQUEST_COMPLETED", function(evt){
                var appinfo = evt.data.data;
                var app = SVMX.toObject(evt.data.data);
                d.resolve(app[0].Installed === "true");
            }, this);
            req.bind("REQUEST_ERROR", function(evt){
                d.resolve({});
            }, this);
            req.execute(request);
            return d;
        },
        
        find : function(text, action, locationIds, selectAll){
            this.root.blockUI();
            if(this.__inited == false){ this.__init();}
            else {
            	var fieldDescribe = this.__fieldsMap && this.__fieldsMap["Name"] ? 
            			this.__fieldsMap : {Name: {label: $TR.INSTALLED_PRODUCT_ID_LABEL, type: "text"}, Id : {label: "Id", type: "text"}};
            	
            	var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                        "INSTALLIGENCE." + action, this, {request : { context : this, text : text, 
                        	params : this.__params, locationIds : locationIds, selectAll : selectAll,
                        	fields : this.__getAPIColumns(), searchFields : this.__getSearchColumns(), fieldsDescribe : fieldDescribe}});
                com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
            }
            
        },
        
        onSearchByIBComplete : function(results){
            this.root.unblockUI();
            this.__searchStatus.setValue(
                    results.data.length + ( results.hasMoreRecords ? "+" : "") + " record(s) found.");

            this.grid.getStore().loadData(results.data);
            if(results.selectAll || this.__findingLMIBs){
                var sm = this.grid.getSelectionModel();
                sm.selectAll(false);
            }
            
            // auto get IBs when triggered from LM
            if(this.__findingLMIBs){
                this.getIBs();
                delete this.__findingLMIBs;
            }
        },

        onSearchByIBError : function(){
            this.root.unblockUI();
        },
        
        __getUI : function(){
            var items = [];
            var dispcolumns = this.__getDisplayColumns();
            var store = SVMX.create('com.servicemax.client.ui.components.composites.impl.SVMXStore', {
                fields: dispcolumns,
                data:[]
            });
            this.__store = store;
            var i = 0, l = dispcolumns.length, columns = [];
            for(i = 0; i < l; i++){
            	if(dispcolumns[i] == "Id") continue;
            	columns.push({text: dispcolumns[i],  dataIndex: dispcolumns[i], flex: 1 });
            }
            
            this.grid = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXGrid', {
                store: store,
                selModel: {selType : 'checkboxmodel', renderer : function(value, metaData, record, rowIndex, colIndex, store, view){
                    if(false && record.get('availableInDB')){
                        return '';
                    }else{
                        return '<div class="x-grid-row-checker" role="presentation">&#160;</div>';
                    }
                }, listeners : { beforeselect : function( that, record, index, eOpts ){
                    return true;//!record.get('availableInDB');
                }}, 
                checkOnly : true},
                columns: columns,
                height: "100%",
                width: "100%",
                scroll: "vertical",
                viewConfig : {   
                    getRowClass: function(record, index) {
                        if (record.get('availableInDB')) {
                            return 'svmx-disabled-row';
                        }
                    }
                }
            });
            
            items.push(this.grid);
            return items;
        },
        
        __handeNavigateBack : function(){
            this.root.handleNavigateBack();
        }
    });
    
};

})();

// end of file
