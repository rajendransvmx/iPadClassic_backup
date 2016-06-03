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
        
        //028248
        if ([_locManager respondsToSelector:@selector(setPausesLocationUpdatesAutomatically:)]) {
            [_locManager setPausesLocationUpdatesAutomatically:NO];
        }
        
        if ([_locManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
            [_locManager setAllowsBackgroundLocationUpdates:YES];
        }
    }
    return _locManager;
}

#pragma mark - Location update
-(void)startLocationUpdates
{
    if (self.mode == kLocationManagerModeStandard) {
#ifdef __IPHONE_8_0
        if ([self.locManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            
            [self.locManager requestAlwaysAuthorization];
        }
#endif
        [self.locManager startUpdatingLocation];
    }
    else {
#ifdef __IPHONE_8_0
        if ([self.locManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            
            [self.locManager requestAlwaysAuthorization];
        }
#endif
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
    if (shouldUseNotifications) {
        // notify about the change
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerNotificationLocationUpdatedName
                                                            object:self];
    }
    if (self.delegate) {
        
        if ([self.delegate conformsToProtocol:@protocol(LocationManagerDelegate)]) {
            
            if ([self.delegate respondsToSelector:@selector(locationManagerInstance:didUpdateLocations:)]) {
                [self.delegate locationManagerInstance:manager didUpdateLocations:locations];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (shouldUseNotifications) {
    // notify failed location update
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerNotificationFailedName
                                                        object:self
                                                      userInfo:@{@"error": error}];
    }
    
    if (self.delegate) {
        
        if ([self.delegate conformsToProtocol:@protocol(LocationManagerDelegate)]) {
            
            if ([self.delegate respondsToSelector:@selector(locationManagerInstance:didFailWithError:)]) {
                [self.delegate locationManagerInstance:manager didFailWithError:error];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (shouldUseNotifications) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerNotificationAuthorizationChangedName
                                                        object:self userInfo:@{@"status": @(status)}];
    }
    if (self.delegate) {
        
        if ([self.delegate conformsToProtocol:@protocol(LocationManagerDelegate)]) {
            
            if ([self.delegate respondsToSelector:@selector(locationManagerInstance:didChangeAuthorizationStatus:)]) {
                [self.delegate locationManagerInstance:manager didChangeAuthorizationStatus:status];
            }
        }
    }
}

@end
