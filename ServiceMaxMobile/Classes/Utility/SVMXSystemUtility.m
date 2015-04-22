//
//  SVMXSystemUtility.m
//  iService
//
//  Created by Vipindas on 11/18/13.
//
//

#import "SVMXSystemUtility.h"

@implementation SVMXSystemUtility

static dispatch_once_t _sharedInstanceGuard;
static SVMXSystemUtility *_instance;


@synthesize activeActivityCount;


- (id)init
{    
    self = [super init];
    
    if (self)
    {
        self.activeActivityCount = 0;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}


+ (SVMXSystemUtility *)sharedInstance
{
    dispatch_once(&_sharedInstanceGuard,
                  ^{
                      _instance = [[SVMXSystemUtility alloc] init];
                  });
    return _instance;
}


- (void)startNetworkActivity
{
    @synchronized(self)
    {
        ++ self.activeActivityCount;
        if (self.activeActivityCount > 0)
        {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
    }
}


- (void)stopNetworkActivity
{
    @synchronized(self)
    {
        --self.activeActivityCount;
        if (self.activeActivityCount <= 0)
        {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }
}

@end
