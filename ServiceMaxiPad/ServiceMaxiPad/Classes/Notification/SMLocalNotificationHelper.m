//
//  SMLocalNotificationHelper.m
//  ServiceMaxiPad
//
//  Created by Pushpak on 30/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SMLocalNotificationHelper.h"
#import "SMLocalNotificationManager.h"

@implementation SMLocalNotificationHelper

+ (LocalNotificationModel *)getParametersForLocalNotificationType:(SMLocalNotificationType)notificationType {
    
    LocalNotificationModel *model;
    switch (notificationType) {
        case SMLocalNotificationTypeConfigSyncDue:
        {
          model = [SMLocalNotificationHelper locationParameterForConfigSyncDue];
        }
            break;
            
        default:
            break;
    }
    return model;
}

+ (void)handleReceivedLocalNotification:(UILocalNotification*)notification
                                 ofType:(SMLocalNotificationType)notificationType
              triggeredWhenAppIsRunning:(BOOL)status {
    switch (notificationType) {
        case SMLocalNotificationTypeConfigSyncDue:
        {
            [SMLocalNotificationHelper handleConfigSyncDueNotification:notification
                                             triggeredWhenAppIsRunning:status];
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - Local methods that will grow
+ (LocalNotificationModel *)locationParameterForConfigSyncDue {
    
    LocalNotificationModel *model = [[LocalNotificationModel alloc]init];
    model.alertAction = @"Sync Now";
    model.alertMessage = @"ServiceMax needs to sync forms, rules and other configuration items.";
    return model;
}
+ (void)handleConfigSyncDueNotification:(UILocalNotification *)notification
              triggeredWhenAppIsRunning:(BOOL)status {
   
    if (status)
    {
        /*
         * Triggered when application in running. Hence populate a alert so do whatsoever.
         */
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Config Sync Needed"
                                                       message:@"ServiceMax needs to sync forms, rules and other configuration items. If you choose to sync later, this action can be found in Tools."
                                                      delegate:nil
                                             cancelButtonTitle:@"Later"
                                             otherButtonTitles:@"Sync Now", nil];
        [alert show];
    }
    else
    {
        /*
         * Triggered when application not running. Probably do a little deep linking from here.
         */
        
    }
}
@end
