(function(){
	var setupUserActions = SVMX.Package("com.servicemax.client.installigence.admin.useractions");

setupUserActions.init = function() {
		
		Ext.define("com.servicemax.client.installigence.admin.userStandardActionsGrid", {
			extend: "com.servicemax.client.installigence.ui.components.SVMXGrid",
			
			constructor: function(config){
				var me = this;
				var config = config || {};
				config.viewConfig = {
		    	        
	    	        getRowClass: function(record, index) {
	    	        }
	    	    };
				config.columns = [];
				var me = this;
				config.columns.push(this.createCheckBoxColumn({text: $TR.HIDE_STANDARD_ACTIONS, dataIndex: 'isHidden'}));
				config.columns.push(this.createTextBoxColumn({text: $TR.UAF_GRID_COL_NAME, dataIndex: 'name', width:200, flex: 1, listeners : config.nameFieldListner}));
				config.columns.push(this.createTextBoxColumn({text: $TR.UAF_GRID_COL_ACTION, dataIndex: 'action', width:200, flex: 1, listeners : config.nameFieldListner}));
				this.callParent([config]);
			},
			createCheckBoxColumn: function(fieldInfo) {
		    	   var me = this;
		    	   fieldInfo = fieldInfo || {};
		    	   fieldInfo.xtype = 'checkcolumn';
		    	   fieldInfo.menuDisabled = true;
		    	   fieldInfo.sortable = false;
		    	   fieldInfo.renderer = function(value, meta, record){
		    		   return (new Ext.ux.CheckColumn()).renderer(value);
		           };
		           fieldInfo.listeners = { 
		        		   beforecheckchange  : function( component, rowIndex, checked, eOpts ){
		        			   return true;
		           			}
			           }
		    	   return fieldInfo;
		       },
			createTextBoxColumn: function(fieldInfo) {
		    	   var me = this;
		    	   var txtboxCol = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXTextField',{
		    		   allowBlank : true,
		    		   editable : false,
		    		   listeners : fieldInfo.listeners
		    	   });
		    	   
		    	   var fieldInfo = fieldInfo || {};
		    	   fieldInfo.sortable = false;
		    	   fieldInfo.editable = true;
		    	   fieldInfo.getEditor = function(currentRecord){
		    		   return txtboxCol;
	               };
		    	   return fieldInfo;
		       },
		       createActionFieldColumn: function(fieldInfo) {
		    	   var me = this;
		    	   var valueMapData = [];
		    	   var i = 0;
		    	   var ibFieldMappingsStore = fieldInfo.valueMapStore;
		    	   
		    	   this.ibFieldMappingsComboBox = SVMX.create('com.servicemax.client.installigence.admin.celleditors.SVMXComboBoxCellEditor',{
						store: ibFieldMappingsStore,
				        displayField: 'mapName',
				        valueField: 'mapId',
				        queryMode: 'local',
				        editable: false,
				        fieldName: 'action'
		    	   });
		    	   
		    	   fieldInfo = fieldInfo || {};
		    	   fieldInfo.getEditor = function(currentRecord) {
		    		   var gridStore = me.getStore();
		    		   var currTypeValue = currentRecord.get('actionType_key');
		    		   //change this to valuefield, now comparing with display field
		    		   if(currentRecord.get('isGlobal') === true && currentRecord.get('parentProfileId') !== me.selectedProfileId) {
		    			   return "";
		    		   } else if(currTypeValue === 'fieldupdate') {
						   me.ibFieldMappingsComboBox.setRecord(currentRecord);
		    			   return SVMX.create('com.servicemax.client.installigence.ui.components.SVMXCellEditor', {
								field: me.ibFieldMappingsComboBox
	                            });
		    		   }else {
		    			   return SVMX.create('com.servicemax.client.installigence.ui.components.SVMXCellEditor', {
	                                    field: me.createTextBoxColumn()
	                                });
		    		   }
		    	   };
		    	   return fieldInfo;
		       },

		       getProfileRecords: function() {
		    	   var records = [];
		    	   this.store.each(function(rec) {          
		    			delete rec.data["id"];           		
		           		records.push(rec.data);
		    	   });
		    	   return records;
		       },
		       
		});
		
		Ext.define("com.servicemax.client.installigence.admin.userActionsGrid", {
	        extend: "com.servicemax.client.installigence.ui.components.SVMXGrid",
	        
	       constructor: function(config) {
	    	   
	    	   var me = this;
	    	   var config = config || {};
	    	   config.viewConfig = {
	    	        
	    	        getRowClass: function(record, index) {
	    	        	if (record.get('isGlobal') === true && record.get('parentProfileId') !== me.selectedProfileId) {
  		                    return 'svmx-disabled-row';
  		                }
	    	        }
	    	    };
	    	   config.columns = [
                   {
						menuDisabled: true,
						sortable: false,
						xtype: 'actioncolumn',
						width: 50,
						items: [{
									iconCls: 'delet-icon',
									tooltip: 'Delete'
								}],
						handler: function(grid, rowIndex, colIndex) {
							var gridStore = grid.getStore();
		                    var rec = gridStore.getAt(rowIndex);
		                    if (rec.get('isGlobal') === null || rec.get('isGlobal') === false 
		                    		|| (rec.get('isGlobal') === true && rec.get('parentProfileId') === me.selectedProfileId)) {
		                    	gridStore.remove(rec);
	  		                }		                    
		                },  		                
  		                renderer: function (value, metadata, record) {
  		                	if (record.get('isGlobal') === null || record.get('isGlobal') === false 
  		                			|| (record.get('isGlobal') === true && record.get('parentProfileId') === me.selectedProfileId)) {
	  		                    config.columns[0].items[0].iconCls = 'delet-icon';
	  		                } else {
	  		                    config.columns[0].items[0].iconCls = 'svmx-global-icon';
	  		                }
  		                }
                   }
               ];
	    	   var me = this;
	    	   config.columns.push(this.createTextBoxColumn({text: $TR.UAF_GRID_COL_NAME, dataIndex: 'name', width:200, flex: 1, listeners : config.nameFieldListner}));
	    	   if(!config.isFiltersGrid) {
		    	   config.columns.push(this.createComboBoxColumn({text: $TR.UAF_GRID_COL_TYPE, dataIndex: 'actionType', width:200, flex: 1, 
		    		   actionTypeStore: config.actionTypeStore}));
		    	   config.columns.push(this.createActionFieldColumn({text: $TR.UAF_GRID_COL_ACTION, sortable: false, 
		   				menuDisabled: true, dataIndex: 'action', width:200, valueMapStore: config.valueMapStore}));
	    	   }
	    	   config.columns.push(this.createCheckBoxColumn({text: $TR.UAF_GRID_COL_ISGLOBAL, dataIndex: 'isGlobal'}));
	    	   this.callParent([config]);
	       },
	       
	       createCheckBoxColumn: function(fieldInfo) {
	    	   var me = this;
	    	   fieldInfo = fieldInfo || {};
	    	   fieldInfo.xtype = 'checkcolumn';
	    	   fieldInfo.menuDisabled = true;
	    	   fieldInfo.sortable = false;
	    	   fieldInfo.renderer = function(value, meta, record){
	    		   var currTypeValue = record.get('parentProfileId');
	    		   if(record.get('isGlobal') === true && currTypeValue !== me.selectedProfileId) {
	    			   return "";
	    		   }
	    		   return (new Ext.ux.CheckColumn()).renderer(value);
	           };
	           fieldInfo.listeners = { 
        		   beforecheckchange  : function( component, rowIndex, checked, eOpts ){
        			   var row = component.getView().getRow(rowIndex),
        	            record = component.getView().getRecord(row);
        			   var currTypeValue = record.get('parentProfileId');
    	    		   if(record.get('isGlobal') === true && currTypeValue !== me.selectedProfileId) {
    	    			   return false;
    	    		   }
    	    		   return true;
           			}
	           }
	           fieldInfo.checkOnly = true;
	    	   
	    	   return fieldInfo;
	       },
	       
	       setIBFieldMappings: function(){
	    	   return this.ibFieldMappings;
	       },
	       
	       createActionFieldColumn: function(fieldInfo) {
	    	   
	    	   var me = this;
	    	   var valueMapData = [];
	    	   var i = 0;
	    	   
	    	   
	    	   var ibFieldMappingsStore = fieldInfo.valueMapStore;
	    	   
	    	   this.ibFieldMappingsComboBox = SVMX.create('com.servicemax.client.installigence.admin.celleditors.SVMXComboBoxCellEditor',{
					store: ibFieldMappingsStore,
			        displayField: 'mapName',
			        valueField: 'mapId',
			        queryMode: 'local',
			        editable: false,
			        fieldName: 'action'
	    	   });	 //com.servicemax.client.installigence.ui.components.SVMXComboBox
	    	   
	    	   fieldInfo = fieldInfo || {};
	    	   fieldInfo.getEditor = function(currentRecord) {
	    		   var gridStore = me.getStore();
	    		   var currTypeValue = currentRecord.get('actionType_key');
	    		   //change this to valuefield, now comparing with display field
	    		   if(currentRecord.get('isGlobal') === true && currentRecord.get('parentProfileId') !== me.selectedProfileId) {
	    			   return "";
	    		   } else if(currTypeValue === 'fieldupdate') {
					   me.ibFieldMappingsComboBox.setRecord(currentRecord);//.get('action_key')
	    			   return SVMX.create('com.servicemax.client.installigence.ui.components.SVMXCellEditor', {
							field: me.ibFieldMappingsComboBox
                            });
	    		   }else {
	    			   return SVMX.create('com.servicemax.client.installigence.ui.components.SVMXCellEditor', {
                                    field: me.createTextBoxColumn()
                                });
	    		   }
	    	   };
	    	   return fieldInfo;
	       },
	       
	       createTextBoxColumn: function(fieldInfo) {
	    	   var me = this;
	    	   var txtboxCol = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXTextField',{
	    		   allowBlank : true,
	    		   editable : true,
	    		   listeners : fieldInfo.listeners
	    	   });
	    	   
	    	   var fieldInfo = fieldInfo || {};
	    	   fieldInfo.sortable = false;
	    	   fieldInfo.editable = true;
	    	   fieldInfo.getEditor = function(currentRecord){
	    		   var currTypeValue = currentRecord.get('parentProfileId');
	    		   if(currentRecord.get('isGlobal') === true && currTypeValue !== me.selectedProfileId) {
	    			   return "";
	    		   }
	    		   return txtboxCol;
               };
               
	    	   return fieldInfo;
	       },
	       
	       createComboBoxColumn: function(fieldInfo) {
	    	   var me = this;
	    	   
	    	   var optionPicklist = SVMX.create('com.servicemax.client.installigence.admin.celleditors.SVMXComboBoxCellEditor',{
					displayField: 'label',
			        queryMode: 'local',
			        editable: false,
			        valueField: 'value',
			        fieldName: 'actionType',
			        store: fieldInfo.actionTypeStore
	    	   });	    	   
	    	   
	    	   var fieldInfo = fieldInfo || {};
	    	   fieldInfo.menuDisabled = true;
	    	   fieldInfo.sortable = false;
	    	   fieldInfo.getEditor = function(currentRecord){
	    		   var currTypeValue = currentRecord.get('parentProfileId');
	    		   if(currentRecord.get('isGlobal') === true && currTypeValue !== me.selectedProfileId) {
	    			   return "";
	    		   }
	    		   optionPicklist.setRecord(currentRecord);
                   return optionPicklist;
               };
	    	   return fieldInfo;	    	   
	    	   
	       },
	       
	       addItemBeforeGlobalRecs : function(records, noOfGlobalRecs) {
	    	   noOfGlobalRecs = (noOfGlobalRecs === undefined || noOfGlobalRecs.length === 0) ? 0 : noOfGlobalRecs; 
	    	   if (!records) return;
               this.store.insert(this.getStore().count() - noOfGlobalRecs, records);
	       },
	       
	       getProfileRecords: function() {
	    	   var records = [];
	    	   this.store.each(function(rec) {           		
		    		if(rec.get("isGlobal") !== true) {
		    			delete rec.data["id"];           		
		           		records.push(rec.data);
		    		}           		
	    	   });
	    	   return records;
	       },
	       
	       getGlobalRecords: function() {
	    	   var records = [];
	    	   this.store.each(function(rec) {           		
		    		if(rec.get("isGlobal") === true) {
		    			delete rec.data["id"];           		
		           		records.push(rec.data);
		    		}           		
	    	   });
	    	   return records;
	       }
		});		
	
		Ext.define("com.servicemax.client.installigence.admin.UserActions", {
	         extend: "com.servicemax.client.installigence.ui.components.SVMXPanel",
	         
	        constructor: function(config) {
   	 			var me = this;
   	 			var profiles = config.metadata.svmxProfiles;
   	 			var ibValueMapData = config.metadata.ibValueMaps;
				
	   	 		Ext.define('stdActionsModel', {
				    extend: 'Ext.data.Model',
				    fields: [ {name: 'isHidden', type: 'boolean'},
				              {name: 'name',  type: 'string'},
				              {name: 'action', type: 'string'}]
				});
	   	 		
   	 			Ext.define('actionsModel', {
				    extend: 'Ext.data.Model',
				    fields: [ {name: 'name',  type: 'string'},
				              {name: 'actionType',   type: 'string'},
				              {name: 'action', type: 'string'},
				              {name: 'isGlobal', type: 'boolean'}]
				});
   	 			
   	 			this.actionTypeStore = SVMX.create('com.servicemax.client.ui.components.composites.impl.SVMXStore', {
			        fields: ['value', 'label'],
			        data: [{ value: 'fieldupdate', label: $TR.FIELD_UPDATE}]/*,
			               { value: 'externalapp', label: $TR.EXTERNAL_APP}]*/
   	 			});
				
				//the below data model have to be replaced with the actual data
				me.actionsStore = SVMX.create('com.servicemax.client.ui.components.composites.impl.SVMXStore', {
				    model: 'actionsModel',
				    data: [			        
				        
				    ]
				});
				
				me.stdActionsStore = SVMX.create('com.servicemax.client.ui.components.composites.impl.SVMXStore', {
				    model: 'stdActionsModel',
				    data: [			        
				        
				    ]
				});
				
				var i = 0;
		    	var valueMapData = [];
		    	for(i=0; i< ibValueMapData.length; i++){
		    		   valueMapData[i] = {mapId: ibValueMapData[i].valueMapName, mapName: ibValueMapData[i].valueMapProcessName};
		    	}
		    	   
				this.valueMapStore = SVMX.create('com.servicemax.client.ui.components.composites.impl.SVMXStore', {
			        fields: ['mapId', 'mapName'],
			        data: valueMapData
   	 			});
				
				var profilesData = [{profileId: "--None--", profileName: $TR.NONE}];
				me.globalActions = [];
				me.globalFilters = [];
				var iProfile = 0, iProfileLength = profiles.length;
				for(iProfile = 0; iProfile < iProfileLength; iProfile++) {
					if(profiles[iProfile].profileId !== 'global'){
						profilesData.push(profiles[iProfile])
					}else {
						me.globalActions = profiles[iProfile].actions;
						me.globalFilters = profiles[iProfile].filters;
					}
				}				
				
				me.profiles = SVMX.create('com.servicemax.client.ui.components.composites.impl.SVMXStore', {
			        fields: ['profileId', 'profileName'],
			        data: profilesData
			    });
							
				me.actionSearchGrid = SVMX.create('com.servicemax.client.installigence.admin.userActionsGrid',{
					cls: 'grid-panel-borderless panel-radiusless',
					store: me.actionsStore,
					height: 160,
				    selType: 'cellmodel',
				    actionTypeStore: me.actionTypeStore,			        
				    plugins: [
				              SVMX.create('com.servicemax.client.installigence.ui.components.SVMXCellEditorPlugin', {
				                  clicksToEdit: 2
				              })
				          ],
				    valueMapStore: me.valueMapStore
	            });			
				
				me.addRecButton = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXButton',{
					//cls: 'plain-btn',
					ui: 'svmx-toolbar-icon-btn',
					scale: 'large',
					iconCls: 'plus-icon',
					disabled: true,
					handler : function(){
						me.onAddRecords();
					}
				});
				
				me.actionsTextSearch = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXTextSearch',{
					width: '40%',
					cls: 'search-textfield',
					emptyText : 'Search',
					listeners: {
	                    change: {
	                        fn: me.onTextFieldChange,
	                        scope: this,
	                        buffer: 500
	                    }
	               }
				});
				
				me.showProfiles = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXComboBox',{
					fieldLabel: $TR.SELECT_PROFILE,
			        store: me.profiles,
			        labelWidth: 120,
			        width: 450,
			        displayField: 'profileName',
			        queryMode: 'local',
			        editable: false,
			        selectedProfile: undefined,
			        listeners: {
			        	select: {
			        		fn: me.__persistNLoadUserActionFilters,
			        		scope: me
			        	},
						afterrender: function(combo) {
							var recordSelected = combo.getStore().getAt(0);                     
							combo.setValue(recordSelected.get('profileName'));
						}
			        }
				});
				
				me.profileFormPanel = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXFormPanel',{
					width: 450,
					style: 'margin: 3px 0',
					layout: 'fit',
					cls: 'grid-panel-borderless',
					defaults: {
						anchor: '40%'
					}
				});
				me.profileFormPanel.add(me.showProfiles);
				
				me.actionsTabPanel = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXTabPanel',{
						cls: 'horizontal-tab-panel grid-panel-borderless panel-radiusless',
						plain : 'true'
                });
				
				me.searchToolbar = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXToolbar',{
					style: 'border-width: 0'
				});				
				
				me.searchToolbar.add(me.actionsTextSearch);
				me.searchToolbar.add('->');
				me.searchToolbar.add(me.addRecButton);

				me.stdActionSearchGrid = SVMX.create('com.servicemax.client.installigence.admin.userStandardActionsGrid',{
					cls: 'grid-panel-borderless panel-radiusless',
					store: me.stdActionsStore,
					height: 160,
				    selType: 'cellmodel',
				    plugins: [
				              SVMX.create('com.servicemax.client.installigence.ui.components.SVMXCellEditorPlugin', {
				                  clicksToEdit: 2
				              })
				          ],
				    valueMapStore: me.valueMapStore
	            });
				
				me.stdUserActionsPanel = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXFormPanel',{
					style: 'margin: 1px 0',
					layout: 'fit',
					title: $TR.STANDARD_ACTIONS,
					cls: 'grid-panel-borderless',
					defaults: {
						anchor: '40%'
					}
				});
				me.stdUserActionsPanel.add(me.stdActionSearchGrid);
				
				me.userActionsPanel = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXFormPanel',{
					style: 'margin: 1px 0',
					layout: 'fit',
					title: $TR.CUSTOM_ACTIONS,
					cls: 'grid-panel-borderless',
					defaults: {
						anchor: '40%'
					}
				});
				me.userActionsPanel.add(me.actionSearchGrid);
				
				me.actionsTabPanel.add({id:"UA", title: $TR.USERACTIONS, items: [ 
				  me.searchToolbar,
				  me.stdUserActionsPanel,
				  me.userActionsPanel
				  ]
				});
				
				me.filters = SVMX.create("com.servicemax.client.installigence.admin.Filters", {
					metadata: config.metadata
				});
				me.actionsTabPanel.add({title: $TR.FILTERS, items: [me.filters]});
				me.actionsTabPanel.setActiveTab("UA");
				
				config = config || {};
				config.items = [];
				config.items.push(me.profileFormPanel);
				config.items.push(me.actionsTabPanel);
				config.title = $TR.USERACTIONS_FILTERS;
				config.id = "UF";
				this.callParent([config]);
	         },
	         
	         onTextFieldChange: function() {
	        	var value = this.actionsTextSearch.getValue();
	        	this.actionSearchGrid.search(value);
	        	this.stdActionSearchGrid.search(value);
	         },
	         
	         onAddRecords: function() {
	        	 this.actionSearchGrid.addItemBeforeGlobalRecs({parentProfileId: this.actionSearchGrid.selectedProfileId}, this.globalActions.length);
	         },
	         
	         __persistNLoadUserActionFilters: function(combo, record) { 
	        	 
	        	 //all disable goes here
	        	 this.addRecButton.setDisabled(combo.getSelectedRecord().get("profileId") == "--None--");
	        	 this.filters.addFilterRecButton.setDisabled(combo.getSelectedRecord().get("profileId") == "--None--");
	        	 this.filters.expressiontree.setDisabled(true);
	        	 
	        	 if(combo.getSelectedRecord() && combo.getSelectedRecord().get("profileId") !== "--None--")
        		 {
	        		 this.actionSearchGrid.selectedProfileId = combo.getSelectedRecord().get("profileId");
	        		 this.filters.filtersSearchGrid.selectedProfileId = combo.getSelectedRecord().get("profileId");
        		 }        	 
	        	 var prevSelTemplate = this.showProfiles.selectedProfile;
	        	 if(prevSelTemplate) {
        		 	   this.filters.persistNLoadExpression({});		        	 
		    		   this.__persistUserActions(prevSelTemplate);
		    		   this.__persistFilters(prevSelTemplate);
		    		   this.__persistUserStdActions(prevSelTemplate);
	        	 }
	        	 if(combo.getSelectedRecord().get("profileId") !== "--None--"){
	        		 this.showProfiles.selectedProfile = record;
		        	 this.__loadUserActions(record.getData().actions);
		        	 this.__loadUserStdActions(record.getData().stdActions);
		        	 this.__loadFilters(record.getData().filters);
	        	 }else {
	        		 this.showProfiles.selectedProfile = undefined;
	        		 this.actionSearchGrid.getStore().removeAll();
	        		 this.filters.filtersSearchGrid.getStore().removeAll();
	        		 this.stdActionSearchGrid.getStore().removeAll();
        		 }        	 
	         },
	         
	         __persistUserActions: function(record) {
	        	 var userActionsInfo = this.actionSearchGrid.getProfileRecords();
	        	 this.globalActions = this.actionSearchGrid.getGlobalRecords();
	        	 this.__savePicklistValues(userActionsInfo);
	        	 this.__savePicklistValues(this.globalActions);
	        	 record.set("actions", userActionsInfo);
	         },
	         
	         __persistUserStdActions: function(record) {
	        	 var userActionsInfo = this.stdActionSearchGrid.getProfileRecords();
	        	 this.__savePicklistValues(userActionsInfo);
	        	 record.set("stdActions", userActionsInfo);
	         },
	         
	         __persistFilters: function(record) {
	        	 var filtersInfo = this.filters.filtersSearchGrid.getProfileRecords();
	        	 this.globalFilters = this.filters.filtersSearchGrid.getGlobalRecords();	        	 
	        	 record.set("filters", filtersInfo)
	         },
	         
	         __loadUserActions: function(record) {
	        	 if(!record) {
	        		 record = [];
	        	 }
	        	 record = record.concat(this.globalActions);
        		 this.__loadPicklistValues(record);
        		 this.actionSearchGrid.getStore().loadData(record)
	         },

	         __loadUserStdActions: function(record) {
	        	 if(!record) {
	        		 record = [];
	        	 }
        		 this.__loadPicklistValues(record);
        		 this.stdActionSearchGrid.getStore().loadData(record);
	         },
	         
	         __loadFilters: function(record) {
	        	 if(!record) {
	        		 record = [];
	        	 }
	        	 record = record.concat(this.globalFilters);
        		 this.filters.filtersSearchGrid.getStore().loadData(record)
	         },
	         
	         __loadPicklistValues: function(records) {
	        	 var iActionsRecs = 0, iActionRecsLen = records.length;
	        	 for(iActionsRecs = 0; iActionsRecs < iActionRecsLen; iActionsRecs++) {
	        		 var currRec = records[iActionsRecs];
	        		 currRec.actionType_key = currRec.actionType;
	        		 currRec.actionType = this.actionTypeStore.findRecord("value", currRec.actionType) !== null ? 
							   this.actionTypeStore.findRecord("value", currRec.actionType).get("label") : currRec.actionType;
					currRec.action_key = currRec.action;
					
					currRec.action = this.valueMapStore.findRecord("mapId", currRec.action) !== null ? 
							   this.valueMapStore.findRecord("mapId", currRec.action).get("mapName") : currRec.action;
	        	 }
	         },
	         
	         __savePicklistValues: function(records) {
	        	 var iActionsRecs = 0, iActionRecsLen = records.length;
	        	 for(iActionsRecs = 0; iActionsRecs < iActionRecsLen; iActionsRecs++) {
	        		 var currRec = records[iActionsRecs];
	        		 if(currRec.actionType_key) {
	        			 currRec.actionType = currRec.actionType_key;
		        		 delete currRec["actionType_key"];
	        		 }
	        		 if(currRec.action_key) {
	        			 currRec.action = currRec.action_key;
		        		 delete currRec["action_key"];
	        		 }
	        	 }
	         }
	         
	     });
	};
})();