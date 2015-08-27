/**
 * 
 */

(function(){
    
    var homeImpl = SVMX.Package("com.servicemax.client.installigence.home");

homeImpl.init = function(){
    
    Ext.define("com.servicemax.client.installigence.home.Home", {
        extend: "com.servicemax.client.installigence.ui.components.SVMXPanel",
        alias: 'widget.installigence.home',
        meta : null, root : null,
        __contentArea : null,
        __actions : null,
        __menu : null,
        
        constructor: function(config) { 
            
            this.meta = config.meta;
            this.root = config.root;
            /*
            var filters = SVMX.create("com.servicemax.client.installigence.filters.Filters", {
                region: 'west', collapsed: true, collapsible: true, split: false, width: 200, meta : this.meta
            });
			*/
            
            var contentarea = SVMX.create("com.servicemax.client.installigence.contentarea.ContentArea", {
                region: 'center', collapsible: false, floatable: false, split: false, meta : this.meta
            });
            
            var actions = SVMX.create("com.servicemax.client.installigence.actions.Actions", {
                region: 'east', collapsed: false, split: false, width: 200, floatable: true, meta : this.meta,
                contentarea : contentarea
            });
            
            // Prevent context menu
            Ext.getDoc().on('contextmenu', function(e){
                e.preventDefault();
            });

            var me = this;
            config = Ext.apply({
                title: '<span class="title-text">ProductIQ</span> <div class="logo img"/></div> <div class="logo spinner" style="background-image: none"/></div>',
                titleAlign: 'center', 
                frame: 'true',
                collapsible : false,
                style: 'margin:10px',
                height : SVMX.getWindowInnerHeight() - 40,
                toolPosition: 0,
                tools: [{
                    type:'hamburger',
                    cls: 'hamburger',
                    handler: function(e, el, owner, tool){
                        if(!me.__showingMenu){
                            me.__showingMenu = true;
                            me.getMenu(owner).showBy(owner,'tl-bl?');
                        }else{
                            me.__showingMenu = false;
                            me.getMenu(owner).hide();
                        }
                    }
                }],
                layout: {
                    type: 'border',
                    padding: '3'
                },
                defaults: {
                    collapsible: true,
                    split      : true
                },
                items : [ contentarea, actions ]
            }, config || {});
            
            this.__contentArea = contentarea;
            this.__actions = actions;

            this.__bindSyncEvents();

            this.callParent([config]);
        },

        __bindSyncEvents : function(){
            var syncService = SVMX.getClient().getServiceRegistry()
            .getService("com.servicemax.client.installigence.sync").getInstance();
            syncService.bind("SYNC.STATUS", function(evt){
                var status = evt.data.type;
                var message = evt.data.msg;
                var syncType = evt.data.syncType;
                if(status === "start"){
                    this._disableMenuItem($TR.SYNC_DATA);
                }else if(status === "complete" || status === "canceled"){
                    this._enableMenuItem($TR.SYNC_DATA);
                }
            }, this);
        },
        
        getMenu : function(){
            var me = this;
            if (!me.__menu) {
                me.__menu = SVMX.create('com.servicemax.client.installigence.ui.components.Menu', {
                    cls: 'svmx-nav-menu',
                    plain: true,
                    height: '80%',
                    items: [
                            {text: $TR.FIND_AND_GET, handler : function(){
                                me._handleFindAndGet({syncType : "ib"});
                            }},
                            {text: $TR.SYNC_CONFIG, handler : function(){
                                me._handleConfigSync();
                            }},
                            {text: $TR.SYNC_DATA, handler : function(){
                                me._handleIncrementalSync();
                            }},
                            // TODO: $TR.SYNC_CONFLICTS
                            {text: "Sync Conflicts", handler : function(){
                                me._showSyncConflicts();
                            }},
                            {text: "Purge Data", handler : function(){
                                me._handlePurgeSync();
                            }},
                            {text: $TR.RESET_APPLICATION_TITLE, handler : function(){
                                me._handleResetApplication();
                            }}
                    ]
                });
            }
            return me.__menu;
        },

        _disableMenuItem : function(menuText){
            var items = this.getMenu().items.items;
            for(var i = 0; i < items.length; i++){
                if(items[i].text === menuText){
                    items[i].disable();
                    break;
                }
            }
        },

        _enableMenuItem : function(menuText){
            var items = this.getMenu().items.items;
            for(var i = 0; i < items.length; i++){
                if(items[i].text === menuText){
                    items[i].enable();
                    break;
                }
            }
        },
        
        _handleResetApplication : function(){
            this.root.handleResetApplication();
        },
        
        _handleFindAndGet : function(){
            this.root.handleFindAndGet();
        },

        _handleConfigSync : function(){
            this.root.handleConfigSync();
        },

        _handleIncrementalSync : function(){
            this.root.handleIncrementalSync();
        },

        _handlePurgeSync : function(){
            this.root.handlePurgeSync();
        },

        _showSyncConflicts : function(){
            this.root.showSyncConflicts();
        },
        
        handleFocus : function(params){
            this.__contentArea.refreshContent(params);
        },

        selectTreeNode : function(recordId){
            this.__contentArea.selectTreeNode(recordId);
        }
    });
};

})();

// end of file
