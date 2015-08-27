/**
 * 
 */

(function(){
	var compsImpl = SVMX.Package("com.servicemax.client.installigence.ui.comps");

compsImpl.init = function(){
	
	Ext.define("com.servicemax.client.installigence.ui.comps.StringField", {
        extend: "com.servicemax.client.installigence.ui.components.SVMXTextField",
        alias: 'widget.inst.stringfield',
        
        constructor: function(config) {	
       	 	
       	 	var me = this;
       	 	config.fld.getBinding().setter = function(value){
       	 		me.setValue(value);
	       	};
	       	
	       	config.fld.getBinding().getter = function(){
       	 		return me.getValue() || "";
	       	};
	       	
	       	this.callParent([config]);       	 	
	       	config.fld.register(this);
	       	
        }
    });
	
	Ext.define("com.servicemax.client.installigence.ui.comps.BooleanField", {
        extend: "com.servicemax.client.installigence.ui.components.Checkbox",
        alias: 'widget.inst.booleanfield',
        
        constructor: function(config) {	
       	 	
       	 	var me = this;
       	 	config.fld.getBinding().setter = function(value){
       	 		me.setValue(value);
	       	};
	       	
	       	config.fld.getBinding().getter = function(){
       	 		return me.getValue();
	       	};
	       	this.callParent([config]);
       	 	
	       	config.fld.register(this);
        }
    });
	
	Ext.define("com.servicemax.client.installigence.ui.comps.ReferenceField", {
        extend: "com.servicemax.client.installigence.lookup.Container", 
        alias: 'widget.inst.fieldcontainer',
        	
        constructor: function(config) {	
        	var me = this;        	
       	    config.items = [];
       	    config.objectName = config.fld.referenceTo[0];
       	    
       	    config.columns = (config.objectName == "Product2" && config.meta.productDisplayFields) 
       	    									?  config.meta.productDisplayFields : [{name: 'Name'}];
       	    config.searchColumns = (config.objectName == "Product2" && config.meta.productDisplayFields) 
												?  config.meta.productSearchFields : [{name: 'Name'}];
       	    config.mvcEvent = "GET_RECORDS";
       	    
       	          	    
       	    this.callParent([config]);
       	    if(config.fld._parent.__objectName !== SVMX.getCustomObjectName("Installed_Product")) {       	    	
       	    	this.makeReadOnly();
       	    } 
       	 	
       	 	//now value setter and getters       	 	
       	 	config.fld.getBinding().setter = function(value){
       	 		me.setValue(value);
	       	};
	       	
	       	config.fld.getBinding().getter = function(){
    	 		  return me.getValue() || "";
	       	};

          config.fld.getBinding().name = function(){
            return me.getLookupText().getValue() || "";
          };
	          	
	       	config.fld.register(this.getLookupText());     	 	
       	 	
        }
    });
	
	Ext.define("com.servicemax.client.installigence.ui.comps.PicklistField", {
        extend: "com.servicemax.client.installigence.ui.components.SVMXComboBox",
        alias: 'widget.inst.picklistfield',
        
        constructor: function(config) {	
       	 	
        	var lov = config.fld.getListOfValues(), l = lov.length, i, values = [];
       	 	if(!config.fld.dependentPickList){
		    	for(i = 0; i < l; i++){
		   	 		values.push({value : lov[i].value, display : lov[i].label});
		   	 	}
       	 	}	
        	
       	 	
       	 	var store = SVMX.create('com.servicemax.client.ui.components.composites.impl.SVMXStore', 
       	 			{fields: ['display', 'value'], data : values});
       	 	
       	 	config = Ext.apply({
				store : store,
				queryMode: 'local',
			    displayField: 'display',
			    valueField: 'value',
       	 	}, config || {});
       	 
       	 	var me = this;
       	 	config.fld.getBinding().setter = function(value){
	       		me.setValue(value);
       	 	};
       	 	
       	 	config.fld.getBinding().getter = function(){
    	 		return me.getValue() || "";
	       	};

	       	config.fld.getBinding().updateStore = function(store){
    	 		if(store.length > 0){
    	 			me.store.loadData(store);
    	 		}
    	 		else{
    	 			me.store.loadData([],false);
    	 		}
	       	};
	       	
	       	this.callParent([config]);
	       	config.fld.register(this);       	
        }
    });
	
	Ext.define("com.servicemax.client.installigence.ui.comps.DateField", {
        extend: "com.servicemax.client.ui.components.controls.impl.SVMXDate",
        alias: 'widget.inst.datefield',
        
        constructor: function(config) {	
       	 	
       	 	config = Ext.apply({
				
       	 	}, config || {});
       	 
       	 	var me = this;
       	 	config.fld.getBinding().setter = function(value){
	       		me.setValue(value);
       	 	};
       	 	
       	 	config.fld.getBinding().getter = function(){
       	 		var value = me.getValue() || "";	 		
       	 		if(value && value != ""){
       	 			value = Ext.Date.format(me.getValue(),"Y-m-d")
       	 		}
       	 		return value;
	       	};
	       	
	       	this.callParent([config]);
	       	config.fld.register(this);        	
        }
    });
	
	Ext.define("com.servicemax.client.installigence.ui.comps.DatetimeField", {
        extend: "com.servicemax.client.ui.components.controls.impl.SVMXDatetime",
        alias: 'widget.inst.datetimefield',
        
        constructor: function(config) {	
       	 	
       	 	config = Ext.apply({
       	 		
       	 	}, config || {});
       	 
       	 	var me = this;
       	 	config.fld.getBinding().setter = function(value){
	       		if(value && value != ""){
	       			value = value.substring(0, "yyyy-mm-ddThh:mm:ss".length).replace("T", " ");
	       			value = new Date(value + " UTC");
	       			value = value.toLocaleDateString() + "T" + value.toLocaleTimeString();
	       		}
       	 		me.setValue(value);
       	 	};
       	 	
       	 	config.fld.getBinding().getter = function(){
       	 		var value = me.getValue() || "";
       	 		var actValue = value;
       	 		if(value && value != ""){
       	 			value = new Date(value);
       	 			value = new Date(value.getTime() + (value.getTimezoneOffset() * 60000))
       	 			value = value.toISOString();
       	 			value = value.substring(0, value.length - 1);
       	 			value = value + "+0000";
       	 		}
    	 		return value;
	       	};
	       	
	       	this.callParent([config]);
	       	config.fld.register(this.getDateField());
	       	config.fld.register(this.getTimeField());        	
        }
    });
};

})();

// end of file