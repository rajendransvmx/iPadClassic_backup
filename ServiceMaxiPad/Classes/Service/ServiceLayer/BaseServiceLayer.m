//
//  BaseServiceLayer.m
//  ServiceMaxMobile
//
//  Created by Anoop on 8/12/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "BaseServiceLayer.h"
#import "TimeLogCacheManager.h"
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

- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)requestCount
{
    if(self.requestType == RequestSyncTimeLogs)
    {
        RequestParamModel * param = nil;
        
        NSArray *resultArray = [[TimeLogCacheManager sharedInstance] getCompleteLogEntryforCategoryType:self.categoryType andCurrentRequestId:self.requestIdentifier]; // IPAD-4764
        if ([resultArray count] > 0) {
            
            param = [[RequestParamModel alloc] init];
            param.valueMap = resultArray;
            
            return @[param];
        }
    }
    return nil;

}

@end
