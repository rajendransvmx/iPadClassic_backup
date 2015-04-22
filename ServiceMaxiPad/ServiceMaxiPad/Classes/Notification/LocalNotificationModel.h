//
//  LocalNotificationModel.h
//  ServiceMaxiPad
//
//  Created by Pushpak on 30/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalNotificationModel : NSObject

@property (nonatomic, strong) NSDate *fireDate;
@property (nonatomic, copy) NSString *alertMessage;
@property (nonatomic, copy) NSString *alertAction;
@property (nonatomic, copy) NSString *soundFileName;
@property (nonatomic, copy) NSString *launcImageName;
@property (nonatomic, copy) NSDictionary *userInfo;
@property NSCalendarUnit repeatInterval;
@property (nonatomic, readwrite)BOOL isRepeatIntervalSet;
@property (nonatomic, assign) NSInteger badgeNumber;

@end
