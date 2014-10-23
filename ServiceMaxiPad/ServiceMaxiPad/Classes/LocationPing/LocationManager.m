//
//  LocationManager.m
//  LocationPingPOC
//
//  Created by Pushpak on 17/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager ()

@property (strong, nonatomic) CLLocationManager *locManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic) LocationManagerMonitorMode mode;

@end;

@implementation LocationManager

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


#pragma mark - LocationManager
-(CLLocationManager*)locManager
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == _locManager) {
        _locManager = [[CLLocationManager alloc] init];
        _locManager.delegate = self;
    }
    return _locManager;
}

#pragma mark - Location update
-(void)startLocationUpdates
{
    if (self.mode == kLocationManagerModeStandard) {
      //  [self.locManager requestAlwaysAuthorization];
        [self.locManager startUpdatingLocation];
    }
    else {
      //  [self.locManager requestAlwaysAuthorization]; // Add This Line
        [self.locManager startMonitoringSignificantLocationChanges];
    }
    
    // based on docs, locationmanager's location property is populated with latest
    // known location even before we started monitoring, so let's simulate a change
    if (self.locManager.location) {
        [self locationManager:self.locManager didUpdateLocations:@[self.locManager.location]];
    }
}

-(void)startLocationUpdates:(LocationManagerMonitorMode)mode
             distanceFilter:(CLLocationDistance)filter
                   accuracy:(CLLocationAccuracy)accuracy
{
    self.mode = mode;
    self.locManager.distanceFilter = filter;
    self.locManager.desiredAccuracy = accuracy;
    
    [self startLocationUpdates];
}

- (void)stopLocationUpdates
{
    if (self.mode == kLocationManagerModeStandard) {
        
        [self.locManager stopUpdatingLocation];
    }
    else {
        [self.locManager stopMonitoringSignificantLocationChanges];
    }
    
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (![locations count]) {
        return;
    }
    
    // location didn't change
    if (nil != self.currentLocation && [[locations lastObject] isEqual:self.currentLocation]) {
        return;
    }
    
    // update last known location
    self.currentLocation = [locations lastObject];
    if (self.shouldUseNotifications) {
        // notify about the change
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerNotificationLocationUpdatedName
                                                            object:self];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (self.shouldUseNotifications) {
    // notify failed location update
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerNotificationFailedName
                                                        object:self
                                                      userInfo:@{@"error": error}];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (self.shouldUseNotifications) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerNotificationAuthorizationChangedName
                                                        object:self userInfo:@{@"status": @(status)}];
    }
}

@end
