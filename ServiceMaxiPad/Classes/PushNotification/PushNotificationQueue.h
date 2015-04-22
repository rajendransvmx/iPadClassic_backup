//
//  NotificationQueue.h
//  ServiceMaxiPad
//
//  Created by Sahana on 04/03/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PushNotificationModel.h"

@interface PushNotificationQueue : NSObject

-(void)addRequestToQueue:(PushNotificationModel *)reqModel;

-(void)removeReqFromQueue:(PushNotificationModel *)requestModel;
-(void)removeRequestsFromQueue:(NSArray *)requestsArray;

-(PushNotificationModel *)getNextRequestForCurrentRequest:(PushNotificationModel * )PreviousReq;
-(PushNotificationModel *)getNextRequestToBeDownloaded;

//-(PushNotificationQueueStatus)getQueueState;


-(BOOL)shouldProcessTheNextRequest;
-(BOOL)shouldShowUserActionForRequest:(PushNotificationModel *)notificationModel;
-(PushNotificationModel *)getLastDownloadCompletedRequest;

-(BOOL)checkForLastRequest:(PushNotificationModel *)model;
-(void)removeAllDownloadCompletedRequests;

@end
