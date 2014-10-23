//
//  BaseServiceLayer.m
//  ServiceMaxMobile
//
//  Created by Anoop on 8/12/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "BaseServiceLayer.h"

@implementation BaseServiceLayer

- (instancetype)initWithCategoryType:(CategoryType)categoryType
                         requestType:(RequestType)requestType {
    
    self = [super init];
    
    if(self != nil) {
        
        _categoryType = categoryType;
        _requestType = requestType;
        
    }
    
    return self;
}

//TODO: Update following three methods in child classes
- (ResponseCallback*)processResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                      responseData:(id)responseData {
    return nil;
    
}

- (NSArray*)getRequestParameters:(NSInteger)requestCount {
    
    return nil;
    
}


@end
