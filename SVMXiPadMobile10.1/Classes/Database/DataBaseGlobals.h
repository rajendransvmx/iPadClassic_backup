//
//  DataBaseGlobals.h
//  iService
//
//  Created by Pavamanaprasad Athani on 10/12/11.
//  Copyright (c) 2011 Bit Order Technologies. All rights reserved.
//

#ifndef iService_DataBaseGlobals_h
#define iService_DataBaseGlobals_h



#endif


#define User_created_events         @"user_created_events"
#define Event_local_Ids             @"Event_local_ids"

//Macros For Database
#define DATABASENAME1               @"sfm"
#define DATABASETYPE1                @"sqlite"
//Abinash
//Temporary Database for incremental database
#define TEMPDATABASENAME            @"tempsfm"


//Table Names
#define SFPROCESS                   @"SFProcess"
#define SFPROCESSTEST               @"SFProcess_test"
#define SFPROCESSCOMPONENT          @"SFProcessComponent"
#define SFEXPRESSION                @"SFExpression"
#define SFEXPRESSIONCOMPONENT       @"SFExpressionComponent"
#define SFOBJECTMAPPING             @"SFObjectMapping"
#define SFOBJECTMAPCOMPONENT        @"SFObjectMappingComponent"
#define SFOBJECTFIELD               @"SFObjectField"
#define SFREFERENCETO               @"SFReferenceTo"
#define SFRECORDTYPE                @"SFRecordType"
#define SFOBJECT                    @"SFObject"
#define SFPICKLIST                  @"SFPickList"
#define SFWIZARD                    @"SFWizard"
#define SFWIZARDCOMPONENT           @"SFWizardComponent"
#define SFNAMEDSEARCH               @"SFNamedSearch"
#define SFNAMEDSEACHCOMPONENT       @"SFNamedSearchComponent"
#define MOBILEDEVICETAGS            @"MobileDeviceTags"
#define MOBILEDEVICESETTINGS        @"MobileDeviceSettings"
#define SFCHILDRELATIONSHIP         @"SFChildRelationship"
#define SFRTPICKLIST                @"SFRTPicklist"



//SFProcess
#define SOURCETOTARGET                      @"SOURCETOTARGET"
#define SOURCETOTARGETONLYCHILDROWS         @"SOURCETOTARGETONLYCHILDROWS"
#define STANDALONECREATE                    @"STANDALONECREATE"
#define EDIT                                @"EDIT"
#define VIEWRECORD                          @"VIEWRECORD"
#define SOURCE_TO_TARGET_ALL                @"SOURCE TO TARGET ALL"
#define SOURCE_TO_TARGET_CHILD              @"SOURCE TO TARGET CHILD"
#define STANDALONE_CREATE                   @"STANDALONE CREATE"
#define STANDALONE_EDIT                     @"STANDALONE EDIT"
#define VIEW_RECORD                         @"VIEW RECORD"

//Common
#define MLOCAL_ID                @"local_id"
#define MOBJECT_API_NAME         @"object_api_name"
#define MFIELD_API_NAME          @"api_name"
#define _MFIELD_API_NAME         @"field_api_name"
#define MLABEL                   @"label"
#define MVALUEM                  @"value"
#define MEXPRESSION_ID           @"expression_id"
#define MOBJECT_MAPPING_ID       @"object_mapping_id"
#define MSOURCE_FIELD_NAME       @"source_field_name"
#define MSEQUENCE                @"sequence"
#define MOBJECT_NAME             @"object_name"
#define MPROCESS_ID              @"process_id"
#define MOBJECT_NAME             @"object_name"
#define MVALUE_MAPPING_ID        @"value_mapping_id"
#define MPERFORM_SYNC            @"perform_sync"

//SFobjectField
#define MREFERENCE_TO            @"reference_to"
#define MLENGTH                  @"length"
#define MTYPEM                   @"type"
#define MRELATIONSHIP_NAME       @"relationship_name"
#define MPRECISION               @"precision"
#define MNILLABLE                @"nillable"
#define MRESTRICTED_PICKLIST     @"restricted_picklist"
#define MCALCULATED              @"calculated"
#define MDEFAULT_ON_CREATE       @"defaulted_on_create"
#define MNAME_FIELD              @"name_field"   
#define OBJECT                   @"OBJECT"
#define FIELD                    @"FIELD"
#define _LENGTH                  @"LENGTH"
#define _TYPE                    @"TYPE"
#define _REFERENCETO             @"REFERENCETO"
#define _RELATIONSHIPNAME        @"RELATIONSHIPNAME"
#define _NAMEFIELD               @"NAMEFIELD"
#define _LABEL                   @"LABEL"

//SFRecordType
#define MRECORDTYPE_LABEL        @"recordtype_label"
#define MRECORD_TYPE             @"record_type"
#define MRECORD_TYPE_ID          @"record_type_id"

//SFobject
#define MKEY_PREFIX              @"key_prefix"
#define MLABEL_PURAL             @"label_plural"
#define _MKEYPREFIX              @"KEYPREFIX"
#define _MPLURALLABEL            @"PLURALLABEL"

//Picklist
#define MDEFAULTVALUE            @"defaultvalue"
#define MDEFAULTLABEL            @"defaultlabel"
#define DEFAULTPICKLISTVALUE     @"DEFAULTPICKLISTVALUE"

//SfExpression
#define MEXPRESSION_NAME         @"expression_name"
#define MEXPRESSION              @"expression"
#define MADVANCE_EXPRESSION      @"advance_expression"

//SfExpression Component
#define MCOMPONENT_SEQ_NUM       @"component_sequence_number"
#define MCOMPONENT_LHS           @"component_lhs"
#define MCOMPONENT_RHS           @"component_rhs"
#define MOPERATOR                @"operator"


//SFObjectMappingComp
#define MTARGET_FIELD_NAME       @"target_field_name"
#define MMAPPING_VALUE           @"mapping_value"
#define MMAPPING_COMP_TYPE       @"mapping_component_type"
#define MMAPPING_VALUE_FLAG      @"mapping_value_flag"


//SFNamedSearch
#define MDEFAULT_LOOKUP_COLUMN   @"default_lookup_column"
#define MSEARCH_NAME             @"search_name"
#define MSEARCH_TYPE             @"search_type"
#define MNAMED_SEARCHID          @"named_search_id"
#define MNO_OF_LOOKUP_RECORDS    @"no_of_lookup_records"
#define MIS_DEFAULT              @"is_default"
#define MIS_STANDARD             @"is_standard"



//SFNameSearchComp
#define MEXPRESSION_TYPE         @"expression_type"
#define MFIELD_NAME              @"field_name"
#define MNAMED_SEARCH            @"named_search"
#define MSEARCH_OBJECT_FIELD     @"search_object_field_type"
#define MFIELD_TYPE              @"field_type"
#define MFIELD_RELATIONSHIPNAME  @"field_relationship_name"


//Sfprocess
#define MPROCESS_TYPE            @"process_type"
#define MPROCESS_NAME            @"process_name"
#define MPROCESS_DESCRIPTION     @"process_description"
#define MPROCESS_INFO            @"process_info"
#define MPROCESS_UNIQUE_ID       @"process_unique_id"
#define MPAGE_LAYOUT_ID          @"page_layout_id"

//Keys For SFProcess
#define MHEADER                  @"header"
#define MHEADER_LAYOUT_ID        @"hdr_Header_Layout_ID"
#define MHEADER_OBJECT_NAME      @"hdr_Object_Name"
#define MPROCESSTYPE             @"PROCESSTYPE"


//SFProcess_component
#define MLAYOUT_ID               @"layout_id"
#define MTARGET_OBJECT_NAME      @"target_object_name"
#define MSOURCE_OBJECT_NAME      @"source_object_name"
#define MCOMPONENT_TYPE          @"component_type"
#define MPARENT_COLUMN           @"parent_column"
#define MPARENT_OBJECT           @"parent_object"

#define MVALUE_MAPPING_ID        @"value_mapping_id"
#define SFM                      @"SFM"

//SFwizard and Component
#define MWIZARD_ID               @"wizard_id"
#define MWIZARD_DESCRIPTION      @"wizard_description"
#define MACTION_ID               @"action_id"
#define MACTION_DESCRIPTION      @"action_description"
#define MWIZARD_STEP_DESCRIPTION @"wizard_step_description"
#define MWIZARD_STEP_NAME        @"wizard_step_name"
#define MACTION_TYPE             @"action_type"
#define MWIZARD_NAME             @"wizard_name"   

//MobileDeviceTags
#define MTAG_ID                  @"tag_id"

//MobileDeviceSettings
#define MSETTING_ID              @"setting_id"

//Column Number
#define COLUMNPROCESS_ID         0
#define COLUMNLAYOUT_ID          1
#define COLUMNOBJECT_NAME        2
#define COLUMNEXPRESSION_ID      3
#define COLUMNMAPPING_ID         4
#define COLUMNCOMP_TYPE          5
#define COLUMNPARENT_COLUMN      7
#define COLUNMVALUEMAP           8

//Tags
#define COLUMNTAG_ID             0
#define COLUMNTAG_VALUE          1

//TYPES
#define BOOLEAN                 @"BOOLEAN"
#define _BOOL                   @"BOOL"
#define CURRENCY                @"CURRENCY"
#define DOUBLE                  @"DOUBLE"
#define PERCENT                 @"PERCENT"
#define INTEGER                 @"INTEGER"
#define DATE                    @"DATE"
#define DATETIME                @"DATETIME"
#define TEXTAREA                @"TEXTAREA"
#define VARCHAR                 @"VARCHAR"
#define TEXT                    @"TEXT"

//Macros
#define MVALUEMAPPING           @"VALUEMAPPING"
#define MFIELDMAPPING           @"FIELDMAPPING"


//Keys 
#define MFIELDPROPERTY                  @"FIELDPROPERTY"
#define MOBJECTPROPERTY                 @"OBJECTPROPERTY"
#define MRECORDTYPE                     @"RECORDTYPE"
#define MOBJECTDEFINITION               @"OBJECTDEFINITION"
#define MSFMProcess                     @"SFMProcess"
#define MSFProcess_component            @"SFProcess_component"
#define MSFExpression                   @"SFExpression"
#define MSFExpression_component         @"SFExpression_component"
#define MSFObject_mapping               @"SFObject_mapping"
#define MSFObject_mapping_component     @"SFObject_mapping_component"
#define MSFNAMEDSEARCH                  @"SFNAMEDSEARCH"
#define MSFNAMEDSEARCH_COMPONENT        @"SFNAMEDSEARCH_COMPONENT"
#define MSFW_wizard                     @"SFW_wizard"
#define MSFW_wizard_steps               @"SFW_wizard_steps"
#define MASTERDETAILS                   @"MASTERDETAILS"
#define SFW_Custom_Actions              @"SFW_Custom_Actions"

#define METASYNCDUE                     @"meta_sync_due"


