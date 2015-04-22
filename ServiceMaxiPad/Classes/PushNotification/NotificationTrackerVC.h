//
//  NotificationTrackerVC.h
//  ServiceMaxiPad
//
//  Created by Krishna Shanbhag on 06/03/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PushNotificationModel.h"
#import "PushNotificationManager.h"

@interface NotificationTrackerVC : UIViewController <UITableViewDataSource, UITableViewDelegate>
- (void) downloadProgressForNotification:(PushNotificationModel *)model;

-(void)presentuserActionForRequest:(PushNotificationModel *)reqModel presentingMode:(NSInteger)presentingMode;

//-(void)notifyManagerForSelectedUSerOption:()

@end