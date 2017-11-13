//
//  DatabaseConstant.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/26/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   DatabaseConstant.h
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


#import <Foundation/Foundation.h>

/* Account */
extern NSString *const kAccountTableName;
extern NSString *const kAccountName;

/*Sales force supported data types */
/** SfDT = SalesForceDataType */
extern NSString *const kSfDTBoolean;        //BOOLEAN
extern NSString *const kSfDTCurrency;       //CURRENCY
extern NSString *const kSfDTDouble;         //DOUBLE
extern NSString *const kSfDTPercent;        //PERCENT
extern NSString *const kSfDTInteger;        //INTEGER
extern NSString *const kSfDTDate;           //DATE
extern NSString *const kSfDTDateTime;       //DATETIME
extern NSString *const kSfDTTextArea;       //TEXTAREA
extern NSString *const kSfDTString;         //STRING
extern NSString *const kSfDTReference;      //REFERENCE
extern NSString *const kSfDTPicklist;       //PICKLIST
extern NSString *const kSfDTRecordTypeId;   //RECORD_TYPE_ID
extern NSString *const kSfDTMultiPicklist;  //MULTI_PICKLIST
extern NSString *const kSfDTEmail;
extern NSString *const kTargetChild;
extern NSString *const kProcessTableName;
extern NSString *const kSFObjectField;
extern NSString *const kProcessComponentTableName;
extern NSString *const kTarget;



extern NSString *const kMobileDeviceTagsTableName;

/*Database datatypes*/
/** DT datatype*/
extern NSString *const kDTBool;     //kBOOL
extern NSString *const kDTVarChar;  //VARCHAR
extern NSString *const kDTText;     //TEXT
extern NSString *const kDTDouble;     //DOUBLE
extern NSString *const kDTDateTime;     //DATETIME
extern NSString *const kDTInteger; //INTEGER
extern NSString *const kTrue;
extern NSString *const kFalse;
extern NSString *const kLocalId;
extern NSString *const kId;
extern NSString *const kYes;
extern NSString *const kNo;

/*Technician details*/
extern NSString *const kServiceGroup;
extern NSString *const kInventoryLocation;
extern NSString *const kServiceGroupMembers;
extern NSString *const kSalesForceUser;


/*Work order constants*/
extern NSString *const kWorkOrderTableName;
extern NSString *const kWorkOrderDetailTableName;
extern NSString *const kIsBillableLabel;

/*extern NSString *const kSLAResolutionActual;
extern NSString *const kSLAResolutionInternal;
extern NSString *const kSLAResolutionCustomer;
extern NSString *const kSLARestorationActual;
extern NSString *const kSLARestorationInternal;
extern NSString *const kSLARestorationCustomer;*/


/* WorkOrder Summary */
extern NSString *const kWorkOrderName;
extern NSString *const kWorkOrderLatitude;
extern NSString *const kWorkOrderLongitude;
extern NSString *const kWorkOrderPriority;
extern NSString *const kWorkOrderCompanyId;
extern NSString *const kWorkOrderContactId;
extern NSString *const kWorkOrderPurposeOfVisit;
extern NSString *const kWorkOrderProblemDescription;
extern NSString *const kWorkOrderCITY;
extern NSString *const kWorkOrderSTATE;
extern NSString *const kWorkOrderSTREET;
extern NSString *const kWorkOrderZIP;
extern NSString *const kWorkOrderCOUNTRY;
extern NSString *const kWorkOrderScheduledDateTime;
extern NSString *const kWorkOrderBillingType;
extern NSString *const kWorkOrderOrderStatus;
extern NSString *const kWorkOrderSite;

/* PROCESS constants */
extern NSString *const kProcessTypeView;
extern NSString *const kProcessTypeStandAloneEdit;
extern NSString *const kProcessTypeStandAloneCreate;
extern NSString *const kProcessTypeSRCToTargetAll;
extern NSString *const kProcessTypeSRCToTargetChild;
extern NSString *const kProcessTypeOutputDocument;

/* Expression constants */
extern NSString *const kSFExpression;
extern NSString *const kSFExpressionComponent;
extern NSString *const kSFExpComponentLHS;
extern NSString *const kSFExpComponentRHS;
extern NSString *const kSFExpComponentOperator;
extern NSString *const kSFExpressionId;
extern NSString *const kSFExpressionCompSeqNo;
extern NSString *const kSFExpressionKey;
extern NSString *const kSFExpComponentFieldType;
extern NSString *const kSFExpComponentParamType;
extern NSString *const kSFExpSourceObjectName;
extern NSString *const kSFExpErrorMessage;

/* Name field constants */
extern NSString *const kCaseNameField;      //kCASE_NAME_Field
extern NSString *const kCaseObject;
extern NSString *const kAllObjectNameField; //kALL_OBJECT_NAME_FIELD
extern NSString *const kEventObject;
extern NSString *const kServicemaxEventObject;
extern NSString *const kEventNameField;
extern NSString *const kEventOwnerId;

extern NSString *const kSalesforceEvent;

/* Incremental Data Sync related constants */
extern NSString *const kSyncRecordLocalId;
extern NSString *const kSyncRecordSFId;
extern NSString *const kSyncRecordType;
extern NSString *const kSyncRecordOperation;
extern NSString *const kSyncRecordObjectname;

extern NSString *const kModifiedRecords;
extern NSString *const kSyncRecordSent;
extern NSString *const kCustomActionRequestParams;

/* Lookup constants */
extern NSString *const kSearchObjectFields;
extern NSString *const kSearchFieldTypeSearch;
extern NSString *const kSearchFieldTypeResult;
extern NSString *const kSearchFieldTypeOrderBy;

/*Supported literals in expression */
extern NSString *const kLiteralNow;
extern NSString *const kLiteralRecordOwner;
extern NSString *const kLiteralToday;
extern NSString *const kLiteralTomorrow;
extern NSString *const kLiteralYesterday;
extern NSString *const kLiteralCurrentUser;
extern NSString *const kLiteralOwner;
extern NSString *const kLiteralCurrentRecord;
extern NSString *const kLiteralCurrentRecordHeader;
extern NSString *const kLiteralUserTrunk;
extern NSString *const kLiteralSVMXNow;
extern NSString *const kLiteralCurrentUserId;

extern NSString *const kidentifier;
extern NSString *const kobjectApiName;
extern NSString *const ksfId;
extern NSString *const kprocessName;
extern NSString *const kprocessDescription;
extern NSString *const ktype;
extern NSString *const kpageLayoutId;
extern NSString *const kprocessInfo;

/*DocTemplate and attachments constants*/
extern NSString *const kDocTemplateTableName;
extern NSString *const kDocTemplateDetailTableName;
extern NSString *const kAttachmentsTableName;

//Attachments Documents, Images and Videos
extern NSString *const kAttachmentTableName;
extern NSString *const kAttachmentLocalTableName;
extern NSString *const kAttachmentErrorTableName;


/* SFExpression table */
extern NSString *const kSFExpressionTableName;

/** SFExpressionComponent */
extern NSString *const kSFExpressionComponentTableName;

/*SFProcessComponent constants*/
extern NSString *const kSFProcessComponentType;

/* SFMSearchField */
extern NSString *const kSFMSearchFieldTableName;

/* SFMSearchFilterCriteria */
extern NSString *const kSFMSearchFilterCriteriaTableName;

/*SFPicklist*/
extern NSString *const kSFPicklist;
extern NSString *const kSFPicklist;
extern NSString *const kobjectName;
extern NSString *const kfieldname;
extern NSString *const klabel;
extern NSString *const kvalue;
extern NSString *const kdefaultValue;
extern NSString *const kvalidFor;
extern NSString *const kindexValue;
extern NSString *const kdefaultLabel;

/*SFRecordType*/
extern NSString *const kSFRecordType;
extern NSString *const kRecordType;
extern NSString *const kRecordTypeId;
extern NSString *const kRecordtypeLabel;

/* SFNameSearch constants*/
extern NSString *const kSFNamedSearchTableName;

/* SFNamedSearchComponent (SFSearchObjectDetail) constants*/
extern NSString *const kSFNamedSearchComponentTableName;

/*ObjectNameFieldValue*/
extern NSString *const kObjectNameFieldValue;

/** SFRTPicklist */
extern NSString *const kSFRTPicklistTableName;

/*SFobject field*/
extern NSString *const kSFObjectFieldReferenceTo;
extern NSString *const kSFObjectNameField;
extern NSString *const kDataType;

/*SFobject*/
extern NSString *const kSFObject;

/*SLA Clock*/
extern NSString *const kSLARestorationCustomer;
extern NSString *const kSLAResolutionCustomer;
extern NSString *const kSLAActualRestoration;
extern NSString *const kSLAActualResolution;
extern NSString *const kSLAClockPauseTime;
extern NSString *const kSLAClockPaused;
extern NSString *const kSLAResolutionInternal;
extern NSString *const kSLARestorationInternal;

/*Work Detail Summary*/
extern NSString *const kSerialNumber;

/*Sorting Order*/
extern NSString *const kFieldAPIName;

/* Event related constants */
extern NSString *const kActivityDate;
extern NSString *const kActivityDateTime;
extern NSString *const kDurationInMinutes;
extern NSString *const kEndDateTime;
extern NSString *const kStartDateTime;
extern NSString *const kEventIndex;
extern NSString *const kEventNumber;
extern NSString *const kSubject;
extern NSString *const kWhatId;
extern NSString *const klocalId;
extern NSString *const kOwnerId;
extern NSString *const kEventDescription;
extern NSString *const kIsAlldayEvent;

/*svmxc event related*/
//extern NSString *const kSvmxcActivityDate;
//extern NSString *const kSvmxActivityDateTime;
//extern NSString *const kSvmxDurationInMinutes;
//extern NSString *const kSvmxEndDateTime;
//extern NSString *const kSvmxStartDateTime;
//extern NSString *const kSvmxWhatId;

/* SVMX Event related constants */

extern NSString *const kSVMXTableName;
extern NSString *const kSVMXActivityDate;
extern NSString *const kSVMXActivityDateTime;
extern NSString *const kSVMXDurationInMinutes;
extern NSString *const kSVMXStartDateTime;
extern NSString *const kSVMXEndDateTime;
extern NSString *const kSVMXEventDescription;
extern NSString *const kSVMXlocalId;
extern NSString *const kSVMXID;
extern NSString *const kSVMXWhatId;
extern NSString *const kSVMXOwnerId;
extern NSString *const kSVMXLocation;
extern NSString *const kSVMXEventName;
extern NSString *const kSVMXTechnicianId;
extern NSString *const kSVMXIsAlldayEvent;
extern NSString *const kSfDTUrl;

extern NSString *const kGENERAL_ALL_DAY;

extern NSString *const kObjectSfId;
//Id use kId
/*SyncErrorConflict*/
extern NSString *const kSyncErrorConflictTableName;
extern NSString *const kCountStart;

/* Contact */
extern NSString *const kContactTableName;
extern NSString *const kContactName;
extern NSString *const kContactEmail;
extern NSString *const kContactPhone;
extern NSString *const kContactMobilePhone;

extern NSString *const kSettingId;
/*SFM Page History constants*/
extern NSString *const kTopLevelId;
extern NSString *const kComponentId;
extern NSString *const kOrderStatus;

/*Location*/
extern NSString *const kSiteAccountId;


/* search process table */
extern NSString *const kSearchProcessTableName;

/* JobLogs table */
extern NSString *const kJobLogsTableName;

/* GPSLog table */
extern NSString *const kUserGPSLogTableName;

/* TroubleShootingConstants */
extern NSString *const KDocId;
extern NSString *const KDocName;
extern NSString *const KDocKeyWords;

extern NSString *const kProductField;

/*Child RelationShip Table*/
extern NSString *const kChildRelationshipTableName;
extern NSString *const kCRLocalIdField;
extern NSString *const kCRObjectNameParentField;
extern NSString *const kCRObjectNameChildField;
extern NSString *const kCRFieldNameField;


// Installed Product Table

extern NSString *const kInstalledProductTableName;
extern NSString *const kIPProductNameField;

//SubLocation Table.
extern NSString *const KSubLocationTableName;

//ProductList
extern NSString *const KProductTable;
extern NSString *const KProductName;

extern NSString *const kCRFieldNameField;

extern NSString *const kCodeSnippetData;
extern NSString *const kCodeSnippetName;
extern NSString *const kTableCodeSnippet;
extern NSString *const kTableCodeManifest;

/* Smart doc constants */
extern NSString *const kOPDocTableName;
extern NSString *const kOPDocLocalId;
extern NSString *const kOPDocProcessId;
extern NSString *const kOPDocRecordId;
extern NSString *const kOPDocObjectName;
extern NSString *const kOPDocFileName;
extern NSString *const kOPDocSFID;

extern NSString *const kOPDocSignatureTableName;
extern NSString *const kOPDocSignatureId;
extern NSString *const kOPDocHTMLFileName;

/*look up filters*/
extern NSString *const kSFNamedSearchFilters;
extern NSString *const kSearchFilterObject;
extern NSString *const kSearchFilterCriteria;

/*Linked SFM*/
extern NSString *const kLinkedProcessTable;
extern NSString *const kLinkedSfmSourceHeaderId;
extern NSString *const kLinkedSfmSourceDetailId;
extern NSString *const kLinkedSfmTargetHeaderId;


/*Business Rule*/
extern NSString *const kProcessBusinessRuleTable;
extern NSString *const kBusinessruleTable;


/*Constants related to BusinessRule table*/
extern NSString * const kBizRuleSfId;
extern NSString * const kBizRuleAdvExpression;
extern NSString * const kBizRuleErrorMessage;
extern NSString * const kBizRuleDescription;
extern NSString * const kBizRuleMessageType;
extern NSString * const kBizRuleSourceObjectName;
extern NSString * const kBusinessRuleProcessId;
extern NSString * const kBusinessRuleRuleType;

/*Constants related to ProcessBusinessRule table*/
extern NSString * const kBizRuleProcessSfId;
extern NSString * const kBizRuleProcessRuleId;
extern NSString * const kBizRuleProcessNodeObject;
extern NSString * const kBizRuleProcessSequence;
extern NSString * const kBizRuleProcessTargetManager;
extern NSString * const kBizRuleProcessErrorMessage;

/*Notification constant for OPDoc*/
extern NSString * const OPDocSavedNotification;

/** DataPurgeHeap table */
extern NSString *const kDataPurgeHeapTable;

extern NSString * const kIsMultiDayEvent;
extern NSString * const kSplitDayEvents;
extern NSString * const kTimeZone;
extern NSString * const kCompleteWhatId;

// PageEventProcessManager Constants
extern NSString * const kBeforeSaveProcessKey;
extern NSString * const kAfterSaveProcessKey;
extern NSString * const kAfterSaveInsertKey;
extern NSString * const kWebserviceProcessKey;

extern NSString *const kCodeSnippetID;
extern NSString * const kChangedLocalIDForCustomCall;
