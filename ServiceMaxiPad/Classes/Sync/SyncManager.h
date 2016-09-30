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
#import "SFMCustomActionWebServiceHelper.h"
#import "TagConstant.h"
#import "WebserviceResponseStatus.h"

extern NSString *kInitialSyncStatusNotification;
extern NSString *kConfigSyncStatusNotification;
extern NSString *kDataSyncStatusNotification;
extern NSString *kEventSyncStatusNotification;
extern NSString *kSyncTimeUpdateNotification;
extern NSString *kProfileValidationStatusNotification;
extern NSString *kScheduledConfigSyncNotification;
extern NSString *kUpdateEventNotification;
extern NSString *lastConfigSyncTimeKey;
extern NSString *lastDataSyncTimeKey;
extern NSString *syncMetaDataFile;
extern NSString *kUpadteWebserviceData;

@interface SyncManager : NSObject <FlowDelegate, SchedulerDelegate, OPDocCustomDelegate>

@property(nonatomic, assign) BOOL isConfigSyncDueAlertShown;
@property(nonatomic, assign) BOOL isGetPriceCallEnabled;

@property (nonatomic,assign) SyncType syncType;
@property (nonatomic,strong) WebserviceResponseStatus *syncResponseStatus;
@property (nonatomic,strong) NSError *syncError;

// ...

+ (instancetype) sharedInstance;

+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));

// ...


/**
 * @name  performDataSyncIfNetworkReachable
 *
 * @author Vipindas Palli
 *
 * @brief Perform Datasync If network reachable Other wise not. This is for offfline support
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Void
 *
 */
- (void)performDataSyncIfNetworkReachable;

- (void)performSyncWithType:(SyncType)syncType;
- (void)cancelSyncForType:(SyncType)syncType;

- (NSDate*)getLastSyncTimeFor:(SyncType)syncType;
- (NSDate*)getNextSyncTimeFor:(SyncType)syncType;
- (SyncStatus)getSyncStatusFor:(SyncType)syncType;

- (BOOL)syncInProgress;
- (BOOL)isDataSyncInProgress;
- (BOOL)isConfigSyncInProgress;
- (BOOL)isInitalSyncOrResetApplicationInProgress;
- (BOOL)isConfigSyncInQueue;
- (BOOL)isInitialSyncInQueue;

- (void)updateUserTableIfRecordDoesnotExist;

- (NSString *)nextScheduledDataSyncTime;
- (NSString *)nextScheduledConfigSyncTime;

- (void)scheduleSync;
- (void)scheduleConfigSync;
- (void)invalidateScheduleSync;
- (void)enableAllParallelSync:(BOOL)shouldEnable;

- (void)setSyncCompletionFlag;

- (void)resetConfigSyncLocalNotification;
- (void)removeConfigSyncLocalNotification;

- (void)enqueueSyncQueue:(SyncType)syncType;
- (SyncType)dequeueSyncQueue;

- (void)handleSyncCompletion;
- (dispatch_queue_t)getSyncErrorReportQueue;

@end
