/**
 * 
 */

(function(){
	
	var translationImpl = SVMX.Package("com.servicemax.client.installigence.utils.translation");
	
	translationImpl.Class("Translation", com.servicemax.client.lib.api.Object, {
		__d : null,
		__constructor : function(){
			this.__base();
			this.FIND_AND_GET = "FIND_AND_GET";
			this.FILTERS = "FILTERS";
			this.ACTIONS = "ACTIONS";
			this.RECORD_VIEW_TITLE = "RECORD_VIEW_TITLE";
			this.SHOW_LOCATIONS = "SHOW_LOCATIONS";
         	this.SHOW_SWAPPED_PRODUCTS = "SHOW_SWAPPED_PRODUCTS";
         	this.SHOW_DISABLED_ACTIONS = "SHOW_DISABLED_ACTIONS";
			this.ADD_NEW_INSTALLED_PRODUCT = "ADD_NEW_INSTALLED_PRODUCT";
			this.ADD_NEW_LOCATION = "ADD_NEW_LOCATION";
			this.ADD_NEW_SUB_LOCATION = "ADD_NEW_SUB_LOCATION";
			this.SYNC_CONFIG = "SYNC_CONFIG";
			this.SYNC_DATA = "SYNC_DATA";
			this.SYNC_STATUS = "SYNC_STATUS";
			this.RESET_APPLICATION_TITLE = "RESET_APPLICATION_TITLE";
			this.RESET_APPLICATION_MESSAGE = "RESET_APPLICATION_MESSAGE";
			this.RESET_YES = "RESET_YES";
			this.RESET_NO = "RESET_NO";
			this.SEARCH = "SEARCH";
			this.FIND_BY_IB = "FIND_BY_IB";
			this.FIND_BY_TEMPLATE = "FIND_BY_TEMPLATE";
			this.FIND_BY_PRODUCT = "FIND_BY_PRODUCT";
			this.GET = "GET";
        	this.FIND_ATTRIBUTE = "FIND_ATTRIBUTE";
        	this.INSTALLED_PRODUCT_ID_LABEL = "INSTALLED_PRODUCT_ID_LABEL";
        	this.ACCOUNT_LABEL = "ACCOUNT_LABEL";
        	this.CONTACT_LABEL = "CONTACT_LABEL";
        	this.STATUS_LABEL = "STATUS_LABEL";
        	this.DATE_INSTALLED_LABEL = "DATE_INSTALLED_LABEL";
        	this.PREPARING_APP_MESSAGE = "PREPARING_APP_MESSAGE";
        	this.DOWNLOAD_SELECTED_IB_MESSAGE = "DOWNLOAD_SELECTED_IB_MESSAGE";
        	this.UPDATING_CONFIG_MESSAGE = "UPDATING_CONFIG_MESSAGE";
        	this.FIELD_UPDATE_APPLIED_MESSAGE = "FIELD_UPDATE_APPLIED_MESSAGE";
        	this.DELETE_CONFIRM_MESSAGE = "DELETE_CONFIRM_MESSAGE";
        	this.DELETE_ERROR_MESSAGE = "DELETE_CONFIRM_MESSAGE";
        	this.MESSAGE_INFO = "MESSAGE_INFO";
        	this.MESSAGE_SUCCESS = "MESSAGE_SUCCESS";
        	this.MESSAGE_ERROR = "MESSAGE_ERROR";
        	this.MESSAGE_CONFIRM = "MESSAGE_CONFIRM";
        	this.MESSAGE_IB_NOT_EXISTS = "MESSAGE_IB_NOT_EXISTS";
		},
		
		refresh : function(){
			this.__d = $.Deferred();
			
			var evt = SVMX.create("com.servicemax.client.lib.api.Event",
					"INSTALLIGENCE.GET_TRANSLATIONS", this, 
					{request : {context : this, handler : this.__refreshComplete}});
			com.servicemax.client.installigence.impl.EventBus.getInstance().triggerEvent(evt);
			
			return this.__d;
		},
		
		__refreshComplete : function(data, params){
			var i, l = data.length;
			for(i = 0; i < l; i++){
				this[data[i].Key] = data[i].Text;
			}
			this.__d.resolve();
		}
	}, {});
})();

// end of file