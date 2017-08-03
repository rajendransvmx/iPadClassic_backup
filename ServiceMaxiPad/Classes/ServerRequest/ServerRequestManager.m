//
//  ServerRequestManager.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/31/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   ServerRequestManager.m
 *  @class  ServerRequestManager
 *
 *  @brief  This class will mainitain all reequest with them,
 *
 *
 *
 *  @author  Vipindas Palli and Shravya Shridhar
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "ServerRequestManager.h"
#import "RequestFactory.h"
#import "RequestConstants.h"
#import "ProductIQManager.h"
#import "SuccessiveSyncManager.h"

@interface ServerRequestManager()

@end


@implementation ServerRequestManager


#pragma mark Singleton Methods

+ (instancetype) sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initInstance];
    });
    return sharedInstance;
}

- (instancetype) initInstance {
    self = [super init];
    // Do any other initialisation stuff here
    // ...
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

#pragma mark - Functions to give next request type
- (BOOL) isTimeLogEnabledForCategoryType :(CategoryType)categoryType {
    
    bool isapplicable;
    switch (categoryType){
            
        case CategoryTypeInitialSync:
        case CategoryTypeOneCallRestInitialSync:
        case CategoryTypeDataSync:
        case CategoryTypeOneCallDataSync:
        case CategoryTypeIncrementalOneCallMetaSync:
        case CategoryTypeEventSync:                 // Supporting, but not implemented WIN 15 release
        case CategoryTypeConfigSync:
        case CategoryTypeOneCallConfigSync:
        case CategoryTypeSFMSearch:
        case CategoryTypeLookupSearch:
        case CategoryTypeResetApp:
        case CategoryTypeGetPriceData:
        case CategoryTypeJobLog:                    // By default Yes :)
            isapplicable = YES;
            break;
            
        case CategoryTypeLocationPing:
        case CategoryTypeDataPurgeFrequency:
        case CategoryTypeTroubleShooting:
        case CategoryTypeValidateProfile:
        case CategoryTypeTroubleShootingDataDownload:
        case CategoryTypeTechnicianAddress:
        case CategoryTypeTechnicianDetails:
        case CategoryTypeCustomWS:
        case CategoryTypeDOD:
        case CategoryTypeAPNSDOD:
        case CategoryTypeAccountHistory:
        case CategoryTypeProductHistory:
        case CategoryTypeChatter:
        case CategoryTypeChatterPosts:
        case CategoryTypeChatterUserImage:
        case CategoryTypeChatterFeedInsert:
        case CategoryTypeChatterFeedUpdate:
        case CategoryTypeCustomWebServiceCall:
        case CategoryTypeCustomWebServiceAfterBeforeCall:
        case CategoryTypeSyncProfiling:
            isapplicable = NO;
            break;

        default:
            isapplicable = NO;
            break;
    }
    return isapplicable;
  
}
- (NSString *)getTheContextvalueForCategoryType:(CategoryType)categoryType
{
    NSString *contextValue ;
    switch (categoryType)
    {
        case CategoryTypeOneCallRestInitialSync:
        case CategoryTypeResetApp:
        case CategoryTypeInitialSync:
            contextValue = kInItialSyncContext;
            break;
            
        case CategoryTypeIncrementalOneCallMetaSync:
        case CategoryTypeConfigSync:
        case CategoryTypeOneCallConfigSync:
            contextValue = kConfigSyncContext;
            break;
            
        case CategoryTypeDataSync:
        case CategoryTypeOneCallDataSync:
            contextValue = kDataSyncContext;
            break;
        case CategoryTypeDOD:
            contextValue = kDownloadOnDemand;
        case CategoryTypeAPNSDOD:
            contextValue = kDownloadOnDemand;
            break;
        case CategoryTypeSFMSearch:
            contextValue = kSfmSearchContext;
            break;
        case CategoryTypeGetPriceData:
            contextValue = kGetPriceContext;
            break;
            
        default:
            contextValue = @"--";
            break;
            //Context value is not mandatory,but we are sending because of push logs             break;
    }
    return contextValue;
}


- (RequestType )getNextRequestTypeForCategoryType:(CategoryType)categoryType
                              withPreviousRequest:(SVMXServerRequest *)previousRequest {
    
    @synchronized([self class]) {
        /* Find the next request based on category type. Returns nil if next request is not there */
        RequestType nextRequestType = [self getNextRequestForCategoryType:categoryType currenrRequest:previousRequest previousRequest:nil];
        return nextRequestType;
    }
}

- (NSInteger)getConcurrencyCountForRequestType:(RequestType)requestType andCategoryType:(CategoryType)categoryType {
    
    switch (requestType) {
        case RequestSFMPageData:
            return kMaximumNoOfParallelPageLayoutCalls;//New page layout call.
            // Vipindas changed Bugbash - Nov 04 2014
            break;
        case RequestProductIQObjectDescribe:
            return [[[ProductIQManager sharedInstance]getProdIQRelatedObjects] count];
            
        default:
            break;
    }
    return 1;
}

- (SVMXServerRequest*)requestForType:(RequestType)requestType
                        withCategory:(CategoryType)categoryType
                  andPreviousRequest:(SVMXServerRequest *)previousRequest {
    
       @synchronized([self class]) {
           
           SVMXServerRequest *nextServerRequest =  [RequestFactory requestForRequestType:requestType];
           
           /* Setting the next request type */
           RequestType nextNextRequestType =  [self getNextRequestForCategoryType:categoryType currenrRequest:nextServerRequest previousRequest:previousRequest];
           nextServerRequest.nextRequestType = nextNextRequestType;
           nextServerRequest.categoryType = categoryType;
           return nextServerRequest;
       }
}

//- (SVMXServerRequest *)requestForCategoryType:(CategoryType)categoryType
//                            withPreviousRequest:(SVMXServerRequest *)previousRequest
//                           andCallback:(BOOL)callBack {
//    
//    
//    @synchronized([self class]) {
//        SVMXServerRequest *nextServerRequest = nil;
//    
//        if (callBack)  {
//            /*call back is true and need to re do the same request */
//            /* Send same request type to request factory */
//            SVMXServerRequest *nextServerRequest = [RequestFactory requestForRequestType:previousRequest.requestType];
//            nextServerRequest.nextRequestType = previousRequest.nextRequestType;
//        }
//        else {
//            
//            /* Find the next request based on category type. Returns nil if next request is not there */
//            RequestType nextRequestType = [self getNextRequestForCategoryType:categoryType andPreviousRequest:previousRequest];
//            nextServerRequest = [RequestFactory requestForRequestType:nextRequestType];
//            
//            /* Setting the next request type */
//            RequestType nextNextRequestType =  [self getNextRequestForCategoryType:categoryType andPreviousRequest:nextServerRequest];
//            nextServerRequest.nextRequestType = nextNextRequestType;
//        }
//        
//        return nextServerRequest;
//    }
//}

- (RequestType )getNextRequestForCategoryType:(CategoryType)categoryType
                              currenrRequest:(SVMXServerRequest*)currentRequest
                  previousRequest:(SVMXServerRequest *)previousRequest {
    
    RequestType requestType  = 0;
    
    switch (categoryType) {
            
        case CategoryTypeAttachmentUpload:
            requestType = [self getNextRequestForAttachmentUpload:currentRequest
                                                     andPreviousRequest:previousRequest];
 
            break;
            
        case CategoryTypeOneCallRestInitialSync:
            requestType = [self getNextRequestForOneCallMetaInitialSync:currentRequest
                                                     andPreviousRequest:previousRequest];
            break;
            
        case CategoryTypeValidateProfile:
            requestType = [self getNextRequestForValidateProfile:currentRequest
                                              andPreviousRequest:previousRequest];
            break;
            
        case CategoryTypeResetApp:
              //requestType = [self getNextRequestForResetInitialSync:currentRequest
        //                                         andPreviousRequest:previousRequest];
            break;
            
        case CategoryTypeOneCallDataSync:
            requestType = [self getNextRequestForOneCallDataSync:currentRequest
                                              andPreviousRequest:previousRequest];
            break;
            
            case CategoryTypeIncrementalOneCallMetaSync:
            requestType = [self getNextRequestForIncrementalOneCallConfigSync:currentRequest andPreviousRequest:previousRequest];
            break;
        case CategoryTypeTroubleShooting:
            requestType = [self getNextRequestForTroubleShooting:currentRequest
                                              andPreviousRequest:previousRequest];
            break;
            
        case CategoryTypeDOD:
            requestType = [self getNextRequestForDOD:currentRequest
                                              andPreviousRequest:previousRequest];
            break;
        case CategoryTypeAPNSDOD:
            requestType = [self getNextRequestForAPNS:currentRequest
                                  andPreviousRequest:previousRequest];
            break;
            
        case CategoryTypeTroubleShootingDataDownload:
            requestType = [self getNextRequestForTroubleShootingDataDownload:currentRequest
                                                          andPreviousRequest:previousRequest];
            break;
            
        case CategoryTypeTechnicianDetails:
            requestType = [self getNextRequestForTechnicianDetails:currentRequest andPreviousRequest:previousRequest];
            break;
        case CategoryTypeTechnicianAddress:
            requestType = [self getNextRequestForTechnicianAddress:currentRequest andPreviousRequest:previousRequest];
            break;
        case CategoryTypeGetPriceData:
            requestType = [self getNextRequestForGetPriceData:currentRequest
                                           andPreviousRequest:previousRequest];

            break;
        case CategoryTypeJobLog:
            requestType = [self getNextRequestForJobLog:currentRequest
                                     andPreviousRequest:previousRequest];
            break;
            
        case CategoryTypeLocationPing:
            requestType = [self getNextRequestForUserGPSLog:currentRequest
                                         andPreviousRequest:previousRequest];
            break;
            
        case CategoryTypeOpDocUploadStatus:
            requestType = [self getNextRequestForOPDocUploadStatus:currentRequest andPreviousRequest:previousRequest];

            break;
        case CategoryTypeOpDoc:
            requestType = [self getNextRequestForOPDoc:currentRequest andPreviousRequest:previousRequest];
            break;
        case CategoryTypeSubmitDocument:
            requestType = [self getNextRequestForSubmittingOPdocDocDetails:currentRequest andPreviousRequest:previousRequest];
            break;
            
        case CategoryTypeDataPurgeFrequency:
            requestType = [self getNextRequestForDataPurgeFrequency:currentRequest andPreviousRequest:previousRequest];
            break;
            
        case CategoryTypeDataPurge:
            requestType =[ self getNextRequestForDataPurge:currentRequest andPreviousRequest:previousRequest];
            break;
       
        case CategoryTypeGeneratePDF:
            requestType = [self getNextRequestForGeneratingPDF:currentRequest andPreviousRequest:previousRequest];
            break;
        case CategoryTypeProductManual:
            requestType = [self getNextRequestForProductManual:currentRequest andPreviousRequest:previousRequest];
            break;
        case CategoryTypeProductManualDownlaod:
            
            requestType = [self getNextRequestForProductManualDownload:currentRequest andPreviousRequest:previousRequest];
            break;
        case CategoryTypeSFMSearch:
            requestType = [self getNextRequestForSFMSearchResult:currentRequest andPreviousRequest:previousRequest];
            break;
        case CategoryTypeLookupSearch:
            requestType = [self getNextRequestForOnlineLookUp:currentRequest andPreviousRequest:previousRequest];
            break;

        case CategoryTypeAccountHistory:
            requestType = [self getNextRequestForAccountHistoryResult:currentRequest andPreviousRequest:previousRequest];
            break;
        case CategoryTypeProductHistory:
            requestType = [self getNextRequestForProductHistoryResult:currentRequest andPreviousRequest:previousRequest];
            break;
        case CategoryTypeChatter:
            requestType = [self getNextRequestForChatter:currentRequest andPreviousRequst:previousRequest];
            break;
        case CategoryTypeChatterPosts:
            requestType = [self getNextRequestForChatterPosts:currentRequest andPreviousRequst:previousRequest];
            break;
        case CategoryTypeChatterUserImage:
            requestType = [self getNextRequestForChatterUserImage:currentRequest andPreviousRequst:previousRequest];
            break;
        case CategoryTypeChatterFeedInsert:
            requestType = [self getNextRequestForChatterFeed:currentRequest andPreviousRequst:previousRequest];
            break;
        case CategoryTypeChatterFeedUpdate:
            requestType = [self getNextRequestForChatterFeedComment:currentRequest andPreviousRequst:previousRequest];
            break;
            
        case CategoryTypeCustomWebServiceCall:
            requestType = [self getNextRequestForCustomWebService:currentRequest andPreviousRequst:previousRequest];
            break;
            
        case CategoryTypeCustomWebServiceAfterBeforeCall:
            requestType = [self getNextRequestForCustomWebServiceAfterBefore:currentRequest andPreviousRequst:previousRequest];
            break;
        case CategoryTypeProductIQData:
            requestType = [self getNextRequestForProductIQData:currentRequest andPreviousRequest:previousRequest];
            break;
        case CategoryTypeSyncProfiling:
            requestType = [self getNextRequestForSyncProfiling:currentRequest andPreviousRequest:previousRequest];
            break;
        default:
            break;
    }
    return requestType;
}


- (RequestType)getNextRequestForSFMSearchResult:(SVMXServerRequest *)currentRequest
                             andPreviousRequest:(SVMXServerRequest *)previousRequest {
    
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestSFMSearch;
    }
    if (currentRequest.requestType == RequestSFMSearch) {
        nextRequestType = RequestTypeNone;
    }
    return nextRequestType;
}

- (RequestType)getNextRequestForOnlineLookUp:(SVMXServerRequest *)currentRequest
                             andPreviousRequest:(SVMXServerRequest *)previousRequest {
    
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestTypeOnlineLookUp;
    }
    if (currentRequest.requestType == RequestTypeOnlineLookUp) {
        nextRequestType = RequestTypeNone;
    }
    return nextRequestType;
}


- (RequestType)getNextRequestForOneCallMetaInitialSync:(SVMXServerRequest *)currentRequest
                                    andPreviousRequest:(SVMXServerRequest *)previousRequest {
    
    RequestType nextRequestType = 0;
    
    
    if (currentRequest == nil)
    {
        nextRequestType = RequestValidateProfile;
        return nextRequestType;
    }
    
    switch (currentRequest.requestType) {
            
        case RequestValidateProfile:
            nextRequestType = RequestTypeUserInfo; // IPAD-4599
            break;
        case RequestTypeUserInfo:
            nextRequestType = RequestMasterSyncTimeLog;
            break;
            
        case RequestMasterSyncTimeLog:
            nextRequestType = RequestMobileDeviceTags;
            break;

        case RequestMobileDeviceTags:
            nextRequestType = RequestOneCallMetaSync;
            break;
        case RequestOneCallMetaSync:
            nextRequestType = RequestSFMPageData ;
            break;
        case RequestSFMPageData:
            nextRequestType = RequestObjectDefinition;
            break;
        case RequestObjectDefinition:
            nextRequestType = ([[ProductIQManager sharedInstance] isProductIQSettingEnable])?RequestProductIQObjectDescribe:RequestGetPriceObjects;
            break;
        case RequestGetPriceObjects:
            nextRequestType = RequestGetPriceCodeSnippet;
            break;
        case RequestGetPriceCodeSnippet:
            nextRequestType =  RequestRecordType;
            break;
        case RequestRecordType:
            nextRequestType =  RequestDependantPickListRest;
            break;
        case RequestDependantPickListRest:
            nextRequestType =  RequestRTDependentPicklist;//RequestDocumentDownload;
            break;
        case RequestRTDependentPicklist:
            nextRequestType =  RequestStaticResourceLibrary;
            break;
        case RequestStaticResourceLibrary:
            nextRequestType =  RequestStaticResourceDownload;
            break;
        case RequestStaticResourceDownload:
            nextRequestType =  ([[ProductIQManager sharedInstance] isProductIQSettingEnable])?RequestProductIQUserConfiguration:RequestAttachmentDownload;
            break;
        case RequestAttachmentDownload:
            nextRequestType =  RequestDocumentInfoFetch;
            break;
        case RequestDocumentInfoFetch:
            nextRequestType =  RequestDocumentDownload;
            break;
        case RequestDocumentDownload:
            nextRequestType =  RequestEvents;
            break;
        case RequestEvents:
            nextRequestType =  RequestTypeUserTrunk;
            // TODO : krishna change to RequestDownloadCriteria
            // Download criteria will only work after upgarading to latest server updates.
            break;
            
        case RequestTypeUserTrunk:
            nextRequestType = RequestDownloadCriteria;
            break;
        case RequestDownloadCriteria:
            nextRequestType = RequestAdvancedDownLoadCriteria;
            break;
        case RequestAdvancedDownLoadCriteria:
            nextRequestType = RequestGetPriceDataTypeZero ;
            break;
        case RequestGetPriceDataTypeZero:
            nextRequestType = RequestGetPriceDataTypeOne;
            break;
        case RequestGetPriceDataTypeOne:
            nextRequestType = RequestGetPriceDataTypeTwo;
            break;
        case RequestGetPriceDataTypeTwo:
            nextRequestType = RequestGetPriceDataTypeThree;
            break;
        case RequestGetPriceDataTypeThree:
            nextRequestType = ([[ProductIQManager sharedInstance] isProductIQSettingEnable])?RequestProductIQData:RequestTXFetch;
            break;
        case RequestTXFetch: {
            BOOL permissionFailed = [[NSUserDefaults standardUserDefaults] boolForKey:@"kProdIQDataPermissionFailed"];
            nextRequestType = ([[ProductIQManager sharedInstance] isProductIQSettingEnable] && !permissionFailed)?RequestProductIQTxFetch:RequestSyncTimeLogs;
        }
            break;
        case RequestCleanUp:
            nextRequestType = RequestSyncTimeLogs;
            break;
        case RequestProductIQUserConfiguration:  /** Product IQ **/
            nextRequestType = RequestProductIQTranslations;
            break;
        case RequestProductIQTranslations:
            nextRequestType = RequestAttachmentDownload;
            break;
        case RequestProductIQObjectDescribe:
            nextRequestType = RequestGetPriceObjects;
            break;
        case RequestProductIQTxFetch:
            nextRequestType = RequestSyncTimeLogs;
            break;
        case RequestSyncTimeLogs:
            nextRequestType = RequestTypeNone;
            break;
        case RequestProductIQData:
            nextRequestType = RequestTXFetch;
            break;
        default:
            break;
    }
    return nextRequestType;
}

/* This function is different for Reset App as we are not Validating Group Profile in Reset App
- (RequestType)getNextRequestForResetInitialSync:(SVMXServerRequest *)currentRequest
                                    andPreviousRequest:(SVMXServerRequest *)previousRequest {
    
    RequestType nextRequestType = 0;
    
     if (currentRequest == nil) {
     nextRequestType = RequestMobileDeviceTags;
     }
    
    switch (currentRequest.requestType) {
            
        case RequestValidateProfile:
            nextRequestType = RequestMobileDeviceTags;
            break;
        case RequestMobileDeviceTags:
            nextRequestType = RequestOneCallMetaSync;
            break;
        case RequestOneCallMetaSync:
            nextRequestType = RequestSFMPageData ;
            break;
        case RequestSFMPageData:
            nextRequestType = RequestObjectDefinition;
            break;
        case RequestObjectDefinition:
            nextRequestType = RequestGetPriceObjects;
            break;
        case RequestGetPriceObjects:
            nextRequestType = RequestGetPriceCodeSnippet;
            break;
        case RequestGetPriceCodeSnippet:
            nextRequestType =  RequestRecordType;
            break;
        case RequestRecordType:
            nextRequestType =  RequestDependantPickListRest;
            break;
        case RequestDependantPickListRest:
            nextRequestType =  RequestRTDependentPicklist;
            break;
        case RequestRTDependentPicklist:
            nextRequestType =  RequestStaticResourceLibrary;
            break;
        case RequestStaticResourceLibrary:
            nextRequestType =  RequestStaticResourceDownload;
            break;
        case RequestStaticResourceDownload:
            nextRequestType =  RequestAttachmentDownload;
            break;
        case RequestAttachmentDownload:
            nextRequestType =  RequestDocumentInfoFetch;
            break;
        case RequestDocumentInfoFetch:
            nextRequestType =  RequestDocumentDownload;
            break;
        case RequestDocumentDownload:
            nextRequestType =  RequestEvents;
            break;
        case RequestEvents:
            nextRequestType =  RequestAdvancedDownLoadCriteria;
            // TODO : krishna change to RequestDownloadCriteria
            // Download criteria will only work after upgarading to latest server updates.
            break;
        case RequestDownloadCriteria:
            nextRequestType = RequestAdvancedDownLoadCriteria;
            break;
        case RequestAdvancedDownLoadCriteria:
            nextRequestType = RequestGetPriceDataTypeZero ;
            break;
        case RequestGetPriceDataTypeZero:
            nextRequestType = RequestGetPriceDataTypeOne;
            break;
        case RequestGetPriceDataTypeOne:
            nextRequestType = RequestGetPriceDataTypeTwo;
            break;
        case RequestGetPriceDataTypeTwo:
            nextRequestType = RequestGetPriceDataTypeThree;
            break;
        case RequestGetPriceDataTypeThree:
            nextRequestType = RequestTXFetch;
            break;
        case RequestTXFetch:
            nextRequestType = RequestTypeNone;
            break;
        default:
            break;
    }
    return nextRequestType;
}
 */

- (RequestType)getNextRequestForIncrementalOneCallConfigSync:(SVMXServerRequest *)currentRequest
                                          andPreviousRequest:(SVMXServerRequest *)previousRequest {
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestValidateProfile;
    }
    
    switch (currentRequest.requestType) {
        case RequestValidateProfile:
            nextRequestType = RequestTypeUserInfo; // IPAD-4599
            break;
        case RequestTypeUserInfo:
            nextRequestType = RequestMasterSyncTimeLog;
            break;
        case RequestMasterSyncTimeLog:
            nextRequestType = RequestMobileDeviceTags;
            break;
        case RequestMobileDeviceTags:
            nextRequestType = RequestOneCallMetaSync;
            break;

        case RequestOneCallMetaSync:
            nextRequestType = RequestSFMPageData ;
            break;
        case RequestSFMPageData:
            nextRequestType = RequestObjectDefinition;
            break;
        case RequestObjectDefinition:
            nextRequestType = ([[ProductIQManager sharedInstance] isProductIQSettingEnable])?RequestProductIQObjectDescribe:RequestGetPriceObjects;
            break;
        case RequestGetPriceObjects:
            nextRequestType = RequestGetPriceCodeSnippet;
            break;
        case RequestGetPriceCodeSnippet:
            nextRequestType =  RequestRecordType; /* removing RequestRecordType  defect NUmber 023976*/
            break;
            
        case RequestRecordType:
            nextRequestType =  RequestDependantPickListRest;
            break;
        case RequestDependantPickListRest:
            nextRequestType =  RequestRTDependentPicklist;//RequestDocumentDownload;
            break;
        case RequestRTDependentPicklist:
            nextRequestType =  RequestStaticResourceLibrary;
            break;
        case RequestStaticResourceLibrary:
            nextRequestType =  RequestStaticResourceDownload;
            break;
        case RequestStaticResourceDownload:
            nextRequestType =  ([[ProductIQManager sharedInstance] isProductIQSettingEnable])?RequestProductIQUserConfiguration:RequestAttachmentDownload;
            break;
        case RequestAttachmentDownload:
            nextRequestType =  RequestDocumentInfoFetch;
            break;
        case RequestDocumentInfoFetch:
            nextRequestType =  RequestDocumentDownload;
            break;
        case RequestDocumentDownload:
        nextRequestType = RequestSyncTimeLogs;
            break;
        case RequestProductIQUserConfiguration: /** Product IQ **/
            nextRequestType = RequestProductIQTranslations;
            break;
        case RequestProductIQTranslations:
            nextRequestType = RequestAttachmentDownload;
            break;
        case RequestProductIQObjectDescribe:
            nextRequestType = RequestGetPriceObjects;
            break;
        case RequestSyncTimeLogs:
            nextRequestType = RequestTypeNone;
            break;
        default:
            break;
    }
    return nextRequestType;
}


#pragma mark End


- (RequestType)getNextRequestForOneCallDataSync:(SVMXServerRequest *)currentRequest
                                    andPreviousRequest:(SVMXServerRequest *)previousRequest {
    
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestMasterSyncTimeLog;
    }
    
    switch (currentRequest.requestType) {
        case RequestMasterSyncTimeLog:
            nextRequestType = RequestOneCallDataSync;
            break;
        case RequestOneCallDataSync:
            nextRequestType = RequestTypeUserTrunk;
        case RequestTypeUserTrunk:
            nextRequestType = RequestAdvancedDownLoadCriteria;//RequestGetPriceDataTypeZero;
            break;
        // Anoop: Sync enhancement changes for onecalldatasync
        // JIRA : IPAD-1591
        // PCRD-220
        /*
        case RequestGetPriceDataTypeZero:
            nextRequestType = RequestGetPriceDataTypeOne;
            break;
        case RequestGetPriceDataTypeOne:
            nextRequestType = RequestGetPriceDataTypeTwo;
            break;
        case RequestGetPriceDataTypeTwo:
            nextRequestType = RequestGetPriceDataTypeThree;
            break;
        case RequestGetPriceDataTypeThree:
            nextRequestType = RequestAdvancedDownLoadCriteria;
            break;
        */
        case RequestAdvancedDownLoadCriteria:
            nextRequestType = RequestCleanUpSelect;
            break;
         case RequestCleanUpSelect:
            nextRequestType = RequestTXFetch;
            break;
        case RequestTXFetch:
            nextRequestType = RequestTypePurgeRecords;
            break;
        case RequestTypePurgeRecords:
            nextRequestType = RequestCleanUp;
            break;
        case RequestCleanUp:
            nextRequestType = RequestSyncTimeLogs;
            break;
        case RequestSyncTimeLogs:
            nextRequestType = RequestTypeNone;
            break;
        default:
            break;
    }
    return nextRequestType;
}
- (RequestType)getNextRequestForTroubleShooting:(SVMXServerRequest *)currentRequest
                             andPreviousRequest:(SVMXServerRequest *)previousRequest {
    
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestTroubleshooting;
    }
    if (currentRequest.requestType == RequestTroubleshooting) {
        nextRequestType = RequestTypeNone;
    }
    return nextRequestType;
}

- (RequestType)getNextRequestForTroubleShootingDataDownload:(SVMXServerRequest *)currentRequest
                                         andPreviousRequest:(SVMXServerRequest *)previousRequest {
    
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestTroubleShootDocInfoFetch;
    }
    if (currentRequest.requestType == RequestTroubleShootDocInfoFetch) {
        nextRequestType = RequestTypeNone;
    }
    return nextRequestType;
}

- (RequestType)getNextRequestForTechnicianDetails:(SVMXServerRequest *)currentRequest
                             andPreviousRequest:(SVMXServerRequest *)previousRequest {
    
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestTechnicianDetails;
    }
    if (currentRequest.requestType == RequestTechnicianDetails) {
        nextRequestType = RequestTypeNone;
    }
    return nextRequestType;
}

- (RequestType)getNextRequestForTechnicianAddress:(SVMXServerRequest *)currentRequest
                                         andPreviousRequest:(SVMXServerRequest *)previousRequest {
    
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestTechnicianAddress;
    }
    if (currentRequest.requestType == RequestTechnicianAddress) {
        nextRequestType = RequestTypeNone;
    }
    return nextRequestType;
}

- (RequestType)getNextRequestForGetPriceData:(SVMXServerRequest *)currentRequest
                          andPreviousRequest:(SVMXServerRequest *)previousRequest
{
    RequestType nextRequestType = 0;
    if (currentRequest == nil) {
        nextRequestType = RequestGetPriceDataTypeZero;
    }
    
    switch (currentRequest.requestType) {
        case RequestGetPriceDataTypeZero:
            nextRequestType = RequestGetPriceDataTypeOne;
            break;
        case RequestGetPriceDataTypeOne:
            nextRequestType = RequestGetPriceDataTypeTwo;
            break;
        case RequestGetPriceDataTypeTwo:
            nextRequestType = RequestGetPriceDataTypeThree;
            break;
        case RequestGetPriceDataTypeThree:
            nextRequestType = RequestCleanUpSelect;
            break;
        case RequestCleanUpSelect:
            nextRequestType = RequestTXFetch;
            break;
        case RequestTXFetch:
            nextRequestType = RequestSyncTimeLogs;
            break;
        case RequestCleanUp:
            nextRequestType = RequestSyncTimeLogs;
            break;
        case RequestSyncTimeLogs:
            nextRequestType = RequestTypeNone;
        default:
            break;
    }
    return nextRequestType;
}

- (RequestType)getNextRequestForOPDocUploadStatus:(SVMXServerRequest *)currentRequest
                   andPreviousRequest:(SVMXServerRequest *)previousRequest {
    
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestTypeCheckOPDOCUploadStatus;
    }
    else{
        
        nextRequestType = RequestTypeNone;
    }
    return nextRequestType;
}

- (RequestType)getNextRequestForOPDoc:(SVMXServerRequest *)currentRequest
                             andPreviousRequest:(SVMXServerRequest *)previousRequest {
    
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestTypeOpDocUploading;
    }
    else{
        
        nextRequestType = RequestTypeNone;
    }
    return nextRequestType;
}

- (RequestType)getNextRequestForSubmittingOPdocDocDetails:(SVMXServerRequest *)currentRequest
                   andPreviousRequest:(SVMXServerRequest *)previousRequest {
    
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestTypeOPDocHTMLAndSignatureSubmit;
    }
    else{
        
        nextRequestType = RequestTypeNone;
    }
    return nextRequestType;
}

- (RequestType)getNextRequestForGeneratingPDF:(SVMXServerRequest *)currentRequest
                                       andPreviousRequest:(SVMXServerRequest *)previousRequest {
    
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestTypeOPDocGeneratePDF;
    }
    else{
        
        nextRequestType = RequestTypeNone;
    }
    return nextRequestType;
}

- (BOOL)isOptionalRequest:(RequestType)type
{
    BOOL shouldSkip = NO;
    
    if (   (type == RequestStaticResourceDownload)
        || (type == RequestAttachmentDownload )
        || (type == RequestDocumentDownload)
        || (type == RequestDocumentInfoFetch)
        || (type == RequestDependantPickListRest)
        || (type == RequestRTDependentPicklist)
        || (type == RequestTypeOPDocGeneratePDF)
        || (type == RequestTypeOPDocHTMLAndSignatureSubmit)
        || (type == RequestTypeOpDocUploading)
        || (type == RequestSyncTimeLogs)
        || (type == RequestCleanUp)
        || (type == RequestTypeChatterProductImageDownload)
        || (type == RequestTypeChatterrProductData)
        || (type == RequestTypeChatterUserImage)
        || (type == RequestStaticResourceLibrary)
        || (type == RequestTypeUserTrunk)
        || (type == RequestProductIQObjectDescribe))
        
        //PA Static resource to avoid crash in SVMX_LIbrary TODO : Remove it
    {
        shouldSkip = YES;
    }
    return shouldSkip;
}


- (RequestType)getNextRequestForJobLog:(SVMXServerRequest *)currentRequest
                             andPreviousRequest:(SVMXServerRequest *)previousRequest {
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestLogs;
    }
    
    if (currentRequest.requestType == RequestLogs) {
        nextRequestType = RequestTypeNone;
    }
    return nextRequestType;
}

- (RequestType)getNextRequestForValidateProfile:(SVMXServerRequest *)currentRequest
                                    andPreviousRequest:(SVMXServerRequest *)previousRequest {
    
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestValidateProfile;
    }
    
    if (currentRequest.requestType == RequestValidateProfile) {
        nextRequestType = RequestTypeNone;
    }
    return nextRequestType;
}

- (RequestType)getNextRequestForUserGPSLog:(SVMXServerRequest *)currentRequest
                             andPreviousRequest:(SVMXServerRequest *)previousRequest {
    
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestTechnicianLocationUpdate;
    }
    
    switch (currentRequest.requestType) {
        case RequestTechnicianLocationUpdate:
            nextRequestType = RequestLocationHistory;
            break;
        case RequestLocationHistory:
            nextRequestType = RequestTypeNone;
        default:
            break;
    }
    
    return nextRequestType;
}


-(RequestType) getNextRequestForAttachmentUpload:(SVMXServerRequest *)currentRequest
                              andPreviousRequest:(SVMXServerRequest *)previousRequest {
    
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestAttachmentUpload;
    }
    else
    {
        nextRequestType = RequestTypeNone;

    }
    
    return nextRequestType;

}



- (RequestType)getNextRequestForDataPurgeFrequency:(SVMXServerRequest *)currentRequest
                                andPreviousRequest:(SVMXServerRequest *)previousRequest {
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestDataPurgeFrequency;
    }
    
    if (currentRequest.requestType == RequestDataPurgeFrequency) {
        nextRequestType = RequestTypeNone;
    }
    return nextRequestType;
    
}

- (RequestType)getNextRequestForDataPurge:(SVMXServerRequest *)currentRequest
                       andPreviousRequest:(SVMXServerRequest *)previousRequest {
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestDatPurgeDownloadCriteria;
    }
    
    switch (currentRequest.requestType) {
        case RequestDatPurgeDownloadCriteria:
            nextRequestType = RequestDataPurgeAdvancedDownLoadCriteria;
            break;
        case RequestDataPurgeAdvancedDownLoadCriteria:
            nextRequestType = RequestDataPurgeGetPriceDataTypeZero;
            break;
        case RequestDataPurgeGetPriceDataTypeZero:
            nextRequestType = RequestDataPurgeGetPriceDataTypeOne;
            break;
        case RequestDataPurgeGetPriceDataTypeOne:
            nextRequestType = RequestDataPurgeGetPriceDataTypeTwo;
            break;
        case RequestDataPurgeGetPriceDataTypeTwo:
            nextRequestType = RequestDataPurgeGetPriceDataTypeThree;
            break;
        case RequestDataPurgeGetPriceDataTypeThree:
            nextRequestType = ([[ProductIQManager sharedInstance] isProductIQSettingEnable])?RequestDataPurgeProductIQData:RequestTypeNone;
            break;
        case RequestDataPurgeProductIQData:
            nextRequestType = RequestTypeNone;
            break;
        default:
            break;
    }
    
    return nextRequestType;
}
- (RequestType)getNextRequestForProductManual:(SVMXServerRequest *)currentRequest
                                andPreviousRequest:(SVMXServerRequest *)previousRequest {
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestProductManual;
    }
    
    if (currentRequest.requestType == RequestProductManual) {
        nextRequestType = RequestTypeNone;
    }
    return nextRequestType;
    
}

- (RequestType)getNextRequestForProductManualDownload:(SVMXServerRequest *)currentRequest
                                   andPreviousRequest:(SVMXServerRequest *)previousRequest {
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestProductManualDownload;
    }
    
    if (currentRequest.requestType == RequestProductManualDownload) {
        nextRequestType = RequestTypeNone;
    }
    return nextRequestType;
    
}

//DOD
- (RequestType)getNextRequestForDOD:(SVMXServerRequest *)currentRequest
                   andPreviousRequest:(SVMXServerRequest *)previousRequest {
    
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestDataOnDemandGetData;
    }
    else{
        
        nextRequestType = RequestTypeNone;
    }
    return nextRequestType;
}

//APNS - Push Notification
- (RequestType)getNextRequestForAPNS:(SVMXServerRequest *)currentRequest
                 andPreviousRequest:(SVMXServerRequest *)previousRequest {
    
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestDataPushNotification;
    }
    else{
        
        nextRequestType = RequestTypeNone;
    }
    return nextRequestType;
}


- (RequestType)getNextRequestForAccountHistoryResult:(SVMXServerRequest *)currentRequest
                             andPreviousRequest:(SVMXServerRequest *)previousRequest {
    
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestTypeAccountHistory;
    }
    if (currentRequest.requestType == RequestTypeAccountHistory) {
        nextRequestType = RequestTypeNone;
    }
    return nextRequestType;
}


- (RequestType)getNextRequestForProductHistoryResult:(SVMXServerRequest *)currentRequest
                                  andPreviousRequest:(SVMXServerRequest *)previousRequest {
    
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestTypeProductHistory;
    }
    if (currentRequest.requestType == RequestTypeProductHistory) {
        nextRequestType = RequestTypeNone;
    }
    return nextRequestType;
}

/*Chatter*/
- (RequestType)getNextRequestForChatter:(SVMXServerRequest *)currentRequest
                     andPreviousRequst:(SVMXServerRequest *)previousRequst
{
    RequestType nextReuestType = 0;
    
    if (currentRequest == nil) {
        nextReuestType = RequestTypeChatterrProductData;

    }
    switch (currentRequest.requestType) {
        case RequestTypeChatterrProductData:
            nextReuestType = RequestTypeChatterProductImageDownload;
            break;
        case RequestTypeChatterProductImageDownload:
            nextReuestType = RequestTypeChatterPost;
            break;
        case RequestTypeChatterPost:
            nextReuestType = RequestTypeChatterPostDetails;
            break;
        case RequestTypeChatterPostDetails:
            nextReuestType = RequestTypeNone;
            break;
        default:
            break;
    }
    return nextReuestType;
}

- (RequestType)getNextRequestForChatterPosts:(SVMXServerRequest *)currentRequest
                      andPreviousRequst:(SVMXServerRequest *)previousRequst
{
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestTypeChatterPost;
        
    }
    switch (currentRequest.requestType) {
        case RequestTypeChatterPost:
            nextRequestType = RequestTypeChatterPostDetails;
            break;
        case RequestTypeChatterPostDetails:
            nextRequestType = RequestTypeNone;
            break;
        default:
            break;
    }
    return nextRequestType;
}


- (RequestType)getNextRequestForChatterUserImage:(SVMXServerRequest *)currentRequest
                      andPreviousRequst:(SVMXServerRequest *)previousRequst
{
    RequestType nextReuestType = 0;
    
    if (currentRequest == nil) {
        nextReuestType = RequestTypeChatterUserImage;
        
    }
    switch (currentRequest.requestType) {
        case RequestTypeChatterUserImage:
            nextReuestType = RequestTypeNone;
            break;
        default:
            break;
    }
    return nextReuestType;
}

- (RequestType)getNextRequestForChatterFeed:(SVMXServerRequest *)currentRequest
                               andPreviousRequst:(SVMXServerRequest *)previousRequst
{
    RequestType nextReuestType = 0;
    
    if (currentRequest == nil) {
        nextReuestType = RequestTypeChatterFeedInsert;
        
    }
    switch (currentRequest.requestType) {
        case RequestTypeChatterFeedInsert:
            nextReuestType = RequestTypeNone;
            break;
        default:
            break;
    }
    return nextReuestType;
}

- (RequestType)getNextRequestForChatterFeedComment:(SVMXServerRequest *)currentRequest
                          andPreviousRequst:(SVMXServerRequest *)previousRequst
{
    RequestType nextReuestType = 0;
    
    if (currentRequest == nil) {
        nextReuestType = RequestTypeChatterFeedCommnetInsert;
        
    }
    switch (currentRequest.requestType) {
        case RequestTypeChatterFeedCommnetInsert:
            nextReuestType = RequestTypeNone;
            break;
        default:
            break;
    }
    return nextReuestType;
}
- (RequestType)getNextRequestForCustomWebService:(SVMXServerRequest *)currentRequest
                                 andPreviousRequst:(SVMXServerRequest *)previousRequst
{
    RequestType nextReuestType = 0;
    
    if (currentRequest == nil) {
        nextReuestType = RequestTypeCustomActionWebService;
        
    }
    
    if(currentRequest.requestType == RequestTypeCustomActionWebService)
    {
        nextReuestType = RequestTypeNone;
    }
    return nextReuestType;
}

- (RequestType)getNextRequestForCustomWebServiceAfterBefore:(SVMXServerRequest *)currentRequest
                               andPreviousRequst:(SVMXServerRequest *)previousRequst
{
    RequestType nextReuestType = 0;
    
    if (currentRequest == nil) {
        nextReuestType = RequestTypeCustomActionWebServiceAfterBefore;
        
    }
    
    if(currentRequest.requestType == RequestTypeCustomActionWebServiceAfterBefore)
    {
        nextReuestType = RequestTypeNone;
    }
    return nextReuestType;
}


#pragma mark - Product IQ

- (RequestType)getNextRequestForProductIQData:(SVMXServerRequest *)currentRequest andPreviousRequest:(SVMXServerRequest *)previousRequest {
    
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestProductIQDeleteData;
    }
    
    switch (currentRequest.requestType) {
        case RequestProductIQDeleteData:
            nextRequestType = RequestProductIQData;
            break;
        case RequestProductIQData:
            nextRequestType = RequestCleanUpSelect;
            break;
        case RequestCleanUpSelect:
            nextRequestType = RequestTXFetch;
            break;
        case RequestTXFetch:
            nextRequestType = RequestTypeNone;
            break;
        case RequestCleanUp:
            nextRequestType = RequestTypeNone;
        default:
            break;
    }
    return nextRequestType;
}


#pragma mark - Sync Profiling

- (RequestType)getNextRequestForSyncProfiling:(SVMXServerRequest *)currentRequest andPreviousRequest:(SVMXServerRequest *)previousRequest {
    
    RequestType nextRequestType = 0;
    
    if (currentRequest == nil) {
        nextRequestType = RequestTypeSyncProfiling;
    }
    
    switch (currentRequest.requestType) {
        case RequestTypeSyncProfiling:
            nextRequestType = RequestTypeNone;
            break;
        default:
            break;
    }
    return nextRequestType;
}

@end
