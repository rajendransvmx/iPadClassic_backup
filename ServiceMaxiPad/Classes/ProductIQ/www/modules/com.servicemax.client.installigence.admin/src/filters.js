(function(){
	var setupFilters = SVMX.Package("com.servicemax.client.installigence.admin.filters");

setupFilters.init = function() {
		
		Ext.define("com.servicemax.client.installigence.admin.ExpressionBuilder", {
	        extend: "com.servicemax.client.installigence.ui.components.Tree",
	        
	       constructor: function(config) {
	    	   
	    	   var me = this;
	    	   config.viewConfig = {
                   listeners: {
                       itemcontextmenu: {
                           fn: me.onViewItemContextMenu,
                           scope: me
                       },
                       
                       itemclick: { 
                            fn: me.onNodeClick,
                            scope: me
                       },
                       cellclick : function(view, cell, cellIndex, record,row, rowIndex, e) {
                    	   var selModel = this.getSelectionModel();
                       }
                   },
                   markDirty:false
               };
	    	   	    	   
	    	   me.addCondition = SVMX.create('Ext.Action', {
	    		   text: $TR.ADD_CONDITION,
				   iconCls: 'svmx-add-condition',	    		   
	    		   handler: function(widget, event) {
	    			   var rec = me.getSelectionModel().getSelection()[0];
	    			   rec.appendChild({exprType: "expression", expandable:false, iconCls: 'svmx-no-icon', expanded: true})
	    		   }
	    	   });
	    	   
	    	   me.addGroup = SVMX.create('Ext.Action', {
	    		   text: $TR.ADD_GROUP,
				   iconCls: 'svmx-add-group',
	    		   menu: {
	                    xtype: 'menu',
	                    items: [
                            me.createGroup('And', $TR.AND, 'svmx-and-operator'),
                            me.createGroup('Or', $TR.OR,'svmx-or-operator'),
                            me.createGroup('Not And', $TR.NOT_AND, 'svmx-not-and-operator'),
                            me.createGroup('Not Or', $TR.NOT_OR,'svmx-not-or-operator')
                        ]
	                }
	    	   });
	    	   
	    	   me.changeGroup = SVMX.create('Ext.Action', {
	    		   text: $TR.CHANGE_GROUP,
				   iconCls: 'svmx-change-group',
	    		   menu: {
	                    xtype: 'menu',
	                    items: [
							me.modifyGroup('And', $TR.AND, 'svmx-and-operator'),
                            me.modifyGroup('Or', $TR.OR, 'svmx-or-operator'),
                            me.modifyGroup('Not And', $TR.NOT_AND, 'svmx-not-and-operator'),
                            me.modifyGroup('Not Or', $TR.NOT_OR, 'svmx-not-or-operator')
                
                        ]
	                }
	    	   });
	    	   
	    	   me.deleteGroup = SVMX.create('Ext.Action', {
	    		   text: $TR.DELETE_GROUP,
				   iconCls: 'svmx-delete-group',	    		   
	    		   handler: function(widget, event) {
	    			   var rec = me.getSelectionModel().getSelection()[0];
	    			   while(rec.firstChild) {
	    				   rec.removeChild(rec.firstChild);
	    			   }
	    			   rec.remove(true);
	    			   
	    			   me.getStore().sync();
	    		   }
	    	   });
	    	   
	    	   config.columns = [{
	               xtype: 'treecolumn', //this is so we know which column will show the tree
	               text: 'Task',
	               sortable: true,
	               width: 300,
	               dataIndex: 'operator',
	               renderer: function(value, meta, currentRecord) {
		    		   var currTypeValue = currentRecord.get('exprType');
		    		   if(currTypeValue === "expression" ) {
		    			   var parentNodeDepth = currentRecord.parentNode.data.depth;
			    		   var tdWidth = 35 * parentNodeDepth;
		    			   meta.tdStyle = "width:" + tdWidth + "px;";
		    		   }
		    		   return value;
	               }
	           }];
	    	   var fieldsColumn = this.createComboBoxColumn({text: 'Fields', dataIndex: 'field', width:250
						, store: config.ibFieldStore, displayField: 'fieldLabel', valueField: 'fieldAPIName', defaultValue: 'Account'});
	    	   config.columns.push(fieldsColumn);   	   
	    	   config.columns.push(this.createComboBoxColumn({text: 'Condition', dataIndex: 'condition', width:200
	    		   						, store: config.operatorsStore, displayField: 'opLabel', valueField: 'opValue', defaultValue: 'Equals'}));   	   
	    	   config.columns.push(this.createTextBoxColumn({text: 'Value', dataIndex: 'value', width:150}));
	    	   config.columns.push(
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
	    	  		                    rec.remove(true);
	    	  		                    gridStore.sync();
	    	  		                    
	    	  		                },
	    	  		                
	    	  		                renderer: function (value, metadata, record) {
	    	  		                	if (record.get('exprType') === "expression") {
		    	  		                    config.columns[4].items[0].iconCls = 'delet-icon';
		    	  		                } else {
		    	  		                    config.columns[4].items[0].iconCls = '';
		    	  		                }
	    	  		                }		
	    	  					}                  
	    	                 );
	    	   config = config || {};
	    	   config.items = [];
	    	   this.callParent([config]);
	       },
	       
	       onViewItemContextMenu: function(dataview, record, item, index, e) {
	    	  e.stopEvent();
	    	  var contextMenu;
	    	  if(record.get("exprType") === 'operatorroot' || record.get("exprType") === 'operator') {
	    		   contextMenu = new Ext.menu.Menu({
	    			   items: [this.addCondition, this.addGroup, '-', this.changeGroup]
	    		   });
	    		   if(record.get("exprType") === 'operator'){
	    			   contextMenu.add(this.deleteGroup);
    	  		   }
	    		   contextMenu.showAt(e.getXY());
	    	  }	    	   
	       },
	       
	       createGroup: function(value ,text, iconcls) {
	    	   var group = {};
	    	   group.text = text;
			   group.iconCls = iconcls;
	    	   group.context = this;
	    	   group.handler = function(widget, event) {
    			   var rec = this.context.getSelectionModel().getSelection()[0];
    			   rec.appendChild({operator: text, exprType: "operator", iconCls: iconcls, expanded: true, operator_key: value})
	    	   }  
	    	   return group;
	       },
	       
	       modifyGroup: function(value, text, iconcls) {
	    	   var group = {};
	    	   group.text = text;
			   group.iconCls = iconcls;
	    	   group.context = this;
	    	   group.handler = function(widget, event) {
    			   var rec = this.context.getSelectionModel().getSelection()[0];
    			   rec.data.operator = text;
    			   rec.data.operator_key = value;
    			   rec.set('iconCls',iconcls);
    			   rec.set('title', text);
	    	   }  
	    	   return group;
	       },
	       
	       createTextBoxColumn: function(fieldInfo) {
	    	   
	    	   var txtboxCol = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXTextField',{
	    		   allowBlank : true,
	    		   editable : true,
	    		   emptyText: $TR.ENTER_VALUE
	    	   });
	    	   
	    	   var fieldInfo = fieldInfo || {};
	    	   fieldInfo.editor = {
                   xtype: 'textfield',
                   emptyText: $TR.ENTER_VALUE
                   
               };
               fieldInfo.renderer = function(value, meta, currentRecord){
            	   var currTypeValue = currentRecord.get('exprType');
	    		   if(currTypeValue === "expression" ) {	    			   
	    			   if (value === undefined || value === "") {
	    				    meta.tdStyle = 'color:#ccc';
	    	                return 'enter a value';
	    	            } 
	    		   }
                   return value;
               };
	    	   return fieldInfo;
	       },
	       
	       createComboBoxColumn: function(fieldInfo) {
	    	   var me = this;
	    	   
	    	   var picklist = SVMX.create('com.servicemax.client.installigence.admin.celleditors.SVMXComboBoxCellEditor',{
					store: fieldInfo.store,
			        displayField: fieldInfo.displayField,
			        value: fieldInfo.defaultValue,
			        valueField: fieldInfo.valueField,
			        fieldName: fieldInfo.dataIndex,
			        queryMode: 'local',
			        width: '80px',
			        editable: false
	    	   });	    	   
	    	   
	    	   var fieldInfo = fieldInfo || {};
	    	   fieldInfo.renderer = function(value, meta, currentRecord) {
	    		   var currTypeValue = currentRecord.get('exprType');
	    		   picklist.setRecord(currentRecord);                   
	    		   if(currTypeValue === "expression" ) {
	    			   meta.tdCls = 'svmx-default-content';	    			   
	    			   if(value === undefined || value.length === 0) {
		    			   picklist.setValue(fieldInfo.store.getAt('0').get(fieldInfo.valueField));
		    			   value = picklist.getValue();
		    		   }	    			   
	    		   }	    		   
	    		   return value;
	    	   };
	    	   
	    	   fieldInfo.menuDisabled = true;
	    	   fieldInfo.sortable = false;
	    	   fieldInfo.getEditor = function(currentRecord){
	    		   var currTypeValue = currentRecord.get('exprType');
	    		   if(currTypeValue !== "expression") {
	    			   return "";
	    		   }
	    		   picklist.setRecord(currentRecord); 
	    		   return picklist;
               };
	    	   return fieldInfo;	    	   
	    	   
	       }
		});
		
		Ext.define("com.servicemax.client.installigence.admin.Filters", {
		    extend: "com.servicemax.client.installigence.ui.components.SVMXPanel",
		   cls: 'grid-panel-borderless panel-radiusless',
		    
		    
		   constructor: function(config) {		   
			   
			    var me = this;
				me.filtersPanel = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXPanel',{
						cls: 'grid-panel-borderless panel-radiusless',
						plain : 'true',
						height: 200,
						width: '100%'					   
				});
				
				me.searchFiltersToolbar = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXToolbar',{
					style: 'border-width: 0'
				});
				
				me.addFilterRecButton = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXButton',{
					//cls: 'plain-btn',
					ui: 'svmx-toolbar-icon-btn',
					scale: 'large',
					iconCls: 'plus-icon',
					disabled: true,
					handler : function(){
						me.onAddRecords();
					}
				});
				
				me.filtersTextSearch = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXTextSearch',{
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
				
				me.searchFiltersToolbar.add(me.filtersTextSearch);
				me.searchFiltersToolbar.add('->');
				me.searchFiltersToolbar.add(me.addFilterRecButton);
								
				//the below data model have to be replaced with the actual data
				me.filterStore = SVMX.create('com.servicemax.client.ui.components.composites.impl.SVMXStore', {
				    fields: [ {name: 'name',  type: 'string'},
				              {name: 'isGlobal', type: 'boolean'} ,
				              {name: 'expression',   type: 'auto'}],
				    data: [				        
				    ]
				});
				
				me.filtersSearchGrid = SVMX.create('com.servicemax.client.installigence.admin.userActionsGrid',{
					cls: 'grid-panel-borderless panel-radiusless',
					store: me.filterStore,
					height: 150,
				    selType: 'cellmodel',
				    plugins: [
			              SVMX.create('com.servicemax.client.installigence.ui.components.SVMXCellEditorPlugin', {
			                  clicksToEdit: 2
			              })
			          ],
			        isFiltersGrid: true,
			        selectedExpression: undefined,
			        listeners: {
			             itemclick: function(dataview, record, item, index, e) {
			            	 me.expressiontree.setDisabled(false);
			            	 me.__persistNLoadExpression(record);
			             }
			        },
			        
			        nameFieldListner: {
			        	change: function(field, value) {
			        		 if(me.expressiontree.getStore().getData().items[0] !== undefined) {
			  	    		   me.expressiontree.getStore().getData().items[0].data.operator = value;
			  				   me.expressiontree.getStore().getData().items[0].set("title", value);
			  	    	   	}
			            }
			        }
	            });
				
				Ext.define('expressionModel', {
				    extend: 'Ext.data.Model',
				    fields: [{name: "operator", type: 'string'}, 
				             {name: "field", type: 'string'}, 
				             {name: "condition", type: 'string'}, 
				             {name: "value", type: 'string'}]
				});
				
				var expressionStore = Ext.create('Ext.data.TreeStore', {
					model: 'expressionModel',
				   root: {
					   nodeType: 'async',
					   attributes : [],
					   expanded: true,
					   children:[
				            { operator: $TR.SELECTED_EXPR, exprType: "root", iconCls:'svmx-expression-icon', expanded: true, 
				            	children: [{operator: 'And', exprType: "operatorroot", iconCls:'svmx-and-operator', expanded: true}]
				            }			            
					   ]
				   }
				});				
				
				var ibFieldsStore = this.__getIBFieldsStore(config.metadata);
				
				me.expressiontree = SVMX.create('com.servicemax.client.installigence.admin.ExpressionBuilder', { 
				   cls: 'grid-panel-borderless svmx-tree-panel svmx-expression-tree',
				   margin: '5 7 7 7',
				   //width: '100%',
				   height: 238,
				   store: expressionStore, 
				   header: false,
				   disabled: true,
				   selType: 'cellmodel',
				   plugins: [
			              SVMX.create('com.servicemax.client.installigence.ui.components.SVMXCellEditorPlugin', {
			                  clicksToEdit: 1
			              })
		              ],
		           
				   rootVisible: false,
				   ibFieldStore: ibFieldsStore,
				   operatorsStore: this.__getOperatorsStore()
				});
			   
				config = config || {};
				config.items = [];
				config.items.push(me.searchFiltersToolbar);
				config.items.push(me.filtersSearchGrid);
				config.items.push(me.expressiontree);
				this.callParent([config]);
			   
		   },
		   
		   __getIBFieldsStore: function(metadata) {
			   var data = metadata[SVMX.OrgNamespace + "__Installed_Product__c"] ? metadata[SVMX.OrgNamespace + "__Installed_Product__c"]["fields"] : [];
			   var fields = SVMX.create('com.servicemax.client.ui.components.composites.impl.SVMXStore', {
			        fields: ['fieldAPIName', 'fieldLabel'],
			        data: data,
			        sorters: [{
			            property: 'fieldLabel',
			            direction: 'ASC'
			        }],
			        sortRoot: 'fieldLabel',
			        sortOnLoad: true,
			        remoteSort: false,
			   });
			   return fields;
		   },
		   
		   __getOperatorsStore: function(metadata) {
			   var data = [{opLabel: $TR.EQUALS, opValue: "equals"},
			               {opLabel: $TR.NOT_EQUAL, opValue: "notequal"},
			               {opLabel: $TR.GREATER_THAN, opValue: "greaterthan"},
			               {opLabel: $TR.GREATER_OR_EQUAL, opValue: "greaterorequalto"},
			               {opLabel: $TR.LESS_THAN, opValue: "lessthan"},
			               {opLabel: $TR.LESS_OR_EQUAL, opValue: "lessorequalto"},
			               {opLabel: $TR.STARTS_WITH, opValue: "startswith"},
			               {opLabel: $TR.CONTAINS, opValue: "contains"},
			               {opLabel: $TR.DOES_NOT_CONTAIN, opValue: "doesnotcontain"},
			               {opLabel: $TR.INCLUDES, opValue: "includes"},
			               {opLabel: $TR.EXCLUDES, opValue: "excludes"},
			               {opLabel: $TR.ISNULL, opValue: "isnull"},
			               {opLabel: $TR.ISNOTNULL, opValue: "isnotnull"}]
			   var fields = SVMX.create('com.servicemax.client.ui.components.composites.impl.SVMXStore', {
			        fields: ['opValue', 'opLabel'],
			        data: data
			   });
			   return fields;
		   },
	         
		   onTextFieldChange: function() {
			   var value = this.filtersTextSearch.getValue();
			   this.filtersSearchGrid.search(value);
		   },
         
		   onAddRecords: function() {
			   this.filtersSearchGrid.addItems({parentProfileId: this.filtersSearchGrid.selectedProfileId});
		   },
		   
		   persistNLoadExpression : function(record){
	    	   this.__persistNLoadExpression(record);
	       },
		   
		   __persistNLoadExpression: function(record) {
	    	   //store the existing Expression information to previous selected Expression
	    	   var prevSelExpression = this.filtersSearchGrid.selectedExpression;
	    	   if(this.filtersSearchGrid.selectedExpression) {
	    		   this.__persistExpression(prevSelExpression);
	    	   }
	    	   //load the Expression information to selected Expression
	    	   this.filtersSearchGrid.selectedExpression = record.getData ? record : undefined;
	    	   this.__loadExpression(record.getData ? record.getData() : {});
			   
		   },
		   
		   __persistExpression: function(record) {
			   var expressionInfo = {};
			   expressionInfo.children = this.__getRecords(this.expressiontree.getStore().getRootNode().childNodes[0]);
	    	   var storeRec = record;
	    	   if(storeRec) {
	    		   storeRec.set("expression", expressionInfo);
	    	   }
		   },
		   
	       __getRecords: function(rootNode) {
	    	 
	    	   return this.__getChildNodes(rootNode);
	       },
	       
	       __getChildNodes: function(node) {
	    	   
	    	   var rec = {};
	    	   if(node !== undefined && node.getData() !== undefined) {
		    	   rec.operator = node.getData().operator_key;
		    	   rec.exprType = node.getData().exprType;
		    	   rec.field = node.getData().field_key;
		    	   rec.condition = node.getData().condition_key;
		    	   rec.value = node.getData().value;
		    	   rec.expanded = true;
		    	   rec.iconCls = node.getData().iconCls;
		    	   if(node.isLeaf()) return;
		    	   if(node.childNodes && node.childNodes.length > 0){
		    		   rec.children = [];
			    	   var children = node.childNodes || [], i, l = children.length;
			    	   for(i = 0; i < l; i++){
			    		   rec.children.push(this.__getChildNodes(children[i]));
			    	   }
		    	   }
		    	   
	    	   }
	    	   return rec;	    	   
	       },
	       
		   __loadExpression: function(record) {
			   
			   if(record.expression === undefined || record.expression.length === 0) {
				   record.expression = {
					   nodeType: 'sync',
					   attributes : [],
					   expanded: true,
					   children:[
				            { operator: $TR.SELECTED_EXPR, exprType: "root", expanded: true, 
				            	children: [{operator: $TR.AND, exprType: "operatorroot", expanded: true, children:[], operator_key: "And"}]
				            }			            
					   ]
				   }
	    	   }
			   
			   this.__loadIconClsForNodes(record.expression.children[0] || record.expression.children);
	    	   this.expressiontree.getStore().setRootNode({
	    		   nodeType: 'sync',
				   attributes : [],
				   expanded: true,
    			   children: record.expression.children
    		   });
	    	   this.expressiontree.getStore().getRootNode().expand(true);
	    	   if(this.expressiontree.getStore().getData().items[0] !== undefined) {
	    		   this.expressiontree.getStore().getData().items[0].data.operator = record.name;
				   this.expressiontree.getStore().getData().items[0].set("title",record.name);
	    	   }	    	   
		   },
		   
		   __loadIconClsForNodes: function(record) {
			   
			   if(record.exprType === "root") {
				   record.iconCls = "svmx-expression-icon";
			   }else if(record.exprType === "operator" || record.exprType === "operatorroot") {
				   record.operator_key = record.operator;
				   if(record.operator === "And") {
					   record.operator = $TR.AND;
					   record.iconCls = "svmx-and-operator";
				   }else if(record.operator === "Or") {
					   record.operator = $TR.OR;
					   record.iconCls = "svmx-or-operator";
				   }else if(record.operator === "Not And") {
					   record.operator = $TR.NOT_AND;
					   record.iconCls = "svmx-not-and-operator";
				   }else if(record.operator === "Not Or") {
					   record.operator = $TR.NOT_OR;
					   record.iconCls = "svmx-not-or-operator";
				   }
			   }else if(record.exprType === "expression") {
				   record.iconCls = "svmx-no-icon";
				   record.expandable = false;
				   record.field_key = record.field;
				   record.condition_key = record.condition;
				   record.condition = this.__getOperatorsStore().findRecord("opValue", record.condition) !== null ? 
						   this.__getOperatorsStore().findRecord("opValue", record.condition).get("opLabel") : record.condition;
				   record.field = this.__getIBFieldsStore(this.metadata).findRecord("fieldAPIName", record.field) ? 
						   this.__getIBFieldsStore(this.metadata).findRecord("fieldAPIName", record.field).get("fieldLabel") : record.field;
			   }
			   if(record.children) {
				   var iData = 0, iLength = record.children.length || 0;
				   for(iData = 0; iData < iLength; iData++) {
					   this.__loadIconClsForNodes(record.children[iData]);
				   }
			   }
			   return record;
		   }
		});
	}
})();