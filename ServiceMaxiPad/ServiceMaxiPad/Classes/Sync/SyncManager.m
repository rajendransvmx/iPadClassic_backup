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


const NSInteger alertViewTagForDataSync     = 888888;
const NSInteger alertViewTagForConfigSync   = 888889;
const NSInteger alertViewTagForInitialSync  = 888890;

NSString *kInitialSyncStatusNotification    = @"InitialSyncStatus";
NSString *kConfigSyncStatusNotification     = @"ConfigSyncStatus";
NSString *kDataSyncStatusNotification       = @"DataSyncStatus";
NSString *kEventSyncStatusNotification      = @"EventSyncStatus";
NSString *kProfileValidationStatusNotification = @"ProfileValidationStatus";

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

@synthesize dataSetForMigration;


#pragma mark - Sync Meta Data
- (NSString*)getSyncMetaDataFilePath
{
//    NSString *appDirPath = [(AppDelegate*)[[UIApplication sharedApplication] delegate] getAppCustomSubDirectory];
    //return [appDirPath stringByAppendingPathComponent:syncMetaDataFile];
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


- (NSUInteger)getConflictsCount
{
    return 0;
}

- (NSArray*)getConflictsList
{
    return nil;
}

#pragma mark - Private methods - internally used

- (void)performInitialSync
{
    [self prepareDatabaseForInitialSync];
    
    [self showNetworkActivityIndicator:YES];
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
    [self showNetworkActivityIndicator:YES];
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
        [self showNetworkActivityIndicator:NO];
    }
    else  if ( (responseStatus.syncStatus == SyncStatusFailed) ||  (responseStatus.syncStatus == SyncStatusNetworkError))
    {
        SXLogDebug(@"Initial Sync failed");
        [self currentInitialSyncFailedWithError:responseStatus.syncError];
        
        [self showNetworkActivityIndicator:NO];
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
        [self showNetworkActivityIndicator:NO];
        
        [[AppManager sharedInstance] loadScreen];
    
    }
    else  if (responseStatus.syncStatus == SyncStatusFailed ||  responseStatus.syncStatus == SyncStatusNetworkError)
    {
        SXLogDebug(@"Config Sync failed");
        [[DatabaseConfigurationManager sharedInstance] postMetaSyncDatabaseConfigurationByResult:NO];
        [self currentConfigSyncFailedWithError:responseStatus.syncError];
        [self showNetworkActivityIndicator:NO];
    }
}



#pragma mark - Flow delegates
/*
- (void)flowStatus:(id)status
{
    if([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        NSString *notification = nil;
        
        WebserviceResponseStatus *st = (WebserviceResponseStatus*)status;
        BOOL shouldNotify = YES;
      
        switch (st.category) {
            
            case CategoryTypeOneCallRestInitialSync:
            case CategoryTypeInitialSync:
            case CategoryTypeResetApp:
  

            
                self.initialSyncStatus = st.syncStatus;
                notification = kInitialSyncStatusNotification;
                
                if (st.syncStatus == SyncStatusSuccess) {
                    NSLog(@"Initial Sync Finished");
                    [self currentInitialSyncFinished];
                }
                else  if (st.syncStatus == SyncStatusFailed ||  st.syncStatus == SyncStatusNetworkError) {
                    NSLog(@"Initial Sync failed");
                    [self currentInitialSyncFailedWithError:st.syncError];
                }
                break;
            case CategoryTypeValidateProfile:
            {
                //self.initialSyncStatus = st.syncStatus;
                notification = kProfileValidationStatusNotification;
                
                if (st.syncStatus == SyncStatusSuccess) {
                    NSLog(@"Profile validation Finished");
                    //[self currentInitialSyncFinished];
                }
                else  if (st.syncStatus == SyncStatusFailed ||  st.syncStatus == SyncStatusNetworkError) {
                    NSLog(@"Profile validation failed");
                    [self profileValidationFailedWithError:st.syncError];

                }
                break;
            }

            case CategoryTypeDataSync:
            case CategoryTypeOneCallDataSync:
                
                self.dataSyncStatus = st.syncStatus;
                notification = kDataSyncStatusNotification;
                shouldNotify = NO;
                
                if (st.syncStatus == SyncStatusSuccess) {
                    NSLog(@"Data Sync Finished");
                    [self currentDataSyncfinished];
                }
                else  if (st.syncStatus == SyncStatusFailed ||  st.syncStatus == SyncStatusNetworkError) {
                    NSLog(@"Data Sync failed");
                    [self currentDataSyncFailedWithError:st.syncError];
                }
                break;
                
                
            case CategoryTypeEventSync:
                break;
                
            case CategoryTypeConfigSync:
            case CategoryTypeOneCallConfigSync:
            case CategoryTypeIncrementalOneCallMetaSync:
                self.configSyncStatus = st.syncStatus;
                notification = kConfigSyncStatusNotification;
                if (st.syncStatus == SyncStatusSuccess) {
                    NSLog(@"Config Sync Finished");
                    [self currentConfigSyncFinished];
                }
                else  if (st.syncStatus == SyncStatusFailed ||  st.syncStatus == SyncStatusNetworkError) {
                    NSLog(@"Config Sync failed");
                    [self currentConfigSyncFailedWithError:st.syncError];
                }
                break;
                
            default:
                break;
        }
        
        if (shouldNotify) {
            SyncProgressStatusHandler *syncProHandler = [[SyncProgressStatusHandler alloc] init];
            SyncProgressDetailModel *syncProModel = [syncProHandler getProgressDetailsForStatus:status];
            
            NSDictionary *syncStatus = [NSDictionary dictionaryWithObject:syncProModel forKey:@"syncstatus"];
            [self sendNotification:notification andUserInfo:syncStatus];
        }
       
    }
}

 
*/

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

#pragma mark - Data Sync Functions
- (BOOL)initiateDataSync {
    
    @synchronized([self class])
    {
        if (self.isDataSyncRunning)
        {
            SXLogInfo(@" Data sync is already running ");
            return NO;
        }
        else
        {
            self.isDataSyncRunning = YES;
            [PlistManager storeLastDataSyncStatus:@"In Progress"];
            [self performSelectorInBackground:@selector(initiateSyncInBackGround) withObject:nil];
        }
        return YES;
    }
}

- (void)currentDataSyncfinished {
    
    @synchronized([self class]) {

        [[SuccessiveSyncManager sharedSuccessiveSyncManager] doSuccessiveSync];

        [self updateLastSyncTime];
        
        BOOL didRestart = [self restartDataSyncIfNecessary];
        
        if (!didRestart) {
            
            self.isDataSyncRunning = NO;
            
            [PlistManager removeLastLocalIdFromDefaults];
            
            [self showNetworkActivityIndicator:NO];
              [self resetNetworkIndicator];
            [self updatePlistWithLastDataSyncTimeAndStatus:[[TagManager sharedInstance] tagByName:kTagPushLogStatusSuccess]];
            /* Send data sync Success notification */
            [self sendNotification:kDataSyncStatusNotification andUserInfo:nil];
            
            /* Clear user deafults utility */
            [PlistManager clearAllWhatIdObjectInformation];
        }
    }
}


- (void)currentDataSyncFailedWithError:(NSError *)error {
    
    @synchronized([self class]) {
        
        [self updatePlistWithLastDataSyncTimeAndStatus:[[TagManager sharedInstance] tagByName:kTagPushLogStatusFailed]];
       
        [self showNetworkActivityIndicator:NO];
        [self resetNetworkIndicator];
         self.isDataSyncRunning = NO;
        
        /* Send data sync Failure notification */
        [self sendNotification:kDataSyncStatusNotification andUserInfo:nil];
        
        [[AlertMessageHandler sharedInstance] showCustomMessage:[error errorEndUserMessage] withDelegate:nil tag:alertViewTagForConfigSync title:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage] cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] andOtherButtonTitles:nil];
    }
}

- (void)initiateSyncInBackGround {
    
    [self showNetworkActivityIndicator:YES];
    
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
        
        [PlistManager moveDataSyncTimeFromTemp];
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

#pragma mark -End
#pragma mark - Config Sync Functions

- (void)currentConfigSyncFinished
{
    [[LocationPingManager sharedInstance] stopLocationPing];
    [[LocationPingManager sharedInstance] startLocationPing];
    [self updatePlistWithLastConfigSyncTimeAndStatus:[[TagManager sharedInstance] tagByName:kTagPushLogStatusSuccess]];
}

- (void)currentConfigSyncFailedWithError:(NSError *)error
{
    [self updatePlistWithLastConfigSyncTimeAndStatus:[[TagManager sharedInstance] tagByName:kTagPushLogStatusFailed]];
   
    if (error) {
        //if (error.actionCategory == SMErrorActionCategoryAuthenticationReopenSession) {
        //Try to get new access token and retrigger sync. Ideally this should happen within flow node.
        //}
        [[AlertMessageHandler sharedInstance] showCustomMessage:[error errorEndUserMessage] withDelegate:self tag:alertViewTagForConfigSync title:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage] cancelButtonTitle:nil andOtherButtonTitles:@[[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]]];
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


#pragma mark -End
#pragma mark - Initial Sync Functions

- (void)currentInitialSyncFinished
{
    [[AppManager sharedInstance] setApplicationStatus:ApplicationStatusInitialSyncCompleted];
    [self updatePlistWithLastDataSyncTimeAndStatus:[[TagManager sharedInstance] tagByName:kTagPushLogStatusSuccess]];
    [self updatePlistWithLastConfigSyncTimeAndStatus:[[TagManager sharedInstance] tagByName:kTagPushLogStatusSuccess]];
    [[LocationPingManager sharedInstance] stopLocationPing];
    [[LocationPingManager sharedInstance] startLocationPing];
}

- (void)currentInitialSyncFailedWithError:(NSError *)error
{
    // Yoo initial sync failed!! Lets remove incompleted data 
    [[DatabaseConfigurationManager sharedInstance] performDatabaseConfigurationForSwitchUser];
    
    [[AppManager sharedInstance] setApplicationFailedStatus:ApplicationStatusInitialSyncFailed];
    
    [self updatePlistWithLastDataSyncTimeAndStatus:[[TagManager sharedInstance] tagByName:kTagPushLogStatusFailed]];
    [self updatePlistWithLastConfigSyncTimeAndStatus:[[TagManager sharedInstance] tagByName:kTagPushLogStatusFailed]];
    
    if (error) {
        
        [[AlertMessageHandler sharedInstance] showCustomMessage:[error errorEndUserMessage]
                                                   withDelegate:self
                                                            tag:alertViewTagForInitialSync
                                                          title:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage]
                                              cancelButtonTitle:nil
                                           andOtherButtonTitles:@[[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]]];//HS added 23 oct
    }
}

//Error handling for Profile Validaton
- (void)profileValidationFailedWithError:(NSError *)error
{
    if (error) {
        //if (error.actionCategory == SMErrorActionCategoryAuthenticationReopenSession) {
        //Try to get new access token and retrigger sync. Ideally this should happen within flow node.
        //}
        //[[AlertMessageHandler sharedInstance] showCustomMessage:[error errorEndUserMessage] withDelegate:self tag:alertViewTagForInitialSync title:@"Error" cancelButtonTitle:nil andOtherButtonTitles:@[@"Retry",@"Sign Out"]]; //HS commented on 23 Oct for new change of OK instead of Signout button.
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage] message:[error errorEndUserMessage] delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles:nil];
        [alertView show];
        
        [[AlertMessageHandler sharedInstance] showCustomMessage:[error errorEndUserMessage]
                                                   withDelegate:nil
                                                            tag:alertViewTagForInitialSync
                                                          title:@"Error"
                                              cancelButtonTitle:@"OK"
                                           andOtherButtonTitles:nil];
        //[[AlertMessageHandler sharedInstance] showCustomMessage:[error errorEndUserMessage] withDelegate:self tag:alertViewTagForInitialSync title:@"Error" cancelButtonTitle:nil andOtherButtonTitles:@[@"OK"]];//HS added 23 oct
    }
}

- (void)updatePlistWithLastConfigSyncTimeAndStatus:(NSString *)status
{
    if (status)
    {
        [PlistManager storeLastConfigSyncGMTTime:[DateUtil getDatabaseStringForDate:[NSDate date]]];
        [PlistManager storeLastConfigSyncStatus:status];
    }
}

/* HS 23 Oct commmented to handle OK button
- (void)handleInitialSyncAlertViewCallBack:(UIAlertView *)alertView
                      clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
        {
            //Retry
            [[DatabaseConfigurationManager sharedInstance] postMetaSyncDatabaseConfigurationByResult:false];
            [self performSyncWithType:SyncTypeInitial];
        }
            break;
        case 1:
        {
            //Sign Out
            [self performSelectorOnMainThread:@selector(performLoggout) withObject:nil waitUntilDone:NO];
        }
        default:
            break;
    }
}
 */

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


#pragma mark - Start/Stop network activity Indicator
- (void)showNetworkActivityIndicator:(BOOL)show
{
    @synchronized([self class])
    {
        if (show) {
            [[SVMXSystemUtility sharedInstance] performSelectorOnMainThread:@selector(startNetworkActivity)
                                                                 withObject:nil
                                                              waitUntilDone:NO];
        }
        else
        {
            [[SVMXSystemUtility sharedInstance] performSelectorOnMainThread:@selector(stopNetworkActivity)
                                                                 withObject:nil
                                                              waitUntilDone:NO];
        }
    }
}

- (void)resetNetworkIndicator {
    [[SVMXSystemUtility sharedInstance] performSelectorOnMainThread:@selector(resetNetworkActivityIndiator)
                                                         withObject:nil
                                                      waitUntilDone:NO];
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


#pragma mark - Data Migration

- (void)populateDataForMigration
{
   self.dataSetForMigration = [DataMigrationHelper fetchMigrationMetaDataFromOldDatabase];
}

- (NSDictionary *)dataSetForDataMigration
{
    return self.dataSetForMigration;
}

- (void)resetDataMigration
{
    self.dataSetForMigration = nil;
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


@end
