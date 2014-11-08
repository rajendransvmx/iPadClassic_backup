//
//  SyncScheduler.m
//  ServiceMaxMobile
//
//  Created by Damodar on 21/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SyncScheduler.h"
#import "SyncManager.h"

@interface SyncScheduler ()

@property (nonatomic, strong) NSTimer *schduler;

@property (nonatomic, assign) SyncType sync;
@property (nonatomic, assign) BOOL shouldSkip;
@property (nonatomic, assign) NSTimeInterval interval;

@end

@implementation SyncScheduler

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // Set to invalid data.
        _sync = NSNotFound;
        _interval = NAN;
        _shouldSkip = YES;
        _schduler = nil;
        _delegate = nil;
    }
    return self;
}
- (void)scheduleForSync:(SyncType)syncType withInterval:(NSTimeInterval)timeInterval andDelegate:(id<SchedulerDelegate>)delegate
{
    self.sync = syncType;
    self.interval = timeInterval;
    self.delegate = delegate;
    self.shouldSkip = NO;
    self.schduler = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:self.interval]
                                             interval:self.interval
                                               target:self
                                             selector:@selector(triggerSync:)
                                             userInfo:nil
                                              repeats:YES];
}

- (void)skipNextSchedule
{
    self.shouldSkip = YES;
}

- (void)invalidateScheduler
{
    [self.schduler invalidate];
    self.schduler = nil;
}

- (void)reScheduleWithTimeInterval:(NSTimeInterval)interval
{
    [self invalidateScheduler];
    
    self.interval = interval;
    self.schduler = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:self.interval]
                                             interval:self.interval
                                               target:self
                                             selector:@selector(triggerSync:)
                                             userInfo:nil
                                              repeats:YES];
}

- (void)dealloc
{
    [self invalidateScheduler];
    [super dealloc];
}

- (void)triggerSync:(NSTimer*)timer
{
    if(self.shouldSkip)
    {
        self.shouldSkip = NO;
        return;
    }
    
    [[SyncManager sharedInstance] performSyncWithType:self.sync];
    
    if([self.delegate respondsToSelector:@selector(sync:firedAt:)])
    {
        [self.delegate sync:self.sync firedAt:[NSDate date]];
    }
    
}

@end
