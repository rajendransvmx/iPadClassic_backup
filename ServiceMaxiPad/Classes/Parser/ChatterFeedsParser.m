//
//  ChatterFeedsParser.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 01/01/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "ChatterFeedsParser.h"
#import "ChatterManager.h"

@implementation ChatterFeedsParser

- (ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel responseData:(id)responseData {
    @synchronized([self class]){
        @autoreleasepool {
            
            if ([responseData isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *dict = (NSDictionary *)responseData;
                
                SXLogInfo(@"Chatter Id = %@", [dict objectForKey:kId]);
                
                if ([requestParamModel.value  length] > 0) {
                    [[ChatterManager sharedInstance] deleteParamDictForkey:requestParamModel.value];
                }
            }
        }
    }
    return nil;
}


@end
