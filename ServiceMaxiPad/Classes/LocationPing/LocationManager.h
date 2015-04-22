//
//  LocationManager.h
//  LocationPingPOC
//
//  Created by Pushpak on 17/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationManagerDelegate <NSObject>

@optional
- (void)locationManagerInstance:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status;
- (void)locationManagerInstance:(CLLocationManager *)manager didFailWithError:(NSError *)error;
- (void)locationManagerInstance:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;

@end

/**
 Just a flag that notifications should be used or not, by default the protocol will be supported.
 */
static BOOL shouldUseNotifications = YES;


/**
 Notification posted when location of the device changes
 */
static NSString *kLocationManagerNotificationLocationUpdatedName = @"LocationManagerNotificationLocationUpdated";
static NSString *kLocationManagerNotificationFailedName = @"LocationManagerNotificationFailed";

/**
 Notification posted when the authorization status changes
 */
static NSString *kLocationManagerNotificationAuthorizationChangedName = @"LocationManagerNotificationAuthorizationChangedName";


typedef NS_ENUM(NSInteger, LocationManagerMonitorMode)
{
    /** `kLocationManagerModeStandard` triggers CoreLocation's `startUpdatingLocation`, which
    uses device's built-in GPS to determine location. Such location will be more acurate, but
    will also reduce battery performance.*/
    kLocationManagerModeStandard,
    /** `kLocationManagerModeSignificantLocationUpdates` on the other hand triggers CoreLocation's
    `startMonitoringSignificantLocation` instead. This interface delivers new events only when it detects
    changes to the device’s associated cell towers, resulting in less frequent updates and
    significantly lower power usage.*/
    kLocationManagerModeSignificantLocationUpdates
};

@interface LocationManager : NSObject<CLLocationManagerDelegate>

/**
 * The last known location of the user's device. This information may be used
 to display user's location in the app or do calculation based on that.
 */
@property (strong, readonly) CLLocation *currentLocation;

/**
 The CoreLocation CLLocationManager. Read-only property that you can access to configure
 manager with settings.
 */
@property (nonatomic, strong, readonly) CLLocationManager *locManager;


/** As per our internal discussion with team, notification is heavy object when only one want to be updated.
 * Hence this delegate mechanism. Already this delegate is being used in location ping. 
 * so going forward, if anyone wants to use. use notification and change the implementation of location ping manager too.
 */
@property (nonatomic, weak) id<LocationManagerDelegate> delegate;

+ (instancetype) sharedInstance;
+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));

/**
 Begins (resumes) the location updates.
 Start this immedialy after application launch to make we get location fix
 soon enought to be used in the app.
 
 A notification `GETCLocationManagerNotificationLocationUpdatedName` will be
 posted on every change of location. Last known location can be accessed from
 `currentLocation` property.
 */
-(void)startLocationUpdates;

/**
 Begins (resumes) the location updates.
 Start this immedialy after application launch to make we get location fix
 soon enought to be used in the app.
 
 A notification `GETCLocationManagerNotificationLocationUpdatedName` will be
 posted on every change of location. Last known location can be accessed from
 `currentLocation` property.
 
 @param mode Determines a location update mode (standard or significant location change)
 @param filter The minimum distance (measured in meters) a device must move horizontally
 before an update event is generated.
 @param accuracy The accuracy of the location data.
 */

-(void)startLocationUpdates:(LocationManagerMonitorMode)mode
             distanceFilter:(CLLocationDistance)filter
                   accuracy:(CLLocationAccuracy)accuracy;
/**
 Ends (pauses) the location updates.
 */
- (void)stopLocationUpdates;

@end
