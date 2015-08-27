
(function(){
	
	SVMX.OrgNamespace = SVMX.getClient().getApplicationParameter("org-name-space") || "SVMXC";
	SVMX.getCustomFieldName = function(name){ return SVMX.OrgNamespace + "__" + name + "__c"; };
	SVMX.getCustomObjectName = function(name){ return SVMX.OrgNamespace + "__" + name + "__c"; };
	SVMX.getCustomRelationName = function(name){ return SVMX.OrgNamespace + "__" + name + "__r"; };
	SVMX.appType = SVMX.getClient().getApplicationParameter("app-type") || "independent";
	var instImpl = SVMX.Package("com.servicemax.client.installigence.impl");

	instImpl.Class("Module", com.servicemax.client.lib.api.ModuleActivator, {
		__constructor : function(){
			this.__base();
			instImpl.Module.instance = this;
		},

		initialize : function(){
			com.servicemax.client.installigence.root.init();
			com.servicemax.client.installigence.filters.init();
			com.servicemax.client.installigence.actions.init();
			com.servicemax.client.installigence.documents.init();
			com.servicemax.client.installigence.topography.init();
			com.servicemax.client.installigence.configuration.init();
			com.servicemax.client.installigence.record.init();
			com.servicemax.client.installigence.ibtree.init();
			com.servicemax.client.installigence.home.init();
			com.servicemax.client.installigence.progress.init();
			com.servicemax.client.installigence.findandget.init();
			com.servicemax.client.installigence.contentarea.init();
			com.servicemax.client.installigence.commands.init();
			com.servicemax.client.installigence.ui.comps.init();
			com.servicemax.client.installigence.lookup.init();
			com.servicemax.client.installigence.objectsearch.init();
			com.servicemax.client.installigence.conflict.init();
			com.servicemax.client.installigence.loadselectedib.init();
			com.servicemax.client.installigence.utils.init();
			
		},
		
		afterInitialize : function(){
			
		}
	}, {
		instance : null
	});
	
	instImpl.Class("EventBus", com.servicemax.client.lib.api.EventDispatcher, {
		__constructor : function(){ this.__base(); }
	}, {
		__instance : null,
		getInstance : function(){
			if(!instImpl.EventBus.__instance){
				instImpl.EventBus.__instance = SVMX.create("com.servicemax.client.installigence.impl.EventBus", {});
			}
			return instImpl.EventBus.__instance;
		}
	});
})();