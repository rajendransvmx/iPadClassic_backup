//
//  PageLayoutConstants.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 20/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "PageLayoutConstants.h"

//Page Header Constants

NSString *const  kPageHeaderSections             =   @"sections";
NSString *const kPageHeaderFields                =   @"fields";
NSString *const kPageHeaderName                  =   @"Name";
NSString *const kPageHeaderFieldDetail           =   @"fieldDetail";
NSString *const kPageHeadersectionDetail         =   @"sectionDetail";
NSString *const kPageHeaderEvents                =   @"pageEvents";

NSString *const kPageHeaderSLAClock               =   ORG_NAME_SPACE@"__Use_For_SLA_Clock__c";

NSString *const kPageHeaderSectionColumns         =   ORG_NAME_SPACE@"__No_Of_Columns__c";
NSString *const kPageHeaderSectionTitle           =  ORG_NAME_SPACE@"__Title__c";
NSString *const kPageHeaderSectionSequence        =  ORG_NAME_SPACE@"__Sequence__c";
NSString *const kPageHeaderSectionsFields         =  @"sectionFields";
NSString *const kPageHeaderSectionSLAClock        =  ORG_NAME_SPACE@"__Use_For_SLA_Clock__c";
NSString *const kPageHeaderLayout                 =  @"headerLayout";


NSString *const kPageEventName                     = @"Name";
NSString *const kPageEventType                     = ORG_NAME_SPACE@"__Event_Type__c";
NSString *const kPageTargetCall                    =  ORG_NAME_SPACE@"__Target_Call__c";
NSString *const kPageEventId                       =  ORG_NAME_SPACE@"__Event_Id__c";
NSString *const kPageEventPageLayout               =  ORG_NAME_SPACE@"__Page_Layout__c";
NSString *const kPageEventCallType                 = ORG_NAME_SPACE@"__Event_Call_Type__c";
NSString *const kPageEventCodeSnippetId            = ORG_NAME_SPACE@"__Code_Snippet__c";

NSString *const kPageHeaderpageLayoutId            = ORG_NAME_SPACE@"__Page_Layout_ID__c";
NSString *const kPageHeaderSfname                  = ORG_NAME_SPACE@"__Name__c";
NSString *const kPageHeaderObjectName              = ORG_NAME_SPACE@"__Object_Name__c";
NSString *const kPageHeaderAllowNewLines           = ORG_NAME_SPACE@"__Allow_New_Lines__c";
NSString *const kPageHeaderAllowDeleteLines        = ORG_NAME_SPACE@"__Allow_Delete_Lines__c";
NSString *const kPageHeaderIsStandard              = ORG_NAME_SPACE@"__IsStandard__c";
NSString *const kPageHeaderActionOnZeroLines       = ORG_NAME_SPACE@"__Action_On_Zero_Lines__c";
NSString *const kPageHeaderLayoutId                = @"hdrLayoutId";
NSString *const kPHeaderEvents                     = @"HeaderEvents";

NSString *const kPageHeaderOwnerId                 = @"OwnerId";
NSString *const kPageHeaderEnableAttachments       =  ORG_NAME_SPACE@"__Enable_Attachments__c";
NSString *const kPageEnableChatter                 = ORG_NAME_SPACE@"__Enable_Chatter__c";
NSString *const kPageEnableTroubleShooting         = ORG_NAME_SPACE@"__Enable_Troubleshooting__c";
NSString *const kPageEnableSummary                 = ORG_NAME_SPACE@"__Enable_Service_Report_View__c";
NSString *const kPageEnableSummaryGeneration       = ORG_NAME_SPACE@"__Enable_Service_Report_Generation__c";
NSString *const kPageHeaderShowAllSectionsByDefault =ORG_NAME_SPACE@"__Show_All_Sections_By_Default__c";
NSString *const kPageHeaderShowProductHistory      =ORG_NAME_SPACE@"__Show_Product_History__c";
NSString *const kPageHeaderShowAccountHistory      = ORG_NAME_SPACE@"__Show_Account_History__c";
NSString *const kPageHeaderObjectLabel             = @"HeaderLAbel";
NSString *const kPageHeaderId                      = @"Id";
NSString *const kPageHeaderResolutionCustomerBy    = ORG_NAME_SPACE@"__Resolution_Customer_By__c";
NSString *const kPageHeaderRestorationCustomerBy   = ORG_NAME_SPACE@"__Restoration_Customer_By__c";
NSString *const kPageShowHideQuickSave             = ORG_NAME_SPACE@"__Hide_Quick_Save__c";
NSString *const kPageShowHideSave                  = ORG_NAME_SPACE@"__Hide_Save__";
NSString *const kPageHeaderData                    = @"HeaderData";
NSString *const kPageLevelEvents                   = @"PageLevelEvents";




// Page Buttons Constants

NSString *const kPageHeaderBtnEventTarget           = ORG_NAME_SPACE@"__Target_Call__c";
NSString *const kPageHeaderBtnEventCall             = ORG_NAME_SPACE@"__Event_Call_Type__c";
NSString *const kPageHeaderBtnEventType             = ORG_NAME_SPACE@"__Event_Type__c";


NSString *const kPageHeaderBtnTitle                = ORG_NAME_SPACE@"__Title__c";
NSString *const kPageHeaderBtnEvents               = @"HeaderBtnEvents";
NSString *const kPageHeaderBtnEnable               = @"enable";

NSString *const kPageHeaderButtons                  =  @"buttons";
NSString *const kPageHeaderButtonEvents              = @"buttonEvents";
NSString *const kPageHeaderButtonDetail              = @"buttonDetail";



//Page Detail Constants

NSString *const kPageDetails                       = @"details";
NSString *const kPageDetailFields                  = @"fields";
NSString *const kPageDetailFieldDetail             = @"fieldDetail";
NSString *const kPageHeader                        = @"header";
NSString *const kEventDetails                      = @"events";

NSString *const kPageFieldApiName                  = ORG_NAME_SPACE@"__Field_API_Name__c";
NSString *const kPageFieldDisplayColumn            = ORG_NAME_SPACE@"__Display_Column__c";
NSString *const kPageFieldDisplayRow               = ORG_NAME_SPACE@"__Display_Row__c";
NSString *const kPageFieldReadOnly                 = ORG_NAME_SPACE@"__Readonly__c";
NSString *const kPageFieldRequired                 = ORG_NAME_SPACE@"__Required__c";
NSString *const kPageFieldLookupContext            = ORG_NAME_SPACE@"__Lookup_Context__c";
NSString *const kPageFieldLookupQuery              = ORG_NAME_SPACE@"__Lookup_Query_Field__c";
NSString *const kPageFieldContextSourceObject      = ORG_NAME_SPACE@"__Context_Source_Object__c";
NSString *const kPageFieldSequence                 = ORG_NAME_SPACE@"__Sequence__c";
NSString *const kPageFieldRelatedObjectSearchId    = ORG_NAME_SPACE@"__Named_Search__c";
NSString *const kPageFieldRelatedObjectName        = ORG_NAME_SPACE@"__Related_Object_Name__c";
NSString *const kPageFieldDataType                 = ORG_NAME_SPACE@"__DataType__c";
NSString *const kPageFieldLabel                    = @"Label";
NSString *const kPageFieldValueKey                 = @"Key";
NSString *const kPageFieldValueValue               = @"Value";
NSString *const kPageFieldOverrideRelatedLookup    = ORG_NAME_SPACE@"__Override_Related_Lookup__c";
NSString *const kPageFieldMapping                  = ORG_NAME_SPACE@"__Field_Mapping__c";


NSString *const kPageDetailFieldsArray             = @"DetailsFieldsArray";
NSString *const kPageDetailValuesArray             = @"";
NSString *const kPageDetailLayoutId                = @"dtlLayoutId";

NSString *const kPageDetailAllowNewLines           = ORG_NAME_SPACE@"__Allow_New_Lines__c";
NSString *const kPageDetailAllowDeleteLines        = ORG_NAME_SPACE@"__Allow_Delete_Lines__c";
NSString *const kPageDetailActionOnZeroLines       = ORG_NAME_SPACE@"__Action_On_Zero_Lines__c";
NSString *const kPageDetailNumberOfColumns         = @"noOfColumns";
NSString *const kPageDetailObjectLabel             = ORG_NAME_SPACE@"__Name__c";
NSString *const kPageDetailValuesRecordId          = @"";
NSString *const kPageDetailHeaderRefField          = ORG_NAME_SPACE@"__Header_Reference_Field__c";
NSString *const kPageDetailObjectName              = ORG_NAME_SPACE@"__Object_Name__c";
NSString *const kPageDetailSequenceNo              = ORG_NAME_SPACE@"__Sequence__c";
NSString *const kPageDetailObjectAliasName         = ORG_NAME_SPACE@"__Name__c";
NSString *const kPageDetailDeletedRecord           = @"";
NSString *const kPageDetailMuliaddConfig           = ORG_NAME_SPACE@"__Multi_Add_Configuration__c";
NSString *const kPageDetailMultiAddSearch          = ORG_NAME_SPACE@"__Multi_Add_Search_Field__c";
NSString *const kPageDetailMultiaddSearchObject    = ORG_NAME_SPACE@"__Multi_Add_Search_Object__c";
NSString *const kPageDetailPageLayoutId            = ORG_NAME_SPACE@"__Page_Layout_ID__c";
NSString *const kcurrentRecordContextFilter        = @"CURRENT_RECORD";

/*page Layout Params*/
NSString *const kSVMXPageUi               = @"pageUI";
NSString *const kSVMXPage                 = @"page";
NSString *const kSVMXPageDetails          = @"details";
NSString *const kSVMXPageFields           = @"fields";
NSString *const kSVMXPageHeader           = @"header";
NSString *const kSVMXPageSections         = @"sections";
NSString *const kSVMXPageFieldDetail      = @"fieldDetail";

NSString *const kSVMXPageDataType         = ORG_NAME_SPACE@"__DataType__c";
NSString *const kSVMXPageReferenceField   = ORG_NAME_SPACE@"__Related_Object_Name__c";
NSString *const kSVMXHdrLayoutId          = @"hdrLayoutId";


