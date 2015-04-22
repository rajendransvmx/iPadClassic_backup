//
//  SMLocalNotificationsScheduler.h
//  ServiceMaxiPad
//
//  Created by Pushpak on 30/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SMLocalNotificationType)
{
    SMLocalNotificationTypeUnknown = -1,
    SMLocalNotificationTypeConfigSyncDue = 20,
    SMLocalNotificationTypePurgeDataDue = 21,
};

@interface SMLocalNotificationManager : NSObject
/*
 * BadgeCount is to keep track of the application icon badge count.
 */
@property (nonatomic) NSInteger badgeCount;

+ (instancetype)sharedInstance;
+ (instancetype)alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype)init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype)new    __attribute__((unavailable("new not available, call sharedInstance instead")));
- (void)decreaseBadgeCountBy:(int) count;
- (void)clearBadgeCount;

- (void)scheduleLocalNotificationOfType:(SMLocalNotificationType)notificationType on:(NSDate *)fireDate;
- (void)handleReceivedLocalNotification:(UILocalNotification*)notification triggeredWhenAppIsRunning:(BOOL)status;
- (void)cancelAllLocalNotifications;
- (void)cancelNotificationOfType:(SMLocalNotificationType)notificationType;
@end
