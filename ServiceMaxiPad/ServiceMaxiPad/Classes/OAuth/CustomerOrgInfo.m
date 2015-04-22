//
//  CustomerOrgInfo.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 4/4/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "CustomerOrgInfo.h"
//#import "SVMXSystemConstant.h"
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

- (void)reloadOrgInfo
{
    // Reload
}

- (void)explainMe
{
    SXLogInfo(@"CustomerOrgInfo UsernName : %@ \n currentUserName : %@ \n userDisplayName : %@ \n previousUserName : %@ \n userLanguage : %@ \n userId : %@ \n userOrgId : %@ \n currentUserId : %@ \n loggedUserId : %@ \n profileId : %@ \n apiURL : %@ \n instanceURL : %@ \nidentityURL : %@ \n accessToken : %@ \n refreshToken : %@ \n userLoggedInHost : %@ \n userPreferenceHost : %@ \n previousOrg : %@ \n serverVersion : %@ \n",  userName,currentUserName, userDisplayName, previousUserName, userLanguage, userId, userOrgId, currentUserId, loggedUserId, profileId, apiURL, instanceURL, identityURL, accessToken, refreshToken, userLoggedInHost, userPreferenceHost, previousOrg, serverVersion);
}

@end

