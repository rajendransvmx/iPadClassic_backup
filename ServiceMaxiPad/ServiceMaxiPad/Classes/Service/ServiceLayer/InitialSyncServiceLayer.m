//
//  InitialSyncServiceLayer.m
//  ServiceMaxMobile
//
//  Created by Anoop on 8/13/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "InitialSyncServiceLayer.h"

@implementation InitialSyncServiceLayer

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
        case RequestGetDelete:
            
            break;
            
        case RequestgetDeleteDownloadCriteria:
            
            break;
            
        case RequestCleanUpSelect:
        case RequestCleanUp:
            break;
            
        case RequestPutDelete:
            
            break;
            
        case RequestPutInsert:
            
            break;
            
        case requestGetInsert:
            
            break;
            
        case RequestGetInsertDownloadCriteria:
            
            break;
            
        default:
            break;
    }
    NSLog(@"Invalid request type");
    return nil;
    
}


@end
