//
//  SVMXSystemConstant.h
//  iService
//
//  Created by Vipindas on 11/18/13.
//
//

#import <Foundation/Foundation.h>

/***  NSString Constant ******/
extern NSString * const kEmptyString;


/***  Attachment Notification ******/
extern NSString * const kSM_REST_REQUEST_NOTIFICATION;

/***  Attachment Notification userInfo - Keys ******/
extern  NSString * const kNotificationStatus;
extern  NSString * const kNotificationId;
extern  NSString * const  kError;
extern  NSString * const  kProgress;


/***  Attachment Notification userInfo - Status - Values ******/
extern  NSString * const statusCompleted;
extern  NSString * const statusInProgress;
extern  NSString * const statusFailure;


/***  Attachment Error - Status - Values ******/

extern  NSString * const kSMLocalId;
extern  NSString * const kSMSfid;
extern  NSString * const kSMSize;
extern  NSString * const kSMAttachmentStatus;
extern  NSString * const kSMFileName;


/*** ServiceMax Sync Notification - constants ******/
extern  NSString * const kNotificationSyncStarted;
extern  NSString * const kNotificationSyncCompleted;

/*** ServiceMax Data Purge Notification - constants ******/
extern  NSString * const kNotificationDataPurgeStarted;
extern  NSString * const kNotificationDataPurgeCompleted;
extern  NSString * const kNotificationDataPurgeProgressBar;
extern  NSString * const kNotificationDataPurgeCompletedOrFailed;
extern  NSString * const kNotificationDataPurgeDisableCancelButton;
extern  NSString * const kNotificationDataPurgeDueAlert;


/*** ServiceMax REST API Network Error messages ******/
extern  NSString * const  kNetworkFailureMsg;
extern  NSString * const  kDataCorruptionMsg;
extern  NSString * const  kFileNotFoundMsg;
extern  NSString * const  kFileNotSavedMsg;
extern  NSString * const  kUnauthorizedAccessMsg;
extern  NSString * const  kRequestCancelledMsg;
extern  NSString * const  kRequestTimeOutMsg;
extern  NSString * const  kUnknownErrorMsg;

extern  NSString * const  kSVMXRestAPIErrorDomain;


/*** ServiceMax Attachment Action Type ******/
extern  NSString * const  kAttachmentActionTypeUpload;
extern  NSString * const  kAttachmentActionTypeDownload;


/*** ServiceMax REST API Network Error Code ******/
typedef enum errorCode
{
    SMAttachmentRequestErrorCodeNetworkFailure = 1,
    SMAttachmentRequestErrorCodeDataCorruption = 2,
    SMAttachmentRequestErrorCodeFileNotFound = 3,
    SMAttachmentRequestErrorCodeFileNotSaved = 4,
    SMAttachmentRequestErrorCodeUnauthorizedAccess = 5,
    SMAttachmentRequestErrorCodeCancelled = 6,
    SMAttachmentRequestErrorCodeRequestTimeOut = 7,
    SMAttachmentRequestErrorCodeUnknown = 8
    
}SMAttachmentRequestErrorCode;


/*** ServiceMax Attachment Action Type ******/

typedef enum AttachmentActionType
{
    SMAttachmentActionTypeUnknown = -1,
    SMAttachmentActionTypeUpload = 1,
    SMAttachmentActionTypeDownload = 2,
    
}SMAttachmentActionType;


/*** Data Purging - W S API Response Key ******/
extern  NSString * const kWSAPIResponseDataPurgeFrequency;
extern  NSString * const kWSAPIResponseDataPurgeRecordOlderThan;
extern  NSString * const kWSAPIResponseDataPurgeConfigLastModifiedDate;

/*** Data Purging - WS Request Key ******/
extern  NSString * const kWSDataPurgeEventTypeSync;
extern  NSString * const kWSDataPurgeEventNameConfigLastModifiedTime;
extern  NSString * const kWSDataPurgeEventNameDownloadCriteria;
extern  NSString * const kWSDataPurgeEventNameAdvancedDownloadCriteria;
extern  NSString * const kWSDataPurgeEventNameCleanUp;
extern  NSString * const kWSDataPurgeEventNameGetPrice;

/*** Data Purging - Internal Storage Key ******/
extern  NSString * const kDataPurgeHasConfigSyncInDue;
extern  NSString * const kDataPurgeConfigSyncStartTime;
extern  NSString * const kDataPurgeLastSuccessfulConfigSyncStartTime;
extern  NSString * const kDataPurgeFrequency;
extern  NSString * const kDataPurgeRecordOlderThan;
extern  NSString * const kDataPurgeConfigLastModifiedDate;

extern  NSString * const kDataPurgeLastSyncTime;
extern  NSString * const kDataPurgeNextSyncTime;
extern  NSString * const kDataPurgeStatus;

/***Data Purging - GetPrice WS request Key***/
extern  NSString * const kDataPurgeCustomPriceBook;
extern  NSString * const kDataPurgeCustomPriceBookEntry;
extern  NSString * const kDataPurgePriceBook;
extern  NSString * const kDataPurgePriceBookEntry;
extern  NSString * const kDataPurgeColumnName;
extern  NSString * const kDataPurgePriceBookEntryColumnName;
extern  NSString * const kDataPurgePriceBookColumnName;
extern  NSString * const kDataPurgeCustomPriceBookColumnName;


/*****Data Purge - Internal storage key for related objectname*******/
extern NSString * const kDataPurgeProduct;
extern NSString * const kDataPurgeTrobleShoot;
extern NSString * const kDataPurgeProductImage;

@interface SVMXSystemConstant : NSObject

+(NSString *)restAPIErrorMessageByErrorCode:(SMAttachmentRequestErrorCode)errorCode;

@end
