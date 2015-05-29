//
//  PushNotificationManager.h
//  ServiceMaxiPad
//
//  Created by Sahana on 04/03/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PushNotificationModel.h"
#import "PushNotificationQueue.h"
#import "NotificationRuleManager.h"
#import "PushNotificationWebServiceHelper.h"
#import "NotificationTrackerVC.h"



typedef NS_ENUM(NSUInteger, NotificationScreenState){
    NotificationScreenStateHidden,
    NotificationScreenStateVisible,
    NotificationScreenStateUserAction
} ;


typedef NS_ENUM(NSUInteger, NotificationUserActionState){
    NotificationUSerActionSaveAndView,
    NotificationUserActionView,
    NotificationUserActionCancel
    
};

typedef NS_ENUM(NSInteger, NotificationEditSaveStatus){
    
    NotificationEditSaveStatusSuccess,
    NotificationEditSaveStatusFailure
};

typedef NS_ENUM(NSInteger,UserActionPresentedOn ){
    
    UserActionPresentedOnNonEditScreen,
    UserActionPresentedOnEditScreen
};

typedef NS_ENUM(NSInteger,AlertMessageStyle ){
    
    AlertMessageStyleNoInternet,
    AlertMessageStyleInvalidPayload,
    AlertMessageStyleConflictsFound,
    AlertMessageGeneral
};

@interface PushNotificationManager : NSObject <NotifiactionHelperProtocol>

+(instancetype)sharedInstance;
+ (instancetype)alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype)init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype)new    __attribute__((unavailable("new not available, call sharedInstance instead")));


-( PushNotificationModel * )getNextRequestForPrevReq:(  PushNotificationModel * )currentRequest;
-(void)processRequestQueue;
-(void)loadNotification:(NSDictionary *)notificationDict;

-(void)notificationScreenIsDismissed;
-(void)deleteRequestsFromQueue:(NSArray *)requests;

-(void)externalFlowCompleted;

-(void)onSelectionOfUserAction:(NotificationUserActionState)action forRequest:(PushNotificationModel *)model;

-(void)onEditSaveCompletion:(NotificationEditSaveStatus)saveStatus
;
-(void)onEditSaveSuccess;
@end

#define PushNotificationProcessRequest     @"PushNotificationProcessRequest"

