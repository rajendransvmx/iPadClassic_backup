//
//  SMDataPurgeManager.m
//  ServiceMaxiPad
//
//  Created by Pushpak on 16/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SMDataPurgeManager.h"
#import "SMDataPurgeModel.h"
#import "SMObjectRelationModel.h"
#import "SMObjectRelationModel.h"
#import "SVMXSystemConstant.h"
#import "TagConstant.h"
#import "SyncManager.h"
#import "TagManager.h"
#import "DBCriteria.h"
#import "DBField.h"
#import "FlowDelegate.h"
#import "TaskGenerator.h"
#import "TaskManager.h"
#import "WebserviceResponseStatus.h"
#import "Reachability.h"
#import "DateUtil.h"
#import "SMLocalNotificationManager.h"
#import "AlertMessageHandler.h"
#import "NonTagConstant.h"
#import "ProductIQManager.h"

const int percentage = 5;
const float progress = 0.05;

@interface SMDataPurgeManager ()<FlowDelegate>
@property (nonatomic, copy) NSString *dataPurgeTaskID;
@end

@implementation SMDataPurgeManager

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
    // Do any other initialisation stuff here
    // ...
    self.purgeStatus = DataPurgeStatusCompleted;
    self.isCleanUpDataBaseRequired = NO;
    [self registerForServiceMaxSyncNotification];

    return self;
}

- (void)dealloc
{
    _configLastModifiedDate = nil;
    _requestId = nil;
    _purgeMap = nil;
    _graceLimitDate = nil;
    _dataPurgeTimer = nil;
    _conflictRecordMap = nil;
    _partialExecutedValuesDict = nil;
    _syncWatchDogTimer = nil;
}

-(void)updateDataPurgeTimer
{
    NSDate * nextDPTime = [SMDataPurgeHelper retrieveNextDPTime];
    
    if (nextDPTime == nil)   //Holds good for upgrade scenario
    {
        [self initiateAllDataPurgeProcess];
    }
    else
    {
        NSTimeInterval interval = [SMDataPurgeHelper getTimerIntervalForDataPurge];
        
        if (interval > 0)
        {
            [[SMDataPurgeManager sharedInstance] updateTimerWhenAppLoggedIn:[NSDate date]];
        }
    }
}

- (void)invalidateAllDataPurgeProcess {
    [self clearPurgeDefaultValues];
}

- (void)rescheduleDataPurgeTimer
{
    [[SMDataPurgeManager sharedInstance] clearDueIfConfigSyncSuccess];
    [self initiateAllDataPurgeProcess];
}


- (void)initiateAllDataPurgeProcess {
    
    NSTimeInterval interval = [SMDataPurgeHelper getTimerIntervalForDataPurge];
    
    if (interval > 0)
    {
        SXLogDebug(@"%@", [NSNumber numberWithDouble:interval]);
        
        [[SMDataPurgeManager sharedInstance] performSelectorOnMainThread:@selector(invalidateAndScheduleTimer:) withObject:[NSNumber numberWithFloat:interval] waitUntilDone:YES];
        [self updateNextDataPurgeTime:[[NSDate date] dateByAddingTimeInterval:interval]];
    }
}

- (void)manageDataPurge
{
    @synchronized([self class])
    {
        switch (self.purgeStatus)
        {
            case DataPurgeStatusScheduled:
            {
                self.purgeStatus = DataPurgeStatusWSForLastModifiedDate;
                [self makeRequestToserverForTheCategoryType:CategoryTypeDataPurgeFrequency];
                break;
            }
                
            case DataPurgeStatusWSForLastModifiedDate:
            {
                self.purgeStatus = DataPurgeStatusWSForDownloadCriteria;
                [self makeRequestToserverForTheCategoryType:CategoryTypeDataPurge];
                break;
            }
                
            case DataPurgeStatusWSForDownloadCriteria:
            {
                self.purgeStatus = DataPurgeStatusWSForAdvancedDownloadCriteria;
                break;
            }
                
            case DataPurgeStatusWSForAdvancedDownloadCriteria:
            {
                self.purgeStatus = DataPurgeStatusWSForGetPrice;
                break;
            }
                
            case DataPurgeStatusWSForGetPrice:
            {
                self.purgeStatus = DataPurgeStatusWSForCleanup;
                break;
            }
                
            case DataPurgeStatusWSForCleanup:
            {
                
                if ([[ProductIQManager sharedInstance] isProductIQSettingEnable]) {
                    [SMDataPurgeHelper saveLocationSfIdsFromDataPurgeTableForWorkOrderObject];
                }
                
                
                self.purgeStatus = DataPurgeStatusDataProcessing;
                self.purgeMap = [SMDataPurgeHelper populatePurgeMapFromDataPurgeTable];
                double delayInSeconds = 0.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    //code to be executed on the main queue after delay
                    [self identifyingDataToRemove];
                });
                break;
            }
                
            case DataPurgeStatusDataProcessing:
            {
                self.purgeStatus = DataPurgeStatusPurgingInProgress;
                [self postNotificationToDisableCancelButton];
                double delayInSeconds = 0.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    //code to be executed on the main queue after delay
                    [self startPurgeDatabase];
                });
                break;
            }
                
            case DataPurgeStatusCompleted:
            case DataPurgeStatusRequiredConfigUpdate:
            {
                double delayInSeconds = 0.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    //code to be executed on the main queue after delay
                    [self updateDataPurgeTimeAndCleanUpManager];
                });
                break;
            }
                
            default:
                break;
        }
        [self postNotificationToUpdateProgressBar];
        
    }
    
}

//Defect Fix:029269
-(BOOL)isDataPurgeInProgress
{
    //DefectFix:029269 //
    if (([SMDataPurgeManager sharedInstance].purgeStatus == DataPurgeStatusScheduled) || ([SMDataPurgeManager sharedInstance].purgeStatus == DataPurgeStatusWSForLastModifiedDate) || ([SMDataPurgeManager sharedInstance].purgeStatus == DataPurgeStatusWSForDownloadCriteria) || ([SMDataPurgeManager sharedInstance].purgeStatus == DataPurgeStatusWSForAdvancedDownloadCriteria) ||([SMDataPurgeManager sharedInstance].purgeStatus == DataPurgeStatusWSForGetPrice) ||([SMDataPurgeManager sharedInstance].purgeStatus == DataPurgeStatusWSForCleanup)||([SMDataPurgeManager sharedInstance].purgeStatus == DataPurgeStatusDataProcessing)|| ([SMDataPurgeManager sharedInstance].purgeStatus == DataPurgeStatusPurgingInProgress))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)generatePurgeReport
{
    NSArray *apiNames =  [self.purgeMap  allKeys];
    
    for (NSString *apiOrTableName in apiNames)
    {
        SMDataPurgeModel *model = [self.purgeMap objectForKey:apiOrTableName];
        
        if (model != nil)
        {
            @autoreleasepool
            {
                [model generatePurgeReport];
            }
        }
    }
}


- (void)cleanupDataPurgeManager
{
    if (self.purgeMap != nil)
    {
        [self.purgeMap removeAllObjects];
        self.purgeMap = nil;
    }

    if(self.conflictRecordMap != nil)
    {
        [self.conflictRecordMap removeAllObjects];
        self.conflictRecordMap = nil;
    }
    [self emptyKeyPrefixDictionary];
    
    if (self.partialExecutedValuesDict != nil)
    {
        [self.partialExecutedValuesDict removeAllObjects];
        self.partialExecutedValuesDict = nil;
    }
    
    self.isCleanUpDataBaseRequired = NO;
}


- (void)cleanUpDataBase
{
    if (self.purgeStatus == DataPurgeStatusCompleted
        && [self isdataPurgeSuccess]
        && self.isCleanUpDataBaseRequired)
    {
        self.isCleanUpDataBaseRequired = NO;
        [SMDataPurgeHelper initiateDataBaseCleanUp];
    }
}

- (void)identifyingDataToRemove
{
    @synchronized([self class])
    {
        if ([self isRescheduled])
        {
            return;
        }
        
        [self fillPurgeMapWithApiName];
        [self fillChildrenAndRelatedRecordForPurgeMap];
        
        // To identify whatId of Object.
        [self fillKeyPrefixMapWithObjectName];
        
        [self fillGracePeriodRecordsForPurgeMap];
        //Due to database error we have commented the following method. Radha
       // [self fillNonGracePeriodTrailerTableRecords];
        
        [self fillPurgeableDODRecords];
        [self fillNonPurgeableDODRecords];
        [self fillEventRelatedDataForPurgeMap];
        
        [self seggregateNonPurgeableRecords:NO];
        
        // Reference and Child Objects need to be idenitified.
        [self findAndFillChildObjectRecordForSave];
        [self findAndFillReferenceObjectRecordForSave];
        
        [self seggregateNonPurgeableRecords:YES];
        
        //seggregrate record to be purged
        [self fillPurgeableRecordForPurgeMap];
        
        //update all the child record should purge with parent 9969 - Defect Fix
        [self fillPurgeableRecordForChildShouldPurgeWithParent];
        
        [self fillConflictRecordsForPurgeMap];
        
        [self manageDataPurge];
    }
}


- (void)startPurgeDatabase
{
    @synchronized([self class])
    {
        if ([self isRescheduled])
        {
            return;
        }
        
        self.purgeStatus = DataPurgeStatusPurgingInProgress;
        
        NSArray *apiNames =  [self.purgeMap  allKeys];
        BOOL failed = NO;
        
        for (NSString *apiOrTableName in apiNames)
        {
            SMDataPurgeModel *model = [self.purgeMap objectForKey:apiOrTableName];
            
            if ( (model != nil) && (model.isPurgeable))
            {
                model.status = DPActionStatusInProgress;
                
                [SMDataPurgeHelper executeDataPurging:model];
                
                if (model.status != DPActionStatusCompleted)
                {
                    SXLogDebug(@" Error on pruging %@", apiNames);
                    failed = YES;
                }
            }
            if (model != nil)
            {
                [SMDataPurgeHelper checkForDODTrailerAndConflictRecrdToPurge:model];
            }
        }
        
        if (!failed)
        {
            /* here using constant value, not tag value for success display value */
            [SMDataPurgeHelper saveDataPurgeStatusSinceCompleted:kSuccess];
        }
        else
        {
             /* here using constant value, not tag value for failure display value */
            [SMDataPurgeHelper saveDataPurgeStatusSinceCompleted:kFailed];
        }
        
        self.purgeStatus = DataPurgeStatusCompleted;
        
        [self manageDataPurge];
        SXLogDebug(@" Completed Data Purging");
    }
}


- (void)updateDataPurgeTimeAndCleanUpManager
{
    [self setLastDataPurgeTime];
    [self updateTimerAndNextDPTime:[NSDate date]];
    self.isCleanUpDataBaseRequired = NO;
    [self generatePurgeReport];
    [self cleanUpDataBase];
    [self cleanupDataPurgeManager];
    [self clearIfPurgeDueFlagSet];
    
    if (self.purgeStatus == DataPurgeStatusCompleted)
    {
        [self postNotificationToRemoveProgressBar];
    }
    
}

#pragma Mark  Manage sync Notification Observe

- (void)registerForServiceMaxSyncNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelDataPurgeSinceSyncInProgress)
                                                 name:kNotificationSyncStarted
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(restartDataPurge)
                                                 name:kNotificationSyncCompleted
                                               object:nil];
}


- (void)deregisterForServiceMaxSyncNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationSyncStarted
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationSyncCompleted
                                                  object:nil];
}


- (void)postDataPurgeStartedNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDataPurgeStarted
                                                        object:nil
                                                      userInfo:nil];
    
}


- (void)postDataPurgeCompletedNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDataPurgeCompleted
                                                        object:nil
                                                      userInfo:nil];
    
}


- (void)postDataPurgeDueNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDataPurgeDueAlert
                                                        object:nil
                                                      userInfo:nil];
    
}


#pragma mark - Data Purge Process Sync with OnGoing Sync call

- (void)cancelDataPurgeSinceSyncInProgress
{
    self.isSyncInProgress = YES;
    
    
    if (self.purgeStatus != DataPurgeStatusCompleted && (![self isSchedulePurgeInDue])) //9946 Defect Fix
    {
        //When any of the sync is in progress start timer to check the status - 10168
        [self performSelectorOnMainThread:@selector(startWatchDogTimerWhenSyncInProgress) withObject:nil waitUntilDone:YES];
        
        self.purgeStatus = DataPurgeStatusPurgingRescheduled;
        double delayInSeconds = 5.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            [self cleanupDataPurgeManager];
        });
        
        [self manageDataPurge];
    }
}

- (void)stopDataPurge
{
    //[SMDataPurgeHelper saveDataPurgeStatusSinceCompleted:[[TagManager sharedInstance] tagByName:kTagDataPurgeStatusCancelled]];
    
    [SMDataPurgeHelper saveDataPurgeStatusSinceCompleted:kCancel];
    [[TaskManager sharedInstance] cancelFlowNodeWithId:self.dataPurgeTaskID];
    
    self.purgeStatus = DataPurgeStatusCancelled;
  
    
    [self updateTimerAndNextDPTime:[NSDate date]];
    [self clearIfPurgeDueFlagSet];
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        SXLogDebug(@"stopDataPurge - Calling clean up");
        [self cleanupDataPurgeManager];
        [self postNotificationToRemoveProgressBar];
        self.purgeStatus = DataPurgeStatusCompleted;
    });
}


- (void)purgeInititate
{
    if ([self isSyncGoingOn])
    {
        if(self.isSyncInProgress)
        {
            self.purgeStatus = DataPurgeStatusPurgingRescheduled;
        }
    }
    else
    {
        //Defect:026563
        SyncManager *syncMan = [SyncManager sharedInstance];
        syncMan.dataPurgeStatus = DataPurgeInProgress;
        
        [self postDataPurgeStartedNotification];
        self.purgeStatus = DataPurgeStatusScheduled;
        [SMDataPurgeHelper clearDataPurgeTableContents];
        [self updateGraceLimitDate];
        [self manageDataPurge];
    }
}

- (void)shouldRestartDataPurge
{
    if (self.purgeStatus == DataPurgeStatusPurgingRescheduled)
    {
        [self purgeInititate];
    }
}

- (void)restartDataPurge
{
    
    self.isSyncInProgress = NO;
    
    if (self.purgeStatus == DataPurgeStatusPurgingRescheduled)
    {
        // It is good we are checking any pending job on my desk :)
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            [self shouldRestartDataPurge];
        });
    }
}


- (void)clearPurgeDefaultValues
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults)
    {
        [userDefaults setObject:nil forKey:kDataPurgeLastSyncTime];
        [userDefaults setObject:nil forKey:kDataPurgeNextSyncTime];
        [userDefaults setObject:nil forKey:kDataPurgeStatus];
        [userDefaults setObject:nil forKey:kDataPurgeConfigSyncStartTime];
        [userDefaults setObject:nil forKey:kDataPurgeLastSuccessfulConfigSyncStartTime];
        [userDefaults synchronize];
    }
    self.purgeStatus = DataPurgeStatusCompleted;
    self.isCleanUpDataBaseRequired = NO;
    self.isSyncInProgress = NO;
    
    [self invalidateDataPurgeTimer];
    [self cleanupDataPurgeManager];
    [self clearIfPurgeDueFlagSet];
}


- (void)clearIfPurgeDueFlagSet
{
    if (self.isScheduledPurging == YES)
    {
        self.isScheduledPurging = NO;
        [SMDataPurgeHelper saveIfDataPurgeDue:NO];
    }
}


- (void)clearDueIfConfigSyncSuccess
{
    [self clearIfPurgeDueFlagSet];
    self.isCleanUpDataBaseRequired = NO;
    self.purgeStatus = DataPurgeStatusCompleted;
}

#pragma mark - Data Purging Initiate

- (void)startMannualPurging
{
    
    if ((self.purgeStatus == DataPurgeStatusCompleted)
        || [self isDataPurgeInDue])
    {
        self.isScheduledPurging = NO;
        [SMDataPurgeHelper saveIfDataPurgeDue:NO];
        [self purgeInititate];
        [self setSyncWatchDogTimerIfRequired];
    }
}


- (void)startSchedulePurging
{
    SXLogDebug(@"Status = %d", self.purgeStatus);
    if ((self.purgeStatus == DataPurgeStatusCompleted)
        || [self isDataPurgeInDue])
    {
        self.isScheduledPurging = YES;
        [SMDataPurgeHelper saveIfDataPurgeDue:NO];
        [self purgeInititate];
    }
}

- (void)scheduleDataPurge
{
    [self reschedulePurgingForNextInterval:[NSDate date]];
    self.purgeStatus = DataPurgeStatusDue;
    self.isScheduledPurging = YES;
    [SMDataPurgeHelper saveIfDataPurgeDue:YES];
    [self postDataPurgeDueNotification];
    
}


- (BOOL)isDataPurgeInDue;
{
    if (self.purgeStatus == DataPurgeStatusDue || self.purgeStatus == DataPurgeStatusPurgingRescheduled)
    {
        return YES;
    }
    return NO;
}


- (BOOL)isSchedulePurgeInDue
{
    if ([SMDataPurgeHelper isPurgeDue] == YES)
    {
        return YES;
    }
    return NO;
}


- (BOOL)isDataPurgeScheduled
{
    int value = [[SMDataPurgeHelper getDataPurgeFrequencySettingsValue] intValue];
    
    if (value <= 0)
    {
        return NO;
    }
    return YES;
}

- (BOOL)isdataPurgeSuccess
{
     /* here using constant value, not tag value for success display value */
    NSString * value = kSuccess;

    if ([[SMDataPurgeHelper lastDataPurgeStatus] isEqualToString:value])
    {
        return YES;
    }
    
    return NO;
}

- (NSString *)dataPurgeDueMessage
{
    return [[TagManager sharedInstance] tagByName:kTagDataPurgeDue];
}


- (void)reschedulePurgingForNextInterval:(NSDate *)date
{
    self.purgeStatus = DataPurgeStatusCompleted;
    //Invalidate timer and reschedule timer for next interval
    [self updateTimerAndNextDPTime:date];
    [SMDataPurgeHelper saveIfDataPurgeDue:NO];
    [self clearIfPurgeDueFlagSet];
}


- (NSString *)getLastDataPurgeTime
{
    NSString * lastDpTime = nil;
    NSDate * date = [SMDataPurgeHelper retrieveLastSuccesDPTime];
    if (date != nil)
    {
        lastDpTime = [self getLocalTimeWithUserReadableFormat:date];
    }
    return  lastDpTime;
}


- (NSString *)getNextDataPurgeTime
{
    NSString * nexttDpTime = nil;
    
    if ([self isDataPurgeScheduled])
    {
        NSDate * date = [SMDataPurgeHelper retrieveNextDPTime];
        if (date != nil)
        {
            nexttDpTime = [self getLocalTimeWithUserReadableFormat:date];
        }
    }
    else
    {
        nexttDpTime = [[TagManager sharedInstance] tagByName:kTagNotScheduled];
    }
    return  nexttDpTime;
}


- (NSString *)getLastDataPurgeStatus
{
    return [SMDataPurgeHelper lastDataPurgeStatus];
}


- (NSString *)getLocalTimeWithUserReadableFormat:(NSDate *)gmtDate
{
    NSString * dateInString = [DateUtil getLiteralSupported12Hr_24HrDateStringForDate:gmtDate];
    return dateInString;
}


- (BOOL)isConfigSyncToBeDone:(NSString *)lastServerConfigTime
{
    self.configLastModifiedDate  = [DateUtil dateFromString:lastServerConfigTime inFormat:kDateFormatType9];
    
    NSDate * lastConfigDate = [SMDataPurgeHelper lastSuccessConfigSyncTimeForDataPurge];
    
    SXLogDebug(@"Last Server Modified Time = %@  Last Client Config Sync Time = %@", lastServerConfigTime, lastConfigDate);
    
    if (lastConfigDate != nil && self.configLastModifiedDate != nil)
    {
        NSComparisonResult compare = [self compareLastSyncConfigTime:lastConfigDate withModifiedSyncConfigTime:self.configLastModifiedDate];
        
        if (compare == NSOrderedSame || compare == NSOrderedAscending)
        {
            return YES;
        }
    }
    return NO;
}


- (BOOL)isRescheduled
{
    if (self.purgeStatus == DataPurgeStatusPurgingRescheduled || self.purgeStatus == DataPurgeStatusCancelled)
    {
        return YES;
    }
    return NO;
}

- (NSComparisonResult)compareLastSyncConfigTime:(NSDate *)lastConfigTime withModifiedSyncConfigTime:(NSDate *)configTime
{
    NSComparisonResult compare = 2;
    if (lastConfigTime != nil && configTime != nil)
    {
        compare = [lastConfigTime compare:configTime];
    }
    return compare;
}

- (void)setPurgeMapWithResponseDict:(NSMutableDictionary *)resultDict
{
    if (self.purgeMap == nil)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        self.purgeMap = dict;
    }
    SMDataPurgeModel * purgeModel = nil;
    
    NSArray * allKey = [resultDict allKeys];
    
    @autoreleasepool
    {
        for (NSString * objectName in allKey)
        {
            purgeModel = [self getPurgeModelForObjectName:objectName];
            
            if (purgeModel != nil)
            {
                SMDataPurgeModel * resultModel = [resultDict objectForKey:objectName];
                
                NSArray * array = resultModel.advancedOrDownloadedCriteriaRecords;
                
                for (NSString * recordId in array)
                {
                    [purgeModel addDownloadedCriteriaObject:recordId];
                }
            }
            else
            {
                [self.purgeMap setObject:[resultDict objectForKey:objectName] forKey:objectName];
            }
        }
    }
}


- (SMDataPurgeModel *)getPurgeModelForObjectName:(NSString *)objecName
{
    NSArray * purgeMapKey = [self.purgeMap allKeys];
    
    if ([purgeMapKey containsObject:objecName])
    {
        return [self.purgeMap objectForKey:objecName];
    }
    return nil;
}


- (void)fillKeyPrefixMapWithObjectName
{
    self.keyPrefixObjectName  = [SMDataPurgeHelper retieveKeyPrefixWithObjecName];
}


- (void)emptyKeyPrefixDictionary
{
    if (self.keyPrefixObjectName != nil)
    {
        [self.keyPrefixObjectName removeAllObjects];
        self.keyPrefixObjectName = nil;
    }
}


- (void)fillPurgeableRecordForPurgeMap
{
    NSArray * purgeKey = [self.purgeMap allKeys];
    
    @autoreleasepool
    {
        for (NSString * objectName in purgeKey)
        {
            [SMDataPurgeHelper purgeDataForObject:[self.purgeMap objectForKey:objectName]];
        }
    }
}

- (void)fillPurgeableRecordForChildShouldPurgeWithParent
{
    NSArray * apiNames = [self.purgeMap allKeys];
    
    for (NSString * objectName in apiNames)
    {
        SMDataPurgeModel * model = [self.purgeMap objectForKey:objectName];
        
        if (model != nil && (!model.isEmptyTable))
        {
            if ([model shouldPurgeWithParent])
            {
                for (NSMutableDictionary * dict in model.parentObjectNames)
                {
                    NSArray * allKeys = [dict allKeys];
                    if (allKeys != nil)
                    {
                        NSString * columnName = [dict objectForKey:[allKeys objectAtIndex:0]];
                        SMDataPurgeModel * parentModel = [self.purgeMap objectForKey:[allKeys objectAtIndex:0]];
                        [SMDataPurgeHelper fillPurgeableRecordForIsolatedChild:model parent:parentModel column:columnName];
                    }
                }
            }
        }
    }
}


- (void)fillConflictRecordsForPurgeMap
{
    self.conflictRecordMap = [SMDataPurgeHelper retrieveConflictRecordMap];
    NSArray * purgeMapKey = [self.purgeMap allKeys];
    @autoreleasepool
    {
        for (NSString * objectName in purgeMapKey)
        {
            [SMDataPurgeHelper retrievePurgeableConflictRecordForModel:[self.purgeMap objectForKey:objectName] conflictMap:self.conflictRecordMap];
        }
    }
    
}


- (void)fillGracePeriodRecordsForPurgeMap
{
    DBCriteria *filterCriteria = [[DBCriteria alloc]initWithFieldName:@"LastModifiedDate"
                                                         operatorType:SQLOperatorGreaterThanEqualTo
                                                        andFieldValue:self.graceLimitDate];
    
    DBCriteria *trailerFilterCrirteria = [[DBCriteria alloc]initWithFieldName:@"timeStamp"
                                                                 operatorType:SQLOperatorGreaterThanEqualTo
                                                                andFieldValue:self.graceLimitDate];
    
    NSArray * purgeMapKey = [self.purgeMap allKeys];
    @autoreleasepool
    {
        for (NSString * objectName in purgeMapKey)
        {
            [SMDataPurgeHelper getAllGarceLimitRecrordsForModel:[self.purgeMap objectForKey:objectName] criteria:filterCriteria trialerCriteria:trailerFilterCrirteria];
        }
    }
}

- (void)fillNonGracePeriodTrailerTableRecords //To be purged
{
    
    DBCriteria *trailerCrirteria = [[DBCriteria alloc]initWithFieldName:@"timeStamp"
                                                           operatorType:SQLOperatorLessThan
                                                          andFieldValue:self.graceLimitDate];
    
    NSArray * purgeMapKey = [self.purgeMap allKeys];
    @autoreleasepool
    {
        for (NSString * objectName in purgeMapKey)
        {
            [SMDataPurgeHelper getNonGracePeriodTrailerTableRecords:[self.purgeMap objectForKey:objectName]
                                                    trailerCriteria:trailerCrirteria];
        }
    }
}

- (void)fillNonPurgeableDODRecords
{
    NSArray * purgeMapKey = [self.purgeMap allKeys];
    DBCriteria *filterCriteria = [[DBCriteria alloc]initWithFieldName:@"timeStamp"
                                                         operatorType:SQLOperatorGreaterThanEqualTo
                                                        andFieldValue:self.graceLimitDate];
    @autoreleasepool
    {
        for (NSString * objectName in purgeMapKey)
        {
            [SMDataPurgeHelper getAllGarceDODRecrds:[self.purgeMap objectForKey:objectName]
                                     filterCriteria:filterCriteria];
        }
    }
}


- (void)fillPurgeableDODRecords
{
    NSArray * purgeMapKey = [self.purgeMap allKeys];
    
    DBCriteria *filterCriteria = [[DBCriteria alloc]initWithFieldName:@"timeStamp"
                                                         operatorType:SQLOperatorLessThan
                                                        andFieldValue:self.graceLimitDate];
        @autoreleasepool
    {
        for (NSString * objectName in purgeMapKey)
        {
            [SMDataPurgeHelper getAllNonGraceDODRecrds:[self.purgeMap objectForKey:objectName]
                                        filterCriteria:filterCriteria];
        }
    }
}


- (void)fillEventRelatedDataForPurgeMap
{
    NSMutableDictionary * eventDictionary = [self getAllEventRealtedObjectWithIds];
    @autoreleasepool
    {
        NSArray * allKeys = [eventDictionary allKeys];
        
        for (NSString * objectName in allKeys)
        {
            SMDataPurgeModel * purgeModel = [self getPurgeModelForObjectName:objectName];
            
            if (purgeModel != nil)
            {
                NSMutableArray * ids = [eventDictionary objectForKey:objectName];
                
                //Assuming always whatId of the evnet will be SFID
                for (NSString * whatId in ids)
                {
                    [purgeModel addEventsRelatedRecord:whatId];
                }
                [self fillEventRelatedChildLine:purgeModel.purgeableReferenceObjects
                                      parentIds:ids
                                     parentName:objectName];
            }
        }
    }
}


- (NSMutableDictionary *)getAllEventRealtedObjectWithIds
{
    NSMutableArray * eventIds = [SMDataPurgeHelper getAllEventRelatedWhatId];
    
    NSMutableDictionary * eventDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    @autoreleasepool
    {
        for (NSString * whatId in eventIds)
        {
            NSString * keyPrefix = @"";
            if ([whatId length] > 3)
            {
                keyPrefix = [whatId substringToIndex:3];
            }
            NSString * objectName = [self.keyPrefixObjectName valueForKey:keyPrefix];
            
            NSMutableArray * array = [eventDict objectForKey:objectName];
            
            if ((array != nil) && [array count] > 0)
            {
                [array addObject:whatId];
            }
            else
            {
                array = [[NSMutableArray alloc] initWithCapacity:0];
                [array addObject:whatId];
                [eventDict setObject:array forKey:objectName];
            }
            
        }
    }
    return eventDict;
}


- (void)fillEventRelatedChildLine:(NSMutableArray *)childObjects parentIds:(NSMutableArray *)Ids parentName:(NSString *)parentObject
{
    @autoreleasepool
    {
        for (SMObjectRelationModel * relationModel in childObjects)
        {
            if (relationModel != nil)
            {
                SMDataPurgeModel * purgeModel = [self getPurgeModelForObjectName:relationModel.childName];
                
                if (purgeModel != nil && purgeModel.isPurgeable)
                {
                    NSMutableArray * childIds = [SMDataPurgeHelper getAllChildIdsForObject:relationModel
                                                                                  parentId:Ids
                                                                                parentName:parentObject];
                    
                    for (NSString * recordId in childIds)
                    {
                        [purgeModel addChildRecordsOfEvents:recordId];
                    }
                }
            }
        }
    }
}


- (NSMutableDictionary *)getProgressBarDetails
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    switch (self.purgeStatus)
    {
        case DataPurgeStatusWSForLastModifiedDate:
        {
            [dict setValue:[NSString stringWithFormat:@"%d%%", percentage] forKey:@"percentage"];
            [dict setValue:[NSString stringWithFormat:@"%f", progress] forKey:@"progress"];
            [dict setValue:[[TagManager sharedInstance] tagByName:kTagDpProgressConfigWs] forKey:@"subtitle"];
            [dict setValue:[[TagManager sharedInstance] tagByName:kTagDpProgressConfigData] forKey:@"subtitle1"];
            break;
        }
            
        case DataPurgeStatusWSForDownloadCriteria:
        {
            [dict setValue:[NSString stringWithFormat:@"%d%%", percentage*5] forKey:@"percentage"];
            [dict setValue:[NSString stringWithFormat:@"%f", progress*5] forKey:@"progress"];
            [dict setValue:[[TagManager sharedInstance] tagByName:kTagDpProgressDataBasevalidate] forKey:@"subtitle"];
            [dict setValue:[[TagManager sharedInstance] tagByName:kTagDpProgressDc] forKey:@"subtitle1"];
            
            break;
        }
            
        case DataPurgeStatusWSForAdvancedDownloadCriteria:
        {
            [dict setValue:[NSString stringWithFormat:@"%d%%", percentage*8] forKey:@"percentage"];
            [dict setValue:[NSString stringWithFormat:@"%f", progress*8] forKey:@"progress"];
            [dict setValue:[[TagManager sharedInstance] tagByName:kTagDpProgressDataBasevalidate] forKey:@"subtitle"];
            [dict setValue:[[TagManager sharedInstance] tagByName:kTagDpProgressAdc] forKey:@"subtitle1"];
            
            break;
        }
        case DataPurgeStatusWSForGetPrice:
        {
            [dict setValue:[NSString stringWithFormat:@"%d%%", percentage*12] forKey:@"percentage"];
            [dict setValue:[NSString stringWithFormat:@"%f", progress*12] forKey:@"progress"];
            [dict setValue:[[TagManager sharedInstance] tagByName:kTagDpProgressDataBasevalidate] forKey:@"subtitle"];
            [dict setValue:[[TagManager sharedInstance] tagByName:kTagDpProgressPriceData] forKey:@"subtitle1"];
            
            break;
        }
            
        case DataPurgeStatusRequiredConfigUpdate:
        {
            [dict setValue:[NSString stringWithFormat:@"%d%%", percentage] forKey:@"percentage"];
            [dict setValue:[NSString stringWithFormat:@"%f", progress] forKey:@"progress"];
            [dict setValue:[[TagManager sharedInstance] tagByName:kTagDpProgressConfigWs] forKey:@"subtitle"];
            [dict setValue:[[TagManager sharedInstance] tagByName:kTagDpProgressConfigOutOfData] forKey:@"subtitle1"];
            [self showConfigSyncUpdateAlert];
            
            break;
        }
            
        case DataPurgeStatusDataProcessing:
        {
            [dict setValue:[NSString stringWithFormat:@"%d%%", percentage * 16] forKey:@"percentage"];
            [dict setValue:[NSString stringWithFormat:@"%f", progress*16] forKey:@"progress"];
            [dict setValue:[[TagManager sharedInstance] tagByName:kTagDpProgressDataBaseCleanUp] forKey:@"subtitle"];
            [dict setValue:[[TagManager sharedInstance] tagByName:kTagDpProgressGetData] forKey:@"subtitle1"];
            break;
        }
            
        case DataPurgeStatusCompleted:
        {
            [SMDataPurgeHelper clearDataPurgeTableContents];
            [dict setValue:[NSString stringWithFormat:@"%d%%", percentage * 20] forKey:@"percentage"];
            [dict setValue:[NSString stringWithFormat:@"%f", progress*20] forKey:@"progress"];
            [dict setValue:[[TagManager sharedInstance] tagByName:kTagDpProgressDataBaseCleanUp] forKey:@"subtitle"];
            [dict setValue:[[TagManager sharedInstance] tagByName:kTagDpProgressRemoveData] forKey:@"subtitle1"];
            break;
        }
            
        default:
            break;
    }
    
    return dict;
}


- (void)showConfigSyncUpdateAlert
{
    NSString * title    = [[TagManager sharedInstance]tagByName:kTagAlertTitleError];
    NSString * cancel   = [[TagManager sharedInstance]tagByName:kTagAlertErrorOk];
    NSString * message  = [[TagManager sharedInstance]tagByName:kTagDpProgressConfigOutOfData];
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:nil, nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self postNotificationToRemoveProgressBar];
        self.purgeStatus = DataPurgeStatusCompleted;
    }
}

- (void) postNotificationToUpdateProgressBar
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDataPurgeProgressBar object:nil userInfo:nil];
}


- (void) postNotificationToRemoveProgressBar
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDataPurgeCompletedOrFailed object:nil userInfo:nil];
    [self postDataPurgeCompletedNotification];
}


- (void) postNotificationToDisableCancelButton
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDataPurgeDisableCancelButton object:nil userInfo:nil];
}


- (void)updateGraceLimitDate
{
    NSDate * currentDateTime = [NSDate date];
    
    NSString * criteria = [SMDataPurgeHelper getDataPurgeRecordOlderThanSettingsValue];
    
    int value = [criteria intValue];
    
    if (value <= 0)
    {
        value = 1;
    }
    
    NSDate * olderThen = [currentDateTime dateByAddingTimeInterval:(-value * 24 * 60 * 60)];
    NSString * date = [DateUtil getDatabaseStringForDate:olderThen];
    if (date != nil || [date length] > 0)
    {
//        date = [date stringByReplacingCharactersInRange:NSMakeRange(10, 1) withString:@"T"];
//        date = [date stringByAppendingString:@".000+0000"];
        
        [self setGraceLimitDate:date];
    }
    else
    {
        [self setGraceLimitDate:@""];
    }
    
    SXLogDebug(@"GraceLimtDate = %@", self.graceLimitDate);
}


- (void)fillPurgeMapWithApiName
{
    if (self.purgeMap == nil)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        self.purgeMap = dict;
    }
    
    NSArray *allTransactionalObjects = [SMDataPurgeHelper getAllTransactionalObjectName];
    
    @autoreleasepool
    {
        if ((allTransactionalObjects != nil) && ([allTransactionalObjects count] > 0) )
        {
            for (NSString *apiName in allTransactionalObjects)
            {
                SMDataPurgeModel *model = [self.purgeMap objectForKey:apiName];
                
                if (model == nil)
                {
                    model = [[SMDataPurgeModel alloc] initWithName:apiName];
                    [self validateRecordCountForModel:model];
                    [self.purgeMap setObject:model forKey:apiName];
                }
            }
        }
    }
}


- (void)validateRecordCountForModel:(SMDataPurgeModel *)model
{
    BOOL hasRecord =  [SMDataPurgeHelper isEmptyTable:model.name];
    
    if (hasRecord)
    {
        // Should not belongs to Chatter, Event, LocationTracking, User, RecordType and Task
        if (   (! model.isChatterObject)
            && (! model.isEventObject)
            && (! model.isLocationTrackingObject)
            && (! model.isUserObject)
            && (! model.isRcordTypeObject)
            && (! model.isTaskObject)
            && (! model.isPriceBook)
            && (! model.isCodeSnippetObject)
            && (! model.isCodeSnippetManifestObject))
        {
            model.status = DPActionStatusAwaited;
        }
    }
    else
    {
        model.status = DPActionStatusNonPurgeableSinceDataUnavailable;
    }
}


- (void)fillChildrenAndRelatedRecordForPurgeMap
{
    NSArray *apiNames  = [self.purgeMap allKeys];
    
    for (NSString *apiName in apiNames)
    {
        SMDataPurgeModel *model = [self.purgeMap objectForKey:apiName];
        NSArray *relationModels = [SMDataPurgeHelper  findAndFillChildAndRelatedObjectForModel:model];
        
        BOOL isChild = NO;
        
        for (SMObjectRelationModel *relationModel in relationModels)
        {
            // Is Child/related Object already exist in Local DB ?
            
            SMDataPurgeModel *existPurgeModel = [self.purgeMap objectForKey:relationModel.childName];
            if (existPurgeModel != nil)
            {
                // table should have some records, then consider
                if (!existPurgeModel.isEmptyTable)
                {
                    if ([existPurgeModel shouldPurgeWithParent])
                    {
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
                        if ([relationModel.parentName length] > 0 && [relationModel.childFieldName length] > 0)
                        {
                            [dict setObject:relationModel.childFieldName forKey:relationModel.parentName];
                        }
                        [existPurgeModel addParentObjectNames:dict];
                    }
                    
                    if (isChild)
                    {
                        [model addPurgeableChild:relationModel];
                    }
                    else
                    {
                        [model addPurgeableReferenceObject:relationModel];
                    }
                }
            }
        }
        
        // For safe we are adding back :)
        [self.purgeMap setObject:model forKey:apiName];
    }
}


- (void)invalidateAndScheduleTimer:(NSNumber *)interval
{
    NSTimeInterval timeInterval = [interval doubleValue];
    [self invalidateDataPurgeTimer];
    [self scheduleDataPurgeTimer:timeInterval];
    
}

- (void)scheduleDataPurgeTimer:(NSTimeInterval)interval
{
    if(![self.dataPurgeTimer isValid])
    {
        [[SMLocalNotificationManager sharedInstance]scheduleLocalNotificationOfType:SMLocalNotificationTypePurgeDataDue on:[NSDate dateWithTimeIntervalSinceNow:interval]];
        self.dataPurgeTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(scheduleDataPurge) userInfo:nil repeats:NO];
    }
}


- (void)invalidateDataPurgeTimer
{
    if ([self.dataPurgeTimer isValid])
    {
        [[SMLocalNotificationManager sharedInstance]cancelNotificationOfType:SMLocalNotificationTypePurgeDataDue];
        [self.dataPurgeTimer invalidate];
        self.dataPurgeTimer = nil;
    }
}


- (void)setLastDataPurgeTime;
{
    if (self.purgeStatus == DataPurgeStatusCompleted && [self isdataPurgeSuccess])
    {
        [SMDataPurgeHelper saveDataPurgeTimeSinceCompleted];
    }
}


- (void)updateNextDataPurgeTime:(NSDate *)date
{
    if (date != nil)
    {
        if ([[SMDataPurgeManager sharedInstance] isDataPurgeScheduled])
            [SMDataPurgeHelper updateNextDataPurgeTime:date];
    }
    
}


- (void)updateTimerAndNextDPTime:(NSDate *)date
{
    SXLogDebug(@"DP date = %@", date);
    NSDate * dataPurgeTime = [SMDataPurgeHelper retrieveNextDPTime];
    
    if (dataPurgeTime != nil)
    {
        if (self.isScheduledPurging)
        {
            //one method
            [self setTimer:date];
        }
        else
        {
            NSComparisonResult result = [date compare:dataPurgeTime];
            if (result == NSOrderedAscending)
            {
                NSTimeInterval interval = [date timeIntervalSinceDate:dataPurgeTime];
                SXLogDebug(@"interval = %f", interval);
                if (interval < 0)
                {
                    interval = -(interval);
                }
                [self performSelectorOnMainThread:@selector(invalidateAndScheduleTimer:) withObject:[NSNumber numberWithFloat:interval] waitUntilDone:YES];
            }
            else if (result == (NSOrderedDescending || NSOrderedSame))
            {
                [self setTimer:date];
            }
        }
    }
}


-(void)setTimer:(NSDate *)date
{
    NSDate * dataPurgeTime = [SMDataPurgeHelper retrieveNextDPTime];
    
    NSTimeInterval interval = 0;
    NSTimeInterval scheduleTimeInterval = [SMDataPurgeHelper getTimerIntervalForDataPurge];
    
    NSDate * nextDPTime = dataPurgeTime;
    do
    {
        nextDPTime = [NSDate dateWithTimeInterval:scheduleTimeInterval sinceDate:nextDPTime];
    }
    while ([nextDPTime compare:date] == ( NSOrderedAscending));
    
    SXLogDebug(@"NextDPTime %@", nextDPTime);
    interval = [date timeIntervalSinceDate:nextDPTime];
    [self updateNextDataPurgeTime:nextDPTime];
    nextDPTime = nil;
    if (interval < 0)
    {
        interval = -(interval);
    }
    [self performSelectorOnMainThread:@selector(invalidateAndScheduleTimer:) withObject:[NSNumber numberWithFloat:interval] waitUntilDone:YES];
}


-(void)updateTimerWhenAppLoggedIn:(NSDate *)date
{
    SXLogDebug(@" updateTimerWhenAppLoggedIn %@", date);
    NSDate * dataPurgeTime = [SMDataPurgeHelper retrieveNextDPTime];
    
    NSTimeInterval interval = 0;
    
    if (dataPurgeTime != nil)
    {
        NSComparisonResult result = [date compare:dataPurgeTime];
        if (result == NSOrderedAscending)
        {
            interval = [date timeIntervalSinceDate:dataPurgeTime];
            SXLogDebug(@"Data purge interval %f", interval);
            if (interval < 0)
            {
                interval = -(interval);
            }
            [self performSelectorOnMainThread:@selector(invalidateAndScheduleTimer:) withObject:[NSNumber numberWithFloat:interval] waitUntilDone:YES];
        }
        else if (result == (NSOrderedDescending || NSOrderedSame))
        {
            [self scheduleDataPurge];
        }
    }
}


//Method to handle data purge when any of the sync is failed
- (void) startWatchDogTimerWhenSyncInProgress
{
    [self invalidateSyncWatchDogTimer];
    if (![self.syncWatchDogTimer isValid])
    {
        self.syncWatchDogTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(checkSyncStaus) userInfo:nil repeats:YES];
    }
    
}


- (void) invalidateSyncWatchDogTimer
{
    if ([self.syncWatchDogTimer isValid])
    {
        [self.syncWatchDogTimer invalidate];
        self.syncWatchDogTimer = nil;
    }
}

- (void) checkSyncStaus
{
    if (![self isSyncGoingOn])
    {
        [self performSelectorOnMainThread:@selector(invalidateSyncWatchDogTimer) withObject:nil waitUntilDone:YES];
        
        if (self.isSyncInProgress)
        {
            [self restartDataPurge];
        }
    }
}


- (void) setSyncWatchDogTimerIfRequired
{
    if ([self isSyncGoingOn])
    {
        [self performSelectorOnMainThread:@selector(startWatchDogTimerWhenSyncInProgress) withObject:nil waitUntilDone:YES];
    }
}


- (BOOL) isSyncGoingOn
{
    BOOL syncGoingOn = NO;
    
    SyncManager *syncMan = [SyncManager sharedInstance];
    
    if ((![syncMan isConfigSyncInProgress]) &&
        (![syncMan isDataSyncInProgress]))
    {
        syncGoingOn = NO;
    }
    else
    {
        syncGoingOn = YES;
    }
    
    return syncGoingOn;
}


- (void)findAndFillChildObjectRecordForSave
{
    NSArray * purgeMapKey = [self.purgeMap allKeys];
    
    @autoreleasepool
    {
        for (NSString * objectName in purgeMapKey)
        {
            SMDataPurgeModel *purgeModel = [self.purgeMap objectForKey:objectName];
            
            if ( (purgeModel != nil) && ([purgeModel isPurgeable]))
            {
                NSArray *childRelations = [purgeModel purgeableChilds];
                
                @autoreleasepool
                {
                    for (SMObjectRelationModel *childRelation in childRelations)
                    {
                        NSMutableArray *savedChilds = [[NSMutableArray alloc] init];
                        
                        NSMutableDictionary *relationshipDictionary = [SMDataPurgeHelper relationshipKeyDictionaryForRelationshipModel:childRelation];
                        
                        NSSet *nonPurgeableSet = [purgeModel nonPurgeableRecordSet];
                        
                        if ( (nonPurgeableSet != nil) && ([nonPurgeableSet count] > 0))
                        {
                            for (NSString *recordId in nonPurgeableSet)
                            {
                                if ([relationshipDictionary count] == 0)
                                {
                                    // Does not have entry on relationship dictionary. Lets break it!
                                    break;
                                }
                                
                                // Find and save non-purgeable Record from relation
                                if ([relationshipDictionary objectForKey:recordId] != nil)
                                {
                                    [savedChilds addObject:[relationshipDictionary objectForKey:recordId]];
                                }
                            }
                            
                        }
                        
                        SMDataPurgeModel *childPurgeModel = [self.purgeMap objectForKey:childRelation.childName];
                        
                        @autoreleasepool
                        {
                            if (childPurgeModel != nil)
                            {
                                if ([savedChilds count] > 0)
                                {
                                    for (NSString *childRecordId in savedChilds)
                                    {
                                        [childPurgeModel addNonPurgeableRecordIdsAsAChilds:childRecordId];
                                    }
                                    [self.purgeMap setObject:childPurgeModel forKey:childPurgeModel.name];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


- (void)findAndFillReferenceObjectRecordForSave
{
    NSArray * purgeMapKey = [self.purgeMap allKeys];
    
    @autoreleasepool
    {
        for (NSString * objectName in purgeMapKey)
        {
            SMDataPurgeModel *purgeModel = [self.purgeMap objectForKey:objectName];
            
            if ( (purgeModel != nil) && ([purgeModel isPurgeable]))
            {
                NSArray *referenceRelations = [purgeModel purgeableReferenceObjects];
                
                @autoreleasepool
                {
                    for (SMObjectRelationModel *childRelation in referenceRelations)
                    {
                        NSMutableArray *savedRelations = [[NSMutableArray alloc] init];
                        
                        NSMutableDictionary *relationshipDictionary = [SMDataPurgeHelper relationshipKeyDictionaryForRelationshipModel:childRelation];
                        
                        NSSet *nonPurgeableSet = [purgeModel nonPurgeableRecordSet];
                        
                        if ( (nonPurgeableSet != nil) && ([nonPurgeableSet count] > 0))
                        {
                            for (NSString *recordId in nonPurgeableSet)
                            {
                                if ([relationshipDictionary count] == 0)
                                {
                                    // Does not have entry on relationship dictionary. Lets break it!
                                    break;
                                }
                                
                                // Find and remove non-purgeable Record from relation
                                if ([relationshipDictionary objectForKey:recordId] != nil)
                                {
                                    [savedRelations addObjectsFromArray:[relationshipDictionary objectForKey:recordId]]; //10181
                                }
                            }
                        }
                        
                        SMDataPurgeModel *childPurgeModel = [self.purgeMap objectForKey:childRelation.childName];
                        
                        @autoreleasepool
                        {
                            if (childPurgeModel != nil)
                            {
                                if ([savedRelations count] > 0)
                                {
                                    for (NSString *relationRecordId in savedRelations)
                                    {
                                        [childPurgeModel addNonPurgeableRecordIdsAsARelatedTable:relationRecordId];
                                    }
                                    [self.purgeMap setObject:childPurgeModel forKey:childPurgeModel.name];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


- (void)seggregateNonPurgeableRecords:(BOOL)isFinal
{
    NSArray * purgeMapKey = [self.purgeMap allKeys];
    
    @autoreleasepool
    {
        for (NSString * objectName in purgeMapKey)
        {
            SMDataPurgeModel *purgeModel = [self.purgeMap objectForKey:objectName];
            if (isFinal)
            {
                [purgeModel doFinalAggregationForNonPurgeableRecords];
            }
            else
            {
                [purgeModel aggregateNonPurgeableRecords];
            }
            
            [self.purgeMap setObject:purgeModel forKey:purgeModel.name];
        }
    }
}
#pragma mark - Webservice triggering methods
- (void)makeRequestToserverForTheCategoryType:(CategoryType)categoryType
{
    if ([Reachability connectivityStatus])
    {
        TaskModel *taskModel = [TaskGenerator generateTaskFor:categoryType
                                                 requestParam:nil
                                               callerDelegate:[SMDataPurgeManager sharedInstance]];
        self.dataPurgeTaskID = taskModel.taskId;
        [[TaskManager sharedInstance] addTask:taskModel];
    }
    else
    {
        UIAlertView * _alert = [[UIAlertView alloc] initWithTitle:@"Network Issue" message:@"Connection is not working" delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles:nil];
        [_alert show];
    }
}

#pragma mark - End
#pragma mark - Flow status delegate methods
- (void)flowStatus:(id)status
{
    if([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *st = (WebserviceResponseStatus*)status;
        switch (st.category)
        {
            case CategoryTypeDataPurgeFrequency:
            {
                if (st.syncStatus == SyncStatusSuccess)
                {
                    BOOL result = [self isConfigSyncToBeDone:self.responseLastConfigTime];
                    if (result)
                    {
                        if (![self isRescheduled])
                        {
                            self.purgeStatus = DataPurgeStatusRequiredConfigUpdate;
                        }
                        /* using consatnt value for Data purge status */
                        [SMDataPurgeHelper saveDataPurgeStatusSinceCompleted:kFailed];
                        [self manageDataPurge];
                        //DefectFix:26563
                        SyncManager *syncManager = [SyncManager sharedInstance];
                        [syncManager updateDataPurgeStatus:SyncStatusSuccess];
                    }
                    else
                    {
                        [self manageDataPurge];
                    }

                }
                else if ((st.syncStatus == SyncStatusFailed)
                         || (st.syncStatus == SyncStatusRefreshTokenFailedWithError)
                         || (st.syncStatus == SyncStatusNetworkError))
                {
                    [self dataPurgeWebserviceFailedWithError:st.syncError];
                }
                    
            }
            break;
            case CategoryTypeDataPurge:
            {
                if (st.syncStatus == SyncStatusSuccess)
                {
                    //DefectFix:26563
                    SyncManager *syncManager = [SyncManager sharedInstance];
                    [syncManager updateDataPurgeStatus:SyncStatusSuccess];
                    
                    [self manageDataPurge];
                }
                else if ((st.syncStatus == SyncStatusFailed)
                         || (st.syncStatus == SyncStatusRefreshTokenFailedWithError)
                         || (st.syncStatus == SyncStatusNetworkError))
                {
                    [self dataPurgeWebserviceFailedWithError:st.syncError];
                }
                
            }
                break;
            default:
                break;
        }
    }
}

- (void)dataPurgeWebserviceFailedWithError:(NSError *)error {
    
    //DefectFix:26563
    SyncManager *syncManager = [SyncManager sharedInstance];
    [syncManager updateDataPurgeStatus:SyncStatusFailed];
    
    if (![self isRescheduled])
    {
        self.purgeStatus = DataPurgeStatusFailed;
    }
    
    /* using consatnt value for Data purge status */
    [SMDataPurgeHelper saveDataPurgeStatusSinceCompleted:kFailed];
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        SXLogDebug(@"failedWithError - Calling updateDataPurgeTimeAndCleanUpManager");
        
        [[AlertMessageHandler sharedInstance] showCustomMessage:[error errorEndUserMessage]
                                                   withDelegate:nil
                                                            tag:999
                                                          title:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage]
                                              cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]
                                           andOtherButtonTitles:nil];
        
        [self updateDataPurgeTimeAndCleanUpManager];
        self.purgeStatus = DataPurgeStatusCompleted;
        [self postNotificationToRemoveProgressBar];
    });

}
#pragma mark - End


@end
