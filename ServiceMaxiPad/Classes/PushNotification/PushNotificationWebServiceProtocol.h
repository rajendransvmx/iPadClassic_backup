//
//  PushNotificationWebServiceProtocol.h
//  ServiceMaxiPad
//
//  Created by Sahana on 06/03/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PushNotificationModel.h"


@protocol PushNotificationWebServiceProtocol <NSObject>
-(void)startDownloadRequest:(PushNotificationModel *)notificationModel;
-(void)cancelAllDownloads;
-(void)downloadCompletedForRequest:(PushNotificationModel *)notificationModel;
-(void)notifyManagerDownloadStateForRequest:(PushNotificationModel *)notificationModel;

@end
