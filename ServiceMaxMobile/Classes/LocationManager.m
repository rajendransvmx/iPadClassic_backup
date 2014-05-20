//
//  LocationPing.m
//  ServiceMaxMobile
//
//  Created by Naveen Vasu on 15/04/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import "LocationManager.h"
#import "DataBase.h"
#import "AppDelegate.h"
#import "AppManager.h"
#import  <CoreLocation/CoreLocation.h>

@implementation LocationManager

@synthesize locationManager;
@synthesize lastLocationUpdateTimeStamp;
@synthesize lastLocationUpdateCount;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static LocationManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
    
    }
    return self;
}

#pragma mark Managing Service Location

- (void) startLocationServices
{
    NSString *enableLocationService = [[AppManager sharedManager] getSettingValueForKey: ENABLE_LOCATION_UPDATE];
    enableLocationService = (enableLocationService != nil) ? enableLocationService : @"True";
    if ([enableLocationService boolValue])
    {
        if (self.locationManager == nil)
        {
            CLLocationManager *locationMgr = [[CLLocationManager alloc] init];
            self.locationManager = locationMgr;
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.distanceFilter = kCLDistanceFilterNone; //500 meters
            [locationMgr release];
        }
        else
        {
            self.locationManager.delegate = self;
        }
        
        [locationManager startUpdatingLocation];
    }
    else
    {
        if (self.locationManager != nil)
        {
            [self stopLocationServices];
        }
    }
}

- (void)stopLocationServices
{
    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;
    self.locationManager = nil;
}

#pragma mark CLLocationManagerDelegate Method Implementation

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSDate *newLocationTimeStamp = newLocation.timestamp;
    [self getLastLocationTimeStamp];
    NSString *frequencyForLocationUpdate = [self getFrequencyForLocationUpdate];
    
    if(self.lastLocationUpdateTimeStamp != nil)
    //NSLog(@" lastLocationUpdateTimeStamp :%@", [lastLocationUpdateTimeStamp description]);
    
   // if ((self.lastLocationUpdateTimeStamp == nil) || !([newLocationTimeStamp timeIntervalSinceDate:self.lastLocationUpdateTimeStamp] < [frequencyForLocationUpdate intValue]*60 ))
    if ((self.lastLocationUpdateTimeStamp == nil) || !([newLocationTimeStamp timeIntervalSinceDate:self.lastLocationUpdateTimeStamp] < 2*60 ))
        
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self didUpdateToLocation:newLocation];
        });
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSDate *currentTimeStamp = [NSDate date];
    [self getLastLocationTimeStamp];
    NSString *frequencyForLocationUpdate = [self getFrequencyForLocationUpdate];
    
    if ((self.lastLocationUpdateTimeStamp == nil) || !([currentTimeStamp timeIntervalSinceDate:self.lastLocationUpdateTimeStamp] < [frequencyForLocationUpdate intValue]*60 ))
    {
        [self didUpdateToLocation:nil];
    }
}

-(void)didUpdateToLocation:(CLLocation*)location
{
    /*
     if(![appDelegate enableGPS_SFMSearch])
     return;
     */
    
    //call db to store the data
    NSMutableDictionary *locationInfo = [[NSMutableDictionary alloc] init];
    
    NSDateFormatter * frm = [[NSDateFormatter alloc] init];
    [frm setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * timeStamp = [frm stringFromDate:[NSDate date]];
    timeStamp = [iOSInterfaceObject getGMTFromLocalTime:timeStamp];
    [locationInfo setObject:[NSString stringWithFormat:@"%@",timeStamp] forKey:@"timestamp"];
    
    if(location != nil)
    {
        [locationInfo setObject:[NSString stringWithFormat:@"%lf", location.coordinate.latitude] forKey:@"latitude"];
        [locationInfo setObject:[NSString stringWithFormat:@"%lf", location.coordinate.longitude] forKey:@"longitude"];
        [locationInfo setObject:[NSString stringWithFormat:@" "] forKey:@"additionalInfo"];
        [locationInfo setObject:Location_Success forKey:@"status"];
    }
    else
    {
        [locationInfo setObject:[NSString stringWithFormat:@""] forKey:@"latitude"];
        [locationInfo setObject:[NSString stringWithFormat:@""] forKey:@"longitude"];
        [locationInfo setObject:Failed_to_Get_Location forKey:@"additionalInfo"];
        [locationInfo setObject:Failure forKey:@"status"];
    }
    
    [appDelegate.dataBase insertrecordIntoUserGPSLog:locationInfo];
    
    [frm release];
    frm = nil;
    
    [locationInfo release];
    self.lastLocationUpdateTimeStamp = [NSDate date];
    self.lastLocationUpdateCount++;
    
    /*
    TO DO: Plug out the code from the database Class, which makes the WS call Technician update location and move it here.
    TO DO: Remove the older records in the User GPS Locations table from the DataBase.
    
    NSString *numberOfGPSLocationsToSave = [[AppManager sharedManager] getSettingValueForKey: MAX_LOCATION_RECORD];
    if(self.lastLocationUpdateCount > [numberOfGPSLocationsToSave intValue])
    {
        
    }
    */
}

- (void) getLastLocationTimeStamp
{
    if (self.lastLocationUpdateTimeStamp == nil)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if (userDefaults)
        {
            self.lastLocationUpdateTimeStamp = [userDefaults objectForKey:kLastLocationUpdateTimestamp];
        }
    }
}

- (NSString *) getFrequencyForLocationUpdate
{
    NSString *frequencyForLocationUpdate = [[AppManager sharedManager] getSettingValueForKey: FREQ_LOCATION_TRACKING];
    frequencyForLocationUpdate = (frequencyForLocationUpdate != nil)? frequencyForLocationUpdate:@"10";
    return frequencyForLocationUpdate;
}

- (void)bindUserTrunkLocationToClientInfo:(INTF_WebServicesDefServiceSvc_SVMXClient *)SVMXC_client
{
    /*
    TO DO:
     
    NSString *userTrunkLocation = @"usertrunklocation:";
    NSString *previousTrunkLocation = nil;
    
    // Check Does it have already user location assigned
    for (NSString *valueString in SVMXC_client.clientInfo)
    {
        if ([valueString hasPrefix:userTrunkLocation])
        {
            previousTrunkLocation =  valueString;
            break;
        }
    }
    
    if ([dataBase getTechnicianLocationId] == nil)
    {
        if (previousTrunkLocation != nil)
        {
            // There are no user-trunk-location exist now. Lets remove previous value
            [SVMXC_client.clientInfo removeObject:previousTrunkLocation];
        }
    }
    else
    {
        NSString *trunkLocation = [NSString stringWithFormat:@"%@%@",userTrunkLocation,[dataBase getTechnicianLocationId]];
        
        // 1. No previous user-trunk-location exist. Lets add now.
        if (previousTrunkLocation == nil)
        {
            [SVMXC_client.clientInfo addObject:trunkLocation];
        }
        else if (![previousTrunkLocation isEqualToString:trunkLocation])
        {
            // 2. User has previous user-trunk-location but not matching with current
            
            [SVMXC_client.clientInfo removeObject:previousTrunkLocation];
            [SVMXC_client.clientInfo addObject:trunkLocation];
        }
        
        // 3. It is maching.. so we are not rewriting user-trunk-location
    }
    return SVMXC_client;*/
}

- (void) startBackgroundThreadForLocationServiceSettings
{
    /*if(![appDelegate enableGPS_SFMSearch])
        return;
    
      if(metaSyncRunning )
     {
        SMLog(kLogLevelVerbose,@"Meta Sync is Running");
        return;
     }*/
    
    /*
    NSString *enableLocationServiceStatus = [self.settingsDict objectForKey:ENABLE_LOCATION_UPDATE];
    enableLocationService = (enableLocationServiceStatus != nil)?[enableLocationServiceStatus boolValue]:TRUE;
    frequencyLocationService = [[self.settingsDict objectForKey:FREQ_LOCATION_TRACKING] retain];
    frequencyLocationService = (frequencyLocationService != nil)?frequencyLocationService:@"10";
    if(enableLocationService)
    {
        if(frequencyLocationService == nil)
            frequencyLocationService = @"10";
        NSTimeInterval scheduledTimer = 0;
        scheduledTimer = [frequencyLocationService doubleValue] * 60;
        if( [self.locationPingSettingTimer isValid] )
        {
            [self.locationPingSettingTimer invalidate];
            self.locationPingSettingTimer = nil;
        }
        self.locationPingSettingTimer = [NSTimer scheduledTimerWithTimeInterval:scheduledTimer
                                                                         target:self
                                                                       selector:@selector(checkLocationServiceSetting)
                                                                       userInfo:nil
                                                                        repeats:YES];
    }
     */
}


@end
