//
//  SMDataPurgeManager.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 12/31/13.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "SMDataPurgeManager.h"
#import "SVMXSystemConstant.h"
#import "SMDataPurgeResponse.h"
#import "SMDataPurgeRequest.h"
#import "AppDelegate.h"
//#import "iOSInterfaceObject.h"
#import "SMDataPurgeModel.h"
#import "SMObjectRelationModel.h"
#import "Utility.h"
#import "SMObjectRelationModel.h"

static dispatch_once_t _sharedInstanceGuard;
static SMDataPurgeManager *_instance;

const int percentage = 5;
const float progress = 0.05;

@interface SMDataPurgeManager()

//
- (void)cancelDataPurgeSinceSyncInProgress;
- (void)restartDataPurge;

- (void)registerForServiceMaxSyncNotification;
- (void)deregisterForServiceMaxSyncNotification;

// WebService Call
- (void)makeWSForConfiguationModifiedDate;
- (void)makeWSForDownloadCriteriaWithCallBack:(SMDataPurgeCallBackData *)callBackData;
- (void)makeWSForAdvancedDownloadCriteriaWithCallBack:(SMDataPurgeCallBackData *)callBackData;
- (void)makeWSForCleanupService;
- (void)makeWSForGetPriceWithCallBack:(SMDataPurgeCallBackData *)callBackData;;

- (BOOL)isConfigSyncToBeDone:(NSString *)lastServerConfigTime;
- (NSComparisonResult)compareLastSyncConfigTime:(NSDate *)lastConfigTime withModifiedSyncConfigTime:(NSDate *)configTime;

- (BOOL)isRescheduled;

//Get puring time
- (NSString *)getLocalTimeWithUserReadableFormat:(NSDate *)gmtDate;

//Set call back objects
-(SMDataPurgeCallBackData *)getCallBackObject:(SMDataPurgeResponse *)response;

//SetPurgeMap;
- (void)setPurgeMapWithResponseDict:(NSMutableDictionary *)resultDict;
- (SMDataPurgeModel *)getPurgeModelForObjectName:(NSString *)objecName;

- (void)fillKeyPrefixMapWithObjectName;
- (void)emptyKeyPrefixDictionary;
- (void)fillEventRelatedDataForPurgeMap;
- (void)fillGracePeriodRecordsForPurgeMap;
//- (void)fillNonGracePeriodRecordsForPurgeMap;

- (void)findAndFillChildObjectRecordForSave;
- (void)findAndFillReferenceObjectRecordForSave;

- (void)identifyingDataToRemove;
- (void)startPurgeDatabase;

- (void)cleanupDataPurgeManager;
- (void)updateGraceLimitDate;
- (void)setLastDataPurgeTime;
- (void)updateDataPurgeTimeAndCleanUpManager;
- (void)validateRecordCountForModel:(SMDataPurgeModel *)model;

- (void)seggregateNonPurgeableRecords:(BOOL)isFinal;

- (void)scheduleDataPurgeTimer:(NSTimeInterval)interval;
- (void)invalidateDataPurgeTimer;

//Post notification when one web service completes
- (void) postNotificationToUpdateProgressBar;

@end

@implementation SMDataPurgeManager

@synthesize purgeMap;
@synthesize configLastModifiedDate;
@synthesize requestId;
@synthesize purgeStatus;
@synthesize isScheduledPurging;
@synthesize activeRequest;
@synthesize keyPrefixObjectName;
@synthesize graceLimitDate;
@synthesize dataPurgeTimer;
@synthesize conflictRecordMap;
@synthesize isCleanUpDataBaseRequired;

- (id)init
{
    return [SMDataPurgeManager sharedInstance];
}


- (id)initializeDataPurgeManager
{
    self = [super init];
    
    if (self)
    {
        self.purgeStatus = DataPurgeStatusCompleted;
        self.isCleanUpDataBaseRequired = NO;
        [self registerForServiceMaxSyncNotification];
    }
    return self;
}


+ (SMDataPurgeManager *)sharedInstance
{
    dispatch_once(&_sharedInstanceGuard,
                  ^{
                      _instance = [[SMDataPurgeManager alloc] initializeDataPurgeManager];
                  });
    return _instance;
}


- (void)dealloc
{
    [configLastModifiedDate release];
    [requestId release];
    [purgeMap release];
    [activeRequest release];
    [graceLimitDate release];
    [dataPurgeTimer release];
    [conflictRecordMap release];
    [super dealloc];
}


- (void)manageDataPurge
{
    @synchronized([self class])
    {
        switch (self.purgeStatus)
        {
            case DataPurgeStatusScheduled:
            {
                [self makeWSForConfiguationModifiedDate];
                break;
            }
                
            case DataPurgeStatusWSForLastModifiedDate:
            {
                [self makeWSForDownloadCriteriaWithCallBack:nil];
                break;
            }
                
            case DataPurgeStatusWSForDownloadCriteria:
            {
                [self makeWSForAdvancedDownloadCriteriaWithCallBack:nil];
                break;
            }
                
            case DataPurgeStatusWSForAdvancedDownloadCriteria:
            {
                [self makeWSForGetPriceWithCallBack:nil];
                break;
            }
                
            case DataPurgeStatusWSForGetPrice:
            {
                [self makeWSForCleanupService];
                break;
            }
                
            case DataPurgeStatusWSForCleanup:
            {
                self.purgeStatus = DataPurgeStatusDataProcessing;
                
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
        
        
        if (self.purgeStatus == DataPurgeStatusCompleted)
        {
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //code to be executed on the main queue after delay
                [self postNotificationToRemoveProgressBar];
            });
        }
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
    if (self.activeRequest != nil)
    {
        self.activeRequest = nil;
    }
    if(self.conflictRecordMap != nil)
    {
        [self.conflictRecordMap removeAllObjects];
        self.conflictRecordMap = nil;
    }
    [self emptyKeyPrefixDictionary];
    
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
        [self fillNonGracePeriodTrailerTableRecords];
        //[self fillNonGracePeriodRecordsForPurgeMap];
        
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
                    SMLog(kLogLevelVerbose, @" Error on pruging %@", apiNames);
                    failed = YES;
                }
            }
        }
        if (!failed)
        {
            [SMDataPurgeHelper saveDataPurgeStatusSinceCompleted:[Utility getValueForTagFromTagDict:Data_Purge_Status_Success]];
        }
        else
        {
            [SMDataPurgeHelper saveDataPurgeStatusSinceCompleted:[Utility getValueForTagFromTagDict:Data_Purge_Status_Failed]];
        }
        
        self.purgeStatus = DataPurgeStatusCompleted;
        
        [self manageDataPurge];
        SMLog(kLogLevelVerbose, @" Completed Data Purging");
    }
}


- (void)updateDataPurgeTimeAndCleanUpManager
{
    [self setLastDataPurgeTime];
    [self updateTimerAndNextDPTime:[NSDate date]];
    [self generatePurgeReport];
    [self cleanUpDataBase];
    [self cleanupDataPurgeManager];
    [self clearIfPurgeDueFlagSet];
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

    if (self.purgeStatus != DataPurgeStatusCompleted)
    {
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
    [SMDataPurgeHelper saveDataPurgeStatusSinceCompleted:[Utility getValueForTagFromTagDict:Data_Purge_Status_Canceled]];
    self.purgeStatus = DataPurgeStatusCompleted;
    
    [self updateTimerAndNextDPTime:[NSDate date]];
    [self clearIfPurgeDueFlagSet];
    double delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        NSLog(@"stopDataPurge - Calling clean up");
        [self cleanupDataPurgeManager];
    });
}


- (void)purgeInititate
{
    if(self.isSyncInProgress)
    {
        self.purgeStatus = DataPurgeStatusPurgingRescheduled;
    }
    else
    {
        [self postDataPurgeStartedNotification];
        self.purgeStatus = DataPurgeStatusScheduled;
        [self updateGraceLimitDate];
        [self generateRequestIdentifier];
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


//9862 - Defect Fix
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
    }
}


- (void)clearDueIfConfigSyncSuccess
{
    [self clearIfPurgeDueFlagSet];
    self.isCleanUpDataBaseRequired = NO;
}


#pragma mark - SMDataPurgeRequestDelegate Method

- (void)request:(SMDataPurgeRequest *)request completedWithResponse:(SMDataPurgeResponse *)response
{
    if ([self isRescheduled])
    {
        return;
    }
    
    if ([response.resultObjectNameToObjectDictionary count] > 0)
    {
        [self setPurgeMapWithResponseDict:response.resultObjectNameToObjectDictionary];
    }
    
    if ([request.eventName isEqualToString:kWSDataPurgeEventNameConfigLastModifiedTime])
    {
        BOOL result = [self isConfigSyncToBeDone:response.lastConfigTime];
        if (result)
        {
            //Radha - Cancel data purge and show the aler view
            if (![self isRescheduled])
            {
                self.purgeStatus = DataPurgeStatusRequiredConfigUpdate;
            }
            [SMDataPurgeHelper saveDataPurgeStatusSinceCompleted:[Utility getValueForTagFromTagDict:Data_Purge_Status_Failed]];
            [self manageDataPurge];
        }
        else
        {
            [self manageDataPurge];
        }
    }
    else if ([request.eventName isEqualToString:kWSDataPurgeEventNameDownloadCriteria])
    {
        if ([response hasMoreData])
        {
            SMDataPurgeCallBackData * callBackData = [[self getCallBackObject:response] retain];
            [self makeWSForDownloadCriteriaWithCallBack:callBackData];
            [callBackData release];
        }
        else
        {
            [self manageDataPurge];
        }
     
    }
    else if ([request.eventName isEqualToString:kWSDataPurgeEventNameAdvancedDownloadCriteria])
    {
        if ([response hasMoreData])
        {
            SMDataPurgeCallBackData * callBackData = [[self getCallBackObject:response] retain];
            [self makeWSForAdvancedDownloadCriteriaWithCallBack:callBackData];
            [callBackData release];
        }
        else
        {
            [self manageDataPurge];
        }
    }
    else if ([request.eventName isEqualToString:kWSDataPurgeEventNameGetPrice])
    {
        SMDataPurgeCallBackData * callBackData = nil;
        if ([response hasMoreData])
        {
            callBackData = [[self getCallBackObject:response] retain];
            [self makeWSForGetPriceWithCallBack:callBackData];
            [callBackData release];
        }
        else if ([request.index isEqualToString:@"0"])
        {
            callBackData = [[self getCallBackObject:response] retain];
            callBackData.lastIndex = @"1";
            [self makeWSForGetPriceWithCallBack:callBackData];
            [callBackData release];
        }
        else if ([request.index isEqualToString:@"1"])
        {
            callBackData = [[self getCallBackObject:response] retain];
            callBackData.lastIndex = @"2";
            [self makeWSForGetPriceWithCallBack:callBackData];
            [callBackData release];
        }
        else
        {
            [self manageDataPurge];
        }
    }
    else if ([request.eventName isEqualToString:kWSDataPurgeEventNameCleanUp])
    {
        [self manageDataPurge];
    }
}


- (void)request:(SMDataPurgeRequest *)request failedWithError:(SMDataPurgeResponseError *)error
{
    if ([self isRescheduled])
    {
        return;
    }
    
    [SMDataPurgeHelper saveDataPurgeStatusSinceCompleted:[Utility getValueForTagFromTagDict:Data_Purge_Status_Failed]];
    
    if (![self isRescheduled])
    {
        self.purgeStatus = DataPurgeStatusFailed;
    }
    
    
    ALERT_VIEW_ERROR var = APPLICATION_ERROR;
    
    if ([error isSystemError] || [error isSoapFault])
    {
        var = SOAP_ERROR;
    }
    else if ( [error isResponseError])
    {
        var = RES_ERROR;
    }
    
    if ([error isInternetNotReachableError])
    {
        
        NSString * title = [Utility getValueForTagFromTagDict:alert_application_error];
        NSString * message = (error.message != nil)?error.message:@"";
        NSString * cancel = [Utility getValueForTagFromTagDict:ALERT_ERROR_OK];
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:nil, nil];
        [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
        [alertView release];

    }
    else
    {
        NSMutableDictionary * errodict = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        [errodict setObject:(error.type != nil)?error.type:@"" forKey:@"ExpName"];
        [errodict setObject:(error.message != nil)?error.message:@"" forKey:@"ExpReason"];
        [errodict setObject:error.userInfoDict forKey:@"userInfo"];
        
        [appDelegate CustomizeAletView:nil alertType:var Dict:errodict exception:nil];
        
        [errodict release];
    }
    
    self.purgeStatus = DataPurgeStatusCompleted;
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        NSLog(@"failedWithError - Calling updateDataPurgeTimeAndCleanUpManager");
        [self updateDataPurgeTimeAndCleanUpManager];
    });
}


- (void)generateRequestIdentifier
{
    if (self.requestId != nil)
    {
        self.requestId = nil;
    }
    self.requestId = [AppDelegate GetUUID];
}


#pragma mark - Data Purging Initiate

- (void)startMannualPurging
{

    if ((self.purgeStatus == DataPurgeStatusCompleted)
        || [self isDataPurgeInDue])
    {
        [[ZKServerSwitchboard switchboard] doCheckSession];
        self.isScheduledPurging = NO;
        [self purgeInititate];
    }
}


- (void)startSchedulePurging
{
    NSLog(@"Status = %d", self.purgeStatus);
    if ((self.purgeStatus == DataPurgeStatusCompleted)
        || [self isDataPurgeInDue])
    {
        NSLog(@"do check session data purge started");
        [[ZKServerSwitchboard switchboard] doCheckSession];
        self.isScheduledPurging = YES;
        [self purgeInititate];
    }
}

- (void)scheduleDataPurge
{
    self.purgeStatus = DataPurgeStatusDue;
    self.isScheduledPurging = YES;
    [self postDataPurgeDueNotification];
    
}


#pragma mark - Data Purging Web ServiceCall

- (void)makeWSRequestWithData:(SMDataPurgeCallBackData *)callBackData
{
    if ([self isRescheduled])
    {
        return;
    }
    
    SMDataPurgeRequest *request = [[SMDataPurgeRequest alloc] initWithRequestIdentifier:self.requestId withCallBackValues:callBackData];
    request.requestDelegate = self;
    self.activeRequest = request;
    [request release];
}


- (void)makeWSForConfiguationModifiedDate
{
    if ([self isRescheduled])
    {
        return;
    }
    
    [self makeWSRequestWithData:nil];
    self.purgeStatus = DataPurgeStatusWSForLastModifiedDate;
    [self.activeRequest makeConfigurationLastModifiedDateRequest];
}


- (void)makeWSForDownloadCriteriaWithCallBack:(SMDataPurgeCallBackData *)callBackData
{
    if ([self isRescheduled])
    {
        return;
    }
    
    [self makeWSRequestWithData:callBackData];
    self.purgeStatus = DataPurgeStatusWSForDownloadCriteria;
    [self.activeRequest makeDownloadCriteriaRequest];
}


- (void)makeWSForAdvancedDownloadCriteriaWithCallBack:(SMDataPurgeCallBackData *)callBackData
{
    if ([self isRescheduled])
    {
        return;
    }
    
    [self makeWSRequestWithData:callBackData];
    self.purgeStatus = DataPurgeStatusWSForAdvancedDownloadCriteria;
    [self.activeRequest makeAdvancedDownloadCriteriaRequest];
}


- (void)makeWSForGetPriceWithCallBack:(SMDataPurgeCallBackData *)callBackData
{
    if ([self isRescheduled])
    {
        return;
    }
    
    self.purgeStatus = DataPurgeStatusWSForGetPrice;
    
    NSString * priceValue = [Utility getValueForSettingIdFromDict:@"IPAD018_SET009"];
    if ([priceValue caseInsensitiveCompare:@"True"] == NSOrderedSame)
    {
        [self makeWSRequestWithData:callBackData];
        [self.activeRequest makeGetPriceRequest];
    }
    else
    {
        [self manageDataPurge];
    }
}


- (void)makeWSForCleanupService
{
    if ([self isRescheduled])
    {
        return;
    }
    
    [self makeWSRequestWithData:nil];
    self.purgeStatus = DataPurgeStatusWSForCleanup;
    [self.activeRequest makeCleanUpRequest];
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
    if (self.purgeStatus == DataPurgeStatusDue)
    {
        return YES;
    }
    return NO;
}


- (BOOL)isDataPurgeScheduled
{
    if ([[Utility getValueForSettingIdFromDict:kWSAPIResponseDataPurgeFrequency] isEqualToString:@"0"])
    {
        return NO;
    }
    return YES;
}

- (BOOL)isdataPurgeSuccess
{
    NSString * value = [Utility getValueForTagFromTagDict:Data_Purge_Status_Success];
    if ([[SMDataPurgeHelper lastDataPurgeStatus] isEqualToString:value])
    {
        return YES;
    }
    
    return NO;
}

- (NSString *)dataPurgeDueMessage
{
    return [Utility getValueForTagFromTagDict:Data_Purge_Due];
}


- (void)reschedulePurgingForNextInterval:(NSDate *)date
{
    self.purgeStatus = DataPurgeStatusCompleted; //9862 - Defect Fix
    //Invalidate timer and reschedule timer for next interval
    [self updateTimerAndNextDPTime:date];
    
    [self clearIfPurgeDueFlagSet];
}


- (NSString *)getLastDataPurgeTime
{
    //get lastpurge from userdefaults
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
    //get nextpurge from userdefaults
    
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
        nexttDpTime = [Utility getValueForTagFromTagDict:Not_Scheduled];
    }
    
    
    return  nexttDpTime;
}


- (NSString *)getLastDataPurgeStatus
{
    //get status from helper class
    return [SMDataPurgeHelper lastDataPurgeStatus];
}


- (NSString *)getLocalTimeWithUserReadableFormat:(NSDate *)gmtDate
{
    NSString * dateInString = [Utility getUserReableStringFromDate:gmtDate];
    return dateInString;
}


- (BOOL)isConfigSyncToBeDone:(NSString *)lastServerConfigTime
{
    configLastModifiedDate  = [Utility getDatetimeFromString:lastServerConfigTime];
    
    NSDate * lastConfigDate = [SMDataPurgeHelper lastSuccessConfigSyncTimeForDataPurge];
    
    SMLog(kLogLevelVerbose, @"Last Server Modified Time = %@  Last Client Config Sync Time = %@", lastServerConfigTime, lastConfigDate);
    
    if (lastConfigDate != nil && configLastModifiedDate != nil)
    {
        NSComparisonResult compare = [self compareLastSyncConfigTime:lastConfigDate withModifiedSyncConfigTime:configLastModifiedDate];
        
        if (compare == NSOrderedSame || compare == NSOrderedAscending)
        {
            return YES;
        }
    }
    return NO;
}


- (BOOL)isRescheduled
{
    if (self.purgeStatus == DataPurgeStatusPurgingRescheduled)
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


- (SMDataPurgeCallBackData *)getCallBackObject:(SMDataPurgeResponse *)response
{
    SMDataPurgeCallBackData * callBacKObject = [[SMDataPurgeCallBackData alloc] init];

    if ([response.lastIndex length] > 0)
    {
        [callBacKObject setLastIndex:response.lastIndex];
    }
    
    if ([response.values count] > 0)
    {
        [callBacKObject setValues:response.values];
    }

    if ([response.partialExecutedObjects count] > 0)
    {
        [callBacKObject setPartialExecutedObject:response.partialExecutedObjects];
        NSString * value = [response.partialExecutedObjects objectForKey:@"PARTIAL_EXECUTED_OBJECT"];
        [callBacKObject setPartialExecutedObjData:[response.resultDictionary objectForKey:value]];
    }
    
    return [callBacKObject autorelease];
}


- (void)setPurgeMapWithResponseDict:(NSMutableDictionary *)resultDict
{
    if (self.purgeMap == nil)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        self.purgeMap = dict;
        [dict  release];
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
    NSArray * purgeMapKey = [purgeMap allKeys];
    
    if ([purgeMapKey containsObject:objecName])
    {
        return [purgeMap objectForKey:objecName];
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
        [keyPrefixObjectName removeAllObjects];
        self.keyPrefixObjectName = nil;
    }
}


- (void)fillPurgeableRecordForPurgeMap
{
    NSArray * purgeKey = [purgeMap allKeys];
    
    @autoreleasepool
    {
        for (NSString * objectName in purgeKey)
        {
            [SMDataPurgeHelper purgeDataForObject:[purgeMap objectForKey:objectName]];
        }
    }
}


- (void)fillConflictRecordsForPurgeMap
{
    self.conflictRecordMap = [SMDataPurgeHelper retrieveConflictRecordMap];
    NSArray * purgeMapKey = [purgeMap allKeys];
    @autoreleasepool
    {
        for (NSString * objectName in purgeMapKey)
        {
            [SMDataPurgeHelper retrievePurgeableConflictRecordForModel:[purgeMap objectForKey:objectName] conflictMap:self.conflictRecordMap];
        }
    }

}


- (void)fillGracePeriodRecordsForPurgeMap
{
    NSString * filterCriteria = [[NSString alloc] initWithFormat:@"LastModifiedDate >= '%@'", self.graceLimitDate];
    NSString * trailerFilterCrirteria = [[NSString alloc] initWithFormat:@"timestamp >= '%@'", self.graceLimitDate];
    
    NSArray * purgeMapKey = [purgeMap allKeys];
    @autoreleasepool
    {
        for (NSString * objectName in purgeMapKey)
        {
           [SMDataPurgeHelper getAllGarceLimitRecrordsForModel:[purgeMap objectForKey:objectName] criteria:filterCriteria trialerCriteria:trailerFilterCrirteria];
        }
    }
    [filterCriteria release];
    [trailerFilterCrirteria release];
}

- (void)fillNonGracePeriodTrailerTableRecords //To be purged
{
    NSString * trailerCrirteria = [[NSString alloc] initWithFormat:@"timestamp < '%@'", self.graceLimitDate];
    
    NSArray * purgeMapKey = [purgeMap allKeys];
    @autoreleasepool
    {
        for (NSString * objectName in purgeMapKey)
        {
            [SMDataPurgeHelper getNonGracePeriodTrailerTableRecords:[purgeMap objectForKey:objectName] trailerCriteria:trailerCrirteria];
        }
    }
    [trailerCrirteria release];
}

/*- (void)fillNonGracePeriodRecordsForPurgeMap //To be purged
{
    NSString * filterCriteria = [[NSString alloc] initWithFormat:@"LastModifiedDate < '%@'", self.graceLimitDate];
    
    NSString * trailerFilerCrirteria = [[NSString alloc] initWithFormat:@"timestamp < '%@'", self.graceLimitDate];
    
    NSArray * purgeMapKey = [purgeMap allKeys];
    @autoreleasepool
    {
        for (NSString * objectName in purgeMapKey)
        {
            [SMDataPurgeHelper getAllNonGraceLimitRecrordsForModel:[purgeMap objectForKey:objectName] criteria:filterCriteria trialerCriteria:trailerFilterCrirteria];
        }
    }
    [filterCriteria release];
    [trailerFilterCrirteria release];
} */


- (void)fillNonPurgeableDODRecords
{
    NSArray * purgeMapKey = [purgeMap allKeys];
    NSString * filterCriteria = [[NSString alloc] initWithFormat:@"time_stamp >= '%@'", self.graceLimitDate];
  
    @autoreleasepool
    {
        for (NSString * objectName in purgeMapKey)
        {
            [SMDataPurgeHelper getAllGarceDODRecrds:[purgeMap objectForKey:objectName] filterCriteria:filterCriteria];
        }
    }
    [filterCriteria release];
    filterCriteria  = nil;
}


- (void)fillPurgeableDODRecords
{
    NSArray * purgeMapKey = [purgeMap allKeys];
    NSString * filterCriteria = [[NSString alloc] initWithFormat:@"time_stamp < '%@'", self.graceLimitDate];

    @autoreleasepool
    {
        for (NSString * objectName in purgeMapKey)
        {
            [SMDataPurgeHelper getAllNonGraceDODRecrds:[purgeMap objectForKey:objectName] filterCriteria:filterCriteria];
        }
    }
    [filterCriteria release];
    filterCriteria  = nil;
}


- (void)fillEventRelatedDataForPurgeMap
{
    NSMutableArray * eventIds = [[SMDataPurgeHelper getAllEventRelatedWhatId] retain];
    
    @autoreleasepool
    {
        for (NSString * whatId in eventIds)
        {
            NSString * keyPrefix = @"";
            if ([whatId length] > 3)
            {
                 keyPrefix = [whatId substringToIndex:3];
            }
            NSString * objectName = [keyPrefixObjectName valueForKey:keyPrefix];
            
            SMDataPurgeModel * purgeModel = [self getPurgeModelForObjectName:objectName];
            
            if (purgeModel != nil)
            {
                [purgeModel addEventsRelatedRecord:whatId];
                
                [self fillEventRelatedChildLine:purgeModel.purgeableChilds parentId:whatId parentName:objectName];
            }
        }
    }
    [eventIds release];
}


- (void)fillEventRelatedChildLine:(NSMutableArray *)childObjects parentId:(NSString *)Id parentName:(NSString *)parentObject
{
    @autoreleasepool
    {
        for (NSString * object in childObjects)
        {
            SMDataPurgeModel * purgeModel = [self getPurgeModelForObjectName:object];
            
            if (purgeModel != nil)
            {
                NSMutableArray * childIds = [[SMDataPurgeHelper getAllChildIdsForObject:object parentId:Id parentColumn:parentObject] retain];
                
                for (NSString * recordId in childIds)
                {
                    [purgeModel addChildRecordsOfEvents:recordId];
                }
                
                [childIds release];
                childIds = nil;
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
            [dict setValue:[Utility getValueForTagFromTagDict:DP_Progress_Config_WS] forKey:@"subtitle"];
            [dict setValue:[Utility getValueForTagFromTagDict:DP_Progress_Config_Data] forKey:@"subtitle1"];
            break;
        }
            
        case DataPurgeStatusWSForDownloadCriteria:
        {
            [dict setValue:[NSString stringWithFormat:@"%d%%", percentage*5] forKey:@"percentage"];
            [dict setValue:[NSString stringWithFormat:@"%f", progress*5] forKey:@"progress"];
            [dict setValue:[Utility getValueForTagFromTagDict:DP_Progress_DataBase_Validate] forKey:@"subtitle"];
            [dict setValue:[Utility getValueForTagFromTagDict:DP_Progress_DC] forKey:@"subtitle1"];

            break;
        }
            
        case DataPurgeStatusWSForAdvancedDownloadCriteria:
        {
            [dict setValue:[NSString stringWithFormat:@"%d%%", percentage*8] forKey:@"percentage"];
            [dict setValue:[NSString stringWithFormat:@"%f", progress*8] forKey:@"progress"];
            [dict setValue:[Utility getValueForTagFromTagDict:DP_Progress_DataBase_Validate] forKey:@"subtitle"];
            [dict setValue:[Utility getValueForTagFromTagDict:DP_Progress_ADC] forKey:@"subtitle1"];

            break;
        }
        case DataPurgeStatusWSForGetPrice:
        {
            [dict setValue:[NSString stringWithFormat:@"%d%%", percentage*12] forKey:@"percentage"];
            [dict setValue:[NSString stringWithFormat:@"%f", progress*12] forKey:@"progress"];
            [dict setValue:[Utility getValueForTagFromTagDict:DP_Progress_DataBase_Validate] forKey:@"subtitle"];
            [dict setValue:[Utility getValueForTagFromTagDict:DP_Progress_PriceData] forKey:@"subtitle1"];

            break;
        }
            
        case DataPurgeStatusRequiredConfigUpdate:
        {
            [dict setValue:[NSString stringWithFormat:@"%d%%", percentage] forKey:@"percentage"];
            [dict setValue:[NSString stringWithFormat:@"%f", progress] forKey:@"progress"];
            [dict setValue:[Utility getValueForTagFromTagDict:DP_Progress_Config_WS] forKey:@"subtitle"];
            [dict setValue:[Utility getValueForTagFromTagDict:DP_Progress_Congig_OutOfData] forKey:@"subtitle1"];
            [self showConfigSyncUpdateAlert];
            
            break;
        }
            
        case DataPurgeStatusDataProcessing:
        {
            [dict setValue:[NSString stringWithFormat:@"%d%%", percentage * 16] forKey:@"percentage"];
            [dict setValue:[NSString stringWithFormat:@"%f", progress*16] forKey:@"progress"];
            [dict setValue:[Utility getValueForTagFromTagDict:DP_Progress_DataBase_CleanUp] forKey:@"subtitle"];
            [dict setValue:[Utility getValueForTagFromTagDict:DP_Progress_Get_Data] forKey:@"subtitle1"];
            break;
        }
            
        case DataPurgeStatusCompleted:
        {
            [dict setValue:[NSString stringWithFormat:@"%d%%", percentage * 20] forKey:@"percentage"];
            [dict setValue:[NSString stringWithFormat:@"%f", progress*20] forKey:@"progress"];
            [dict setValue:[Utility getValueForTagFromTagDict:DP_Progress_DataBase_CleanUp] forKey:@"subtitle"];
            [dict setValue:[Utility getValueForTagFromTagDict:DP_Progress_Remove_Data] forKey:@"subtitle1"];
            break;
        }
            
        default:
            break;
    }
    
    return [dict autorelease];
}


- (void)showConfigSyncUpdateAlert
{
    NSString * title = [Utility getValueForTagFromTagDict:ALERT_ERROR_TITLE];
    NSString * cancel = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:DP_Progress_Congig_OutOfData];
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:nil, nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    [alertView release];
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
    
    NSString * criteria = [Utility getValueForSettingIdFromDict:kWSAPIResponseDataPurgeRecordOlderThan];
    
    int value = [criteria intValue];
    
    if (value != 0)
    {
        NSDate * olderThen = [currentDateTime dateByAddingTimeInterval:(-value * 24 * 60 * 60)];
        
        NSString * date = [Utility getStringFromDate:olderThen];
        if (date != nil || [date length] > 0)
        {
            date = [date stringByReplacingCharactersInRange:NSMakeRange(10, 1) withString:@"T"];
            date = [date stringByAppendingString:@".000+0000"];
            
            [self setGraceLimitDate:date];
        }
        else
        {
            [self setGraceLimitDate:@""];
        }
    }
    SMLog(kLogLevelVerbose, @"GraceLimtDate = %@", graceLimitDate);
}


- (void)fillPurgeMapWithApiName
{
    if (self.purgeMap == nil)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        self.purgeMap = dict;
        [dict  release];
    }

    NSArray *allTransactionalObjects = [[SMDataPurgeHelper getAllTransactionalObjectName] retain];
    
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
                    [model release];
                }
            }
        }
    }
    [allTransactionalObjects release];
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
            && (! model.isTaskObject))
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
        self.dataPurgeTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(scheduleDataPurge) userInfo:nil repeats:NO];
    }
}


- (void)invalidateDataPurgeTimer
{
    if ([self.dataPurgeTimer isValid])
    {
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
    SMLog(kLogLevelVerbose,@"DP date = %@", date);
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
                SMLog(kLogLevelVerbose,@"interval = %f", interval);
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
    NSTimeInterval scheduleTimeInterval = [Utility getTimerIntervalForDataPurge];
    
    NSDate * nextDPTime = dataPurgeTime;
    do
    {
        nextDPTime = [NSDate dateWithTimeInterval:scheduleTimeInterval sinceDate:nextDPTime];
    }
    while ([nextDPTime compare:date] == ( NSOrderedAscending));
    
    SMLog(kLogLevelVerbose,@"NextDPTime %@", nextDPTime);
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
    SMLog(kLogLevelVerbose,@" updateTimerWhenAppLoggedIn %@", date);
    NSDate * dataPurgeTime = [SMDataPurgeHelper retrieveNextDPTime];
    
    NSTimeInterval interval = 0;
    
    if (dataPurgeTime != nil)
    {
        NSComparisonResult result = [date compare:dataPurgeTime];
        if (result == NSOrderedAscending)
        {
            interval = [date timeIntervalSinceDate:dataPurgeTime];
            SMLog(kLogLevelVerbose,@"Data purge interval %f", interval);
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


- (void)findAndFillChildObjectRecordForSave
{
    NSArray * purgeMapKey = [purgeMap allKeys];
    
    @autoreleasepool
    {
        for (NSString * objectName in purgeMapKey)
        {
            SMDataPurgeModel *purgeModel = [purgeMap objectForKey:objectName];
            
            if ( (purgeModel != nil) && ([purgeModel isPurgeable]))
            {
                NSArray *childRelations = [purgeModel purgeableChilds];
                
                @autoreleasepool
                {
                    for (SMObjectRelationModel *childRelation in childRelations)
                    {
                        NSMutableArray *savedChilds = [[NSMutableArray alloc] init];
                        
                        NSMutableDictionary *relationshipDictionary = [[SMDataPurgeHelper relationshipKeyDictionaryForRelationshipModel:childRelation] retain];
                        
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
                        
                        SMDataPurgeModel *childPurgeModel = [purgeMap objectForKey:childRelation.childName];
                        
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
                                    [purgeMap setObject:childPurgeModel forKey:childPurgeModel.name];
                                }
                            }
                        
                        }
                        
                        [savedChilds release];
                        savedChilds = nil;
                        
                        [relationshipDictionary release];
                    }
                }
            }
        }
    }
}


- (void)findAndFillReferenceObjectRecordForSave
{
    NSArray * purgeMapKey = [purgeMap allKeys];
    
    @autoreleasepool
    {
        for (NSString * objectName in purgeMapKey)
        {
            SMDataPurgeModel *purgeModel = [purgeMap objectForKey:objectName];
            
            if ( (purgeModel != nil) && ([purgeModel isPurgeable]))
            {
                NSArray *referenceRelations = [purgeModel purgeableReferenceObjects];
                
                @autoreleasepool
                {
                    for (SMObjectRelationModel *childRelation in referenceRelations)
                    {
                        NSMutableArray *savedRelations = [[NSMutableArray alloc] init];
                        
                        NSMutableDictionary *relationshipDictionary = [[SMDataPurgeHelper relationshipKeyDictionaryForRelationshipModel:childRelation] retain];
                        
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
                                    [savedRelations addObject:[relationshipDictionary objectForKey:recordId]];
                                }
                            }
                        }
                        
                        SMDataPurgeModel *childPurgeModel = [purgeMap objectForKey:childRelation.childName];
                        
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
                                    [purgeMap setObject:childPurgeModel forKey:childPurgeModel.name];
                                }
                            }
                        }
                        
                        [savedRelations release];
                        savedRelations = nil;
                        [relationshipDictionary release];
                    }
                }
            }
        }
    }
}


- (void)seggregateNonPurgeableRecords:(BOOL)isFinal
{
    NSArray * purgeMapKey = [purgeMap allKeys];
    
    @autoreleasepool
    {
        for (NSString * objectName in purgeMapKey)
        {
            SMDataPurgeModel *purgeModel = [purgeMap objectForKey:objectName];
            if (isFinal)
            {
                [purgeModel aggregateNonPurgeableRecords];
            }
            else
            {
                [purgeModel aggregateNonPurgeableRecords];    
            }
            
            [purgeMap setObject:purgeModel forKey:purgeModel.name];
        }
    }
}

@end
