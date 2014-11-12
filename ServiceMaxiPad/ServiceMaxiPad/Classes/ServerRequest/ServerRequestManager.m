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
- (BOOL) isTimeLogEnabledForCategoryType :(CategoryType) categoryType {
    
    return NO;
    
    bool isapplicable;
    
    switch (categoryType) {
            
        case CategoryTypeInitialSync:
        case CategoryTypeOneCallRestInitialSync:
        case CategoryTypeDataSync:
        case CategoryTypeOneCallDataSync:
        case CategoryTypeIncrementalOneCallMetaSync:
        case CategoryTypeEventSync:
        case CategoryTypeConfigSync:
        case CategoryTypeOneCallConfigSync:
        case CategoryTypeCustomWS:
        case CategoryTypeSFMSearch:
        case CategoryTypeTroubleShooting:
        case CategoryTypeTroubleShootingDataDownload:
        case CategoryTypeTechnicianAddress:
        case CategoryTypeTechnicianDetails:
        case CategoryTypeJobLog:
        case CategoryTypeResetApp:
        case CategoryTypeValidateProfile:
            isapplicable = YES;
            break;
            
        case CategoryTypeLocationPing:
        case CategoryTypeDataPurgeFrequency:
        case CategoryTypeDOD:
            isapplicable = NO;
            break;
        
        default:
            isapplicable = NO;
            break;
    }
    return isapplicable;
  
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
            return 2; // Vipindas changed Bugbash - Nov 04 2014
            break;
            
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

        case CategoryTypeJobLog:
            requestType = [self getNextRequestForJobLog:currentRequest
                                     andPreviousRequest:previousRequest];
            break;
            
        case CategoryTypeLocationPing:
            requestType = [self getNextRequestForUserGPSLog:currentRequest
                                         andPreviousRequest:previousRequest];
            break;
            
        case CategoryTypeOpDoc:
            requestType = [self getNextRequestForOPDoc:currentRequest andPreviousRequest:previousRequest];
           
            break;
               case CategoryTypeSubmitDocument:
            requestType = [self getNextRequestForSubmittingOPdocDocDetails:currentRequest andPreviousRequest:previousRequest];
            break;
             /************************************************************************** */
            
        case CategoryTypeDataPurgeFrequency:
            requestType = [self getNextRequestForDataPurgeFrequency:currentRequest andPreviousRequest:previousRequest];
            break;
        case CategoryTypeDataPurge:
            requestType =[ self getNextRequestForDataPurge:currentRequest andPreviousRequest:previousRequest];
            break;
            

            /**********************************************************************/
       
            
        case CategoryTypeGeneratePDF:
            requestType = [self getNextRequestForGeneratingPDF:currentRequest andPreviousRequest:previousRequest];
            break;
        case CategoryTypeProductManual:
            requestType = [self getNextRequestForProductManual:currentRequest andPreviousRequest:previousRequest];
            break;
        case CategoryTypeProductManualDownlaod:
            
            requestType = [self getNextRequestForProductManualDownload:currentRequest andPreviousRequest:previousRequest];
            break;
        default:
            break;
    }
    return requestType;
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
            nextRequestType =  RequestRTDependentPicklist;//RequestDocumentDownload;
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
             nextRequestType =  RequestDownloadCriteria;
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
        nextRequestType = RequestMobileDeviceTags;
    }
    
    switch (currentRequest.requestType) {
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
            nextRequestType =  RequestRTDependentPicklist;//RequestDocumentDownload;
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
            nextRequestType =  RequestTypeNone;
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
        nextRequestType = RequestOneCallDataSync;
    }
    
    switch (currentRequest.requestType) {
        case RequestOneCallDataSync:
            nextRequestType = RequestGetPriceDataTypeZero;
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
            nextRequestType = RequestAdvancedDownLoadCriteria;
            break;
        case RequestAdvancedDownLoadCriteria:
            nextRequestType = RequestCleanUpSelect;
            break;
         case RequestCleanUpSelect:
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
        || (type == RequestTroubleShootDocInfoFetch)
        || (type == RequestProductManualDownload)
        || (type == RequestDependantPickListRest)
        || (type == RequestRTDependentPicklist)
        || (type == RequestTypeOPDocGeneratePDF)
        || (type == RequestTypeOPDocHTMLAndSignatureSubmit)
        || (type == RequestTypeOpDocUploading))
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




@end
