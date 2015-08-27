
(function(){
	var svmxComponents = SVMX.Package("com.servicemax.client.installigence.ui.components");

svmxComponents.init = function() {
		
		Ext.define('com.servicemax.client.ui.components.composites.impl.SVMXStore', {
            extend: 'Ext.data.Store',
            alias: 'widget.svmx.store',

            constructor: function(config) {
                if (!config) config = {};
                this.callParent([config]);
            },

            /**
             * Search the store for a given text.
             * @param searchtext - The text to be searched
             * Currently only local searching is supported
             */
            searchStore: function(searchtext) {
                // clear any existing filter
                store.clearFilter();
                if (searchtext) {
                    store.filterBy(function(record) { //
                        var retval = false;
                        var iFields, length = record.fields.length;
                        for(iFields = 0; iFields < length; iFields++) {
                        	var field = record.fields[iFields];
                        	var recValue = record.get(record.fields[iFields].name)
                            var regExp = new RegExp(searchtext, 'gi');
                            retval = regExp.test(recValue);
                            if (retval) {
                                return true;
                            }
                        }                    	
                        return retval;
                    }); //TODO : will have to pass the store's instance once remote searching feature is introduced.
                }
            },
            
            getStoreRecords: function() {
            	var records = [];
            	store.each(function(rec) {
            		delete rec.data["id"];
            		records.push(rec.data);
            	});
            	return records;
            }
        });

		 Ext.define("com.servicemax.client.installigence.ui.components.SVMXPanel", {
	         extend: "Ext.panel.Panel",
	         alias: 'widget.svmx.panel',
	         
	         constructor: function(config) {
	             config = Ext.apply({
	                 collapsible: false
	             }, config || {});
	             this.callParent([config]);
	         }
	     });
		 
		 Ext.define("com.servicemax.client.installigence.ui.components.SVMXCarousel", {
	         extend: "Ext.panel.Panel",
	         alias: 'widget.svmx.panel', __id : null, __rendered : null, __contentCache : null,
	         
	         constructor: function(config) {
	             this.__id = Ext.id(null, "carousel-");
	             
	        	 config = Ext.apply({
	                 collapsible: false,
	                 html : '<div style="width:100%;text-align:center;padding:20px" id="' + this.__id + '"></div>'
	             }, config || {});
	             this.callParent([config]);
	         },
	         
	         setContent : function(content){
	        	 if(!this.__rendered) {
	        		 this.__contentCache = content;
	        		 return;
	        	 }
	        	 
	        	 var root = "#" + this.__id;
	        	 $(root).hide();
	        	 $(root).html(content);
	        	 $(root).slick({
	        		 autoplay: true
	             });
	        	 
	        	 // hack. otherwise all images are displayed at the beginning!
	        	 setTimeout(function(){
	        		 $(root).show();
	        	 }, 3000);
	         },
	         
	         afterRender : function(){
	        	 this.callParent();
	        	 this.__rendered = true;
	        	 
	        	 if(this.__contentCache) {
	        		 var tmp = this.__contentCache;
	        		 this.__contentCache = null;
	        		 this.setContent(tmp);
	        	 }
	         }
	     });
		 
		 Ext.define("com.servicemax.client.installigence.ui.components.SVMXFormPanel", {
	         extend: "Ext.form.Panel",
	         alias: 'widget.svmx.formpanel',
	         
	         constructor: function(config) {
	             config = Ext.apply({
	                 collapsible: false
	             }, config || {});
	             this.callParent([config]);
	         }
	     });
		 
		 Ext.define("com.servicemax.client.installigence.ui.components.SVMXFieldContainer", {
	         extend: "Ext.form.FieldContainer",
	         alias: 'widget.svmx.fieldcontainer',
	         
	         constructor: function(config) {
	             config = Ext.apply({
	             }, config || {});
	             this.callParent([config]);
	         }
	     });
		 
		 Ext.define("com.servicemax.client.installigence.ui.components.SVMXTabPanel", {
	         extend: "Ext.TabPanel",
	         alias: 'widget.svmx.tabpanel',
	         
	         constructor: function(config) {	             
	             this.callParent([config]);
	         }
	     });
		 
		 Ext.define("com.servicemax.client.installigence.ui.components.SVMXButton", {
	         extend: "Ext.Button",
	         alias: 'widget.svmx.button',
	         
	         constructor: function(config) {	             
	             this.callParent([config]);
	         }
	     });
		 
		 Ext.define("com.servicemax.client.installigence.ui.components.SVMXGrid", {
	         extend: "Ext.grid.Panel",
	         alias: 'widget.svmx.grid',
	         
	         constructor: function(config) {	             
	             this.callParent([config]);
	         },
	         
	         /** Search SVMXListComposite's store.
             * Search happens on the store associated with SVMXListComposite
             * @param {searchtext} - Text to be searched.
             * */
            search: function(searchtext) {
                if (!this.store) return;
                store = this.store;
                store.searchStore(searchtext);
            },
            
            /** Adds   {Ext.data store, ArrayStore} into SVMXListComposite.
             * @param {object/array...} - New records to be added.
             * New records will be added to the end of the grid
             * */
            addItems: function(records) {
                if (!records) return;
                this.store.insert(this.getStore().count(), records);
            },
            
            getRecords: function() {
            	if (!this.store) return;
            	store = this.store;
                return store.getStoreRecords();                
            }
	         
	     });
		 
		 Ext.define("com.servicemax.client.installigence.ui.components.SVMXTextSearch", {
	         extend: "Ext.form.field.Text",
	         alias: 'widget.svmx.searchtext',
	         
	         constructor: function(config) {	
	        	 this.callParent([config]);
	         }
	     });
		 
		 Ext.define("com.servicemax.client.installigence.ui.components.SVMXTextField", {
	         extend: "Ext.form.field.Text",
	         alias: 'widget.svmx.textfield',
	         
	         constructor: function(config) {	
	        	 this.callParent([config]);
	         }
	     });
		 
		 Ext.define("com.servicemax.client.installigence.ui.components.SVMXDisplayField", {
	         extend: "Ext.form.field.Display",
	         alias: 'widget.svmx.displayfield',
	         
	         constructor: function(config) {	
	        	 this.callParent([config]);
	         }
	     });
		 
		 Ext.define("com.servicemax.client.installigence.ui.components.SVMXComboBox", {
	         extend: "Ext.form.field.ComboBox",
	         alias: 'widget.svmx.combobox',
	         
	         constructor: function(config) {	
	        	 this.callParent([config]);
	         },
         
	         getRecords: function() {
	         	if (!this.store) return;
	         	store = this.store;
	             return store.getStoreRecords();                
	         }
		 
	     });
		
		 Ext.define("com.servicemax.client.installigence.ui.components.SVMXToolbar", {
	         extend: "Ext.toolbar.Toolbar",
	         alias: 'widget.svmx.toolbar',
	         
	         constructor: function(config) {	
	        	 this.callParent([config]);
	         }
	     });
	     
	     Ext.define("com.servicemax.client.installigence.ui.components.SVMXProgressBar", {
	         extend: "Ext.ProgressBar",
	         alias: 'widget.svmx.progressbar',
	         
	         constructor: function(config) {	
	        	 this.callParent([config]);
	         }
	     });
	     
	     Ext.define("com.servicemax.client.installigence.ui.components.SVMXCellEditor", {
	         extend: "Ext.grid.CellEditor",
	         alias: 'widget.svmx.celleditor',
	         
	         constructor: function(config) {	
	        	 this.callParent([config]);
	         }
	     });
	     
	     Ext.define("com.servicemax.client.installigence.ui.components.SVMXCellEditorPlugin", {
	         extend: "Ext.grid.plugin.CellEditing",
	         alias: 'widget.svmx.celleditorplugin',
	         
	         constructor: function(config) {	
	        	 this.callParent([config]);
	         }
	     });
	     
	     Ext.define("com.servicemax.client.installigence.ui.components.SVMXTree", {
	         extend: "Ext.tree.Panel",
	         alias: 'widget.svmx.tree',
	         
	         constructor: function(config) {	
	        	 this.callParent([config]);
	         },
	     
     		/** Search SVMXListComposite's store.
	          * Search happens on the store associated with SVMXListComposite
	          * @param {searchtext} - Text to be searched.
	          * */
	         search: function(searchtext) {
	             if (!this.store) return;
	             store = this.store;
	             store.searchStore(searchtext);
	         }
	     });
	     
	     Ext.define("com.servicemax.client.installigence.ui.components.SVMXFieldSets", {
	         extend: "Ext.form.FieldSet",
	         alias: 'widget.svmx.fieldset',
	         
	         constructor: function(config) {	
	        	 this.callParent([config]);
	         }
	     });
	     
	     Ext.define("com.servicemax.client.installigence.ui.components.Menu", {
	         extend: "Ext.menu.Menu",
	         alias: 'widget.svmx.menu',
	         
	         constructor: function(config) {	
	        	 this.callParent([config]);
	         }
	     });
	     
	     Ext.define("com.servicemax.client.installigence.ui.components.Checkbox", {
	         extend: "Ext.form.field.Checkbox",
	         alias: 'widget.svmx.checkbox',
	         
	         constructor: function(config) {	
	        	 this.callParent([config]);
	         }
	     });
	     
	     Ext.define("com.servicemax.client.installigence.ui.components.SVMXCheckboxGroup", {
	         extend: "Ext.form.CheckboxGroup",
	         alias: 'widget.svmx.checkboxgroup',
	         
	         constructor: function(config) {	
	        	 this.callParent([config]);
	         }
	     });
	     
	     Ext.define("com.servicemax.client.installigence.ui.components.Label", {
	         extend: "Ext.form.Label",
	         alias: 'widget.svmx.label',
	         
	         constructor: function(config) {	
	        	 this.callParent([config]);
	         }
	     });
	     
	     Ext.define("com.servicemax.client.installigence.ui.components.Tree", {
	         extend: "Ext.tree.Panel",
	         alias: 'widget.svmx.tree',
	         
	         constructor: function(config) {	
	        	 this.callParent([config]);
	         },
	         
	         search : function(txt){
	        	 // clear all the highlighting
	        	 this.clearSearch();
	        	 
	        	 var rn = this.getRootNode();
	        	 
	        	 if(!txt) return;
	        	 if(!rn) return;
	        	 
	        	 this.__search(rn, txt);
	         },
	         
	         __search : function(node, txt){
	        	 var re = new RegExp( txt, 'i' );
	        	 if(re.test(node.data.text)){
	        		 this.__highlightNode(node);
	        	 }
	        	 
	        	 if(node.isLeaf()) return;
	        	 
	        	 // check for child node
	        	 var children = node.childNodes || [], i, l = children.length;
	        	 for(i = 0; i < l; i++){
	        		 this.__search(children[i], txt);
	        	 }
	         },
	         
	         __highlightNode : function(node){
	        	 var v = this.getView();
	        	 setTimeout(function(){
	        		 var n = v.getNode(node);
	        		 if(n) Ext.fly(n).addCls("svmx-tree-search-node-highlight");
	        	 }, 1);
	         },
	         
	         clearSearch : function(){
	        	 var rn = this.getRootNode();
	        	 if(!rn) return;
	        	 
	        	 this.__clearSearch(rn);
	         },
	         
	         __clearSearch : function(node){
	        	 this.__clearHighlight(node);
	        	 
	        	 if(node.isLeaf()) return;
	        	 
	        	 // check for child node
	        	 var children = node.childNodes || [], i, l = children.length;
	        	 for(i = 0; i < l; i++){
	        		 this.__clearSearch(children[i]);
	        	 }
	         },
	         
	         __clearHighlight : function(node){
	        	 var v = this.getView();
	        	 setTimeout(function(){
	        		 var n = v.getNode(node);
	        		 if(n) Ext.fly(n).removeCls("svmx-tree-search-node-highlight");
	        	 },1);
	         }
	         
	     });
	     
	     Ext.define("com.servicemax.client.ui.components.controls.impl.SVMXImage", {
            extend: 'Ext.Img',
            alias: 'widget.svmx.image',
            constructor: function(root, config) {
                if (!config) config = {};
                this.callParent([root, config]);
            }
	     });
	     
	     Ext.define("com.servicemax.client.ui.components.controls.impl.SVMXDate", {
            extend: 'Ext.form.field.Date',
            alias: 'widget.svmx.datefield',
            constructor: function(config) {
                if (!config) config = {};
                this.callParent([config]);
            }
	     });
	     
	     Ext.define("com.servicemax.client.ui.components.controls.impl.SVMXTime", {
            extend: 'Ext.form.field.Time',
            alias: 'widget.svmx.timefield',
            constructor: function(config) {
                if (!config) config = {};
                this.callParent([config]);
            }
	     });
	     
	     Ext.define("com.servicemax.client.ui.components.controls.impl.SVMXDatetime", {
            extend: 'com.servicemax.client.installigence.ui.components.SVMXFieldContainer',
            alias: 'widget.svmx.datetimefield',
            __date :null, __time : null, __widthFromBoxReady : 0, __readOnly : false,
            
            constructor: function(config) {

                config = Ext.apply({
                	layout : { type : "hbox"},
                	items : [],
                	defaults: {
                        hideLabel: true
                    }
	             }, config || {});
                
                this.__readOnly = config.readOnly;
                this.callParent([config]);
            },
            
            initComponent : function(){
            	this.callParent();
            	this.__date = SVMX.create("com.servicemax.client.ui.components.controls.impl.SVMXDate", {
            		readOnly : this.__readOnly
            	});
                this.__time = SVMX.create("com.servicemax.client.ui.components.controls.impl.SVMXTime", {
                	readOnly : this.__readOnly
                });
                
            	this.__date.setWidth(0);
            	this.__time.setWidth(0);
            	this.add(this.__date);
            	this.add(this.__time);
            },
            
            onAdded : function( container, pos, instanced ){
            	this.callParent([ container, pos, instanced ]);
            	
            	var me = this;
            	container.on("resize", function(){
            		me.readjustItemsWidth(container.getWidth() - 40);
            	}, this);
            	
            	container.on("all_fields_added", function(){
            		me.readjustItemsWidth(container.getWidth() - 40);
            	}, this);
            },
            
            onBoxReady : function(width, height){
            	this.callParent([ width, height ]);
            	this.__widthFromBoxReady = width;
            },
            
            readjustItemsWidth : function(width){
            	var labelWidth = this.labelEl.getWidth();
            	var availableWidth = width - labelWidth; // 25 scrollbar
            	this.__date.setWidth(availableWidth/2);
            	this.__time.setWidth(availableWidth/2);
            },
            
            setValue : function(value){
            	var dateVal = "", timeVal = "";
            	if(value && value.length > 0){
            		value = value.split("T");
            		if(value.length > 1){
            			dateVal = value[0];
            			timeVal = value[1];
            		}
            	}
            	
            	this.__date.setValue(dateVal);
            	this.__time.setValue(new Date(value[0] + " " + value[1]));
            },
            
            getValue : function(value){
            	return Ext.Date.format(this.__date.getValue(),"Y-m-d") + "T" + 
            	Ext.Date.format(this.__time.getValue(),"h:i:s");
            },
            
            getTimeField : function(){
            	return this.__time;
            },
            
            getDateField : function(){
            	return this.__date;
            }
	     });
	     
	     Ext.define("com.servicemax.client.ui.components.controls.impl.SVMXWindow", {
            extend: 'Ext.window.Window',
            alias: 'widget.svmx.window',
            constructor: function(root, config) {
                if (!config) config = {};
                this.callParent([root, config]);
            }
	     });
	     	     	     
	     Ext.define('com.servicemax.client.installigence.ui.components.DragZone', {
	    	    override: 'Ext.view.DragZone',
	    	    init: function(id, sGroup, config) {
	    	        var me = this,
	    	            eventSpec = {
	    	                itemmousedown: me.onItemMouseDown,
	    	                scope: me
	    	            };

	    	        // If there may be ambiguity with touch/swipe to scroll and a drag gesture
	    	        // *also* trigger drag start on longpress
	    	        if (Ext.supports.touchScroll) {
	    	            eventSpec['itemlongpress'] = me.onItemMouseDown;
	    	        }
	    	        me.initTarget(id, sGroup, config);
	    	        me.view.mon(me.view, eventSpec);
	    	    }
	     });
	     
	     Ext.define("com.servicemax.client.installigence.ui.components.SVMXLookup", {
	         extend: "Ext.form.FieldContainer",
	         alias: 'widget.svmx.lookup',
	         
	         constructor: function(config) {
	        	 var me = this;
	        	 config = config || [];
	                // set default to no items
	        	 config.items = config.items || [];
	        	 config.layout = 'hbox';
	        	 
	        	 var productDisplayFields = this.__getFields(config.meta.productDisplayFields || [{name: 'Name', name: 'SVMXC__Replacement_Available__c'}]);
	        	 var productSearchFields = this.__getSearchFields(config.meta.productSearchFields || [{name:'Name'}]);
	        	 me.getValue = function() {
	        		 return me.lookupText.getValue();
	        	 };
	        	 
	        	 me.getIdValue = function() {
	        		 return me.lookupText.idValue;
	        	 }
	        	 
	        	 me.setValue= function(value) {
	        		 me.lookupText.setValue(value); 
	        	 }
	        	 
	        	 me.setIdValue= function(value) {
	        		 me.lookupText.idValue = value; 
	        	 }
	             
                 me.lookupBtn = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXButton', {
                	 iconCls: 'svmx-lookup-icon',
 					 margin: '0, 5', 
                     flex: 1
                 });
	        	 
	        	 me.lookupText = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXTextField', {
                     minWidth: 5,
                     width: 305,
                     listeners: {
                    	 specialkey: function(f,e){
                             if(e.getKey() == e.ENTER){
                            	 me.lookupBtn.fireEvent('click', me.lookupBtn);
                             }
                         }
                     }
                 });	       	 
	        	
	        	
				//the below data model have to be replaced with the actual data
	        	 me.datastore = SVMX.create('com.servicemax.client.ui.components.composites.impl.SVMXStore', {
	        		fields: productDisplayFields
	        	 });
	        	 var l = productDisplayFields.length;
	        	 var gridColumns = [], objectInfo = config.meta.Product2, j, oFields = objectInfo ? objectInfo.fields : [], t = oFields.length, c;
				 for(i = 0; i < l; i++){
	 				c = productDisplayFields[i];
	 				for(j = 0; j < t; j++){
	 					if(c == oFields[j].fieldAPIName && c != "Id"){
	 						gridColumns.push({ text : oFields[j].fieldLabel, dataIndex : c, flex : 1 });
	 					}
	 				}
				 }
	        	 me.dataGrid = SVMX.create('com.servicemax.client.installigence.ui.components.SVMXGrid',{
	        		 store: me.datastore,forceFit : true, columns: gridColumns, flex : 1, width: "100%", autoScroll: true,	        		 	 
	        		 viewConfig: {
	    			    listeners: {
	    			        itemdblclick: function(dataview, record, item, index, e) {
	    			            me.lookupText.setValue(record.data.Name);
	    			            me.lookupText.idValue = record.data.Id;
	    			            if(me.config.onValueSelected)
	    			            	me.config.onValueSelected("", record.data.Name, record.data.Id);
	    			            me.win.close();
	    			        }
	    			    }
	        		 }
	        	 });
	        	 
	        	 me.lookupBtn.on('click', function(){
	        		me.getLookupData(me.lookupText.getValue(), productDisplayFields, productSearchFields, config.meta.Product2);		        	 
        	        if (!me.win) {
        	            me.win = SVMX.create('com.servicemax.client.ui.components.controls.impl.SVMXWindow', {
        	            	
        	            	layout : {type : "vbox"}, height : 400, width : 340,
        					closable: true, maximizable: false, animateTarget: me.lookupBtn,
        	                minWidth: 340 , layout: {
        	                    padding: 5
        	                }, layout : 'fit', items : [me.dataGrid],
        	                closeAction: 'hide', modal : true
        	            	
        	            });
        	            
        	            var toXY = me.lookupText.getXY();
       	        	 	me.win.setPosition(toXY[0], toXY[1] + 30);	       	        	 	
        	        }
	        	        //me.win.show();
	        	 });
	        	 
	        	 config.items.push(me.lookupText);
	        	 config.items.push(me.lookupBtn);
	        	 
	        	 this.callParent([config]);
	         },
	         
	         getLookupData: function(filtertext, displayFields, searchFields, descInfo) {
	 	       	var me = this;
		       	var evt = SVMX.create("com.servicemax.client.lib.api.Event",
								"UICOMPONENTS.GET_LOOKUP_DATA", me,
								{request : { context : me, filter: filtertext, 
									displayFields: displayFields, searchFields: searchFields, productDesc: descInfo}});
		       	
		       	SVMX.getCurrentApplication().getEventBus().triggerEvent(evt);
	         },
	 		
	 		__getFields : function(fields){
	 			var colFields = ["Id", "Name"];

	 			var i = 0, l = fields.length;
	 			for(i = 0; i < l; i++){
	 				if(fields[i].name && fields[i].name.toLowerCase() == "id") continue;
	 				if(fields[i].name && fields[i].name.toLowerCase() == "name") continue;
	 				colFields.push(fields[i].name);
	 			}
	 			
	 			return colFields;
	 		},
	 		
	 		__getSearchFields : function(fields){
	 			var colFields = [];
	 			var i = 0, l = fields.length;
	 			for(i = 0; i < l; i++){				
	 				colFields.push(fields[i].name);
	 			}
	 			
	 			return colFields;
	 		},
	         
	         onGetLookupDataComplete: function(data) {
	        	 var me = this;
	        	 me.datastore.loadData(data);	        	 
	        	 me.win.show();
	         },
	         
	         
	     });
	     
	     Ext.override(Ext.layout.container.Card, {
	    	 setActiveItem: function (newCard) {
	    		 var me = this, owner = me.owner, oldCard = me.activeItem, rendered = owner.rendered, newIndex;
	    		 
	    		 newCard = me.parseActiveItem(newCard);
	    	     newIndex = owner.items.indexOf(newCard);

	    	     // If the card is not a child of the owner, then add it.
	    	     // Without doing a layout!
	    	     if (newIndex === -1) {
	    	    	 newIndex = owner.items.items.length;
	    	    	 Ext.suspendLayouts();
	    	    	 newCard = owner.add(newCard);
	    	    	 Ext.resumeLayouts();
	    	     }

	    	     // Is this a valid, different card?
	    	     if (newCard && oldCard !== newCard) {
	    	    	 // Fire the beforeactivate and beforedeactivate events on the cards
	    	    	 if (newCard.fireEvent('beforeactivate', newCard, oldCard) === false) {
	    	    		 return false;
	    	    	 }
	    	    	 if (oldCard && oldCard.fireEvent('beforedeactivate', oldCard, newCard) === false) {
	    	    		 return false;
	    	    	 }

	    	    	 if (rendered) {
	    	    		 Ext.suspendLayouts();

	    	    		 // If the card has not been rendered yet, now is the time to do so.
	    	    		 if (!newCard.rendered) {
	    	    			 me.renderItem(newCard, me.getRenderTarget(), owner.items.length);
	    	    		 }

	    	    		 var handleNewCard = function () {
	    	    			 // Make sure the new card is shown
	    	    			 if (newCard.hidden) {
	    	    				 newCard.show();
	    	    			 }

	    	    			 if (!newCard.tab) {
	    	    				 var newCardEl = newCard.getEl();
	    	    				 newCardEl.dom.style.opacity = 1;
	    	    				 if (newCardEl.isStyle('display', 'none')) {
	    	    					 newCardEl.setDisplayed('');
	    	    				 } else {
	    	    					 newCardEl.show();
	    	    				 }
	    	    			 }

	    	    			 // Layout needs activeItem to be correct, so set it if the show has not been vetoed
	    	    			 if (!newCard.hidden) {
	    	    				 me.activeItem = newCard;
	    	    			 }
	    	    			 Ext.resumeLayouts(true);
	    	    		 };

	    	    		 var handleOldCard = function () {
	    	    			 if (me.hideInactive) {
	    	    				 oldCard.hide();
	    	    				 oldCard.hiddenByLayout = true;
	    	    			 }
	    	    			 oldCard.fireEvent('deactivate', oldCard, newCard);
	    	    		 };

	    	    		 if (oldCard && !newCard.tab) {
	    	    			 var oldCardEl = oldCard.getEl();
	    	    			 oldCardEl.slideOut("r", {
	    	    				 callback: function () {
	    	    					 handleOldCard();
	    	    					 handleNewCard();
	    	    				 }
	    	    			 });

	    	    		 } else if (oldCard) {
	    	    			 handleOldCard();
	    	    			 handleNewCard();
	    	    		 } else {
	    	    			 handleNewCard();
	    	    		 }

	    	    	 } else {
	    	    		 me.activeItem = newCard;
	    	    	 }

	    	    	 newCard.fireEvent('activate', newCard, oldCard);
	    	    	 return me.activeItem;
	    	     }
	    	     return false;
	    	 }
	     });
	};
})();