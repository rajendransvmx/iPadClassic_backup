//
//  Globals.h
//  project
//
//  Created by Samman on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Globals : NSObject {
    
}

@end


#define SYNC_RECORD_header              @"MASTER"
#define SYNC_RECORD_DETAIL              @"DETAIL"
#define SYNC_RECORD_OBJECT_NAME         @"object_name"
#define SYNC_RECORD_SF_id                @"Id"
#define SYNC_RECORD_LOCAL_ID            @"local_id"
#define SYNC_RECORD_OPERATION_TYPE      @"operation_type"



#define KMinPkgForScheduleEvents                       10.20000
#define KMinPkgForLocalUpdateEventCreation             10.20003
#define DOD                                            9.3
#define kMinSFMSearchSorting                           11.2 

#define NOT_OWNERLESSTHAN                               @"NOT_OWNERLESSTHAN"
#define NOT_OWNER_GREATERTHAN                           @"NOT_OWNER_GREATERTHAN"

#define AFTERSAVEPAGELEVELEVENT                        @"AFTERSAVEPAGELEVELEVENT"
#define AFTERSAVEPAQGELEVELBINDING                     @"AFTERSAVEPAGELEVELBINDING"
#define PAGE_LEVEL_EVENT_ID                             @"PAGE_LEVEL_EVENT_ID"
//sahana
//signature 
#define SIG_AFTERUPDATE                                 @"AFTER_UPDATE"
#define SIG_BEFOREUPDATE                                @"BEFORE_UPDATE"
#define SIG_AFTERSYNC                                   @"AFTER_SYNC"

//sahana initial sync crash fix
#define USER_INFO_PLIST                                 @"USER_INFO_PLIST"
#define USER_NAME_AUTHANTICATED                         @"USER_NAME_AUTHENTICATED"
#define INITIAL_SYNC_LOGIN_SATUS                        @"INITIAL_SYNC_LOGIN_SATUS"

#define META_SYNC_                                      @"meta_sync"
#define DATA_SYNC_                                     @"data_sync"
#define TX_FETCH_                                       @"tx_fetch"

#define EVENT_SYNC                                      @"EVENT_SYNC"
#define DOWNLOAD_CREITERIA_SYNC                         @"DOWNLOAD_CREITERIA_SYNC"
#define DOWNLOAD_CRITERIA_OBJECTS                       @"DOWNLOAD_CRITERIA_OBJECTS"
#define DOWNLOAD_CRITERIA_CHANGE                        @"DOWNLOAD_CRITERIA_CHANGE"


#define RecordType_Id                                   @"RecordType_Id"
#define SFM_Object                                      @"sfm_object"

#define LAST_INCREMENTAL_SYNC_TIME                       @"last_incremental_sync_time"
#define LAST_INITIAL_SYNC_IME                            @"last_initial_sync_time"
#define REQUEST_ID                                       @"request_id"

#define LAST_INITIAL_META_SYNC_TIME                      @"last_initial_meta_sync"
#define NEXT_META_SYNC_TIME                              @"next_meta_sync_time"

//Radha - defect Fix - 5542
#define DATASYNC_TIME_TOBE_DISPLAYED					 @"data_sync_time_tobe_displayed"
#define NEXT_DATA_SYNC_TIME_DISPLAYED					 @"next_daya_sync_time_displayed"

//Radha Data sync
#define SYNC_FAILED										 @"sync_failed"
#define PUSH_LOG_LABEL                                   @"push_log"
#define PUSH_LOG_LABEL_COLOR                             @"push_log_color"
//META SYNC STATUS
#define META_SYNC_STATUS								 @"meta_sync_status"

#define STRUE	@"true"
#define SFALSE	@"false"


// INSERT
#define LAST_INSERT_REQUEST_TIME                        @"last_insert_request_time"
#define LAST_INSERT_RESONSE_TIME                        @"last_insert_response_time"
#define LAST_DC_INSERT_REQUEST_TIME                     @"last_dc_insert_request_time"            //DOWNLOAD_CRiteria records
#define LAST_DC_INSERT_RESPONSE_TIME                    @"last_dc_insert_response_time"             //DOWNLOAD_CRiteria records
#define INSERT_SUCCESS                                  @"INSERT_SUCCESS"

//UPDATE
#define GET_UPDATE_LAST_SYNC_TIME                       @"GET_UPDATE_LST"                           // Damodar : Defect 8593
#define LAST_UPDATE_REQUEST_TIME                        @"last_update_request_time"
#define LAST_UPDATE_RESONSE_TIME                        @"last_update_response_time"
#define LAST_DC_UPDATE_REQUEST_TIME                     @"last_dc_update_request_time"              //DOWNLOAD_CRiteria records
#define LAST_DC_UPDATE_RESPONSE_TIME                     @"last_dc_update_response_time"             //DOWNLOAD_CRiteria records
#define UPDATE_SUCCESS                                  @"UPDATE_SUCCESS"

//DELETE
#define LAST_DELETE_REQUEST_TIME                        @"last_delete_request_time"
#define LAST_DELETE_RESPONSE_TIME                       @"last_delete_response_time"
#define LAST_DC_DELETE_REQUEST_TIME                     @"last_dc_delete_request_time"               //DOWNLOAD_CRiteria records
#define LAST_DC_DELETE_RESPONSE_TIME                    @"last_dc_delete_response_time"               //DOWNLOAD_CRiteria records
#define DELETE_SUCCESS                                  @"DELETE_SUCCESS"


#define GET_INSERT_FOR_DOWNLOAD_CRITERIA                @"GET_INSERT_FOR_DOWNLOAD_CRITERIA"
#define GET_DELETE_FOR_DOWNLOAD_CRITERIA                @"GET_DELETE_FOR_DOWNLOAD_CRITERIA"
#define GET_UPDATE_FOR_DOWNLOAD_CRITERIA                @"GET_UPDATE_FOR_DOWNLOAD_CRITERIA"


//One Call sync
#define LAST_OSC_TIMESTAMP								@"last_osc_timestamp"

#define DOWNLOAD_CRITERIA_PLIST                         @"download_criteria_plist.plist"
#define SYNC_HISTORY                                    @"SYNC_HISTORY.plist"
#define SESSION_INFO                                    @"session_info.plist"

#define ObjectAPIName                                   @"ObjectAPIName"

//create Process
#define  SVMXC_OBJECT_NAME                              @"SVMXC__Source_Object_Name__c"

// View Layout Constants
#define gPROCESS_TYPE                                   @"SVMXC__ServiceMax_Processes__c"
#define gPROCESS_ID                                     @"SVMXC__ProcessID__c"
#define gPROCESS_NAME                                   @"SVMXC__Name__c"

// Web Service Interface Constants
#define RECORDID                                        @"RECORDID"
#define OBJECTNAME                                      @"OBJECTNAME"
#define CALENDAR_START_DATE                             @"startDate"
#define CALENDAR_END_DATE                               @"endDate"
#define USERID                                          @"userID"
#define TAG_KEY                                         @"TAG"
#define ISSUBMODULE_KEY                                 @"ISSUBMODULE"
#define PAGEID                                          @"PAGEID"
#define PROCESSID                                       @"PROCESSID"
#define SAVETYPE                                        @"SAVETYPE"

#define gWSRESPONSE                                     @"wsResponse"
#define gRESULT                                         @"result"
#define gPAGE                                           @"page"
#define gHEADER                                         @"header"
#define gDETAILS                                        @"details"
#define gPROCESSTYPE                                    @"PROCESSTYPE"
#define gRESPONSE                                       @"RESPONSE"
#define SLATIMER                                        @"SLATIMER"
#define RESTORATIONTIME                                 @"RESTORATIONTIME"
#define RESOLUTIONTIME                                  @"RESOLUTIONTIME"

#define HEADER                                          @"Header"
#define LINES                                           @"Lines"

// Split View - Root View Controller
#define gNUM_SECTIONS_IN_TABLE                          2
#define gNUM_SECTION_IN_TABLE_ADDITIONALINFO            3
#define gNUM_SECTION_IN_TABLE_Attachment                4
// Detail View Controller
#define gSTANDARD_TABLE_ROW_HEIGHT                      40

// Button Event
#define gBUTTON_EVENT_TARGET_CALL                       @"button_Event_Target_Call"
#define gBUTTON_TYPE_WEBSERVICE                         @"WEBSERVICE"
#define gBUTTON_TYPE_TDM_IPAD_ONLY                      @"TDM - IPAD ONLY"

//8915 - cancel

#define gBUTTON_TYPE_TDM_IPAD_ONLY_CANCEL                     @"TDM - IPAD ONLY CANCEL"
// Button
#define gBUTTON_TITLE                                   @"button_Title"
#define gBUTTON_EVENTS                                  @"button_Events"
#define gBUTTON_TARGET_CALL                             @"SVMXC__Target_Call__c"
#define gBUTTON_EVENT_CALL_TYPE                         @"SVMXC__Event_Call_Type__c"
#define gBUTTON_EVENT_TYPE                              @"SVMXC__Event_Type__c"
#define gBUTTON_EVENT_ENABLE                            @"Enable"
                                    
//sahana 1st Aug 2011
#define gEVENT_ID                                       @"SVMXC__Event_Id__c"
#define gEVENT_TARGET_CALL                              @"SVMXC__Target_Call__c"
#define gEVENT_CALL_TYPE                                @"SVMXC__Event_Call_Type__c"
#define gEVENT_TYPE                                     @"SVMXC__Event_Type__c"
#define gEVENT_NAME                                     @"Name"
#define gEVENT_LAYOUT_ID                                @"SVMXC__Page_Layout__c"

//sahana 2nd Aug 2011
#define gPAGELEVEL_EVENTS                               @"PageLevel_Evnts"
// Header Section Fields
#define gPROCESS_TITLE                                  @"processTitle"
// Header Data Fields
#define gName                                           @"Name"
#define gCurrencyIsoCode                                @"CurrencyIsoCode"
#define gId                                             @"Id_"
#define gSVMXC__Billing_Type__c                         @"SVMXC__Billing_Type__c"
#define gSVMXC__Clock_Paused_Forever__c                 @"SVMXC__Clock_Paused_Forever__c"
#define gSVMXC__Company__c                              @"SVMXC__Company__c"
#define gSVMXC__Customer_Down_Status__c                 @"SVMXC__Customer_Down_Status__c"
#define gSVMXC__Customer_Down__c                        @"SVMXC__Customer_Down__c"
#define gSVMXC__Order_Status__c                         @"SVMXC__Order_Status__c"
#define gSVMXC__Order_Type__c                           @"SVMXC__Order_Type__c"
#define gSVMXC__Problem_Description__c                  @"SVMXC__Problem_Description__c"
#define gSVMXC__SLA_Clock_Paused__c                     @"SVMXC__SLA_Clock_Paused__c"
#define gSVMXC__Service_Duration__c                     @"SVMXC__Service_Duration__c"
#define gSVMXC__Actual_Resolution__c                    @"SVMXC__Actual_Resolution__c"
#define gSVMXC__Actual_Restoration__c                   @"SVMXC__Actual_Restoration__c"
#define gSVMXC__Resolution_Customer_By__c               @"SVMXC__Resolution_Customer_By__c"
#define gSVMXC__Restoration_Customer_By__c              @"SVMXC__Restoration_Customer_By__c"
#define gSVMXC__Product__c                              @"SVMXC__Product__c"
#define gSVMXC__Product_Name__c                         @"SVMXC__Product_Name__c"

// Page Detail Fields
#define gFIELD_API_NAME                                 @"Field_API_Name"
#define gFIELD_DISPLAY_COLUMN                           @"Field_Display_Column"
#define gFIELD_DISPLAY_ROW                              @"Field_Display_Row"
#define gFIELD_READ_ONLY                                @"Field_Read_Only"
#define gFIELD_REQUIRED                                 @"Field_Required"
#define gFIELD_LOOKUP_CONTEXT                           @"Field_Lookup_Context"
#define gFIELD_LOOKUP_QUERY                             @"Field_Lookup_Query"
#define gFIELD_SEQUENCE                                 @"Field_Sequence"
#define gFIELD_RELATED_OBJECT_NAME                      @"Field_Related_Object_Name"
#define gFIELD_RELATED_OBJECT_SEARCH_ID                 @"SVMXC__Named_Search__c"
#define gFIELD_DATA_TYPE                                @"Field_Data_Type"
#define gFIELD_LABEL                                    @"Field_Label"
#define gFIELD_VALUE_KEY                                @"Field_Value_Key"
#define gFIELD_VALUE_VALUE                              @"Field_Value_Value"
#define gSLA_CLOCK                                      @"SVMXC__Use_For_SLA_Clock__c"
#define gFIELD_OVERRIDE_RELATED_LOOKUP                  @"SVMXC__Override_Related_Lookup__c"
//Aparna: FORMFILL
#define gFIELD_MAPPING                                  @"SVMXC__Field_Mapping__c"

// Header Section
#define gSECTION_NUMBER_OF_COLUMNS                      @"section_Number_Of_Columns"
#define gSECTION_TITLE                                  @"section_Title"
#define gSECTION_SEQUENCE                               @"section_Sequence"
#define gSECTION_FIELDS                                 @"section_Fields"
#define gSLA_CLOCK                                      @"SVMXC__Use_For_SLA_Clock__c"
// Header Layout
#define gHEADER_OBJECT_NAME                             @"hdr_Object_Name"
#define gHEADER_ID                                      @"hdr_id"
// Header Describable
#define gHEADER_OBJECT_LABEL                            @"hdr_Object_Label"
#define gHEADER_ALLOW_NEW_LINES                         @"hdr_Allow_New_Lines"
#define gHEADER_ALLOW_DELETE_LINES                      @"hdr_Allow_Delete_Lines"
#define gHEADER_IS_STANDARD                             @"hdr_IsStandard"
#define gHEADER_ACTION_ON_ZERO_LINES                    @"hdr_Action_On_Zero_Lines"
#define gHEADER_SECTIONS                                @"hdr_Sections"
#define gHEADER_BUTTONS                                 @"hdr_Buttons"
#define gHEADER_DATA                                    @"hdr_Data"
#define gHEADER_HEADER_LAYOUT_ID                        @"hdr_Header_Layout_ID"
#define gHEADER_EVENTS                                  @"hdr_Events"
#define gHEADER_NAME                                    @"hdr_Name"
#define gHEADER_OWNER_ID                                @"hdr_OwnerID"
#define gHEADER_ENABLE_ATTACHMENTS                      @"hdr_Enable_Attachments"
#define gENABLE_CHATTER                                 @"hdr_Enable_Chatter"
#define gENABLE_TROUBLESHOOTING                         @"hdr_Enable_Troubleshooting"
#define gENABLE_SUMMARY                                 @"hdr_Enable_Summary"
#define gENABLE_SUMMURY_GENERATION                      @"hdr_Enable_Summuary_Generation"
#define gHEADER_SHOW_ALL_SECTIONS_BY_DEFAULT            @"hdr_Show_All_Sections_By_Default"
#define gHEADER_SHOW_PRODUCT_HISTORY                    @"hdr_Show_Product_History"
#define gHEADER_SHOW_ACCOUNT_HISTORY                    @"hdr_Show_Account_History"
//Radha
#define gHEADER_SHOW_HIDE_QUICK_SAVE                    @"SVMXC__Hide_Quick_Save__c"
#define gHEADER_SHOW_HIDE_SAVE                          @"SVMXC__Hide_Save__c"



//Radha
#define gHEADER_RESOLUTION                              @"hdr_Actual_Resolution"
#define gHEADER_RESTORATION                             @"hdr_Actual_Restoration"

#define gSVMXC__Product__r                              @"SVMXC__Product__r"
#define gSVMXC__Actual_Quantity2__c                     @"SVMXC__Actual_Quantity2__c"
#define gPartsUsed                                      @"PartsUsed"
#define gSVMXC__Work_Description__c                     @"SVMXC__Work_Description__c"
#define gSVMXC__Actual_Price2__c                        @"SVMXC__Actual_Price2__c"
#define gSVMXC__Discount__c                             @"SVMXC__Discount__c"

// Page Detail Value (Bubble)
#define gVALUE_FIELD_API_NAME                           @"value_Field_API_Name"
#define gVALUE_FIELD_VALUE_KEY                          @"value_Field_Value_key"
#define gVALUE_FIELD_VALUE_VALUE                        @"value_Field_Value_value"
#define gDETAIL_SAVED_RECORD                            @"details_saved_record"
// Page Detail
#define gDETAILS_FIELDS_ARRAY                           @"details_Fields_Array"
#define gDETAILS_VALUES_ARRAY                           @"details_Values_Array"
#define gDETAILS_LAYOUT_ID                              @"details_Layout_Id"
#define gDETAILS_PAGE_LAYOUT_ID                         @"details_Page_Layout_Id"
#define gDETAILS_EVENT_INFO                             @"SVMXC__SFM_Event__c"
#define gDETAILS_ALLOW_NEW_LINES                        @"details_Allow_New_Lines"
#define gDETAILS_ALLOW_DELETE_LINES                     @"details_Allow_Delete_Lines"
#define gDETAILS_NUMBER_OF_COLUMNS                      @"details_Number_Of_Columns"
#define gDETAILS_OBJECT_LABEL                           @"details_Object_Label"
#define gDETAILS_OBJECT_API_NAME                        @"details_Object_API_Name"
#define gDETAIL_VALUES_RECORD_ID                        @"detail_Values_RecId"
#define gDETAIL_HEADER_REFERENCE_FIELD                  @"detail_header_reference_field"
#define gDETAIL_OBJECT_NAME                             @"detail_object_name"
#define gDETAIL_OBJECT_ALIAS_NAME                       @"detail_object_alias_name" 
#define gDETAIL_DELETED_RECORDS                         @"detail_deleted_records"
#define gDetail_MULTIADD_CONFIG                         @"SVMXC__Multi_Add_Configuration__c"
#define gDETAIL_MULTIADD_SEARCH                         @"SVMXC__Multi_Add_Search_Field__c"
#define gDETAIL_MULTIADD_SEARCH_OBJECT                  @"SVMXC__Multi_Add_Search_Object__c"
#define gDETAIL_SEQUENCE_NO                             @"SVMXC__Sequence__c"
#define gDATE_TODAY                                     @"todays_date"
#define gDETAIL_SOBJECT_ARRAY                           @"DETAIL_SOBJECT_ARRAY"
#define gDETAIL_SEQUENCENO_GETPRICE                     @"SequenceNo_for_Record"

// Lookup Keys
#define gLOOKUP_DETAILS                                 @"Lookup_Details"
#define gLOOKUP_DESCRIBEOBJECT                          @"Lookup_DecribeObject"
#define gLOOKUP_FIELD_LABEL                             @"Lookup_Field_Label"
#define gLOOKUP_FIELD_VALUE                             @"Lookup_Field_Value"

#define DEFAULT_LOOKUP_COLUMN                           @"SVMXC__Default_Lookup_Column__c"

#define CONTEXTVALUE                                    @"CONTEXTVALUE"
#define FIELDNAME                                       @"FIELDNAME"

// Edit Control Details
#define gFIELD_REQUIRED                                 @"Field_Required"

// Product, Account History
#define PRODUCTHISTORY                                  @"ProductHistory"
#define ACCOUNTHISTORY                                  @"AccountHistory"

#define PRODUCT_ADDITIONALINFO                          @"Product History"
#define ACCOUNT_ADITIONALINFO                           @"Account History"

// Call Event
#define WEBSERVICE_NAME                                 @"WEBSERVICE_NAME"
#define EVENT_TYPE                                      @"EVENT_TYPE"
#define ALIAS_NAME                                      @"ALIAS_NAME"
#define OBJECT_NAME                                     @"OBJECT_NAME"
#define PAGELAYOUT_ID                                   @"PAGELAYOUT_ID"
#define SFM_DICTIONARY                                  @"SFM_DICTIONARY"

// What is a WorkOrder
#define WORKORDER                                       @"SVMXC__Service_Order__c"


//Radha
#define gSVMXCX1__Name__c                               @"SVMXCX1__Name__c"
#define gSVMXCX1__Page_Layout_ID__c                     @"SVMXCX1__Page_Layout_ID__c"


//Radha - Macros For MetaData EventName and EventType
#define INITIAL_SYNC                                    @"INITIAL_SYNC"
#define SYNC                                            @"SYNC"
#define SFM_SEARCH                                      @"SFM_SEARCH"
#define GET_PRICE_OBJECTS                               @"PRICE_CALC_OBJECTS"
#define GET_PRICE_CODE_SNIPPET                          @"PRICE_CALC_CODE_SNIPPET"
#define GET_PRICE_DATA                                  @"PRICE_CALC_DATA"
#define SFM_METADATA                                    @"SFM_METADATA"
#define SFW_METADATA                                    @"SFW_METADATA"
#define SFM_OBJECT_DEFINITIONS                          @"SFM_OBJECT_DEFINITIONS"
#define MOBILE_DEVICE_TAGS                              @"MOBILE_DEVICE_TAGS"
#define MOBILE_DEVICE_SETTINGS                          @"MOBILE_DEVICE_SETTINGS"
#define SFM_PICKLIST_DEFINITIONS                        @"SFM_PICKLIST_DEFINITIONS"
#define SFM_PAGEDATA                                    @"SFM_PAGEDATA"
#define SFM_BATCH_OBJECT_DEFINITIONS                    @"SFM_BATCH_OBJECT_DEFINITIONS"

 // Damodar - OPDOC
#define SUBMIT_DOCUMENT                                 @"SUBMIT_DOCUMENT"
#define GENERATE_PDF                                    @"GENERATE_PDF"

#define CLIENT_TYPE                                     @"iPad"
#define CLIENT_INFO                                     @""


#define STATIC_RESOURCES_LIBRARY                        @"SVMX_LIBRARY"

//Macro For profile check
#define VALIDATE_PROFILE                                @"VALIDATE_PROFILE"
#define GROUP_PROFILE                                   @"GROUP_PROFILE"

//Conflict
#define ISCONFLICT                                      @"ISCONFLICT"

//6347: Aparna
#define kIncrementalDataSyncDone                    @"IncrementalDataSyncDone"

//7221
#define CONFIGURATTON_SYNC_COMPLETED                          @"CONFIGURATTON_SYNC_COMPLETED"


//4850
#define HEADER_SOURCE_ID_STRING                        @"headerSourceId"
#define HEADER_SOURCE_OBJECT_NAME                   @"headerSourceObjectName"
#define DETAIL_OBJECTS_SOURCE                       @"detailObjectSources"
#define DETAIL_PROCESS_COMPONENT_ID_ARRAY           @"detailProcessComponentIdArray"
#define SOURCE_INFO_OF_RECORDS                      @"sourceUpdateInfo"


