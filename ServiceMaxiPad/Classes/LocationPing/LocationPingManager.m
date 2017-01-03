//
//  LocationPingManager.m
//  ServiceMaxiPad
//
//  Created by Pushpak on 17/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "LocationPingManager.h"
#import "MobileDeviceSettingDAO.h"
#import "UserGPSLogDAO.h"
#import "FactoryDAO.h"
#import "NonTagConstant.h"
#import "DateUtil.h"
#import "PlistManager.h"
#import "CustomerOrgInfo.h"
#import "TaskModel.h"
#import "TaskGenerator.h"
#import "TaskManager.h"
#import "FlowDelegate.h"
#import "WebserviceResponseStatus.h"
#import "SyncManager.h"
#import "SNetworkReachabilityManager.h"

@interface LocationPingManager ()<LocationManagerDelegate,FlowDelegate>
@property (nonatomic, strong) NSTimer *locationPingTimer;
@end

@implementation LocationPingManager

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
#pragma mark - End
#pragma mark - location ping settings
- (NSInteger)getLocationPingTimerFrequencyInSeconds {
    
    NSInteger frequency = 0;
    id mobileSettingService = [FactoryDAO serviceByServiceType:ServiceTypeMobileDeviceSettings];
    if ([mobileSettingService conformsToProtocol:@protocol(MobileDeviceSettingDAO)]) {
        
        MobileDeviceSettingsModel *model = [mobileSettingService fetchDataForSettingId:kTextLocationTrackFequency];
        frequency = model.value.doubleValue * 60;
    }
    if (frequency == 0) {
        frequency = 10*60;//10 min default.
    }
    return frequency;
}

- (BOOL)isLocationPingIsEnabledInServer {
    
    BOOL status = NO;
    id mobileSettingService = [FactoryDAO serviceByServiceType:ServiceTypeMobileDeviceSettings];
    if ([mobileSettingService conformsToProtocol:@protocol(MobileDeviceSettingDAO)]) {
        
        MobileDeviceSettingsModel *model = [mobileSettingService fetchDataForSettingId:kTextEnableLocationUpdate];
        status = model.value.boolValue;
    }
    return status;
}

- (NSInteger)getRecordLimitSettingForUserGPSLogTable
{
    NSInteger limit = 0;
    id mobileSettingService = [FactoryDAO serviceByServiceType:ServiceTypeMobileDeviceSettings];
    if ([mobileSettingService conformsToProtocol:@protocol(MobileDeviceSettingDAO)]) {
        
        MobileDeviceSettingsModel *model = [mobileSettingService fetchDataForSettingId:kTextLocationRecord];
        limit = model.value.integerValue;
    }
    return limit;
}
#pragma mark - End

- (void)configureLocationPingTimer {
    [self invalidateLocationPingTimer];
    NSInteger timeInterval = [self getLocationPingTimerFrequencyInSeconds];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.locationPingTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                                  target:self
                                                                selector:@selector(performLocationPingUpdate:)
                                                                userInfo:nil
                                                                 repeats:YES];
    });
}

- (void)invalidateLocationPingTimer {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        /**
         * Invalidate the timer if its valid.
         */
        if([self.locationPingTimer isValid]) {
            [self.locationPingTimer invalidate];
            self.locationPingTimer = nil;
        }
    });
}
#pragma mark - End
- (void)startLocationPing {
    
    [self stopLocationPing];
    /**
     * Check whether location ping feature is enabled on server side.
     */
    if ([self isLocationPingIsEnabledInServer]) {
        
        /**
         * Lets start the location service using the shared instance. For time being we'll use delegate instead
         * of notification, as notification is heavy.
         */
        
        [self configureLocationPingTimer]; // IPAD-4492
        [LocationManager sharedInstance].delegate = [LocationPingManager sharedInstance];
        [[LocationManager sharedInstance] startLocationUpdates:kLocationManagerModeStandard
                                                distanceFilter:kCLDistanceFilterNone
                                                      accuracy:kCLLocationAccuracyBest];
        
    }
}

- (void)stopLocationPing {
    
    /**
     * Invalidate the timer if its valid.
     */
    if([self.locationPingTimer isValid]) {
        [self.locationPingTimer invalidate];
        self.locationPingTimer = nil;
    }
    [[LocationManager sharedInstance] stopLocationUpdates];
    [LocationManager sharedInstance].delegate = nil;
    
}

#pragma mark location manager delegate methods
- (void)locationManagerInstance:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {

}

- (void)locationManagerInstance:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    NSMutableDictionary *locationInfo = [[NSMutableDictionary alloc] init];
    NSString * gmtTimeStamp = [DateUtil getDatabaseStringForDate:[NSDate date]];
    [locationInfo setObject:gmtTimeStamp forKey:@"timestamp"];
    [locationInfo setObject:[NSString stringWithFormat:@""] forKey:@"latitude"];
    [locationInfo setObject:[NSString stringWithFormat:@""] forKey:@"longitude"];
    [locationInfo setObject:kTextFailedToGetLocation forKey:@"additionalInfo"];
    [locationInfo setObject:kTextFailure forKey:@"status"];
    [self storeLatestLocationManagerStatusIntoNSUserDefaults:locationInfo];
    
}

- (void)locationManagerInstance:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    CLLocation *location = [locations lastObject];
    NSMutableDictionary *locationInfo = [[NSMutableDictionary alloc] init];
    NSString * gmtTimeStamp = [DateUtil getDatabaseStringForDate:location.timestamp];
    [locationInfo setObject:gmtTimeStamp forKey:@"timestamp"];
    [locationInfo setObject:[[NSString alloc] initWithFormat:@"%g",location.coordinate.latitude] forKey:@"latitude"];
    [locationInfo setObject:[[NSString alloc] initWithFormat:@"%g",location.coordinate.longitude] forKey:@"longitude"];
    [locationInfo setObject:@" " forKey:@"additionalInfo"];
    [locationInfo setObject:kTextLocationSuccess forKey:@"status"];
    [self storeLatestLocationManagerStatusIntoNSUserDefaults:locationInfo];
}
#pragma mark - End

#pragma mark - Plist storage method
- (void)storeLatestLocationManagerStatusIntoNSUserDefaults:(NSDictionary *)locationDict
{

    //Sudguru Fix:018708 ,previoulsy was in @synchronized block, changed to mainQueue
    dispatch_async(dispatch_get_main_queue(), ^{

            [PlistManager storeTechnicianLastLocationStatus:locationDict];
        
    });
}

- (UserGPSLogModel *)populateModelFromLastestLocationManagerStatus
{
    NSDictionary *locationDict = [PlistManager getTechnicianLastLocationStatus];
    UserGPSLogModel *model = [[UserGPSLogModel alloc]init];
    if (locationDict) {
        
        NSString *uniqueId = [AppManager generateUniqueId];
        if ([uniqueId length] > 0) {
            /**
             * Get localId by generating unique id.
             */
            model.localId = uniqueId;
        }
        model.timeRecorded   = [locationDict objectForKey:@"timestamp"];
        model.latitude       = [locationDict objectForKey:@"latitude"];
        model.longitude      = [locationDict objectForKey:@"longitude"];
        model.additionalInfo = [locationDict objectForKey:@"additionalInfo"];
        model.status         = [locationDict objectForKey:@"status"];
        model.user           = [CustomerOrgInfo sharedInstance].loggedUserId;
        model.ownerId        = @"";
        model.createdById    = @"";
        model.deviceType     = @"iPad";
    }
    return model;
}


- (UserGPSLogModel *)populateModelIfClientPermissionDenied
{
    UserGPSLogModel *model = [[UserGPSLogModel alloc]init];
    NSString *uniqueId = [AppManager generateUniqueId];
    if ([uniqueId length] > 0) {
        /**
         * Get localId by generating unique id.
         */
        model.localId = uniqueId;
    }
    model.timeRecorded   = [DateUtil getDatabaseStringForDate:[NSDate date]];
    model.latitude       = @"";
    model.longitude      = @"";
    model.additionalInfo = kTextAppLocationSettingDisable;
    model.status         = kTextFailure;
    model.user           = [CustomerOrgInfo sharedInstance].loggedUserId;
    model.ownerId        = @"";
    model.createdById    = @"";
    model.deviceType     = @"iPad";
    return model;
}

- (UserGPSLogModel *)populateModelIfLocationServicesIsDisabled
{
    UserGPSLogModel *model = [[UserGPSLogModel alloc]init];
    NSString *uniqueId = [AppManager generateUniqueId];
    if ([uniqueId length] > 0) {
        /**
         * Get localId by generating unique id.
         */
        model.localId = uniqueId;
    }
    model.timeRecorded   = [DateUtil getDatabaseStringForDate:[NSDate date]];
    model.latitude       = @"";
    model.longitude      = @"";
    model.additionalInfo = kTextLocationSettingDisable;
    model.status         = kTextFailure;
    model.user           = [CustomerOrgInfo sharedInstance].loggedUserId;
    model.ownerId        = @"";
    model.createdById    = @"";
    model.deviceType     = @"iPad";
    return model;
}

#pragma mark - End

#pragma mark - Location ping timer method
- (void)performLocationPingUpdate:(id)sender
{
    @synchronized ([self class])
    {
        SXLogDebug(@"Location ping timer triggered.");
        /**
         * Check whether meta /initial  sync is in progress, if yes then return. Do nothing.
         *
         */
        if ([[SyncManager sharedInstance] isConfigSyncInProgress] || [[SyncManager sharedInstance] isInitalSyncOrResetApplicationInProgress]) {
            SXLogDebug(@"Location ping not updating as meta/initial sync is progress.");
            return;
        }
        /**
         * Just to ignore first timer call that is random when location services is disabled in background.
         */
        if (self.isApplicationInBackground && (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) ) {
            return;
        }
        
        /**
         * Purge GPS Log table before insertion
         */
        id gpsLogService = [FactoryDAO serviceByServiceType:ServiceTypeUserGPSLog];
        if ([gpsLogService conformsToProtocol:@protocol(UserGPSLogDAO)]) {
            
            [gpsLogService deleteGPSLogsIfRecordCountCrossedLimit:[self getRecordLimitSettingForUserGPSLogTable]];
            
            UserGPSLogModel *model;
            
            if (![CLLocationManager locationServicesEnabled]) {
                
                /**
                 * Location Services is disabled.
                 */
                model = [self populateModelIfLocationServicesIsDisabled];
                
            } else if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
                
                /**
                 * User clicked cancel on permission request.
                 */
                model = [self populateModelIfClientPermissionDenied];
                
            } else {
                
                /**
                 * Well location services is working so fetch last status.
                 */
                model = [self populateModelFromLastestLocationManagerStatus];
            }
            
            BOOL status = [gpsLogService saveRecordModel:model];
            if (status) {
                
                SXLogDebug(@"Location ping record successfully inserted.");
                [self triggerLocationWebservices];
            } else {
                SXLogDebug(@"Location ping record failed to insert.");
            }
        }
    }
}

- (void)triggerLocationWebservices
{
    if (![[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
    {
        SXLogDebug(@"Location ping webservice not triggered as no connectivity.");
        return;
    }
    
    if ([[SyncManager sharedInstance] isConfigSyncInProgress] || [[SyncManager sharedInstance] isInitalSyncOrResetApplicationInProgress]) {
        SXLogDebug(@"Location ping webservice not triggered as meta/initial sync is in progress.");
        return;
    }
    
    if ([[AppManager sharedInstance] hasTokenRevoked]) {
        SXLogDebug(@"Location ping webservice not triggered as oauth token is revoked.");
        return;
    }
    
    if (self.isLocationRequestRunning) {
        SXLogDebug(@"Location ping webservice not triggered as already old location web service is in progress.");
        return;
    }
    if ( ![self isLogsAvailable]) {
        SXLogDebug(@"Location ping webservice not triggered as there is no locations logs available.");
        return;
    }
    /*
     * Initiating webserviceInBackground As FlowNode Refresh Token Blocking the UI.
     */
    [self performSelectorInBackground:@selector(initiateLocationWebServiceInBackground:) withObject:self];
}

- (void)initiateLocationWebServiceInBackground:(id)sender
{
    _isLocationRequestRunning = YES;
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeLocationPing
                                             requestParam:nil
                                           callerDelegate:self];
    [[TaskManager sharedInstance] addTask:taskModel];

}

#pragma mark - End
- (BOOL)isLogsAvailable
{
    BOOL status = NO;
    id service = [FactoryDAO serviceByServiceType:ServiceTypeUserGPSLog];
    
    if ([service conformsToProtocol:@protocol(UserGPSLogDAO)]) {
        NSInteger count = [service getNumberOfRecordsFromObject:kUserGPSLogTableName
                                                       withDbCriteria:nil
                                                andAdvancedExpression:nil];
        if (count > 0) {
            status = YES;
        }
    }
    return status;
}

#pragma mark - Flow Node delegate methods
- (void)flowStatus:(id)status
{
    if([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *st = (WebserviceResponseStatus*)status;
        if (st.syncStatus == SyncStatusSuccess) {
            
            _isLocationRequestRunning = NO;
            SXLogDebug(@"Location ping web service was successfull.");
            
        } else if ((st.syncStatus == SyncStatusFailed)
                        || (st.syncStatus == SyncStatusRefreshTokenFailedWithError)
                        || (st.syncStatus == SyncStatusNetworkError)) {
            
            _isLocationRequestRunning = NO;
            SXLogDebug(@"Location ping web service failed.");
        }
    }
}
#pragma mark - End
@end
