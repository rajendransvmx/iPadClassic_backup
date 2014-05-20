//
//  SNetworkReachabilityManager.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 3/25/14.
//  Copyright (c) 2013 ServiceMax. All rights reserved.
//

/**
 *  @file   SNetworkReachabilityManager.m
 *  @class  SNetworkReachabilityManager
 *
 *  @brief  Observer and manage device Network Reachability changes
 *
 *
 *
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "SNetworkReachabilityManager.h"


static dispatch_once_t _sharedNetworkInstanceGuard;
static SNetworkReachabilityManager *_instance;


@interface SNetworkReachabilityManager ()
{
    
}
@property(nonatomic)  BOOL isReachable;

@property (nonatomic, strong) Reachability *internetReach;

- (void)initializeNetworkStatus;

@end


@implementation SNetworkReachabilityManager

@synthesize isReachable;
@synthesize internetReach;

- (void)registerNetworkReachability
{

    NSLog(@" Register NetworkReachability ");
    // Register for network connection changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityDidChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
}

#pragma mark - Singleton implementation 

- (id)init
{
    return [SNetworkReachabilityManager sharedInstance];
}


- (id)initializeNetworkReachabilityManager
{
    self = [super init];
    
    if (self)
    {
        [self initializeNetworkStatus];
        [self registerNetworkReachability];
    }
    return self;
}


+ (SNetworkReachabilityManager *)sharedInstance
{
    dispatch_once(&_sharedNetworkInstanceGuard,
                  ^{
                      _instance = [[SNetworkReachabilityManager alloc] initializeNetworkReachabilityManager];
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


#pragma mark - Reachability Changes

/**
 * @name   reachabilityDidChanged:
 *
 * @author Vipindas Palli
 *
 * @brief  Recieve notification from reachability class and propagate same to application
 *
 * \par
 *  <Longer description starts here>
 *
 *
 *
 * @return void
 *
 */

- (void)reachabilityDidChanged:(NSNotification* )notification
{
    NSLog(@"SNetwork Reachbality Changed %@ ", [notification  description]);
    
    Reachability *curReach = [notification object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    
    // By default NO.
    NSNumber  *networkCurrentStatus = [NSNumber numberWithInt:0];
    
    if ((netStatus == ReachableViaWWAN) || ( netStatus == ReachableViaWiFi) )
    {
        self.isReachable = YES;
        networkCurrentStatus = [NSNumber numberWithInt:1];
    }
    else
    {
        self.isReachable = NO;
    }
    
    // Post notifications to other observ class : This could be other components in the application
    [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkConnectionChanged
                                                        object:networkCurrentStatus
                                                      userInfo:nil];
    
    NSLog(@"------------------ SNetwork Reachbality status ------------ %d", self.isReachable);
    
}


#pragma mark - Reachability Instance Methods

/**
 * @name   isNetworkReachable
 *
 * @author Vipindas Palli
 *
 * @brief
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return BOOL Yes, if network reachable, otherwise No
 *
 */


- (void)reachabilityStatus
{
    // Reachability check for internet
    if (self.internetReach == nil)
    {
        self.internetReach = [Reachability reachabilityForInternetConnection];
    }
	[self.internetReach startNotifier];

    
    NetworkStatus inetStatus = [self.internetReach currentReachabilityStatus];
    
    NSString* internetStatusString  = ( inetStatus == ReachableViaWWAN) ? @"Reachable WWAN" : ( ( inetStatus == ReachableViaWiFi) ? @"Reachable WiFi" : @"Access Not Available");
    
    
    // Reachability check for Salesforce Host
    Reachability *hostReach = [Reachability reachabilityWithHostName:@"www.salesforce.com"] ;
	[hostReach startNotifier];
    
    NetworkStatus hostStatus = [hostReach currentReachabilityStatus];
    
    NSString* hostStatusString  = (hostStatus == ReachableViaWWAN) ? @"Reachable WWAN" : ( ( hostStatus == ReachableViaWiFi) ? @"Reachable WiFi" : @"Access Not Available");
    
    NSLog(@" Host :  %@ \n Internet :  %@ \n ", hostStatusString, internetStatusString);
    
    [hostReach stopNotifier];
}

/**
 * @name   initializeNetworkStatus
 *
 * @author Vipindas Palli
 *
 * @brief
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return void
 *
 */

- (void)initializeNetworkStatus
{
    
     NSLog(@" Initialize NetworkStatus ");
    
 // Reachability check for internet
    if (self.internetReach == nil)
    {
        self.internetReach = [Reachability reachabilityForInternetConnection];
    }
    [self.internetReach startNotifier];
 
    NetworkStatus inetStatus = [self.internetReach currentReachabilityStatus];
    
    if ((inetStatus == ReachableViaWWAN) || ( inetStatus == ReachableViaWiFi) )
    {
        self.isReachable = YES;
    }
    else
    {
        self.isReachable = NO;
    }
}

/**
 * @name   reachabilityStatus
 *
 * @author Vipindas Palli
 *
 * @brief  Status of reachability
 *
 * \par
 *  <Longer description starts here>
 *
 *
 *
 * @return void
 *
 */

- (BOOL)isNetworkReachable
{
    if (self.isReachable)
    {
      NSLog(@" YES, reachable");
    }
    else
    {
      NSLog(@" NO, not reachable");
    }
    return self.isReachable;
}

@end
