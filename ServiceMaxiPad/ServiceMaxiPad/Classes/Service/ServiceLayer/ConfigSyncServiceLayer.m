//
//  ConfigSyncServiceLayer.m
//  ServiceMaxMobile
//
//  Created by Anoop on 8/13/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "ConfigSyncServiceLayer.h"

@implementation ConfigSyncServiceLayer


- (instancetype) initWithCategoryType:(CategoryType)categoryType
                requestType:(RequestType)requestType {
    
    self = [super initWithCategoryType:categoryType requestType:requestType];
    
    if (self != nil) {
        //Intialize if required
        
    }
    
    return self;
    
}

- (ResponseCallback*)processResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                      responseData:(id)responseData {
    
    return nil;
    
}

- (RequestParamModel*)getRequestParameters {
    
    switch (self.requestType) {
            
        case RequestSFMMetaDataSync:
            
            break;
            
        case RequestSFMMetaDataInitialSync:
            
            break;
            
        case RequestSFMPageData:
            
            break;
            
        case RequestSFMObjectDefinition:
            
            break;
            
        case RequestSFMBatchObjectDefinition:
            
            break;
            
        case RequestSFMPicklistDefinition:
            
            break;
            
        case RequestRecordTypePicklist:
            
            break;
            
        case RequestRecordType:
            
            break;
            
        case RequestSFWMetaData:
            
            break;
            
        case RequestMobileDeviceTags:
            
            break;
            
        case RequestMobileDeviceSettings:
            
            break;
            
        case RequestSFMSearch:
            
            break;
            
        case RequestGetPriceObjects:
            
            break;
            
        case RequestGetPriceCodeSnippet:
            
            break;
            
        case RequestDependentPicklist:
            
            break;
            
        case RequestCodeSnippet:
            
            break;
            
        default:
            break;
    }
    return nil;
    
}


@end
