//
//  SMDataPurgeManager.h
//  ServiceMaxiPad
//
//  Created by Pushpak on 16/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SMDataPurgeHelper.h"

typedef enum DataPurgeStatus
{
    DataPurgeStatusUnknown = -1,
    DataPurgeStatusScheduled = 1,
    DataPurgeStatusWSForLastModifiedDate = 2,
    DataPurgeStatusWSForDownloadCriteria = 3,
    DataPurgeStatusWSForAdvancedDownloadCriteria = 4,
    DataPurgeStatusWSForGetPrice = 5,
    DataPurgeStatusWSForCleanup = 20,
    DataPurgeStatusWSRescheduled= 21,
    DataPurgeStatusDataProcessing = 30,
    DataPurgeStatusDataProcessRescheduled = 31,
    DataPurgeStatusPurgingInProgress = 40,
    DataPurgeStatusPurgingRescheduled = 41,
    DataPurgeStatusCancelled = 42,
    DataPurgeStatusCompleted = 100,
    DataPurgeStatusFailed = 101,
    DataPurgeStatusException = 102,
    DataPurgeStatusRequiredConfigUpdate = 103,
    DataPurgeStatusDue = 999,
    
}DataPurgeStatus;

@interface SMDataPurgeManager : NSObject<UIAlertViewDelegate>

+ (instancetype) sharedInstance;
+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));

@property (nonatomic, copy)NSString              *responseLastConfigTime;

//NStimer to schedule the timer for purge
@property (nonatomic, strong)NSTimer             *dataPurgeTimer;
@property (nonatomic, strong)NSMutableDictionary *purgeMap;
@property (nonatomic, strong)NSDate              *configLastModifiedDate;
@property (nonatomic, strong)NSString            *requestId;
@property (nonatomic, assign)DataPurgeStatus     purgeStatus;
@property (nonatomic, assign)BOOL                isScheduledPurging;
@property (nonatomic, strong)NSMutableDictionary *keyPrefixObjectName;
@property (nonatomic, strong)NSString            *graceLimitDate;
@property (nonatomic, strong)NSMutableDictionary *conflictRecordMap;
@property (nonatomic, assign)BOOL                isSyncInProgress;
//To avoid unnecessary cleanup of database
@property (nonatomic, assign)BOOL                isCleanUpDataBaseRequired;
@property (nonatomic, strong)NSMutableDictionary *partialExecutedValuesDict;
//NStimer to watch the sync activities
@property (nonatomic, strong)NSTimer             *syncWatchDogTimer;


- (void)startMannualPurging;
- (void)startSchedulePurging;
- (BOOL)isDataPurgeInDue;
- (BOOL)isSchedulePurgeInDue;
- (BOOL)isDataPurgeScheduled;
- (NSString *)dataPurgeDueMessage;
- (void)reschedulePurgingForNextInterval:(NSDate *)date;
- (NSString *)getLastDataPurgeTime;
- (NSString *)getNextDataPurgeTime;
- (NSString *)getLastDataPurgeStatus;
- (NSMutableDictionary *)getProgressBarDetails;
- (void)invalidateAndScheduleTimer:(NSNumber *)interval;

- (void)updateNextDataPurgeTime:(NSDate *)date;
- (void)updateTimerAndNextDPTime:(NSDate *)date;
- (void)updateTimerWhenAppLoggedIn:(NSDate *)date;
- (void)stopDataPurge;
- (void)clearPurgeDefaultValues;
- (void)clearDueIfConfigSyncSuccess;


- (void)manageDataPurge;

@end
