(function(){
	var cellEditors = SVMX.Package("com.servicemax.client.installigence.admin.celleditors");

cellEditors.init = function() {
	
	Ext.define("com.servicemax.client.installigence.admin.celleditors.SVMXComboBoxCellEditor", {
        extend: "com.servicemax.client.installigence.ui.components.SVMXComboBox",
        constructor: function(config) {
        	this.callParent([config]);
        },
        
        setRecord : function(record){
        	this.__record = record;
        },
        
        setValue : function(value){
        	if(this.__record && this.__record.data[this.fieldName + "_key"]){
				value = this.__record.data[this.fieldName + "_key"];
			}
			this.callParent([value]);
        },
        
        getValue : function(){
        	if(!this.__record) return null;
        	var value = this.callParent();
        	var displayValue = "";						
        	if(this.findRecordByValue(value)){
				displayValue = this.findRecordByValue(value).get(this.displayField);
			}
        	this.__record.data[this.fieldName + "_key"] = value;
			return displayValue;
        }
	});
}
})();