//
//  SMConnectionManager.m
//  iService
//
//  Created by Vipindas on 11/17/13.
//
//

#import "SMConnectionManager.h"

static dispatch_once_t _sharedInstanceGuard;
static SMConnectionManager *_instance;



@implementation SMConnectionManager

@synthesize sessionToken;
@synthesize instanceURL;


- (id)init {
    
    self = [super init];
    
    if (self)
    {
        [self refreshConnectionInfo];
    }
    return self;
}

- (void)dealloc
{
    [sessionToken release]; sessionToken = nil;
    [instanceURL release]; instanceURL = nil;
    
    [super dealloc];
}

- (void)refreshConnectionInfo
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    self.instanceURL = [userDefaults objectForKey:SERVERURL];
    self.sessionToken = [userDefaults objectForKey:ACCESS_TOKEN];
    
    NSLog(@" -----  refreshConnectionInfo   ------ ");
}


+ (SMConnectionManager *)sharedInstance
{
    dispatch_once(&_sharedInstanceGuard,
                  ^{
                      _instance = [[SMConnectionManager alloc] init];
                  });
    return _instance;
}

@end
