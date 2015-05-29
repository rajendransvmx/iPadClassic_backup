//
//  AutoLockManager.h
//  ServiceMaxiPad
//
//  Created by Admin on 26/05/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    initialSyncAL = 0,
    configSyncAL,
    resetAppAL,
    manualDataSyncAL,
    purgeDataAL,
    pushLogsAL,
    noneAL
} AutoLock;

@interface AutoLockManager : NSObject
{
    BOOL initialSync;
    BOOL configSync;
    BOOL resetApp;
    BOOL manualDataSync;
    BOOL dataPurge;
    BOOL pushLogs;
    
}
+ (id)sharedManager;
-(void)enableAutoLockSettingFor:(AutoLock) autoLock;
-(void)disableAutoLockSettingFor:(AutoLock) autoLock;

@end
