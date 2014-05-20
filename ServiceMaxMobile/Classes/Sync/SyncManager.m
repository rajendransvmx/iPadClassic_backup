//
//  SyncManager.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 3/26/14.
//  Copyright (c) 2013 ServiceMax. All rights reserved.
//

#import "SyncManager.h"


static dispatch_once_t _sharedSyncManagerInstanceGuard;
static SyncManager *_instance;


@implementation SyncManager



#pragma mark - Singleton class Implementation

- (id)init
{
    return [SyncManager sharedInstance];
}


- (id)initializeSyncManager
{
    self = [super init];
    
    if (self)
    {
       
    }
    return self;
}


+ (SyncManager *)sharedInstance
{
    dispatch_once(&_sharedSyncManagerInstanceGuard,
                  ^{
                      _instance = [[SyncManager alloc] initializeSyncManager];
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


@end
