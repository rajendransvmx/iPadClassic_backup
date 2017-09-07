//
//  SMLocalNotificationHelper.m
//  ServiceMaxiPad
//
//  Created by Pushpak on 30/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SMLocalNotificationHelper.h"
#import "SMLocalNotificationManager.h"
#import "CustomTabBar.h"
#import "SyncManager.h"
#import "SMDataPurgeManager.h"
#import "TagManager.h"
#import "TagConstant.h"

NSInteger const configSyncDueAlertTag = 998;
NSInteger const purgeDataDueAlertTag = 999;

@interface SMLocalNotificationHelper ()<UIAlertViewDelegate>

@end

@implementation SMLocalNotificationHelper

- (LocalNotificationModel *)getParametersForLocalNotificationType:(SMLocalNotificationType)notificationType {
    
    LocalNotificationModel *model;
    switch (notificationType) {
        case SMLocalNotificationTypeConfigSyncDue:
        {
          model = [self localNotificationParameterForConfigSyncDue];
        }
            break;
        case SMLocalNotificationTypePurgeDataDue:
        {
            model = [self localNotificationParameterForPurgeDataDue];
        }
            break;
        default:
            break;
    }
    return model;
}

- (void)handleReceivedLocalNotification:(UILocalNotification*)notification
                                 ofType:(SMLocalNotificationType)notificationType
              triggeredWhenAppIsRunning:(BOOL)status {
    switch (notificationType) {
        case SMLocalNotificationTypeConfigSyncDue:
        {
            [self handleConfigSyncDueNotification:notification
                                             triggeredWhenAppIsRunning:status];
        }
            break;
        case SMLocalNotificationTypePurgeDataDue:
        {
            [self handlePurgeDataDueNotification:notification triggeredWhenAppIsRunning:status];
        }
            break;
        default:
            break;
    }
    
}

#pragma mark - Local methods that will grow
- (LocalNotificationModel *)localNotificationParameterForConfigSyncDue {
    
    LocalNotificationModel *model = [[LocalNotificationModel alloc]init];
    model.alertAction = [[TagManager sharedInstance]tagByName:kTag_SyncNow];
    model.alertMessage = [[TagManager sharedInstance]tagByName:kTag_ServiceMaxNeedSyncForms];
    model.isRepeatIntervalSet = NO;
    model.badgeNumber = 1;
    return model;
}

- (void)handleConfigSyncDueNotification:(UILocalNotification *)notification
              triggeredWhenAppIsRunning:(BOOL)status {
   
    if (status)
    {
        if ([SyncManager sharedInstance].isConfigSyncDueAlertShown) {
            return;
        }
        [SyncManager sharedInstance].isConfigSyncDueAlertShown = YES;
        /*
         * Triggered when application in running. Hence populate a alert so do whatsoever.
         */
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[[TagManager sharedInstance]tagByName:kTag_ConfigSyncNeeded]
                                                       message:[[TagManager sharedInstance]tagByName:kTag_ServiceMaxNeedSyncFormsActionsFoundInTools]
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk], nil];
        alert.tag = configSyncDueAlertTag;
        [alert show];
    }
    else
    {
        /*
         * Triggered when application not running. Probably do a little deep linking from here.
         */
        
    }
}

#pragma mark - Purge Data 
- (LocalNotificationModel *)localNotificationParameterForPurgeDataDue {
    
    LocalNotificationModel *model = [[LocalNotificationModel alloc]init];
    model.alertAction = [[TagManager sharedInstance]tagByName:kTag_PurgeNow];
    model.alertMessage = [[TagManager sharedInstance]tagByName:kTag_ServiceMAxNeedPurgeOldAppmt];
    model.isRepeatIntervalSet = NO;
    model.badgeNumber = 1;
    return model;
}

- (void)handlePurgeDataDueNotification:(UILocalNotification *)notification
             triggeredWhenAppIsRunning:(BOOL)status {
    
    if (status)
    {
        if ([SMDataPurgeManager sharedInstance].isPurgeDataDueAlertShown) {
            return;
        }
        [SMDataPurgeManager sharedInstance].isPurgeDataDueAlertShown = YES;
        /*
         * Triggered when application in running. Hence populate a alert so do whatsoever.
         */
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Data Purge Needed"
                                                       message:[[TagManager sharedInstance]tagByName:kTag_ServiceMAxNeedPurgeOldAppmtActionFoundInTools]
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk], nil];
        alert.tag = purgeDataDueAlertTag;
        [alert show];
    }
    else
    {
        /*
         * Triggered when application not running. Probably do a little deep linking from here.
         */
        
    }
}

#pragma mark - UIAlertViewDelegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (alertView.tag) {
            
        case configSyncDueAlertTag:
        {
            if (buttonIndex == 0)
            {
                /*
                 * User pressed ok.
                 */
                [SyncManager sharedInstance].isConfigSyncDueAlertShown = NO;
            }
        }
            break;
        case purgeDataDueAlertTag:
        {
            if (buttonIndex == 0)
            {
                /*
                 * User pressed ok.
                 */
                [SMDataPurgeManager sharedInstance].isPurgeDataDueAlertShown = NO;
                [[SMDataPurgeManager sharedInstance] initiateAllDataPurgeProcess]; //IPAD-4651
            }
        }
            break;

        default:
            break;
    }
}
@end
