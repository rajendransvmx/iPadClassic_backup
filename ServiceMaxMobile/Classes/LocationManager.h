//
//  LocationPing.h
//  ServiceMaxMobile
//
//  Created by Naveen Vasu on 15/04/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import  <CoreLocation/CoreLocation.h>
#import "DataBase.h"

@class CLLocation;

@interface LocationManager : NSObject<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    NSDate *lastLocationUpdateTimeStamp;
    int lastLocationUpdateCount;
}


+ (id)sharedManager;

- (void)didUpdateToLocation:(CLLocation*)location;
- (void)startLocationServices;
- (void)stopLocationServices;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSDate *lastLocationUpdateTimeStamp;
@property (nonatomic) int lastLocationUpdateCount;

@end
