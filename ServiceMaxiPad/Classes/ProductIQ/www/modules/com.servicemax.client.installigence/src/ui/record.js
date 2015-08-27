/**
 * 
 */

(function(){
    
    var recordImpl = SVMX.Package("com.servicemax.client.installigence.record");

recordImpl.init = function(){
    
    Ext.define("com.servicemax.client.installigence.record.Record", {
        extend: "com.servicemax.client.installigence.ui.components.SVMXPanel",
        alias: 'widget.installigence.record', __views : null, __title : null, __meta : null,
        
        constructor: function(config) { 
            
            this.__meta = config.meta;
            // create different views
            this.__views = this.__createViews();
            this.__title = $TR.RECORD_VIEW_TITLE;
            config = Ext.apply({
                title: this.__title,
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
                layout: {type : "card"},
                items: this.__views
            }, config || {});
            
            config.tree.on("node_selected", function(node){
                this.__render(node);
            }, this);
            
            config.tree.on("reset", function(node){
                this.__resetView();
            }, this);
            
            this.callParent([config]);
        },
        
        __resetView : function(){
            this.removeAll(true);
            this.setTitle(this.__title);
            this.__views = this.__createViews();
            var i, l = this.__views.length;
            for(i = 0; i < l; i++){
                this.add(this.__views[i]);
            }
        },
        
        __createViews : function(){
            var viewClasses = [
                "IBRecord", "LocationRecord", "SubLocationRecord", "AccountRecord"
            ];
            var views = [];
            for(var i = 0; i < viewClasses.length; i++){
                var v = SVMX.create("com.servicemax.client.installigence.record." + viewClasses[i], { root : this, meta : this.__meta});
                v.cardIndex = i;
                views.push(v);
            }
            
            return views;
        },
        
        __render : function(node){
            var v = this.__getViewForNode(node);
            
            if(!v) return; // should not happen!
            
            this.getLayout().setActiveItem(v.cardIndex);
            v.renderNode(node);
            v.currentlyActive = true;
        },
        
        __getViewForNode : function(node){
            var i, v = this.__views, l = v.length;
            for(i = 0; i < l; i++){
                v[i].currentlyActive = false;
                if(v[i].getViewType() == node.nodeType){
                    return v[i];
                }
            }
        },

        __getActiveView : function(){
            var i, v = this.__views, l = v.length;
            for(i = 0; i < l; i++){
                if(v[i].currentlyActive){
                    return v[i];
                }
            }
        },

        refreshData : function(){
            this.__getActiveView().refreshData();
        }
    });
    Ext.define("com.servicemax.client.installigence.record.errorConfirmationView", {
        extend: "com.servicemax.client.installigence.ui.components.SVMXPanel",
        alias: 'widget.installigence.errorConfirmationView',
        __okButtonToConfirm : null, __cancelButtonToConfirm : null, __errorConfirmationLabel : null,
        constructor: function(config) { 
            var me =this;
            
            this.__parent = config.parent;

            this.__errorConfirmationLabel = SVMX.create("com.servicemax.client.installigence.ui.components.SVMXPanel", {
                layout: 'vbox', border: false, width: '100%', style: 'border: none !important;'

            });

            this.__okButtonToConfirm = SVMX.create("com.servicemax.client.installigence.ui.components.SVMXButton", {
                hidden : true, text: 'Ok', flex: 1, margin: '2,2,2,2',
                handler : SVMX.proxy(this, function() {
                    //Save Directly -> saveConfirm
                    
                    this.__parent.__pl.saveConfirm();
                    this.__parent.__errorConfirmationPanel.hide();
                    this.__okButtonToConfirm.hide();
                    this.__cancelButtonToConfirm.hide();
                    this.__parent.root.tree.updateRecordName(this.__parent.__pl.__record.__r.Id, this.__parent.__pl.__record.__r.Name);
                })
            });

            this.__cancelButtonToConfirm = SVMX.create("com.servicemax.client.installigence.ui.components.SVMXButton", {
                hidden : true, text: 'Cancel', flex: 1, margin: '2,2,2,2',
                handler : SVMX.proxy(this, function() {
                    //Save Directly -> saveConfirm
                    
                    this.__parent.refreshData();
                    this.__parent.__errorConfirmationPanel.hide();
                    me.__okButtonToConfirm.hide();
                    me.__cancelButtonToConfirm.hide();
                })
            });

			this.__errorConfirmationButtons = SVMX.create("com.servicemax.client.installigence.ui.components.SVMXPanel", {
                layout: 'hbox', align:'center', width: '100%',style: 'border: none !important;', border: false, defaults: {style: 'border: none !important;'},
                items: [ {flex: 1}, {flex: 1}, {flex: 1}, this.__okButtonToConfirm, this.__cancelButtonToConfirm, {flex: 1}, {flex: 1}, {flex: 1}]
            });
            config = Ext.apply({
                layout : {type : "vbox", align:'center', pack: 'center'},
                overflowY : "auto",
                cls : "grid-panel-borderless",
                border: false,
                items : [
                    this.__errorConfirmationLabel, this.__errorConfirmationButtons
                ]
            }, config || {});
            
            this.callParent([config]);
        },

        hideErrorPanel: function(){

        }
    });

    Ext.define("com.servicemax.client.installigence.record.RecordView", {
        extend: "com.servicemax.client.installigence.ui.components.SVMXPanel",
        alias: 'widget.installigence.recordview',
        __root : null, __bInitialized : false, __node : null, __pl : null,
        __objectName : null, __searchText : null, __readOnly : false, __meta : null,__errorConfirmationPanel : null,
        constructor: function(config) { 
            
            var me = this;
            // search
            this.__searchText = SVMX.create("com.servicemax.client.installigence.ui.components.SVMXTextField", {
                cls: 'toolbar-search-textfield', width: '100%', emptyText : $TR.FIND_ATTRIBUTE + '...', enableKeyEvents : true,
                listeners : {
                    keyup : function(that, e, opts) {
                        clearTimeout(me.__filterTimeout);
                        me.__filterTimeout = setTimeout(function(){
                            me.__filterFields(that.getValue());
                        }, 25);
                    }
                }
            });
            
            this.__errorConfirmationPanel = SVMX.create("com.servicemax.client.installigence.record.errorConfirmationView", {
                hidden : true, autoRender : true, parent : this, width: '100%', layout : 'vbox', border: false
            });

            config = Ext.apply({
                layout : {type : "form"},
                overflowY : "auto",
                width: '100%',
                cls : "grid-panel-borderless",
                items : [],
                dockedItems : [
                    {dock : 'top', xtype : 'toolbar', margin : '0',
                        items : [ this.__searchText ]
                    },
                    {dock : 'top', xtype : 'toolbar', margin : '0',
                        items : [ this.__errorConfirmationPanel]
                    }
                ]
            }, config || {});
            
            this.__root = config.root;
            this.__objectName = config.objectName;
            this.__bInitialized = false;
            this.__readOnly = config.readOnly;
            this.__meta = config.meta;
            this.callParent([config]);
        },
        
        showErrorConfirmation : function(dataValidationResult){
            if(dataValidationResult.data.errors.length > 0 || dataValidationResult.data.warnings.length > 0){
                var errors = "";
                var errorNumber = 1;

                this.__errorConfirmationPanel.__errorConfirmationLabel.removeAll();

                if(dataValidationResult.data.errors.length > 0){

                    this.__errorConfirmationPanel.__okButtonToConfirm.hide();
                    this.__errorConfirmationPanel.__cancelButtonToConfirm.hide();
					

                    this.__errorConfirmationPanel.__errorConfirmationLabel.setTitle("Error(s)");

                    var i=0;
                    for(i=0; i< dataValidationResult.data.errors.length; i++){
                        
                        if(errors.length === 0){
                            if(dataValidationResult.data.errors.length > 1){
                                this.__errorConfirmationPanel.__errorConfirmationLabel.add({
                                    xtype: 'label',
                                    text: " • " + dataValidationResult.data.errors[i].message,
                                    padding: '4px',
                                    width: '100%',
                                    border: false,
                                    style: 'text-wrap: normal !important; color:red;'
                                });
                            }else{
                                this.__errorConfirmationPanel.__errorConfirmationLabel.add({
                                    xtype: 'label',
                                    text: dataValidationResult.data.errors[i].message,
                                    padding: '4px',
                                    width: '100%',
                                    border: false,
                                    style: 'text-wrap: normal !important; color:red;'
                                });
                            }
                        }else{
                            this.__errorConfirmationPanel.__errorConfirmationLabel.add({
                                xtype: 'label',
                                text: " • " + dataValidationResult.data.errors[i].message,
                                padding: '4px',
                                width: '100%',
                                    border: false,
                                style: 'text-wrap: normal !important; color:red;'
                            });
                        }
                    }
                } else if(dataValidationResult.data.warnings.length > 0){

                    this.__errorConfirmationPanel.__errorConfirmationLabel.setTitle("Warning(s)");

                    this.__pl.okcallback = dataValidationResult.okCallBack;
                    for(i=0; i< dataValidationResult.data.warnings.length; i++){
                        
                        if(errors.length === 0){
                            if(dataValidationResult.data.warnings.length > 1){
                                this.__errorConfirmationPanel.__errorConfirmationLabel.add({
                                    xtype: 'label',
                                    text: " • " + dataValidationResult.data.warnings[i].message,
                                    padding: '4px',
                                    width: '100%',
                                    border: false,
                                    style: 'text-wrap: normal !important; color:red;'
                                });
                            }else{
                                this.__errorConfirmationPanel.__errorConfirmationLabel.add({
                                    xtype: 'label',
                                    text: dataValidationResult.data.warnings[i].message,
                                    padding: '4px',
                                    width: '100%',
                                    border: false,
                                    style: 'text-wrap: normal !important; color:red;'
                                });
                            }
                        }else{
                            this.__errorConfirmationPanel.__errorConfirmationLabel.add({
                                xtype: 'label',
                                text: " • " + dataValidationResult.data.warnings[i].message,
                                padding: '4px',
                                    width: '100%',
                                    border: false,
                                style: 'text-wrap: normal !important; color:red;'
                            });
                        }
                    }
                    this.__errorConfirmationPanel.__okButtonToConfirm.show();
                    this.__errorConfirmationPanel.__cancelButtonToConfirm.show();
                }
                this.__errorConfirmationPanel.show();
            }
        },

        hideErrorConfirmation : function(){
            this.__errorConfirmationPanel.hide();
        },

        initComponent: function() {
            this.on('beforeadd', function(me, field){
              if (!field.allowBlank)
                field.labelSeparator += '<span style="color: rgb(255, 0, 0); padding-left: 2px;">*</span>';
            });
            this.callParent(arguments);
        },
        
        __filterFields : function(val){
            var items = this.items || [], i , l = items.length, item, lbl, re;
            
            if(l == 0) return;

            for(i = 0; i < l; i++){
                item = items.getAt(i);
                if(!val) {
                    // Note: Use jQuery for speed. Tests show this is over 10-50x faster
                    $('#'+item.getId()).show();
                    //item.setVisible(true);
                }else{
                    lbl = item.getFieldLabel();
                    re = new RegExp( val, 'i' );
                    if(re.test(lbl)){
                        $('#'+item.getId()).show();
                        //item.setVisible(true);
                    }else{
                        $('#'+item.getId()).hide();
                        //item.setVisible(false);
                    }
                }
            }
        },
        
        getViewType : function(){
            throw new Error("This method should be overridden!");
        },
        
        getPriorityFields : function(){
            throw new Error("This method should be overridden!");
        },
        
        getHiddenFields : function(){
            throw new Error("This method should be overridden!");
        },
        
        renderNode : function(node){
            this.__root.setTitle(node.text);
            this.__node = node;
            
            if(!this.__bInitialized){
                this.__init();
            }else{
                this.refreshData();
				this.hideErrorConfirmation();
            }
        },
        
        __init : function(){
            SVMX.getCurrentApplication().blockUI();
            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                    "INSTALLIGENCE.GET_PAGELAYOUT", this, 
                    {request : { context : this, objectName : this.__objectName }});
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
        },
        
        onGetPageLayoutCompleted : function(pl){
        	this.__pl = SVMX.create("com.servicemax.client.installigence.record.PageLayout", {objectName : this.__objectName, root: this.__root});
            this.__pl.init(pl.DescribeResult, pl.dataValidationRules);
			//this.__pl.init(pl);
            this.__bInitialized = true;
            this.__layout();
        },
        
        __layout : function(){
        	SVMX.getCurrentApplication().unblockUI();
            var labelLength;
            var fields = this.__pl.fields, i, l = fields.length, f, type, cls, fieldElem, name, ro, ab, isAutoNumber;
            var priorityFields = this.getFields(this.getPriorityFields());
            var hiddenFields = this.getFields(this.getHiddenFields());
            var priorityUIFields = {};
            //var nameSearchInfo = this.__pl.nameSearchInfo;
            var fieldElems = [];
            for(i = 0; i < l; i++){
                f = fields[i]; type = f.type, name = f.name, isAutoNumber = f.autoNumber;
                if(type == "id") continue;
                
                if(     name == "SystemModstamp" || name == "LastReferencedDate" || name == "LastViewedDate"
                    ||  name == "LastActivityDate" || name == "CreatedDate" || name == "CreatedById"
                    ||  name == "LastModifiedById" || name == "LastModifiedDate" || name == "OwnerId"
                    ||  hiddenFields[name]) continue;
                    
                if(type == "reference"){
                    cls = "ReferenceField";
                }else if(type == "string"){
                    cls = "StringField";
                }else if(type == "boolean"){
                    cls = "BooleanField";
                }else if(type == "picklist"){
                    cls = "PicklistField";
                }else if(type == "date"){
                    cls = "DateField";
                }else if(type == "datetime"){
                    cls = "DatetimeField";
                }else{
                    // default to 'string' type
                    cls = "StringField";
                }
                
                ro = this.__readOnly || f.readOnly;
                // Make non-createable/updateable fields readonly
                if(!f.__f.createable || !f.__f.updateable){
                    ro = true;
                }
                // Defect Fix 014330 - If field type is Auto Number then change required attribute to false so that red asterix sign should not come
                ab = !f.required; // Default value base on database required attribute
                // If Field type is Auto number then mark it as not required.
                if(isAutoNumber === true)
                	ab = true;
                
                fieldElem = SVMX.create("com.servicemax.client.installigence.ui.comps." + cls, 
                        {parent : this, fld : f, fieldLabel : f.label, labelAlign : "right", readOnly : ro, allowBlank : ab, meta : this.__meta});
                
                if(priorityFields[name]){
                    priorityUIFields[priorityFields[name]] = fieldElem;
                    continue;
                }
                fieldElems.push(fieldElem);
            }
            this.add(fieldElems);

            //now insert the priority fields
            var ipr, iprlength = this.getPriorityFields().length, nxtFldPos = 1;
            for(ipr = 1; ipr <= iprlength; ipr++){
                if(priorityUIFields[ipr]){
                    this.insert(nxtFldPos - 1 , priorityUIFields[ipr]);
                    nxtFldPos++;
                }
            }
            
            var me = this;
            setTimeout(function(){
                me.fireEvent("all_fields_added", this);
                me.refreshData();
            }, 600);
        },
        
        getFields : function(fields){
            var i = 0, ilength = fields.length;
            var fieldsPriority = {};
            for(i = 0; i < ilength; i++){
                fieldsPriority[fields[i].name] = fields[i].priority;
            }
            return fieldsPriority;
        },
        
        refreshData : function(){
            SVMX.getCurrentApplication().blockUI();
            
            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                    "INSTALLIGENCE.GET_PAGEDATA", this, {request : { 
                        context : this, objectName : this.__objectName, id : this.__node.recordId
                    }});
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
        },
        
        onGetPageDataCompleted : function(data){
            var dr = SVMX.create("com.servicemax.client.installigence.record.DataRecord", {r : data});
            this.__pl.setRecord(dr);
            SVMX.getCurrentApplication().unblockUI();
			
			this.root.tree.updateRecordName(this.__pl.__record.__r.Id, this.__pl.__record.__r.Name);
			this.root.setTitle(this.__pl.__record.__r.Name);
        }
    });
    
    Ext.define("com.servicemax.client.installigence.record.IBRecord", {
        extend: "com.servicemax.client.installigence.record.RecordView",
        alias: 'widget.installigence.ibrecord',
        __root : null, __bInitialized : false, __node : null, __pl : null, __meta : null,
        
        constructor: function(config) { 
            config = Ext.apply({
                objectName : SVMX.getCustomObjectName("Installed_Product")
            }, config || {});
            this.__meta = config.meta;
            this.callParent([config]);
        },
        
        getViewType : function(){
            return "IB";
        },
        
        getPriorityFields: function(){
            return this.__meta.ibPriorityFields || [];
        },
        
        getHiddenFields: function(){
            return this.__meta.ibHiddenFields || [];
        }
    });
    
    Ext.define("com.servicemax.client.installigence.record.LocationRecord", {
        extend: "com.servicemax.client.installigence.record.RecordView",
        alias: 'widget.installigence.locationrecord',
        
        constructor: function(config) { 
            
            config = Ext.apply({
                objectName : SVMX.getCustomObjectName("Site")
            }, config || {});
            
            this.callParent([config]);
        },
        
        getViewType : function(){
            return "LOCATION";
        },
        
        getPriorityFields: function(){
            return this.__meta.locPriorityFields || [];
        },
        
        getHiddenFields: function(){
            return this.__meta.locHiddenFields || [];
        }
    });

    Ext.define("com.servicemax.client.installigence.record.SubLocationRecord", {
        extend: "com.servicemax.client.installigence.record.RecordView",
        alias: 'widget.installigence.locationrecord',
        
        constructor: function(config) { 
            
            config = Ext.apply({
                objectName : SVMX.getCustomObjectName("Sub_Location")
            }, config || {});
            
            this.callParent([config]);
        },
        
        getViewType : function(){
            return "SUBLOCATION";
        },
        
        getPriorityFields: function(){
            return this.__meta.locPriorityFields || [];
        },
        
        getHiddenFields: function(){
            return this.__meta.locHiddenFields || [];
        }
    });
    
    Ext.define("com.servicemax.client.installigence.record.AccountRecord", {
        extend: "com.servicemax.client.installigence.record.RecordView",
        alias: 'widget.installigence.accountrecord',
        __root : null,
        
        constructor: function(config) { 
            config = Ext.apply({
                objectName : "Account",
                readOnly : true
            }, config || {});
            
            this.__root = config.root;
            this.callParent([config]);
        },
        
        getViewType : function(){
            return "ACCOUNT";
        },
        
        getPriorityFields: function(){
            return this.__meta.accPriorityFields || [];
        },
        
        getHiddenFields: function(){
            return this.__meta.accHiddenFields || [];
        }
    });
    
    recordImpl.Class("PageLayout", com.servicemax.client.lib.api.Object, {
        fields : null,
        bindings : null,
        __root : null,
        __objectName : null,
        __record : null,
        objectDescribe : null,
        lookupDef : null, 
        masterDependentArray :  null,
        __dataValidationRules : null,
        me : this,
        
        __constructor : function(config){
            this.__base();
            this.fields = [];
            this.bindings = [];
            this.__root = config.root;
            this.__objectName = config.objectName;
			me = this;
            this.objectDescribe = null;
            this.lookupDef = null;
            this.masterDependentArray = [];
        },
        
        init : function(describeResult, dataValidationRules){
        	this.objectDescribe = describeResult;
        	//Update Dependent picklist information
        	SVMX.create("com.servicemax.client.installigence.utils.dependentPickList", {param : this.objectDescribe});
        	
        	var i , fields = this.objectDescribe.fields, l = fields.length, fld;
            for(i = 0; i < l; i++){
                if(fields[i].type == 'picklist'){
                    fld = SVMX.create("com.servicemax.client.installigence.record.PicklistPageField", {parent : this});
                }else if(fields[i].type == 'boolean'){
                    fld = SVMX.create("com.servicemax.client.installigence.record.BooleanPageField", {parent : this});
                }else{
                    fld = SVMX.create("com.servicemax.client.installigence.record.PageField", {parent : this});
                }
                
                fld.init(fields[i]);
                this.fields.push(fld);
            }
            
            SVMX.sort(this.fields, "label");
			
			this.__dataValidationRules = dataValidationRules;
        },
        
        registerBinding : function(b){
            this.bindings.push(b);
        },
        
        setRecord : function(r){
            var i, l = this.bindings.length;
            for(i = 0; i < l; i++){
                this.bindings[i].setRecord(r);
                this.bindings[i].push();
            }
            this.__recordName = r.__r.Name;
            this.__record = r; 
            this.__updateDependetPickList();
        },
        
        saveConfirm : function(){
            var d = this.okcallback.handler.call(this.okcallback.context, this.__objectName, this.fields, this.__record, this.__dataValidationRules);
            
            d.done(this.onSaveComplete);
        },
        
        __getDependencyChainOfFields : function(){
        	var i, masterPickListVsDependentPickList = this.objectDescribe.masterPickListVsDependentPickList, l = masterPickListVsDependentPickList.length;
        	for(i = 0; i < l; i++){
        		this.__resolveDependencyChain(masterPickListVsDependentPickList[i].dependentField,masterPickListVsDependentPickList[i].masterField);
        	}
        },
       
        __resolveDependencyChain : function(dependentField, masterField){
        	var i, masterPickListVsDependentPickList = this.objectDescribe.masterPickListVsDependentPickList, l = masterPickListVsDependentPickList.length;
        	for(i = 0; i < l; i++){
        		if(dependentField === masterPickListVsDependentPickList[i].masterField){
        			this.__resolveDependencyChain(masterPickListVsDependentPickList[i].dependentField,masterPickListVsDependentPickList[i].masterField);
        		}
        		else{
        			var j, m = this.masterDependentArray.length, isInArray = false;
        			for(j = 0; j < m; j++){
        				if(this.masterDependentArray[j].master === masterField && this.masterDependentArray[j].dependent === dependentField)
        					isInArray = true;
        			}
        			if(!isInArray)
        				this.masterDependentArray.push({"master" : masterField, "dependent" : dependentField});
        		}
        	}
        },
        
        // Update dependent picklist values. 
        __updateDependetPickList : function(){
        	this.__getDependencyChainOfFields();
        	var i, j, fields = this.fields, m = fields.length, masterDependentArray = this.masterDependentArray, l = masterDependentArray.length;
        	for(i = 0; i < l; i++){
        		for(j = 0; j < m; j++){
        			if(masterDependentArray[i].master === fields[j].name){
        				var currentValue = this.__record.__r[fields[j].name];
    					fields[j].updateDependentPickList(currentValue,false); // Do not clean set value 
    					break;
        			}
        		}
        	}
        },
        
       
        
        save : function(){
            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                    "INSTALLIGENCE.SAVE_RECORD", this, {
                        request : { context : this, objectName: this.__objectName, meta : this.fields, record : this.__record, recordName : this.__recordName, root : this.__root, handler : this.onSaveComplete, dataValidationRules : this.__dataValidationRules}
                });
                com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
        },
        
        onSaveComplete: function(resp){
            if(resp){
                var data = resp.data;
                if(data && (data.errors.length > 0 || data.warnings.length > 0)){
                    // Mark the record in the Tree
                    this.root.tree.updateRecordWithErrorStar(this.record.__r.Id, this.record.__r.Name);
                    
                    //Show Data Validation Error/Confirmation.
                    for (var i = this.root.__views.length - 1; i >= 0; i--) {
                        if(this.root.__views[i].__objectName === this.objectName){
                            this.root.__views[i].showErrorConfirmation(resp);
                            break;
                        }
                    }
                }    
            }
            else{
                //Hide Data Validation Error/Confirmation.
                
                for (var i = this.root.__views.length - 1; i >= 0; i--) {
                    if(this.root.__views[i].__objectName === this.objectName){
                        this.root.__views[i].hideErrorConfirmation();
                        break;
                    }
                }

                if(this.recordName && this.recordName !== this.record.__r.Name){
                // Update IB tree record name
                    this.root.tree.updateRecordName(this.record.__r.Id, this.record.__r.Name);
                }
            }

            me.__updateDependentRecords(this.objectName, this.record.__r, this.meta);
        },

        __updateDependentRecords: function(objectName, record, fields){
            for(var i=0; i< fields.length; i++){
                if(fields[i].type === 'reference' && record[fields[i].name] && record[fields[i].name].indexOf('_local_') != -1){
                    me.__createDependentEntry(record[fields[i].name], objectName, record['Id'], fields[i].name);
                }
            }
        },

        __createDependentEntry: function(fieldValue, objectName, recId, fieldName){
            var d = SVMX.Deferred();
            var cols = [{name: "parent_object_name"}, {name: "local_id"}, {name: "parent_record_id"}, {name: "parent_field_name"}];

            var colValue = {parent_object_name: objectName, local_id: fieldValue, parent_record_id: recId, parent_field_name: fieldName};
            var colValues = [colValue];
            var whereCondition = "parent_record_id = '" + recId + "' AND parent_field_name = '" + fieldName + "'";
            var updateSet = "parent_object_name = '" + objectName + "', local_id = '" + fieldValue + "', parent_record_id = '" + recId + "', parent_field_name = '" + fieldName + "'";
            var queryObj = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
            queryObj.select("parent_object_name, local_id, parent_record_id, parent_field_name").from("SyncDependentLog")
            .where(whereCondition).execute()
            .done(function(resp){
                if(resp && resp.length > 0){
                    var qoUpdate = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                    qoUpdate.update("SyncDependentLog")
                    .setValue(updateSet)
                    .where(whereCondition).execute()
                    .done(function(resp){
                        d.resolve();
                    });
                }else{
                    var qoInsert = SVMX.create("com.servicemax.client.installigence.offline.model.utils.Query", {});
                    qoInsert.insertInto("SyncDependentLog")
                    .columns(cols)
                    .values(colValues)
                    .execute()
                    .done(function(resp){
                        d.resolve();
                    });
                }
            });
        }
    }, {});
    
    recordImpl.Class("PageField", com.servicemax.client.lib.api.Object, {
        _parent : null, label : null, type : null, name : null, __f : null,
        _binding : null, required : false, readOnly : false, autoNumber : false, dependetFields : [], masterPickListFieldDependentPickListField : [], 
        __constructor : function(config){
            this.__base();
            this._parent = config.parent;
            this.dependetFields = [];
            this.masterPickListFieldDependentPickListField = [];
        },
        
        init : function(fldInfo){
            this.label = fldInfo.label;
            this.name = fldInfo.name;
            this.type = fldInfo.type;
            this.readOnly = !fldInfo.updateable;
            this.required = !fldInfo.nillable;
            this.referenceTo = fldInfo.referenceTo;
            this.autoNumber = fldInfo.autoNumber;
            this.__f = fldInfo;
            
            if(this._parent.objectDescribe.hasOwnProperty("masterPickListVsDependentPickList") && this._parent.objectDescribe.masterPickListVsDependentPickList != null){
            	masterPickListFieldDependentPickListField = this._parent.objectDescribe.masterPickListVsDependentPickList;
            	var i, l = masterPickListFieldDependentPickListField.length;
            	for(i = 0; i < l; i++){
            		if(this.name === masterPickListFieldDependentPickListField[i].masterField){
            			this.dependetFields.push(masterPickListFieldDependentPickListField[i].dependentField);
            		}
            	}
            	
            }
        },
        
        getBinding : function(){
            if(this._binding == null){
                this._binding = SVMX.create("com.servicemax.client.installigence.record.PageFieldBinding", 
                        {name : this.name});
                this._parent.registerBinding(this._binding);
            }
            
            return this._binding;
        },
        
        register : function(field){
            var me = this;
            switch(field.getXType()) {
                case "inst.stringfield" :
                case "inst.referencefield" :
                case "inst.datefield" :
                case "svmx.datefield" :
                    field.on('blur', function(context, event, eOpts){
                        var value = field.value || "";
                        if(me._parent.__record && me._parent.__record.__r[me.name] != value){
                            me.getBinding().pull();
                            me._parent.save();
                        }
                    });
                    break;
                case "inst.picklistfield" :
                    field.on('select', function(combo, records, eOpts) {
                        var value = field.value || "";
                        if(me._parent.__record && me._parent.__record.__r[me.name] != value){
                           // Update All Dependent picklist field of this value. Also clean set value as per the salesforce functionality.
                        	me.updateDependentPickList(value, true);
                        	me.getBinding().pull();
                            me._parent.save();
                        }
                    });
                    break;
                case "inst.booleanfield" :
                    field.on('blur', function(field, newValue, oldValue, eOpts) {
                        var value = field? field.value: "";
                        if(me._parent.__record && me._parent.__record.__r[me.name] != value){
                        	// Update All Dependent picklist field of this value. Also clean set value as per the salesforce functionality.
                        	me.updateDependentPickList(value.toString(), true);
                        	me.getBinding().pull();
                            me._parent.save();
                        }
                    });
                    break;
                case "svmx.timefield" :
                    field.on('select', function(combo, records, eOpts) {
                        var value = field.value || "";
                        if(me._parent.__record && me._parent.__record.__r[me.name] != value){
                            me.getBinding().pull();
                            me._parent.save();
                        }
                    });
                    break;
            }
            
        },
        
        updateDependentPickList : function(currentValue,cleanSetValue){
        	var i, values = this.getListOfValues(), l = values.length, dependentFieldArray = [];
        	for(i = 0; i < l; i++){
        		if(currentValue == values[i].value && values[i].hasOwnProperty("dependendPicklist")){
        			var dependentArray = values[i].dependendPicklist, j, m = dependentArray.length;
        			if(dependentArray.length > 0){
	        			for(j = 0; j < m; j++){
	        				var dpFieldAPIName = dependentArray[j].fieldAPIName, dpValueIndices = dependentArray[j].value, allPickListValues = null;
	        				dependentFieldArray.push(dpFieldAPIName);
	        				dpValueIndices = dpValueIndices.split(';');
	        				allPickListValues = this.getPickListValueForFieldName(dpFieldAPIName);
	        				var result = [], k, x, allPVLength = allPickListValues.length;
	        				for(k = 0, x = 0; k < allPVLength; k++){
								if(dpValueIndices[x] == k){
									var data = {};
									data.display = allPickListValues[k].label; 
									data.value 	= allPickListValues[k].value;
									result.push(data);
									x++;
								}
							}
	        				this.__updateStoresForDependent(dpFieldAPIName,result,cleanSetValue);
	        	       	}
	        		}
        			else{
        				// If for the master picklist value, no dependent indices found then empty the sotre and store set value.
        				var j, depndentFields = this.dependetFields, m = depndentFields.length;
        				for(j = 0; j < m; j++){
        					this.__updateStoresForDependent(depndentFields[j],[],true);
        					this.__updateDependencyChain(depndentFields[j],true);
        				}
        			}
        		}	
        	}
        	if(dependentFieldArray.length > 0){
        		l = dependentFieldArray.length;
        		for(i = 0; i < l; i++){
        			this.__updateDependencyChain(dependentFieldArray[i],cleanSetValue);
        		}
        	}
        }, 
        
        __updateDependencyChain : function(dependentField,cleanSetValue){
        	var i, l = masterPickListFieldDependentPickListField.length;
        	for(i = 0; i < l; i++){
        		if(dependentField === masterPickListFieldDependentPickListField[i].masterField){
        			this.__updateStoresForDependent(masterPickListFieldDependentPickListField[i].dependentField,[],cleanSetValue);
        			this.__updateDependencyChain(masterPickListFieldDependentPickListField[i].dependentField,cleanSetValue);
        		}
        	}
        }, 
        
        __updateStoresForDependent : function(dpFieldAPIName, data, cleanSetValue){
        	var i, bindings  = this._parent.bindings, l =  bindings.length;
        	for(i = 0; i < l; i++){
        		if(bindings[i].__name === dpFieldAPIName){
        			bindings[i].updateStore(data);
        			if(cleanSetValue){
            			bindings[i].setter("");
            		}
        			bindings[i].pull();
        		}
        	}
        }, 
        
        getPickListValueForFieldName : function(fieldName){
        	var fields = this._parent.fields, i, l = fields.length, ret = [];
        	for(i = 0; i < l; i++){
        		if(fields[i].name === fieldName){
        			ret = fields[i].__f.picklistValues;
        			break;
        		}
        	}
        	return ret;
        },
		
		getListOfValues : function(){
        	return this.__f.picklistValues;
        }
        
    }, {});
    
    recordImpl.Class("PicklistPageField", recordImpl.PageField, {
    	 isDependentPickList : false, controllerName : null, 
    	__constructor : function(config){
            this.__base(config);
            this.isDependentPickList = false;
            this.controllerName = null;
        },
        
        init : function(fldInfo){
            this.__base(fldInfo);
           if(fldInfo.dependentPicklist){
            	this.isDependentPickList = true;
            	this.controllerName = fldInfo.controllerName;
            }
        }
    
    }, {});
    
    recordImpl.Class("BooleanPageField", recordImpl.PageField, {
        
        __constructor : function(config){
            this.__base(config);
        },
        
        init : function(fldInfo){
            this.__base(fldInfo);
            this.required = false;
        }
    
    }, {});
    
    recordImpl.Class("PageFieldBinding", com.servicemax.client.lib.api.Object, {
        __name : null, __record : null, setter : null, 
        
        __constructor : function(config){
            this.__base();
            this.__name = config.name;
        },
        
        setRecord : function(r){
            this.__record = r;
        },
        
        getRecord : function(){
            return this.__record;
        },
        
        push : function(){
            this.setter(this.__record.pull(this.__name));
        },
        
        pull : function(){
            this.__record.push(this.__name, this.getter());
        }
        
    }, {});
    
    recordImpl.Class("DataRecord", com.servicemax.client.lib.api.Object, {
        __r : null,
        __constructor : function(config){
            this.__base();
            this.__r = config.r || {};
        },
        
        pull : function(name){
            return this.__r[name];
        },
        
        push : function(name, value){
            this.__r[name] = value;
        }
    }, {});
};

})();

// end of file