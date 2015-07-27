//
//  AutoLockManager.m
//  ServiceMaxiPad
//
//  Created by Admin on 26/05/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "AutoLockManager.h"

@interface AutoLockManager ()

@property(nonatomic, assign) BOOL initialSync;
@property(nonatomic, assign) BOOL configSync;
@property(nonatomic, assign) BOOL resetApp;
@property(nonatomic, assign) BOOL manualDataSync;
@property(nonatomic, assign) BOOL dataPurge;
@property(nonatomic, assign) BOOL pushLogs;

@end


@implementation AutoLockManager

#pragma mark Singleton Methods

+ (id)sharedManager {
    static AutoLockManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

-(void)enableAutoLockSettingFor:(AutoLock) autoLock{
    
    switch (autoLock) {
        case initialSyncAL:
            self.initialSync = NO;
            break;
        case configSyncAL:
            self.configSync = NO;
            break;
        case resetAppAL:
            self.resetApp = NO;
            break;
        case manualDataSyncAL:
            self.manualDataSync = NO;
            break;
        case purgeDataAL:
            self.dataPurge = NO;
            break;
        case pushLogsAL:
            self.pushLogs = NO;
            break;
            
        default:
            break;
    }
    
    [self enableAutoLockAfterDelay];
}

-(void)enableAutoLockAfterDelay
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!self.initialSync && !self.configSync && !self.resetApp && !self.manualDataSync && !self.dataPurge && !self.pushLogs)
        {
            [self killTimer];
            [self performSelector:@selector(autoLockEnable) withObject:nil afterDelay:10.0f];
        }
        
    });
}

-(void)autoLockEnable
{
    
    NSLog(@"Auto-lock ENABLED");
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
}

-(void)disableAutoLockSettingFor:(AutoLock) autoLock
{
    switch (autoLock) {
        case initialSyncAL:
            self.initialSync = YES;
            break;
        case configSyncAL:
            self.configSync = YES;
            break;
        case resetAppAL:
            self.resetApp = YES;
            break;
        case manualDataSyncAL:
            self.manualDataSync = YES;
            break;
        case purgeDataAL:
            self.dataPurge = YES;
            break;
        case pushLogsAL:
            self.pushLogs = YES;
            break;
            
        default:
            break;
    }
    
    [self disableAutoLockSetting];
    
}

-(void)disableAutoLockSetting
{
    [self killTimer];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

-(void)killTimer
{
    // cancel the above call (and any others on self)
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoLockEnable) object:nil];
}

- (void)dealloc
{
    // Should never be called.
}

@end
