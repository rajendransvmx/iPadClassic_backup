//
//  NotificationModel.h
//  ServiceMaxiPad
//
//  Created by Krishna Shanbhag on 04/03/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NotificationRequestState) {
    
    NotificationRequestStateUnknown,
    NotificationRequestStateDownloadInProgress,
    NotificationRequestStateDownloadStarted,
    NotificationRequestStateDownloadCompleted,
    NotificationRequestStateUserAction,
    NotificationRequestStateDownloadFailed,
    NotificationRequestStateNetworkNotReachable
    
};

typedef NS_ENUM(NSInteger,NotificationRequestType){
    
    NotificationRequestTypeDownload = 0,
    NotificationRequestTypeSync
};

@interface PushNotificationModel : NSObject

@property (nonatomic, strong) NSString *notificationId;
@property (nonatomic, strong) NSString *sfId;
@property (nonatomic, strong) NSString *objectName;
@property (nonatomic, strong) NSString *actionTag;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *orgId;
@property (nonatomic, strong) NSString *localId;
@property (nonatomic, strong) NSString *notificationMessage;
@property (nonatomic,strong)  NSString *notificationTitle;
@property (nonatomic)         NotificationRequestState requestStatus;
@property (nonatomic)         NotificationRequestType  requestType;

- (id)initWithDictionary:(NSDictionary *)dataDictionay;

@end
