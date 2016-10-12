//
//  SMAppDelegate.h
//  ServiceMaxMobile
//
//  Created by AnilKumar on 3/21/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

@class OAuthLoginViewController;
@class AppManager;

@interface SMAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSString          * kRestoreLocationKey;
@property (strong, nonatomic) UIWindow *window;
@property (copy) void (^backgroundSessionCompletionHandler)();

//IPAD-4283 Back Porting Sync error reporting for WIN 16
@property(nonatomic,strong)NSString *syncReportingType;
@property(nonatomic,strong)NSMutableArray *syncDataArray;
@property(nonatomic,strong)NSMutableArray *syncErrorDataArray;
@property(nonatomic,strong)NSString *serverUrl;

/**
 * @name  loadWithController:(UIViewController *)rootController
 *
 * @author Vipindas Palli
 *
 * @brief Load with Controller
 *
 * \par
 *
 *
 * @return Void
 *
 */

- (void)loadWithController:(UIViewController *)rootController;


/**
 * @name  - (void)addSubviewToRootController:(UIView *)subView
 *
 * @author Vipindas Palli
 *
 * @brief  Add subview to root view controller
 *
 * \par
 *
 *
 * @return Void
 *
 */

- (void)addSubviewToRootController:(UIView *)subView;

- (void)disableIdleTimerForApplication;

@end
