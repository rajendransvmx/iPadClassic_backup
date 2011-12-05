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
// Detail View Controller
#define gSTANDARD_TABLE_ROW_HEIGHT                      31

// Button Event
#define gBUTTON_EVENT_TARGET_CALL                       @"button_Event_Target_Call"
#define gBUTTON_TYPE_WEBSERVICE                         @"WEBSERVICE"
#define gBUTTON_TYPE_TDM_IPAD_ONLY                      @"TDM - IPAD ONLY"
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
