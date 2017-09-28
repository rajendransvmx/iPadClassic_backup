//
//  ResponseConstants.h
//  ServiceMaxMobile
//
//  Created by shravya on 21/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>


/* TargetManager constant */
extern NSString *const kProcessUniqueId;
extern NSString *const kProcessSFID;
extern NSString *const kObjectApiName;
extern NSString *const kProcessType;
extern NSString *const kProcessName;
extern NSString *const kProcessDesc;
extern NSString *const kPageLayoutId;
extern NSString *const kDocTemplate;

/* MobileDeviceSettings OBJECT */
extern NSString *const kMobileSettingsUniqueId;
extern NSString *const kMobileSettingsValue;
extern NSString *const kMobileSettingsDisplayValue;
extern NSString *const kMobileSettingsAggressiveSync;

/* SFObjectMapping OBJECT */
extern NSString *const kObjMapId;
extern NSString *const kObjMapSourceObjectName;
extern NSString *const kObjMaptargetObjectName;

/* SFProcessComponent OBJECT */
extern NSString *const  kPCompSFId;
extern NSString *const  kPCompProcessId;
extern NSString *const  kPCompPageLayout;
extern NSString *const  kPCompType;
extern NSString *const  kPCompObjectName;
extern NSString *const  kPCompTargetObjLabel;
extern NSString *const  kPCompEntryCriteria;
extern NSString *const  kPCompObjectMappingId;
extern NSString *const  kPCompValueMappingId;
extern NSString *const  kPCompParentNodeId;
extern NSString *const  kPCompParentObjectName;
extern NSString *const  kPCompValuesC;
extern NSString *const  kPCompDocTemplateId;
extern NSString *const  kPCompEnableAttachment;
extern NSString *const  kPCompParentColumnName;

extern NSString *const  kPCompSequence;

/* Page layout */
extern NSString *const kSVMXCallBackIds;
extern NSString *const kSVMXObjectList;
extern NSString *const kSVMXRTObjects;


//dynamic value properties
extern NSString *const kSVMXValue;
extern NSString *const kSVMXKey;
extern NSString *const kSVMXSVMXMap;
extern NSString *const kSVMXValues;

extern NSString *const  kPCompSequence;
extern NSString *const  kPCompProcessNodeId;

/* SFM_SEARCH_PROCESS OBJECT */
extern NSString *const ksfmSearchProcessSFID;
extern NSString *const ksfmSearchName;
extern NSString *const ksfmSearchProcessDescrip;
extern NSString *const ksfmSearchProcessName;

/* SFSearchObject Object*/
extern NSString *const kSfmSearchObjId;
extern NSString *const kSfmSearchObjProcessID;
extern NSString *const kSfmSearchObjTargetObjName;
extern NSString *const kSfmSearchObjModule;
extern NSString *const kSfmSearchObjAdvExpr;
extern NSString *const kSfmSearchObjParentObjCriteria;
extern NSString *const kSfmSearchObjName;
extern NSString *const kSearchCriteriaSequence;

/* SFObjectMappingComponent OBJECT */
extern NSString *const kObjMapCompId;
extern NSString *const kObjMapCompSourceFieldName;
extern NSString *const kObjMapCompTargetFieldName;
extern NSString *const kObjMapCompMappingValue;
extern NSString *const kObjMapCompPreference2;
extern NSString *const kObjMapCompPreference3;
/* SFWizard  Object */

extern NSString *const kWizardSfId;
extern NSString *const KwizardActive;
extern NSString *const KwizardDescription;
extern NSString *const KwizardName;
extern NSString *const KwizardSourceObjName;
extern NSString *const KwizardSubmodule;
extern NSString *const kWizardLayoutRow;
extern NSString *const kWizardlayoutColumn;
extern NSString *const kWizardDispatchProcessId;

/* SFWizardComponent Object*/

extern NSString *const kWizardCompId;
extern NSString *const kWizardCompActionType;
extern NSString *const kWizardCompDescription;
extern NSString *const kWizardCompModule;
extern NSString *const kWizardCompSubModule;
extern NSString *const kWizardCompName;
extern NSString *const kWizardCompProcess;
extern NSString *const kWizardCompSequence;
extern NSString *const kWizardCompStepName;
extern NSString *const kWizardCompClassName;
extern NSString *const kWizardCompMethodName;
extern NSString *const kWizardCompCustomActionType;
extern NSString *const kWizardCompCustomActionUrl;

/* custom Action Url */
extern NSString *const kCustomActionProcessId;
extern NSString *const kCustomActionDispatchProcess;
extern NSString *const kCustomActionParameterName;
extern NSString *const kCustomActionParameterType;
extern NSString *const kCustomActionParameterValue;
extern NSString *const kCustomActionName;

/* SFExpression */
/* SFExpression Object*/
extern NSString *const kExpressionId;
extern NSString *const kExpressionProcessId;
extern NSString *const kExpressionSourceObjName;
extern NSString *const kExpressionFailureReason;
extern NSString *const kExpressionSequence;
extern NSString *const kExpressionAdvExpression;
extern NSString *const kExpressionErrorMsg;

/* SFExpressionComponent Object*/
extern NSString *const kExpressionCompExprRule;
extern NSString *const kExpressionCompFieldName;
extern NSString *const kExpressionCompOperator;
extern NSString *const kExpressionCompOperand;
extern NSString *const kExpressionCompDisplayType;
extern NSString *const kExpressionCompSequence;
extern NSString *const kExpressionCompParentType;
extern NSString *const kExpressionCompExprtype;
extern NSString *const kExpressionCompFormula;
extern NSString *const kExpressionCompActionType;
extern NSString *const kExpressionCompDescription;


/*BusinessRule OBJECT */

extern NSString *const kBizRulesId;
extern NSString *const kBizRulesName;
extern NSString *const kBizRulesTargetManager;
extern NSString *const kBizRulesProcessNodeObject;
extern NSString *const kBizRule;
extern NSString *const kBizRulesErrorMsg;
extern NSString *const kBizRulesSequence;
extern NSString *const kBizRulesAdvExpression;
extern NSString *const kBizRulesDescription;
extern NSString *const kBizRulesMsgType;
extern NSString *const kBizRulesProcessId;
extern NSString *const kBizRulesSrcObjectName;
extern NSString *const kBizRulesRuleType;

/*DOC Template Object*/
extern NSString *const kDocTemplateName;
extern NSString *const kDocTemplateTableId;
extern NSString *const kDocTemplateId;
extern NSString *const kDocTemplateIsStandard;
extern NSString *const kDocTemplateDetailObjectCount;
extern NSString *const kDocTemplateMediaResources;

/*DOC Template details Object*/
extern NSString *const kDocTempDetailDocTemplate;
extern NSString *const kDocTempDetailId;
extern NSString *const kDocTempDetailheaderRefField;
extern NSString *const kDocTempDetailalias;
extern NSString *const kDocTempDetailobjectName;
extern NSString *const kDocTempDetailsoql;
extern NSString *const kDocTempDetailUniqueId;
extern NSString *const kDocTempDetailfields;
extern NSString *const kDocTempDetailtype;
extern NSString *const kDocTempDetailidTable;

/*Attachments Object*/
extern NSString *const kAttachmentId;
extern NSString *const kAttachmentName;
extern NSString *const kAttachmentParentId;
extern NSString *const kAttachmentBody;

/*Attachment images, videos, pdf Object*/
extern NSString *const kAttachmentTXlocalId;
extern NSString *const kAttachmentTXBody;
extern NSString *const kAttachmentTXParentId;
extern NSString *const kAttachmentTXCreatedDate;
extern NSString *const kAttachmentTXContentType;
extern NSString *const kAttachmentTXBodyLength;
extern NSString *const kAttachmentTXOwnerId;
extern NSString *const kAttachmentTXCreatedById;
extern NSString *const kAttachmentTXLastModifiedDate;
extern NSString *const kAttachmentTXId;
extern NSString *const kAttachmentTXIsPrivate;
extern NSString *const kAttachmentTXDescription;
extern NSString *const kAttachmentTXIsDeleted;
extern NSString *const kAttachmentTXName;
extern NSString *const kAttachmentTXSystemModStamp;
extern NSString *const kAttachmentTXLastModifiedById;

/*Attachment error objects */
extern NSString *const kAttachmentERlocalId ;
extern NSString *const kAttachmentERParentSFId;
extern NSString *const kAttachmentERId;
extern NSString *const kAttachmentERName;
extern NSString *const kAttachmentERErrorCode;
extern NSString *const kAttachmentERErrorMessage;



/*NamedSearch constants*/
extern NSString *const kNamedSearchId;
extern NSString *const kNamedSearchLookupColumn;
extern NSString *const kNamedSearchIsDefault;
extern NSString *const kNamedSearchIsStandard;
extern NSString *const kNamedSearchName;
extern NSString *const kNamedSearchNoOfLookupRecs;
extern NSString *const kNamedSearchProcessID;
extern NSString *const kNamedSearchRuleType;
extern NSString *const kNamedSearchSourceObjName;

/* SFNamedSearchComponent (SFSearchObjectDetail) Constants */
extern NSString *const kNSComponentExpressionType;
extern NSString *const kNSComponentFieldName;
extern NSString *const kNSComponentNamedSearchId;
extern NSString *const kNSComponentSearchFieldType;
extern NSString *const kNSComponentFieldDataType;
extern NSString *const kNSComponentFieldRelation;
extern NSString *const kNSComponentSequence;
extern NSString *const kNSCompoentKeyNameField;

/* SFM_SEARCH_DETAILS */
extern NSString *const kSearchDetailSFID;
extern NSString *const kSearchDisplayType;
extern NSString *const kSearchExpRule;
extern NSString *const kSearchObjFieldType;
extern NSString *const kSearchObjName;
extern NSString *const kSearchObjName2;
extern NSString *const kSearchFieldName;
extern NSString *const kSearchLookupFieldApiName;
extern NSString *const kSearchFieldRelationShipName;
extern NSString *const kSearchSortOrder;
extern NSString *const kSearchOperator;
extern NSString *const kSearchOperand;
extern NSString *const kSearchExpressionType;
extern NSString *const kSearchCriteriaSequence;
extern NSString *const kSearchObjectId;
/* Page layout */

extern NSString *const kFILTER_CRITERIA_OBJ;



/* SFObject, SFObjectField, SFPicklist, SFRecordType, SFChildRelatioship*/
extern NSString *const  kAPIObjectDefnObject;
extern NSString *const  kAPIObjectDefnProperty;
extern NSString *const  kAPIObjDefnObjDefn;
extern NSString *const  kAPIObjDefnKeyPrefix;
extern NSString *const  kAPIObjDefnlabel;
extern NSString *const  kAPIObjDefnPluLabel;
extern NSString *const  kAPIObjDefnQueryable;
extern NSString *const  kAPIObjDefnMasterDetails;
extern NSString *const  kAPIObjDefnRecordType;
extern NSString *const  kAPIObjDefnFieldProperty;
extern NSString *const  kAPIObjDefnKeyField;
extern NSString *const  kAPIObjDefnType;
extern NSString *const  kAPIObjDefnCreatable;
extern NSString *const  kAPIObjDefnUpdatable ;
extern NSString *const  kAPIObjDefnLength;
extern NSString *const  kAPIObjDefnNameField ;
extern NSString *const  kAPIObjDefnReferencedTo;
extern NSString *const  kAPIObjDefnRelationShipName;
extern NSString *const  kAPIObjDefnDependentPickList;
extern NSString *const  kAPIObjDefnControllerField;
extern NSString *const  kAPIObjDefnPicklistInfo;
extern NSString *const  kAPIObjDefnPicklistvalue;
extern NSString *const  kAPIObjDefnPicklistLabel;
extern NSString *const  kAPIObjDefnPicklistDefalut;
extern NSString *const  kAPIGetPriceRequiredObjects;
extern NSString *const  kAPIObjDefnPrecision;
extern NSString *const  kAPIObjDefnScale;


/* SFSourceUpdate    Object*/
extern NSString *const kSourceUpdateId ;
extern NSString *const kSSourceUpdateProcessId;
extern NSString *const kSSourceUpdateSettingId ;
extern NSString *const kSSourceUpdateAction;
extern NSString *const kSSourceUpdateConfigType;
extern NSString *const kSSourceUpdateDisplayValue;
extern NSString *const kSSourceUpdateSrcFieldName;
extern NSString *const kSSourceUpdatetargetFieldName;

/*DependentPicklist  constants*/

extern NSString *const kPICKLISTFIELDS;
extern NSString *const kPICKLISTVALUES;
extern NSString *const kPICKLISTVALIDFOR;
extern NSString *const kPickListValue;
extern NSString *const kPickListName;
extern NSString *const kDependentPickListType;
extern NSString *const kMultiPicklist;
extern NSString *const kPicklist;
extern NSString *const kDependentPicklist;
extern NSString *const kControllerName;    
extern NSString *const kFieldApiName;
extern NSString *const kObjApiName;
extern NSString *const kIndex;

/* GetPriceData Constants */
extern NSString *const kGetPriceWarrantyObjectName;
extern NSString *const kGetPriceDataLastIndex;
extern NSString *const kGetPriceDataLastId;
extern NSString *const kGetPriceDataPricingData;

/*static resource*/
extern NSString *const kStaticResourceKey;
extern NSString *const kStaticResource;
extern NSString *const kStaticResourceId;
extern NSString *const kStaticResourceName;

/* Adv Download Criteria constants */
extern NSString *const kADCPartiallyExecutedObjectKey;
extern NSString *const kADCDeleteKey;
extern NSString *const kADCCallBackKey;

/* One call sync */
extern NSString * const kConflict;
extern NSString * const kCallBack;
extern NSString * const kCallbackContext;
extern NSString * const kCallBackInCaps;
extern NSString * const kCurrentContextKey;
extern NSString * const kPartiallyExecutedobj;
extern NSString * const kPartiallyExecutedobjUpdate;
extern NSString * const kPartiallyExecutedobjDelete;
extern NSString * const kLastOneCallSyncPutUpdateTime;
extern NSString * const kAllEvents;
extern NSString * const kRecordIds;


/* timeLog constants */
extern NSString *const kTimeT4;
extern NSString *const kTimeT5;
extern NSString *const kTimeT1;
extern NSString *const kTimeLogId;
extern NSString *const kRequestTypeKey;
extern NSString *const kAttributeKey;
extern NSString *const kTimeLogRequestID;
extern NSString *const kTimeLogClientProcessingTimeStamp;
extern NSString *const kTimeLogClientReceivingTimeStamp;
extern NSString *const kTimeLogStatus;
extern NSString *const ktimeLogType;
extern NSString *const kTimeLogSucess;
extern NSString *const kTimeLogFailure;
extern NSString *const kTimeLogFailureID;


/* SEARCH_OBJECT Server Contants  */
extern NSString *const kSearchFilterParentObjectCriteria;
extern NSString *const kSearchFilterStatus;
extern NSString *const kSearchFilterSequence;
extern NSString *const kSearchFilterRuleType;
extern NSString *const kSearchFilterSourceObjectName;
extern NSString *const kSearchFilterName;
extern NSString *const kSearchFilterAllowOveride;
extern NSString *const kSaerchFilterDefaultOn;
extern NSString *const kSearchFilterFieldName;
extern NSString *const kSearchFilterModuleId;
extern NSString *const kSearchFilterAdvanceExpression;
extern NSString *const kSearchFiltrerId;


/*Linked SFM*/
extern NSString *const kLinkefSfmId;
extern NSString *const kLinkedSfmProcess1;
extern NSString *const kLinkedSfmProcess2;
extern NSString *const kLinkedSfmProcess3;


/*Chatter*/
extern NSString *const kRecords;
extern NSString *const kResult;
extern NSString *const kFeedComments;

/*Pulse constants*/
extern NSString *const kPulseNotificationString;
extern NSString *const kPulseNotificationId;
extern NSString *const kPulseNotificationSFId;
extern NSString *const kPulseNotificationObjectName;
extern NSString *const kPulseNotificationActionTag;
extern NSString *const kPulseNotificationUserId;
extern NSString *const kPulseNotificationOrgId;
extern NSString *const kPulseNotificationLocalId;
extern NSString *const kPulseNotificationMessage;
extern NSString *const kPulseNotificationAps;
extern NSString *const kPulseNotificationDownload;
extern NSString *const kPulseNotificationTitle;

/*Map error*/
extern NSString *const kMapErrorNotFound;
extern NSString *const kMapErrorZeroResults;
extern NSString *const kMapErrorWayPointsExceeded;
extern NSString *const kMapErrorInvalidRequest;
extern NSString *const kMapErrorOverQueryLimit;
extern NSString *const kMapErrorRequestDenied;
extern NSString *const kMapErrorUnknownError;

extern NSInteger const kPageLimit ;
extern NSInteger const kMaximumNoOfParallelPageLayoutCalls;
extern NSInteger const kOBJdefnLimit;
extern NSString *const kOBJdefList;

extern NSString *const kMobileSettingsGetPrice;

/** Validate Profile **/
extern NSString *const kValidateProfileSFProfileId;
extern NSString *const kValidateProfileOrgName;
extern NSString *const kValidateProfileOrgId;
extern NSString *const kValidateProfileSyncProfiling;
extern NSString *const kValidateProfileGroupProfileName;

/*IPAD-4674 */
extern NSString *const kValidateProfileSyncProfileOrgType;
extern NSString *const kValidateProfileSyncProfileEndPointUrl;
