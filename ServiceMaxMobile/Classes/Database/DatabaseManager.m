//
//  DatabaseManager.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 3/26/14.
//  Copyright (c) 2013 ServiceMax. All rights reserved.
//

#import "DatabaseManager.h"


static dispatch_once_t _sharedDatabaseManagerInstanceGuard;
static DatabaseManager *_instance;


@implementation DatabaseManager


#pragma mark - Singleton class Implementation

- (id)init
{
    return [DatabaseManager sharedInstance];
}


- (id)initializeDatabaseManager
{
    self = [super init];
    
    if (self)
    {
        
    }
    return self;
}


+ (DatabaseManager *)sharedInstance
{
    dispatch_once(&_sharedDatabaseManagerInstanceGuard,
                  ^{
                      _instance = [[DatabaseManager alloc] initializeDatabaseManager];
                  });
    return _instance;
}


+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedInstance] retain];
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
