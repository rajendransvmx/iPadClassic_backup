//
//  SVMXSystemConstant.m
//  iService
//
//  Created by Vipindas on 11/18/13.
//
//

#import "SVMXSystemConstant.h"


/***  NSString Constant ******/
NSString * const kEmptyString  = @"";


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


/*** ServiceMax Data Purge Notification - constants ******/
NSString * const kNotificationDataPurgeStarted = @"Not_DataPurge_Starts";
NSString * const kNotificationDataPurgeCompleted = @"Not_DataPurge_Completed";
NSString * const kNotificationDataPurgeProgressBar = @"Update_DataPurge_Progress";
NSString * const kNotificationDataPurgeCompletedOrFailed = @"DP_ProgressBar_Remove";
NSString * const kNotificationDataPurgeDisableCancelButton = @"DP_ProgressBar_DisableCancelButton";
NSString * const kNotificationDataPurgeDueAlert = @"Data_Purge_InDue";


/*** ServiceMax REST API Network Error messages ******/
NSString * const  kNetworkFailureMsg = @"Network Failure";
NSString * const  kDataCorruptionMsg = @"Data Corruption";
NSString * const  kFileNotFoundMsg = @"File Not Found";
NSString * const  kFileNotSavedMsg = @"File Not Saved";
NSString * const  kUnauthorizedAccessMsg = @"Unauthorized Access";
NSString * const  kRequestCancelledMsg = @"Request Cancelled";
NSString * const  kRequestTimeOutMsg = @"Time Out";
NSString * const  kUnknownErrorMsg  = @"Unknown Error";


/*** ServiceMax REST API Network Error Domain ******/
NSString * const  kSVMXRestAPIErrorDomain = @"com.servicemax.mobile.restapi.ErrorDomain";


/*** ServiceMax Attachment Action Type ******/
NSString * const  kAttachmentActionTypeUpload = @"UPLOAD";
NSString * const  kAttachmentActionTypeDownload = @"DOWNLOAD";


/*** Data Purging - W S API Response Key ******/
NSString * const kWSAPIResponseDataPurgeFrequency              = @"PURGE_FREQ";
NSString * const kWSAPIResponseDataPurgeRecordOlderThan        = @"PURGE_REC_OLDER_THAN";
NSString * const kWSAPIResponseDataPurgeConfigLastModifiedDate = @"CONFIG_LAST_MOD";

/*** Data Purging - WS Request Key ******/
NSString * const kWSDataPurgeEventTypeSync                       = @"SYNC";
NSString * const kWSDataPurgeEventNameConfigLastModifiedTime     = @"SYNC_CONFIG_LMD";
NSString * const kWSDataPurgeEventNameDownloadCriteria           = @"DOWNLOAD_CREITERIA_SYNC";
NSString * const kWSDataPurgeEventNameAdvancedDownloadCriteria   = @"ADV_DOWNLOAD_CRITERIA";
NSString * const kWSDataPurgeEventNameCleanUp                    = @"CLEAN_UP";
NSString * const kWSDataPurgeEventNameGetPrice                   = @"PRICE_CALC_DATA";



/*** Data Purging - Internal Storage Key ******/
NSString * const kDataPurgeHasConfigSyncInDue                   = @"DP_config_due";
NSString * const kDataPurgeConfigSyncStartTime                  = @"DP_cfg_strt_time";
NSString * const kDataPurgeLastSuccessfulConfigSyncStartTime    = @"DP_sucs_strt_time";
NSString * const kDataPurgeFrequency                            = @"DP_freq";
NSString * const kDataPurgeRecordOlderThan                      = @"DP_record_older_than";
NSString * const kDataPurgeConfigLastModifiedDate               = @"DP_lst_mod_date";

NSString * const kDataPurgeLastSyncTime                         = @"DP_last_sync_time";
NSString * const kDataPurgeNextSyncTime                         = @"DP_next_sync_time";
NSString * const kDataPurgeStatus                               = @"DP_status";

/***Data Purging - GetPrice WS request Key***/
NSString * const kDataPurgeCustomPriceBook                      = ORG_NAME_SPACE@"__Service_Pricebook__c";
NSString * const kDataPurgeCustomPriceBookEntry                 = ORG_NAME_SPACE@"__Service_Pricebook_Entry__c";
NSString * const kDataPurgePriceBook                            = @"Pricebook2";
NSString * const kDataPurgePriceBookEntry                       = @"PricebookEntry";
NSString * const kDataPurgeColumnName                           = @"Id";
NSString * const kDataPurgePriceBookEntryColumnName             = @"CurrencyIsoCode";
NSString * const kDataPurgePriceBookColumnName                  = @"Pricebook2Id";
NSString * const kDataPurgeCustomPriceBookColumnName            = ORG_NAME_SPACE@"__Price_Book__c";

/*****Data Purge - Internal storage key for related objectname*******/
NSString * const kDataPurgeProduct                              = @"Product2";
NSString * const kDataPurgeTrobleShoot                          = @"trobleshootdata";
NSString * const kDataPurgeProductImage                         = @"ProductImage";


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
