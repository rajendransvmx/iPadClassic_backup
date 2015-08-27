(function(){
	var setupProductTemplates = SVMX.Package("com.servicemax.client.installigence.admin.producttemplates");

setupProductTemplates.init = function() {
	
		Ext.define("com.servicemax.client.installigence.admin.producttemplates.configSpecGrid", {
	        extend: "com.servicemax.client.installigence.ui.components.SVMXGrid",
	        
	       constructor: function(config) {
	    	   
	    	   var config = config || {};
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
		                    gridStore.remove(rec);		                    
		                }		
					}                  
	           ]
	    	   var me = this;
	    	   config.columns.push(this.createTextBoxColumn({text: 'Name', dataIndex: 'name', width:200}));
	    	   config.columns.push(this.createComboBoxColumn({text: 'Type', dataIndex: 'type', width:200, flex: 1}));
	    	   this.callParent([config]);
	       },
	       
	       createTextBoxColumn: function(fieldInfo) {
	    	   
	    	   var txtboxCol = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXTextField',{
	    		   allowBlank : true,
	    		   editable : true
	    	   });
	    	   
	    	   var fieldInfo = fieldInfo || {};
	    	   fieldInfo.sortable = false;
	    	   fieldInfo.editable = true;
	    	   fieldInfo.getEditor = function(){
	               return txtboxCol;
	           };
	    	   return fieldInfo;
	       },
	       
	       createComboBoxColumn: function(fieldInfo) {
	    	   var me = this;
	    	   this.options = SVMX.create('com.servicemax.client.ui.components.composites.impl.SVMXStore', {
			        fields: ['Name', 'Type'],
			        data: [{ Id: 'text', Option: 'Text'},
			               { Id: 'number', Option: 'Number'}]
			   });
	    	   var optionPicklist = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXComboBox',{
					store: me.options,
			        displayField: 'Option',
			        queryMode: 'local',
			        editable: false
	    	   });	    	   
	    	   
	    	   var fieldInfo = fieldInfo || {};
	    	   fieldInfo.menuDisabled = true;
	    	   fieldInfo.sortable = false;
	    	   fieldInfo.getEditor = function(){
	               return optionPicklist;
	           };
	    	   return fieldInfo;	    	   
	    	   
	       }		
		});		
		
		Ext.define("com.servicemax.client.installigence.admin.ProductTemplates", {
	        extend: "com.servicemax.client.installigence.ui.components.SVMXPanel",
	        
	       constructor: function(config) {
	    	   var me = this;
	    	   var ibValueMapData = config.metadata.ibValueMaps;
	    	   var ibTemplatesData = [{templateId: "--None--", templateName: $TR.NONE}];
	    	   /*all stores goes here*/
	    	   var logosStore = me.__getInstalligenceLogosStore(config.metadata.installigenceLogos);
	    	   ibTemplatesData = ibTemplatesData.concat(config.metadata.ibTemplates);
	    	   ibDescribe = config.metadata[ SVMX.OrgNamespace + "__Installed_Product__c"];
	    	   /**/
	    	   
	    	   var ibFieldMappingsStore = SVMX.create('com.servicemax.client.ui.components.composites.impl.SVMXStore', {
			        fields: ['valueMapName', 'valueMapProcessName'],
			        data: ibValueMapData
			   });
	    	   
	    	   me.templatesStore = SVMX.create('com.servicemax.client.ui.components.composites.impl.SVMXStore', {
			       fields: ['templateId', 'templateName'],
			       data: ibTemplatesData
			   });
	    	   
	    	   me.deletedTemplateIds = [];
	    	   
	    	   me.showTemplates = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXComboBox',{
	    		   fieldLabel: $TR.SELECT_TEMPLATE,
			       store: me.templatesStore,
			       labelWidth: 150,
			       displayField: 'templateName',
			       queryMode: 'local',
			       valueField: 'templateId',
			       value:'--None--',
			       selectedTemplate: undefined,
			       editable: false,
	    		   width: 400,
	    		   listeners: {
	    			   select: {
                           fn: me.__persistNLoadTemplate,
                           scope: me
                       },
                       
                       beforeselect: {
                    	   fn: me.__validateForm,
                           scope: me
                       }
                   }
	    	   });
	    	   
	    	   
	    	   me.templateActionsToolbar = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXToolbar',{
					
	    	   });	
	    	   
	    	   Ext.override(Ext.tree.View, {
	    		    collapse : function (record, deep, callback, scope) {
	    		        this.callParent(arguments);
	    		        this.refresh();
	    		    },
	    		    expand : function (record, deep, callback, scope) {
	    		        this.callParent(arguments);
	    		        this.refresh();
	    		    }       
	    		});
	    	   
	    	   //show the tree and their properties
	    	   me.templatePropertyPanel = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXPanel',{
	    		   margin: '5 0 5 0',
	    		   layout: 'anchor',
	    		   cls: 'grid-panel-border',
	    		   height: 480,
	    		   flex: 1
	    	   });
	    	   
	    	   me.templateNameText = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXTextField',{
	    		   allowBlank : true,
	    		   editable : true,
	    		   margin: '5, 5',
	    		   labelAlign:'right',
	    		   fieldLabel: $TR.TEMPLATE_NAME,
	    		   labelWidth: 200,
	    		   allowBlank: false,
	    		   width: 550,
	    		   listeners: {
		    		   change: function(field, value) {
		    			    me.templateTree.changeProductText(value);
		    		   }
	    		   }
	    	   });
	    	   
	    	   me.templateNameId = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXTextField',{
	    		   allowBlank : true,
	    		   editable : true,
	    		   margin: '5, 5',
	    		   labelAlign:'right',
	    		   fieldLabel: $TR.TEMPLATE_ID,
	    		   labelWidth: 200,
	    		   allowBlank: false,
	    		   width: 550
	    	   });
	    	   
	    	   me.ibNameText = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXTextField',{
	    		   allowBlank : true,
	    		   editable : true,
	    		   margin: '5, 5',
	    		   labelAlign:'right',
	    		   fieldLabel: $TR.IB_DISPLAY_TEXT,
	    		   labelWidth: 200,
	    		   width: 550,
	    		   hidden: true
	    	   });
	    	   
	    	   me.locationNameText = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXTextField',{
	    		   allowBlank : true,
	    		   editable : true,
	    		   margin: '5, 5',
	    		   labelAlign:'right',
	    		   fieldLabel: $TR.LOCATION_DISPLAY_TEXT,
	    		   labelWidth: 200,
	    		   width: 550,
	    		   hidden: true
	    	   });
	    	   
	    	   me.subLocationNameText = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXTextField',{
	    		   allowBlank : true,
	    		   editable : true,
	    		   margin: '5, 5',
	    		   labelAlign:'right',
	    		   fieldLabel: $TR.SUB_LOCATION_DISPLAY_TEXT,
	    		   labelWidth: 200,
	    		   width: 550,
	    		   hidden: true
	    	   });
	    	   me.templatePropertyPanel.add(me.templateNameText);
	    	   me.templatePropertyPanel.add(me.templateNameId);
	    	   me.templatePropertyPanel.add(me.ibNameText);
	    	   me.templatePropertyPanel.add(me.locationNameText);
	    	   me.templatePropertyPanel.add(me.subLocationNameText);
	    	   
	    	   me.productPropertyPanel = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXPanel',{
	    		   margin: '5 0 5 0',
	    		   layout: 'anchor',
	    		   cls: 'grid-panel-border',
	    		   height: 480,
	    		   flex: 1
	    	   });
	    	   
	    	   me.productNameText = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXLookup',{
	    		   allowBlank : true,
	    		   editable : true,
	    		   cls: 'svmx-lookup-field',
	    		   margin: '5, 5',
	    		   labelAlign:'right',
	    		   fieldLabel: $TR.PRODUCT,
	    		   labelWidth: 200,
	    		   width: 550,
	    		   textWidth: 500,
	    		   meta: config.metadata,
	    		   onValueSelected: function(field, value, idValue) {
	    			    me.templateTree.changeProductText(value);
	    		   }
	    	   });
	    	   
	    	   me.productIcon = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXComboBox',{
	    		   fieldLabel: $TR.ICON,
			       store: logosStore,
			       labelWidth: 200,
			       labelAlign:'right',
			       margin: '5, 5',	    		   
			       displayField: 'name',
			       valueField: 'uniqueName',
			       queryMode: 'local',
			       editable: false,
	    		   width: 550,
	    		   listConfig: {
	    		        getInnerTpl: function() {
	    		        	var tpl = "<div style='width:100%;height:20px;' align='center'>" +	
	    		                      "<img src='/servlet/servlet.FileDownload?file={logoId}'>" +
	    		        			  "</div>" + "<div style='width:100%;height:30px;background:#f2f2f2' align='center'>" + 
	    		                      "{name}</div>";
	    		            return tpl;
	    		        }
	    		   },
	    		   listeners: {
	    			    select: function(combo, records, eOpts) {
	    			        me.templateTree.changeProductIcon(records.get('logoId'));
	    			    }
	    		   }
	    	   });
	    	   
	    	   me.productDefaultValues = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXComboBox',{
	    		   fieldLabel: $TR.DEFAULT_VALUES,
			       store: ibFieldMappingsStore,
			       labelWidth: 200,
			       labelAlign:'right',
			       margin: '5, 5',	    		   
			       displayField: 'valueMapProcessName',
			       valueField: 'valueMapName',
			       queryMode: 'local',
			       editable: false,
	    		   width: 550
	    	   });
	    	   
	    	   Ext.define('templatemodel', {
				    extend: 'Ext.data.Model',
				    fields: [ 'text', 'type', 'product']
				});
	    	   
	    	   var store = Ext.create('Ext.data.TreeStore', {
	    		   model: templatemodel,
	    		   root: {
	    			   expanded: true,
	    			   children: [					
    			              { text: $TR.TEMPLATE_NAME, type:"root", expanded: true, iconCls: 'template-icon', templateDetails: {} }	    					
	    			   ]
	    		   }
	    	   });
	    	   
	    	   me.oldProductValueMap = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXComboBox',{
	    		   fieldLabel: $TR.VALUE_MAP_OLD_IB,
			       store: ibFieldMappingsStore,
			       labelWidth: 200,
			       labelAlign:'right',
			       margin: '5, 5',	    		   
			       displayField: 'valueMapName',
			       valueField: 'valueMapName',
			       queryMode: 'local',
			       editable: false,
	    		   width: 545,
	    		   bind: {
	    	            store: '{store}',
	    	            selection: '{product.oldValueMap}'
	    		   }
	    	   });
	    	   
	    	   me.newProductValueMap = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXComboBox',{
	    		   fieldLabel: $TR.VALUE_MAP_NEW_IB,
			       store: ibFieldMappingsStore,
			       labelWidth: 200,
			       labelAlign:'right',
			       margin: '5, 5',	    		   
			       displayField: 'valueMapName',
			       valueField: 'valueMapName',
			       queryMode: 'local',
			       editable: false,
	    		   width: 545
	    	   });
	    	   
	    	   var productSwapContainer = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXFormPanel',{
	    		   title: $TR.PRODUCT_SWAP,
	    		   margin: '10 5 10 5',
	    		   cls: 'grid-panel-borderless',
	    		   ui: 'svmx-gray-panel',
	    		   hidden : true
	    	   });
	    	   productSwapContainer.add(me.oldProductValueMap);
	    	   productSwapContainer.add(me.newProductValueMap);	    	   
	    	   
	    	 //the below data model have to be replaced with the actual data
	    	   me.productConfigStore = SVMX.create('com.servicemax.client.ui.components.composites.impl.SVMXStore', {
	    		   fields: ['name', 'type'],
	    		   data: []
	    	   });
	    	   
	    	   me.productConfigGrid = SVMX.create('com.servicemax.client.installigence.admin.producttemplates.configSpecGrid',{
	    		   cls: 'grid-panel-border panel-radiusless',
	    		   store: me.productConfigStore,
	    		   height: 165,
	    		   margin: '0 5 10 5',	
	    		   selType: 'cellmodel',
	    		   hidden : true,
	    		   plugins: [
			              SVMX.create('com.servicemax.client.installigence.ui.components.SVMXCellEditorPlugin', {
			                  clicksToEdit: 2
			              })
		              	]
	    	   });
	    	   
	    	   var productConfigSpecContainer = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXToolbar',{
	    		   margin: '10 5 0 5',
	    		   hidden: true
	    	   });
	    	   
	    	   var addTypeButton = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXButton',{
					//cls: 'plain-btn',
					ui: 'svmx-toolbar-icon-btn',
					scale: 'large',
					iconCls: 'plus-icon',
					handler : function(){
						me.productConfigGrid.addItems({});
					}
	    	   });
	    	   
	    	   var configSpecLabel = SVMX.create('com.servicemax.client.installigence.ui.components.Label',{
					text: $TR.PRODUCT_CONFIGURATION
	    	   });
	    	   productConfigSpecContainer.add(configSpecLabel);
	    	   productConfigSpecContainer.add('->');
	    	   productConfigSpecContainer.add(addTypeButton);
	    	   	    	   
	    	   me.productPropertyPanel.add(me.productNameText);
	    	   me.productPropertyPanel.add(me.productIcon);
	    	   me.productPropertyPanel.add(me.productDefaultValues);
	    	   me.productPropertyPanel.add(productSwapContainer);
	    	   me.productPropertyPanel.add(productConfigSpecContainer);
	    	   me.productPropertyPanel.add(me.productConfigGrid);
	    	   
	    	   //show the tree
	    	   me.templateTreePanel = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXPanel',{
	    		   margin: '5 7 5 0',
	    		   layout: 'anchor',
	    		   cls: 'grid-panel-border',
	    		   width: '30%',
	    		   height: 480
	    	   });	    	   
	    	   
	    	   me.templateTree = SVMX.create('com.servicemax.client.installigence.ui.components.Tree',{
	    		   cls: 'grid-panel-borderless svmx-tree-panel',
	    		   margin: '5 0 0 0',
	    		   width: '100%',
	    		   rootVisible: false,
	    		   height: 480,
	    		   store: store,
	    		   rootVisible: false,
	    		   selectedRec: undefined,
	    		   viewConfig: {
	                    listeners: {
	                        itemcontextmenu: {
	                            fn: me.onViewItemContextMenu,
	                            scope: me
	                        },
	                        
	                        itemclick: { 
	                             fn: me.onNodeClick,
	                             scope: me
	                        }
	                    }
	               },	                
	     	       changeProductIcon: function(iconId) {
	     	    	   var node = this.getSelectionModel().getSelection()[0];
	     	    	   node.set('iconCls','');
	     	    	   node.set('icon','/servlet/servlet.FileDownload?file=' + iconId);
	     	       },	                
	     	       changeProductText: function(value, idValue) {
	     	    	   var node = this.getSelectionModel().getSelection()[0];
	     	    	   node.data.text = value;
	     	    	   node.set('title', value);
	     	       }
	    	   });
	    	   
	    	   me.templateTreeSearch = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXTextSearch',{
					width: '97%', margin: '5 5 5 5',
					cls: 'search-textfield',
					emptyText : $TR.SEARCH_EMPTY_TEXT,
					listeners: {
	                    change: {
	                    	fn: me.onTextFieldChange,	                        
	                        scope: this,
	                        buffer: 500
	                    }
	               }
	    	   });
	    	   
	    	   me.addProduct = Ext.create('Ext.Action', {
	    		   text: $TR.ADD_PRODUCT,
	    		   iconCls: 'product-icon',
	    		   handler: function(widget, event) {
	    			   var rec = me.templateTree.getSelectionModel().getSelection()[0];
	    			   rec.appendChild({text: $TR.PRODUCT, type: "product", expanded: true, iconCls: 'product-icon', product: {}})
	    		   }
	    	   });
	    	   
	    	   me.deleteProduct = Ext.create('Ext.Action', {
	    		   text: $TR.DEL_PRODUCT,
	    		   iconCls: 'product-icon',
	    		   handler: function(widget, event) {
	    			   var rec = me.templateTree.getSelectionModel().getSelection()[0];
	    			   while(rec.firstChild) {
	    				   rec.removeChild(rec.firstChild);
	    			   }
	    			   rec.remove(true);
	    			   
	    			   me.templateTree.getStore().sync();
	    		   }
	    	   });
	    	   
	    	   me.templateTreePanel.add(me.templateTreeSearch);
	    	   me.templateTreePanel.add(me.templateTree);
	    	   
	    	   //show the properties	    	   
	    	   me.templateTreePropertiesPanel = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXPanel',{
	    		   width: '100%',
	    		   style: 'margin: 3px 0',
	    		   layout: {
	    			   type: 'hbox',
	    			   align: 'strech'
    				  },
	    		   cls: 'grid-panel-borderless'	    		   
	    	   });    	   
	    	   
	    	   me.templateTreePropertiesPanel.add(me.templateTreePanel);	    	   
	    	   me.templateTreePropertiesPanel.add(me.templatePropertyPanel);
	    	   
	    	   var addTemplateButton = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXButton',{
					//cls: 'plain-btn',
					ui: 'svmx-toolbar-icon-btn',
					scale: 'large',
					iconCls: 'plus-icon',
					handler : function(){
						if(me.__validateForm() == false) return false;
						me.__addNewTemplate();
					}
	    	   });
	    	   
	    	   var delTemplateButton = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXButton',{
					//cls: 'plain-btn',
					ui: 'svmx-toolbar-icon-btn',
					scale: 'large',
					iconCls: 'delete-icon',
					handler : function(){
						me.__deleteTemplate();
					}
	    	   });
	    	   
	    	   var saveAsTemplateButton = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXButton',{
					//cls: 'plain-btn',
					ui: 'svmx-toolbar-icon-btn',
					scale: 'large',
					iconCls: 'save-as-icon'
	    	   });
	    	   
	    	   var createFromIBButton = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXButton',{
					//cls: 'plain-btn',
					ui: 'svmx-toolbar-icon-btn',
					scale: 'large',
					iconCls: 'create-from-ib-icon',
					handler: function(){
						if(me.__validateForm() == false) return false;						
						me.__createFromIB(this, me, ibDescribe);
					}
	    	   });
	    	   
	    	   me.templateActionsToolbar.add(me.showTemplates);
	    	   me.templateActionsToolbar.add('->');
	    	   me.templateActionsToolbar.add(addTemplateButton);
	    	   me.templateActionsToolbar.add(delTemplateButton);
	    	   //me.templateActionsToolbar.add(saveAsTemplateButton);
	    	   me.templateActionsToolbar.add(createFromIBButton);
	    	   config = config || {};
	    	   config.items = [];
	    	   config.items.push(me.templateActionsToolbar);
	    	   config.items.push(me.templateTreePropertiesPanel);
	    	   config.title = $TR.TEMPLATES;
	    	   this.callParent([config]);
	       },
	       
	       onViewItemContextMenu: function(dataview, record, item, index, e) {
	    	   e.stopEvent();
	    	   var me = this;
	    	   
	    	   if(record.get("type") === 'root' && record.childNodes && record.childNodes.length > 0) {
	    		   return true;
	    	   }
	    	   
	    	   contextMenu = new Ext.menu.Menu({
	    		   items: [me.addProduct]
	    		 });
	    	   if(record.get("type") === 'product') {
	    		   contextMenu = new Ext.menu.Menu({
	    			   items: [me.addProduct, me.deleteProduct]
	    		   });
	    	   }
	    	   contextMenu.showAt(e.getXY());
	    	   return true;
	       },
	       
	       onNodeClick: function(node, rec, item, index, e) {
	    	   //e.stopEvent();
	    	   if(rec.get("type") === 'product') {
	    		   this.templateTreePropertiesPanel.remove(this.templatePropertyPanel, false);
	    		   this.templateTreePropertiesPanel.add(this.productPropertyPanel);
	    	   }else if(rec.get("type") === 'root') {
	    		   this.templateTreePropertiesPanel.add(this.templatePropertyPanel);
	    		   this.templateTreePropertiesPanel.remove(this.productPropertyPanel, false);
	    	   }
    		   this.__persistNLoadProductData(rec);
	    	   return true;
	       },
	         
	       onTextFieldChange: function() {
	    	   var value = this.templateTreeSearch.getValue();
	    	   this.templateTree.search(value);
	       },
	       
	       __getInstalligenceLogosStore: function(logos) {
	    	   var data = logos;
			   var logosStore = SVMX.create('com.servicemax.client.ui.components.composites.impl.SVMXStore', {
			        fields: ['name', 'uniqueName'],
			        data: data
			   });
			   return logosStore;
	       },
	       
	       __persistNLoadProductData: function(selectedRecord) {
	    	   //store the existing information to previous selected node
	    	   var prevSelRec = this.templateTree.selectedRec;
	    	   if(prevSelRec) {
	    		   if(prevSelRec.get("type") === "root"){
	    			   this.__persistTemplateDetails(prevSelRec);
	    		   }else {
	    			   this.__persistProductData(prevSelRec);
	    		   }    		   
	    	   }
	    	   //load the informnation to selected node
	    	   this.templateTree.selectedRec = selectedRecord;
	    	   if(selectedRecord.get("type") === "root"){
	    		   this.__loadTemplateDetails(selectedRecord);
	    	   }else {
	    		   this.__loadProductData(selectedRecord);
	    	   }
	       },
	       
	       __persistTemplateDetails: function(record) {
	    	   templInfo = {};
    		   templInfo.templateName = this.templateNameText.getValue();
    		   templInfo.templateId = this.templateNameId.getValue();
    		   templInfo.ibText = this.ibNameText.getValue();
    		   templInfo.locationText = this.locationNameText.getValue();
    		   templInfo.subLocationText = this.subLocationNameText.getValue();
    		   record.set("templateDetails", templInfo);
	    	   
	       },
	       
	       __loadTemplateDetails: function(record) {
	    	   var templInfo = record.getData().templateDetails;
	    	   if(!templInfo) {
	    		   templInfo = {};
	    	   }
	    	   this.__loadTemplateDet(templInfo);
	       },
	       
	       __loadTemplateDet: function(templInfo) {
	    	   this.templateNameId.setReadOnly(true);
	    	   if(!templInfo.templateId) {
	    		   this.templateNameId.setReadOnly(false);
	    	   }
	    	   this.templateNameText.setValue(templInfo.templateName);
    		   this.templateNameId.setValue(templInfo.templateId);
    		   this.ibNameText.setValue(templInfo.ibText);
    		   this.locationNameText.setValue(templInfo.locationText);
    		   this.subLocationNameText.setValue(templInfo.subLocationText);
	       },
	       
	       __persistProductData: function(record) {
	    	   var proInfo = record && record.getData() ? record.getData().product : undefined;
	    	   if(proInfo) {
	    		   proInfo.product = this.productNameText.getValue();
	    		   proInfo.productId = this.productNameText.getIdValue();
	    		   proInfo.productIcon = this.productIcon.getValue();
	    		   proInfo.productDefaultValues = this.productDefaultValues.getValue();
	    		   proInfo.oldProductValueMap = this.oldProductValueMap.getValue();
	    		   proInfo.newProductValueMap = this.newProductValueMap.getValue();
	    		   proInfo.productConfiguration = this.productConfigGrid.getRecords();
	    	   }	    	   
	       },
	       
	       __loadProductData: function(record) {
	    	   var proInfo = record.getData().product;
	    	   if(proInfo) {
	    		   this.productNameText.setValue(proInfo.product);
	    		   this.productNameText.setIdValue(proInfo.productId);
	    		   this.productIcon.setValue(proInfo.productIcon);
	    		   this.productDefaultValues.setValue(proInfo.productDefaultValues);
	    		   this.oldProductValueMap.setValue(proInfo.oldProductValueMap);
	    		   this.newProductValueMap.setValue(proInfo.newProductValueMap);
	    		   this.productConfigGrid.getStore().removeAll();
	    		   if(proInfo.productConfiguration && proInfo.productConfiguration.length > 0) {
	    			   this.productConfigGrid.getStore().loadData(proInfo.productConfiguration);
	    		   }	    		   
	    	   }
	       },
	       
	       __persistNLoadTemplate: function(combo, record) {
	    	   
	    	   //store the existing template information to previous selected template
	    	   var prevSelTemplate = this.showTemplates.selectedTemplate;
	    	   if(this.showTemplates.selectedTemplate && prevSelTemplate.getData().templateId !== "--None--") {
	    		   
	    		   this.__persistTemplate(prevSelTemplate);
	    	   }
	    	   //load the template information to selected template
	    	   this.showTemplates.selectedTemplate = record;
	    	   this.__loadTemplate(record.getData().template);
	       },
	       
	       __persistTemplate: function(record) {
	    	   var templateInfo = this.__getRecords(this.templateTree.getStore().getRootNode());
	    	   var templateName = this.showTemplates.selectedTemplate.getData().templateName;
	    	   var storeRec = this.showTemplates.getStore().findRecord("templateName", templateName);
	    	   if(storeRec) {
	    		   storeRec.set("template", templateInfo);
	    	   }
	       },
		   
	       __getRecords: function(rootNode) {
	    	 
	    	   return this.__getChildNodes(rootNode);
	       },
	       
	       __getChildNodes: function(node) {
	    	   
	    	   var rec = {};
	    	   
	    	   rec.text = node.getData().text;
	    	   rec.type = node.getData().type;
	    	   rec.product = node.getData().product;
	    	   rec.templateDetails = node.getData().templateDetails;
	    	   rec.expanded = true;
	    	   rec.iconCls = node.getData().iconCls;
	    	   if(node.isLeaf()) return;
	    	   
	    	   rec.children = [];
	    	   var children = node.childNodes || [], i, l = children.length;
	    	   for(i = 0; i < l; i++){
	    		   rec.children.push(this.__getChildNodes(children[i]));
	    	   }
	    	   return rec;	    	   
	       },
	       
	       __loadTemplate: function(record) {
	    	   if(record === undefined) {
	    		   record = {
	    			   expanded: true,
	    			   leaf: false,
	    			   children: [					
    			              { text: $TR.TEMPLATE_NAME, type:"root", expanded: true, iconCls: 'template-icon', templateDetails: {} }	    					
	    			   ]
	    		   }
	    	   }
	    	   
	    	   this.__loadIconClsForNodes(record.children[0]);	    	   
	    	   this.templateTree.getStore().setRootNode({
    			   expanded: true,
    			   leaf: false,
    			   children: record.children
    		   });
	    	   
	    	   this.templateTreePropertiesPanel.add(this.templatePropertyPanel);
    		   this.templateTreePropertiesPanel.remove(this.productPropertyPanel, false);
    		   this.templateTree.getStore().getRootNode().expand(true);
    		   this.templateTree.getSelectionModel().select(0);
    		   this.__loadTemplateDet(this.templateTree.getStore().getRootNode().getData().children[0].templateDetails || {});

			   this.templateTree.selectedRec = this.templateTree.getSelectionModel().getSelection()[0];
	    	   
	       },
		   
		   __loadIconClsForNodes: function(record) {
			   
			   var product = record.product;
			   productIcon = product && product.productIcon && product.productIcon !== null ? product.productIcon : undefined;
			   var productIconRec = this.productIcon.getStore().findRecord("uniqueName", productIcon);
			   record.iconCls = "product-icon";	
			   if(record.type === "root"){
				   record.iconCls = "template-icon";
			   }else if(productIconRec) {
				   record.iconCls = "";
				   record.icon = "/servlet/servlet.FileDownload?file=" + productIconRec.get("logoId");				   
			   }
			   if(record.children) {
				   var iData = 0, iLength = record.children.length || 0;
				   for(iData = 0; iData < iLength; iData++) {
					   this.__loadIconClsForNodes(record.children[iData]);
				   }
			   }
			   return record;
		   },
		   
		   __addNewTemplate: function() {
			   this.showTemplates.setValue("--None--");
			   this.templateNameId.setReadOnly(false);
			   this.showTemplates.getSelectedRecord().set("isNew", true);
			   this.__persistNLoadTemplate("", this.showTemplates.getSelectedRecord());
			   this.templateNameText.setValue("ProductIQ Template " + new Date);
			   this.templateNameId.setValue("ProductIQ_Template_" + Math.round(+new Date()/1000));
			   this.templateTree.selectedRec = this.templateTree.getSelectionModel().getSelection()[0];
		   },
		   
		   __deleteTemplate: function() {
			   var selectedRecord = this.showTemplates.getSelectedRecord();
			   var selectedTemplateId = selectedRecord.get("templateId");
			   if(selectedTemplateId === "--None--") {
				   return;			   
			   }
			   this.deletedTemplateIds.push(selectedRecord.get("templateId"));	
			   this.showTemplates.getStore().remove(selectedRecord);
			   this.showTemplates.setValue("--None--");
			   this.__loadTemplate(this.showTemplates.getSelectedRecord().template);
		   },
		   
		   __createFromIB: function(source, parent, objectDescribe) {
			   var getTopLevelIbs = SVMX.create("com.servicemax.client.installigence.admin.objectsearch.ObjectSearch", {
	                objectName :  SVMX.OrgNamespace + "__Installed_Product__c",
	                columns : [{name : "Name"}],
	                multiSelect : false,
	                sourceComponent : source,
	                objectDescribe: ibDescribe,
	                mvcEvent : "FIND_TOPLEVEL_IBS"
			   });
			   
			   getTopLevelIbs.find().done(function(results){
	               var topLevelIB = results[0].Id;
	               parent.__getTemplateForIB(topLevelIB);
			   });
		   },
		   
		   __getTemplateForIB: function(topLevelIB) {
			   var me = this;
		       	var evt = SVMX.create("com.servicemax.client.lib.api.Event",
								"INSTALLIGENCEADMIN.GET_TEMPLATE_FROM_IB", me,
								{request : { context : me, topLevelIB : topLevelIB}});
		       	
		       	SVMX.getCurrentApplication().getEventBus().triggerEvent(evt);
		   },
		   
		   GetTemplateFromIBComplete: function(results) {
			   var results = results;
			   var record = {};
			   record.children = [];
			   var templateName = "ProductIQ Template " + new Date, templateId = "ProductIQ_Template_" + Math.round(+new Date()/1000);
			   record.children.push({ text: templateName, type:"root", expanded: true, iconCls: 'template-icon', 
				   templateDetails: {
					   templateName: templateName,
		    		   templateId: templateId
		    		   
			   }, children: [results] });
			   
			   this.showTemplates.findRecord("templateId","--None--").set("template", record);
			   this.__addNewTemplate(record);
		   },
		   
		   __validateForm: function(){
			   var isValid = true;
			   if(!this.templateNameText.getValue() || this.templateNameText.getValue().length == 0) isValid = false;
			   if(!this.templateNameId.getValue() || this.templateNameId.getValue().length == 0) isValid = false;
			   var selectedTemp = this.showTemplates.selectedTemplate;
			   if( !selectedTemp || 
					   (selectedTemp.getData().templateId == "--None--" && !selectedTemp.getData().isNew)) {
				   isValid = true;
			   }
			   if(isValid == false){
				   SVMX.getCurrentApplication().showQuickMessage("error", $TR.MANDATORY_FIELDS);
			   }			   
			   return isValid;
		   },
		   
		   validateForm: function(){
			   return this.__validateForm();
		   }
		   
	       
		});
	
	}
})();