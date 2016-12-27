//
//  SyncManager.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 3/26/14.
//  Copyright (c) 2013 ServiceMax. All rights reserved.
//

#import "SyncManager.h"
#import "SyncScheduler.h"
#import "TaskManager.h"
#import "TaskModel.h"
#import "TaskGenerator.h"
#import "WebserviceResponseStatus.h"
#import "SyncProgressStatusHandler.h"
#import "DatabaseConfigurationManager.h"
#import "FileManager.h"
#import "PlistManager.h"
#import "ModifiedRecordsService.h"
#import "SVMXSystemUtility.h"
#import "DateUtil.h"
#import "TagManager.h"
#import "TagConstant.h"
#import "AlertMessageHandler.h"
#import "OAuthService.h"
#import "CacheManager.h"
#import "AppManager.h"
#import "LocationPingManager.h"
#import "DataMigrationHelper.h"
#import "DatabaseManager.h"
#import "SuccessiveSyncManager.h"
#import "TransactionObjectModel.h"
#import "CustomerOrgInfo.h"
#import "TXFetchHelper.h"
#import "NonTagConstant.h"
#import "FactoryDAO.h"
#import "MobileDeviceSettingDAO.h"
#import "ResolveConflictsHelper.h"
#import "SMLocalNotificationManager.h"
#import "PerformanceAnalyser.h"
#import "SNetworkReachabilityManager.h"
#import "SMDataPurgeManager.h"
#import "GetPriceManager.h"
#import "SFMPageHelper.h"
#import "CacheConstants.h"
#import "StringUtil.h"
#import "ProductIQManager.h"
#import "TransactionObjectService.h"
#import "SyncErrorConflictService.h"
#import "MobileDataUsageExecuter.h"
#import "SMAppDelegate.h"
#import "AutoLockManager.h"

const NSInteger alertViewTagForDataSync     = 888888;
const NSInteger alertViewTagForInitialSync  = 888890;
const NSInteger alertViewTagForProfileValidation  = 888891;
const NSInteger alertViewTagForInitialSyncRevokeToken = 888892;


NSString *kInitialSyncStatusNotification    = @"InitialSyncStatus";
NSString *kConfigSyncStatusNotification     = @"ConfigSyncStatus";
NSString *kDataSyncStatusNotification       = @"DataSyncStatus";
NSString *kEventSyncStatusNotification      = @"EventSyncStatus";
NSString *kProfileValidationStatusNotification = @"ProfileValidationStatus";
NSString *kUpdateEventNotification = @"UpdateEventOnNotification";
NSString *kUpadteWebserviceData             = @"customActionWebServiceNotification";
NSString *KBlockScreenForProductIQ          = @"BlockScreenForProductIQ";

NSString *kSyncTimeUpdateNotification       = @"UpdateSyncTime";
NSString *kScheduledConfigSyncNotification  = @"ScheduledConfigSyncNotf";

NSString *lastConfigSyncTimeKey             = @"Last Config sync time";
NSString *lastDataSyncTimeKey               = @"Last data sync time";

NSString *configSyncTimeIntervalKey         = @"Config sync time";
NSString *dataSyncTimeIntervalKey           = @"Data sync time";
NSString *syncMetaDataFile                  = @"SyncMetaData.plist";


//static dispatch_once_t _sharedSyncManagerInstanceGuard;
static SyncManager *_instance;
static const void * const kDispatchSyncReportQueueSpecificKey = &kDispatchSyncReportQueueSpecificKey;


@interface SyncManager ()<UIAlertViewDelegate>
{
     dispatch_queue_t    _queue;
}
@property (nonatomic, strong) SyncScheduler *configSyncScheduler;
@property (nonatomic, strong) SyncScheduler *dataSyncScheduler;

@property (nonatomic, assign) NSTimeInterval configSyncTimeInterval;
@property (nonatomic, assign) NSTimeInterval dataSyncTimeInterval;

@property (nonatomic, assign) SyncStatus initialSyncStatus;
@property (nonatomic, assign) SyncStatus configSyncStatus;
@property (nonatomic, assign) SyncStatus dataSyncStatus;
@property (nonatomic, assign) SyncStatus eventSyncStatus;

@property (nonatomic, strong) NSTimer  *dataSyncTimer;
@property (nonatomic, strong) NSTimer  *configSyncTimer;
@property (nonatomic, strong) NSMutableArray  *syncQueue;
@property (nonatomic, strong) ModifiedRecordModel *cCustomCallRecordModel;
//@property (nonatomic, strong) NSMutableArray *notSyncedDataArrayForCustomeCall;
@property (nonatomic) BOOL isBeforeUpdate;
@property (nonatomic) BOOL isAfterInsert;
@property (nonatomic) BOOL isAfterUpdate;

@property (nonatomic, assign) BOOL isDataSyncRunning;
@property (nonatomic) BOOL isDataSyncInLoop;

- (void)performInitialSync;
- (void)performConfigSync;
- (void)performDataSync;
- (void)performEventSync;

- (BOOL)cancelInitialSync;
- (BOOL)cancelConfigSync;
- (BOOL)cancelDataSync;
- (BOOL)cancelEventSync;

- (void)processSyncQueue;
- (void)manageSyncQueueProcess;

@end

@implementation SyncManager


#pragma mark - Sync Meta Data
- (NSString*)getSyncMetaDataFilePath
{
    NSString *appDirPath =[[FileManager getRootPath]stringByAppendingPathComponent:syncMetaDataFile];
    return appDirPath;
}

- (NSMutableDictionary*)getSyncMetaData
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[self getSyncMetaDataFilePath]];
    return dict;
}

- (void)updateSyncMetaDataWith:(NSMutableDictionary*)dict
{
    [dict writeToFile:[self getSyncMetaDataFilePath] atomically:NO];
}

- (void)updateLastConfigSyncTime:(NSDate*)date
{
    NSMutableDictionary *dict = [self getSyncMetaData];
    [dict setObject:date forKey:lastConfigSyncTimeKey];
    [self updateSyncMetaDataWith:dict];
}

- (void)updateLastDataSyncTime:(NSDate*)date
{
    NSMutableDictionary *dict = [self getSyncMetaData];
    [dict setObject:date forKey:lastDataSyncTimeKey];
    [self updateSyncMetaDataWith:dict];
}

- (void)updateConfigSyncTimeInterval:(NSTimeInterval)timeInterval
{
    NSMutableDictionary *dict = [self getSyncMetaData];
    [dict setObject:[NSNumber numberWithDouble:timeInterval] forKey:configSyncTimeIntervalKey];
    [self updateSyncMetaDataWith:dict];
}

- (void)updateDataSyncTimeInterval:(NSTimeInterval)timeInterval
{
    NSMutableDictionary *dict = [self getSyncMetaData];
    [dict setObject:[NSNumber numberWithDouble:timeInterval] forKey:dataSyncTimeIntervalKey];
    [self updateSyncMetaDataWith:dict];
}

- (NSDate*)getLastConfigSyncTime
{
    NSDictionary *dict = [self getSyncMetaData];
    return [dict objectForKey:lastConfigSyncTimeKey];
}

- (NSDate*)getLastDataSyncTime
{
    NSDictionary *dict = [self getSyncMetaData];
    return [dict objectForKey:lastDataSyncTimeKey];
}

- (NSTimeInterval)getConfigSyncTimeInterval
{
    NSMutableDictionary *dict = [self getSyncMetaData];
    
    // Temporary fix just for crash handling
    if([dict objectForKey:configSyncTimeIntervalKey] == nil)
    {
        [self updateConfigSyncTimeInterval:3600];
        dict = [self getSyncMetaData];
    }
    
    return [[dict objectForKey:configSyncTimeIntervalKey] doubleValue];
}

- (NSTimeInterval)getDataSyncTimeInterval
{
    NSMutableDictionary *dict = [self getSyncMetaData];
    
    // Temporary fix just for crash handling
    if([dict objectForKey:dataSyncTimeIntervalKey] == nil)
    {
        [self updateDataSyncTimeInterval:600];
        dict = [self getSyncMetaData];
    }

    return [[dict objectForKey:dataSyncTimeIntervalKey] doubleValue];
}

- (NSDate*)getNextConfigSyncTime
{
    NSDictionary *dict = [self getSyncMetaData];
    NSDate *dt = [dict objectForKey:lastConfigSyncTimeKey];
    return [dt dateByAddingTimeInterval:[self getConfigSyncTimeInterval]];
}

- (NSDate*)getNextDataSyncTime
{
    NSDictionary *dict = [self getSyncMetaData];
    NSDate *dt = [dict objectForKey:lastDataSyncTimeKey];
    return [dt dateByAddingTimeInterval:[self getDataSyncTimeInterval]];
}


#pragma mark - Scheduler delegate method and its helpers

- (void)sync:(SyncType)sync firedAt:(NSDate*)date
{
    switch (sync) {
        case SyncTypeConfig:
            [self updateLastConfigSyncTime:date];
            break;
        case SyncTypeData:
            [self updateLastDataSyncTime:date];
            break;
        case SyncTypeEvent:
            break;
        default:
            break;
    }
}

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
    self.initialSyncStatus = SyncStatusCompleted;
    self.configSyncStatus = SyncStatusCompleted;
    self.dataSyncStatus = SyncStatusCompleted;
    _queue = dispatch_queue_create([[NSString stringWithFormat:@"syncreport.%@", self] UTF8String], NULL);
    dispatch_queue_set_specific(_queue, kDispatchSyncReportQueueSpecificKey, (__bridge void *)self, NULL);
    

    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
    if (_queue) {
        _queue = nil;
        _queue = 0x00;
    }
}

#pragma mark - Class Methods

- (void)performSyncWithType:(SyncType)syncType
{
    switch (syncType) {
            
        case SyncTypeInitial:
            
            if ([self isDataSyncInProgress])
            {
                self.initialSyncStatus = SyncStatusInQueue;
                [self enqueueSyncQueue:SyncTypeInitial];
            }
            else
            {
                [self performInitialSync];
            }
            break;
            
        case SyncTypeConfig:
            
            if ([self isDataSyncInProgress])
            {
                self.configSyncStatus = SyncStatusInQueue;
                [self enqueueSyncQueue:SyncTypeConfig];
            }
            else
            {
                [self performConfigSync];
            }
            break;
            
        case SyncTypeData:{
            
                if (![self isDataSyncInProgress])
                {
                    if([[SMDataPurgeManager sharedInstance] isDataPurgeInProgress])
                    {
                        self.dataSyncStatus = SyncStatusInQueue;
                        [self enqueueSyncQueue:SyncTypeData];
                    }
                    
                    else
                    {
                        [self performDataSync];
                        
                        if (self.isGetPriceCallEnabled)
                        {
                            self.isGetPriceCallEnabled = NO;
                            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGetPriceNotification:) name:@"DoGetPrice" object:nil];
                        }
                        
                        if([[ProductIQManager sharedInstance] isProductIQSettingEnable]) {
                            [self performSelectorInBackground:@selector(initiateProdIQDataSync) withObject:nil];
                        }
                        
                    }
                    
                }
            else//HS 16June Defect Fix:020834
            {
                BOOL conflictResolved = [ResolveConflictsHelper checkResolvedConflicts];
                
            }//HS 16June
            }
            break;
            
        case SyncTypeEvent:
            [self performEventSync];
            break;
            
        case SyncTypeValidateProfile:
            if ([self isDataSyncInProgress])
            {
                self.configSyncStatus = SyncStatusInQueue;
                [self enqueueSyncQueue:SyncTypeValidateProfile];
            }
            else
            {
                [self performValidateProfile];
            }

            
           
            break;
            
        default:
            break;
    }
}
- (void)handleGetPriceNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DoGetPrice" object:nil];

    
    [self performSelectorInBackground:@selector(initiateGetPriceInBackGround) withObject:nil];
    
}
- (void)initiateGetPriceInBackGround
{
   [[GetPriceManager sharedInstance] intiateGetPriceSync];
}

- (void)cancelGetPriceInBackGround
{
    [[GetPriceManager sharedInstance] cancelGetPriceSync];
}


- (void)cancelSyncForType:(SyncType)syncType
{
    switch (syncType) {
            
        case SyncTypeInitial:
            [self cancelInitialSync];
            break;
            
        case SyncTypeConfig:
            [self cancelConfigSync];
            break;
            
        case SyncTypeData:
            [self cancelDataSync];
            break;
            
        case SyncTypeEvent:
            [self cancelEventSync];
            break;
            
        default:
            break;
    }
}


- (NSDate*)getLastSyncTimeFor:(SyncType)syncType
{
    NSDate *returnVal = nil;
    switch (syncType) {
            
        case SyncTypeConfig:
            returnVal = [self getLastConfigSyncTime];
            break;
            
        case SyncTypeData:
            returnVal = [self getLastConfigSyncTime];
            break;
            
        default:
            break;
    }
    
    return returnVal;
}


- (NSDate*)getNextSyncTimeFor:(SyncType)syncType
{
    NSDate *returnVal = nil;
    switch (syncType)
    {
        case SyncTypeConfig:
            returnVal = [self getNextConfigSyncTime];
            break;
            
        case SyncTypeData:
            returnVal = [self getNextDataSyncTime];
            break;
            
        default:
            break;
    }
    return returnVal;
}


- (SyncStatus)getSyncStatusFor:(SyncType)syncType
{
    SyncStatus returnVal = SyncStatusInQueue;
 
    switch (syncType) {
            
        case SyncTypeInitial:
            returnVal = self.initialSyncStatus;
            break;
            
        case SyncTypeConfig:
            returnVal = self.configSyncStatus;
            break;
            
        case SyncTypeData:
            returnVal = self.dataSyncStatus;
            break;
            
        case SyncTypeEvent:
            returnVal = self.eventSyncStatus;
            break;
            
        default:
            break;
    }
    
    return returnVal;
}


#pragma mark - Private methods - internally used

- (void)performInitialSync
{
    [self performSelectorInBackground:@selector(cancelGetPriceInBackGround) withObject:nil];
    [self performSelectorInBackground:@selector(cancelProdIQDataSync) withObject:nil];
    
    [self enableAllParallelSync:NO];
    self.initialSyncStatus = SyncStatusInProgress;
    [self prepareDatabaseForInitialSync];
    [SMDataPurgeHelper startedConfigSyncTime];
    [self setSyncProgressFlag];
    
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeOneCallRestInitialSync
                                             requestParam:nil
                                           callerDelegate:self];
    [self setUpRequestIdForSyncProfiling:taskModel.taskId];
    [[TaskManager sharedInstance] addTask:taskModel];
}

- (void)performResetApp
{
    [self performSelectorInBackground:@selector(cancelGetPriceInBackGround) withObject:nil];
    [self performSelectorInBackground:@selector(cancelProdIQDataSync) withObject:nil];

    [self prepareDatabaseForInitialSync];
    [SMDataPurgeHelper startedConfigSyncTime];
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeResetApp requestParam:nil callerDelegate:self];
    [[TaskManager sharedInstance] addTask:taskModel];
}

- (void)performConfigSync
{
    [self performSelectorInBackground:@selector(cancelGetPriceInBackGround) withObject:nil];
    [self performSelectorInBackground:@selector(cancelProdIQDataSync) withObject:nil];

    self.configSyncStatus = SyncStatusInProgress;
    [SMDataPurgeHelper startedConfigSyncTime];
    [self enableAllParallelSync:NO];
    [self performDBBackUp];
    [FileManager recopyStaticResourcesFromBundle]; // 27690
    [self setSyncProgressFlag];
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeIncrementalOneCallMetaSync
                                             requestParam:nil
                                           callerDelegate:self];
    [self setUpRequestIdForSyncProfiling:taskModel.taskId];
    [[TaskManager sharedInstance] addTask:taskModel];
}

- (void)performDataSync
{
    
    [self initiateCustomDataSync];
   // [self initiateDataSync];
}

- (void)performEventSync
{
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeEventSync requestParam:nil callerDelegate:self];
    [[TaskManager sharedInstance] addTask:taskModel];
}

- (void)performValidateProfile
{
    [self enableAllParallelSync:NO];
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeValidateProfile
                                             requestParam:nil
                                           callerDelegate:self];
    
    [[TaskManager sharedInstance] addTask:taskModel];
}

- (BOOL)cancelInitialSync
{
    return NO;
}

- (BOOL)cancelConfigSync
{
    return NO;
}

- (BOOL)cancelDataSync
{
    return NO;
}

- (BOOL)cancelEventSync
{
    return NO;
}

#pragma mark - Scheduler
- (void)fireScheduleTimer
{
    // TODO : Get the time interval from the configuration
    self.configSyncTimeInterval = [self getConfigSyncTimeInterval]; // 3600;
    self.dataSyncTimeInterval = [self getDataSyncTimeInterval]; // 600;
    
    // Fire a timer
    if(self.configSyncScheduler == nil) // First time
    {
        self.configSyncScheduler = [[SyncScheduler alloc] init];
        [self.configSyncScheduler scheduleForSync:SyncTypeConfig
                                     withInterval:self.configSyncTimeInterval
                                      andDelegate:self];
    }
    else // If called after running config sync : time intervals are bound to change
    {
        [self.configSyncScheduler reScheduleWithTimeInterval:self.configSyncTimeInterval];
    }
    
    if (self.dataSyncScheduler == nil) // First time
    {
        self.dataSyncScheduler = [[SyncScheduler alloc] init];
        [self.dataSyncScheduler scheduleForSync:SyncTypeData
                                   withInterval:self.dataSyncTimeInterval
                                    andDelegate:self];
    }
    else // If called after running config sync : time intervals are bound to change
    {
        [self.dataSyncScheduler reScheduleWithTimeInterval:self.dataSyncTimeInterval];
    }
    
}

#pragma mark - Reset Sync MetaData
- (void)reset
{
    // Invalidate schedulers
    [self.configSyncScheduler invalidateScheduler];
    [self.dataSyncScheduler   invalidateScheduler];
    // Reset sync meta data
}

#pragma mark - Recieved Sync Respnse
- (void)recievedInitialSyncResponse:(WebserviceResponseStatus *)responseStatus
{
    self.initialSyncStatus = responseStatus.syncStatus;
    self.syncType = SyncTypeInitial;
    self.syncResponseStatus = responseStatus;
    
    if (responseStatus.syncStatus == SyncStatusSuccess)
    {
        SXLogDebug(@"Initial Sync Finished");
        [self executeSyncErrorReporting];
    }
    else  if ( (responseStatus.syncStatus == SyncStatusFailed) ||  (responseStatus.syncStatus == SyncStatusNetworkError))
    {
         SXLogDebug(@"Initial Sync Failed");
        if(responseStatus.syncError!=nil) {
            self.syncError=[responseStatus.syncError copy];
        }
        [self executeSyncErrorReporting];
    }

}


- (void)recievedDataSyncResponse:(WebserviceResponseStatus *)responseStatus
{
    self.dataSyncStatus = responseStatus.syncStatus;
    self.syncType = SyncTypeData;
    self.syncResponseStatus = responseStatus;
    
    if (responseStatus.syncStatus == SyncStatusSuccess)
    {
        SXLogDebug(@"Data Sync Finished");
        [self executeSyncErrorReporting];
    }
    else  if (   (responseStatus.syncStatus == SyncStatusFailed)
              || (responseStatus.syncStatus == SyncStatusRefreshTokenFailedWithError)
              || (responseStatus.syncStatus == SyncStatusNetworkError))
    {
        if(responseStatus.syncError!=nil) {
            self.syncError=[responseStatus.syncError copy];
        }
        SXLogDebug(@"Data Sync Failed");
        [self executeSyncErrorReporting];
    }
    SXLogDebug(@"Data Sync - %d", responseStatus.syncStatus);
}


- (void)recievedConfigSyncResponse:(WebserviceResponseStatus *)responseStatus
{
    self.configSyncStatus = responseStatus.syncStatus;
    self.syncResponseStatus = responseStatus;
    self.syncType = SyncTypeConfig;
   
    if (self.syncResponseStatus.syncStatus == SyncStatusSuccess)
    {
        SXLogDebug(@"Config Sync Finished");
        [self executeSyncErrorReporting];
    }
    else  if (self.syncResponseStatus.syncStatus == SyncStatusFailed ||  self.syncResponseStatus.syncStatus == SyncStatusNetworkError)
    {
        SXLogDebug(@"Config Sync Failed");
        if(responseStatus.syncError!=nil) {
            self.syncError=[responseStatus.syncError copy];
        }
        [self executeSyncErrorReporting];
    }
}



#pragma mark - Flow delegates

- (void)flowStatus:(id)status
{
    if ([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        NSString *notification = nil;
        
        WebserviceResponseStatus *wsResponseStatus = (WebserviceResponseStatus*)status;
        BOOL shouldNotify = YES;
        
        switch (wsResponseStatus.category) {
                
            case CategoryTypeOneCallRestInitialSync:
            case CategoryTypeInitialSync:
            {
                notification = kInitialSyncStatusNotification;
                [self recievedInitialSyncResponse:wsResponseStatus];
                if(wsResponseStatus.syncStatus == SyncStatusSuccess)
                {
                    shouldNotify = NO;
                }
                [self checkStatusForSyncProfiling:wsResponseStatus];
            }
                break;
                
            case CategoryTypeDataSync:
            case CategoryTypeOneCallDataSync:
            {
                notification = kDataSyncStatusNotification;
                shouldNotify = NO;
                [self recievedDataSyncResponse:wsResponseStatus];
            }
                break;
                
            case CategoryTypeEventSync:
                break;
                
            case CategoryTypeValidateProfile:
            {
                notification = kProfileValidationStatusNotification;
                if (   (wsResponseStatus.syncStatus == SyncStatusFailed)
                          || (wsResponseStatus.syncStatus == SyncStatusNetworkError) )
                {
                    [self profileValidationFailedWithError:wsResponseStatus.syncError];
                }
            }
                break;

    
                
            case CategoryTypeConfigSync:
            case CategoryTypeOneCallConfigSync:
            case CategoryTypeIncrementalOneCallMetaSync:
            {
                notification = kConfigSyncStatusNotification;
                [self recievedConfigSyncResponse:wsResponseStatus];
                if(wsResponseStatus.syncStatus == SyncStatusSuccess)
                {
                    shouldNotify = NO;
                }
                [self checkStatusForSyncProfiling:wsResponseStatus];
            }
                break;
            case CategoryTypeCustomWebServiceCall: //call for webservice
            {
                [self makeNextCallForCustomDataSyncWithResponse:wsResponseStatus];
                break;
            }
            case CategoryTypeCustomWebServiceAfterBeforeCall:
            {
                [self makeNextCallForCustomDataSyncWithResponse:wsResponseStatus];
                break;
            }
                
            default:
                break;
        }
        
        if (shouldNotify) {
            
            SyncProgressStatusHandler *syncProgressHandler = [[SyncProgressStatusHandler alloc] init];
            SyncProgressDetailModel   *syncProgressModel = [syncProgressHandler getProgressDetailsForStatus:status];
            
            syncProgressModel.syncError = wsResponseStatus.syncError;
            NSDictionary *syncStatus = nil;
            
            if (syncProgressModel != nil)
            {
                syncStatus = [NSDictionary dictionaryWithObject:syncProgressModel forKey:@"syncstatus"];
            }
            else
            {
                syncStatus = [NSDictionary dictionaryWithObject:@"In Progress" forKey:@"syncstatus"];
            }
            
            [self sendNotification:notification andUserInfo:syncStatus];
        }
    }
}

- (void)sendNotification:(NSString *)notificationName andUserInfo:(NSDictionary *)userInfo {
    
    NSMutableDictionary *notificationDict = [[NSMutableDictionary alloc] init];
    [notificationDict setValue:notificationName forKey:@"NotoficationName"];
    [notificationDict setValue:userInfo forKey:@"UserInfo"];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:userInfo];
    });
}

#pragma mark - RESET DATABASE BEFORE INITIAL SYNC

- (void)prepareDatabaseForInitialSync
{
     DatabaseManager *manager;
     manager = [DatabaseManager sharedInstance];
    [[DatabaseConfigurationManager sharedInstance] performDatabaseConfigurationForSwitchUser];
    [[DatabaseConfigurationManager sharedInstance] preInitialSyncDBPreparation];
    [[SMDataPurgeManager sharedInstance]invalidateAllDataPurgeProcess];
}

#pragma mark - Post Sync Completed Notification

- (void)postSyncTimeUpdateNotificationAfterSyncCompletion
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSyncTimeUpdateNotification object:nil];
}


#pragma mark - Data Sync Functions
- (BOOL)initiateDataSync {
    
    @synchronized([self class])
    {
        if (self.isDataSyncRunning)
        {
            self.isGetPriceCallEnabled = NO;
            SXLogInfo(@"Data sync is already running ");
            return NO;
        }
        else if (![self continueDataSyncIfConflictsResolved])
        {
            self.isGetPriceCallEnabled = NO;
            [self postSyncTimeUpdateNotificationAfterSyncCompletion];
            return NO;
        }
        else if ([self syncInProgress])
        {
            [self enqueueSyncQueue:SyncTypeData];
        }
        else
        {
            self.isDataSyncRunning = YES;
            self.dataSyncStatus = SyncStatusInProgress;
            [[SMDataPurgeManager sharedInstance]cancelDataPurgeSinceSyncInProgress];
            [PlistManager storeLastDataSyncStartGMTTime:[DateUtil getDatabaseStringForDate:[NSDate date]]];
            [PlistManager storeLastDataSyncStatus:kInProgress];
            [self performSelectorInBackground:@selector(initiateSyncInBackGround) withObject:nil];
            [self performSelectorInBackground:@selector(initiateSyncProfiling:) withObject:kSPTypeStart];
        }
        return YES;
    }
}


- (void)currentDataSyncfinished {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [AppManager updateTabBarBadges];
    });
        [[SuccessiveSyncManager sharedSuccessiveSyncManager] doSuccessiveSync];
        [self updateLastSyncTime];
        
        // if conflicts not resolved, then stop data sync..
        BOOL conflictsResolved = [self continueDataSyncIfConflictsResolved];
        
        BOOL didRestart = (conflictsResolved)?[self restartDataSyncIfNecessary]:NO;
        
        SXLogDebug(@"SS: didRestartSuccessiveSync: %d", didRestart);
        
        if (!didRestart) {
            
            [self updateSyncStatus];
            self.isDataSyncInLoop = NO;
            self.isDataSyncRunning = NO;
            self.dataSyncStatus = SyncStatusSuccess;
            
            [[SMDataPurgeManager sharedInstance] restartDataPurge];
            [PlistManager removeLastDataSyncStartGMTTime];
            [PlistManager removeLastLocalIdFromDefaults];
            
            //[self updatePlistWithLastDataSyncTimeAndStatus:kSuccess];
            /* Send data sync Success notification */
            [self sendNotification:kDataSyncStatusNotification andUserInfo:nil];
            
            [self initiateSyncProfiling:kSPTypeEnd];
            
            if (conflictsResolved) {
                /* Clear user deafults utility */
                
                [PlistManager clearAllWhatIdObjectInformation];
                
                if (![[OpDocHelper sharedManager] isTheOpDocSyncInProgress]) {
                    
                    [[OpDocHelper sharedManager] initiateFileSync];
                    [[OpDocHelper sharedManager] setCustomDelegate:self];
                }
            }
            
            [self manageSyncQueueProcess];
        }
    }


- (void)OpdocStatus:(BOOL)status forCategory:(CategoryType)category {
    
    [self updatePlistWithLastDataSyncTimeAndStatus:kSuccess];
    if (!status)
    {
        NSString *status = [[TagManager sharedInstance] tagByName:KTagFailed];
        [self updatePlistWithLastReportsSyncTimeAndStatus:status];
        SXLogDebug(@"OutPutDocument failed : %lu",(long)category );
    }
    else {
        NSString *status = [[TagManager sharedInstance] tagByName:KTagSuccess];
        [self updatePlistWithLastReportsSyncTimeAndStatus:status];
        SXLogDebug(@"OPDoc Success for category %lu",(long)category);
    }
    [self postSyncTimeUpdateNotificationAfterSyncCompletion];

}

- (void)currentDataSyncFailedWithError:(NSError *)error {
    
    @synchronized([self class]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [AppManager updateTabBarBadges];
        });
        
        [self updatePlistWithLastDataSyncTimeAndStatus:kFailed];
         self.isDataSyncRunning = NO;
         [PlistManager removeLastDataSyncStartGMTTime];
        [[SMDataPurgeManager sharedInstance] restartDataPurge];
        /* Send data sync Failure notification */
        [self sendNotification:kDataSyncStatusNotification andUserInfo:nil];
        
        [self checkIfRequestTimedOutForSyncProfiling:error];
        [self initiateSyncProfiling:kSPTypeEnd];
        
        if (error != nil) {
            [[AlertMessageHandler sharedInstance] showCustomMessage:[error errorEndUserMessage]
                                                       withDelegate:nil
                                                                tag:alertViewTagForDataSync
                                                              title:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage]
                                                  cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]
                                               andOtherButtonTitles:nil];
        }
         [self manageSyncQueueProcess];
    }
}

- (void)initiateSyncInBackGround {
    
    /* If conflict count is 0, then continue with Sync */
    
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeOneCallDataSync requestParam:nil callerDelegate:self];
    [self setUpRequestIdForSyncProfiling:taskModel.taskId];
    [[TaskManager sharedInstance] addTask:taskModel];
}

- (BOOL)restartDataSyncIfNecessary {
    
    @synchronized([self class]) {
        
        BOOL modifiedRecordsExist = [self checkIfModifiedRecordsExist];
        
        if (modifiedRecordsExist) {
            NSLog(@"Successsive sync: initiated");
            [self performSelectorInBackground:@selector(initiateSyncInBackGround) withObject:nil];
            return modifiedRecordsExist;
        }
        else {
            NSLog(@"No successive sync started");
        }
        return modifiedRecordsExist;
    }
}

- (void)updateLastSyncTime{
    
    @synchronized([self class]){
        
        [PlistManager moveDataSyncTimeFromTemp];
        
    }
}

- (void)updateSyncStatus {
    NSInteger conflictsCount = [ResolveConflictsHelper getConflictsCount];
    if (conflictsCount>0) {
        [self updatePlistWithLastDataSyncTimeAndStatus:kFailed];
    }
    else {
        [self updatePlistWithLastDataSyncTimeAndStatus:kSuccess];
    }
}

- (void)updatePlistWithLastDataSyncTimeAndStatus:(NSString *)status
{
    if (status)
    {
        NSString *someString = [DateUtil getDatabaseStringForDate:[NSDate date]];
        [PlistManager storeLastDataSyncGMTTime:someString];
        [PlistManager storeLastDataSyncStatus:status];
        
    }
}

- (void)updatePlistWithLastReportsSyncTimeAndStatus:(NSString*)status {
    
    if (status) {
        NSString *dateString = [DateUtil getDatabaseStringForDate:[NSDate date]];
        [PlistManager storeLastReportSyncGMTTime:dateString];
        [PlistManager storeLastReportSyncStatus:status];
    }
}

#pragma mark -End
#pragma mark - Config Sync Functions

- (void)currentConfigSyncFinished
{
    [PlistManager storeLastScheduledConfigSyncGMTTime:[DateUtil getDatabaseStringForDate:[NSDate date]]];
    [SMDataPurgeHelper saveConfigSyncTimeSinceSyncCompleted];
    [[SMDataPurgeManager sharedInstance] initiateAllDataPurgeProcess];
    [self enableAllParallelSync:YES];
    [self updatePlistWithLastConfigSyncTimeAndStatus:kSuccess];
    [self setSyncCompletionFlag];
    
    [self manageSyncQueueProcess];
    
    if ( (self.configSyncStatus == SyncStatusInProgress) || (self.configSyncStatus == SyncStatusInQueue))
    {
        self.configSyncStatus = SyncStatusCompleted;
    }
}

- (void)currentConfigSyncFailedWithError:(NSError *)error
{
    [self updatePlistWithLastConfigSyncTimeAndStatus:kFailed];
    [self manageSyncQueueProcess];
    
    if ( (self.configSyncStatus == SyncStatusInProgress) || (self.configSyncStatus == SyncStatusInQueue))
    {
        self.configSyncStatus = SyncStatusFailedWithError;
    }
}


#pragma mark End

#pragma mark - Frequency caclulation

- (NSInteger)configSyncFrequencyInSeconds
{
    NSInteger frequency = 0;
    id mobileSettingService = [FactoryDAO serviceByServiceType:ServiceTypeMobileDeviceSettings];
   
    if ([mobileSettingService conformsToProtocol:@protocol(MobileDeviceSettingDAO)]) {
        
       frequency = [mobileSettingService configurationSyncFrequency];
    }

    if (frequency > 0)
    {
        // Converting into minutes
        frequency = 60 * frequency;
    }
    
    return frequency;
}

- (NSInteger)dataSyncFrequencyInSeconds
{
    NSInteger frequency = 0;
    id mobileSettingService = [FactoryDAO serviceByServiceType:ServiceTypeMobileDeviceSettings];
    
    if ([mobileSettingService conformsToProtocol:@protocol(MobileDeviceSettingDAO)]) {
        
        frequency = [mobileSettingService dataSyncFrequency];
    }
    
    if (frequency > 0)
    {
        // Converting into minutes
        frequency = 60 * frequency;
    }
    
    return frequency;
}


- (NSDate *)nextScheduledSyncTimeByLastSyncTime:(NSString *)dateString andFrequency:(NSInteger)frequency
{
    if (frequency <= 0 )
    {
        return nil;
    }
    
    NSDate *scheduledTime = nil;

    if (dateString == nil)
    {
        return nil;
    }
    
    NSDate *lastDataSyncDate =  [DateUtil getDateFromDatabaseString:dateString];
    
    long lastDataSyncTimeSince1970 = [lastDataSyncDate timeIntervalSince1970];
    long currentDateSince1979 = [[NSDate date]timeIntervalSince1970];
    
    long timeDifference = currentDateSince1979 - lastDataSyncTimeSince1970;
    long timeDifferenceForNextSync = 0;
    
    timeDifferenceForNextSync = timeDifference % frequency;
    timeDifferenceForNextSync = frequency - timeDifferenceForNextSync;
    
    scheduledTime = [NSDate dateWithTimeIntervalSinceNow:timeDifferenceForNextSync];
    
    return scheduledTime;
}


- (NSDate *)dataSyncNextScheduledTime
{
    NSInteger frequency = [self dataSyncFrequencyInSeconds];
    
    NSString * dateString  = [PlistManager getLastScheduledConfigSyncGMTTime];
    
    NSDate *nextSyncTime = [self nextScheduledSyncTimeByLastSyncTime:dateString
                                                        andFrequency:frequency];
    
    SXLogDebug(@"NextSyncTime   : %@", nextSyncTime );
    
    return nextSyncTime;
}


- (NSDate *)configSyncNextScheduledTime
{
    NSInteger frequency = [self configSyncFrequencyInSeconds];
    
    NSString * dateString  = [PlistManager getLastScheduledConfigSyncGMTTime];
   
    NSDate *nextSyncTime = [self nextScheduledSyncTimeByLastSyncTime:dateString
                                                        andFrequency:frequency];
    SXLogDebug(@"NextSyncTime   : %@", nextSyncTime );
    
    return nextSyncTime;
}


- (void)showLocalNotification
{
    [self postSyncTimeUpdateNotificationAfterSyncCompletion];
    /*
     * Lets schedule next config sync notification.
     */
    NSDate *nextScheduledTime = [self configSyncNextScheduledTime];
    if (nextScheduledTime &&
        (!([nextScheduledTime compare:[NSDate date]] == NSOrderedAscending))) {
        
        [[SMLocalNotificationManager sharedInstance] scheduleLocalNotificationOfType:SMLocalNotificationTypeConfigSyncDue
                                                                                  on:nextScheduledTime];

    }
}
#pragma mark - Config Sync Local Notification methods.

- (void)resetConfigSyncLocalNotification
{
    /*
     * Cancels previous notifications and schedule new notification for next config sync due.
     */
    [self removeConfigSyncLocalNotification];
    NSDate *nextScheduledTime = [self configSyncNextScheduledTime];
    if (nextScheduledTime &&
        (!([nextScheduledTime compare:[NSDate date]] == NSOrderedAscending))) {
        
        [[SMLocalNotificationManager sharedInstance] scheduleLocalNotificationOfType:SMLocalNotificationTypeConfigSyncDue
                                                                                  on:nextScheduledTime];
        
    }
}


- (void)removeConfigSyncLocalNotification
{
    [[SMLocalNotificationManager sharedInstance] cancelNotificationOfType:SMLocalNotificationTypeConfigSyncDue];
}

#pragma mark - End

- (void)scheduleConfigSync
{
    NSDate *date = [self configSyncNextScheduledTime];
    NSInteger frequency = [self configSyncFrequencyInSeconds];
    
    SXLogDebug(@"Sch. Config Sync Time  %@   -- %ld", [date description], (long)frequency);
    
    if ((date != nil) && (frequency > 0))
    {
        if (self.configSyncTimer != nil)
        {
            [self.configSyncTimer invalidate];
        }
        
        NSTimer *syncTimer = [[NSTimer alloc] initWithFireDate:date
                                                      interval:frequency
                                                        target:self
                                                      selector:@selector(showLocalNotification)
                                                      userInfo:nil
                                                       repeats:YES];
        self.configSyncTimer = syncTimer;
        
        [[NSRunLoop currentRunLoop] addTimer:syncTimer forMode:NSDefaultRunLoopMode];
        /*
         * Lets configure first Local Notification.
         */
        [self resetConfigSyncLocalNotification];
    }
}


- (void)startScheduledDataSync
{
    if ([self syncInProgress])
    {
        return;
    }
    
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable] && ![[ AppManager sharedInstance] hasTokenRevoked])
    {
        self.isGetPriceCallEnabled = YES;
        [self performSyncWithType:SyncTypeData];
        [[LocationPingManager sharedInstance] triggerLocationWebservices];
        [self postSyncTimeUpdateNotificationAfterSyncCompletion];
    }
    else
    {
        [self updatePlistWithLastDataSyncTimeAndStatus:kFailed];
        NSString *status = [[TagManager sharedInstance] tagByName:KTagFailed];
        [self updatePlistWithLastReportsSyncTimeAndStatus:status];
        [self postSyncTimeUpdateNotificationAfterSyncCompletion];
    }
}

- (void)scheduleDataSync
{
    NSDate *date = [self dataSyncNextScheduledTime];
    NSInteger frequency = [self dataSyncFrequencyInSeconds];
    
    if ((date != nil) && (frequency > 0))
    {
        if (self.dataSyncTimer != nil)
        {
            [self.dataSyncTimer invalidate];
        }

        NSTimer *syncTimer = [[NSTimer alloc] initWithFireDate:date
                                                      interval:frequency
                                                        target:self
                                                      selector:@selector(startScheduledDataSync)
                                                      userInfo:nil
                                                       repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:syncTimer forMode:NSDefaultRunLoopMode];
        
        self.dataSyncTimer = syncTimer;
    }
}


- (void)invalidateScheduleSync
{
    SXLogDebug(@"=========== Invalidate Schedule Sync =======");
    [self performSelectorOnMainThread:@selector(invalidateScheduleSyncInMainThread) withObject:nil waitUntilDone:NO];
}


- (void)invalidateScheduleSyncInMainThread
{
    SXLogDebug(@"=========== MT:Invalidate Schedule Sync  =======");
    // Invalidate Data sync timer
    if (self.dataSyncTimer != nil)
    {
        [self.dataSyncTimer invalidate];
    }
    
    // Invalidate config sync timer
    if (self.configSyncTimer != nil)
    {
        [self.configSyncTimer invalidate];
    }
}


- (void)scheduleSync
{
    [self performSelectorOnMainThread:@selector(scheduleSyncInMainThread) withObject:nil waitUntilDone:NO];
    NSLog(@"=========== Schedule Sync in Main thread =======");
}


- (void)scheduleSyncInMainThread
{
    [self scheduleConfigSync];
    [self scheduleDataSync];
}


#pragma mark -End
#pragma mark - Initial Sync Functions

- (void)currentInitialSyncFinished
{
    [[AppManager sharedInstance] setApplicationStatus:ApplicationStatusInitialSyncCompleted];
    
    [self loadDataIntoInstalledBaseObject];
    
    [self updatePlistWithLastDataSyncTimeAndStatus:kSuccess];
    [self updatePlistWithLastConfigSyncTimeAndStatus:kSuccess];
    [[SMDataPurgeManager sharedInstance] initiateAllDataPurgeProcess];
    [PlistManager storeLastScheduledConfigSyncGMTTime:[DateUtil getDatabaseStringForDate:[NSDate date]]];
    [PlistManager storeLastScheduledDataSyncGMTTime:[DateUtil getDatabaseStringForDate:[NSDate date]]];
    [PlistManager storeLastResetAppOrInitialSyncGMTTime:[DateUtil getDatabaseStringForDate:[NSDate date]]];
    [SMDataPurgeHelper saveConfigSyncTimeSinceSyncCompleted];
    [self enableAllParallelSync:YES];
    
    if ( (self.initialSyncStatus == SyncStatusInProgress) || (self.initialSyncStatus == SyncStatusInQueue))
    {
        self.initialSyncStatus = SyncStatusCompleted;
    }
    
    [self manageSyncQueueProcess];
}


- (void)loadDataIntoInstalledBaseObject {
    
    [[ProductIQManager sharedInstance] loadDataIntoInstalledBaseObject];
}

- (void)currentInitialSyncFailedWithError:(NSError *)error
{
    // Yoo initial sync failed!! Lets remove incompleted data
    [[DatabaseConfigurationManager sharedInstance] performDatabaseConfigurationForSwitchUser];
    
    [[AppManager sharedInstance] setApplicationFailedStatus:ApplicationStatusInitialSyncFailed];
    
    [self updatePlistWithLastDataSyncTimeAndStatus:kFailed];
    [self updatePlistWithLastConfigSyncTimeAndStatus:kFailed];
    
    if (error != nil) {
        [self showSyncFailedForInitialSyncAlertViewForError:[error errorEndUserMessage]];
    }
    
    if ( (self.initialSyncStatus == SyncStatusInProgress) || (self.initialSyncStatus == SyncStatusInQueue))
    {
        self.initialSyncStatus = SyncStatusFailedWithError;
    }

    [self manageSyncQueueProcess];
}


- (void)showSyncFailedForInitialSyncAlertViewForError:(NSString *)message {
    //Remove all cached data for PA
    [[PerformanceAnalyser sharedInstance] clearAllData];
    
    if ([[AppManager sharedInstance] applicationStatus] == ApplicationStatusTokenRevoked) {
       
        [[AlertMessageHandler sharedInstance] showCustomMessage:message
                                                   withDelegate:self
                                                            tag:alertViewTagForInitialSyncRevokeToken
                                                          title:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage]
                                              cancelButtonTitle:nil
                                           andOtherButtonTitles:@[[[TagManager sharedInstance]tagByName:kTagSignOut]]];
        return;
    }
    
    NSString *retry =[ [TagManager sharedInstance]tagByName:kTagSyncProgressRetry] ;
    [[AlertMessageHandler sharedInstance] showCustomMessage:message
                                               withDelegate:self
                                                        tag:alertViewTagForInitialSync
                                                      title:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage]
                                          cancelButtonTitle:retry
                                       andOtherButtonTitles:@[[[TagManager sharedInstance]tagByName:kTagSignOut]]];

}


//Error handling for Profile Validaton
- (void)profileValidationFailedWithError:(NSError *)error
{
    if (error != nil) {
        
       
       // [self updatePlistWithLastDataSyncTimeAndStatus:kFailed];
        [self updatePlistWithLastConfigSyncTimeAndStatus:kFailed];
        [[AlertMessageHandler sharedInstance] showCustomMessage:[error errorEndUserMessage]
                                                   withDelegate:nil
                                                            tag:alertViewTagForProfileValidation
                                                          title:@"Error"
                                              cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]
                                           andOtherButtonTitles:nil];
        
         [self enableAllParallelSync:YES];
    }
}

- (void)updatePlistWithLastConfigSyncTimeAndStatus:(NSString *)status
{
    if (status != nil)
    {
        [PlistManager storeLastConfigSyncGMTTime:[DateUtil getDatabaseStringForDate:[NSDate date]]];
        [PlistManager storeLastConfigSyncStatus:status];
    }
}


#pragma mark - Alert view handling for Initial Sync

- (void)handleInitialSyncAlertViewCallBack:(UIAlertView *)alertView
                      clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (![[SNetworkReachabilityManager sharedInstance] isNetworkReachable]) {
        
        [self showSyncFailedForInitialSyncAlertViewForError:[[TagManager sharedInstance] tagByName:KTagAlertInrnetNotAvailableError]];
        return;
    }
    switch (buttonIndex) {
        case 0:
        {
            if (alertView.tag == alertViewTagForInitialSyncRevokeToken) {
                [self performSelectorOnMainThread:@selector(performLoggout) withObject:nil waitUntilDone:NO];
                return;
            }
             /*Send progress view  */
             [self performInitialSync];

        }
        break;
            
        case 1:
        {
            [self performSelectorOnMainThread:@selector(performLoggout) withObject:nil waitUntilDone:NO];

        }
        default:
            break;
    }
}

#pragma mark End 

- (void)performLoggout
{
    [[SVMXSystemUtility sharedInstance] startNetworkActivity];

    @synchronized([self class])
    {
        BOOL isRevoked = [OAuthService revokeAccessToken];
        
        if (isRevoked)
        {
            [[CacheManager sharedInstance] clearCache];
            [OAuthService clearOAuthErrorMessage];
            [[AppManager sharedInstance] completedLogoutProcess];
            [[AppManager sharedInstance] loadScreen];
        }
        else
        {
            // VIPIN : TODO
            //Pushpak - for time being I am adding this so that it won't block the initial screen.
            [[CacheManager sharedInstance] clearCache];
            [OAuthService clearOAuthErrorMessage];
            [[AppManager sharedInstance] completedLogoutProcess];
            [[AppManager sharedInstance] loadScreen];
        }
    }
    
    [[SVMXSystemUtility sharedInstance] stopNetworkActivity];
}

#pragma mark -End
#pragma mark - UIAlertViewDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
        case alertViewTagForInitialSyncRevokeToken:
        case alertViewTagForInitialSync:
        {
            [self handleInitialSyncAlertViewCallBack:alertView clickedButtonAtIndex:buttonIndex];
        }
        break;
        case alertViewTagForDataSync:
        {
    
        }
            break;
        default:
            break;
    }
}


#pragma mark -  Sync Progress Status

- (BOOL)isDataSyncInProgress
{
    return self.isDataSyncRunning;
}

- (BOOL)isConfigSyncInProgress
{
    if (self.configSyncStatus == SyncStatusInProgress)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)isInitalSyncOrResetApplicationInProgress
{
    if (self.initialSyncStatus == SyncStatusInProgress)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)isDataPurgeInProgress
{
    //DefectFix:029269
    if ([SMDataPurgeManager sharedInstance].purgeStatus == DataPurgeStatusPurgingInProgress)
    {
        return YES;
    }
    else
    {
        return NO;
    }
  
    
}

- (void)updateDataPurgeStatus:(SyncStatus)status
{
    if ((status == SyncStatusSuccess) || (status == SyncStatusFailed))
    {
        self.dataPurgeStatus = DataPurgeCompleted;
    }
    [self manageSyncQueueProcess];
    
}

- (BOOL)syncInProgress
{
    if (   [self isConfigSyncInProgress]
        || [self isInitalSyncOrResetApplicationInProgress]
        || [self isDataSyncInProgress])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)isConfigSyncInQueue
{
    if (self.configSyncStatus == SyncStatusInQueue)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)isInitialSyncInQueue
{
    if (self.initialSyncStatus == SyncStatusInQueue)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


#pragma mark - User record update
- (void)updateUserTableIfRecordDoesnotExist {
    
    
    NSString *userId = [[CustomerOrgInfo sharedInstance] userId];
    if (userId.length <= 0) {
        return;
    }
    NSString *userName = [[CustomerOrgInfo sharedInstance] userName];
    NSString *name = [[CustomerOrgInfo sharedInstance] userDisplayName];
    NSString *userLanguage = [[CustomerOrgInfo sharedInstance] userLanguage];
    
     NSMutableDictionary *recordDictionary = [[NSMutableDictionary alloc] init];
    [recordDictionary setObject:userId forKey:kId];
    if (userName != nil) {
        [recordDictionary setObject:userName forKey:@"Username"];
    }
    if (name != nil) {
          [recordDictionary setObject:name forKey:@"Name"];
    }
   if (userLanguage != nil) {
        [recordDictionary setObject:userLanguage forKey:@"LanguageLocaleKey"];
    }
 
    TransactionObjectModel *model = [[TransactionObjectModel alloc] init];
    [model mergeFieldValueDictionaryForFields:recordDictionary];
    
    TXFetchHelper *helper = [[TXFetchHelper alloc] initWithCheckForDuplicateRecords:YES];
    [helper insertObjects:@[model] withObjectName:@"User"];
}

#pragma mark End
#pragma mark - sync conflicts manager
// checks if conflicts exist and resolve them..
-(BOOL)continueDataSyncIfConflictsResolved {
    BOOL contiuneDataSync = TRUE;
    //delete decide later conflicts records from  modified records table
    
    NSInteger conflictsCount = [ResolveConflictsHelper getConflictsCount];
    if (conflictsCount > 0) {
        contiuneDataSync = [ResolveConflictsHelper checkResolvedConflicts];
    }
    return contiuneDataSync;
}


- (NSString *)nextScheduledDataSyncTime
{
    NSString *nextSyncTime = @"--";
    NSDate *date = [self dataSyncNextScheduledTime];
    if (date != nil)
    {
        nextSyncTime = [DateUtil getUserReadableDateForSyncStatus:date];
    }
    return nextSyncTime;
}


- (NSString *)nextScheduledConfigSyncTime
{
    NSString *nextSyncTime = @"--";
    NSDate *date = [self configSyncNextScheduledTime];
    if (date != nil)
    {
        nextSyncTime = [DateUtil getUserReadableDateForSyncStatus:date];
    }
    return nextSyncTime;
}

#pragma mark - Enable or disable other syncs
- (void)enableAllParallelSync:(BOOL)shouldEnable {
    
    if (shouldEnable) {
        [self scheduleSync];
        [[LocationPingManager sharedInstance] startLocationPing];
        [[SMDataPurgeManager sharedInstance] updateDataPurgeTimer];
    }
    else{
         [self invalidateScheduleSync];
        [[SMDataPurgeManager sharedInstance] invalidateDataPurgeTimer];
        /*
         * Since timers are gettings invalidated.
         */
        [self removeConfigSyncLocalNotification];
        [[LocationPingManager sharedInstance] stopLocationPing];
    }
}

#pragma mark - Set Initial Sync Flag
- (void)setSyncProgressFlag
{
    [[AppManager sharedInstance] setApplicationStatus:ApplicationStatusInitialSyncInProgress];
}

- (void)setSyncCompletionFlag
{
    [[AppManager sharedInstance] setApplicationStatus:ApplicationStatusInitialSyncCompleted];
}

#pragma mark - End

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
- (void)performDataSyncIfNetworkReachable
{
    @synchronized([self class])
    {
        if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
        {
            NSString *aggressiveSyncEnabled = [SFMPageHelper getSettingValueForSettingId:kMobileSettingsAggressiveSync];
            if (![[aggressiveSyncEnabled uppercaseString] isEqualToString:@"FALSE"])
            {
                   NSString *getPriceEnabled= [SFMPageHelper getSettingValueForSettingId:kMobileSettingsGetPrice];
                
                BOOL isGetPrice = [getPriceEnabled boolValue];
                
                   if(isGetPrice)
                   {
                       self.isGetPriceCallEnabled = YES;

                   }
                   else{
                       self.isGetPriceCallEnabled = NO;

                   }
                
                [self performSyncWithType:SyncTypeData];
            }
        }
    }
    return;
}

#pragma - DB back up

- (void)performDBBackUp {
    DatabaseConfigurationManager *configurationManager = [DatabaseConfigurationManager sharedInstance];
    [configurationManager resetDataMigration];
    [configurationManager populateDataForMigration];
    [configurationManager doPriorDatabaseConfigurationForMetaSync];
}

#pragma - End

/**
 * @name  enqueueSyncQueue
 *
 * @author Vipindas Palli
 *
 * @brief
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Void
 *
 */

- (void)enqueueSyncQueue:(SyncType)syncType
{
    NSLog(@"EnqueueSyncQueue -  %d", (int)syncType);
    if (self.syncQueue == nil)
    {
        self.syncQueue = [NSMutableArray array];
    }

    int val = (int) syncType;
    
    [self.syncQueue addObject:[NSNumber numberWithInt:val]];
    
    
}

/**
 * @name  dequeueSyncQueue
 *
 * @author Vipindas Palli
 *
 * @brief
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Void
 *
 */

- (SyncType)dequeueSyncQueue
{
    NSLog(@"DequeueSyncQueue ");
    SyncType syncType = SyncTypeUnknown;
    
    if ( (self.syncQueue == nil) || ([self.syncQueue count] < 1))
    {
        //return syncType;
    }
    else
    {
        NSNumber *number = [self.syncQueue  objectAtIndex:0];
        
        if (number != nil)
        {
            syncType = [number integerValue];
        }
        
        [self.syncQueue removeObjectAtIndex:0];
        
        if ([self.syncQueue count] < 1)
        {
            self.syncQueue = nil;
        }
    }
    
    if(syncType == SyncTypeInitial)
    {
        [[AppManager sharedInstance] resetApplicationContents];
    }
    
    NSLog(@"DequeueSyncQueue -  %d", (int)syncType);
    return syncType;
}

/**
 * @name  processSyncQueue
 *
 * @author Vipindas Palli
 *
 * @brief
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Void
 *
 */

- (void)processSyncQueue
{
    NSLog(@"Process Sync Queue");
    
    SyncType syncType  = [self dequeueSyncQueue];

    switch (syncType)
    {
        case SyncTypeData:
        case SyncTypeReset:
        case SyncTypeInitial:
        case SyncTypeConfig:
        case SyncTypeValidateProfile:
            [self performSyncWithType:syncType];
            break;
            
        default:
           // Woow no Sync in queue
            NSLog(@"Woow no Sync in queue");
            break;
    }
}


/**
 * @name  manageSyncQueueProcess
 *
 * @author Vipindas Palli
 *
 * @brief
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Void
 *
 */

- (void)manageSyncQueueProcess
{
    double delayInSeconds = 1.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        [self processSyncQueue];
    });
}



#pragma mark Custom data sync.

/* It will check whether modified record has after update,after insert, befor update operations are there or not and based on that the sync will happen */

- (void)initiateCustomDataSync
{
  @synchronized([self class]) {
      
    self.isAfterInsert = NO;
    self.isBeforeUpdate = NO;
    self.isAfterUpdate = NO;
    
//    BOOL isConflictResolved = [self allConflictsResolved];
    BOOL isConflictResolved = [self continueDataSyncIfConflictsResolved];
    NSArray *operationArray = [self theModifiedRecords];
    
//      Manage decide later for custom webservice calls related record.

    if(operationArray.count && isConflictResolved)
    {
    NSArray *afterInsertFilteredArray = [operationArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(%K CONTAINS[c] %@) ", @"operation", @"AFTERINSERT"]];
    NSArray *beforeFilteredArray = [operationArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(%K CONTAINS[c] %@) ", @"operation", @"BEFOREUPDATE"]];
    NSArray *afterUpdateFilteredArray = [operationArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(%K CONTAINS[c] %@) ", @"operation", @"AFTERUPDATE"]];

       NSArray *newOperationArray = [afterInsertFilteredArray arrayByAddingObjectsFromArray:beforeFilteredArray];
        newOperationArray = [newOperationArray arrayByAddingObjectsFromArray:afterUpdateFilteredArray];

        for(ModifiedRecordModel *model in newOperationArray)
        {
            self.cCustomCallRecordModel = model;
            if([model.operation isEqualToString:@"AFTERINSERT"])
            {
                self.isBeforeUpdate = NO;
                self.isAfterInsert = YES;
                self.isAfterUpdate = NO;
//                [self.notSyncedDataArrayForCustomeCall removeAllObjects];
                
                if ([self isThereAnyRecordForInsertion]) {
                    
                    // If all the insert records are already uploaded to server, then no need of initiating the sync again.
                    [[CacheManager sharedInstance] pushToCache:@"AfterInsert" byKey:kAfterSaveInsertCustomCallValueMap];

                    self.isDataSyncRunning = NO;
                    [self checkNetworkReachabilityAndInitiateDataSync];
                }
                else {
                    
                   BOOL status = [self customAPICallwithModifiedRecordModelRequestData:model.requestData andRequestType:1];
                    if (!status) {
                      
                        [self customCallDidNotInitiateDuetoSomeRaeason];

                    }
                }
                
                break;
            }
            else if ([model.operation isEqualToString:@"BEFOREUPDATE"])
            {
                self.isBeforeUpdate = YES;
                self.isAfterInsert = NO;
                self.isAfterUpdate = NO;
                
                /* condition is for insert record checking, If is there any record for insert then perform PUT_INSERT first then make WS call */
                if ([self isThereAnyRecordForInsertion]) {
                    
                    // If all the insert records are already uploaded to server, then no need of initiating the sync again.
                    [[CacheManager sharedInstance] pushToCache:@"AfterInsert" byKey:kAfterSaveInsertCustomCallValueMap];
                    self.isDataSyncRunning = NO;
                    self.isBeforeUpdate = NO;
                    [self checkNetworkReachabilityAndInitiateDataSync];
                }
                else{
                    BOOL status = [self customAPICallwithModifiedRecordModelRequestData:model.requestData andRequestType:2];
                    if (!status) {
                        [self customCallDidNotInitiateDuetoSomeRaeason];
                    }
                }
                break;
            }
            else
            {
                
                //AFTER UPDATE
                self.isBeforeUpdate = NO;
                self.isAfterInsert = NO;
                self.isAfterUpdate = YES;
//                [self.notSyncedDataArrayForCustomeCall removeAllObjects];
//                NSInteger conflictsCount = [ResolveConflictsHelper getConflictsCount];
                NSArray *conflictArray = [ResolveConflictsHelper getConflictsRecords];
                NSInteger holdConflictCount = 0;
                for (SyncErrorConflictModel *syncConflictModel in conflictArray) {
                    if ([syncConflictModel.overrideFlag isEqualToString:@"hold"]) {
                        holdConflictCount++;
                    }
                }
                if ([self isThereAnyRecordForUpdationOrInsertion] || (conflictArray.count != holdConflictCount) )
                {
                    self.isDataSyncRunning = NO;
                    self.isAfterUpdate = NO;
                    [self checkNetworkReachabilityAndInitiateDataSync];
                }
                else
                {
                    BOOL status = [self customAPICallwithModifiedRecordModelRequestData:model.requestData andRequestType:3];
                    
                    if (!status) {
                        [self customCallDidNotInitiateDuetoSomeRaeason];
                    }
                }
                break;
            }
        }
    }
    else if(isConflictResolved)
    {
        SXLogDebug(@"ELSE if IN initiateCustomDataSync");
        [self checkNetworkReachabilityAndInitiateDataSync];
    }
    else
    {
        SXLogDebug(@"Conflicts Present so failure Case");
       [self currentDataSyncFailedWithError:nil];
    }
  }
}

-(void)customCallDidNotInitiateDuetoSomeRaeason
{


    if (self.isAfterUpdate) {
        [self currentDataSyncFailedWithError:nil];

    }
    else
    {
        /*
       TODO: manage infinite call loop. SHould use counter for atleast 1 complete data Sync cycle.
            If for some reason, the custom call fails in afterinsert call, then data sync gets intiated, when tat finishes, again it is checked if a cvustom call has to be initiated. When the custom call is tired to be invoked, again it fails and after that again the data sync call starts. So infiite loop. Manage this.
           */
            SXLogDebug(@"IN customCallDidNotInitiateDuetoSomeRaeason for Record model");

            [self.cCustomCallRecordModel explainMe];
        
                if (!self.isDataSyncInLoop) {
                    self.isDataSyncInLoop = YES;
                    [self checkNetworkReachabilityAndInitiateDataSync];

                }
                else
                {
                    self.isDataSyncInLoop = NO;
                    [self currentDataSyncFailedWithError:nil];

                }
        

    }
    
    self.isBeforeUpdate = NO;
    self.isAfterInsert = NO;
    self.isAfterUpdate = NO;

}

-(BOOL)allConflictsResolved
{
    NSArray * conflictRecords = [ResolveConflictsHelper getConflictsRecords];
    
    BOOL conflictsResolved = YES;
    if (conflictRecords.count) {
        for (SyncErrorConflictModel *syncConflictModel in conflictRecords) {
            
            if([StringUtil isStringEmpty:syncConflictModel.overrideFlag]) {
                
                conflictsResolved = FALSE;
                break;
            }
            
        }
    }
    return conflictsResolved;
}
-(void)checkNetworkReachabilityAndInitiateDataSync
{
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable]) {
        [self initiateDataSync];

    }
    else
    {
        [self currentDataSyncFailedWithError:nil];
    }
}

-(BOOL)customAPICallwithModifiedRecordModelRequestData:(NSString *)requestData andRequestType:(int)requestType
{
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable] && [self doesTheRecordStillExist])
    {
        SFMCustomActionWebServiceHelper *webserviceHelper=[[SFMCustomActionWebServiceHelper alloc] initWithSFMPageRequestData:requestData requestType:requestType];

        if (webserviceHelper) {
            
            if (![self isDataSyncInProgress]) {
                [self setTheDataSyncStatus];
            }
            [webserviceHelper performSelectorInBackground:@selector(initiateCustomWebServiceForAfterBeforeWithDelegate:) withObject:self];
            return YES;
        }
    }
        return NO;
}

- (void)PerformSYncBasedOnFlags
{
    @synchronized([self class]) {
        
        [[CacheManager sharedInstance] clearCacheByKey:kAfterSaveInsertCustomCallValueMap]; // This is being saved in SFMCustomActionWebServiceHelper. So removing it after the custom call.
        
        [[CacheManager sharedInstance] clearCacheByKey:kCustomWebServiceAction]; // This is being saved in SFMCustomActionWebServiceHelper. So removing it after the custom call.
        
        [[SuccessiveSyncManager sharedSuccessiveSyncManager] doSuccessiveSync];
        
        BOOL modifiedRecordsExist = [self checkIfModifiedRecordsExist];
        
        if(modifiedRecordsExist)
        {
            self.isDataSyncRunning = NO;
            [self initiateCustomDataSync];
            
            // 030783
            NSString *getPriceEnabled = [SFMPageHelper getSettingValueForSettingId:kMobileSettingsGetPrice];
            self.isGetPriceCallEnabled = [getPriceEnabled boolValue];
            
            if (self.isGetPriceCallEnabled) {
                SXLogDebug(@"GP: CALLED IN QUEUE");
                self.isGetPriceCallEnabled = NO;
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGetPriceNotification:) name:@"DoGetPrice" object:nil];
            }
            
        }
        else {
            [self currentDataSyncfinished];
        }
        
        /*
         if(self.isAfterInsert)
         {
         
         status =  [self customAPICallwithModifiedRecordModelRequestData:self.cCustomCallRecordModel.requestData andRequestType:1];
         }
         else if(self.isBeforeUpdate)
         {
         [self performDataSync];
         return;
         
         }
         else if(self.isAfterUpdate)
         {
         status =  [self customAPICallwithModifiedRecordModelRequestData:self.cCustomCallRecordModel.requestData andRequestType:3];
         }
         
         if (!status) {
         [self currentDataSyncfinished];
         
         }
         */
        
    }
}

- (void)customCallResponse
{
    [[CacheManager sharedInstance] clearCacheByKey:kAfterSaveInsertCustomCallValueMap];
}

- (void)makeNextCallForCustomDataSyncWithResponse:(WebserviceResponseStatus *)responseStatus
{
    self.initialSyncStatus = responseStatus.syncStatus;

    if (responseStatus.syncStatus == SyncStatusSuccess)
    {
        SXLogDebug(@"custom call Finished");
        
        //Delete the Record which was synced.
        id <ModifiedRecordsDAO> modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
        
        BOOL status = [modifiedRecordService deleteUpdatedRecordsForModifiedRecordModel:self.cCustomCallRecordModel];
        
        if (status) {
            self.cCustomCallRecordModel = nil;
        }
        
        [self nextFlow];

    }
    else  if ( (responseStatus.syncStatus == SyncStatusFailed) ||  (responseStatus.syncStatus == SyncStatusNetworkError))
    {
        SXLogDebug(@"Initial Sync failed");
        [self currentDataSyncFailedWithError:responseStatus.syncError];
    }
}

-(void)nextFlow
{
    [[SuccessiveSyncManager sharedSuccessiveSyncManager] doSuccessiveSync];
    
    ModifiedRecordsService *modifiedRecordService = [[ModifiedRecordsService alloc] init];
    BOOL doesExist = NO;
    
    if ([modifiedRecordService conformsToProtocol:@protocol(ModifiedRecordsDAO)]) {
        
        doesExist =  [modifiedRecordService doesRecordExistInTheTable];
    }
    if(doesExist)
    {
        self.isDataSyncRunning = NO;
        [self initiateCustomDataSync];
    }
    else {
        [self currentDataSyncfinished];
        
    }
}

-(void)setTheDataSyncStatus
{
    self.isDataSyncRunning = YES;
    self.dataSyncStatus = SyncStatusInProgress;
    [PlistManager storeLastDataSyncStartGMTTime:[DateUtil getDatabaseStringForDate:[NSDate date]]];
    [PlistManager storeLastDataSyncStatus:kInProgress];
}

-(NSArray *)theModifiedRecords
{
    id <ModifiedRecordsDAO> modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
    
    NSArray *operationArray = [modifiedRecordService getTheOperationValue];
    return operationArray;
}

-(BOOL)doesTheRecordStillExist
{

    id <ModifiedRecordsDAO> modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
        
    BOOL status = [modifiedRecordService doesRecordExistForId:self.cCustomCallRecordModel.recordLocalId andOperationType:self.cCustomCallRecordModel.operation];
    return status;
}

-(BOOL)isThereAnyRecordForInsertion
{
    id <ModifiedRecordsDAO> modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
    
    NSDictionary *insertedRecords = [modifiedRecordService getInsertedSyncRecords];

    return (insertedRecords.count?YES:NO);
}

-(BOOL)isThereAnyRecordForUpdationOrInsertion
{
    if ([self isThereAnyRecordForInsertion]) {
        return YES;
    }
    
    id <ModifiedRecordsDAO> modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
    
    NSDictionary *insertedRecords = [modifiedRecordService getUpdatedRecords];
    
    return (insertedRecords.count?YES:NO);
}



// check if there is any record in ModifiedRecords. Also, check if all the records in this table meet following conditions: recordType - DETAIL, operation - INSERT, parent record is unsynced with a conflict (& 'decide later' status). If all records in ModifiedRecords meet these conditions, then dont trigger data sync - for defect 020834
-(BOOL)checkIfModifiedRecordsExist {
    BOOL doesExist = NO;
    ModifiedRecordsService *modifiedRecordService = [[ModifiedRecordsService alloc] init];
    if ([modifiedRecordService conformsToProtocol:@protocol(ModifiedRecordsDAO)]) {
        doesExist =  [modifiedRecordService doesAnyRecordExistForSyncing];
        if (doesExist) {
            BOOL nonInsertRecordsExist = [modifiedRecordService checkIfNonInsertRecordsExist]; //HS 31May - check for AfterInsert operation type
            
            BOOL AfterSaveInsertRecordsExist = [modifiedRecordService checkIfNonAfterSaveInsertRecordsExist]; //HS 31May - check for AfterInsert operation type

            if ((!nonInsertRecordsExist) || ((AfterSaveInsertRecordsExist))) { // if only insert records exist..
               // if ((!nonInsertRecordsExist) && (!nonAfterSaveInsertRecordsExist)) { // if only insert records exist..

                TransactionObjectService *transObjectService = [[TransactionObjectService alloc] init];
                SyncErrorConflictService *conflictService = [[SyncErrorConflictService alloc] init];
                NSArray *insertRecords = [modifiedRecordService getInsertRecordsAsArray];
                for (ModifiedRecordModel *model in insertRecords) {
                    if ([model.recordType isEqualToString:kRecordTypeMaster]) {
                        doesExist = YES; // header insert record exist, trigger data sync.
                        break;
                    }
                    else {
                        
                        BOOL doesParentRecordExist = [transObjectService doesRecordExistsForObject:model.parentObjectName forRecordId:model.parentLocalId];
                        
                        if (doesParentRecordExist) {
                            
                            NSString *sfIdValue = [transObjectService getSfIdForLocalId:model.parentLocalId forObjectName:model.parentObjectName];
                            if ([StringUtil isStringEmpty:sfIdValue]) {
                                BOOL conflictRecordExist = [conflictService isConflictFoundOnHoldForLocalRecordWithObject:model.parentObjectName withLocalId:model.parentLocalId];
                                if (conflictRecordExist) {
                                    doesExist = NO; // parent record is in conflict with 'decide later' status..
                                }
                                else {
                                    doesExist = YES; // parent record exist with no conflict, trigger data sync..
                                    break;
                                }
                            }
                            else {
                                doesExist = YES; // parent record has SFID, trigger data sync..
                                break;
                            }
                        }
                        else {
                            doesExist = YES; // parent record doesn't exist, trigger data sync..
                            break;
                        }
                    }
                }
            }
            else {
                doesExist = YES; // update/delete records exist, trigger data sync..
            }
        }
    }
    return doesExist;
}

#pragma mark - Product IQ

-(void)initiateProdIQDataSync {
    [[ProductIQManager sharedInstance] initiateProdIQDataSync];
}

-(void)cancelProdIQDataSync {
    [[ProductIQManager sharedInstance] cancelProdIQDataSync];
}

#pragma mark Sync Error Report

-(void)executeSyncErrorReporting
{
    SMAppDelegate *appDelegate = (SMAppDelegate*)[[UIApplication sharedApplication]delegate];
    //HS 13 Jul syncErrorReporting andling for valid "errors"
    //Defect Fix:033904
    
    if ([appDelegate.syncReportingType isEqualToString:@"always"] || (( [appDelegate.syncReportingType isEqualToString:@"error"]) && ([appDelegate.syncErrorDataArray count]!=0) ) )
    {
        dispatch_async(_queue, ^{
             MobileDataUsageExecuter *executor = [[MobileDataUsageExecuter alloc]initWithParentView:nil andFrame:CGRectZero];
            [executor execute];
        });
        
        ConfigureLoggerAccordingToSettings();
    }
    else
    {
        [self handleSyncCompletion];
    }
}

- (void)handleSyncCompletion
{
    SMAppDelegate *appDelegate = (SMAppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.syncDataArray = nil;
    appDelegate.syncErrorDataArray = nil;

    switch (self.syncType) {
        case SyncTypeInitial:
            [self handleInitialSyncCompletion];
            break;
        case SyncTypeConfig:
            [self handleConfigSyncCompletion];
            break;
        case SyncTypeData:
            [self handleDataSyncCompletion];
            break;
        default:
            break;
    }
    self.syncResponseStatus = nil;
}

- (void)handleInitialSyncCompletion
{
    if (self.syncResponseStatus.syncStatus == SyncStatusSuccess)
    {
        [self currentInitialSyncFinished];
        [self updateUserTableIfRecordDoesnotExist];
        [[AutoLockManager sharedManager] enableAutoLockSettingFor:initialSyncAL]; // Enable the user controlled device lock. 26-May-2015
        [self notifyStatus:kInitialSyncStatusNotification];
    }
    else  if ( (self.syncResponseStatus.syncStatus == SyncStatusFailed) ||  (self.syncResponseStatus.syncStatus == SyncStatusNetworkError))
    {
        [self currentInitialSyncFailedWithError:self.syncError];
    }
}

- (void)handleConfigSyncCompletion
{
    if (self.syncResponseStatus.syncStatus == SyncStatusSuccess)
    {
        [[DatabaseConfigurationManager sharedInstance] postMetaSyncDatabaseConfigurationByResult:YES];
        [self currentConfigSyncFinished];
        [self notifyStatus:kConfigSyncStatusNotification];
    }
    else  if (self.syncResponseStatus.syncStatus == SyncStatusFailed ||  self.syncResponseStatus.syncStatus == SyncStatusNetworkError)
    {
        [[DatabaseConfigurationManager sharedInstance] postMetaSyncDatabaseConfigurationByResult:NO];
        [self currentConfigSyncFailedWithError:self.syncError];
    }
}

- (void)notifyStatus:(NSString*)notification {
    SyncProgressStatusHandler *syncProgressHandler = [[SyncProgressStatusHandler alloc] init];
    SyncProgressDetailModel   *syncProgressModel = [syncProgressHandler getProgressDetailsForStatus:self.syncResponseStatus];
    
    syncProgressModel.syncError = self.syncError;
    NSDictionary *syncStatus = nil;
    
    if (syncProgressModel != nil)
    {
        syncStatus = [NSDictionary dictionaryWithObject:syncProgressModel forKey:@"syncstatus"];
    }
    else
    {
        syncStatus = [NSDictionary dictionaryWithObject:@"In Progress" forKey:@"syncstatus"];
    }
    
    [self sendNotification:notification andUserInfo:syncStatus];
}

- (void)handleDataSyncCompletion
{
    if (self.syncResponseStatus.syncStatus == SyncStatusSuccess)
    {
        [self PerformSYncBasedOnFlags];
    }
    else  if (   (self.syncResponseStatus.syncStatus == SyncStatusFailed)
              || (self.syncResponseStatus.syncStatus == SyncStatusRefreshTokenFailedWithError)
              || (self.syncResponseStatus.syncStatus == SyncStatusNetworkError))
    {
        [self currentDataSyncFailedWithError:self.syncError];
    }
    
}

- (dispatch_queue_t)getSyncErrorReportQueue
{
    return _queue;
}




#pragma mark - Sync Profiling

-(void)initiateSyncProfiling:(NSString *)profileType {
    
    if ([self isSyncProfilingEnabled])
    {
        [self pushSyncProfileInfoToUserDefaultsWithValue:profileType forKey:kSyncProfileType];
        
        if ([profileType isEqualToString:kSPTypeStart])
        {
            if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
            {
                [self performSyncProfiling];
            }
        }
        else if ([profileType isEqualToString:kSPTypeEnd])
        {
            NSString *startReqId = [[NSUserDefaults standardUserDefaults] valueForKey:kSyncprofileStartReqId];
            [self pushSyncProfileInfoToUserDefaultsWithValue:startReqId forKey:kSyncprofileEndReqId];
            
            if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
            {
                [self performSyncProfiling];
            }
            else
            {
                NSString *currentDate = [DateUtil getCurrentDateForSyncProfiling];
                [self pushSyncProfileInfoToUserDefaultsWithValue:currentDate forKey:kSPSyncTime];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkConnectivityChanged) name:kNetworkConnectionChanged object:nil];
            }
        }
    }
}


-(void)performSyncProfiling {
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeSyncProfiling requestParam:nil callerDelegate:self];
    [[TaskManager sharedInstance] addTask:taskModel];
}

-(void)checkStatusForSyncProfiling:(WebserviceResponseStatus *)response {
    if ([self isSyncProfilingEnabled]) {
        switch (response.syncStatus) {
            case SyncStatusInProgress:
            {
                if (response.requestType == RequestValidateProfile) {
                    [self initiateSyncProfiling:kSPTypeStart];
                }
            }
                break;
            case SyncStatusSuccess:
            case SyncStatusFailed:
            {
                if (response.requestType != RequestValidateProfile) {
                    if (response.syncStatus == SyncStatusFailed) {
                        [self checkIfRequestTimedOutForSyncProfiling:response.syncError];
                    }
                    [self initiateSyncProfiling:kSPTypeEnd];
                }
            }
                break;
            default:
                break;
        }
    }
}


-(void)networkConnectivityChanged {
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNetworkConnectionChanged object:nil];
        [self performSyncProfiling];
    }
}

-(void)pushSyncProfileInfoToUserDefaultsWithValue:(NSString *)value forKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}

-(BOOL)isSyncProfilingEnabled {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isSyncProfileEnabled = [[userDefaults objectForKey:kSyncProfileEnabled] boolValue];
    return isSyncProfileEnabled;
}

-(void)checkIfRequestTimedOutForSyncProfiling:(NSError *)error {
    if ([self isSyncProfilingEnabled]) {
        if (error != nil) {
            if ([[error description] containsString:@"-1001"]) {
                [self pushSyncProfileInfoToUserDefaultsWithValue:@"Yes" forKey:kSPReqTimedOut];
            }
        }
    }
}

-(void)setUpRequestIdForSyncProfiling:(NSString *)requestId {
    if([self isSyncProfilingEnabled]) {
        [self pushSyncProfileInfoToUserDefaultsWithValue:@"No" forKey:kSPReqTimedOut];
        [self pushSyncProfileInfoToUserDefaultsWithValue:requestId forKey:kSyncprofileStartReqId];
    }
}

@end
