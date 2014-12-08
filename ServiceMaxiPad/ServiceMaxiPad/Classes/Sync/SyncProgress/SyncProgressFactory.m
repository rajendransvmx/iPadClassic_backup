//
//  SyncProgressFactory.m
//  ServiceMaxMobile
//
//  Created by Sahana on 22/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SyncProgressFactory.h"

@implementation SyncProgressFactory
+(SyncProgressStatus)getSyncProcessStatusforRequestType:(RequestType)requestType
{
    
    SyncProgressStatus progressStatus = 0;
    switch (requestType) {
        case RequestValidateProfile :
            break;
        case RequestServicemaxVersion:
            break;
        case RequestGroupProfile:
            break;
        case RequestSFMMetaDataSync:  //metadata
            break;
        case RequestSFMMetaDataInitialSync:
            progressStatus =  SyncStatusOneCallSync;
            break;
        case RequestSFMPageData:
            progressStatus = SyncStatusPageLayoutDownlaoding;
            break;
        case RequestObjectDefinition:
            progressStatus =  SyncStatusObjectDefinitionsDownloading;
            break;
        case RequestSFMBatchObjectDefinition:
            break;
        case RequestSFMPicklistDefinition:
            break;
        case RequestSFWMetaData:
            break;
        case RequestMobileDeviceTags:
            progressStatus = SyncStatusDeviceTagsDownloading;
            break;
        case RequestMobileDeviceSettings:
            break;
        case RequestSFMSearch:
            break;
        case RequestGetPriceObjects:
            break;
        case RequestGetPriceCodeSnippet:
            break;
        case RequestGetAttachment:
            break;
        case RequestProductManual:
            break;
        case RequestEvents: //Data
            progressStatus = SyncStatusDownloadingEvents;
            break;
        case RequestDownloadCriteria:
            progressStatus = SyncStatusDownloadingRecords;
            break;
        case RequestGetPriceDataTypeZero:
            break;
        case RequestGetPriceDataTypeOne:
            break;
        case RequestGetPriceDataTypeTwo:
            break;
        case RequestGetPriceDataTypeThree:
            break;
        case RequestTXFetch:
            progressStatus = SyncStatusDownloadingTXFETCH;
            break;
        case RequestDependantPickListRest:
            progressStatus = SyncStatusDependentPicklistDownloading;
            break;
        case RequestRTDependentPicklist:
              progressStatus = SyncStatusRTPicklistDownlaoding;
            break;
            
        default:
            break;
    }
    
    return progressStatus;
}



@end
