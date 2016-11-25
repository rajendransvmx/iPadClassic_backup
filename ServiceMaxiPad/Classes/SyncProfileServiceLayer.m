//
//  SyncProfileServiceLayer.m
//  ServiceMaxiPad
//
//  Created by Padmashree on 11/14/16.
//  Copyright © 2016 ServiceMax Inc. All rights reserved.
//

#import "SyncProfileServiceLayer.h"

@implementation SyncProfileServiceLayer

- (instancetype) initWithCategoryType:(CategoryType)categoryType requestType:(RequestType)requestType {
    self = [super initWithCategoryType:categoryType requestType:requestType];
    if (self != nil) {
        //Intialize if required
    }
    return self;
}

- (ResponseCallback*)processResponseWithRequestParam:(RequestParamModel*)requestParamModel responseData:(id)responseData {
//    NSLog(@"Sync profiling responseData: %@", responseData);
    return nil;
}

- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)count {
    return [self getSyncProfilingParams];
}


-(NSArray *)getSyncProfilingParams {
    RequestParamModel *model = [[RequestParamModel alloc]init];
    return @[model];
}

@end
