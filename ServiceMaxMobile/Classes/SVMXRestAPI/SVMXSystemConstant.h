//
//  SVMXSystemConstant.h
//  iService
//
//  Created by Vipindas on 11/18/13.
//
//

#import <Foundation/Foundation.h>

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




@interface SVMXSystemConstant : NSObject

+(NSString *)restAPIErrorMessageByErrorCode:(SMAttachmentRequestErrorCode)errorCode;

@end
