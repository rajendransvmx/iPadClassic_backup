//
//  TimeLogCacheManager.h
//  ServiceMaxiPad
//
//  Created by Krishna Shanbhag on 28/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimeLogModel.h"
@interface TimeLogCacheManager : NSObject


+ (instancetype) sharedInstance;
+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));

- (void) logEntryForSyncResponceTime:(TimeLogModel *)modelObject;
- (void) deleteLogEntryForId:(NSString *)logId;
- (NSDictionary *) getLogEntry;
- (NSDictionary *) getAllLogEntry;
- (BOOL) isCacheEmpty;

@end
