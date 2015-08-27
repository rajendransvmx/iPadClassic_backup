/**
 * 
 */

(function(){
    
    var loadselectedibImpl = SVMX.Package("com.servicemax.client.installigence.loadselectedib");

loadselectedibImpl.init = function(){
    loadselectedibImpl.Class("LoadSelectedIB", com.servicemax.client.lib.api.Object, {
    __selectedIB : null, __parent : null, __root : null, __parentIBs : null, __accountNode : null,
    __ibtree : null, __treeDataById : null,
    
    __constructor : function(options){
        this.__root = options.root;
        this.__parent = options.parent;
        this.__ibtree = options.parent.getTree();
        this.__treeDataById = options.parent.getTreeDataById();
        this.__callback = options.callback || function(){};
        this.__selectedFirst = null;

        var loadingMore = false;
        for(var i = 0; i < options.selectedIB.recordIds.length; i++){
            var recordId = options.selectedIB.recordIds[i];

            var ibNode = this.__ibtree.getStore().getNodeById(recordId);
            if (ibNode != null) {
                // Only select the first path
                if (this.__selectedFirst !== true) {
                    this.__selectedFirst = true;
                    this.__parent.fireEvent("node_selected", ibNode.data);
                    this.__ibtree.selectPath(ibNode.getPath());
                }
                continue;
            }
            loadingMore = true;
            var evt = SVMX.create("com.servicemax.client.lib.api.Event",
                "INSTALLIGENCE.GET_ALL_PARENT_IBS", this, {
                    request : { context : this, params : {}, record : {Id : recordId}, 
                        handler : function(data){}
                        }
                });
            com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
        }
        if(!loadingMore){
            this.__callback();
        }
    },
        
    onAllParentIBsComplete : function(data) {
        if (data == null || data.length == 0) {
            if (this.__parent.__selectFromExternal) {
                SVMX.getCurrentApplication().showQuickMessage("Info", $TR.MESSAGE_IB_NOT_EXISTS);
                delete this.__parent.__selectFromExternal;
            }
        } else {
            this.traverseNodes(data);
        }
    },
    
    traverseNodes : function (data) {
        var rec = data.pop();
        var ibNode = this.__ibtree.getStore().getNodeById(rec.ids);
        if (!ibNode) {
            this.__callback();
            return;
        }
        var parentNode = this.__treeDataById[ibNode.id];
        if (data.length == 0 && this.__selectedFirst !== true) {
            this.__selectedFirst = true;
            this.__parent.fireEvent("node_selected", ibNode.data);
            this.__ibtree.selectPath(ibNode.getPath());
            this.__callback();
            return;
        }
        // Children are already loaded. Lazy loading is not required.
        if (parentNode != null && parentNode.allIBsLoaded == true) {
            this.traverseNodes(data);
        }
        this.__parent.on("node_loaded", function(input) {
                this.traverseNodes(data);
        }, this, {single : true});
        ibNode.expand(false);
    }
            
    }, {});
    
};

})();

// end of file