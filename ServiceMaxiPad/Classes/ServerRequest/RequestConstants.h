//
//  RequestConstants.h
//  ServiceMaxMobile
//
//  Created by Anoop on 8/13/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RequestType)
{
    //TODO : Need to do changes.
    RequestValidateProfile = 1,
    RequestServicemaxVersion,
    RequestGroupProfile,
    RequestSFMMetaDataSync,  //metadata
    RequestSFMMetaDataInitialSync,
    RequestSFMPageData,
    RequestSFMObjectDefinition,
    RequestSFMBatchObjectDefinition,
    RequestSFMPicklistDefinition,
    RequestRecordTypePicklist,
    RequestRecordType,
    RequestSFWMetaData,
    RequestMobileDeviceTags,
    RequestMobileDeviceSettings,
    RequestSFMSearch,
    RequestGetPriceObjects,
    RequestGetPriceCodeSnippet,
    RequestDependentPicklist,
    RequestCodeSnippet,
    RequestEvents, //Data
    RequestDownloadCriteria,
    RequestTXFetch,
    RequestAdvancedDownLoadCriteria,
    RequestGetDelete,                     //Initial Data Sync
    RequestgetDeleteDownloadCriteria,
    RequestCleanUpSelect,
    RequestCleanUp,	
    RequestPutDelete,
    RequestPutInsert,
    requestGetInsert,
    RequestGetInsertDownloadCriteria,
    RequestGetPriceDataTypeZero,
    RequestGetPriceDataTypeOne,
    RequestGetPriceDataTypeTwo,
    RequestGetPriceDataTypeThree,
    RequestSignatureBeforeUpdate,        //ZKs Call
    RequestProductManual,
    RequestPutUpdate,
    RequestSignatureAfterUpdate,
    RequestGetUpdate,
    RequestGetUpdateDownloadCriteria,
    RequestTechnicianLocationUpdate,
    RequestLocationHistory,
    RequestSignatureAfterSync,
    RequestDataPurge,
    RequestContactImage,
    RequestLogs,
    RequestCustomWebServiceCall,
    RequestTXFetchOptimized,
    RequestStaticResourceLibrary,
    RequestSubmitDocument,
    RequestGeneratePDF,
    RequestMasterSyncTimeLog,
    
    RequestDataOnDemandGetPriceInfo,
    RequestDataOnDemandGetData,
    RequestDataPushNotification,
    RequestTypeUserTrunk,
    RequestChatter,
    RequestDownloadPdf,
    RequestGetAttachment,
    RequestAttachmentUpload,
    RequestServiceReportLogo,
    RequestOneCallDataSync,
    RequestDependantPickListRest,
    RequestOneCallMetaSync,
    RequestObjectDefinition,
    RequestRTDependentPicklist,
    RequestStaticResourceDownload,
    RequestAttachmentDownload,
    RequestTypeSFMAttachmentsDownload,
    RequestDocumentDownload,
    RequestDocumentInfoFetch,
    RequestTroubleShootDocInfoFetch,
    RequestSyncTimeLogs,

    RequestTypeCheckOPDOCUploadStatus,
    RequestTypeOpDocUploading,
    RequestTypeOPDocHTMLAndSignatureSubmit,
    RequestTypeOPDocGeneratePDF,
    RequestTechnicianDetails,
    RequestTechnicianAddress,
    RequestTypeRefresTokenFailed,
    RequestTypeNone,
    
    /* DataPurge RequestConstants */
    
   
    RequestDataPurgeFrequency,
    RequestDatPurgeDownloadCriteria,
    RequestDataPurgeAdvancedDownLoadCriteria,
    RequestDataPurgeGetPriceDataTypeZero,
    RequestDataPurgeGetPriceDataTypeOne,
    RequestDataPurgeGetPriceDataTypeTwo,
    RequestDataPurgeGetPriceDataTypeThree,
    /* ********************************* */
    
   
    RequestProductManualDownload,
    RequestTroubleshooting,
    RequestTypeAccountHistory,
    RequestTypeProductHistory,
    
    /****Chatter********/
    RequestTypeChatterrProductData,
    RequestTypeChatterProductImageDownload,
    RequestTypeChatterPost,
    RequestTypeChatterPostDetails,
    RequestTypeChatterUserImage,
    RequestTypeChatterFeedInsert,
    RequestTypeChatterFeedCommnetInsert,
    
    /******* custom action type ********/
    RequestTypeCustomActionWebService,
    RequestTypeCustomActionWebServiceAfterBefore,
};

extern NSString *const kContentType;
extern NSString *const kHttpMethodPost;
extern NSString *const kHttpMethodGet;

extern NSString *const groupProfile;

extern NSString *const validateProfile;

extern NSString *const kMetaSync;
extern NSString *const initialSync;
extern NSString *const syncText;
extern NSString *const sfmSearch;
extern NSString *const getPriceObjects;
extern NSString *const getPriceCodeSnippet;
extern NSString *const getPriceData;
extern NSString *const sfmMetaData;
extern NSString *const sfwMetaData;
extern NSString *const sfmObjectDefinition;
extern NSString *const mobileDeviceTags;
extern NSString *const mobileDeviceSettings;
extern NSString *const sfmPicklistDefinition;
extern NSString *const sfmPageData;
extern NSString *const sfmBatchObjectDefinition;
extern NSString *const kGetPriceLastSyncTime;

//data sync

extern NSString *const eventSync;
extern NSString *const downloadCriteriaSync;
extern NSString *const downloadCriteriaObjects;
extern NSString *const downLoadCriteriaChange;
extern NSString *const advancedDownloadCriteria;

extern NSString *const kCleanUp;

extern NSString *const kPutInsert;
extern NSString *const kGetInsert;
extern NSString *const kPutUpdate;
extern NSString *const kGetUpdate;
extern NSString *const kPutDelete;
extern NSString *const kGetDelete;

// dowload citeria
extern NSString *const kGetInsertDownloadCriteria ;
extern NSString *const kGetupdateDownloadCriteria ;
extern NSString *const kGetDeleteDownloadCriteria ;
extern NSString *const downloadCriteriaSyncV3;

extern NSString *const kOAuthSessionTokenKey ;

//dynamic value properties
extern NSString *const kSVMXRequestValue;
extern NSString *const kSVMXRequestKey;
extern NSString *const kSVMXRequestSVMXMap;
extern NSString *const kSVMXRequestValues;
extern NSString *const kSVMXCallBack;
extern NSString *const kName;
extern NSString *const kSVMXContextKey;
extern NSString *const kTimeLogKey;
extern NSString *const kGetPriceContext;
extern NSString *const kInItialSyncContext;
extern NSString *const kConfigSyncContext;
extern NSString *const kDataSyncContext;
extern NSString *const kSfmSearchContext;
extern NSString *const kJobLogCarrierContext;
extern NSString *const kDownloadOnDemand;

//For custom Action
extern NSString *const kSVMXRequestMap;

extern NSString *const  kRestUrl;
extern NSString *const  kRestUrlForWebservice;
extern NSString *const  KSVMXRequestData;
extern NSString *const  KSVMXRequestParameters;
extern NSString *const  KFieldName;
extern NSString *const  kSVMXRequestValueUpper;


extern NSString *const  kRestUrlDPPicklist ;

extern NSString *const  kDPRestURlDescribe ;



extern NSString *const kMetaSyncUrlLink;
extern NSString *const kDataSyncUrlLink;
extern NSString *const kCustomWebServiceUrlLink;

extern NSString *const kSync;
extern NSString *const kInitialSync;
extern NSString *const kSearchResult;
extern NSString *const kOnDemandGetData ;
extern NSString *const kOnDemandGetPriceInfo;
extern NSString *const kClientInfo;

extern NSString *const kEventName;
extern NSString *const kEventType;
extern NSString *const kGroupId;
extern NSString *const kProfileId ;
extern NSString *const kUserId;

extern NSString *const kTechLocationUpdate;
extern NSString *const kLocationHistory;
extern NSString *const kOneCallSync;
extern NSString *const kTXFetchOptimised;
extern NSString *const kDataOnDemand;
extern NSString *const kPushNotification;
extern NSString *const kUserTrunk;
extern NSString *const kDependantPickList;
extern NSString *const kObjectDefinition;
extern NSString *const kCodeSnippet;
extern NSString *const kCleanUpSelect;
extern NSString *const kTXFetch;
extern NSString *const kServiceLibrary;
extern NSString *const kSubmitDocument;
extern NSString *const kGeneratePDF;
extern NSString *const kLastSync;

extern NSString *const kGetDeleteDCOptimized;
extern NSString *const kGetUpdateDCOptimized;
extern NSString *const kLastInternalResponse;


/* TX FETCH THREAD CONFIGURATION */
static NSInteger kMaximumnumberOfIdsPerObject                = 400;//2500; Vipindas changes
static NSInteger kOverallIdLimit                             = 500;
static NSInteger kNumberConcurrentRequests                   = 3;

extern NSString *const kSVMXTXObject;
extern NSString *const kSafeToDelete;



/* File downloading */
extern NSString *const kAttachementObject;
extern NSString *const kDocumentObject;
extern NSString *const kQueryDownload;

extern NSString *const kFileDownloadUrlFromObject;
extern NSString *const kFileDownloadUrlBody;
extern NSString *const kFileDownloadUrlFromQuery;
extern NSString *const kChatterFeedInsertUrl;
extern NSString *const kChatterFeedCommentInsertUrl;


extern NSString * const  kLastIndex ;

extern  NSString * const kLastSyncTime;

extern NSString * const  kOldLastSyncTime;

extern NSString * const  kClientRequId;

extern NSString * const  kLsInternalRequest;

extern NSString * const  kFields;

extern  NSString * const  kParentObject;

extern  NSString * const  kChildObject;

extern  NSString * const  kObjectName;

// JobLogs
extern  NSString * const kSyncTimeLog;

extern NSString * const kSmartDocsSubmitHTMLEventName;

//DataPurge

extern  NSString * const kDataPurge;

extern NSString *const kSFMSearchProcessId;
extern NSString *const kSFMSearchKeyword;
extern NSString *const kSFMSearchOperator;
extern NSString *const kSFMSearchObjectId;
extern NSString *const kSFMSearchRecordLimit;
extern NSString *const kAfterSaveInsertCustomCallValueMap;
extern NSString *const  kSoapUrlForWebservice;

extern NSString *const  kNewRelicAnalyticsKey;
