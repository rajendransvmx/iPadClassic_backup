//
//  TimeLogParser.m
//  ServiceMaxiPad
//
//  Created by Krishna Shanbhag on 29/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "TimeLogParser.h"
#import "ResponseConstants.h"
#import "StringUtil.h"
#import "TimeLogCacheManager.h"


@implementation TimeLogParser

-(TimeLogModel *)parseTimeLogIdForResponse:(id)responseData;
{
    @autoreleasepool {
        
        if ([responseData isKindOfClass:[NSDictionary class]])
        {
            TimeLogModel *model;
            NSArray *valueMaps = [responseData objectForKey:kSVMXRequestSVMXMap];
            if ([valueMaps count] > 0) {
                for (NSDictionary *dictObj in valueMaps) {
                    
                    NSString *string = [dictObj valueForKey:kSVMXRequestKey];
                    if (![string isKindOfClass:[NSNull class]] && [string isEqualToString:kTimeLogId]) {
                       model = [self getTimeLogModelFromDictionary:dictObj];
                    }
                    
                }
                
            }
            return model;
        }
    }
    return nil;
}
-(void)parseAndDeleteLogIdFromCache:(id)responseData;
{
    @autoreleasepool {
        
        if ([responseData isKindOfClass:[NSDictionary class]])
        {
            [[TimeLogCacheManager sharedInstance] clearAllFailureList];
            NSArray *valueMaps = [responseData objectForKey:kSVMXRequestSVMXMap];
            if ([valueMaps count] > 0) {
                for (NSDictionary *dictObj in valueMaps) {
                    
                    NSString *string = [dictObj valueForKey:kSVMXRequestKey];
                    if (![string isKindOfClass:[NSNull class]] && [string isEqualToString:kTimeLogRequestID]) {
                        for (NSString *logId in  [dictObj valueForKey:kSVMXRequestValues]) {
                            
                            [[TimeLogCacheManager sharedInstance] deleteLogEntryForId:logId];
                            SXLogDebug(@"TIME_LOG_CACHE %@",[[TimeLogCacheManager sharedInstance] getAllLogEntry]);
                        }
                        
                    }
                    
                }
                
            }
        }
    }
}
#pragma mark - Internal Methods

- (TimeLogModel *)getTimeLogModelFromDictionary:(NSDictionary *)pDict {
    
    TimeLogModel *modelObject = [[TimeLogModel alloc]init];
    NSString *timeLogKey = [pDict objectForKey:kSVMXRequestKey];
    if ([StringUtil checkIfStringEmpty:timeLogKey]) {
        timeLogKey = @"";
    }
    NSString *timelogIdValue = [pDict objectForKey:kSVMXRequestValue];
    if ([StringUtil checkIfStringEmpty:timelogIdValue]) {
        timelogIdValue = @"";
    }
    modelObject.timeLogIdKey = timeLogKey;
    modelObject.timeLogIdvalue = timelogIdValue;
    
    
    return modelObject;
}


@end
