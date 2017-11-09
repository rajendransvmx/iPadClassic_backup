//
//  DatabaseConstant.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/26/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   DatabaseConstant.m
 *  @class  DatabaseConstant
 *
 *  @brief  This class will provide all conatnats which are uses in table/database operations.
 *
 *
 *  @author  Pushpak N
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import "DatabaseConstant.h"

/* Account */
NSString *const kAccountTableName  = @"Account";
NSString *const kAccountName       = @"Name";

/*Sales force supported data types */
NSString *const kSfDTBoolean    = @"boolean";
NSString *const kSfDTCurrency   = @"currency";
NSString *const kSfDTDouble     = @"double";
NSString *const kSfDTPercent    = @"percent";
NSString *const kSfDTInteger    = @"integer";
NSString *const kSfDTDate       = @"date";
NSString *const kSfDTDateTime   = @"datetime";
NSString *const kSfDTTextArea   = @"textarea";
NSString *const kSfDTString     = @"string";
NSString *const kSfDTReference  = @"reference";
NSString *const kSfDTPicklist   = @"picklist";
NSString *const kSfDTEmail      = @"email";
NSString *const kSfDTUrl        = @"URL";


NSString *const kSfDTRecordTypeId   = @"RecordTypeId";
NSString *const kSfDTMultiPicklist  = @"multipicklist";
NSString *const kTargetChild        = @"TARGETCHILD";
NSString *const kProcessTableName   = @"SFProcess";
NSString *const kSFObjectField      = @"SFObjectField";
NSString *const kTarget             = @"TARGET";

NSString *const kProcessComponentTableName  = @"SFProcessComponent";
NSString *const kMobileDeviceTagsTableName = @"MobileDeviceTags";

/*Database datatypes*/
NSString *const kDTBool     = @"BOOL";
NSString *const kDTVarChar  = @"VARCHAR";
NSString *const kDTText     = @"TEXT";
NSString *const kDTDouble   = @"DOUBLE";
NSString *const kDTDateTime = @"DATETIME";
NSString *const kDTInteger = @"INTEGER";

NSString *const kTrue       = @"true";
NSString *const kFalse      = @"false";
NSString *const kLocalId    = @"localId";
NSString *const kId         = @"Id";
NSString *const kYes        = @"Yes";
NSString *const kNo         = @"No";

/*Technician details*/
NSString *const kServiceGroup               = ORG_NAME_SPACE@"__Service_Group__c";
NSString *const kInventoryLocation          = ORG_NAME_SPACE@"__Inventory_Location__c";
NSString *const kServiceGroupMembers        = ORG_NAME_SPACE@"__Service_Group_Members__c";
NSString *const kSalesForceUser             = ORG_NAME_SPACE@"__Salesforce_User__c";

/*Work order constants*/
NSString *const kWorkOrderTableName         = ORG_NAME_SPACE@"__Service_Order__c";
NSString *const kWorkOrderDetailTableName   = ORG_NAME_SPACE@"__Service_Order_Line__c";
NSString *const kIsBillableLabel            = ORG_NAME_SPACE@"__Is_Billable__c";

/*NSString *const kSLAResolutionActual        = ORG_NAME_SPACE@"__Actual_Resolution__c";
NSString *const kSLAResolutionInternal      = ORG_NAME_SPACE@"__Resolution_Internal_By__c";
NSString *const kSLAResolutionCustomer      = ORG_NAME_SPACE@"__Resolution_Customer_By__c";
NSString *const kSLARestorationActual       = ORG_NAME_SPACE@"__Actual_Restoration__c";
NSString *const kSLARestorationInternal     = ORG_NAME_SPACE@"__Restoration_Internal_By__c";
NSString *const kSLARestorationCustomer     = ORG_NAME_SPACE@"__Restoration_Customer_By__c";*/

/* WorkOrder Summary */
NSString *const kWorkOrderName                  = @"Name";
NSString *const kWorkOrderPriority              = ORG_NAME_SPACE@"__Priority__c";
NSString *const kWorkOrderLatitude              = ORG_NAME_SPACE@"__Latitude__c";
NSString *const kWorkOrderLongitude             = ORG_NAME_SPACE@"__Longitude__c";
NSString *const kWorkOrderCompanyId             = ORG_NAME_SPACE@"__Company__c";
NSString *const kWorkOrderContactId             = ORG_NAME_SPACE@"__Contact__c";
NSString *const kWorkOrderPurposeOfVisit        = ORG_NAME_SPACE@"__Purpose_of_Visit__c";
NSString *const kWorkOrderProblemDescription    = ORG_NAME_SPACE@"__Problem_Description__c";
NSString *const kWorkOrderSTREET                = ORG_NAME_SPACE@"__Street__c";
NSString *const kWorkOrderCITY                  = ORG_NAME_SPACE@"__City__c";
NSString *const kWorkOrderSTATE                 = ORG_NAME_SPACE@"__State__c";
NSString *const kWorkOrderCOUNTRY               = ORG_NAME_SPACE@"__Country__c";
NSString *const kWorkOrderZIP                   = ORG_NAME_SPACE@"__Zip__c";
NSString *const kWorkOrderBillingType           = ORG_NAME_SPACE@"__Billing_Type__c";
NSString *const kWorkOrderOrderStatus           = ORG_NAME_SPACE@"__Order_Status__c";
NSString *const kWorkOrderScheduledDateTime     = ORG_NAME_SPACE@"__Scheduled_Date_Time__c";
NSString *const kWorkOrderSite                  = ORG_NAME_SPACE@"__Site__c";

/*Work Detail Summary*/
NSString *const kSerialNumber                   = ORG_NAME_SPACE@"__Serial_Number__c";

/*Location*/
NSString *const kSiteAccountId                  = ORG_NAME_SPACE@"__Account__c";


/* PROCESS constants*/
NSString *const kProcessTypeView                = @"VIEW RECORD";
NSString *const kProcessTypeStandAloneEdit      = @"STANDALONE EDIT";
NSString *const kProcessTypeStandAloneCreate      = @"STANDALONE CREATE";

NSString *const kProcessTypeSRCToTargetAll      = @"SOURCE TO TARGET ALL";
NSString *const kProcessTypeSRCToTargetChild    = @"SOURCE TO TARGET CHILD";

NSString *const kProcessTypeOutputDocument    = @"OUTPUT DOCUMENT";

/*Expression constants*/
NSString *const kSFExpression               = @"SFExpression";
NSString *const kSFExpressionComponent      = @"SFExpressionComponent";
NSString *const kSFExpComponentLHS          = @"componentLHS";
NSString *const kSFExpComponentRHS          = @"componentRHS";
NSString *const kSFExpComponentOperator     = @"operatorValue";
NSString *const kSFExpressionId             = @"expressionId";
NSString *const kSFExpressionCompSeqNo      = @"componentSequenceNumber";
NSString *const kSFExpressionKey            = @"expression";
NSString *const kSFExpComponentFieldType    = @"fieldType";
NSString *const kSFExpComponentParamType    = @"parameterType";
NSString *const kSFExpSourceObjectName      = @"sourceObjectName";
NSString *const kSFExpErrorMessage          = @"errorMessage";


/*Name field constants*/
NSString *const kCaseNameField              = @"CaseNumber";
NSString *const kCaseObject                 = @"Case";
NSString *const kAllObjectNameField         = @"Name";
NSString *const kEventObject                = @"Event";
NSString *const kServicemaxEventObject      = ORG_NAME_SPACE@"__SVMX_Event__c";
NSString *const kEventNameField             = @"Subject";
NSString *const kEventOwnerId               = @"OwnerId";

NSString *const kSalesforceEvent            = @"Salesforce Event";

/*Incremental Data Sync related constants*/
NSString *const kSyncRecordLocalId          = @"recordLocalId";
NSString *const kSyncRecordSFId             = @"sfId";
NSString *const kSyncRecordType             = @"recordType";
NSString *const kSyncRecordOperation        = @"operation";
NSString *const kSyncRecordObjectname       = @"objectName";
NSString *const kModifiedRecords            = @"ModifiedRecords";
NSString *const kSyncRecordSent             = @"recordSent";
NSString *const kCustomActionRequestParams  = @"CustomActionRequestParams";

/* Lookup constants */
NSString *const kSearchObjectFields         = @"SRCH_Object_Fields";
NSString *const kSearchFieldTypeSearch      = @"Search";
NSString *const kSearchFieldTypeResult      = @"Result";
NSString *const kSearchFieldTypeOrderBy     = @"OrderBy";

/* search process table */
NSString *const kSearchProcessTableName     = @"SFM_Search_Process";

/*Supported literals in expression*/
NSString *const kLiteralNow                 = @"Now";
NSString *const kLiteralRecordOwner         = @"RECORDOWNER";
NSString *const kLiteralToday               = @"Today";
NSString *const kLiteralTomorrow            = @"Tomorrow";
NSString *const kLiteralYesterday           = @"Yesterday";
NSString *const kLiteralCurrentUser         = @"SVMX.CURRENTUSER";
NSString *const kLiteralOwner               = @"SVMX.OWNER";
NSString *const kLiteralCurrentRecord       = @"SVMX.CURRENTRECORD";
NSString *const kLiteralCurrentRecordHeader = @"SVMX.CURRENTRECORDHEADER";
NSString *const kLiteralUserTrunk           = @"SVMX.USERTRUNK";
NSString *const kLiteralSVMXNow             = @"SVMX.NOW";
NSString *const kLiteralCurrentUserId       = @"SVMX.CURRENTUSERID";


/*SFProcess column constants*/
NSString *const kidentifier                 = @"processId";
NSString *const kobjectApiName              = @"objectApiName";
NSString *const ksfId                       = @"sfID";
NSString *const kprocessName                = @"processName";
NSString *const ktype                       = @"processType";
NSString *const kpageLayoutId               = @"pageLayoutId";
NSString *const kprocessInfo                = @"processInfo";
NSString *const kprocessDescription         = @"processDescription";


/** DocTemplate and Attachment */
NSString *const kDocTemplateTableName         = @"DocTemplate";
NSString *const kDocTemplateDetailTableName   = @"DocTemplateDetails";
NSString *const kAttachmentsTableName         = @"Attachments";

//Attachments Documents, Images and Videos
NSString *const kAttachmentTableName          = @"Attachment";
NSString *const kAttachmentLocalTableName     = @"AttachmentLocal";
NSString *const kAttachmentErrorTableName     = @"AttachmentError";


/** SFExpression */
NSString *const kSFExpressionTableName        = @"SFExpression";

/** SFExpressionComponent */
NSString *const kSFExpressionComponentTableName = @"SFExpressionComponent";

/* SFNameSearch constants*/
NSString *const kSFNamedSearchTableName = @"SFNamedSearch";

/* SFNamedSearchComponent (SFSearchObjectDetail) constants*/
NSString *const kSFNamedSearchComponentTableName = @"SFNamedSearchComponent";

/*SFProcessComponent constants*/
NSString *const kSFProcessComponentType     = @"componentType";

/* SFMSearchField */
NSString *const kSFMSearchFieldTableName     = @"SFM_Search_Field";

/* SFMSearchFilterCriteria */
NSString *const kSFMSearchFilterCriteriaTableName     = @"SFM_Search_Filter_Criteria";

/*SFPicklist*/
NSString *const kSFPicklist         = @"SFPickList";
NSString *const kobjectName         = @"objectName";
NSString *const kfieldname          = @"fieldName";
NSString *const klabel              = @"label";
NSString *const kvalue              = @"value";
NSString *const kdefaultValue       = @"defaultValue";
NSString *const kvalidFor           = @"validFor";
NSString *const kindexValue         = @"indexValue";
NSString *const kdefaultLabel       = @"defaultLabel";


/*SFRecordType*/
NSString *const kSFRecordType       = @"SFRecordType";
NSString *const kRecordType         = @"recordType";
NSString *const kRecordTypeId       = @"recordTypeId";
NSString *const kRecordtypeLabel    = @"recordtypeLabel";

/*ObjectNameFieldValue*/
NSString *const kObjectNameFieldValue       = @"ObjectNameFieldValue";
/** SFRTPicklist */
NSString *const kSFRTPicklistTableName = @"SFRTPicklist";

/*SFobject field*/
NSString *const kSFObjectFieldReferenceTo = @"referenceTo";
NSString *const kSFObjectNameField        = @"nameField";
NSString *const kDataType                 = @"dataType";

/*SFobject*/
NSString *const kSFObject  = @"SFObject";

/*SLA Clock*/
NSString *const kSLARestorationCustomer  = ORG_NAME_SPACE@"__Restoration_Customer_By__c";
NSString *const kSLAResolutionCustomer       = ORG_NAME_SPACE@"__Resolution_Customer_By__c";
NSString *const kSLAActualRestoration          = ORG_NAME_SPACE@"__Actual_Restoration__c";
NSString *const kSLAActualResolution           = ORG_NAME_SPACE@"__Actual_Resolution__c";
NSString *const kSLAClockPauseTime          = ORG_NAME_SPACE@"__SLA_Clock_Pause_Time__c";
NSString *const kSLAClockPaused            = ORG_NAME_SPACE@"__SLA_Clock_Paused__c";
NSString *const kSLAResolutionInternal      = ORG_NAME_SPACE@"__Resolution_Internal_By__c";
NSString *const kSLARestorationInternal     = ORG_NAME_SPACE@"__Restoration_Internal_By__c";

/*Sorting Order*/
NSString *const kFieldAPIName  = @"fieldAPIName";

/* Event related */
NSString *const kActivityDate        = @"ActivityDate";
NSString *const kActivityDateTime    = @"ActivityDateTime";
NSString *const kDurationInMinutes   = @"DurationInMinutes";
NSString *const kEndDateTime         = @"EndDateTime";
NSString *const kStartDateTime       = @"StartDateTime";
NSString *const kEventIndex           = @"eventIndex";
NSString *const kEventNumber         = @"eventNumber";
NSString *const kSubject             = @"Subject";
NSString *const kWhatId              = @"WhatId";
NSString *const klocalId             = @"localId";
NSString *const kOwnerId             = @"OwnerId";
NSString *const kCountStart          = @"COUNT(*)";
NSString *const kEventDescription          = @"Description";
NSString *const kIsAlldayEvent       = @"IsAllDayEvent";

/*svmxc_event related*/
//NSString *const kSvmxcActivityDate       = ORG_NAME_SPACE@"__ActivityDate__c";
//NSString *const kSvmxActivityDateTime    = ORG_NAME_SPACE@"__ActivityDateTime__c";
//NSString *const kSvmxDurationInMinutes   = ORG_NAME_SPACE@"__DurationInMinutes__c";
//NSString *const kSvmxEndDateTime         = ORG_NAME_SPACE@"__EndDateTime__c";
//NSString *const kSvmxStartDateTime       = ORG_NAME_SPACE@"__StartDateTime__c";
//NSString *const kSvmxWhatId              = ORG_NAME_SPACE@"__WhatId__c";

/* SVMX EVENT related*/

NSString *const kSVMXTableName  = ORG_NAME_SPACE@"__SVMX_Event__c";

NSString *const kSVMXActivityDate  = ORG_NAME_SPACE@"__ActivityDate__c";
NSString *const kSVMXActivityDateTime  = ORG_NAME_SPACE@"__ActivityDateTime__c";
NSString *const kSVMXDurationInMinutes  = ORG_NAME_SPACE@"__DurationInMinutes__c";
NSString *const kSVMXStartDateTime  = ORG_NAME_SPACE@"__StartDateTime__c";
NSString *const kSVMXEndDateTime  = ORG_NAME_SPACE@"__EndDateTime__c";

NSString *const kSVMXEventDescription  = ORG_NAME_SPACE@"__Description__c";
NSString *const kSVMXlocalId  = @"localId";
NSString *const kSVMXID = @"Id";
NSString *const kSVMXWhatId  = ORG_NAME_SPACE@"__WhatId__c";
NSString *const kSVMXEventName  = @"Name";

NSString *const kSVMXOwnerId  = @"OwnerId";
NSString *const kSVMXLocation  = ORG_NAME_SPACE@"__Location__c";
NSString *const kSVMXTechnicianId  = ORG_NAME_SPACE@"__Technician__c";
NSString *const kSVMXIsAlldayEvent  = ORG_NAME_SPACE@"__IsAllDayEvent__c";

NSString *const kObjectSfId = @"objectSfId";



//ISALLDAY General use

NSString *const kGENERAL_ALL_DAY = @"isALLDay";

/*SyncErrorConflict*/

NSString *const kSyncErrorConflictTableName = @"syncErrorConflict";

/*mobileSetting */
NSString *const kSettingId     = @"settingId";


/* Contact */
NSString *const kContactTableName = @"Contact";
NSString *const kContactName  = @"Name";
NSString *const kContactEmail = @"Email";
NSString *const kContactPhone = @"Phone";
NSString *const kContactMobilePhone = @"MobilePhone";

/*SFM Page History constants*/
NSString *const kTopLevelId =  ORG_NAME_SPACE@"__Top_Level__c";
NSString *const kComponentId = ORG_NAME_SPACE@"__Component__c";
NSString *const kOrderStatus = ORG_NAME_SPACE@"__Order_Status__c";

/* JobLogs table */
NSString *const kJobLogsTableName = @"JobLogs";

/* GPSLog table */
NSString *const kUserGPSLogTableName = @"UserGPSLog";

/* TroubleShooting Constants */
NSString *const KDocId = @"Id";
NSString *const KDocName = @"Name";
NSString *const KDocKeyWords = @"Keywords";

NSString *const kProductField = ORG_NAME_SPACE@"__Product__c";
/*Child RelationShip Table*/
NSString *const kChildRelationshipTableName  = @"SFChildRelationship";
NSString *const kCRLocalIdField = @"localId";
NSString *const kCRObjectNameParentField = @"objectNameParent";
NSString *const kCRObjectNameChildField = @"objectNameChild";
NSString *const kCRFieldNameField = @"fieldName";


// Installed Product Table

NSString *const kInstalledProductTableName = ORG_NAME_SPACE@"__Installed_Product__c";
NSString *const kIPProductNameField   = ORG_NAME_SPACE@"__Product_Name__c";

//SubLocation table
NSString *const KSubLocationTableName = ORG_NAME_SPACE@"__Sub_Location__c";

//Product Table
NSString *const KProductTable=@"Product2";
NSString *const KProductName= @"Name";

/* Code snippet and Code snippet manifest table*/
NSString *const kCodeSnippetData    = ORG_NAME_SPACE@"__Data__c";
NSString *const kCodeSnippetName    = ORG_NAME_SPACE@"__Name__c";
NSString *const kTableCodeSnippet   = ORG_NAME_SPACE@"__Code_Snippet__c";
NSString *const kTableCodeManifest  = ORG_NAME_SPACE@"__Code_Snippet_Manifest__c";

/* Smart doc constants */
NSString *const kOPDocTableName  = @"OPDocHTML";
NSString *const kOPDocLocalId  = @"local_id";
NSString *const kOPDocProcessId  = @"process_id";
NSString *const kOPDocRecordId  = @"record_id";
NSString *const kOPDocObjectName  = @"objectName";
NSString *const kOPDocFileName  = @"Name";
NSString *const kOPDocSFID  = @"sfid";

NSString *const kOPDocSignatureTableName  = @"OPDocSignature";
NSString *const kOPDocSignatureId  = @"signId";
NSString *const kOPDocHTMLFileName  = @"HTMLFileName";

/*look up filters*/
NSString *const kSFNamedSearchFilters = @"SFNamedSearchFilters";
NSString *const kSearchFilterObject   = @"SRCH_OBJECT";
NSString *const kSearchFilterCriteria = @"SRCH_CRITERIA";

/*Linked SFM*/
NSString *const kLinkedProcessTable         = @"LinkedSFMProcess";
NSString *const kLinkedSfmSourceHeaderId    = @"sourceHeader";
NSString *const kLinkedSfmSourceDetailId    = @"sourceDetail";
NSString *const kLinkedSfmTargetHeaderId    = @"targetHeader";

/*Business Rule Tables*/
NSString *const kProcessBusinessRuleTable = @"ProcessBusinessRule";
NSString *const kBusinessruleTable = @"BusinessRule";

/*Constants related to BusinessRule table*/
NSString * const kBizRuleAdvExpression = @"advancedExpression";
NSString * const kBizRuleErrorMessage = @"errorMessage";
NSString * const kBizRuleMessageType = @"messageType";
NSString * const kBizRuleSourceObjectName = @"sourceObjectName";
NSString * const kBizRuleSfId = @"Id";
NSString * const kBizRuleDescription = @"description";
NSString * const kBusinessRuleProcessId = @"processId";
NSString * const kBusinessRuleRuleType = @"ruleType";


/*Constants related to ProcessBusinessRule table*/
NSString * const kBizRuleProcessSfId = @"Id";
NSString * const kBizRuleProcessRuleId = @"businesRule";
NSString * const kBizRuleProcessNodeObject = @"processNodeObject";
NSString * const kBizRuleProcessSequence = @"sequence";
NSString * const kBizRuleProcessTargetManager = @"targetManager";
NSString * const kBizRuleProcessErrorMessage = @"errorMessage";

/*Notification constant for OPDoc*/
NSString * const OPDocSavedNotification = @"OPDocSavedNotification";


/** DataPurgeHeap Table */
NSString *const kDataPurgeHeapTable = @"DataPurgeHeap";

NSString * const kIsMultiDayEvent = @"isMultiDay";
NSString * const kSplitDayEvents = @"SplitDayEvents";
NSString * const kTimeZone = @"TimeZone";
NSString * const kCompleteWhatId = @"completeWhatID";

// PageEventProcessManager Constants
NSString * const kBeforeSaveProcessKey = @"Before Save/Update";
NSString * const kAfterSaveProcessKey = @"After Save/Update";
NSString * const kAfterSaveInsertKey = @"After Save/Insert";
NSString * const kWebserviceProcessKey = @"WEBSERVICE";
NSString * const kCodeSnippetID      = ORG_NAME_SPACE@"__SnippetId__c";
NSString * const kChangedLocalIDForCustomCall = @"Dummy";
