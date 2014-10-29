//
//  TimeLogManager.m
//  ServiceMaxiPad
//
//  Created by Chinnababu on 28/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "TimeLogManager.h"
#import "TimeLogCacheManager.h"
#import "DateUtil.h"
#import "RequestConstants.h"

NSString *const kT1 = @"SVMX_LOG_T1";
NSString *const kTimeLogId = @"SVMX_LOG_ID";

@implementation TimeLogManager
#pragma mark Singleton Methods
+ (instancetype) sharedInstance {
    
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initInstance];
    });
    
    return sharedInstance;
}

- (instancetype) initInstance {
    
    self = [super init];
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
- (void) logResponseTimeEntryToCache:(TimeLogModel *)logModel {
    [[TimeLogCacheManager sharedInstance] logEntryForSyncResponceTime:logModel];
}

- (NSArray *)getRequestParameterForLogging
{
    //T1 - time.
    NSString *timeT1 = [DateUtil getDatabaseStringForDate:[NSDate date]];
    
    //key - t1 value - t1 timestamp
    NSMutableDictionary *t1Dict = [[NSMutableDictionary alloc] init];
    [t1Dict setObject:kT1 forKey:kSVMXRequestKey];
    [t1Dict setObject:timeT1 forKey:kSVMXRequestValue];
    
    //t4 + t5
    NSDictionary *dictForRequestParameter = [[TimeLogCacheManager sharedInstance] getLogEntry];
    NSMutableDictionary *t45Dict = nil;

    if (dictForRequestParameter != nil) {
        
        t45Dict = [[NSMutableDictionary alloc] init];
        //key = logid value - Logid
        NSString *logId = (dictForRequestParameter.count > 0) ? [[dictForRequestParameter allKeys] lastObject] : nil;
        
        NSArray * internalValues = [dictForRequestParameter objectForKey:logId];
        [t45Dict setObject:kTimeLogId forKey:kSVMXRequestKey];
        [t45Dict setObject:logId forKey:kSVMXRequestValue];
        
        //t4 + t5
        if(internalValues != nil)
        {
            [t45Dict setObject:internalValues forKey:kSVMXRequestSVMXMap];
        }
        if (logId == nil) {
            t45Dict = nil;
        }
        else {
            [[TimeLogCacheManager sharedInstance] deleteLogEntryForId:logId];
        }
    }
    
    //for first time t4 and t5 will be nil, so send only t1.
    if (t45Dict == nil) {
        return @[t1Dict];
    }
    
    return  @[t1Dict,t45Dict];
}

    
@end
