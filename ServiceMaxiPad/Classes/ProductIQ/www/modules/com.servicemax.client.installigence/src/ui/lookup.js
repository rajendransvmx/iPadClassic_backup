(function(){ 
    var lookupImpl = SVMX.Package("com.servicemax.client.installigence.lookup");
    
lookupImpl.init = function(){
    
    Ext.define("com.servicemax.client.installigence.lookup.TextField", {
        extend: "com.servicemax.client.installigence.ui.components.SVMXTextField",
        alias: 'widget.inst.referencefield',
        
        constructor: function(config) {
            this.callParent([config]);
        }
    });
    
    Ext.define("com.servicemax.client.installigence.lookup.Container", {
        extend: "com.servicemax.client.installigence.ui.components.SVMXFieldContainer", // temporary
        alias: 'widget.inst.fieldcontainer',
        __text : null, __btn : null, __lookup : null,
            
        constructor: function(config) { 
            var me = this;
            config = Ext.apply({
                layout : { type : "hbox"},
                items : [],
                defaults: {
                    hideLabel: true
                }
             }, config || {});
                     
            this.__lookup = SVMX.create("com.servicemax.client.installigence.lookup.Lookup", config);
            this.__text = this.__lookup.getLookupText();
            this.__btn = this.__lookup.getLookupBtn();
                
            this.callParent([config]);
                        
            
        },
        
        setValue : function(value){
            this.__lookup.setValue(value);
        },
        
        getValue : function(){
            return this.__lookup.getValue();
        },
        
        makeReadOnly : function(){
            this.__lookup.readOnly();
        },
        
        getLookupText : function(){
            return this.__lookup.getLookupText();
        },
        
        getLookupBtn : function(){
            return this.__lookup.getLookupBtn();
        },
        
        onAdded : function( container, pos, instanced ){
            this.callParent([ container, pos, instanced ]);
            
            var me = this;
            container.on("resize", function(){
                me.readjustItemsWidth(container.getWidth() - 40);
            }, this);
            
            container.on("all_fields_added", function(){
                me.readjustItemsWidth(container.getWidth() - 40);
            }, this);
        },
        
        readjustItemsWidth : function(width){
            var labelWidth = this.labelEl.getWidth();
            var availableWidth = width - labelWidth - this.__btn.getWidth() - 10; // 25 scrollbar
            this.__text.setWidth(availableWidth);
            
        }
    });
    
    lookupImpl.Class("Lookup", com.servicemax.client.lib.api.Object, {
        __config : null, __lookupBtn : null, __lookupText : null, __inited : false, __objectInfo : null,
        __store : null, __grid : null, __win : null, __value : null, __displayValue : null, __objectName : null,
        __displayFields : null, __searchFields : null, __fields : null, __searchFields : null,__fieldsMap : null,
        __constructor : function(config){
            this.__config = config || [];
            this.__config.items = [];
            this.__config.layout = 'hbox';
            this.__config.cls = 'svmx-lookup-field';
            this.__config.margin = '5, 5';
            this.__config.labelAlign ='right';
            
            this.__parent = config.parent;
            this.__inited = false;          
            this.__objectName = this.__config.objectName; 
            this.__value = "";
            this.__displayValue = "";           
            this.__lookupField();
            this.__fields = this.__getFields(this.__config.columns);
            this.__searchFields = this.__getSearchFields(this.__config.searchColumns);
            this.__parentNodeId = this.__parent.__node.id;
        },
        
        __getFields : function(fields){
            var colFields = ["Id", "Name"];
            for(var key in fields){
                if(fields[key].name && fields[key].name.toLowerCase() == "id") continue;
                if(fields[key].name && fields[key].name.toLowerCase() == "name") continue;
                colFields.push(fields[key].name);
            }
            
            return colFields;
        },      
        
        __getSearchFields : function(fields){
            var colFields = [];
            for(var key in fields){             
                colFields.push(fields[key].name);
            }
            
            return colFields;
        },
        
        __showWindow : function(){
            if(this.__inited == false){ this.__init();}
            else{ this.__showUI(); }
        },
        
        __find1 : function(params){
        	//debugger;
        	SVMX.getCurrentApplication().blockUI();
            this.__parentNodeId = this.__parent.__node.id;
            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                    "INSTALLIGENCE.GET_LOOKUPCONFIG", this, 
                    {request : {
                        context: this,
                        keyword : params.text,
                        handler : params.handler,
                        mflChecked : params.mflChecked,
                        onlineChecked :params.onlineChecked,
                        callType : "BOTH",
                        objectName : this.__objectName,
                        lookupContext : "",
                        lookupQueryField : "",
                        searchOperator : "contains",
                        parentNodeId : this.__config.parent.__node.id
                    }});
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
        },
        
        __find : function(params){
        	//debugger;
        	SVMX.getCurrentApplication().blockUI();
            this.__parentNodeId = this.__parent.__node.id;
            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                    "INSTALLIGENCE." + this.__config.mvcEvent, this, 
                    {request : {
                        context : this,
                        handler : params.handler,
                        mflChecked : params.mflChecked,
                        onlineChecked :params.onlineChecked,
                        fields : params.fields || this.__fields,
                        searchFields : this.__searchFields,
                        objectName: params.objectName || this.__objectName,
                        text : params.text,
                        id : params.value,
                        fieldsDescribe: this.__fieldsMap,
                        parentNodeId : this.__config.parent.__node.id
                    }});
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
        },
        
        __findComplete : function(data, isValid, parentNodeId, gridColomns){
        	SVMX.getCurrentApplication().unblockUI();
            if(parentNodeId !== this.__parentNodeId){
                return;
            }
            if(data.length || isValid){
            	//this.__win = this.__getUI(gridColomns);
            	this.__store.loadData(data);
                //this.__win.show();
            }else{
                this.__initDisable();
            }
        },
        
        __initialLoad : function(data){
            SVMX.getCurrentApplication().unblockUI();
            if(data && data[0]){
                this.setDisplayValue(data[0].Name);
            }else{
                //search actual records, which may search remote (thereby slower)
                this.__find({value: this.__value, handler : this.__getNameFieldComplete});
            }
        },
        
        __getNameFieldComplete: function(data, isValid, parentNodeId){
            SVMX.getCurrentApplication().unblockUI();
            if(parentNodeId !== this.__parentNodeId){
                return;
            }
            if(data && data[0]){
                this.setDisplayValue(data[0].Name);
            }else{
                this.setDisplayValue('');
            }
        },

        __searchComplete : function(data, isValid, parentNodeId){
            SVMX.getCurrentApplication().unblockUI();
            this.__store.loadData(data);
        },
        
        __init : function(){
            var syncService = SVMX.getClient().getServiceRegistry()
            .getService("com.servicemax.client.installigence.sync").getInstance(), me = this;
            syncService.getSObjectInfo(this.__config.objectName)
            .done(function(info){
                me.__objectInfo = info;
                me.__fieldsMap = {};
                if(info){
                    var i = 0,l = info.fields.length;
                    for(i = 0; i < l; i++){
                        me.__fieldsMap[info.fields[i].name] = info.fields[i]
                    }
                }else{
                    me.__fieldsMap = {
                        Id : {type : "text"},
                        Name : {type : "text"}
                    };
                    me.__objectInfo = {
                        fields : [
                            {name : "Name", label : "Name"}
                        ]
                    }
                }
                me.__initComplete();
            });
        },
        
        __initComplete : function(){
            this.__inited = true;
            this.__showUI();
        },

        __initDisable : function(){
            this.__lookupText.disable();
            this.__lookupBtn.disable();
            SVMX.getCurrentApplication().showQuickMessage("info", "No records found");
            if(this.__win){
                this.__win.close();
            }
        },
        
        __showUI : function(){
            this.__win = this.__getUI();            
            this.__find({handler : this.__findComplete, text : this.__lookupText.getValue(), fields: this.__fields});
            //this.__find1({handler : this.__findComplete, keyWord : this.__lookupText.getValue(), objectName : this.__objectName});
            ///this.__win = this.__getUI();
            this.__win.show();
        },
        
        getValue : function(){
            return this.__value;
        },
        
        getDisplayValue : function(){
            return this.__displayValue;
        },
        
        readOnly : function(){
            this.__lookupText.readOnly = true;
            this.__lookupBtn.disabled = true;
        },
        
        setValue: function(value){
            this.__value= value;
            if(value == ""){
                this.setDisplayValue(""); return;
            }
            if(this.__store == null || this.__store.find("Id", value) == -1){
                this.setDisplayValue('');
                this.__find({value: value, handler : this.__initialLoad, objectName : "RecordName"});
            }else{
                this.setDisplayValue(this.__store.findRecord("Id", value).get("Name"));
            }
        },
        
        setDisplayValue: function(value){
            this.__displayValue = value;
            this.__lookupText.setValue(value);
        },
        
        getLookupText: function(){
            return this.__lookupText;
        },
        
        getLookupBtn: function(){
            return this.__lookupBtn;
        },
        
        __lookupField : function(){         
            
            // show the field
            var me = this;
            var items = [];
            this.__lookupBtn = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXButton', {
                iconCls: 'svmx-lookup-icon',
                margin: '0, 5', 
                flex: 1,
                disabled: this.__config.fld.readOnly, 
                handler: function(){
                    me.__showWindow();
                }
            });
         
            this.__lookupText = SVMX.create('com.servicemax.client.installigence.lookup.TextField', {
                value: this.getValue(),
                readOnly: this.__config.fld.readOnly,
                allowBlank: this.__config.fld.required,
                listeners: {
                    specialkey: function(f,e){
                        if(e.getKey() == e.ENTER){
                            me.__showWindow();
                        }
                    },
                    blur: function(){
                        if(this.getValue().trim() === ''){
                            // Clear lookup value
                            me.setValue('');
                        }
                    }
                }
            });
            
            this.__config.items.push(this.__lookupText);
            this.__config.items.push(this.__lookupBtn);
        },
        
        __getUI : function(displayCols){
        
        	var me = this;
            var cols = this.__fields, i, l = cols.length, me = this;
            
            if(displayCols && displayCols !== undefined && displayCols.length > 0){
        		cols = displayCols;
        		l = cols.length;
            }
        	
           
            // store
            var fields = [];
            for(i = 0; i < l; i++){ fields.push(cols[i]); }
            var store = SVMX.create('com.servicemax.client.ui.components.composites.impl.SVMXStore', {fields:fields, data:[]});
            
            //grid
            var gridColumns = [], objectInfo = this.__objectInfo, j, oFields = objectInfo.fields, t = oFields.length, c;
            for(i = 0; i < l; i++){
                c = cols[i];
                for(j = 0; j < t; j++){
                    if(c == oFields[j].name && c != "Id"){
                        gridColumns.push({ text : oFields[j].label, dataIndex : c, flex : 1 });
                    }
                }
            }

            var grid = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXGrid', {
                store: store,
                forceFit : true, columns: gridColumns, flex : 1, width: "100%", autoScroll: true,
                viewConfig: {
                    listeners: {
                        itemdblclick: function(dataview, record, item, index, e) {
                            // TODO: remove this mapping eventually
                            if(me.__objectName === "Product2"){
                                for(var i = 0; i < me.__parent.items.items.length; i++){
                                    var item = me.__parent.items.items[i];
                                    if(item.fld.name === "Category__c"){
                                        item.setValue(record.data.CategoryId__c);
                                    }else if(item.fld.name === "DeviceType2__c"){
                                        item.setValue(record.data.DeviceType2__c);
                                    }else if(item.fld.name === "Brand2__c"){
                                        item.setValue(record.data.Brand2__c);
                                    }
                                }
                            }
                            me.setValue(record.data.Id);
                            me.setDisplayValue(record.data.Name);
                            me.__lookupText.focus();
                            me.__win.close();
                        }
                    }
                }
            });

            // searchText
            var searchText = SVMX.create("com.servicemax.client.installigence.ui.components.SVMXTextField", {
                width: '50%', emptyText : 'Search', enableKeyEvents : true,
                value: me.getDisplayValue(),
                listeners : {
                    keyup : function(that, e, opts) {
                        if(e.getKey() == e.ENTER){
                            me.__find({
                                text : searchText.getValue(),
                                handler : me.__searchComplete,
                                fields: me.__fields
                            });
                        }
                    }
                }
            });       
            //Search Checkboxes
            var searchOption = SVMX.create("com.servicemax.client.installigence.ui.components.SVMXCheckboxGroup", {
            	xtype : 'checkboxgroup',
            	columns : 1,
            	horizontal : true,
            	items : [
            	        
            	        { boxLabel: 'Include MFL Records', name: 'MFLChecked', inputValue: 'true' },
            	        { boxLabel: 'Include Online Records', name: 'OnlineChecked', inputValue: 'true' }
            	       
            	       ]
            });       
            // window
            var win = SVMX.create("com.servicemax.client.ui.components.controls.impl.SVMXWindow", {
                layout : {type : "vbox"}, height : 400, width : this.__lookupText.getWidth() + this.__lookupBtn.getWidth() + 100,
                closable: true, maximizable: false, animateTarget: me.__lookupBtn,
                dockedItems : [
                    {
                        dock: 'top', xtype: 'toolbar', margin: '0',
                        items : [
                            searchText,
                            {
                                xtype: 'button', text: "Go",
                                handler : function(){
                                    me.__find({
                                        text : searchText.getValue(),
                                        handler : me.__searchComplete,
                                        fields: me.__fields,
                                        mflChecked : searchOption.getValue().MFLChecked,
                                        onlineChecked : searchOption.getValue().OnlineChecked
                                        
                                    });
                                }
                            },
                            searchOption,
                        ]
                    }
                ],
                minWidth: this.__lookupText.width , layout: {
                    padding: 5
                }, layout : 'fit', items : [grid], modal : true
            });
            var toXY = this.__lookupText.getXY();
            win.setPosition(toXY[0], toXY[1] + 30); 
            this.__store = store;
            this.__grid = grid;
            return win;
        }
        
    });
}
})();