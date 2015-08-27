/**
 * 
 */

(function(){
    
    var actionsImpl = SVMX.Package("com.servicemax.client.installigence.actions");

actionsImpl.init = function(){
    
    Ext.define("com.servicemax.client.installigence.actions.Actions", {
        extend: "com.servicemax.client.installigence.ui.components.SVMXPanel",
        alias: 'widget.installigence.actions',
        __optionsPanel : null, __allActions : null, __allActionProviders : null,
        __showingDisabledActions : true, __contentarea : null,
        __nodesSelected : null, __meta : null,
        
        constructor: function(config) { 
            var me = this;
            this.__allActions = [];
            this.__allActionProviders = [];
            this.__showingDisabledActions = true;
            this.__meta = config.meta;
            config = Ext.apply({
                title: $TR.ACTIONS,
                ui: 'svmx-white-panel',
                cls: 'filter-region',
                layout : {type : "vbox"},
                defaults : {padding : '0 0 0 5'},
                titleAlign: 'center'
                /*,tools : [
                     { type : "svmx-option-icon", callback : function() { me.toggleOptions(); }},
                     { type : "right", callback : function() { me.collapse(); }}
                ]*/
            }, config || {});
            
            config.contentarea.on("node_selected", function(nodes){
                // actions should work with more that one node.
                // for now, we will mimic it
                if(!(nodes instanceof Array)) nodes = [nodes];
                
                this.handleNodeSelect(nodes);
            }, this);
            
            this.__contentarea = config.contentarea;
            this.callParent([config]);
            this.setup();
        },
        
        handleNodeSelect : function(nodes){
            this.__nodesSelected = nodes;

            var i, actions = this.__allActions, l = actions.length, ac, ap;
            for(i = 0; i < l; i++){
                ac = actions[i]; ap = ac.provider;
                ap.setContext(nodes);
                if(ap.isValid()){
                    ac.setDisabled(false);
                    ac.setVisible(true);
                }else{
                    ac.setDisabled(true);
                    if(!this.__showingDisabledActions){
                        ac.setVisible(false);
                    }
                }
            }
        },

        getNodesSelected : function(){
            return this.__nodesSelected;
        },
        
        setup : function() {
            this.__setupDefaults();
            this.meta.bind("MODEL.UPDATE", function(evt){
                this.refresh();
            }, this);
        },

        __setupDefaults : function(){
            var me = this;
            
            this.addActionProvider({className : "com.servicemax.client.installigence.actions.AddNew"});
            this.addActionProvider({className : "com.servicemax.client.installigence.actions.CloneInstalledProduct"});
            this.addActionProvider({className : "com.servicemax.client.installigence.actions.AddNewLocation"});
            //this.addActionProvider({className : "com.servicemax.client.installigence.actions.AddNewSubLocation"});
            //this.addActionProvider({className : "com.servicemax.client.installigence.actions.AddNewFromTemplate"});
            this.addActionProvider({className : "com.servicemax.client.installigence.actions.DeleteNew"});
            
            // options panel
            var cb = SVMX.create("com.servicemax.client.installigence.ui.components.Checkbox",
                    { boxLabel : $TR.SHOW_DISABLED_ACTIONS, checked : true, margin: '0 0 0 5',
                      handler : function(that, val){
                          if(val){
                              me.showDisabledActions();
                          }else{
                              me.hideDisabledActions();
                          }
                      }
                    });
            this.__optionsPanel = SVMX.create("com.servicemax.client.installigence.ui.components.SVMXPanel", {
                layout : {type : "vbox"}, items : [cb], width : "100%", cls: 'svmx-options-panel', margin: '3 3 0 3', header : false, collapsed : true
            });
            this.add(this.__optionsPanel);
            
            // default actions
            var i,l = this.__allActionProviders.length, b, ap;
            for(i = 0; i < l; i++){
                ap = SVMX.create(this.__allActionProviders[i].className, {});
                b = SVMX.create("com.servicemax.client.installigence.ui.components.SVMXButton",{ 
                    width: '100%', ui: 'svmx-plain-btn-small', cls: 'border-botton', 
                    text: ap.getName(), provider : ap, disabled : true, handler : function(){
                        this.provider.act(this, me);
                    }
                });
                this.add(b);
                this.__allActions.push(b);
            }
            
            // add separator
            var separator = SVMX.create("com.servicemax.client.installigence.ui.components.Label", {
                html : "<div></div>", width: '100%', padding : 0, height : 25, style : {"background-color" : "#D0CDCD"}
            });
            this.add(separator);
        },

        refresh : function(){
            var me = this;

            this.removeCustomActions();

            if(!this.meta.actions || !this.meta.actions.length){
                return;
            }
            var m = this.meta.actions, l = m.length, i, b, ap;
            for(i = 0; i < l; i++){
                if(m[i].isHidden){
                    if(m[i].isHidden === true)
                        continue;
                }
                m[i].mapping = this.__getMappingByName(m[i].action);
                ap = SVMX.create("com.servicemax.client.installigence.actions.CustomActionProvider", m[i]);
                b = SVMX.create("com.servicemax.client.installigence.ui.components.SVMXButton",{ 
                    width: '100%', ui: 'svmx-plain-btn-small', cls: 'border-botton', 
                    text: ap.getName(), provider : ap, disabled : true, handler : function(){
                        this.provider.act(this, me);
                    }
                });
                b.__custom = true;
                this.add(b);
                this.__allActions.push(b);
            }
        },

        removeCustomActions : function(){
            var i = this.__allActions.length;
            while(i > 0){
                i--;
                if(this.__allActions[i].__custom){
                    var b = this.__allActions.splice(i, 1)[0];
                    this.remove(b);
                }
            }
        },

        __getMappingByName : function(mapName){
            if(!this.meta.mappings) return null;
            var i, l = this.meta.mappings.length;
            for(i = 0; i < l; i++){
                if(this.meta.mappings[i].name === mapName){
                    return this.meta.mappings[i];
                }
            }
        },
        
        showDisabledActions : function(){
            var i, l = this.__allActions.length;
            for(i = 0; i < l; i++){
                this.__allActions[i].setVisible(true);
            }
            this.__showingDisabledActions = true;
        },
        
        hideDisabledActions : function(){
            var i, l = this.__allActions.length;
            for(i = 0; i < l; i++){
                if(this.__allActions[i].isDisabled()) this.__allActions[i].setVisible(false);
            }
            this.__showingDisabledActions = false;
        },
        
        toggleOptions : function(){
            this.__optionsPanel.toggleCollapse();
            this.doLayout();
        },
        
        addActionProvider : function(info){
            this.__allActionProviders.push(info);
        },
        
        getContentArea : function(){
            return this.__contentarea;
        }
    });
    
    actionsImpl.Class("ActionProvider", com.servicemax.client.lib.api.Object, {
        _meta : null, _context : null,
        __constructor : function(meta){ 
            this.__base(); 
            this._meta = meta;
        },
        getName: function(){
            return this._meta.name;
        },
        
        setContext : function(context){
            this._context = context;
        },
        
        isValid : function(){
            throw new Error("Please override this method <ActionProvider.isValid()>");
        },
        
        act : function(source, parent){
            throw new Error("Please override this method <ActionProvider.act()>");
        },

        _getTargetRecordIds : function(parent){
            var targetIds = [];
            var nodes = parent.getNodesSelected();
            var i, l = nodes.length;
            for(i = 0; i < l; i++){
                targetIds.push(nodes[i].id);
            }
            return targetIds;
        }
    }, {});
    
    actionsImpl.Class("AddNew", actionsImpl.ActionProvider, {
        __constructor : function(){ 
            this.__base({name : $TR.ADD_NEW_INSTALLED_PRODUCT}); 
        },
        
        isValid : function(){
            if(this._context.length == 1 && (this._context[0].nodeType == "IB" || this._context[0].nodeType == "LOCATION" || this._context[0].nodeType == "SUBLOCATION")){ 
                return true;
            }else{ 
                return false;
            }
        },

        /*act : function(source, parent){
            var parentNode = this._context[0];
            var addType = "IB";
            parent.getContentArea().addToTree({}, parentNode, addType);
        }*/
        
        act : function(source, parent){
            var parentNode = this._context[0];
            var displayFields = parent.__meta.productDisplayFields || [];
            var searchFields = parent.__meta.productSearchFields || [];
            var productSearch = SVMX.create("com.servicemax.client.installigence.objectsearch.ObjectSearch", {
                objectName : "Product2",
           	    columns : displayFields.length ? displayFields : [{name: 'Name'}],
           	    searchColumns : searchFields.length ? searchFields : [{name: 'Name'}],
                multiSelect : true,
                sourceComponent : source,
                mvcEvent : "FIND_PRODUCTS",
                createHandler : function(){
                    var records = [{Name: "New Installed Product"}];
                    parent.getContentArea().addToTree(records, parentNode, "IB");
                }
            });
            var me = this;
            productSearch.find().done(function(results){
                parent.getContentArea().addToTree(results, me._context[0], "IB");
            });
        }
    }, {});
    
    actionsImpl.Class("AddNewLocation", actionsImpl.ActionProvider, {
        __constructor : function(){ 
            this.__base({name : $TR.ADD_NEW_LOCATION}); 
        },
        
        isValid : function(){
            if(this._context.length == 1 && (this._context[0].nodeType == "ACCOUNT" || this._context[0].nodeType == "LOCATION")){ 
                return true;
            }else{ 
                return false;
            }
        },
        
        act : function(source, parent){
            var parentNode = this._context[0];
            var addType = "LOCATION";
            parent.getContentArea().addToTree({}, parentNode, addType);
        }
    }, {});

    actionsImpl.Class("AddNewSubLocation", actionsImpl.ActionProvider, {
        __constructor : function(){ 
            this.__base({name : $TR.ADD_NEW_SUB_LOCATION}); 
        },
        
        isValid : function(){
            if(this._context.length == 1 && (this._context[0].nodeType == "LOCATION" || this._context[0].nodeType == "SUBLOCATION")){ 
                return true;
            }else{ 
                return false;
            }
        },
        
        act : function(source, parent){
            var parentNode = this._context[0];
            var addType = "SUBLOCATION";
            parent.getContentArea().addToTree({}, parentNode, addType);
        }
    }, {});
    
    actionsImpl.Class("AddNewFromTemplate", actionsImpl.ActionProvider, {
        __constructor : function(){ 
            this.__base({name : "Add New From Template"}); 
        },
        
        isValid : function(){
            if(this._context.length == 1 && (this._context[0].nodeType == "IB" || this._context[0].nodeType == "LOCATION" || this._context[0].nodeType == "SUBLOCATION")){ 
                return true;
            }else{ 
                return false;
            }
        },
        
        act : function(source, parent){
            parent.getContentArea().addToTree({}, this._context[0], "LOCATION");
        }
    }, {});

    actionsImpl.Class("DeleteNew", actionsImpl.ActionProvider, {
        __constructor : function(){ 
            this.__base({name : "Delete"}); 
        },
        
        isValid : function(){
            var node = this._context.length === 1 && this._context[0];
            if(node){
                if(!this.__areAllNodesTransient(node)){
                    return false;
                }
                var nodeType = node.nodeType;
                if(nodeType == "IB" || nodeType == "LOCATION" || nodeType == "SUBLOCATION"){ 
                    return true;
                }
            }
            return false;
        },
        
        act : function(source, parent){
            var targetNode = this._context[0];
            SVMX.getCurrentApplication().showQuickMessage("confirm", $TR.DELETE_CONFIRM_MESSAGE, function(resp){
                if(resp === "yes"){
                    parent.getContentArea().deleteFromTree(targetNode);
                }
            });
        },

        __areAllNodesTransient : function(node){
            if(node.recordId.indexOf('transient') !== 0){
                return false;
            }else{
                return checkChildren(node.children);
            }
            function checkChildren(children){
                if(!children){
                    return true;
                }
                var areTransient = true;
                for(var i = 0; i < children.length; i++){
                    var childId = children[i].recordId;
                    if(childId && childId.indexOf('transient') !== 0){
                        areTransient = false;
                    }
                    areTransient = areTransient && checkChildren(children[i].children);
                }
                return areTransient;
            }
        }
    }, {});

    actionsImpl.Class("CloneInstalledProduct", actionsImpl.ActionProvider, {
        __constructor : function(){ 
            this.__base({name : "Clone Installed Product"}); 
        },
        
        isValid : function(){
            if(this._context.length == 1 && this._context[0].nodeType == "IB"){ 
                return true;
            }else{ 
                return false;
            }
        },
        
        act : function(source, parent){
            var me = this;
            window.action_cascade = false;
            SVMX.getCurrentApplication().showQuickMessage("confirm", 'Are you sure?<br/><br/><label><input type="checkbox" onclick="window.action_cascade=this.checked" /> Clone all child records</label>', function(resp){
                if(resp === "yes"){
                    me.__cascade = window.action_cascade;
                    me.__doCloneRecord(source, parent);
                }
            });
        },

        __doCloneRecord : function(source, parent){
            SVMX.getCurrentApplication().blockUI();
            this.__parent = parent;
            var targetId = this._getTargetRecordIds(parent)[0];
            var targetObject = SVMX.getCustomObjectName("Installed_Product");
            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                "INSTALLIGENCE.CLONE_RECORD", this, {
                    request : {
                        context : this,
                        targetId : targetId,
                        objectName : targetObject,
                        cascade : this.__cascade
                    }
            });
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
        },

        onCloneComplete : function(record){
            SVMX.getCurrentApplication().unblockUI();
            this.__parent.getContentArea().addClonedToTree(record, this._context[0], "IB", this.__cascade);
        }

    }, {});
    
    actionsImpl.Class("CustomActionProvider", actionsImpl.ActionProvider, {
        __parent : null,

        __constructor : function(meta){
            this.__base(meta);
        },

        act : function(source, parent){
            var me = this;
            window.action_cascade = false;
            SVMX.getCurrentApplication().showQuickMessage("confirm", 'Are you sure?<br/><br/><label><input type="checkbox" onclick="window.action_cascade=this.checked" /> Apply to child nodes</label>', function(resp){
                if(resp === "yes"){
                    me.__cascade = window.action_cascade;
                    me.__doCustomAction(source, parent);
                }
            });
        },

        __doCustomAction : function(source, parent){
            this.__parent = parent;
            var targetIds = this._getTargetRecordIds(parent);
            switch(this._meta.actionType){
                // TODO: remove "Field Map"
                case "Field Map":
                case "fieldupdate":
                    var mapName = this._meta.action;
                    this.__applyFieldUpdate(targetIds, mapName);
                    break;
            }
        },

        __applyFieldUpdate : function(targetIds, mapName){
            SVMX.getCurrentApplication().blockUI();
            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                "INSTALLIGENCE.APPLY_FIELD_UPDATE", this, {
                    request : {
                        context : this,
                        targetIds : targetIds,
                        mapName : mapName,
                        cascade : this.__cascade
                    }
            });
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
        },

        onApplyFieldUpdateComplete : function(success){
            SVMX.getCurrentApplication().unblockUI();
            if(success){
                this.__parent.getContentArea().refreshRecord();
                //SVMX.getCurrentApplication()
                //    .showQuickMessage('success', $TR.FIELD_UPDATE_APPLIED_MESSAGE);
            }
        },

        isValid : function(){
            var targetObjectName = null;
            if(this._context[0].nodeType === "LOCATION"){
                targetObjectName = SVMX.getCustomObjectName("Site");
            }else if(this._context[0].nodeType === "SUBLOCATION"){
                targetObjectName = SVMX.getCustomObjectName("Sub_Location");
            }else if(this._context[0].nodeType === "ACCOUNT"){
                targetObjectName = "Account";
            }else if(this._context[0].nodeType === "IB"){
                targetObjectName = SVMX.getCustomObjectName("Installed_Product");
            }
            if(this._meta.mapping.targetObjectName === targetObjectName){
                return true;
            }else{
                return false;
            }
        }

    }, {});
};

})();

// end of file