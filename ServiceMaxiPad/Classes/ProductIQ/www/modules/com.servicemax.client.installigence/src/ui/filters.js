/**
 * 
 */

(function(){
    
    var filtersImpl = SVMX.Package("com.servicemax.client.installigence.filters");

filtersImpl.init = function(){
    
    Ext.define("com.servicemax.client.installigence.filters.Filters", {
        extend: "com.servicemax.client.installigence.ui.components.SVMXPanel",
        alias: 'widget.installigence.filters',
        meta : null,
        __checkedIndex : null,
        
        constructor: function(config) { 
            this.meta = config.meta || [];
            this.__checkedIndex = {};
            
            config = Ext.apply({
                title: $TR.FILTERS,
                ui: 'svmx-white-panel',
                cls: 'filter-region',
                layout : {type : "vbox"},
                defaults : {padding : '0 0 0 5'}
            }, config || {});
            this.callParent([config]);
            this.setup();
        },
        
        setup : function(){
            this.meta.bind("MODEL.UPDATE", function(evt){
                this.refresh();
            }, this);
        },

        refresh : function(){
            this.removeAll();
            if(!this.meta.filters || !this.meta.filters.length){
                return;
            }
            var me = this;
            var i, l = this.meta.filters.length;
            for(i = 0; i < l; i++){
                var filter = this.meta.filters[i];
                var filterName = filter.name;
                var cb = SVMX.create("com.servicemax.client.installigence.ui.components.Checkbox", {
                    boxLabel : filterName,
                    filterExpression : filter.expression,
                    inputValue : i,
                    value : me.__checkedIndex[filterName],
                    handler : function(){
                        // Index checked state so that it can be restored
                        me.__checkedIndex[this.boxLabel] = this.value;
                        me.__fireFiltersSelected();
                    }
                });
                this.add(cb);
            }
            // TODO: handle incremental state updates?
        },

        __fireFiltersSelected : function(){
            var selectedExprs = [];
            var i, l = this.items.getCount();
            for(var i = 0; i < l; i++){
                var item = this.items.getAt(i);
                if(item.checked){
                    selectedExprs.push(item.filterExpression);
                }
            }
            this.fireEvent("filters_selected", selectedExprs);
        }
    });
    
};

})();

// end of file
