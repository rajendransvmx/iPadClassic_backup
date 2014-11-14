//
//  CustomerOrgInfo.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 4/4/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "CustomerOrgInfo.h"
//#import "SVMXSystemConstant.h"


static dispatch_once_t _sharedCustomerOrgInstanceGuard;
static CustomerOrgInfo *_instance;

//static int const kPreferredAPIVersion = 20;


@implementation CustomerOrgInfo


@synthesize userName;
@synthesize currentUserName;
@synthesize userDisplayName;
@synthesize previousUserName;

@synthesize userLanguage;

@synthesize userId;
@synthesize userOrgId;
@synthesize currentUserId;
@synthesize loggedUserId;
@synthesize profileId;

@synthesize apiURL;
@synthesize instanceURL;
@synthesize identityURL;

@synthesize accessToken;
@synthesize refreshToken;

@synthesize userLoggedInHost;
@synthesize userPreferenceHost;
@synthesize previousOrg;

@synthesize serverVersion;


#pragma mark - Singleton class Implementation

- (id)init
{
    return [CustomerOrgInfo sharedInstance];
}


- (id)initializeCustomerOrgInfo
{
    self = [super init];
    
    if (self)
    {
        
    }
    return self;
}


+ (CustomerOrgInfo *)sharedInstance
{
    dispatch_once(&_sharedCustomerOrgInstanceGuard,
                  ^{
                      _instance = [[CustomerOrgInfo alloc] initializeCustomerOrgInfo];
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


- (void)reloadOrgInfo
{
    // Reload
}

- (void)explainMe
{
    NSLog(@"UsernName : %@ \n currentUserName : %@ \n userDisplayName : %@ \n previousUserName : %@ \n userLanguage : %@ \n userId : %@ \n userOrgId : %@ \n currentUserId : %@ \n loggedUserId : %@ \n profileId : %@ \n apiURL : %@ \n instanceURL : %@ \nidentityURL : %@ \n accessToken : %@ \n refreshToken : %@ \n userLoggedInHost : %@ \n userPreferenceHost : %@ \n previousOrg : %@ \n serverVersion : %@ \n",  userName,currentUserName, userDisplayName, previousUserName, userLanguage, userId, userOrgId, currentUserId, loggedUserId, profileId, apiURL, instanceURL, identityURL, accessToken, refreshToken, userLoggedInHost, userPreferenceHost, previousOrg, serverVersion);
  }




@end

