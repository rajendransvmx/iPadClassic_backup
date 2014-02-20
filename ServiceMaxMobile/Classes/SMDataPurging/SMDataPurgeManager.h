//
//  SMDataPurgeManager.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 12/31/13.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMDataPurgeRequest.h"
#import "SMDataPurgeHelper.h"
#import "SMDataPurgeCallBackData.h"


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



@interface SMDataPurgeManager : NSObject <SMDataPurgeRequestDelegate, UIAlertViewDelegate>
{

}

//NStimer to schedule the timer for purge
@property (nonatomic, retain)NSTimer             *dataPurgeTimer;
@property (nonatomic, retain)NSMutableDictionary *purgeMap;
@property (nonatomic, retain)NSDate              *configLastModifiedDate;
@property (nonatomic, retain)NSString            *requestId;
@property (nonatomic, assign)DataPurgeStatus     purgeStatus;
@property (nonatomic, assign)BOOL                isScheduledPurging;
@property (nonatomic, retain)SMDataPurgeRequest  *activeRequest;
@property (nonatomic, retain)NSMutableDictionary *keyPrefixObjectName;
@property (nonatomic, retain)NSString            *graceLimitDate;
@property (nonatomic, retain)NSMutableDictionary *conflictRecordMap;
@property (nonatomic, assign)BOOL                isSyncInProgress;
@property (nonatomic, assign)BOOL                isCleanUpDataBaseRequired; //To avoid unnecessary cleanup of databse

+ (SMDataPurgeManager *)sharedInstance;

- (void)startMannualPurging;
- (void)startSchedulePurging;
- (BOOL)isDataPurgeInDue;
- (BOOL)isSchedulePurgeInDue; //9862 - Defect Fix
- (BOOL)isDataPurgeScheduled;
- (NSString *)dataPurgeDueMessage;
- (void)reschedulePurgingForNextInterval:(NSDate *)date;
- (NSString *)getLastDataPurgeTime;
- (NSString *)getNextDataPurgeTime;
- (NSString *)getLastDataPurgeStatus;
- (NSMutableDictionary *)getProgressBarDetails;
- (void)invalidateAndScheduleTimer:(NSNumber *)interval;
//- (void)scheduleDataPurgeTimer:(NSTimeInterval)interval;
//- (void)invalidateDataPurgeTimer;
- (void)updateNextDataPurgeTime:(NSDate *)date;
- (void)updateTimerAndNextDPTime:(NSDate *)date;
- (void)updateTimerWhenAppLoggedIn:(NSDate *)date;
- (void)stopDataPurge;
- (void)clearPurgeDefaultValues; //9862 - Defect Fix
- (void)clearDueIfConfigSyncSuccess; //9862 - Defect Fix

@end

