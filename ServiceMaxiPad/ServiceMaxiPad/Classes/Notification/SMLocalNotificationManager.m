//
//  SMLocalNotificationsScheduler.m
//  ServiceMaxiPad
//
//  Created by Pushpak on 30/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SMLocalNotificationManager.h"
#import "SMLocalNotificationHelper.h"

static NSString *kLocalNotificationType = @"LocalNotificationType";
@interface SMLocalNotificationManager ()

@property (nonatomic, strong)SMLocalNotificationHelper *notificationHelper;
@end

@implementation SMLocalNotificationManager
#pragma mark Singleton Methods

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initInstance];
    });
    return sharedInstance;
}

- (instancetype)initInstance {
    self = [super init];
    // Do any other initialisation stuff here
    // ...
    _notificationHelper = [SMLocalNotificationHelper new];
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
#pragma mark - End

- (void)clearBadgeCount
{
    /*
     * Clear badgeCount from applicationIconBadgeNumber.
     */
    self.badgeCount = 0;
    [UIApplication sharedApplication].applicationIconBadgeNumber = self.badgeCount;
}

- (void)decreaseBadgeCountBy:(int) count
{
    /*
     * Decrease and set badgeCount applicationIconBadgeNumber.
     */
    self.badgeCount -= count;
    /*
     * If our badgeCount is negative, i.e inconsistent: we'll reset to 0.
     */
    if(self.badgeCount < 0) {self.badgeCount = 0;}
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = self.badgeCount;
}

- (void)scheduleLocalNotificationOfType:(SMLocalNotificationType)notificationType on:(NSDate *)fireDate {
    
    LocalNotificationModel *model = [self.notificationHelper getParametersForLocalNotificationType:notificationType];
    if (model && fireDate) {
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = fireDate;
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        
        if (model.alertMessage) {
            localNotification.alertBody = model.alertMessage;
        }
        
        if (model.alertAction) {
            localNotification.alertAction = model.alertAction;
        }
        
        if(model.soundFileName)
        {
            localNotification.soundName = model.soundFileName;
        }
        else
        {
            localNotification.soundName = UILocalNotificationDefaultSoundName;
        }
        if (model.launcImageName) {
            localNotification.alertLaunchImage = model.launcImageName;
        }
        if (model.userInfo) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:model.userInfo];
            [dict setObject:@(notificationType) forKey:kLocalNotificationType];
            localNotification.userInfo = dict;
        }
        else
        {
            localNotification.userInfo = @{kLocalNotificationType:@(notificationType)};
        }
        
        self.badgeCount ++;
        localNotification.applicationIconBadgeNumber = self.badgeCount;
        
        // Schedule it with the app
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }

}

- (void)handleReceivedLocalNotification:(UILocalNotification*)notification triggeredWhenAppIsRunning:(BOOL)status{
    
    SMLocalNotificationType type;
    if ([notification.userInfo isKindOfClass:[NSDictionary class]]) {
        NSNumber *typeNumber = [notification.userInfo objectForKey:kLocalNotificationType];
        type = typeNumber.integerValue;
    }
    [self.notificationHelper handleReceivedLocalNotification:notification
                                                        ofType:type
                                     triggeredWhenAppIsRunning:status];
}

- (void)cancelAllLocalNotifications
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}
@end
