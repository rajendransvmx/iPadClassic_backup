(function(){
	var root = SVMX.Package("com.servicemax.client.installigence.admin.root");

root.init = function() {		
	
		Ext.define("com.servicemax.client.installigence.admin.root.RootPanel", {
			extend : "com.servicemax.client.installigence.ui.components.SVMXPanel", 
			constructor : function(config){
				config = config || {};
				config.renderTo = SVMX.getDisplayRootId();		        
				config.title = "<span class='title-text'>" + $TR.SETUP_TITLE + "</span>";
				
				var me = this;
				me.userActions = SVMX.create('com.servicemax.client.installigence.admin.UserActions',{
					metadata: config.metadata
				});

				me.dataValidationRules = SVMX.create('com.servicemax.client.installigence.admin.DataValidationRules',{
					metadata: config.metadata
				});
				
				me.productTemplates = SVMX.create('com.servicemax.client.installigence.admin.ProductTemplates',{
					metadata: config.metadata
				});
				
				me.otherSettings = SVMX.create('com.servicemax.client.installigence.admin.OtherSettings',{
					metadata: config.metadata,
					hidden : true
				});
				
									
				me.tabPanel = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXTabPanel',{
					height: 550,
					tabPosition: 'left',
					tabRotation: 0,
					tabBar: {
						border: false
					},
					margin: '4 4 0 4',
					ui: 'setup-tabpanel',
					defaults: {
						textAlign: 'left',
						bodyPadding: 7
					}});
				me.tabPanel.add(me.userActions);
				me.tabPanel.add(me.dataValidationRules);
				me.tabPanel.add(me.productTemplates);
				me.tabPanel.add(me.otherSettings);					
				me.tabPanel.setActiveTab("UF");
				
				me.saveButton = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXButton',{
					text: "Save",
					handler : function(){
						me.onSave();
					}
				});
				
				me.closeButton = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXButton',{
					text: "Close"
				});
				
				me.saveCloseButton = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXButton',{
					text: "Save & Close"
				});
				
				me.savencloseToolbar = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXToolbar',{
					style: 'border-top-width: 0 !important',
					margin: '0 4 5',
					
	            });
				me.savencloseToolbar.add('->');
				me.savencloseToolbar.add(me.saveCloseButton);
				me.savencloseToolbar.add(me.saveButton);
				me.savencloseToolbar.add(me.closeButton);
				
				config.items = [];
				config.items.push(me.tabPanel);
				config.items.push(me.savencloseToolbar)
	            this.callParent([config]);
			},
			
			onSave: function() {
				if(this.productTemplates.validateForm() == false) return false;						
				
				//persist the existing configuration
				this.__persistScreenConfiguration();
				var profiles = this.userActions.showProfiles.getRecords() || [];
				var profilesFinal = [];
				var iProfiles = 0, iProfielsLength = profiles.length;
				
				for(iProfiles = 0; iProfiles < iProfielsLength; iProfiles++) {
					if(profiles[iProfiles].profileId === "--None--") continue;
					profiles[iProfiles].actions = this.__removeIdProperty(profiles[iProfiles].actions);
					profiles[iProfiles].filters = this.__removeExtPropertiesExpr(profiles[iProfiles].filters);
					profilesFinal.push(profiles[iProfiles]);
				}
				
				profilesFinal.push({profileId: "global", actions: this.__removeIdProperty(this.userActions.globalActions)
								, filters: this.__removeExtPropertiesExpr(this.userActions.globalFilters)});
				
				var productTemplates = this.productTemplates.showTemplates.getRecords() || [];
				var productTemplateFinal = [];
				var templlength = productTemplates.length, iTemplates = 0;
				for(var iTemplates = 0; iTemplates < templlength; iTemplates++) {
					if(productTemplates[iTemplates].templateId === "--None--") {
						if(productTemplates[iTemplates].isNew && productTemplates[iTemplates].template
								&&  productTemplates[iTemplates].template.children[0] && productTemplates[iTemplates].template.children[0].templateDetails &&
								productTemplates[iTemplates].template.children[0].templateDetails.templateId) {
							delete productTemplates[iTemplates]["isNew"];
						}else {
							continue;
						}
					}
					
					var templateDet = productTemplates[iTemplates].template.templateDetails ? 
							productTemplates[iTemplates].template.templateDetails : productTemplates[iTemplates].template.children[0].templateDetails;
					
					productTemplates[iTemplates].templateId =  templateDet.templateId;
					productTemplates[iTemplates].templateName = templateDet.templateName;					
					if(productTemplates[iTemplates].template) {
						productTemplates[iTemplates].template = this.__removeExtPropertiesProd(productTemplates[iTemplates].template);						
					}
					productTemplateFinal.push(productTemplates[iTemplates]);
				}				
				
				this.blockUI();
				var me = this;
		       	var evt = SVMX.create("com.servicemax.client.lib.api.Event",
								"INSTALLIGENCEADMIN.SAVE_SETUP_DATA", me,
								{request : { context : me, profiles: profilesFinal, ibTemplates: productTemplateFinal, delTemplateIds: this.productTemplates.deletedTemplateIds}});
		       	SVMX.getCurrentApplication().getEventBus().triggerEvent(evt);
				
			},
	        
	        blockUI : function(){
	        	var opts = {
	        			  lines: 25, // The number of lines to draw
	        			  length: 25, // The length of each line
	        			  width: 5, // The line thickness
	        			  radius: 30, // The radius of the inner circle
	        			  corners: 1, // Corner roundness (0..1)
	        			  rotate: 0, // The rotation offset
	        			  direction: 1, // 1: clockwise, -1: counterclockwise
	        			  color: '#ffa384', // #rgb or #rrggbb or array of colors
	        			  speed: 3, // Rounds per second
	        			  trail: 60, // Afterglow percentage
	        			  shadow: false, // Whether to render a shadow
	        			  hwaccel: false, // Whether to use hardware acceleration
	        			  className: 'spinner', // The CSS class to assign to the spinner
	        			  zIndex: 2e9 // The z-index (defaults to 2000000000)
	        			};
	        			
	        	this.__spinner = new Spinner(opts).spin($("#" + SVMX.getDisplayRootId())[0]);
	        },
	        
	        unblockUI : function(){
	        	this.__spinner.stop();
	        },
			
			__persistScreenConfiguration: function() {				
				
				if(this.userActions.showProfiles.getSelectedRecord()) {
					//Store actions
					this.userActions.__persistUserActions(this.userActions.showProfiles.getSelectedRecord());
					this.userActions.__persistUserStdActions(this.userActions.showProfiles.getSelectedRecord());
					
					this.dataValidationRules.__persistDataValidationRules(this.dataValidationRules.showProfiles.getSelectedRecord());
					//persist expression
					var selectedExpr = this.userActions.filters.filtersSearchGrid.selectedExpression;
					if(selectedExpr) {
						this.userActions.filters.__persistExpression(selectedExpr);
					}
					//Store filters
					this.userActions.__persistFilters(this.userActions.showProfiles.getSelectedRecord());
				}			
				
				//store product node data
				var selectedRecord = this.productTemplates.templateTree.getSelectionModel().getSelection()[0];
				this.productTemplates.__persistProductData(selectedRecord);
				
				//store template data
				var selectedTemplate = this.productTemplates.showTemplates.selectedTemplate;
				if(selectedTemplate) {
					this.productTemplates.__persistTemplate(selectedTemplate);
				}
				
			},
			
			onSaveSetupDataComplete: function(records) {
				this.unblockUI();
				
				var me = this;
		       	var evt = SVMX.create("com.servicemax.client.lib.api.Event",
								"INSTALLIGENCEADMIN.GET_SETUP_METADATA", me,
								{request : { context : me}});
		       	
		       	SVMX.getCurrentApplication().getEventBus().triggerEvent(evt);				
		       	
			},
			
	        onGetSetupMetadataComplete: function(records) {
	        	
	        	var sforceObjectDescribes = records.sforceObjectDescribes;
	        	
	        	for(var iObjectCount = 0; iObjectCount < sforceObjectDescribes.length; iObjectCount++) {
	        		records[sforceObjectDescribes[iObjectCount].objectAPIName] = sforceObjectDescribes[iObjectCount];
	        	}
	        	
	        	var profilesData = [{profileId: "--None--", profileName: $TR.NONE}];
				var profiles = records.svmxProfiles;
				var iSerProfiles = 0; iSerLength = profiles.length;
				for(iSerProfiles = 0; iSerProfiles < iSerLength; iSerProfiles++){
					if(profiles[iSerProfiles].profileId !== 'global'){
						profilesData.push(profiles[iSerProfiles])
					}else {
						this.userActions.globalActions = profiles[iSerProfiles].actions;
						this.userActions.globalFilters = profiles[iSerProfiles].filters;
					}
				}
				this.userActions.showProfiles.getStore().loadData(profilesData);
				
				
				var templatesData = [{templateId: "--None--", templateName: $TR.NONE}];
				templatesData =	templatesData.concat(records.ibTemplates);				
				this.productTemplates.showTemplates.getStore().loadData(templatesData);
	        	
	        },
			
			__removeIdProperty: function(records) {
				for(var rec in records) {
					delete records[rec]["id"];
				}
				return records;				
			},
			
			__removeExtPropertiesExpr: function(records) {
				for(var rec in records) {
					delete records[rec]["id"];
					if(records[rec].expression && records[rec].expression.children) {
						var childrenLoc = records[rec].expression.children;
						childrenLoc = this.__isArray(childrenLoc) ? childrenLoc[0] : childrenLoc;
						records[rec]["expression"] = {children: [this.__getExpressionChildNodes(childrenLoc)]};
					}
					
				}
				return records;	
			},
			
			__isArray: function(myArray) {
			    return myArray.constructor.toString().indexOf("Array") > -1;
			},
			
	        __getExpressionChildNodes: function(node) {
	    	   
	    	    var rec = {};
	    	    if(node !== undefined) {	    	    	
		    	    rec.operator = node.operator;
		    	    rec.exprType = node.exprType;
		    	    rec.field = node.field;
		    	    rec.condition = node.condition;
		    	    rec.value = node.value;
		    	    if(node.children && node.children.length > 0){
		    		    rec.children = [];
			    	    var children = node.children || [], i, l = children.length;
			    	    for(i = 0; i < l; i++){
			    		    rec.children.push(this.__getExpressionChildNodes(children[i]));
			    	    }
		    	    }
		    	   
	    	    }
	    	    return rec;	    	   
	        },
			
			__removeExtPropertiesProd: function(records) {
				
				var rec = {};
				if(records && records.children) {
					rec = this.__getProductChildNodes(records.children[0]);
				}				
				return rec;	
			},
			
	        __getProductChildNodes: function(node) {
	    	   
	    	    var rec = {};
	    	    if(node !== undefined && node != null) {	    	    	
		    	    rec.text = node.text;
		    	    rec.type = node.type;
		    	    rec.product = node.product;
		    	    //remove ext properties of product configuraton
		    	    if(rec.product && rec.product.productConfiguration) {
		    	    	rec.product.productConfiguration = this.__removeIdProperty(rec.product.productConfiguration)
		    	    }
		    	    rec.templateDetails = node.templateDetails;
		    	    
		    	    if(node.children && node.children.length > 0){
		    		    rec.children = [];
			    	    var children = node.children || [], i, l = children.length;
			    	    for(i = 0; i < l; i++){
			    		    rec.children.push(this.__getProductChildNodes(children[i]));
			    	    }
		    	    }		    	   
	    	    }
	    	    return rec;	    	   
	        }
			   
			
		});	
	}
})();