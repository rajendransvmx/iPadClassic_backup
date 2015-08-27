/**
 * 
 */

(function(){
    
    var ibtreeImpl = SVMX.Package("com.servicemax.client.installigence.ibtree");

ibtreeImpl.init = function(){
    
    /**
     * EVENTS:
     * 01. node_selected
     * 02. records_selected
     * 03. node_loaded
     */
    Ext.define("com.servicemax.client.installigence.ibtree.IBTree", {
        extend: "com.servicemax.client.installigence.ui.components.SVMXPanel",
        alias: 'widget.installigence.ibtree',
        __meta : null,
        __tree : null,
        __treeData : null,
        __treeDataById : null,
        __expandedById : null,
        __searchText : null,
        __optionsPanel : null,
        __filterExpressions : null,
        __transientFilters : null,
        __allNodeFilters : null,
        __appliedNodeFilters : null,
        __productIconIndex : null,
        __transientRecordIndex : null,
        __locationsVisible : true,
        __swappedVisible : true,
        __selectedNodeId : null,
        
        resizable : true,
        
        constructor: function(config) { 
            var me = this;
            this.__registerExternalRequest();
            var store = Ext.create('Ext.data.TreeStore', {
                
            });

            // meta model
            this.__meta = config.meta;
            this.__meta.bind("MODEL.UPDATE", function(evt){
                this.__refreshFilterOptions();
            }, this);

            // options panel
            /*var cbLocations = SVMX.create("com.servicemax.client.installigence.ui.components.Checkbox",{ 
                boxLabel : $TR.SHOW_LOCATIONS,
                checked : this.__locationsVisible,
                margin: '0 0 0 5',
                handler : function(){
                    me.__locationsVisible = this.value;
                    if(this.value){
                        me.showNodes('loc');
                    }else{
                        me.hideNodes('loc');
                    }
                }
            });
            var cbSwappedProducts = SVMX.create("com.servicemax.client.installigence.ui.components.Checkbox",{ 
                boxLabel : $TR.SHOW_SWAPPED_PRODUCTS,
                checked : this.__swappedVisible,
                margin: '0 0 0 5',
                handler : function(){
                    me.__swappedVisible = this.value;
                    if(this.value){
                        me.showNodes('swap');
                    }else{
                        me.hideNodes('swap');
                    }
                }
            });*/

            var filterOptions = this.__getFilterOptions();
            var optionPanelItems = filterOptions;/*.concat([
                cbLocations,
                cbSwappedProducts
            ]);*/
            this.__optionsPanel = SVMX.create("com.servicemax.client.installigence.ui.components.SVMXPanel", {
                layout : {type : "vbox"}, cls: 'svmx-options-panel',
                items : optionPanelItems,
                header : false, collapsed : true, width : "100%", margin: '2 3 0 3'
            });
            
            // tree
            this.__expandedById = {};
            this.__tree = SVMX.create("com.servicemax.client.installigence.ui.components.Tree", {
                cls: 'grid-panel-borderless svmx-tree-panel', margin: '5 0 0 0', width: '100%', 
                store: store, rootVisible: false, flex : 1,
                viewConfig: {
                    plugins: {
                        ptype : 'treeviewdragdrop',
                        enableDrag : true,
                        enableDrop : true,
                        appendOnly : true
                    },
                    listeners : {
                        nodedragover : function(targetNode, position, dragData, e, eOpts){
                            return me.__canDropOn(dragData, targetNode);
                        },
                        beforedrop : function(node, data, overModel, dropPosition, dropHandlers, eOpts){
                            return me.__handleDropOn(data, overModel, dropHandlers);
                        },
                        drop : function(){
                            
                        }
                    }
                },
                
                listeners : {
                    select : function(that, record, index, eOpts){
                        if(me.__selectedNodeId !== record.data.id){
                            me.__selectedNodeId = record.data.id;
                            me.fireEvent("node_selected", me.__treeDataById[record.data.id]);
                        }
                    },
                    checkchange : function(node, checked, eOpts){
                        // one more records may have been selected via checkbox. fire a different event
                        me.__fireRecordsSelected();
                    },
                    afteritemexpand : function(node, index, item, eOpts) {
                        var treeNode = me.__treeDataById[node.id];
                        if(treeNode){
                            treeNode.expanded = true;
                            // Ensure parents are expanded internally (even if filtered)
                            var parent = me.__treeDataById[treeNode.parentId];
                            while(parent){
                                parent.expanded = true;
                                var parent = me.__treeDataById[parent.parentId];
                            }
                            me.__expandedById[node.id] = true;
                        }
                        if(node.data.nodeType == "IB"){
                            setTimeout(function(){
                                me.__showMore({node : node});
                            },1);
                        }
                    },
                    afteritemcollapse : function(node, index, item, eOpts) {
                        var treeNode = me.__treeDataById[node.id];
                        if(treeNode){
                            treeNode.expanded = false;
                            me.__expandedById[node.id] = false;
                        }
                    }
                }
            });
            
            // search
            this.__searchText = SVMX.create("com.servicemax.client.installigence.ui.components.SVMXTextField", {
                cls: 'toolbar-search-textfield', width: '90%', emptyText : $TR.SEARCH, enableKeyEvents : true,
                listeners : {
                    keyup : function(that, e, opts) {
                        me.__tree.search(that.getValue());
                    }
                }
            });

            this.__transientFilters = [];

            this.__setupNodeFilters();

            this.__bindSyncEvents();
            
            config = Ext.apply({
                layout : {type : "vbox"},
                dockedItems : [
                    {dock: 'top', xtype: 'toolbar', cls: 'grid-panel-borderless svmx-ibtree-toolbar', style:'background-color: #fff', margin: '0',
                    items:[ this.__searchText,
                            { xtype: 'button', iconCls: 'filter-icon', handler : function(){
                                me.toggleOptions();
                            }}
                    ]}
                ],
                items:[this.__optionsPanel, this.__tree]
            }, config || {});
            this.callParent([config]);
        },

        __bindSyncEvents : function(){
            var syncService = SVMX.getClient().getServiceRegistry()
                .getService("com.servicemax.client.installigence.sync").getInstance();

            syncService.bind("SYNC.STATUS", function(evt){
                var type = evt.data.type;
                if(type === "complete"){
                    var syncType = evt.data.syncType;
                    if(syncType === "incremental" || syncType === "purge"){
                        this.refreshContent();
                    }
                }else if(type === "recordstatus"){
                    var recordId = evt.data.recordId;
                    var isTransient = !evt.data.valid;
                    this.setTreeNodeTransient(recordId, isTransient);
                    // Maintain the transient record index
                    var index = this.__transientRecordIndex.indexOf(recordId);
                    if(isTransient){
                        if(index === -1){
                            this.__transientRecordIndex.push(recordId);
                        }
                    }else{
                        if(index !== -1){
                            this.__transientRecordIndex.splice(index, 1);
                        }
                    }
                }
            }, this);
        },
        
        __registerExternalRequest : function(){
            
            SVMX.getClient().bind("EXTERNAL_MESSAGE", function(evt){
                var data = SVMX.toObject(evt.data);
                this.__handleExternalMessage(data);
            }, this);           
        },
        
        __handleExternalMessage : function(data){
            if(data.object === SVMX.getCustomObjectName("Service_Order")){
                this.__selectFromExternal = true;
                SVMX.getCurrentApplication().getAppFocus();
                this.__createTransientFilter(data);
            }else if(data.object === SVMX.getCustomObjectName("Installed_Product")){
                this.__selectFromExternal = true;
                SVMX.getCurrentApplication().getAppFocus();
                this.__uncheckFilters();
                this.__selectTreeNodes(data);
            }else if(data.object === SVMX.getCustomObjectName("Site")){
                this.__selectFromExternal = true;
                SVMX.getCurrentApplication().getAppFocus();
                this.__uncheckFilters();
            	this.__showLocationNode(data);
            } else {
                // Unrelated to IB tree
            }
        },

        __createTransientFilter : function(data){
            var me = this;
            var transFilter = SVMX.create("com.servicemax.client.installigence.ibtree.TransientFilter", {parent : this, data : data});
            var exists = false;
            for(var i = 0; i < this.__transientFilters.length; i++){
                if(this.__transientFilters[i].getAlias() === transFilter.getAlias()){
                    // Already exists, let it reinitialize
                    exists = true;
                    transFilter = this.__transientFilters[i];
                    transFilter.setChecked();
                    break;
                }
            }
            // Expand all the nodes
            this.__selectTreeNodes(data, function(){
                if(!exists){
                    me.__transientFilters.push(transFilter);
                    transFilter.initialize(false);
                }else{
                    transFilter.setup();
                }
            });
        },

        __uncheckFilters : function(){
            var optionItems = this.getOptionsPanel().items.items;
            for(var i = 0; i < optionItems.length; i++){
                var checkbox = optionItems[i];
                checkbox.setValue(false);
            }
        },

        getTransientFilters : function(){
            return this.__transientFilters;
        },

        selectTreeNode : function(recordId, callback){
            this.__selectTreeNodes({recordIds : [recordId]}, callback);
        },
        
        __selectTreeNodes : function(data, callback){
            data = SVMX.toObject(data);
            this.__showSelectedIBRecord(data, callback);
        },
        
        __showLocationNode : function(data){
        	data = SVMX.toObject(data);
        	var root = SVMX.cloneObject(this.__treeData.root);
            var isRecordFound = this.__searchForLocation(root.children, root, data.recordIds[0]);
            if(isRecordFound === false && this.__selectFromExternal){
                SVMX.getCurrentApplication().showQuickMessage("info", $TR.MESSAGE_LOC_NOT_EXISTS);
                delete this.__selectFromExternal;
            }
        },
        
        __searchForLocation : function(children, parentNode, recordId){
            var isRecordFound = false;
            if(!children) return isRecordFound;
            for(var i = 0; i < children.length; i++){
                var child = children[i];
                if(child.id === recordId){
                    var node = this.__tree.getStore().getNodeById(recordId);
                    if(node){
                        isRecordFound = true;
                        this.__tree.selectPath(node.getPath());
                        break;
                    }
                }else{
                    isRecordFound = this.__searchForLocation(child.children, parentNode, recordId);
                    if(isRecordFound === true) break;
                }
            }
            return isRecordFound;
        },
        
        __showSelectedIBRecord : function(data, callback) {
            var root = SVMX.cloneObject(this.__treeData.root);
            var loadSelectedIB = SVMX.create("com.servicemax.client.installigence.loadselectedib.LoadSelectedIB", {
                parent : this,
                selectedIB : data,
                root : root,
                callback : callback
            });
        },

        __getFilterOptions : function(){
            var me = this;
            if(!this.__filterExpressions){
                this.__filterExpressions = [];
            }

            var options = [];
            if(this.__meta.filters && this.__meta.filters.length){
                this.__filterState = this.__filterState || {};
                if(this.__meta.state && this.__meta.state.filters){
                    this.__filterState = this.__meta.state.filters;
                }
                for(i = 0; i < this.__meta.filters.length; i++){
                    var filter = this.__meta.filters[i];
                    var filterName = filter.name;
                    var cb = SVMX.create("com.servicemax.client.installigence.ui.components.Checkbox", {
                        boxLabel : filterName,
                        filterExpression : filter.expression,
                        inputValue : i,
                        value : me.__filterState[filterName],
                        margin: '0 0 0 5',
                        handler : function(){
                            // Index checked state so that it can be restored
                            me.__filterState[this.boxLabel] = this.value;
                            me.__selectFilterExpressions();
                            me.__setFilterState();
                        }
                    });
                    options.push(cb);
                }
                // Restore from saved state
                if(this.__meta.state && this.__meta.state.filters){
                    SVMX.doLater(function(){
                        me.__selectFilterExpressions();
                    });
                }
            }

            return options;
        },

        __setFilterState : function(){
            var newState = SVMX.cloneObject(this.__meta.state);
            newState.filters  = newState.filters || {};
            $.extend(newState.filters, this.__filterState);
            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                "INSTALLIGENCE.SAVE_STATE", this, {
                request : {context : this, state: newState}
            });
            com.servicemax.client.installigence.impl.EventBus.getInstance()
                .triggerEvent(evt);
        },

        __selectFilterExpressions : function(){
            this.__filterExpressions = [];
            var i, l = this.__optionsPanel.items.getCount();
            for(var i = 0; i < l; i++){
                var item = this.__optionsPanel.items.getAt(i);
                if(item.checked && item.filterExpression){
                    this.__filterExpressions.push(item.filterExpression);
                }
            }
            this.refreshContent();
        },

        __refreshFilterOptions : function(){
            var filterOptions = this.__getFilterOptions();
            var i, l = this.__optionsPanel.items.getCount();
            for(var i = 0; i < l; i++){
                var item = this.__optionsPanel.items.getAt(i);
                if(!item.filterExpression){
                    filterOptions.push(item);
                }
            }
            this.__optionsPanel.removeAll(false);
            for(var i = 0; i < filterOptions.length; i++){
                this.__optionsPanel.add(filterOptions[i]);
            }
        },
                
        getFilterExpressions : function(){
            return this.__filterExpressions;
        },

        __appendChildToParent : function(parent, child){
            parent.push({
                id : child.id,
                text : child.text,
                children : child.children,
                icon : child.icon,
                nodeType : child.nodeType,
                recordId : child.recordId
            });
        },

        __setupNodeFilters : function(){
            // setup internal node filters
            this.__allNodeFilters = {
                "loc": {
                    criteriaHandler : function(child){
                        return child.nodeType === "LOCATION"
                            || child.nodeType === "SUBLOCATION";
                    },
                    breakHandler : function(child){
                        return child.nodeType === "IB";
                    }
                },
                "swap": {
                    criteriaHandler : function(child){
                        return child.nodeType === "IB" && child.isSwapped;
                    }
                }
            };
            this.__appliedNodeFilters = {};
        },

        addNodeFilter : function(alias, criteriaHandler, breakHandler){
            this.__allNodeFilters[alias] = {
                criteriaHandler : criteriaHandler,
                breakHandler : breakHandler
            };
        },

        enableNodeFilter : function(alias){
            if(this.__allNodeFilters[alias]){
                this.__appliedNodeFilters[alias] = this.__allNodeFilters[alias];
            }
        },

        disableNodeFilter : function(alias){
            if(this.__appliedNodeFilters[alias]){
                delete this.__appliedNodeFilters[alias];
            }
        },

        hideNodes : function(alias, criteriaHandler, breakHandler){
            // Hide nodes based on criteria function, using alias to reference
            // Break handler is used ot prevent excessive recursion when
            // parent filters do not apply (i.e. locations)
            this.enableNodeFilter(alias);
            this.__applyNodeFilters();
        },

        showNodes : function(alias){
            this.disableNodeFilter(alias);
            this.__applyNodeFilters();
        },

        __applyNodeFilters : function(){
            var me = this;
            var treeData = this.__getTreeDataCloned();
            var root = treeData.root;
            var hasFilters = false;
            if(this.__appliedNodeFilters){
                var filterKeys = Object.keys(this.__appliedNodeFilters);
                for(var i = 0; i < filterKeys.length; i++){
                    if(this.__appliedNodeFilters[filterKeys[i]]){
                        hasFilters = true;
                        break;
                    }
                }
            }
            if(hasFilters){
                filterNodes(root.children, root, true);
            }
            this.__resetTreeStoreData(treeData);

            function criteriaHandler(node){
                for(var alias in me.__appliedNodeFilters){
                    if(!me.__appliedNodeFilters[alias]){
                        return true;
                    }
                    if(me.__appliedNodeFilters[alias].criteriaHandler(node)){
                        return true;
                    }
                }
            }
            function breakHandler(node){
                for(var alias in me.__appliedNodeFilters){
                    if(!me.__appliedNodeFilters[alias]){
                        continue;
                    }
                    if(me.__appliedNodeFilters[alias].breakHandler
                        && me.__appliedNodeFilters[alias].breakHandler(node)){
                        return true;
                    }
                }
            }
            function filterNodes(children, parentNode){
                if(!children) return;
                for(var i = 0; i < children.length; i++){
                    var child = children[i];
                    if(criteriaHandler(child)){
                        if(!parentNode.reset){
                            parentNode.reset = true;
                            parentNode.children = [];
                            // TODO: fix this hack, should be generic
                            if(!child.isSwapped){ // HACK
                                for(var j = 0; j < i; j++){
                                    parentNode.children.push(children[j]);
                                }
                            }
                        }
                        if(!child.isSwapped){ // HACK
                            filterNodes(child.children, parentNode);
                        }
                    }else{
                        if(child.nodeType !== "LOADING"){
                            if(parentNode.reset){
                                parentNode.children.push(child);
                            }
                            if(breakHandler(child)){
                                continue;
                            }
                            filterNodes(child.children, child);
                        }
                    }
                }
            }
        },

        getTreeData : function(){
            return this.__treeData;
        },

        getTreeDataById : function(){
            return this.__treeDataById;
        },

        getTree : function() {
        	return this.__tree;
        },

        __getTreeDataCloned : function(){
            // Clone to prevent inconsistency after of modifying the tree
            return SVMX.cloneObject(this.__treeData);
        },

        __setTreeData : function(treeData, reloaded){
            if(reloaded){
                this.__setTreeDataReloaded(treeData);
            }
            // Clone to prevent inconsistency after of modifying the tree
            this.__treeData = SVMX.cloneObject(treeData);
            this.__treeDataById = {};
            this.__forEachChild(this.__treeData.root, function(child, parent){
                if(!child.id) return;
                // TODO: this check should not be necessary
                // But there exists a bug where a single parent can be referenced from children
                // in different parts of the tree, so we need to prevent that double reference
                // TODO: fix the tree issue and remove this check later
                if(!this.__treeDataById[child.id]){
                    this.__treeDataById[child.id] = child;
                    child.parentId = parent.id;
                }
                if(this.__expandedById[child.id]){
                    // If data was reloaded, then delay expandion of top level IBs
                    if(reloaded && child.nodeType === "IB"){
                        child.__expanded = true;
                    }else{
                        child.expanded = true;
                    }
                }
            });
            // Reset tree data
            this.__resetTreeStoreData(treeData);
            // Restore internal node filters
            if(!this.__locationsVisible){
                // Note: disabled until further notice
                //this.__appliedNodeFilters.loc = this.__allNodeFilters.loc;
            }
            if(!this.__swappedVisible){
                // Note: disabled until further notice
                //this.__appliedNodeFilters.swap = this.__allNodeFilters.swap;
            }
            if(this.__transientFilters){
                for(var i = 0; i < this.__transientFilters.length; i++){
                    if(this.__transientFilters[i].isChecked()){
                        var transAlias = this.__transientFilters[i].getAlias();
                        this.__appliedNodeFilters[transAlias]
                            = this.__allNodeFilters[transAlias];
                    }
                }
            }
            this.__applyNodeFilters();
        },

        __setTreeDataReloaded : function(treeData){
            var priorTreeDataById = this.__treeDataById;
            if(priorTreeDataById){
                var newTreeIBsById = {};
                this.__forEachChild(treeData.root, function(child, parent){
                    if(!child.id) return;
                    if(child.nodeType === "IB"){
                        if(priorTreeDataById[child.id]){
                            // TODO: good idea or bad idea?
                            /*if(this.__expandedById[child.id]){
                                var priorChildren = priorTreeDataById[child.id].children;
                                child.children = priorChildren;
                                child.expanded = true;
                            }*/
                        }else{
                            delete this.__expandedById[child.id];
                        }
                        newTreeIBsById[child.id] = child;
                    }
                });
                // Collapse children which are no longer visible
                this.__forEachChild(this.__treeData.root, function(child, parent){
                    if(child.nodeType === "IB" && child.id && !newTreeIBsById[child.id]){
                        delete this.__expandedById[child.id];
                    }
                });
            }
        },

        __setTreeDataTransients : function(){
            // Restore transient record state indicators
            if(this.__transientRecordIndex){
                for(var i = 0; i < this.__transientRecordIndex.length; i++){
                    var recordId = this.__transientRecordIndex[i];
                    this.setTreeNodeTransient(recordId, true);
                }
            }
        },

        __resetTreeStoreData : function(treeData){
            this.__tree.getStore().removeAll();
            this.__tree.getStore().setRootNode(treeData.root);
        },

        __forEachChild : function(node, callback){
            // iterate through node children from top down
            if(!node.children) return;
            for(var i = 0; i < node.children.length; i++){
                callback.call(this, node.children[i], node);
                this.__forEachChild(node.children[i], callback);
            }
        },

        __detachChildFromParent : function(parent, child){
            for(var i = 0; i < parent.children.length; i++){
                if(parent.children[i].id === child.id){
                    parent.children.splice(i, 1);
                    return;
                }
            }
        },
        
        __canDropOn : function(nodes, parent){
            /******************************************
             * Rules: ALL CHANGES WITHIN SAME ACCOUNT
             * IB to different parent IB
             * IB to different location
             * IB to different to sub-location
             * Sublocation to different location
             * Sublocation to different sublocation
             * Child Location to different child location
             ******************************************/

            var dropNode = parent.data;
            var dropId = dropNode.recordId;
            var dropType = dropNode.nodeType;
            var accountId4Parent = this.__getAccountId4ChildNode(parent);

            var i, recs = nodes.records, l = recs.length, r, ret = true;
            for(i = 0; i < l; i++){
                r = recs[i];

                // if different account
                var accountId4Node = this.__getAccountId4ChildNode(r);
                if(accountId4Node != accountId4Parent){
                    return false;
                }

                var dragNode = r.data;
                var dragType = dragNode.nodeType;
                var dragParent = this.__treeDataById[dragNode.parentId];
                var dragParentType = dragParent.nodeType;

                // if it is the same parent
                if(r.parentNode.data.recordId == dropId){
                    return false;
                }

                if(dropType == "IB"){
                    if(dragType != "IB"){
                        ret = false;
                    }
                }else if(dropType == "SUBLOCATION"){
                    if(!(dragType == "IB" || dragType == "SUBLOCATION")){ 
                        ret = false;
                    }
                }else if(dropType == "LOCATION"){
                    if(!(dragType == "IB" || dragType == "SUBLOCATION" || dragType == "LOCATION")){ 
                        ret = false;
                    }
                    if(dragType == "LOCATION" && dragParentType === "ACCOUNT"){ 
                        ret = false;
                    }
                }else if(dropType == "ACCOUNT"){
                    ret = false;
                }else{
                    ret = false;
                }

                if(ret === false){
                    return false;
                }
            }
            return true;
        },

        __handleDropOn : function(nodes, parent, dropHandlers){
            dropHandlers.wait = true;
            var me = this;
            var parentData = parent.data;
            var parentType = parentData.nodeType;
            var parentId = parentData.recordId;
            var i, recs = nodes.records, l = recs.length, r, nodeType;
            var ur = {}; // ur = {Id, Site, SubLocation, Parent, Top_Level}
            var objectName = {};

            // used below to modify internal tree data
            var dropChildren = [];
            var dropParent = this.__treeDataById[parent.id];
            var dropParentNode = this.__tree.getStore().findNode("id", parent.id);

            // TODO: refactor this to work on treeData instead of store nodes
            for(i = 0; i < l; i++){
                r = recs[i]; nodeType = r.data.nodeType;
                ur.Id = r.data.recordId;
                dropChildren.push(this.__treeDataById[r.id]);
                // being dragged
                if(nodeType == "IB"){
                    objectName = SVMX.getCustomObjectName("Installed_Product");
                    // being dropped on
                    if(parentType == "IB"){
                        // get location, sublocation, and toplevel
                        var tmpParent = parent;
                        var topLevelId;
                        var locationId;
                        var sublocationId;
                        while(tmpParent != null){
                            if(tmpParent.data.nodeType == "IB"){
                                topLevelId = tmpParent.data.recordId;
                            }else if(tmpParent.data.nodeType == "SUBLOCATION" && !sublocationId){
                                sublocationId = tmpParent.data.recordId;
                            }else if(tmpParent.data.nodeType == "LOCATION" && !locationId){
                                locationId = tmpParent.data.recordId;
                            }
                            tmpParent = tmpParent.parentNode;
                        }

                        // update the parent
                        ur[SVMX.getCustomFieldName("Site")] = locationId;
                        ur[SVMX.getCustomFieldName("Parent")] = parentId;
                        ur[SVMX.getCustomFieldName("Top_Level")] = topLevelId;
                        ur[SVMX.getCustomFieldName("Sub_Location")] = sublocationId;
                    }else if(parentType == "SUBLOCATION"){
                        // This IB becomes top level 
                        var locationId = parent.parentNode.data.recordId;
                        ur[SVMX.getCustomFieldName("Site")] = locationId;
                        ur[SVMX.getCustomFieldName("Parent")] = "";
                        ur[SVMX.getCustomFieldName("Top_Level")] = "";
                        ur[SVMX.getCustomFieldName("Sub_Location")] = parentId;
                    }else if (parentType == "LOCATION"){
                        // This IB becomes toplevel
                        ur[SVMX.getCustomFieldName("Site")] = parentId;
                        ur[SVMX.getCustomFieldName("Parent")] = "";
                        ur[SVMX.getCustomFieldName("Top_Level")] = "";
                        ur[SVMX.getCustomFieldName("Sub_Location")] = "";
                    }else{
                        // should not happen
                        dropHandlers.wait = false;
                    }

                }else if(nodeType == "LOCATION"){
                    objectName = SVMX.getCustomObjectName("Site");
                    if(parentType == "LOCATION"){
                        parentId = parent.data.id;
                        // update the parent
                        ur[SVMX.getCustomFieldName("Parent")] = parentId;
                    }else{
                        dropHandlers.wait = false;
                    }
                }else if(nodeType == "SUBLOCATION"){
                    objectName = SVMX.getCustomObjectName("Sub_Location");
                    // TODO:
                    dropHandlers.wait = false;
                }else{
                    // should not happen
                    dropHandlers.wait = false;
                }
            }

            if(!dropHandlers.wait) return false;

            // process drop first to avoid double loading data from operation
            dropHandlers.processDrop();
            // update internal tree data
            var dropNodeSelectedId = false
            for(var i = 0; i < dropChildren.length; i++){
                var prevParent = this.__treeDataById[dropChildren[i].parentId];
                this.__detachChildFromParent(prevParent, dropChildren[i]);
                dropParent.children.push(dropChildren[i]);
                dropChildren[i].parentId = dropParent.id;
                dropChildren[i].prevParentId = prevParent.id;
                if(this.__selectedNodeId === dropChildren[i].id){
                    dropNodeSelectedId = dropChildren[i].id;
                }
            }

            // Cause the tree to reload parent
            dropParent.loaded = false;

            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                "INSTALLIGENCE.UPDATE_IB_HIERARCHY", this, {
                    request : {
                        context : this,
                        params : {},
                        record : ur,
                        objectName : objectName,
                        handler : function(data){
                            // Reset the record view if a dropped node is selected
                            if(dropNodeSelectedId){
                                me.fireEvent("node_selected", me.__treeDataById[dropNodeSelectedId]);
                            }
                        }
                    }
            });
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
        },

        __getAccountId4ChildNode : function(node){
            var ret = null;
            while(node != null){
                if(node.data.nodeType == "ACCOUNT"){
                    ret = node.data.recordId;
                    break;
                }
                node = node.parentNode;
            }
            return ret;
        },

        __fireRecordsSelected : function(){
            var selectedRecords = this.__tree.getChecked(), nodes = [];
            for(var i = 0; i < selectedRecords.length; i++){
                nodes.push(selectedRecords[i].data);
            }
            this.fireEvent("records_selected", nodes);
        },
        
        __showMore : function(p){
            var parentNode = this.__treeDataById[p.node.id];

            if(parentNode.allIBsLoaded){
                SVMX.getLoggingService().getLogger("All nodes loaded for " + parentNode.id);
                return;
            }
            
            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                "INSTALLIGENCE.GET_MORE_IBS", this, {
                    request : { context : this, params : {
                        parentNode : parentNode,
                        thisNode : null // TODO: what was this for? if not needed remove it
                    },
                    lastIBIndex : parentNode.lastIBIndex,
                    parentIBId : parentNode.id
                }
            });
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
            return this.__showMoreD = SVMX.Deferred();
        },
        
        onGetMoreIBsCompleted : function(data, params){
            var updatedLastIndex = 0, i, l = data.length, d;
            var parentNode = this.__tree.getStore().findNode("id", params.parentNode.id);

            var internalParentNode = this.__treeDataById[parentNode.id];
            
            // remove LOADING Node
            for(var i = 0; i < internalParentNode.children.length; i++){ 
                var child = internalParentNode.children[i];
                if(child.nodeType == "LOADING"){ 
                    internalParentNode.children.splice(i, 1);
                    break;
                }
            }
            
            var items = [];
            for(i = 0; i < l; i++){
                d = data[i];
                updatedLastIndex = d["RecordId"];
                
                items.push({
                    id : d["Id"],
                    text : d["Name"],
                    children : [this.__getLoadingNodeObject()],
                    icon : this.__getIconFor(d, "IB"),
                    //checked : false,
                    nodeType : "IB",
                    recordId : d["Id"]
                });
            }

            if(!internalParentNode.children){
                internalParentNode.children = items;
            }else{
                for(var i = items.length-1; i >= 0; i--){
                    internalParentNode.children.unshift(items[i]);
                }
            }
            internalParentNode.lastIBIndex = updatedLastIndex;
            internalParentNode.expanded = true;
            internalParentNode.allIBsLoaded = true;

            // if node has no children, undo the expand state internally
            if(internalParentNode.children.length === 0){
                internalParentNode.expanded = false;
                this.__expandedById[parentNode.id] = false;
            }

            // Apply changes incrementally to data store
            parentNode.removeChild(parentNode.childNodes[0]);

            parentNode.collapse();
            for(var i = 0; i < items.length; i++){
                parentNode.appendChild(items[i]);
                this.__treeDataById[items[i].id] = items[i];
            }

            // Note: can't use setTreeData here because
            // it causes a locked focus on the expanded item
            //this.__setTreeData(this.__treeData);
            this.__setTreeDataTransients();
            this.fireEvent('node_loaded', data);

            if(this.__selectedNodeId){
                this.selectTreeNode(this.__selectedNodeId);
            }

            parentNode.expand();

            this.__showMoreD.resolve();
        },
        
        __getIBChildNodes : function(parentId, childIBs){
            var children = [];
            if(childIBs && childIBs.length){
                var parentField = SVMX.getCustomFieldName("Parent");
                for(var i = 0; i < childIBs.length; i++){
                    var child = childIBs[i];
                    if(child[parentField] === parentId){
                        children.push({
                            id : child.Id,
                            text : child.Name,
                            children : this.__getIBChildNodes(child.Id, childIBs),
                            icon : this.__getIconFor(child, "IB"),
                            //checked : false,
                            nodeType : "IB",
                            recordId : child.Id
                        });
                    }
                }
            }
            if(!children.length){
                children.push(this.__getLoadingNodeObject());
            }
            return children;
        },

        __getLoadingNodeObject : function(){
            var loadingText = "Please wait";
            var ret = {
                text :  loadingText,
                icon : com.servicemax.client.installigence.impl.Module.instance.getResourceUrl("images/paging.gif"),
                nodeType : "LOADING"
            };
            
            return ret;
        },
        
        toggleOptions : function(){
            this.__optionsPanel.toggleCollapse();
            this.doLayout();
        },

        getOptionsPanel : function(){
            return this.__optionsPanel;
        },
        
        addToTree : function(children, parent, type){
            if(type == "IB"){
                this.__addIBsToTree(children, parent, type);
            }else if(type == "LOCATION"){
                this.__addLocationToTree(children, parent, type);
            }else if(type == "SUBLOCATION"){
                this.__addSubLocationToTree(children, parent, type);
            }
        },

        __addLocationToTree : function(children, parent, type){
            var records = [], r = {};

            r["Name"] = "New Location"; // default name
            if(parent.nodeType === "ACCOUNT"){
                r[SVMX.getCustomFieldName("Account")] = parent.id;
            }else if(parent.nodeType === "LOCATION"){
                r[SVMX.getCustomFieldName("Parent")] = parent.id;
                var accParent = parent;
                while(accParent.nodeType !== "ACCOUNT"){
                    accParent = this.__treeDataById[accParent.parentId];
                }
                r[SVMX.getCustomFieldName("Account")] = accParent.id;
            }
            records.push(r);
            this.__addRecords(records, parent, type, SVMX.getCustomObjectName("Site"));
        },

        __addSubLocationToTree : function(children, parent, type){
            var records = [], r = {};

            r["Name"] = "New Sub-Location"; // default name
            if(parent.nodeType === "LOCATION"){
                r[SVMX.getCustomFieldName("Location")] = parent.id;
                var accParent = parent;
                while(accParent.nodeType !== "ACCOUNT"){
                    accParent = this.__treeDataById[accParent.parentId];
                }
                r[SVMX.getCustomFieldName("Account")] = accParent.id;
            }else if(parent.nodeType === "SUBLOCATION"){
                r[SVMX.getCustomFieldName("Parent")] = parent.id;
                var locParent = parent;
                while(locParent && locParent.nodeType !== "LOCATION"){
                    locParent = this.__treeDataById[locParent.parentId];
                }
                var accParent = parent;
                while(accParent.nodeType !== "ACCOUNT"){
                    accParent = this.__treeDataById[accParent.parentId];
                }
                r[SVMX.getCustomFieldName("Location")] = locParent && locParent.id;
                r[SVMX.getCustomFieldName("Account")] = accParent.id;
            }
            records.push(r);
            this.__addRecords(records, parent, type, SVMX.getCustomObjectName("Sub_Location"));
        },

        /*__addIBsToTree_other : function(children, parent, type){
            var records = [], r = {};

            r["Name"] = "New Installed Product"; // default name
            if(parent.nodeType === "LOCATION"){
                var accParent = parent;
                while(accParent.nodeType !== "ACCOUNT"){
                    accParent = this.__treeDataById[accParent.parentId];
                }
                r[SVMX.getCustomFieldName("Site")] = parent.id;
                r[SVMX.getCustomFieldName("Company")] = accParent.id;
            }else if(parent.nodeType === "SUBLOCATION"){
                r[SVMX.getCustomFieldName("Sub_Location")] = parent.id;
                var locParent = parent;
                while(locParent && locParent.nodeType !== "LOCATION"){
                    locParent = this.__treeDataById[locParent.parentId];
                }
                r[SVMX.getCustomFieldName("Site")] = locParent && locParent.id;
            }else if(parent.nodeType === "IB"){
                r[SVMX.getCustomFieldName("Parent")] = parent.id;
                var ibParent = parent;
                while(this.__treeDataById[ibParent.parentId].nodeType === "IB"){
                    ibParent = this.__treeDataById[ibParent.parentId];
                }
                var locParent = parent;
                while(locParent && locParent.nodeType !== "LOCATION"){
                    locParent = this.__treeDataById[locParent.parentId];
                }
                var sublocParent = parent;
                while(sublocParent && sublocParent.nodeType !== "SUBLOCATION"){
                    sublocParent = this.__treeDataById[sublocParent.parentId];
                }
                var accParent = parent;
                while(accParent.nodeType !== "ACCOUNT"){
                    accParent = this.__treeDataById[accParent.parentId];
                }
                r[SVMX.getCustomFieldName("Top_Level")] = ibParent.id;
                r[SVMX.getCustomFieldName("Site")] = locParent && locParent.id;
                r[SVMX.getCustomFieldName("Sub_Location")] = sublocParent && sublocParent.id;
                r[SVMX.getCustomFieldName("Company")] = accParent.id;
            }
            records.push(r);
            this.__addRecords(records, parent, type, SVMX.getCustomObjectName("Installed_Product"));
        },*/

        __addIBsToTree : function(children, parent, type){
            var pnode = this.__tree.getStore().findNode("id", parent.id);
            var records = this.__createNewIBRecordData(pnode, children);
            this.__addRecords(records, parent, type, SVMX.getCustomObjectName("Installed_Product"));
        },

        __addRecords : function(records, parent, type, objectName){
            SVMX.getCurrentApplication().blockUI();
            var pnode = this.__tree.getStore().findNode("id", parent.id);
            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                "INSTALLIGENCE.CREATE_RECORDS", this, {
                    request : {
                        context : this,
                        handler : this.onCreateRecordsComplete,
                        objectName : objectName,
                        params : {
                            parentNode : pnode,
                            type : type
                        },
                        records : records
                    }
            });
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
        },

        addClonedToTree : function(record, cloned, type, cascade){
            var parentNode = this.__tree.getStore().findNode("id", cloned.parentId);
            this.onCreateRecordsComplete([record], {
                type : type,
                parentNode : parentNode,
                insertAfter : cloned,
                hasChildren : cascade
            });
        },

        deleteFromTree : function(node){
            node = this.__tree.getStore().findNode("id", node.id);

            var objectName;
            switch(node.data.nodeType){
                case "ACCOUNT":
                    objectName = SVMX.getCustomObjectName("Account");
                    break;
                case "LOCATION":
                    objectName = SVMX.getCustomObjectName("Site");
                    break;
                case "SUBLOCATION":
                    objectName = SVMX.getCustomObjectName("Sub_Location");
                    break;
                case "IB":
                    objectName = SVMX.getCustomObjectName("Installed_Product");
                    break;
            }
            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                "INSTALLIGENCE.DELETE_RECORDS", this, {
                    request : {
                        context : this,
                        handler : this.onDeleteRecordsComplete,
                        objectName : objectName,
                        recordId : node.data.recordId,
                        params : {
                            node : node,
                            type : node.nodeType
                        }
                    }
            });
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
        },

        onDeleteRecordsComplete : function(success, params){
            if(!success){
                SVMX.getCurrentApplication().showQuickMessage("error", $TR.DELETE_ERROR_MESSAGE);
                return;
            }
            // update internal tree
            var treeNode = this.__treeDataById[params.node.id];
            var treeParent = this.__treeDataById[treeNode.parentId];
            this.__detachChildFromParent(treeParent, treeNode);
            // remove from data store
            params.node.remove();
        },

        __createNewIBRecordData : function(pnode, children){
            var accountId = null;
            var locationId = null;
            var sublocationId = null;
            var topLevel = null;
            var records = [], r, i, l = children.length, c, tmpParent = pnode;
            
            var parentRecordId = null;
            if(pnode.data.nodeType === "IB"){
                parentRecordId = pnode.data.recordId;
            }
            while(tmpParent != null){   
                if(tmpParent.data.nodeType == "LOCATION" && !locationId){
                    locationId = tmpParent.data.recordId;
                }else if(tmpParent.data.nodeType == "SUBLOCATION" && !sublocationId){
                    sublocationId = tmpParent.data.recordId;
                }else if(tmpParent.data.nodeType == "ACCOUNT"){
                    accountId = tmpParent.data.recordId;
                }else if(tmpParent.data.nodeType == "IB"){
                    topLevel = tmpParent.data.recordId;
                }
                
                tmpParent = tmpParent.parentNode;
            }

            for(i = 0; i < l; i++){
                c = children[i];
                r = {};
                r["Name"] = c.Name;
                r[SVMX.getCustomFieldName("Company")] = accountId;
                r[SVMX.getCustomFieldName("Site")] = locationId;
                r[SVMX.getCustomFieldName("Sub_Location")] = sublocationId;
                r[SVMX.getCustomFieldName("Product")] = c.Id;
                r[SVMX.getCustomFieldName("Product_Name")] = c.Name;
                r[SVMX.getCustomFieldName("Parent")] = parentRecordId;
                r[SVMX.getCustomFieldName("Top_Level")] = topLevel;
                // TEMP: Hard coded mappings from product
                // TODO: Remove these after field mapping is available for add new IB action
                r['Category__c'] = c.CategoryId__c__id;     // Range
                r['DeviceType2__c'] = c.DeviceType2__c__id; // DeviceType
                r['Brand2__c'] = c.Brand2__c__id;           // Brand
                records.push(r);
            }
            
            return records;
        },
        
        onCreateRecordsComplete : function(data, params){

            SVMX.getCurrentApplication().unblockUI();

            var parentNode = this.__tree.getStore().findNode("id", params.parentNode.id);
            parentNode.expand(false);

            // if the parent node is not expanded, just return, the first-time expand code
            // will fetch the newly inserted records along with the other records
            var internalParentNode = this.__treeDataById[parentNode.id];
            if(internalParentNode.nodeType == "IB" && !internalParentNode.allIBsLoaded){
                this.__selectedNodeId = data[0].Id;
                return;
            }
            
            var childNodes = [];
            var i, l = data.length, d;
            for(i = 0; i < l; i++){
                d = data[i];
                var child = {
                    id : d.Id,
                    text : d.Name,
                    children : [],
                    icon : this.__getIconFor(d, params.type),
                    //checked : false,
                    nodeType : params.type,
                    recordId : d.Id
                };
                if(params.type === "IB"){
                    child.isSwapped = d[SVMX.getCustomFieldName("IsSwapped")];
                }
                if(params.hasChildren){
                    child.children = [this.__getLoadingNodeObject()];
                }
                childNodes.push(child);
                this.__treeDataById[child.id] = child;
            }
            if(params.insertAfter){
                var afterNode = this.__tree.getStore().findNode("id", params.insertAfter.id);
                for(var i = 0; i < internalParentNode.children.length; i++){
                    if(internalParentNode.children[i].id === params.insertAfter.id){
                        for(var j = 0; j < childNodes.length; j++){
                            internalParentNode.children.splice(i+j+1, 0, childNodes[j]);
                            parentNode.insertChild(i+1, childNodes[j]);
                            this.__tree.getStore().findNode("id", childNodes[j].id).loaded = false;
                        }
                        break;
                    }
                }
            }else{
                for(var i = 0; i < childNodes.length; i++){
                    internalParentNode.children.unshift(childNodes[i]);
                    parentNode.insertChild(0, childNodes[i]);
                    this.__tree.getStore().findNode("id", childNodes[i].id).loaded = false;
                }
            }

            // Cause parent to reload
            parentNode.loaded = false;
            
            this.__setTreeDataTransients();

            if(params.insertAfter){
                this.__tree.getStore().findNode("id", params.insertAfter.id).collapse(false);
            }
            this.__tree.getStore().findNode("id", childNodes[0].id).expand(false);
            this.selectTreeNode(childNodes[0].id);
        },
        
        __getIconFor : function(record, type){
            switch(type){
                case "IB":
                    var ibId = record[SVMX.getCustomFieldName("Top_Level")]
                        || record.Id;
                    var ibIndex = this.__productIconIndex[ibId];
                    var productId = record[SVMX.getCustomFieldName("Product")];
                    if(ibIndex && ibIndex[productId]){
                        // TODO: use native client method to get download path
                        var iconName = ibIndex[productId];
                        var iconPath = "C:/ProgramData/ServiceMax/ProductIQ/Downloads/"+iconName;
                        return iconPath;
                    }
                    return "modules/com.servicemax.client.installigence.ui.components/resources/extjsthemes/installigence/images/custom/dummy-icon1.png";
                default:
                    var defaultIcons = {
                        'LOCATION' : 'modules/com.servicemax.client.installigence.ui.components/resources/extjsthemes/installigence/images/custom/dummy-icon2.png',
                        'SUBLOCATION' : 'modules/com.servicemax.client.installigence.ui.components/resources/extjsthemes/installigence/images/custom/dummy-icon4.png',
                        'ACCOUNT' : 'modules/com.servicemax.client.installigence.ui.components/resources/extjsthemes/installigence/images/custom/dummy-icon5.png'
                    };
                    return defaultIcons[type];
            }
        },

        refreshContent : function(p){
            var bRefresh = true;
            if(p){
                if(p.type == "initialize"){
                    // nothing yet
                }else if(p.params && p.params.syncType && 
                    (p.params.syncType == "initial" || p.params.syncType == "reset" || p.params.syncType == "ib")){
                    
                    // TODO: not sure tree should be refreshed when type is 'ib'
                    
                    // this may not be the right place
                    this.fireEvent("reset");
                }else{
                    bRefresh = false;
                }
            }
            if(bRefresh){
                var me = this;
                setTimeout(function(){
                    me.__refreshContentInternal();
                }, 50);
            }
        },
        
        __refreshContentInternal : function(){
            SVMX.getCurrentApplication().blockUI();
            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                    "INSTALLIGENCE.GET_TOP_LEVEL_IBS", this, {request : { context : this}});
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
        },

        updateRecordName : function(id, name){
            var node = this.__treeDataById[id];
            if(node){
                this.__setTreeNodeName(node, name);
            }
        },
        
        updateRecordWithErrorStar : function(id, name){
        	var node = this.__treeDataById[id];
            if(node){
                this.__setTreeNodeError(node, name);
        	   //node.text = name+"*";
            }
        },
        
        __getLocationAndAccountDetails : function(treeData, listOfLocations, listOfSubLocations, listOfAccounts){
            var locIds = [];
            var sublocIds = [];
            var accIds = [];
            var i, l = listOfLocations.length;
            for(i = 0; i < l; i++){
                locIds.push(listOfLocations[i].id);
            }
            l = listOfSubLocations.length;
            for(i = 0; i < l; i++){
                sublocIds.push(listOfSubLocations[i].id);
            }
            l = listOfAccounts.length;
            for(i = 0; i < l; i++){
                accIds.push(listOfAccounts[i].id);
            }
            
            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                "INSTALLIGENCE.GET_LOC_ACC_DETAILS", this, {
                    request : { 
                        context : this,
                        locIds : locIds,
                        sublocIds : sublocIds,
                        accIds : accIds,
                        params : {
                            treeData : treeData,
                            listOfLocations : listOfLocations,
                            listOfSubLocations : listOfSubLocations,
                            listOfAccounts : listOfAccounts
                        }
                    }
                }
            );
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
        },
        
        onGetLocationAndAccountDetailsCompleted : function(data, params){
            var treeData = params.treeData;
            var listOfAccounts = params.listOfAccounts || [];
            var listOfLocations = params.listOfLocations || [];
            var listOfSubLocations = params.listOfSubLocations || [];
            var accounts = data.accounts || [];
            var locations = data.locations || [];
            var sublocations = data.sublocations || [];
            
            // locations
            var id2nameMap = {}, i;
            for(i = 0; i < locations.length; i++){
                id2nameMap[locations[i].Id] = locations[i].Name;
            }
            
            for(i = 0; i < listOfLocations.length; i++){
                var n = listOfLocations[i].text;
                if(id2nameMap[listOfLocations[i].id]){
                    n = id2nameMap[ listOfLocations[i].id ];
                }
                listOfLocations[i].text = n;
            }
            // end locations

            // sublocations
            id2nameMap = {};
            for(i = 0; i < sublocations.length; i++){
                id2nameMap[sublocations[i].Id] = sublocations[i].Name;
            }
            
            for(i = 0; i < listOfSubLocations.length; i++){
                var n = listOfSubLocations[i].text;
                if(id2nameMap[listOfSubLocations[i].id]){
                    n = id2nameMap[ listOfSubLocations[i].id ];
                }
                listOfSubLocations[i].text = n;
            }
            // end sublocations
            
            // accounts
            id2nameMap = {};
            for(i = 0; i < accounts.length; i++){
                id2nameMap[accounts[i].Id] = accounts[i].Name;
            }
            
            for(i = 0; i < listOfAccounts.length; i++){
                var n = listOfAccounts[i].text;
                if(id2nameMap[listOfAccounts[i].id]){
                    n = id2nameMap[ listOfAccounts[i].id ];
                }
                listOfAccounts[i].text = n;
            }
            // end accounts

            this.onDataLoadComplete(treeData);
        },

        onDataLoadComplete : function(treeData){
            // Finally set new tree data
            this.__setTreeData(treeData, true);
            this.__setTreeDataTransients();
            // Reload previously expanded IBs
            //this.__asyncExpandPriorIBs();

            SVMX.getCurrentApplication().unblockUI();

            // Handle pending external messages
            var pendingMessage = SVMX.getCurrentApplication().getPendingMessage();
            if(pendingMessage !== null){
                pendingMessage = SVMX.toObject(pendingMessage);
                this.__handleExternalMessage(pendingMessage);               
                if(pendingMessage.action === "VIEW"){
                    SVMX.getCurrentApplication().emptyPendingMessage();
                }
            }

            // Re-select previous note when filtering
            if(this.__selectedNodeId){
                this.selectTreeNode(this.__selectedNodeId);
            }
        },

        __asyncExpandPriorIBs : function(){
            var me = this;
            for(var id in this.__treeDataById){
                if(this.__treeDataById[id].__expanded){
                    this.__showMore({node : this.__tree.getStore().findNode("id", id)})
                    .done(function(){
                        // Continue recursively expanding top level nodes
                        //me.__asyncExpandPriorIBs();
                    });
                    this.__treeDataById[id].expanded = true;
                    delete this.__treeDataById[id].__expanded;
                    //break;
                }
            }
        },
        
        onGetTopLevelIBsComplete : function(data){

            this.__loadTreeData(data);
        },

        __loadTreeData : function(data){
            var me = this;
            var treeData = {
                root : {
                    expanded : true,
                    children : []
                }
            };
            data = data || [];

            if(data.templates){
                this.__indexProductIconsFromTemplates(data);
            }
            if(data.transients){
                this.__transientRecordIndex = data.transients;
            }

            // 1) Create all the nodes
            var accountsById = {};
            if(data.accounts){
                for(var i = 0; i < data.accounts.length; i++){
                    var record = data.accounts[i];
                    var accountNode = {
                        id : record.Id,
                        text : record.Name || ("(Acc) "+record.Id),
                        icon : 'modules/com.servicemax.client.installigence.ui.components/resources/extjsthemes/installigence/images/custom/dummy-icon5.png',
                        children : [],
                        nodeType : "ACCOUNT",
                        recordId : record.Id
                    };
                    accountsById[record.Id] = accountNode;
                }
            }
            var locationsById = {};
            if(data.locations){
                for(var i = 0; i < data.locations.length; i++){
                    var record = data.locations[i];
                    var parentId, parentType;
                    if(record[SVMX.getCustomFieldName("Parent")]){
                        parentId = record[SVMX.getCustomFieldName("Parent")];
                        parentType = "LOCATION";
                    }else if(record[SVMX.getCustomFieldName("Account")]){
                        parentId = record[SVMX.getCustomFieldName("Account")];
                        parentType = "ACCOUNT";
                    }
                    var locationNode = {
                        id : record.Id,
                        text : record.Name || ("(Loc) "+record.Id),
                        icon : 'modules/com.servicemax.client.installigence.ui.components/resources/extjsthemes/installigence/images/custom/dummy-icon2.png',
                        children : [],
                        nodeType : "LOCATION",
                        recordId : record.Id,
                        parentId : parentId,
                        parentType : parentType
                    };
                    locationsById[record.Id] = locationNode;
                }
            }
            var sublocationsById = {};
            if(data.sublocations){
                for(var i = 0; i < data.sublocations.length; i++){
                    var record = data.sublocations[i];
                    var parentId, parentType;
                    if(record[SVMX.getCustomFieldName("Parent")]){
                        parentId = record[SVMX.getCustomFieldName("Parent")];
                        parentType = "SUBLOCATION";
                    }else if(record[SVMX.getCustomFieldName("Location")]){
                        parentId = record[SVMX.getCustomFieldName("Location")];
                        parentType = "LOCATION";
                    }
                    var sublocationNode = {
                        id : record.Id,
                        text : record.Name || ("(Sub) "+record.Id),
                        icon : 'modules/com.servicemax.client.installigence.ui.components/resources/extjsthemes/installigence/images/custom/dummy-icon4.png',
                        children : [],
                        nodeType : "SUBLOCATION",
                        recordId : record.Id,
                        parentId : parentId,
                        parentType : parentType
                    };
                    sublocationsById[record.Id] = sublocationNode;
                }
            }
            var ibsById = {};
            if(data.ibs){
                for(var i = 0; i < data.ibs.length; i++){
                    var record = data.ibs[i];
                    var parentId, parentType;
                    if(record[SVMX.getCustomFieldName("Parent")]){
                        parentId = record[SVMX.getCustomFieldName("Parent")];
                        parentType = "IB";
                    }else if(record[SVMX.getCustomFieldName("Sub_Location")]){
                        parentId = record[SVMX.getCustomFieldName("Sub_Location")];
                        parentType = "SUBLOCATION";
                    }else if(record[SVMX.getCustomFieldName("Site")]){
                        parentId = record[SVMX.getCustomFieldName("Site")];
                        parentType = "LOCATION";
                    }else if(record[SVMX.getCustomFieldName("Company")]){
                        parentId = record[SVMX.getCustomFieldName("Company")];
                        parentType = "ACCOUNT";
                    }
                    var ibNode = {
                        id : record.Id,
                        text : record.Name || ("(IB) "+record.Id),
                        icon : me.__getIconFor(record, "IB"),
                        children : [this.__getLoadingNodeObject()],
                        nodeType : "IB",
                        recordId : record.Id,
                        isSwapped : record[SVMX.getCustomFieldName("IsSwapped")],
                        parentId : parentId,
                        parentType : parentType
                    };
                    ibsById[record.Id] = ibNode;
                }
            }

            // 2) Assemble the hierarchy
            for(var key in locationsById){
                var node = locationsById[key];
                if(node.parentType === "LOCATION" && locationsById[node.parentId]){
                    locationsById[node.parentId].children.push(node);
                }else if(node.parentType === "ACCOUNT" && accountsById[node.parentId]){
                    if(accountsById[node.parentId]){
                        accountsById[node.parentId].children.push(node);
                    }
                }else{
                    warnParentInvalid(node);
                }
            }
            for(var key in sublocationsById){
                var node = sublocationsById[key];
                if(node.parentType === "LOCATION" && locationsById[node.parentId]){
                    locationsById[node.parentId].children.push(node);
                }else if(node.parentType === "SUBLOCATION" && sublocationsById[node.parentId]){
                    sublocationsById[node.parentId].children.push(node);
                }else{
                    warnParentInvalid(node);
                }
            }
            for(var key in ibsById){
                var node = ibsById[key];
                if(node.parentType === "ACCOUNT" && accountsById[node.parentId]){
                    accountsById[node.parentId].children.push(node);
                }else if(node.parentType === "LOCATION" && locationsById[node.parentId]){
                    locationsById[node.parentId].children.push(node);
                }else if(node.parentType === "SUBLOCATION" && sublocationsById[node.parentId]){
                    sublocationsById[node.parentId].children.push(node);
                }else if(node.parentType === "IB" && ibsById[node.parentId]){
                    ibsById[node.parentId].children.push(node);
                }else{
                    warnParentInvalid(node);
                }
            }
            for(var key in accountsById){
                var node = accountsById[key];
                treeData.root.children.push(node);
            }

            this.onDataLoadComplete(treeData);

            function warnParentInvalid(node){
                console.warn('Tree structure invalid: Location '+node.id+' parent '+node.parentType+' '+node.parentId+' not found');
            }
        },

        __indexProductIconsFromTemplates : function(data){
            var index = this.__productIconIndex = {};
            for(var i = 0; i < data.ibs.length; i++){
                var ib = data.ibs[i];
                var tplId = ib[SVMX.getCustomFieldName("ProductIQTemplate")];
                if(tplId && data.templates[tplId]) {
                    indexIBProductIconsRecursive(
                        ib.Id, data.templates[tplId].template
                    );
                }
            }

            function indexIBProductIconsRecursive(ibId, template) {
                if(template.children){
                    var i, l = template.children.length;
                    for(i = 0; i < l; i++){
                        indexIBProductIconsRecursive(ibId, template.children[i]);
                    }
                }
                var product = template.product;
                if(product && product.productIcon){
                    index[ibId] = index[ibId] || {};
                    index[ibId][product.productId] = product.productIcon;
                }
            }
        },

        setTreeNodeTransient : function(id, isTransient){
            var me = this;
            var node = this.__treeDataById[id];
            if(!node) return;
            // Unref previous parent (set from handleDropOn...)
            if(node.transient && node.prevParentId){
                var prevParent = this.__treeDataById[node.prevParentId];
                if(prevParent){
                    unrefNode(prevParent);
                }
            }
            isTransient = (isTransient === undefined) ? true : isTransient;
            if(isTransient) {
                refNode(node);
            }else{
                unrefNode(node);
            }
            node.transient = isTransient;
            delete node.prevParentId;
            function refNode(node){
                node.transientRefs = node.transientRefs || [];
                if(node.transientRefs.indexOf(id) === -1){
                    node.transientRefs.push(id);
                }
                if(!node.origText){
                    node.origText = node.text;
                    node.text = node.text+"*";
                    me.__tree.getStore().findNode("id", node.id)
                        .updateInfo(true, {text: node.text});
                }
                var parent = me.__treeDataById[node.parentId];
                if(parent){
                    refNode(parent);
                }
            }
            function unrefNode(node){
                if(node.transientRefs){
                    var idx = node.transientRefs.indexOf(id);
                    if(idx !== -1){
                        node.transientRefs.splice(idx, 1);
                    }
                    if(!node.transientRefs.length && node.origText){
                        node.text = node.origText;
                        me.__tree.getStore().findNode("id", node.id)
                            .updateInfo(true, {text: node.text});
                        delete node.origText;
                    }
                }
                var parent = me.__treeDataById[node.parentId];
                if(parent){
                    unrefNode(parent);
                }
            }
            return;
            this.__setTreeData(this.__treeData);
        },

        __setTreeNodeName : function(node, name){
            if(!node.transientRefs || !node.transientRefs.length){
                node.text = name;
                delete node.origText;
            }else{
                node.origText = name;
                node.text = name+"*";
            }
            this.__tree.getStore().findNode("id", node.id)
                .updateInfo(true, {text: node.text});
        },

        __setTreeNodeError : function(node, name){
            node.origText = name;
            node.text = name+"*";
            this.__tree.getStore().findNode("id", node.id)
                .updateInfo(true, {text: node.text});
        }
    });

    /**
     * Transient filter functionality for IBtree
     * Used to manage and apply transient filters upon IBtree
     * Example: Filter IBs for WO-000000X, from external request
     */
    ibtreeImpl.Class("TransientFilter", com.servicemax.client.lib.api.Object, {
        __ibtree : null,
        __data : null,
        __alias : null,
        __checked : null,
        __checkbox : null,

        __constructor : function(params){
            this.__ibtree = params.parent;
            this.__data = params.data;
            this.__alias = this.__data.sourceRecordName;
            this.__checked = true;
        },

        initialize : function(){
            var me = this;
            this.__checkbox = SVMX.create("com.servicemax.client.installigence.ui.components.Checkbox", { 
                boxLabel : me.__alias,
                checked : true,
                margin: '0 0 0 5',
                isTransientFilter : true,
                handler : function(){
                    me.__checked = this.value;
                    if(this.value){
                        me.__uncheckOtherTransientFilters();
                        me.__ibtree.hideNodes(me.__alias);
                    }else{
                        if(!me.__ibtree.isUncheckingTransientFilters){
                            me.__ibtree.showNodes(me.__alias);
                            me.__addTransientNodeFilter(true);
                        }
                    }
                    if(me.__ibtree.__selectedNodeId){
                        me.__ibtree.selectTreeNode(me.__ibtree.__selectedNodeId);
                    }
                }
            });
            this.__ibtree.getOptionsPanel().add(this.__checkbox);
            this.__ibtree.getOptionsPanel().expand();
            this.setup();
        },

        setup : function(){
            var me = this;
            this.__addTransientNodeFilter();
            this.__uncheckOtherTransientFilters();
            this.__ibtree.hideNodes(this.__alias);
            this.__ibtree.selectTreeNode(this.__data.recordIds[0]);
        },

        setChecked : function(){
            this.__checkbox.setValue(true);
        },

        isChecked : function(){
            return this.__checked; 
        },

        getAlias : function(){
            return this.__alias; 
        },

        __addTransientNodeFilter : function(reset){
            if (!this.__transientNodeFilter || reset) {
                this.__transientNodeFilter = this.__createTransientNodeFilter()
            }
            this.__ibtree.addNodeFilter(this.__alias,
                this.__transientNodeFilter
            );
        },

        __createTransientNodeFilter : function(){
            var me = this;
            // Find applicable parent locations, sublocations and account
            this.__parentAccounts = [];
            this.__parentIBs = [];
            this.__parentLocations = [];
            this.__parentSublocations = [];
            var treeDataById = this.__ibtree.getTreeDataById();
            for(var i = 0; i < this.__data.recordIds.length; i++){
                var recordId = this.__data.recordIds[i];
                var node = treeDataById[recordId];
                findNodeParents(node);
            }
            function findNodeParents(node){
                if(!node) return;
                var parent = treeDataById[node.parentId];
                if(!parent) return;
                if(parent.nodeType === "ACCOUNT"
                    && me.__parentAccounts.indexOf(parent.id) === -1){
                    me.__parentAccounts.push(parent.id);
                    parent.expanded = true;
                }
                if(parent.nodeType === "LOCATION"
                    && me.__parentLocations.indexOf(parent.id) === -1){
                    me.__parentLocations.push(parent.id);
                    parent.expanded = true;
                }
                if(parent.nodeType === "SUBLOCATION"
                    && me.__parentSublocations.indexOf(parent.id) === -1){
                    me.__parentSublocations.push(parent.id);
                    parent.expanded = true;
                }
                if(parent.nodeType === "IB"
                    && me.__parentIBs.indexOf(parent.id) === -1){
                    me.__parentIBs.push(parent.id);
                    parent.expanded = true;
                }
                findNodeParents(parent);
            }
            return function(child){
                // Filter out all records that do not match transient tree
                if(child.nodeType === "ACCOUNT"){
                    if(me.__parentAccounts.indexOf(child.id) === -1){
                        return true;
                    }
                }
                if(child.nodeType === "LOCATION"){
                    if(me.__parentLocations.indexOf(child.id) === -1){
                        return true;
                    }
                }
                if(child.nodeType === "SUBLOCATION"){
                    if(me.__parentSublocations.indexOf(child.id) === -1){
                        return true;
                    }
                }
                if(child.nodeType === "IB"){
                    if(me.__parentIBs.indexOf(child.id) === -1 && me.__data.recordIds.indexOf(child.id) === -1){
                        return true;
                    }
                }
                return false;
            };
        },

        __uncheckOtherTransientFilters : function(){
            var transFilters = this.__ibtree.getTransientFilters();
            for(var i = 0; i < transFilters.length; i++){
                this.__ibtree.disableNodeFilter(transFilters[i].getAlias());
            }
            var optionItems = this.__ibtree.getOptionsPanel().items.items;
            this.__ibtree.isUncheckingTransientFilters = true;
            for(var i = 0; i < optionItems.length; i++){
                var checkbox = optionItems[i];
                if(!checkbox.isTransientFilter) continue;
                if(checkbox.boxLabel === this.__alias) continue;
                checkbox.setValue(false);
            }
            delete this.__ibtree.isUncheckingTransientFilters;
        }

    }, {
        // Only for testing
        testTrigger : function(){
            var data = {
                action : 'VIEW',
                // Test serials under MAccount
                recordIds : [
                    'a0HF000000Nwd7XMAR', // INROW...
                    'a0HF000000Nv0qSMAR', // MInstalled 3
                    'a0HF000000NwcSfMAJ', // Coffee machine...
                    'a0HF000000NwkmQMAR', // ArchProd11
                    'a0HF000000NwkmZMAR'  // ArchProd10
                ],
                object : SVMX.getCustomObjectName("Installed_Product"), // ???
                sourceRecordName : "WO-100000TEST1"
            };
            if(window.previouslySet){
                data.sourceRecordName = "WO-100000TEST2";
            }
            window.previouslySet = true;
            var evt = SVMX.create("com.servicemax.client.lib.api.Event", "EXTERNAL_MESSAGE", this, data);
            SVMX.getClient().triggerEvent(evt); 
        }
    });
    
};

})();

//end of file