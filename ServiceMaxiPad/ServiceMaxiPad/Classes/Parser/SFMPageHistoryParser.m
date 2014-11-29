//
//  SFMPageHistoryParser.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 25/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SFMPageHistoryParser.h"
#import "SFMPageHistoryHelper.h"

@implementation SFMPageHistoryParser

- (ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel responseData:(id)responseData {
    @synchronized([self class]){
        @autoreleasepool {
            if ([responseData isKindOfClass:[NSDictionary class]]) {
                NSDictionary *response = responseData;
                NSArray *resultRecords = [response objectForKey:@"records"];
                [SFMPageHistoryHelper pushPageHistoryResultsToCache:resultRecords];
            }
        }
    }
    return nil;
}

@end
