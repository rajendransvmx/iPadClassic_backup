//
//  RequestConstants.h
//  ServiceMaxMobile
//
//  Created by Anoop on 8/13/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestConstants.h"

NSString *const groupProfile       = @"GROUP_PROFILE";

NSString *const validateProfile    = @"VALIDATE_PROFILE";
NSString *const  recordType        =  @"RECORD_TYPE";


NSString *const kContentType        = @"application/json";
NSString *const kHttpMethodPost     = @"POST";
NSString *const kHttpMethodGet      = @"GET";

NSString *const initialSync                  = @"INITIAL_SYNC";
NSString *const syncText                     = @"SYNC";
NSString *const kMetaSync                    = @"META_SYNC";
NSString *const sfmSearch                    = @"SFM_SEARCH";
NSString *const getPriceObjects              = @"PRICE_CALC_OBJECTS";
NSString *const getPriceCodeSnippet          = @"PRICE_CALC_CODE_SNIPPET";
NSString *const getPriceData                 = @"PRICE_CALC_DATA";
NSString *const sfmMetaData                  = @"SFM_METADATA";
NSString *const sfwMetaData                  = @"SFW_METADATA";
NSString *const sfmObjectDefinition          = @"SFM_OBJECT_DEFINITIONS";
NSString *const mobileDeviceTags             = @"MOBILE_DEVICE_TAGS";
NSString *const mobileDeviceSettings         = @"MOBILE_DEVICE_SETTINGS";
NSString *const sfmPicklistDefinition        = @"SFM_PICKLIST_DEFINITIONS";
NSString *const sfmPageData                  = @"SFM_PAGEDATA";
NSString *const sfmBatchObjectDefinition     = @"SFM_BATCH_OBJECT_DEFINITIONS";

//data sync

NSString *const eventSync                   = @"EVENT_SYNC";

NSString *const downloadCriteriaSyncV3      = @"SYNC_DOWNLOAD_CRITERIA";
NSString *const downloadCriteriaSync        = @"DOWNLOAD_CREITERIA_SYNC";
NSString *const downloadCriteriaObjects     = @"DOWNLOAD_CRITERIA_OBJECTS";
NSString *const downLoadCriteriaChange      = @"DOWNLOAD_CRITERIA_CHANGE";
NSString *const advancedDownloadCriteria    = @"ADV_DOWNLOAD_CRITERIA";

NSString *const kCleanUp    = @"CLEAN_UP";

NSString *const kPutInsert     = @"PUT_INSERT";
NSString *const kGetInsert     = @"GET_INSERT";
NSString *const kPutUpdate     = @"PUT_UPDATE";
NSString *const kGetUpdate     = @"GET_UPDATE";
NSString *const kPutDelete     = @"PUT_DELETE";
NSString *const kGetDelete     = @"GET_DELETE";

// dowload citeria
NSString *const kGetInsertDownloadCriteria  =  @"GET_INSERT_DOWNLOAD_CRITERIA";
NSString *const kGetupdateDownloadCriteria  = @"GET_UPDATE_DOWNLOAD_CRITERIA";
NSString *const kGetDeleteDownloadCriteria  = @"GET_DELETE_DOWNLOAD_CRITERIA";

NSString *const kGetDeleteDCOptimized  = @"GET_DELETE_DC_OPTIMZED";
NSString *const kGetUpdateDCOptimized  = @"GET_UPDATE_DC_OPTIMZED";
NSString *const kLastInternalResponse  = @"lstInternal_Response";

NSString *const kOAuthSessionTokenKey = @"Authorization";

//dynamic value properties
NSString *const kSVMXRequestValue   =  @"value";
NSString *const kSVMXRequestKey     =  @"key";
NSString *const kSVMXRequestSVMXMap =  @"valueMap";
NSString *const kSVMXRequestValues  =  @"values";
NSString *const kSVMXCallBack       =  @"CALL_BACK";
NSString *const kName               =  @"Name";

NSString *const kSVMXRequestMap     =  @"SVMXMap";
NSString *const KSVMXRequestData    =  @"data";
NSString *const KSVMXRequestParameters    =  @"Parameters";
NSString *const KFieldName          =    @"FIELD NAME";
NSString *const kSVMXRequestValueUpper   =  @"VALUE";


//Time logs
NSString *const kSVMXContextKey     =  @"SVMX_LOG_CONTEXT";
NSString *const kTimeLogKey         =  @"SVMX_TIME_LOG";
NSString *const kInItialSyncContext =  @"INITIAL SYNC";
NSString *const kGetPriceContext    =  @"GET PRICE SYNC";
NSString *const kConfigSyncContext  =  @"CONFIG SYNC";
NSString *const kDataSyncContext    =  @"INCREMENTAL DATA SYNC";
NSString *const kSfmSearchContext   =  @"SFM SEARCH";
NSString *const kDownloadOnDemand   =  @"DATA ON DEMAND";
NSString *const kGetPriceLastSyncTime = @"LAST_SYNC_PRICE_CALC";

NSString *const kJobLogCarrierContext   =  @"JOB LOG CARRIER";

NSString *const  kRestUrl =  @"/services/apexrest/"ORG_NAME_SPACE@"/svmx/MobServiceIntf/";
NSString *const  kRestUrlForWebservice =  @"/services/apexrest/";
NSString *const  kSoapUrlForWebservice =  @"/services/Soap/class/";

NSString *const  kRestUrlDPPicklist  =  @"/services/data/v25.0/sobjects/";

NSString *const  kDPRestURlDescribe  =  @"/describe/";



NSString *const kMetaSyncUrlLink = @"MetaSyncRequest";
NSString *const kDataSyncUrlLink = @"DataSyncRequest";
NSString *const kCustomWebServiceUrlLink = @"Web Service";

NSString *const kSync = @"SYNC";
NSString *const kInitialSync = @"INITIAL_SYNC";
NSString *const kSearchResult = @"SEARCH_RESULTS";
NSString *const kOnDemandGetData = @"GET_DATA";
NSString *const kOnDemandGetPriceInfo = @"GET_PRICE_INFO";
NSString *const kPurging = @"PURGING";

NSString *const kClientInfo = @"clientInfo";
NSString *const kEventName = @"eventName";
NSString *const kEventType = @"eventType";
NSString *const kGroupId = @"groupId";
NSString *const kProfileId = @"profileId";
NSString *const kUserId = @"userId";

NSString *const kTechLocationUpdate = @"TECH_LOCATION_UPDATE";
NSString *const kLocationHistory    = @"LOCATION_HISTORY";
NSString *const kOneCallSync        = @"ONE_CALL_SYNC";
NSString *const kTXFetchOptimised   = @"TX_FETCH_OPTIMZED";
NSString *const kDataOnDemand       = @"DATA_ON_DEMAND";
NSString *const kPushNotification = @"PUSH_NOTIFICATION";
NSString *const kUserTrunk          = @"USER_TRUNK";
NSString *const kDependantPickList  = @"DEPENDENT_PICKLIST";
NSString *const kObjectDefinition   = @"OBJECT_DEFINITION";
NSString *const kCodeSnippet        = @"CODE_SNIPPET";
NSString *const kCleanUpSelect      = @"CLEAN_UP_SELECT";
NSString *const kTXFetch            = @"TX_FETCH";
NSString *const kServiceLibrary     = @"SVMX_LIBRARY";
NSString *const kSubmitDocument     = @"SUBMIT_DOCUMENT";
NSString *const kGeneratePDF        = @"GENERATE_PDF";
NSString *const kPurgeRecords       = @"PURGE_RECORDS";

NSString *const kLastSync           = @"LAST_SYNC";

NSString *const kSVMXTXObject   = @"TX_OBJECT";
NSString *const kSafeToDelete   = @"SAFE_TO_DELETE";


NSString *const kAttachementObject          = @"Attachment";
NSString *const kDocumentObject             = @"Document";
NSString *const kQueryDownload              = @"query";

NSString *const kFileDownloadUrlFromObject             = @"/services/data/v26.0/sobjects/";
NSString *const kFileDownloadUrlFromQuery              = @"/services/data/v26.0/query";
NSString *const kFileDownloadUrlBody                   = @"Body";
NSString *const kChatterFeedInsertUrl                  = @"/services/data/v26.0/sobjects/FeedItem";
NSString *const kChatterFeedCommentInsertUrl           = @"/services/data/v26.0/sobjects/FeedComment";


NSString * const  kLastIndex                        = @"LAST_INDEX";

NSString * const  kLastSyncTime                     = @"LAST_SYNC_TIME";

NSString * const  kOldLastSyncTime                  = @"SYNC_TIME_STAMP";
NSString * const  kClientRequId                     = @"value";

NSString * const  kLsInternalRequest                = @"lstInternal_Request";


NSString * const  kFields                           =  @"Fields";

NSString * const  kParentObject                          = @"Parent_Object";
NSString * const  kChildObject                           = @"Child_Object";
NSString * const  kObjectName                            = @"Object_Name";

//JobLogs
NSString * const kSyncTimeLog                             = @"SYNC_TIME_LOG";

//DataPurge
NSString * const kDataPurge                      = @"SYNC_CONFIG_LMD";

//online search

NSString *const kSFMSearchProcessId = @"SearchProcessId";
NSString *const kSFMSearchKeyword   = @"KeyWord";
NSString *const kSFMSearchOperator = @"SEARCH_OPERATOR";
NSString *const kSFMSearchObjectId = @"ObjectId";
NSString *const kSFMSearchRecordLimit = @"RecordLimit";


NSString *const kAfterSaveInsertCustomCallValueMap = @"After_Insert_Web_Service";
NSString *const kOnlineLookUpURL = @"getLookUpResults";

/** Product IQ **/

NSString *const kRestUrlProductIQ = @"/services/apexrest/"ORG_NAME_SPACE"/svmx/rest/ProductIQServiceIntf/";
NSString *const kProductIQUserConfigUrl = @"getUserConfiguration/9.0/";
NSString *const kProductIQTranslationsUrl = @"getTranslations/9.0/";
NSString *const kProductIQObjectDescribeUrl = @"/services/data/v34.0/sobjects/%@/describe";
NSString *const kProductIQSyncData = @"SYNC_PRODUCTIQ_DATA";
NSString *const kProdIQLastSyncTime = @"PRODUCTIQ_LAST_SYNC";
NSString *const kProdIQGetDeleteData = @"GET_DELETE_PRODUCTIQ_DATA";

/** Sync Profiling **/

NSString *const kSyncProfileFromKey = @"From";
NSString *const kSyncProfileAppName = @"ServiceMaxNow";
NSString *const kSyncProfileClientIdKey = @"clientId";
NSString *const kSyncProfileClientNameKey = @"clientName";
NSString *const kSyncProfileRequestIdKey = @"srid";
NSString *const kSyncprofileReqId = @"syncprofileTaskId";
NSString *const kSyncProfileStartTimeKey = @"syncstartime";
NSString *const kSyncProfileSFProfileIdKey = @"classicprofileid";
NSString *const kSyncProfileIdKey = @"id";
NSString *const kSyncProfileNameKey = @"name";
NSString *const kSyncProfileUserIdKey = @"classicuserid";
NSString *const kSyncProfileGroupProfileKey = @"svmxprofile";
NSString *const kSyncProfileDeviceNameKey = @"devicename";
NSString *const kSyncProfileEndTimeKey = @"syncendtime";
NSString *const kSyncProfileRequestTimeOutKey = @"requesttimeout";
// IPAD-4585
NSString *const kSyncprofilePreviousReqId = @"syncprofileTaskPreviousId";
NSString *const kSyncProfileFailType = @"syncProfileFailType";
NSString *const kSyncProfileStatusKey = @"status";
NSString *const kSyncProfileDataSizeKey = @"Data Transferred Amount";
NSString *const kSyncProfileSuccess = @"Success";
NSString *const kSyncProfileAppQuit = @"App Quit";
NSString *const kSyncProfileSyncFailure = @"Sync Failure";

/* User Info */

NSString *const kSFDC = @"SFDC";
NSString *const kAddressField = @"Address";
NSString *const kOrgAddressKey = @"kOrgAddress";
NSString *const kGetUserInfoURLLink = @"getUserInfo";
NSString *const kUserInfoEventName = @"UserInfo";
