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



const NSInteger alertViewTagForDataSync     = 888888;
const NSInteger alertViewTagForConfigSync   = 888889;
const NSInteger alertViewTagForInitialSync  = 888890;

NSString *kInitialSyncStatusNotification    = @"InitialSyncStatus";
NSString *kConfigSyncStatusNotification     = @"ConfigSyncStatus";
NSString *kDataSyncStatusNotification       = @"DataSyncStatus";
NSString *kEventSyncStatusNotification      = @"EventSyncStatus";
NSString *kProfileValidationStatusNotification = @"ProfileValidationStatus";

NSString *kSyncTimeUpdateNotification       = @"UpdateSyncTime";
NSString *kScheduledConfigSyncNotification  = @"ScheduledConfigSyncNotf";

NSString *lastConfigSyncTimeKey             = @"Last Config sync time";
NSString *lastDataSyncTimeKey               = @"Last data sync time";

NSString *configSyncTimeIntervalKey         = @"Config sync time";
NSString *dataSyncTimeIntervalKey           = @"Data sync time";
NSString *syncMetaDataFile                  = @"SyncMetaData.plist";

//static dispatch_once_t _sharedSyncManagerInstanceGuard;
static SyncManager *_instance;


@interface SyncManager ()<UIAlertViewDelegate>

@property (nonatomic, retain) SyncScheduler *configSyncScheduler;
@property (nonatomic, retain) SyncScheduler *dataSyncScheduler;

@property (nonatomic, assign) NSTimeInterval configSyncTimeInterval;
@property (nonatomic, assign) NSTimeInterval dataSyncTimeInterval;

@property (nonatomic, assign) SyncStatus initialSyncStatus;
@property (nonatomic, assign) SyncStatus configSyncStatus;
@property (nonatomic, assign) SyncStatus dataSyncStatus;
@property (nonatomic, assign) SyncStatus eventSyncStatus;

@property (nonatomic, strong) NSTimer  *dataSyncTimer;
@property (nonatomic, strong) NSTimer  *configSyncTimer;


@property(nonatomic,assign) BOOL isDataSyncRunning;



- (void)performInitialSync;
- (void)performConfigSync;
- (void)performDataSync;
- (void)performEventSync;

- (BOOL)cancelInitialSync;
- (BOOL)cancelConfigSync;
- (BOOL)cancelDataSync;
- (BOOL)cancelEventSync;


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
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

#pragma mark - Class Methods

- (void)performSyncWithType:(SyncType)syncType
{
    switch (syncType) {
            
        case SyncTypeInitial:
            [[LocationPingManager sharedInstance] stopLocationPing];
            [self performInitialSync];
            break;
            
        case SyncTypeReset:
            [[LocationPingManager sharedInstance] stopLocationPing];
            [self performResetApp];
            break;
            
        case SyncTypeConfig:
            [[LocationPingManager sharedInstance] stopLocationPing];
            [self performConfigSync];
            break;
            
        case SyncTypeData:
            [[LocationPingManager sharedInstance] triggerLocationWebservices];
            [self performDataSync];
            break;
            
        case SyncTypeEvent:
            [self performEventSync];
            break;
        case SyncTypeValidateProfile:
            [self performValidateProfile];
            break;
            
        default:
            break;
    }
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
    [self prepareDatabaseForInitialSync];

    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeOneCallRestInitialSync
                                             requestParam:nil
                                           callerDelegate:self];
    [[TaskManager sharedInstance] addTask:taskModel];
}

- (void)performResetApp
{
    [self prepareDatabaseForInitialSync];
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeResetApp requestParam:nil callerDelegate:self];
    [[TaskManager sharedInstance] addTask:taskModel];
}

- (void)performConfigSync
{
    
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeIncrementalOneCallMetaSync
                                             requestParam:nil
                                           callerDelegate:self];
    [[TaskManager sharedInstance] addTask:taskModel];
}

- (void)performDataSync
{
    [self initiateDataSync];
}

- (void)performEventSync
{
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeEventSync requestParam:nil callerDelegate:self];
    [[TaskManager sharedInstance] addTask:taskModel];
}

- (void)performValidateProfile
{
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
    
    if (responseStatus.syncStatus == SyncStatusSuccess)
    {
        SXLogDebug(@"Initial Sync Finished");
        [self currentInitialSyncFinished];
        [self updateUserTableIfRecordDoesnotExist];
    }
    else  if ( (responseStatus.syncStatus == SyncStatusFailed) ||  (responseStatus.syncStatus == SyncStatusNetworkError))
    {
        SXLogDebug(@"Initial Sync failed");
        [self currentInitialSyncFailedWithError:responseStatus.syncError];
    }
    else
    {
        // in case of SyncStatusRefreshTokenFailedWithError
       // [self currentInitialSyncFailedWithError:nil];
        
        //[self showNetworkActivityIndicator:NO];
    }
}


- (void)recievedDataSyncResponse:(WebserviceResponseStatus *)responseStatus
{
    self.dataSyncStatus = responseStatus.syncStatus;
    
    if (responseStatus.syncStatus == SyncStatusSuccess)
    {
        SXLogDebug(@"Data Sync Finished");
        
        [self currentDataSyncfinished];
    }
    else  if (   (responseStatus.syncStatus == SyncStatusFailed)
              || (responseStatus.syncStatus == SyncStatusRefreshTokenFailedWithError)
              || (responseStatus.syncStatus == SyncStatusNetworkError))
    {
        SXLogDebug(@"Data Sync failed");
        
        if (responseStatus.syncStatus == SyncStatusRefreshTokenFailedWithError)
        {
            [self currentDataSyncFailedWithError:nil];
        }
        else
        {
            [self currentDataSyncFailedWithError:responseStatus.syncError];
        }
    }
   
    SXLogDebug(@"Data Sync - %d", responseStatus.syncStatus);
}


- (void)recievedConfigSyncResponse:(WebserviceResponseStatus *)responseStatus
{
    self.configSyncStatus = responseStatus.syncStatus;
    
    if (responseStatus.syncStatus == SyncStatusSuccess)
    {        
        [[DatabaseConfigurationManager sharedInstance] postMetaSyncDatabaseConfigurationByResult:YES];
    
        NSLog(@"Config Sync Finished");
        SXLogDebug(@"Config Sync Finished");
        [self currentConfigSyncFinished];
    }
    else  if (responseStatus.syncStatus == SyncStatusFailed ||  responseStatus.syncStatus == SyncStatusNetworkError)
    {
        SXLogDebug(@"Config Sync failed");
        [[DatabaseConfigurationManager sharedInstance] postMetaSyncDatabaseConfigurationByResult:NO];
        [self currentConfigSyncFailedWithError:responseStatus.syncError];
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
            }
                
                break;
                
            case CategoryTypeDataSync:
            case CategoryTypeOneCallDataSync:
            {
                notification = kDataSyncStatusNotification;
                //shouldNotify = NO;
                [self recievedDataSyncResponse:wsResponseStatus];
            }
                break;
                
            case CategoryTypeEventSync:
                break;
                
            case CategoryTypeValidateProfile:
            {
                notification = kProfileValidationStatusNotification;
                
                if (wsResponseStatus.syncStatus == SyncStatusSuccess)
                {
                    NSLog(@"Profile validation completed successfully");
                }
                else  if (   (wsResponseStatus.syncStatus == SyncStatusFailed)
                          || (wsResponseStatus.syncStatus == SyncStatusNetworkError) )
                {
                    NSLog(@"Profile validation failed");
                    [self profileValidationFailedWithError:wsResponseStatus.syncError];
                }
                break;
            }
    
                
            case CategoryTypeConfigSync:
            case CategoryTypeOneCallConfigSync:
            case CategoryTypeIncrementalOneCallMetaSync:
            {
                notification = kConfigSyncStatusNotification;
                [self recievedConfigSyncResponse:wsResponseStatus];
            }
                break;
                
            default:
                break;
        }
        
        if (shouldNotify) {
            
            SyncProgressStatusHandler *syncProgressHandler = [[SyncProgressStatusHandler alloc] init];
            SyncProgressDetailModel   *syncProgressModel = [syncProgressHandler getProgressDetailsForStatus:status];
            
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
     [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:userInfo];
}
#pragma mark - RESET DATABASE BEFORE INITIAL SYNC

- (void)prepareDatabaseForInitialSync
{
    DatabaseManager *manager;
    manager = [DatabaseManager sharedInstance];
  [[DatabaseConfigurationManager sharedInstance] preInitialSyncDBPreparation];
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
            SXLogInfo(@" Data sync is already running ");
            return NO;
        }
        else if (![self continueDataSyncIfConflictsResolved])
        {
            return NO;
        }
        else
        {
            self.isDataSyncRunning = YES;
            self.dataSyncStatus = SyncStatusInProgress;
            
            [PlistManager storeLastDataSyncStatus:kInProgress];
            [self performSelectorInBackground:@selector(initiateSyncInBackGround) withObject:nil];
        }
        return YES;
    }
}


- (void)currentDataSyncfinished {
    
    @synchronized([self class]) {

        [[SuccessiveSyncManager sharedSuccessiveSyncManager] doSuccessiveSync];
        [self updateLastSyncTime];
        
        // if conflicts not resolved, then stop data sync..
        BOOL conflictsResolved = [self continueDataSyncIfConflictsResolved];

        BOOL didRestart = (conflictsResolved)?[self restartDataSyncIfNecessary]:NO;
        
        if (!didRestart) {
            
            self.isDataSyncRunning = NO;
            self.dataSyncStatus = SyncStatusSuccess;
            [self updateLastSyncTime];
            
            [PlistManager removeLastLocalIdFromDefaults];

            [self updatePlistWithLastDataSyncTimeAndStatus:kSuccess];
            /* Send data sync Success notification */
            [self sendNotification:kDataSyncStatusNotification andUserInfo:nil];
            
            if (conflictsResolved) {
                /* Clear user deafults utility */
                
                [PlistManager clearAllWhatIdObjectInformation];
                [[OpDocHelper sharedManager] initiateFileSync];
                [[OpDocHelper sharedManager] setCustomDelegate:self];
            }
        }
    }
}


- (void)OpdocStatus:(BOOL)status forCategory:(CategoryType)category {
    
    [self updatePlistWithLastDataSyncTimeAndStatus:kSuccess];
    
    if (!status)
    {
        NSLog(@"\n\n\n\n\n &&&&&&& OutPutDocument failed : %lu",(long)category );
    }
    else {
        NSLog(@"\n\n\n\n\n *******OPDoc Success for category %lu",(long)category);
    }
}

- (void)currentDataSyncFailedWithError:(NSError *)error {
    
    @synchronized([self class]) {
        
        [self updatePlistWithLastDataSyncTimeAndStatus:kFailed];
        
         self.isDataSyncRunning = NO;
        
        /* Send data sync Failure notification */
        [self sendNotification:kDataSyncStatusNotification andUserInfo:nil];
        
        [[AlertMessageHandler sharedInstance] showCustomMessage:[error errorEndUserMessage]
                                                   withDelegate:nil
                                                            tag:alertViewTagForConfigSync
                                                          title:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage]
                                              cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]
                                           andOtherButtonTitles:nil];
    }
}

- (void)initiateSyncInBackGround {
    
    /* If conflict count is 0, then continue with Sync */
    
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeOneCallDataSync requestParam:nil callerDelegate:self];
    [[TaskManager sharedInstance] addTask:taskModel];
}

- (BOOL)restartDataSyncIfNecessary {
    
    @synchronized([self class]) {
    
        /* Check the count in modified records table */
        ModifiedRecordsService *modifiedRecordService = [[ModifiedRecordsService alloc] init];
        
        if ([modifiedRecordService conformsToProtocol:@protocol(ModifiedRecordsDAO)]) {
        
            BOOL doesExist =  [modifiedRecordService doesRecordExistInTheTable];
            
            if (doesExist) {
                [self performSelectorInBackground:@selector(initiateSyncInBackGround) withObject:nil];
                return doesExist;
            }
        }
        return NO;
    }
}

- (void)updateLastSyncTime{
    
    @synchronized([self class]){
        
        //[PlistManager moveDataSyncTimeFromTemp];
        [self updatePlistWithLastDataSyncTimeAndStatus:kSuccess];
        [self postSyncTimeUpdateNotificationAfterSyncCompletion];
    }
}


- (void)updatePlistWithLastDataSyncTimeAndStatus:(NSString *)status
{
    if (status)
    {
        NSString *someString = [DateUtil getDatabaseStringForDate:[NSDate date]];
        [PlistManager storeLastDataSyncGMTTime:someString];
        [PlistManager storeLastDataSyncStatus:status];
        [self postSyncTimeUpdateNotificationAfterSyncCompletion];
    }
}

#pragma mark -End
#pragma mark - Config Sync Functions

- (void)currentConfigSyncFinished
{
    [[LocationPingManager sharedInstance] stopLocationPing];
    [[LocationPingManager sharedInstance] startLocationPing];
    [self updatePlistWithLastConfigSyncTimeAndStatus:kSuccess];
    [self postSyncTimeUpdateNotificationAfterSyncCompletion];
}

- (void)currentConfigSyncFailedWithError:(NSError *)error
{
    [self updatePlistWithLastConfigSyncTimeAndStatus:kFailed];
    [self postSyncTimeUpdateNotificationAfterSyncCompletion];
   
    if (error) {

        [[AlertMessageHandler sharedInstance] showCustomMessage:[error errorEndUserMessage]
                                                   withDelegate:self
                                                            tag:alertViewTagForConfigSync
                                                          title:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage]
                                              cancelButtonTitle:nil
                                           andOtherButtonTitles:@[[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]]];
    }
}

- (void)handleConfigSyncAlertViewCallBack:(UIAlertView *)alertView
                      clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
        {
            //Ok
            [self performSyncWithType:SyncTypeConfig];
        }
            break;
        default:
            break;
    }
}


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
    
    long timeDifferenceForNextSync = timeDifference % frequency;
    
    scheduledTime = [NSDate dateWithTimeIntervalSinceNow:timeDifferenceForNextSync];
    
    return scheduledTime;
}


- (NSDate *)dataSyncNextScheduledTime
{
    NSInteger frequency = [self dataSyncFrequencyInSeconds];
    
    NSString * dateString  = [PlistManager getLastScheduledDataSyncGMTTime];
    
    NSDate *nextSyncTime = [self nextScheduledSyncTimeByLastSyncTime:dateString
                                                        andFrequency:frequency];
    
    NSLog(@" nextSyncTime   : %@", nextSyncTime );
    
    return nextSyncTime;
}


- (NSDate *)configSyncNextScheduledTime
{
    NSInteger frequency = [self configSyncFrequencyInSeconds];
    
    NSString * dateString  = [PlistManager getLastScheduledConfigSyncGMTTime];
    
    NSDate *nextSyncTime = [self nextScheduledSyncTimeByLastSyncTime:dateString
                                                        andFrequency:frequency];
    NSLog(@" nextSyncTime   : %@", nextSyncTime );
    
    return nextSyncTime;
}


- (void)showLocalNotification
{
    /*
     * Pushpak commented due to issue for bug bash.
     */
/*
    if (self.configSyncTimer != nil)
    {
    
    NSLog(@" Local Notification Time for time - %@", [[self.configSyncTimer fireDate] description]);
    [[SMLocalNotificationManager sharedInstance] scheduleLocalNotificationOfType:SMLocalNotificationTypeConfigSyncDue
                                                                              on:[self.configSyncTimer fireDate]];
    }
 */
}

- (void)scheduleConfigSync
{
    NSDate *date = [self configSyncNextScheduledTime];
    NSInteger frequency = [self configSyncFrequencyInSeconds];
    
    NSLog(@"Sch. Config Sync Time  %@   -- %ld", [date description], (long)frequency);
    
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
        [self showLocalNotification];
    }
}


- (void)startScheduledDataSync
{
    [PlistManager storeLastScheduledDataSyncGMTTime:[DateUtil getDatabaseStringForDate:[NSDate date]]];
    
    if ([self syncInProgress])
    {
        return;
    }
    
    [self performSyncWithType:SyncTypeData];
}

- (void)scheduleDataSync
{
    NSDate *date = [self dataSyncNextScheduledTime];
    NSInteger frequency = [self dataSyncFrequencyInSeconds];

    NSLog(@"Sch. DATA Sync Time  %@   -- %ld", [date description], (long)frequency);
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
    NSLog(@"=========== Invalidate Schedule Sync =======");
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
    NSLog(@" ------ Schedule Sync -------- ");
    [self scheduleConfigSync];
    [self scheduleDataSync];
}


#pragma mark -End
#pragma mark - Initial Sync Functions

- (void)currentInitialSyncFinished
{
    [[AppManager sharedInstance] setApplicationStatus:ApplicationStatusInitialSyncCompleted];
    
    [self updatePlistWithLastDataSyncTimeAndStatus:kSuccess];
    [self updatePlistWithLastConfigSyncTimeAndStatus:kSuccess];
    
    [PlistManager storeLastScheduledConfigSyncGMTTime:[DateUtil getDatabaseStringForDate:[NSDate date]]];
    [PlistManager storeLastScheduledDataSyncGMTTime:[DateUtil getDatabaseStringForDate:[NSDate date]]];
    [PlistManager storeLastResetAppOrInitialSyncGMTTime:[DateUtil getDatabaseStringForDate:[NSDate date]]];
    
    [[LocationPingManager sharedInstance] stopLocationPing];
    [[LocationPingManager sharedInstance] startLocationPing];
    
    [self scheduleSync];
}

- (void)currentInitialSyncFailedWithError:(NSError *)error
{
    // Yoo initial sync failed!! Lets remove incompleted data 
    [[DatabaseConfigurationManager sharedInstance] performDatabaseConfigurationForSwitchUser];
    
    [[AppManager sharedInstance] setApplicationFailedStatus:ApplicationStatusInitialSyncFailed];
    
    [self updatePlistWithLastDataSyncTimeAndStatus:kFailed];
    [self updatePlistWithLastConfigSyncTimeAndStatus:kFailed];
    
    if (error) {
        
        [[AlertMessageHandler sharedInstance] showCustomMessage:[error errorEndUserMessage]
                                                   withDelegate:self
                                                            tag:alertViewTagForInitialSync
                                                          title:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage]
                                              cancelButtonTitle:nil
                                           andOtherButtonTitles:@[[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]]];
    }
}

//Error handling for Profile Validaton
- (void)profileValidationFailedWithError:(NSError *)error
{
    if (error) {
        
        [self updatePlistWithLastConfigSyncTimeAndStatus:kFailed];
        [[AlertMessageHandler sharedInstance] showCustomMessage:[error errorEndUserMessage]
                                                   withDelegate:nil
                                                            tag:alertViewTagForInitialSync
                                                          title:@"Error"
                                              cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]
                                           andOtherButtonTitles:nil];
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


- (void)handleInitialSyncAlertViewCallBack:(UIAlertView *)alertView
                      clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
        {
            //OK
            [self performSelectorOnMainThread:@selector(performLoggout) withObject:nil waitUntilDone:NO];

        }
        break;
            
        case 1:
        {
            //Sign Out
            //[self performSelectorOnMainThread:@selector(performLoggout) withObject:nil waitUntilDone:NO];
        }
        default:
            break;
    }
}


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
        }
        else
        {
            // VIPIN : TODO
            //Pushpak - for time being I am adding this so that it won't block the initial screen.
            [[CacheManager sharedInstance] clearCache];
            [OAuthService clearOAuthErrorMessage];
            [[AppManager sharedInstance] completedLogoutProcess];
        }
    }
    
    [[SVMXSystemUtility sharedInstance] stopNetworkActivity];
}

#pragma mark -End
#pragma mark - UIAlertViewDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
            
        case alertViewTagForInitialSync:
        {
            [self handleInitialSyncAlertViewCallBack:alertView clickedButtonAtIndex:buttonIndex];
        }
        break;
            
            
        case alertViewTagForDataSync:
        {
            //Just Okay I guess so won't get called here.
        }
        break;
            
        case alertViewTagForConfigSync:
        {
            [self handleConfigSyncAlertViewCallBack:alertView clickedButtonAtIndex:buttonIndex];
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
    NSInteger conflictsCount = [ResolveConflictsHelper getConflictsCount];
    
    if (conflictsCount > 0) {
        contiuneDataSync = [ResolveConflictsHelper checkResolvedConflicts];
    }
    return contiuneDataSync;
}


- (NSString *)nextScheduledDataSyncTime
{
    NSString *nextSyncTime = @"--";
    
    if (self.dataSyncTimer == nil)
    {
        [self scheduleDataSync];
    }
    
    if (self.dataSyncTimer != nil)
    {

        NSDate *date = [[self dataSyncTimer] fireDate];
        if (date != nil)
        {
            nextSyncTime = [DateUtil getUserReadableDateForSyncStatus:date];
        }
    }
    return nextSyncTime;
}


- (NSString *)nextScheduledConfigSyncTime
{
    NSString *nextSyncTime = @"--";
    
    if (self.configSyncTimer == nil)
    {
        [self scheduleConfigSync];
    }

    if (self.configSyncTimer != nil)
    {
        NSDate *date = [[self configSyncTimer] fireDate];
        if (date != nil)
        {
            nextSyncTime = [DateUtil getUserReadableDateForSyncStatus:date];
        }
    }
    return nextSyncTime;
}

@end
