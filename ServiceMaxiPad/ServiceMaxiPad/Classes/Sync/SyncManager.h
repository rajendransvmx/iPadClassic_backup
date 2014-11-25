//
//  SyncManager.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 3/26/14.
//  Copyright (c) 2013 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncConstants.h"
#import "FlowDelegate.h"
#import "SyncScheduler.h"
#import "OpDocHelper.h"

extern NSString *kInitialSyncStatusNotification;
extern NSString *kConfigSyncStatusNotification;
extern NSString *kDataSyncStatusNotification;
extern NSString *kEventSyncStatusNotification;
extern NSString *kSyncTimeUpdateNotification;
extern NSString *kProfileValidationStatusNotification;
extern NSString *kScheduledConfigSyncNotification;


extern NSString *lastConfigSyncTimeKey;
extern NSString *lastDataSyncTimeKey;
extern NSString *syncMetaDataFile;

@interface SyncManager : NSObject <FlowDelegate, SchedulerDelegate, OPDocCustomDelegate>


// ...

+ (instancetype) sharedInstance;

+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));

// ...


- (void)performSyncWithType:(SyncType)syncType;
- (void)cancelSyncForType:(SyncType)syncType;

- (NSDate*)getLastSyncTimeFor:(SyncType)syncType;
- (NSDate*)getNextSyncTimeFor:(SyncType)syncType;
- (SyncStatus)getSyncStatusFor:(SyncType)syncType;

- (NSUInteger)getConflictsCount;
- (NSArray*)getConflictsList;

- (BOOL)syncInProgress;
- (BOOL)isDataSyncInProgress;
- (BOOL)isConfigSyncInProgress;
- (BOOL)isInitalSyncOrResetApplicationInProgress;

- (void)updateUserTableIfRecordDoesnotExist;

- (NSString *)nextScheduledDataSyncTime;
- (NSString *)nextScheduledConfigSyncTime;

- (void)scheduleSync;
- (void)scheduleConfigSync;
- (void)invalidateScheduleSync;
- (void)enableAllParallelSync:(BOOL)shouldEnable;

@end
