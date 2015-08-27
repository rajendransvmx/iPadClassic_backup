
(function(){
	var appImpl = SVMX.Package("com.servicemax.client.installigence.app");
	
	appImpl.Class("Application", com.servicemax.client.lib.api.AbstractApplication,{

		__constructor : function(){

		},
		
		run : function(){
		
		var svmxtreestore = Ext.create('Ext.data.TreeStore', {
			root: {
				expanded: true,
				children: [
					{ text: "PEVGEOT Piossing", expanded: true, icon: 'http://localhost/Installigence5/trunk/dev/js/src/modules/com.servicemax.client.installigence.ui.components/resources/extjsthemes/installigence/images/custom/dummy-icon1.png', checked: false, children: [
						{ text: "Electrical Room 1", checked: false, icon: 'http://localhost/Installigence5/trunk/dev/js/src/modules/com.servicemax.client.installigence.ui.components/resources/extjsthemes/installigence/images/custom/dummy-icon2.png', expanded: true, children: [{text: 'Switch Board', checked: false, icon: 'http://localhost/Installigence5/trunk/dev/js/src/modules/com.servicemax.client.installigence.ui.components/resources/extjsthemes/installigence/images/custom/dummy-icon3.png'}] },
						{ text: "Electrical Room 2", checked: false, icon: 'http://localhost/Installigence5/trunk/dev/js/src/modules/com.servicemax.client.installigence.ui.components/resources/extjsthemes/installigence/images/custom/dummy-icon4.png', expanded: true, children: [{text: 'MV Ring Main', checked: true, icon: 'http://localhost/Installigence5/trunk/dev/js/src/modules/com.servicemax.client.installigence.ui.components/resources/extjsthemes/installigence/images/custom/dummy-icon5.png'}] },
						{ text: "Electrical Room 3", checked: false, icon: 'http://localhost/Installigence5/trunk/dev/js/src/modules/com.servicemax.client.installigence.ui.components/resources/extjsthemes/installigence/images/custom/dummy-icon2.png', expanded: true, children: [{text: 'Switch Board', checked: false, icon: 'http://localhost/Installigence5/trunk/dev/js/src/modules/com.servicemax.client.installigence.ui.components/resources/extjsthemes/installigence/images/custom/dummy-icon3.png'}] },
						{ text: "Electrical Room 4", checked: false, icon: 'http://localhost/Installigence5/trunk/dev/js/src/modules/com.servicemax.client.installigence.ui.components/resources/extjsthemes/installigence/images/custom/dummy-icon4.png', expanded: true, children: [{text: 'MV Ring Main', checked: false, icon: 'http://localhost/Installigence5/trunk/dev/js/src/modules/com.servicemax.client.installigence.ui.components/resources/extjsthemes/installigence/images/custom/dummy-icon5.png'}] },
						{ text: "Electrical Room 5", checked: false, iconCls : 'product-icon', expanded: true, children: [{text: 'MV Ring Main', checked: false, iconCls : 'sub-location-icon',}] }
						
					] },
					{ text: "Sub Site", expanded: true, checked: false, leaf: true, icon: 'http://localhost/Installigence5/trunk/dev/js/src/modules/com.servicemax.client.installigence.ui.components/resources/extjsthemes/installigence/images/custom/dummy-icon6.png' }
				]
			}
		});
		
		var getMenu = function (cmp) {			    				    	
			var menu = cmp.down('menu'); 
			if (!menu) {
				menu = Ext.create('Ext.menu.Menu', {
					cls: 'svmx-nav-menu',
					plain: true,
					height: '80%',
					items: [
							{text: 'Find & Get'},
							{text: 'Sync Configuration'},
							{text: 'Sync Data'},
							{text: 'Sync Status'},
							{text: 'Show Alerts'}
					]
				});
			}
			return menu;
		};
		
		
		var store = Ext.create('Ext.data.Store', {
			storeId:'simpsonsStore',
			fields:['name', 'email', 'phone'],
			data:{'items':[
				{ 'name': 'Decommision',  "type":"Field Map",  "action":"SVMX_Default_Decomm"  },
				{ 'name': 'Configurator',  "type":"External App",  "action":"Abc.exe" },
				{ 'name': 'Decommision',  "type":"Field Map",  "action":"SVMX_Default_Decomm"  },
				{ 'name': 'Configurator',  "type":"External App",  "action":"Abc.exe" },
				{ 'name': 'Decommision',  "type":"Field Map",  "action":"SVMX_Default_Decomm"  },
				{ 'name': 'Configurator',  "type":"External App",  "action":"Abc.exe" },
				{ 'name': 'Decommision',  "type":"Field Map",  "action":"SVMX_Default_Decomm"  },
				{ 'name': 'Configurator',  "type":"External App",  "action":"Abc.exe" },
			]},
			proxy: {
				type: 'memory',
				reader: {
					type: 'json',
					rootProperty: 'items'
				}
			}
		});
		
		var pgb = Ext.create('Ext.ProgressBar', {
			text: 'Updating...'
		});
		
		var prog = 0;

		setInterval(function() {
			prog = (prog + 5) % 105;

			pgb.updateProgress(prog / 100);
		}, 100);

		var items = [
			{
				xtype: 'panel',
				ui: 'svmx-gray-panel',
				title: 'Panel',
				margin: '20 20',
				cls: 'grid-panel-borderless',
				html:'<div style="padding:15px">Panel content comes here</div>'
			},
			{
				xtype: 'panel',
				margin: '60 20',
				dockedItems: [{
					xtype: 'toolbar',
					dock: 'top',
					cls: 'grid-panel-borderless',
					items: [{
						text: 'Toolbar Docked to the top'
					}]
				},{
					xtype: 'toolbar',
					dock: 'bottom',
					cls: 'grid-panel-borderless',
					items: [{
						text: 'Toolbar Docked to the bottom'
					}]
				}],
				//title: 'Panel',
				//margin: '3',
				items: [
					{
						xtype: 'button',
						margin: '7',
						text: 'Small'
					},{
						xtype: 'button',
						margin: '7',
						text: 'Medium',
						scale : 'medium'
					},{
						xtype: 'button',
						margin: '7',
						text: 'Large',
						scale : 'large'
					},{
						xtype: 'button',
						margin: '7',
						cls: 'plain-btn-text-center',
						text: 'Action Button 1'
					}
				]
			},{
				xtype: 'toolbar',
				margin: '60 20 5',
				cls: 'grid-panel-borderless',
				items: ['->',
					{xtype: 'button', text: 'Toolbar Button 1'},
					{xtype: 'button', text: 'Toolbar Button 2'},
					{xtype: 'button', text: 'Toolbar Button 3'}
				]
			},{
				xtype: 'toolbar',
				ui: 'svmx-plain-toolbar',
				dock: 'bottom',
				margin: '5 20',
				items: ['->',
					{xtype: 'button', text: 'Plain Toolbar Button 1'},
					{xtype: 'button', text: 'Plain Toolbar Button 2'},
					{xtype: 'button', text: 'Plain Toolbar Button 3'}
				]
			},{
				xtype: 'panel',
				margin: '60 0 0',
				cls: 'grid-panel-borderless',
				layout: {
					type: 'hbox',
					align: 'stretch'
				},
				items:[
					{
						xtype: 'form',
						title: 'Form Panel',
						//cls: 'grid-panel-borderless',
						//width: '50%',
						margin: '0 15',
						flex: 1,
						//layout: 'anchor',
						defaults: {
							anchor: '90%',
							labelAlign: 'right',
							labelWidth: '40%',
							padding: '10 0 10 0'
						},
						items: [{
									fieldLabel: 'Text Field ',
									xtype     : 'textfield',
									name      : 'textfield1'
								},{
									fieldLabel: 'ComboBox ',
									xtype: 'combo',
									store: ['Foo', 'Bar']
								},{
									fieldLabel: 'Number Field ',
									xtype     : 'numberfield',
									name      : 'number'
								},{
									fieldLabel: 'DateField ',
									xtype     : 'datefield',
									name      : 'date'
								},{
									fieldLabel: 'TimeField ',
									name: 'time',
									xtype: 'timefield'
								},{
									fieldLabel: 'Lookup ',
									xtype     : 'textfield',
									cls: 'svmx-lookup-icon'
								},
								{
									fieldLabel: 'Checkboxes ',
									xtype: 'checkboxgroup',
									columns: [100,100],
									items: [
										{boxLabel: 'Foo', checked: true,id:'fooChk',inputId:'fooChkInput'},
										{boxLabel: 'Bar'}
									]
								},{
									fieldLabel: 'Radios ',
									xtype: 'radiogroup',
									columns: [100,100],
									items: [{boxLabel: 'Foo', checked: true, name: 'radios'},{boxLabel: 'Bar', name: 'radios'}]
								},{
									fieldLabel: 'TextArea ',
									xtype     : 'textareafield',
									name      : 'message',
									cls       : 'x-form-valid',
									value     : 'This field is hard-coded to have the "valid" style'
								}
						]
					},{
						xtype: 'window',
						id: 'basicWindow',
						hidden: false,
						title: 'Window',
						margin: '0 20 0 20',
						width: '50%',
						//bodyPadding: 5,
						html       : '<div style="padding: 15px">Click Submit for Confirmation Msg.</div>',
						collapsible: false,
						floating   : false,
						closable   : true,
						draggable  : false,
						//width: 300,
						//height: 300,
						buttons: [
							{
								text   : 'Submit',
								id     : 'message_box',
								handler: function() {
									Ext.MessageBox.confirm('Confirm', 'Are you sure you want to do that?');
								}
							}
						]
					}
				]		
			},{
				xtype: 'gridpanel',
				margin: '60 20 0 20',
				//height: 400,
				cls: 'panel-radiusless',
				store: Ext.data.StoreManager.lookup('simpsonsStore'),
				columns: [
					{
						menuDisabled: true,
						sortable: false,
						xtype: 'actioncolumn',
						width: 50,
						items: [{
									iconCls: 'delet-icon',
									tooltip: 'Delete'
								}]
					},
					{ text: 'Name', sortable: true, menuDisabled: false, dataIndex: 'name', width: 200 },
					{ text: 'Type', sortable: true, menuDisabled: false, dataIndex: 'type', width: 250, flex: 1 },
					{ text: 'Action', sortable: true, menuDisabled: false, dataIndex: 'action', width: 350 },
					{ text: 'Is Global', xtype : 'checkcolumn', dataIndex: 'visible', sortable: false, menuDisabled: true }                                                    
				],
				tbar: [{
						xtype: 'textfield',
						width: '40%',
						cls: 'search-textfield',
						emptyText : 'Search'
						//trigger1Cls: Ext.baseCSSPrefix + 'form-clear-trigger',
						//trigger2Cls: Ext.baseCSSPrefix + 'form-search-trigger'
					},'->',{
						xtype: 'button',
						cls: 'plain-btn',
						iconCls: 'plus-icon'
					},{
						xtype: 'button',
						cls: 'plain-btn',
						iconCls: 'delete-icon'
					},{
						xtype: 'button',
						cls: 'plain-btn',
						iconCls: 'options-orange-icon'
					},{
						xtype: 'button',
						cls: 'plain-btn',
						tooltip: 'Create',
						iconCls: 'create-from-ib-icon'
					},{
						xtype: 'button',
						cls: 'plain-btn',
						tooltip: 'Save as',
						iconCls: 'save-as-icon'
					}
				]
			},{
				xtype: 'panel',
				margin: '60 20 0',
				cls: 'grid-panel-borderless',
				layout: {
					type: 'hbox',
					align: 'stretch'
				},
				items: [{
						xtype: 'treepanel',
						cls: 'svmx-tree-panel',
						margin: '0 0 10 0',
						//width: '40%',
						//height: 480,
						flex: 1,
						store: svmxtreestore,
						rootVisible: false
					},{
						xtype: 'panel',
						margin: '0 0 0 140',
						cls: 'grid-panel-borderless',
						border: false,
						flex: 1,
						items: {
							xtype: 'datepicker'
						}
					},{
						xtype: 'panel',
						ui: 'svmx-gray-panel',
						title: 'Action Buttons',
						cls: 'grid-panel-borderless',
						flex: 1,
						items: [
							{
								xtype: 'button',
								width: '100%',
								cls: 'plain-btn-text-center border-botton',
								text: 'Action Button 1'
							},{
								xtype: 'button',
								width: '100%',
								cls: 'plain-btn-text-center border-botton',
								text: 'Action Button 2'
							},{
								xtype: 'button',
								width: '100%',
								cls: 'plain-btn-text-center border-botton',
								text: 'Action Button 3'
							}
						]
					}
				]
			
			},{
				xtype: 'panel',
				//flex: 1,
				width: '50%',
				margin: '60 0 0 20',
				items:[{
						xtype: 'toolbar',
						cls: 'grid-panel-borderless',
						style:'background-color: #fff',
						margin: '0',
						items:[{
									xtype: 'textfield',
									cls: 'toolbar-search-textfield',
									width: '95%',
									emptyText : 'Search'
								},{
									//width: '2%',
									flex: 1,
									xtype: 'button',
									iconCls: 'option-button'
								}
						]
					}
				]
			},{
				xtype: 'tabpanel',
				cls: 'horizontal-tab-panel grid-panel-borderless panel-radiusless',
				plain : 'true',
				margin: '60 20 0',
				height: 200,
				items: [{
					title: 'Horizontal Tab 1',
					html: '<div style="margin: 10px">Horizontal Tab 1</div>'
					},{
						title: 'Horizontal Tab 2',
						html: '<div style="margin: 10px">Horizontal Tab 2. Horizontal Tab 2</div>'
					}]
			},{
				xtype: 'tabpanel',
				height: 300,
				//width: 600,
				tabPosition: 'left',
				tabRotation: 0,
				tabBar: {
					border: false
				},
				margin: '80 20 0 20',
				cls: 'panel-radiusless',
				ui: 'setup-tabpanel',
				defaults: {
					textAlign: 'left',
					bodyPadding: 7
				},
				items: [{
						title: 'Vertical Tab 1',
						html: "Vertical Tab 1"
					},{
						title: 'Vertical Tab 2',
						html: "Vertical Tab 2. Vertical Tab 2"
					}, {
						title: 'Vertical Tab 3',
						html: "Vertical Tab 3. Vertical Tab 3. Vertical Tab 3"
					}
				]
			},{
				xtype: 'panel',
				margin: '60 20 0 20',
				items: [
					pgb
				]
			},{
				xtype: 'panel',
				height: 80,
				//width: '100%',
				margin: '60 20 0 20',
				autoScroll: true,
				overflowX:'hidden',
				id: 'Parent',
				cls: 'svmx-documents-carousel',
				layout: {
					type: 'hbox',
					align: 'stretch',
					pack: 'center'                    
				},
				dockedItems: [{
						xtype: 'button',
						itemId: 'slideLeft',
						width: 20,
						dock: 'left',
						cls: 'carousel-slide-left',
						listeners: {
							click: {
								fn: function () {
									Ext.getCmp('Parent').scrollBy(-600, 0, true);
								}
							}
						}
					},{
						xtype: 'button',
						itemId: 'slideRight',
						width: 20,
						dock: 'right',
						cls: 'carousel-slide-right',
						listeners: {
							click: {
								fn: function () {
									Ext.getCmp('Parent').scrollBy(600, 0, true);
								}
							}
						}
					}
				],
				items: [{
						xtype: 'panel',
						cls: 'grid-panel-borderless svmx-carousel-btn-panel',
						defaults: {
							//xtype: 'image',
							//cls: 'item-image',
							//height: 160,
							listeners: {
								click: {

								}
							}
						},
						items: [
							{
								xtype: 'button',
								text: 'Change.mp4',
								height: 60,
								cls: 'svmx-carousel-btn',
								iconAlign: 'top',
								scale : 'medium',
								iconCls: 'svmx-audio-icon',
								margin: '0 10'
							},{
								xtype: 'button',
								text: 'Manual.pdf',
								height: 60,
								cls: 'svmx-carousel-btn',
								iconAlign: 'top',
								scale : 'medium',
								iconCls: 'svmx-audio-pdf',
								margin: '0 10'
							},{
								xtype: 'button',
								text: 'Design.jpg',
								height: 60,
								cls: 'svmx-carousel-btn',
								iconAlign: 'top',
								scale : 'medium',
								iconCls: 'svmx-img-icon',
								margin: '0 10'
							},{
								xtype: 'button',
								text: 'Change2.mp4',
								height: 60,
								cls: 'svmx-carousel-btn',
								iconAlign: 'top',
								scale : 'medium',
								iconCls: 'svmx-audio-icon',
								margin: '0 10'
							},{
								xtype: 'button',
								text: 'Manual2.pdf',
								height: 60,
								cls: 'svmx-carousel-btn',
								iconAlign: 'top',
								scale : 'medium',
								iconCls: 'svmx-audio-pdf',
								margin: '0 10'
							},{
								xtype: 'button',
								text: 'Design2.jpg',
								height: 60,
								cls: 'svmx-carousel-btn',
								iconAlign: 'top',
								scale : 'medium',
								iconCls: 'svmx-img-icon',
								margin: '0 10'
							},{
								xtype: 'button',
								text: 'Change3.mp4',
								height: 60,
								cls: 'svmx-carousel-btn',
								iconAlign: 'top',
								scale : 'medium',
								iconCls: 'svmx-audio-icon',
								margin: '0 10'
							},{
								xtype: 'button',
								text: 'Manual3.pdf',
								height: 60,
								cls: 'svmx-carousel-btn',
								iconAlign: 'top',
								scale : 'medium',
								iconCls: 'svmx-audio-pdf',
								margin: '0 10'
							},{
								xtype: 'button',
								text: 'Design3.jpg',
								height: 60,
								cls: 'svmx-carousel-btn',
								iconAlign: 'top',
								scale : 'medium',
								iconCls: 'svmx-img-icon',
								margin: '0 10'
							},{
								xtype: 'button',
								text: 'Change4.mp4',
								height: 60,
								cls: 'svmx-carousel-btn',
								iconAlign: 'top',
								scale : 'medium',
								iconCls: 'svmx-audio-icon',
								margin: '0 10'
							},{
								xtype: 'button',
								text: 'Manual4.pdf',
								height: 60,
								cls: 'svmx-carousel-btn',
								iconAlign: 'top',
								scale : 'medium',
								iconCls: 'svmx-audio-pdf',
								margin: '0 10'
							},{
								xtype: 'button',
								text: 'Design4.jpg',
								height: 60,
								cls: 'svmx-carousel-btn',
								iconAlign: 'top',
								scale : 'medium',
								iconCls: 'svmx-img-icon',
								margin: '0 10'
							},{
								xtype: 'button',
								text: 'Change5.mp4',
								height: 60,
								cls: 'svmx-carousel-btn',
								iconAlign: 'top',
								scale : 'medium',
								iconCls: 'svmx-audio-icon',
								margin: '0 10'
							},{
								xtype: 'button',
								text: 'Manual5.pdf',
								height: 60,
								cls: 'svmx-carousel-btn',
								iconAlign: 'top',
								scale : 'medium',
								iconCls: 'svmx-audio-pdf',
								margin: '0 10'
							},{
								xtype: 'button',
								text: 'ADD',
								height: 60,
								cls: 'svmx-carousel-btn svmx-btn-text-bold',
								iconAlign: 'top',
								scale : 'medium',
								iconCls: 'svmx-carousel-add-icon',
								margin: '0 10'
							}]
					}]
			}			
		];
		mainContainer = Ext.create('Ext.panel.Panel', {
	        renderTo: SVMX.getDisplayRootId(),
	        items: items,
	        title: '<span class="title-text">UI Components</span> <div class="logo"/></div>',
			titleAlign: 'center', 
			frame: 'true',
			collapsible : false,
			style: 'margin:10px',
			height : 3200,
			toolPosition: 0,
			tools: [{
				type:'hamburger',
				cls: 'hamburger',
				handler: function(e, el, owner, tool){			
					getMenu(owner).showBy(owner,'tl-bl?');			
				}
			}],
			layout: {
				padding: '0'
			}
    	});
		}
		
	},{});
})();