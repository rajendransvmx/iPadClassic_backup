//
//  ResponseConstants.m
//  ServiceMaxMobile
//
//  Created by shravya on 21/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "ResponseConstants.h"


/* MobileDeviceSettings OBJECT */
NSString *const kMobileSettingsUniqueId         = ORG_NAME_SPACE@"__Setting_Unique_ID__c";
NSString *const kMobileSettingsValue            = ORG_NAME_SPACE@"__Internal_Value__c";
NSString *const kMobileSettingsDisplayValue     = ORG_NAME_SPACE@"__Display_Type__c";
NSString *const kMobileSettingsAggressiveSync   = @"IPAD018_SET019";

/* TargetManager constant */
NSString *const kProcessUniqueId    = ORG_NAME_SPACE@"__ProcessID__c";
NSString *const kProcessSFID        = @"Id";
NSString *const kObjectApiName      = ORG_NAME_SPACE@"";
NSString *const kProcessType        = ORG_NAME_SPACE@"__Purpose__c";
NSString *const kProcessName        = ORG_NAME_SPACE@"__Name__c";
NSString *const kProcessDesc        = ORG_NAME_SPACE@"__Description__c";
NSString *const kPageLayoutId       = ORG_NAME_SPACE@"__Page_Layout__c";
NSString *const kDocTemplate        = ORG_NAME_SPACE@"__Doc_Template__c";

/* SFObjectMapping OBJECT */
NSString *const kObjMapId                  = @"Id";
NSString *const kObjMapSourceObjectName    = ORG_NAME_SPACE@"__Source_Object_Name__c";
NSString *const kObjMaptargetObjectName    = ORG_NAME_SPACE@"__Target_Object_Name__c";


/* SFProcessComponent OBJECT */

NSString *const kPCompSFId              = @"Id";
NSString *const kPCompProcessId         = ORG_NAME_SPACE@"__Process__c";
NSString *const kPCompPageLayout        = ORG_NAME_SPACE@"__Page_Layout__c";
NSString *const kPCompType              = ORG_NAME_SPACE@"__Type__c";
NSString *const kPCompObjectName        = ORG_NAME_SPACE@"__Source_Object_Name__c";
NSString *const kPCompTargetObjLabel    = ORG_NAME_SPACE@"__Target_Object_label__c";
NSString *const kPCompEntryCriteria     = ORG_NAME_SPACE@"__Submodule__c";
NSString *const kPCompObjectMappingId   = ORG_NAME_SPACE@"__Module__c";
NSString *const kPCompValueMappingId    = ORG_NAME_SPACE@"__Final_Exception_Process__c";
NSString *const kPCompParentNodeId      = ORG_NAME_SPACE@"__Parent_Object__c";
NSString *const kPCompParentObjectName  = ORG_NAME_SPACE@"__Node_Source_Object_API__c";
NSString *const kPCompValuesC           = ORG_NAME_SPACE@"__Values__c";
NSString *const kPCompDocTemplateId     = ORG_NAME_SPACE@"__Doc_Template_Details__c";
NSString *const kPCompEnableAttachment  = ORG_NAME_SPACE@"__Enable_Attachment__c";
NSString *const kPCompParentColumnName  = ORG_NAME_SPACE@"__Parent_Column_Name__c";

NSString *const kPCompSequence          = ORG_NAME_SPACE@"__Sequence__c";


/* Page layout */
NSString *const kSVMXCallBackIds       = @"callBackIds";
NSString *const kSVMXObjectList        = @"ObjectsList";
NSString *const kSVMXRTObjects         = @"RTObjects";


//dynamic value properties
NSString *const kSVMXValue   =  @"value";
NSString *const kSVMXKey     =  @"key";
NSString *const kSVMXSVMXMap =  @"valueMap";
NSString *const kSVMXValues  =  @"values";




NSString *const kPCompProcessNodeId     = ORG_NAME_SPACE@"__Node_Parent__c";

/* SFM_SEARCH_PROCESS OBJECT */

NSString *const ksfmSearchProcessSFID       = @"Id";
NSString *const ksfmSearchName              = @"Name";
NSString *const ksfmSearchProcessDescrip    = ORG_NAME_SPACE@"__Description__c";
NSString *const ksfmSearchProcessName       = ORG_NAME_SPACE@"__Name__c";

/* SFSearchObject    Object*/
NSString *const kSfmSearchObjId                    = @"Id";
NSString *const kSfmSearchObjProcessID             = ORG_NAME_SPACE@"__ProcessID__c";
NSString *const kSfmSearchObjTargetObjName         = ORG_NAME_SPACE@"__Target_Object_Name__c";
NSString *const kSfmSearchObjModule                = ORG_NAME_SPACE@"__Module__c";
NSString *const kSfmSearchObjAdvExpr               = ORG_NAME_SPACE@"__Advance_Expression__c";
NSString *const kSfmSearchObjParentObjCriteria     = ORG_NAME_SPACE@"__Parent_Object_Criteria__c";
NSString *const kSfmSearchObjName                  = ORG_NAME_SPACE@"__Name__c";
NSString *const kSearchCriteriaSequence            = ORG_NAME_SPACE@"__Sequence__c";

/* SFObjectMappingComponent OBJECT */

NSString *const kObjMapCompId                = ORG_NAME_SPACE@"__MapID__c";
NSString *const kObjMapCompSourceFieldName   = ORG_NAME_SPACE@"__Source_Field_Name__c";
NSString *const kObjMapCompTargetFieldName   = ORG_NAME_SPACE@"__Target_Field_Name__c";
NSString *const kObjMapCompMappingValue      = ORG_NAME_SPACE@"__Display_Value__c";
NSString *const kObjMapCompPreference2       = ORG_NAME_SPACE@"__Preference_2__c";
NSString *const kObjMapCompPreference3       = ORG_NAME_SPACE@"__Preference_3__c";
/* SFWizard  Object */

NSString *const kWizardSfId        = @"Id";
NSString *const KwizardActive      = ORG_NAME_SPACE@"__Active__c";
NSString *const KwizardDescription = ORG_NAME_SPACE@"__Description__c";
NSString *const KwizardName        = ORG_NAME_SPACE@"__Name__c";
NSString *const KwizardSourceObjName = ORG_NAME_SPACE@"__Source_Object_Name__c";
NSString *const KwizardSubmodule     = ORG_NAME_SPACE@"__Submodule__c";
NSString *const kWizardLayoutRow     = ORG_NAME_SPACE@"__Wizard_Layout_Row__c";
NSString *const kWizardlayoutColumn  = ORG_NAME_SPACE@"__Wizard_Layout_Column__c";
NSString *const kWizardDispatchProcessId   = ORG_NAME_SPACE@"__Dispatch_Process__c";

/* SFWizardComponent Object*/
NSString *const kWizardCompId          = @"Id";
NSString *const kWizardCompActionType  = ORG_NAME_SPACE@"__Action_Type__c";
NSString *const kWizardCompDescription = ORG_NAME_SPACE@"__Description__c";
NSString *const kWizardCompModule      = ORG_NAME_SPACE@"__Module__c";
NSString *const kWizardCompSubModule   = ORG_NAME_SPACE@"__Submodule__c";
NSString *const kWizardCompName        = ORG_NAME_SPACE@"__Name__c";
NSString *const kWizardCompProcess     = ORG_NAME_SPACE@"__Process__c";
NSString *const kWizardCompSequence    = ORG_NAME_SPACE@"__Sequence__c";
NSString *const kWizardCompStepName    = ORG_NAME_SPACE@"__Name__c";
NSString *const kWizardCompClassName   = ORG_NAME_SPACE@"__Service_Class_Name__c";
NSString *const kWizardCompMethodName  = ORG_NAME_SPACE@"__Service_Method_Name__c";
NSString *const kWizardCompCustomActionType = ORG_NAME_SPACE@"__Custom_Action_Type__c";
NSString *const kWizardCompCustomActionUrl =ORG_NAME_SPACE@"__Target_URL__c";

/* custom Action Url */
NSString *const kCustomActionProcessId       = @"Id";
NSString *const kCustomActionDispatchProcess = ORG_NAME_SPACE@"__Dispatch_Process__c";
NSString *const kCustomActionParameterName   = ORG_NAME_SPACE@"__Parameter_Name__c";
NSString *const kCustomActionParameterType   = ORG_NAME_SPACE@"__Parameter_Type__c";
NSString *const kCustomActionParameterValue  = ORG_NAME_SPACE@"__Parameter_Value__c";
NSString *const kCustomActionName            = @"Name";


/* SFExpression */
/* SFExpression Object*/
NSString *const kExpressionId               = @"Id";
NSString *const kExpressionProcessId        = ORG_NAME_SPACE@"__ProcessID__c";
NSString *const kExpressionSourceObjName    = ORG_NAME_SPACE@"__Source_Object_Name__c";
NSString *const kExpressionFailureReason    = ORG_NAME_SPACE@"__Values__c";
NSString *const kExpressionSequence         = ORG_NAME_SPACE@"__Sequence__c";
NSString *const kExpressionAdvExpression    = ORG_NAME_SPACE@"__Advance_Expression__c";
NSString *const kExpressionErrorMsg         = ORG_NAME_SPACE@"__Parent_Error_Msg__c";

/* ExpressionComponent Object*/
NSString *const kExpressionCompExprRule     = ORG_NAME_SPACE@"__Expression_Rule__c";
NSString *const kExpressionCompFieldName    = ORG_NAME_SPACE@"__Field_Name__c";
NSString *const kExpressionCompOperator     = ORG_NAME_SPACE@"__Operator__c";
NSString *const kExpressionCompOperand      = ORG_NAME_SPACE@"__Operand__c";
NSString *const kExpressionCompDisplayType  = ORG_NAME_SPACE@"__Display_Type__c";
NSString *const kExpressionCompSequence     = ORG_NAME_SPACE@"__Sequence__c";
NSString *const kExpressionCompParentType   = ORG_NAME_SPACE@"__Parameter_Type__c";
NSString *const kExpressionCompExprtype     = ORG_NAME_SPACE@"__Expression_Type__c";
//Formula Fields
NSString *const kExpressionCompFormula      = ORG_NAME_SPACE@"__Formula__c";
NSString *const kExpressionCompActionType   = ORG_NAME_SPACE@"__Action_Type__c";
NSString *const kExpressionCompDescription  = ORG_NAME_SPACE@"__Description__c";


/*BusinessRule OBJECT */

NSString *const kBizRulesId      = @"Id";
NSString *const kBizRulesName    = @"Name";
NSString *const kBizRulesTargetManager  = ORG_NAME_SPACE@"__Process1__c";
NSString *const kBizRulesProcessNodeObject = ORG_NAME_SPACE@"__Process2__c";
NSString *const kBizRule         = ORG_NAME_SPACE@"__Process3__c";
NSString *const kBizRulesErrorMsg  = ORG_NAME_SPACE@"__Parent_Error_Msg__c";
NSString *const kBizRulesSequence  = ORG_NAME_SPACE@"__Sequence__c";
NSString *const kBizRulesAdvExpression = ORG_NAME_SPACE@"__Advance_Expression__c";
NSString *const kBizRulesDescription   = ORG_NAME_SPACE@"__Description__c";
NSString *const kBizRulesMsgType       = ORG_NAME_SPACE@"__Message_Type__c";
NSString *const kBizRulesProcessId     = ORG_NAME_SPACE@"__ProcessID__c";
NSString *const kBizRulesSrcObjectName = ORG_NAME_SPACE@"__Source_Object_Name__c";
//For serviceMax Formula
NSString *const kBizRulesRuleType = ORG_NAME_SPACE@"__Rule_Type__c";


/*DOC Template constants*/
NSString *const kDocTemplateTableId           = @"Id";
NSString *const kDocTemplateName              = ORG_NAME_SPACE@"__Name__c";
NSString *const kDocTemplateId                = ORG_NAME_SPACE@"__Template_Id__c";
NSString *const kDocTemplateIsStandard        = ORG_NAME_SPACE @"__IsStandard__c";
NSString *const kDocTemplateDetailObjectCount = ORG_NAME_SPACE@"__Detail_Object_Count__c";
NSString *const kDocTemplateMediaResources    = ORG_NAME_SPACE@"__Media_Resources__c";

/*DOC Template details constants*/
NSString *const kDocTempDetailDocTemplate     = ORG_NAME_SPACE@"__Doc_Template__c";
NSString *const kDocTempDetailId              = ORG_NAME_SPACE@"__Doc_Template_Detail_Id__c";
NSString *const kDocTempDetailheaderRefField  = ORG_NAME_SPACE@"__Header_Reference_Field__c";
NSString *const kDocTempDetailalias           = ORG_NAME_SPACE@"__Alias__c";
NSString *const kDocTempDetailobjectName      = ORG_NAME_SPACE@"__Object_Name__c";
NSString *const kDocTempDetailsoql            = ORG_NAME_SPACE@"__SOQL__c";
NSString *const kDocTempDetailUniqueId        = ORG_NAME_SPACE@"__Doc_Template_Detail_Unique_Id__c";
NSString *const kDocTempDetailfields          = ORG_NAME_SPACE@"__Fields__c";
NSString *const kDocTempDetailtype            = ORG_NAME_SPACE@"__Type__c";
NSString *const kDocTempDetailidTable         = @"Id";

/*Attachments constants*/
NSString *const kAttachmentId                 = @"Id";
NSString *const kAttachmentName               = @"Name";
NSString *const kAttachmentParentId           = @"ParentId";
NSString *const kAttachmentBody               = @"body";

/*Attachment images, videos, pdf Object*/
NSString *const kAttachmentTXlocalId          = @"localId";
NSString *const kAttachmentTXBody             = @"Body";
NSString *const kAttachmentTXParentId         = @"ParentId";
NSString *const kAttachmentTXCreatedDate      = @"CreatedDate";
NSString *const kAttachmentTXContentType      = @"ContentType";
NSString *const kAttachmentTXBodyLength       = @"BodyLength";
NSString *const kAttachmentTXOwnerId          = @"OwnerId";
NSString *const kAttachmentTXCreatedById      = @"CreatedById";
NSString *const kAttachmentTXLastModifiedDate = @"LastModifiedDate";
NSString *const kAttachmentTXId               = @"Id";
NSString *const kAttachmentTXIsPrivate        = @"IsPrivate";
NSString *const kAttachmentTXDescription      = @"Description";
NSString *const kAttachmentTXIsDeleted        = @"IsDeleted";
NSString *const kAttachmentTXName             = @"Name";
NSString *const kAttachmentTXSystemModStamp   = @"SystemModStamp";
NSString *const kAttachmentTXLastModifiedById = @"LastModifiedById";

/*Attachment error objects */
NSString *const kAttachmentERlocalId          = @"localId";
NSString *const kAttachmentERParentSFId       = @"parentId";
NSString *const kAttachmentERId               = @"attachmentId";
NSString *const kAttachmentERName             = @"fileName";
NSString *const kAttachmentERErrorCode        = @"errorCode";
NSString *const kAttachmentERErrorMessage     = @"errorMessage";


/*NamedSearch constants*/
NSString *const kNamedSearchId              = @"Id";
NSString *const kNamedSearchLookupColumn    = ORG_NAME_SPACE@"__Default_Lookup_Column__c";
NSString *const kNamedSearchIsDefault       = ORG_NAME_SPACE@"__IsDefault__c";
NSString *const kNamedSearchIsStandard      = ORG_NAME_SPACE@"__IsStandard__c";
NSString *const kNamedSearchName            = ORG_NAME_SPACE@"__Name__c";
NSString *const kNamedSearchNoOfLookupRecs  = ORG_NAME_SPACE@"__Number_of_Lookup_Records__c";
NSString *const kNamedSearchProcessID       = ORG_NAME_SPACE@"__ProcessID__c";
NSString *const kNamedSearchRuleType        = ORG_NAME_SPACE@"__Rule_Type__c";
NSString *const kNamedSearchSourceObjName   = ORG_NAME_SPACE@"__Source_Object_Name__c";

/* SFSearchObjectDetail Constants */
NSString *const kSearchObjDetailId                  = @"Id";
NSString *const kSearchObjDetailExpRule             = ORG_NAME_SPACE@"__Expression_Rule__c";
NSString *const kSearchObjDetailExpType             = ORG_NAME_SPACE@"__Expression_Type__c";
NSString *const kSearchObjDetailFieldName           = ORG_NAME_SPACE@"__Field_Name__c";
NSString *const kSearchObjDetailInternalValue       = ORG_NAME_SPACE@"__Internal_Value__c";
NSString *const kSearchObjDetailFieldType           = ORG_NAME_SPACE@"__Search_Object_Field_Type__c";
NSString *const kSearchObjDetailSequence            = ORG_NAME_SPACE@"__Sequence__c";


/* SFNamedSearchComponent (SFSearchObjectDetail) Constants */
NSString *const kNSComponentExpressionType      = ORG_NAME_SPACE@"__Expression_Type__c";
NSString *const kNSComponentFieldName           = ORG_NAME_SPACE@"__Field_Name__c";
NSString *const kNSComponentNamedSearchId       = ORG_NAME_SPACE@"__Internal_Value__c";
NSString *const kNSComponentSearchFieldType     = ORG_NAME_SPACE@"__Search_Object_Field_Type__c";
NSString *const kNSComponentFieldDataType       = ORG_NAME_SPACE@"__Display_Type__c";
NSString *const kNSComponentFieldRelation       = ORG_NAME_SPACE@"__Field_Relationship_Name__c";
NSString *const kNSComponentSequence            = ORG_NAME_SPACE@"__Sequence__c";
NSString *const kNSCompoentKeyNameField         = ORG_NAME_SPACE@"__FKey_Name_Field__c";

/* SFM_SEARCH_DETAILS */
NSString *const kSearchDetailSFID            = @"Id";
NSString *const kSearchDisplayType           = ORG_NAME_SPACE@"__Display_Type__c";
NSString *const kSearchExpRule               = ORG_NAME_SPACE@"__Expression_Rule__c";
NSString *const kSearchObjFieldType          = ORG_NAME_SPACE@"__Search_Object_Field_Type__c";
NSString *const kSearchObjName               = ORG_NAME_SPACE@"__Object_Name__c";
NSString *const kSearchObjName2              = ORG_NAME_SPACE@"__Object_Name2__c";
NSString *const kSearchFieldName             = ORG_NAME_SPACE@"__Field_Name__c";
NSString *const kSearchLookupFieldApiName    = ORG_NAME_SPACE@"__Lookup_Field_API_Name__c";
NSString *const kSearchFieldRelationShipName = ORG_NAME_SPACE@"__Field_Relationship_Name__c";
NSString *const kSearchSortOrder             = ORG_NAME_SPACE@"__Sort_Order__c";
NSString *const kSearchOperator              = ORG_NAME_SPACE@"__Operator__c";
NSString *const kSearchOperand               = ORG_NAME_SPACE@"__Operand__c";
NSString *const kSearchExpressionType        = ORG_NAME_SPACE@"__Expression_Type__c";
NSString *const kSearchObjectId              = @"Object_Id";

/* SFObject, SFObjectField, SFPicklist, SFRecordType, SFChildRelatioship*/
NSString *const kAPIObjectDefnObject             = @"OBJECT";
NSString *const kAPIObjectDefnProperty           = @"OBJECTPROPERTY";
NSString *const kAPIObjDefnObjDefn               = @"OBJECTDEFINITION";
NSString *const kAPIObjDefnKeyPrefix             = @"KEYPREFIX";
NSString *const kAPIObjDefnlabel                 = @"LABEL";
NSString *const kAPIObjDefnPluLabel              = @"PLURALLABEL";
NSString *const kAPIObjDefnQueryable             = @"QUERYABLE";
NSString *const kAPIObjDefnMasterDetails         = @"MASTERDETAILS";
NSString *const kAPIObjDefnRecordType            = @"RECORDTYPE";
NSString *const kAPIObjDefnFieldProperty         = @"FIELDPROPERTY";
NSString *const kAPIObjDefnKeyField              = @"FIELD";
NSString *const kAPIObjDefnType                  = @"TYPE";
NSString *const kAPIObjDefnCreatable             = @"CREATEABLE";
NSString *const kAPIObjDefnUpdatable             = @"UPDATEABLE";
NSString *const kAPIObjDefnLength                = @"LENGTH";
NSString *const kAPIObjDefnNameField             = @"NAMEFIELD";
NSString *const kAPIObjDefnReferencedTo          = @"REFERENCETO";
NSString *const kAPIObjDefnRelationShipName      = @"RELATIONSHIPNAME";
NSString *const kAPIObjDefnDependentPickList     = @"DEPENDENTPICKLIST";
NSString *const kAPIObjDefnControllerField       = @"DEPENDENTPICKLIST";
NSString *const kAPIObjDefnPicklistInfo          = @"PICKLIST_INFO";
NSString *const kAPIObjDefnPicklistvalue         = @"PICKLISTVALUE";
NSString *const kAPIObjDefnPicklistLabel         = @"PICKLISTLABEL";
NSString *const kAPIObjDefnPicklistDefalut       = @"DEFAULTPICKLISTVALUE";
NSString *const kAPIObjDefnPrecision             = @"PRECISION";
NSString *const kAPIObjDefnScale                 = @"SCALE";


NSString *const kAPIGetPriceRequiredObjects      = @"Required_Objects";
NSString *const kFILTER_CRITERIA_OBJ         = @"SRCH_Object_Prefilter_Criteria";

//SFSourceUpdate

NSString *const kSourceUpdateId                =    @"Id";
NSString *const kSSourceUpdateProcessId        =    ORG_NAME_SPACE@"__Dispatch_Process__c";
NSString *const kSSourceUpdateSettingId        =    ORG_NAME_SPACE@"__Setting_ID__c";
NSString *const kSSourceUpdateAction           =    ORG_NAME_SPACE@"__Action__c";
NSString *const kSSourceUpdateConfigType       =    ORG_NAME_SPACE@"__Configuration_Type__c";
NSString *const kSSourceUpdateDisplayValue     =    ORG_NAME_SPACE@"__Display_Value__c";
NSString *const kSSourceUpdateSrcFieldName     =    ORG_NAME_SPACE@"__Source_Field_Name__c";
NSString *const kSSourceUpdatetargetFieldName  =    ORG_NAME_SPACE@"__Target_Field_Name__c";

/*DependentPicklist  constants*/

NSString *const kPICKLISTFIELDS        = @"fields";

NSString *const kPICKLISTVALUES        = @"picklistValues";
NSString *const kPICKLISTVALIDFOR      = @"validFor";
NSString *const kPickListName          = @"name";
NSString *const kDependentPickListType = @"type";
NSString *const kMultiPicklist         = @"multipicklist";
NSString *const kPicklist              = @"picklist";
NSString *const kDependentPicklist     = @"dependentPicklist";
NSString *const kControllerName        = @"controllerName";
NSString *const kFieldApiName          = @"FieldApi";
NSString *const kObjApiName            = @"ObjectApi";
NSString *const kIndex                 = @"Index";
NSString *const kPickListValue         = @"value";

/*Get Pricedata constants*/
NSString *const kGetPriceWarrantyObjectName    =  ORG_NAME_SPACE@"__Warranty__c";
NSString *const kGetPriceDataLastIndex         =  @"LAST_INDEX";
NSString *const kGetPriceDataLastId            =  @"LAST_ID";
NSString *const kGetPriceDataPricingData       =  @"PRICING_DATA";

/*static resource*/
NSString *const kStaticResourceKey    = @"STATIC_RESOURCE";
NSString *const kStaticResource       = @"StaticResource";
NSString *const kStaticResourceId     = @"Id";
NSString *const kStaticResourceName   = @"Name";

/* Adv Download Criteria constants */
NSString *const kADCPartiallyExecutedObjectKey  = @"PARTIAL_EXECUTED_OBJECT";
NSString *const kADCDeleteKey                   = @"DELETE";
NSString *const kADCCallBackKey                 = @"CALL_BACK";


NSString * const kConflict              = @"CONFLICT";



NSString * const  kCallBack                         = @"call_back";

NSString * const  kCallbackContext                  = @"CALL_BACK_CONTEXT";

NSString * const  kCallBackInCaps                   = @"CALL_BACK";
NSString * const  kCurrentContextKey                = @"CURRENT_CALL_BACK_KEY";
NSString * const  kPartiallyExecutedobj             = @"PARTIAL_EXECUTED_OBJECT";
NSString * const  kPartiallyExecutedobjUpdate       = @"PARTIAL_EXECUTED_OBJECT_UPDATE";
NSString * const  kPartiallyExecutedobjDelete       = @"PARTIAL_EXECUTED_OBJECT_DELETE";
NSString * const kAllEvents = @"ALL_EVENTS";
NSString * const kRecordIds = @"REC_IDS";
NSString * const  kLastOneCallSyncPutUpdateTime     = @"GET_UPDATE_LST";

/* timeLog constants */

NSString *const kTimeT4                             = @"SVMX_LOG_T4";
NSString *const kTimeT5                             = @"SVMX_LOG_T5";
NSString *const kTimeT1                             = @"SVMX_LOG_T1";
NSString *const kTimeLogId                          = @"SVMX_LOG_ID";
NSString *const kRequestTypeKey                     = @"type";
NSString *const kAttributeKey                       = @"attributes";
NSString *const kTimeLogRequestID                   = @"SVMX_Job_Log";
NSString *const kTimeLogSucess                      = @"Completed";
NSString *const kTimeLogFailure                     = @"Failed";
NSString *const kTimeLogFailureID                   = @"SVMX_Log_Failed";

NSString *const kTimeLogClientProcessingTimeStamp   = ORG_NAME_SPACE@"__Client_Response_Processing_Timestamp__c";
NSString *const kTimeLogClientReceivingTimeStamp    = ORG_NAME_SPACE@"__Client_Response_Receive_Timestamp__c";
NSString *const kTimeLogStatus                      = ORG_NAME_SPACE@"__Call_Status__c";
NSString *const ktimeLogType                        = ORG_NAME_SPACE@"__SVMX_Job_Logs__c";

/* SEARCH_OBJECT Server Contants  */
NSString *const kSearchFilterParentObjectCriteria = ORG_NAME_SPACE@"__Parent_Object_Criteria__c";
NSString *const kSearchFilterStatus               = ORG_NAME_SPACE@"__Status__c";
NSString *const kSearchFilterSequence             = ORG_NAME_SPACE@"__Sequence__c";
NSString *const kSearchFilterRuleType             = ORG_NAME_SPACE@"__Rule_Type__c";
NSString *const kSearchFilterSourceObjectName     = ORG_NAME_SPACE@"__Source_Object_Name__c";
NSString *const kSearchFilterName                 = ORG_NAME_SPACE@"__Name__c";
NSString *const kSearchFilterAllowOveride         = ORG_NAME_SPACE@"__Allow_Override__c";
NSString *const kSaerchFilterDefaultOn            = ORG_NAME_SPACE@"__Default_On__c";
NSString *const kSearchFilterFieldName            = ORG_NAME_SPACE@"__Field_Name__c";
NSString *const kSearchFilterModuleId             = ORG_NAME_SPACE@"__Module__c";
NSString *const kSearchFilterAdvanceExpression    = ORG_NAME_SPACE@"__Advance_Expression__c";
NSString *const kSearchFiltrerId                  = @"Id";

/*Linked SFM*/
NSString *const kLinkefSfmId                = @"Id";
NSString *const kLinkedSfmProcess1          = ORG_NAME_SPACE@"__Process1__c";
NSString *const kLinkedSfmProcess2          = ORG_NAME_SPACE@"__Process2__c";
NSString *const kLinkedSfmProcess3          = ORG_NAME_SPACE@"__Process3__c";

/*Chatter*/
NSString *const kRecords      = @"records";
NSString *const kResult       = @"result";
NSString *const kFeedComments = @"FeedComments";

/*Pulse constants*/
NSString *const kPulseNotificationString             = @"NotificationString";
NSString *const kPulseNotificationId                 = @"notificationId";
NSString *const kPulseNotificationSFId               = @"ID";
NSString *const kPulseNotificationObjectName         = @"OBJECT_NAME";
NSString *const kPulseNotificationActionTag          = @"ACTION_TAG";
NSString *const kPulseNotificationUserId             = @"userId";
NSString *const kPulseNotificationOrgId              = @"orgId";
NSString *const kPulseNotificationLocalId            = @"localId";
NSString *const kPulseNotificationMessage            = @"alert";
NSString *const kPulseNotificationPriority           = @"PRIORITY";
NSString *const kPulseNotificationTitle              = @"TITLE";
NSString *const kPulseNotificationAps                = @"aps";
NSString *const kPulseNotificationDownload           = @"DOWNLOAD";

/*Map error*/
NSString *const kMapErrorNotFound           = @"NOT_FOUND";
NSString *const kMapErrorZeroResults        = @"ZERO_RESULTS";
NSString *const kMapErrorWayPointsExceeded  = @"MAX_WAYPOINTS_EXCEEDED";
NSString *const kMapErrorInvalidRequest     = @"INVALID_REQUEST";
NSString *const kMapErrorOverQueryLimit     = @"OVER_QUERY_LIMIT";
NSString *const kMapErrorRequestDenied      = @"REQUEST_DENIED";
NSString *const kMapErrorUnknownError       = @"UNKNOWN_ERROR";

NSInteger const kPageLimit   = 15;
NSInteger const kMaximumNoOfParallelPageLayoutCalls = 5;

NSInteger const kOBJdefnLimit = 20;
NSString *const kOBJdefList                 = @"ObjectsDefinitionList";
NSString *const kMobileSettingsGetPrice   = @"IPAD018_SET022";

/** Validate Profile **/
NSString *const kValidateProfileSFProfileId = @"PROFILEID";
NSString *const kValidateProfileOrgName = @"ORGNAME";
NSString *const kValidateProfileOrgId = @"ORGID";
NSString *const kValidateProfileSyncProfiling = @"SYNC_PROFILING";
NSString *const kValidateProfileGroupProfileName = @"PROFILENAME";



