//
//  AttachmentQueue.m
//  ServiceMaxMobile
//
//  Created by Kirti on 21/11/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import "AttachmentQueue.h"
#import "SVMXSystemConstant.h"

static dispatch_once_t _sharedInstanceGuard;
static AttachmentQueue *_instance;
@implementation AttachmentQueue
- (id)init {
    
    return [AttachmentQueue sharedInstance];
    
}


- (id)initializeAttachmentQueue
{
    self = [super init];
    
    if (self)
    {
     
    }
    return self;
    
}

+ (AttachmentQueue *)sharedInstance
{
    dispatch_once(&_sharedInstanceGuard,
                  ^{
                      _instance = [[AttachmentQueue alloc] initializeAttachmentQueue];
                  });
    return _instance;
}


- (void) startQueue
{
    //Notification for attachment to start
   [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSyncCompleted object:nil];//NOTIFICATION_SYNC_STOPPED
}
- (void) stopQueue
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSyncStarted object:nil];//NOTIFICATION_SYNC_STARTED
    //Notification for attachment to stop
    
}
@end
