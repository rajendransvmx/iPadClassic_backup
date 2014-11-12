//
//  AttachmentServiceLayer.m
//  ServiceMaxMobile
//
//  Created by Anoop on 8/13/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "AttachmentServiceLayer.h"

@implementation AttachmentServiceLayer


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
        case RequestGetAttachment:
            
            break;
            
        default:
            break;
    }
   // NSLog(@"Invalid request type");
    return nil;
    
}


@end
