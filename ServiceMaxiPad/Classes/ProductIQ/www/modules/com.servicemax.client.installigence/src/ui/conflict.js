/**
 * 
 */
(function(){
    
    var conflictImpl = SVMX.Package("com.servicemax.client.installigence.conflict");

conflictImpl.init = function(){
    
    conflictImpl.Class("Conflict", com.servicemax.client.lib.api.Object, {
        __config : null,
        __data : null,
        __store : null,
        __grid : null,
        __win : null,
        __root : null,
        
        __constructor : function(config){
            this.__config = config;
            this.__root = config.root;
        },
        
        show : function(){
            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                    "INSTALLIGENCE.GET_SYNC_CONFLICTS", this, {request : {context : this}});
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
        },

        onGetSyncConflictsComplete : function(result){
            this.__data = result;
            this.__showUI();
        },
        
        __showUI : function(){
            this.__win = this.__getUI();
            this.__store.setData(this.__data);
            this.__win.show(this.__config.sourceComponent);
        },

        __save : function(){
            var records = [];
            for(var i = 0; i < this.__store.getCount(); i++){
                var rec = this.__store.getAt(i);
                records.push({
                    Id : rec.get("Id"),
                    Action : rec.get("Action")
                });
            }
            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                    "INSTALLIGENCE.UPDATE_SYNC_CONFLICTS", this, {request : {context : this, records : records}});
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
        },

        __startSync : function(){
            this.__syncing = true;
            this.__save();
        },

        __selectTreeNode : function(recordId){
            this.__root.selectTreeNode(recordId);
        },

        onUpdateSyncConflictsComplete : function(a, b, c){
            if(this.__syncing){
                this.__root.handleIncrementalSync();
                delete this.__syncing;
            }
        },
        
        __getUI : function(){
            var me = this;

            var conflictData = [
                {disp : "<b>Select action</b>", val : ""},
                {disp : "Apply online changes", val : "SERVER_OVERRIDE"}];
            var errorInsertData = [
                {disp : "<b>Select action</b>", val : ""},
                {disp : "Delete record", val : "CLIENT_DELETE"},
                {disp : "Retry", val : "CLIENT_OVERRIDE"}];
            var errorData = [
                {disp : "<b>Select action</b>", val : ""},
                {disp : "Restore record from online", val : "SERVER_OVERRIDE"},
                {disp : "Retry", val : "CLIENT_OVERRIDE"}];

            var setStore = function(type, operation, store) {
                store.removeAll();
                if (type == "conflict") {
                    store.add(conflictData);
                } else if (type == "error" && operation == "insert") {
                    store.add(errorInsertData);
                } else if (type == "error") {
                    store.add(errorData);
                }
            };

            var actionselect = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXComboBox', {
                valueField : "val",
                displayField : "disp",
                queryMode: "local",
                store : {
                    xtype : "svmx.store",
                    fields : ["val", "disp"],
                    data : []
                },
                listeners : {
                    beforequery : function(queryPlan, eOpts) {
                        var grid = me.__win.items.get(0);
                        var error_type = grid.selModel.getSelection()[0].get("Type");
                        var operation =  grid.selModel.getSelection()[0].get("Operation");
                        setStore(error_type, operation, actionselect.store);
                    }
                }
            });
            
            var datastore = SVMX.create('com.servicemax.client.ui.components.composites.impl.SVMXStore', {
                fields : ["Id", "Message", "CreatedDate", "Action", "record"],
                data : []
            });
            var grid = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXGrid', {
                flex : 1, width: "100%",
                store : datastore,
                selModel: 'cellmodel',
                plugins: {
                    ptype: 'cellediting',
                    clicksToEdit: 1
                },
                columns: [
                    {
                        text : "Record",
                        dataIndex : "Id",
                        flex : 1.5,
                        renderer : SVMX.proxy(this, this.__nameFieldRenderer)
                    },
                    {
                        text : "Message",
                        dataIndex : "Message",
                        flex : 2,
                        renderer : function(value){
                            return '<div style="white-space: pre-wrap">'+value+'</div>';
                        }
                    },
                    /*{
                        text : "Conflict Date",
                        dataIndex : "CreatedDate",
                        flex : 1,
                        renderer : function(value){
                            return new Date(value);
                        }
                    },*/
                    {
                        text : "Action",
                        dataIndex : "Action",
                        flex : 1.5,
                        editor : actionselect,
                        readOnly : false,
                        queryCaching : false,
                        renderer : function(value, styleObj, record) {
                            var error_type = record.get("Type");
                            var operation =  record.get("Operation");
                            setStore(error_type, operation, actionselect.store);
                            var idx = actionselect.store.find(actionselect.valueField, value);
                            var rec = actionselect.store.getAt(idx);
                            return rec ? rec.get(actionselect.displayField) : "<b><i>"+"Select action"+"...</i></b>";
                        }
                    }
                ]
            });
            
            var win = SVMX.create("com.servicemax.client.ui.components.controls.impl.SVMXWindow", {
                layout : {type : "vbox"}, height : 400, width : 800,
                title : "Synchronization Conflicts/Errors",
                maximizable : true,
                items : [grid],
                modal : true,
                buttons : [
                    {text : "Retry", handler : function(){
                        me.__startSync();
                        win.close();
                    }},
                    {text : "Hold", handler : function(){
                        me.__save();
                        win.close();
                    }},
                    {text : "Close", handler : function(){
                        win.close();
                    }}
                ]
            });
            
            this.__store = datastore;
            this.__grid = grid;
            return win;
        },

        __nameFieldRenderer : function(value, meta, record){
            var me = this;
            var id = Ext.id();
            var rec = record.get('record');
            var recordId = rec.Id || value;
            var nameValue = rec.CaseNumber || rec.Name;
            if(nameValue !== false){
                nameValue = nameValue || "New Record";
                Ext.defer(function(){
                    $('<a>', {
                        text: nameValue,
                        href: 'javascript:void(0);',
                        click: function() {
                            me.__selectTreeNode(recordId);
                            me.__win.close();
                        }
                    }).appendTo('#' + id);
                }, 25);
                return Ext.String.format('<div id="{0}"></div>', id);
            }else{
                return "--None--";
            }
        }

    }, {});
};

})();