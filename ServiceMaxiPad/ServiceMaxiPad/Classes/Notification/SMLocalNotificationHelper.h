//
//  SMLocalNotificationHelper.h
//  ServiceMaxiPad
//
//  Created by Pushpak on 30/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalNotificationModel.h"
#import "SMLocalNotificationManager.h"

@interface SMLocalNotificationHelper : NSObject

- (LocalNotificationModel *)getParametersForLocalNotificationType:(SMLocalNotificationType)notificationType;
- (void)handleReceivedLocalNotification:(UILocalNotification*)notification
                                 ofType:(SMLocalNotificationType)notificationType
              triggeredWhenAppIsRunning:(BOOL)status;
@end
