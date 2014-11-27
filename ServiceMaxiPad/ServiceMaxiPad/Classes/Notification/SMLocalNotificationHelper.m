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

NSInteger const configSyncDueAlertTag = 134634654;


@interface SMLocalNotificationHelper ()<UIAlertViewDelegate>

@end

@implementation SMLocalNotificationHelper

- (LocalNotificationModel *)getParametersForLocalNotificationType:(SMLocalNotificationType)notificationType {
    
    LocalNotificationModel *model;
    switch (notificationType) {
        case SMLocalNotificationTypeConfigSyncDue:
        {
          model = [self locationParameterForConfigSyncDue];
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
            
        default:
            break;
    }
    
}

#pragma mark - Local methods that will grow
- (LocalNotificationModel *)locationParameterForConfigSyncDue {
    
    LocalNotificationModel *model = [[LocalNotificationModel alloc]init];
    model.alertAction = @"Sync Now";
    model.alertMessage = @"ServiceMax needs to sync forms, rules and other configuration items.";
    model.isRepeatIntervalSet = NO;
    return model;
}

- (void)handleConfigSyncDueNotification:(UILocalNotification *)notification
              triggeredWhenAppIsRunning:(BOOL)status {
   
    if (status)
    {
        /*
         * Triggered when application in running. Hence populate a alert so do whatsoever.
         */
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Config Sync Needed"
                                                       message:@"ServiceMax needs to sync forms, rules and other configuration items. If you choose to sync later, this action can be found in Tools."
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:@"Later", @"Sync Now", nil];
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

#pragma mark - UIAlertViewDelegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (alertView.tag) {
            
        case configSyncDueAlertTag:
        {
            
            if (buttonIndex == 0)
            {
                // Pressed  Later - We need to shift next sync to 
                //[[SyncManager sharedInstance] scheduleConfigSync];
            }
            else
            {
                UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
                
                Class rootClass = [keyWindow.rootViewController class];
                
                if (rootClass == [UINavigationController class]) {
                    
                } else if (rootClass == [CustomTabBar class]) {
                    
                    CustomTabBar *rootViewController = (CustomTabBar *)keyWindow.rootViewController;
                    [rootViewController selectTab:6];
                    //startScheduledConfigSync
                    [[NSNotificationCenter defaultCenter] postNotificationName:kScheduledConfigSyncNotification
                                                                        object:nil userInfo:nil];
                }
            }
        }
            break;
            
        default:
            break;
    }
}
@end
