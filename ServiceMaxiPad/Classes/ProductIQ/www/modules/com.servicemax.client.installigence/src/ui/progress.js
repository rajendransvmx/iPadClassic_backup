/**
 * 
 */

(function(){
    var progressImpl = SVMX.Package("com.servicemax.client.installigence.progress");
    
progressImpl.init = function(){
    
    Ext.define("com.servicemax.client.installigence.progress.Progress", {
        extend: "com.servicemax.client.installigence.ui.components.SVMXPanel",
        alias: 'widget.installigence.progress',
        meta : null, root : null, __bar : null, __stepCount : 0, __carousel : null,
        
        constructor: function(config) { 
            this.meta = config.meta;
            this.root = config.root;

            this.__bar = SVMX.create("com.servicemax.client.installigence.ui.components.SVMXProgressBar", {width : "100%"});
            this.__carousel = SVMX.create("com.servicemax.client.installigence.ui.components.SVMXCarousel", {
                width : "100%", flex : 1
            });

            var content = "", i, l = 2;
            var module = com.servicemax.client.installigence.impl.Module.instance;
            for(i = 0; i < l; i++){
                content += 
                '<div><img style="width:75%;display:block;margin-left:auto;margin-right:auto;" src="' 
                + module.getResourceUrl("progress/img0" + i + ".png") + '"/></div>';
            }
            
            this.__carousel.setContent(content);
            
            this.__stepCount = 0;
            
            config = Ext.apply({
                titleAlign: 'center', 
                frame: 'true',
                collapsible : false,
                style: 'margin:10px',
                height : SVMX.getWindowInnerHeight() - 40,
                toolPosition: 0,
                items : [this.__bar, this.__carousel],
                layout : { type : "vbox"},
                defaults : {margin : '20 20 20 20'}
            }, config || {});
            
            this.callParent([config]);
            
            // register for sync events
            var syncService = SVMX.getClient().getServiceRegistry()
            .getService("com.servicemax.client.installigence.sync").getInstance();
            syncService.bind("SYNC.STATUS", function(evt){
                
                if(evt.data.type == "start" && (evt.data.syncType == "initial" || evt.data.syncType == "reset" || evt.data.syncType == "config")){
                    this.__stepCount = -1;
                    this.__updateStep(syncService.totalStepCount, "");
                }else if(evt.data.type == "step"){
                    this.__updateStep(syncService.totalStepCount, evt.data.msg);
                }
            }, this);
            // end sync events
        },
        
        __updateStep : function(totalCount, message){
            this.__stepCount++;
            this.__bar.updateProgress(this.__stepCount/totalCount, message, true);
        },
        
        handleFocus : function(params){
            var title = "";
            if(params.syncType == "initial" || params.syncType == "reset"){
                title = $TR.PREPARING_APP_MESSAGE + "...";
            }else if(params.syncType == "config"){
                title = $TR.UPDATING_CONFIG_MESSAGE + "...";
            }else if(params.syncType == "ib"){
                title = $TR.DOWNLOAD_SELECTED_IB_MESSAGE + "...";
            }
            this.setProgressTitle(title);
        },
        
        setProgressTitle : function(title){
            title = '<span class="title-text">' + (title || '') + '</span></div>';
            this.setTitle(title);
        }
    });
};
})();

// end of file