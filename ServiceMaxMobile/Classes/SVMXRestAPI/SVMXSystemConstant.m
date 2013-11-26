//
//  SVMXSystemConstant.m
//  iService
//
//  Created by Vipindas on 11/18/13.
//
//

#import "SVMXSystemConstant.h"


/***  Attachment Notification ******/

NSString * const kSM_REST_REQUEST_NOTIFICATION = @"SMRestRequestAttachmentNotififcation";

/***  Attachment Notification userInfo - Keys ******/
NSString * const kNotificationStatus = @"status";
NSString * const kNotificationId     = @"id";
NSString * const kError              = @"error";
NSString * const kProgress           = @"progress";


/***  Attachment Notification userInfo - Status - Values ******/

NSString * const statusCompleted  =   @"Complete";
NSString * const statusInProgress =   @"InProgress";
NSString * const statusFailure    =   @"Failed";


/***  Attachment Dictionary - Values ******/

NSString * const kSMLocalId          =  @"local_id";
NSString * const kSMSfid             =  @"Id";
NSString * const kSMSize             =  @"size";
NSString * const kSMAttachmentStatus =  @"status";
NSString * const kSMFileName         =  @"fileName";

/*** ServiceMax Sync Notification - constants ******/
NSString * const kNotificationSyncStarted = @"Not_Sync_Starts";
NSString * const kNotificationSyncCompleted = @"Not_Sync_Completed";

/*** ServiceMax REST API Network Error messages ******/
NSString * const  kNetworkFailureMsg = @"Network Failure";
NSString * const  kDataCorruptionMsg = @"Data Corruption";
NSString * const  kFileNotFoundMsg = @"File Not Found";
NSString * const  kFileNotSavedMsg = @"File Not Saved";
NSString * const  kUnauthorizedAccessMsg = @"Unauthorized Access";
NSString * const  kRequestCancelledMsg = @"Request Cancelled";
NSString * const  kRequestTimeOutMsg = @"Time Out";
NSString * const  kUnknownErrorMsg  = @"UnknowError";


/*** ServiceMax REST API Network Error Domain ******/
NSString * const  kSVMXRestAPIErrorDomain = @"com.servicemax.mobile.restapi.ErrorDomain";


/*** ServiceMax Attachment Action Type ******/
NSString * const  kAttachmentActionTypeUpload = @"UPLOAD";
NSString * const  kAttachmentActionTypeDownload = @"DOWNLOAD";


@implementation SVMXSystemConstant

+(NSString *)restAPIErrorMessageByErrorCode:(SMAttachmentRequestErrorCode)errorCode
{
    NSString *errorMessage = nil;
   
    switch (errorCode) {
            
        case SMAttachmentRequestErrorCodeNetworkFailure:
        {
            errorMessage = kNetworkFailureMsg;
        }
        break;
            
        case SMAttachmentRequestErrorCodeDataCorruption:
        {
            errorMessage = kDataCorruptionMsg;
        }
        break;
        
        case SMAttachmentRequestErrorCodeFileNotFound:
        {
            errorMessage = kFileNotFoundMsg;
        }
        break;
        
        case SMAttachmentRequestErrorCodeFileNotSaved:
        {
            errorMessage = kFileNotSavedMsg;
        }
        break;
            
        case SMAttachmentRequestErrorCodeUnauthorizedAccess:
        {
            errorMessage = kUnauthorizedAccessMsg;
        }
        break;
            
        case SMAttachmentRequestErrorCodeCancelled:
        {
            errorMessage = kRequestCancelledMsg;
        }
        break;
            
        case SMAttachmentRequestErrorCodeRequestTimeOut:
        {
            errorMessage = kRequestTimeOutMsg;
        }
        break;
            
        case SMAttachmentRequestErrorCodeUnknown:
        {
            errorMessage = kUnknownErrorMsg;
        }
        break;
            
        default:
        {
            errorMessage = kUnknownErrorMsg;
        }
        break;
    }
    
    return errorMessage;
}

@end
