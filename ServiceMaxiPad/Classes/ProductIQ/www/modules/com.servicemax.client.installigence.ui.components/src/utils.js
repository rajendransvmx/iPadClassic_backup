/**
 * 
 */

(function(){
	
	var utilsImpl = SVMX.Package("com.servicemax.client.installigence.ui.components.utils");
	
	utilsImpl.Class("Utils", com.servicemax.client.lib.api.Object, {}, {
		
		confirm : function(params){
			var buttons = Ext.Msg.YESNO;
			if(params.showCancel) buttons = Ext.Msg.YESNOCANCEL;
			
			var icon = Ext.Msg.QUESTION;
			
			Ext.Msg.show({
			    title:params.title, message: params.message, buttons: buttons, icon: icon,
			    buttonText : params.buttonText,
			    fn: function(btn) {
			        params.handler(btn);
			    }
			});
		}
	});
})();

// end of file