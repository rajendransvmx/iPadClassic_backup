//
//  AutoLockManager.m
//  ServiceMaxiPad
//
//  Created by Admin on 26/05/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "AutoLockManager.h"

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
            initialSync = NO;
            break;
        case configSyncAL:
            configSync = NO;
            break;
        case resetAppAL:
            resetApp = NO;
            break;
        case manualDataSyncAL:
            manualDataSync = NO;
            break;
        case purgeDataAL:
            dataPurge = NO;
            break;
        case pushLogsAL:
            pushLogs = NO;
            break;
            
        default:
            break;
    }
    
    [self enableAutoLockSetting];
}

-(void)enableAutoLockSetting
{
    NSLog(@" in enableAutoLockSetting initialSync: %d, configSync:%d, resetApp:%d, manualDataSync:%d, dataPurge:%d, pushLogs:%d", initialSync, configSync, resetApp, manualDataSync, dataPurge, pushLogs);
    if (!initialSync && !configSync && !resetApp && !manualDataSync && !dataPurge && !pushLogs)
    {
        NSLog(@"idleTimerDisabled = NO");
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
}

-(void)disableAutoLockSettingFor:(AutoLock) autoLock
{
    switch (autoLock) {
        case initialSyncAL:
            initialSync = YES;
            break;
        case configSyncAL:
            configSync = YES;
            break;
        case resetAppAL:
            resetApp = YES;
            break;
        case manualDataSyncAL:
            manualDataSync = YES;
            break;
        case purgeDataAL:
            dataPurge = YES;
            break;
        case pushLogsAL:
            pushLogs = YES;
            break;
            
        default:
            break;
    }
    
    [self disableAutoLockSetting];
}

-(void)disableAutoLockSetting
{
    NSLog(@"idleTimerDisabled = YES");

    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)dealloc {
    // Should never be called.
}

@end
