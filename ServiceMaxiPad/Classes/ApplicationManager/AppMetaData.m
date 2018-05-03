//
//  AppMetaData.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 4/15/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "AppMetaData.h"
#import <sys/utsname.h>
#import "CustomerOrgInfo.h"


const NSString *kDeviceType = @"type";
const NSString *kOSVersion  = @"iOSVersion";
const NSString *kApplicationVersion = @"appVersion";
const NSString *kDevVersion = @"deviceVersion";

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
    [self loadApplicationMetaData];
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
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
    //013404
    /*if (self.clientInfo == nil) { */
    
    if (self.clientInfo == nil)
    {
        self.clientInfo = [NSMutableDictionary dictionary];

    }
        UIDevice *currentDevice = [UIDevice currentDevice];
        
        NSString *type = [currentDevice model];
        
        self.currentDeviceType = type;
        
        self.currentOSVersion= [currentDevice systemVersion];
        
        self.currentApplicationVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        
        NSString *devVersion = deviceName();
        
        self.currentDeviceVersion = devVersion;
        NSString *osVer =       @"iosversion:";
        NSString *appVer =      @"appversion:";
        NSString *deviceVer =   @"deviceversion:";
        //HS 19Jul added keys for Sync
        /*
         appversion:16.49.002
         appname:SVMX_MFL
         userid:005F0000005dz0xIAA
         clientudid:undefined
         syncstarttime:Wed, 13 Jul 2016 09:13:56 GMT
         */
        NSString *appName = @"appname:";
        NSString *userId = @"userid:";
        NSString *clientUDID = @"clientudid:";
        NSString *syncStartTime = @"syncstarttime:";
        
        NSString *udid =  [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSString *userid = [userDefaults objectForKey:@"ps_user_id"];
        
        
        NSString *iosVersionString = [NSString stringWithFormat:@"%@%@",osVer,self.currentOSVersion ];
        NSString *appVersionString = [NSString stringWithFormat:@"%@%@",appVer,self.currentApplicationVersion];
        NSString *devVersionString = [NSString stringWithFormat:@"%@%@",deviceVer,devVersion];
        
        NSString *appNameString = [NSString stringWithFormat:@"%@%@",appName,@"SVMX_iPad"];
        NSString *userIdString = [NSString stringWithFormat:@"%@%@",userId,userid];
        NSString *clientUDIDString = [NSString stringWithFormat:@"%@%@",clientUDID,udid];
        NSString *syncStartTimeString = [NSString stringWithFormat:@"%@%@",syncStartTime,@""];

        
        NSArray *infoArray = [[NSArray alloc ] initWithObjects:iosVersionString,appVersionString,devVersionString,appNameString,userIdString,clientUDIDString,syncStartTimeString, nil];
        
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[infoArray mutableCopy],@"clientInfo",type,@"clientType", nil];
        
        NSArray *clientInfoArray = [[NSArray alloc] initWithObjects:dictionary, nil];
        
        [self.clientInfo setObject:clientInfoArray forKey:@"clientInfo"];
   /* } */

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
    return self.clientInfo;
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
