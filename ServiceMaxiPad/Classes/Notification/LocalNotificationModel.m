//
//  LocalNotificationModel.m
//  ServiceMaxiPad
//
//  Created by Pushpak on 30/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "LocalNotificationModel.h"

@implementation LocalNotificationModel
- (void)dealloc {
    _fireDate = nil;
    _alertMessage = nil;
    _alertAction = nil;
    _soundFileName = nil;
    _launcImageName = nil;
    _userInfo = nil;
}
@end
