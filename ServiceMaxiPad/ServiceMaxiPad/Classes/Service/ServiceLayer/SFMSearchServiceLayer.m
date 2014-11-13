//
//  SFMSearchServiceLayer.m
//  ServiceMaxMobile
//
//  Created by Himanshi on 11/3/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMSearchServiceLayer.h"

@implementation SFMSearchServiceLayer


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
        case RequestDataOnDemandGetData:
            //fill Data
            
            break;
            
        default:
            NSLog(@"Invalid request type");
            break;
    }
    
    return nil;
    
}


@end
