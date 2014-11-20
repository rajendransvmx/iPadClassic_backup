//
//  AppMetaData.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 4/15/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "AppMetaData.h"
#import <sys/utsname.h>


const NSString *kDeviceType = @"type";
const NSString *kOSVersion  = @"iOSVersion";
const NSString *kApplicationVersion = @"appVersion";
const NSString *kDevVersion = @"deviceVersion";


static dispatch_once_t _sharedAppDataInstanceGuard;
static AppMetaData *_instance;

@interface AppMetaData ()
{
    NSString *osVersion;
    NSString *deviceVersion;
    NSString *deviceType;
    NSString *applicationVersion;
    
    NSString *currentOSVersion;
    NSString *currentDeviceVersion;
    NSString *currentDeviceType;
    NSString *currentApplicationVersion;
    
    NSMutableDictionary *clientInfo;
}

@property (nonatomic, strong) NSString *osVersion;
@property (nonatomic, strong) NSString *deviceVersion;
@property (nonatomic, strong) NSString *deviceType;
@property (nonatomic, strong) NSString *applicationVersion;

@property (nonatomic, strong) NSString *currentOSVersion;
@property (nonatomic, strong) NSString *currentDeviceVersion;
@property (nonatomic, strong) NSString *currentDeviceType;
@property (nonatomic, strong) NSString *currentApplicationVersion;

@property (nonatomic, strong) NSMutableDictionary *clientInfo;


- (void)loadApplicationMetaData;

@end


@implementation AppMetaData

@synthesize osVersion;
@synthesize deviceVersion;
@synthesize deviceType;
@synthesize applicationVersion;
@synthesize currentOSVersion;
@synthesize currentDeviceVersion;
@synthesize currentDeviceType;
@synthesize currentApplicationVersion;
@synthesize clientInfo;


#pragma mark - Singleton class Implementation

- (id)init
{
    return [AppMetaData sharedInstance];
}


- (id)initializeAppData
{
    self = [super init];
    if (self)
    {
        //[self loadApplicationMetaData];
        // TODO :  Vipindas - review please here
        // TO DO :REMOVE COMMENT LATER AND REMOVE loadApplicationMetaDataForRest
        [self loadApplicationMetaDataForRest];
    }
    return self;
}


+ (AppMetaData *)sharedInstance
{
    dispatch_once(&_sharedAppDataInstanceGuard,
                  ^{
                      _instance = [[AppMetaData alloc] initializeAppData];
                  });
    return _instance;
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


- (id)retain
{
    return self;
}


- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release
{
    // never release
}


- (id)autorelease
{
    return self;
}


- (void)dealloc
{
    // Should never be called, but just here for clarity really.
    [super dealloc];
}

#pragma mark - Application Meta data loading

NSString* deviceName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}


- (void)loadApplicationMetaData
{
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    NSString *type = [currentDevice model];
    
    self.currentDeviceType = type;
    
    self.currentOSVersion = [currentDevice systemVersion];
    
    self.currentApplicationVersion = [[NSBundle mainBundle]
                            objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    NSString *devVersion = deviceName();
    
    self.currentDeviceVersion = devVersion;
    
    NSLog(@"model : %@ systemVersion : %@ appversion %@",type,currentOSVersion,currentApplicationVersion);
    NSString *osVer =       @"iosversion:";
    NSString *appVer =      @"appversion:";
    NSString *deviceVer =   @"deviceversion:";
    NSString *iosVersionString = [NSString stringWithFormat:@"%@%@",osVer,currentOSVersion];
    NSString *appVersionString = [NSString stringWithFormat:@"%@%@",appVer,currentApplicationVersion];
    NSString *devVersionString = [NSString stringWithFormat:@"%@%@",deviceVer,devVersion];
    
    self.clientInfo = [NSMutableDictionary dictionary];
    [clientInfo setObject:type             forKey:kDeviceType];
    [clientInfo setObject:iosVersionString forKey:kOSVersion];
    [clientInfo setObject:appVersionString forKey:kApplicationVersion];
    [clientInfo setObject:devVersionString forKey:kDevVersion];
}

//To do: remove it later

- (void)loadApplicationMetaDataForRest
{
    
    self.clientInfo = [NSMutableDictionary dictionary];
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    NSString *type = [currentDevice model];
    
    self.currentDeviceType = type;
    
    self.currentOSVersion= [currentDevice systemVersion];
    
    self.currentApplicationVersion = [[NSBundle mainBundle]
                                 objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    NSString *devVersion = deviceName();
    
    
    NSString *systemOSVersion = [currentDevice systemVersion];
    NSString *appVersion = [[NSBundle mainBundle]
                            objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    NSString *deviceVersion = devVersion;
    NSString *osVer =       @"iosversion:";
    NSString *appVer =      @"appversion:";
    NSString *deviceVer =   @"deviceversion:";
    NSString *iosVersionString = [NSString stringWithFormat:@"%@%@",osVer,systemOSVersion];
    NSString *appVersionString = [NSString stringWithFormat:@"%@%@",appVer,appVersion];
    NSString *devVersionString = [NSString stringWithFormat:@"%@%@",deviceVer,devVersion];
    
    NSArray *infoArray = [[NSArray alloc ] initWithObjects:iosVersionString,appVersionString,devVersionString, nil];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:infoArray,@"clientInfo",type,@"clientType", nil];
    
    NSArray *clientInfoArray = [[NSArray alloc] initWithObjects:dictionary, nil];
    
    [clientInfo setObject:clientInfoArray forKey:@"clientInfo"];
}


#pragma mark - Instance Methods

- (NSString *)getOSVersion
{
    return osVersion;
}


- (NSString *)getDeviceType
{
    return deviceType;
}


- (NSString *)getDeviceVersion
{
    return deviceVersion;
}


- (NSString *)getApplicationVersion
{
    return applicationVersion;
}


- (NSDictionary *)getApplicationMetaInfo
{
    return clientInfo;
}


- (NSString *)getCurrentOSVersion
{
    return currentOSVersion;
}


- (NSString *)getCurrentDeviceType
{
    return currentDeviceType;
}


- (NSString *)getCurrentDeviceVersion
{
    return currentDeviceVersion;
}


- (NSString *)getCurrentApplicationVersion
{
    return self.currentApplicationVersion;
}

@end