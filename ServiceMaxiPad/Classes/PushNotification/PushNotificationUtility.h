//
//  PushNotificationUtility.h
//  ServiceMaxiPad
//
//  Created by Sahana on 12/03/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncConstants.h"


typedef NS_ENUM(NSInteger, ViewControllerType){
    
    CalendarViewController,
    SearchViewController,
    NewItemViewControllert,
    SettingsViewController,
    TaskViewController,
    Unknown
    
};

@interface PushNotificationUtility : NSObject

+(BOOL)isEditViewController:(UIViewController *)rootViewcontroller;
+(ViewControllerType)getRootViewControllerType:(UIViewController *)rootViewController;
+(ViewControllerType)selectedViewControllerOnTabBar;
+(UIViewController *)getTopViewController;
+(UIViewController *)getRootViewController;
+(void)removeViewControllersFromNavStack:(UIViewController *)viewController;
+(UIViewController *)getCalendarViewController;
+(void)selectCalendarViewController;
+(UIViewController *)getParentViewController;
+(NSString *)getLocalIdForSfId:(NSString *)sfId objectName:(NSString *)objectName;
+(NSString *)getObjectForSfId:(NSString *)sfId;
+(BOOL)validateOrg:(NSDictionary *)APNSDict;
+(NSMutableDictionary*)getDictionaryFromSharedURL:(NSURL*)url;

+(BOOL)shouldInitiatePushNotification:(CategoryType)categoryType;
+(BOOL)isModallyPresented:(UIViewController *)controller;

@end
