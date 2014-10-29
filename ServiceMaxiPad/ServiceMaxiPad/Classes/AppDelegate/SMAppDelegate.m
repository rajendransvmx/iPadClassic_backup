//
//  SMAppDelegate.m
//  ServiceMaxMobile
//
//  Created by AnilKumar on 3/21/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//
#import "SMAppDelegate.h"
#import "CustomerOrgInfo.h"
#import "StringUtil.h"
#import "AlertMessageHandler.h"
#import "ViewControllerFactory.h"
#import "PlistManager.h"
#import "AppManager.h"
#import "OAuthLoginViewController.h"
#import "FileManager.h"
#import "LocationPingManager.h"

@implementation SMAppDelegate

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

- (void)addSubviewToRootController:(UIView *)subView
{
    [self.window.rootViewController.view addSubview:subView];
}

- (void)testLogin
{
    AppManager *appManager = [AppManager sharedInstance];
    [appManager initializeApplication];
    [appManager loadScreen];
    return;
    
   // *** ---  STORED VALUES HERE.... TEXT EDIT ---*////
}

#pragma mark - Application Life Cycle Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 {
     [FileManager createApplicationDirectory];
     
     [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
     //self.window.tintColor = [UIColor whiteColor];                                                                                                                                                                                                                                                                                                                                        
     if([UINavigationBar conformsToProtocol:@protocol(UIAppearanceContainer)]) {
         [UINavigationBar appearance].tintColor = [UIColor whiteColor];
     }
     
     /** Setup Logger  */
     SMLogPerformInitialSetup();
     ConfigureLoggerAccordingToSettings();
     SXLogDebug(@"Sample Log.");
     /***  Will remove  this  part  --- vipindas  21 March 2014 */
     
     self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
     // Override point for customization after application launch.
     self.window.backgroundColor = [UIColor whiteColor];
     [self.window makeKeyAndVisible];
     
     [self testLogin];
     
     if([UINavigationBar conformsToProtocol:@protocol(UIAppearanceContainer)])
     {
         [UINavigationBar appearance].tintColor = [UIColor whiteColor];
     }
     return YES;
}
 
/**
 * @name  loadWithContorller:(UIViewController *)rootContoller
 *
 * @author Vipindas Palli
 *
 * @brief Load With Controller
 *
 * \par
 *
 *
 * @return Void
 *
 */

- (void)loadWithController:(UIViewController *)rootController
{
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window setRootViewController:rootController];
    [self.window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application
{

}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [LocationPingManager sharedInstance].isApplicationInBackground = YES;
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[AppManager  sharedInstance]verifyPlatformPreferenceChanges];
    ConfigureLoggerAccordingToSettings();
    [LocationPingManager sharedInstance].isApplicationInBackground = NO;
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

/**
 * @name  loadHomeScreen
 *
 * @author Vipindas Palli
 *
 * @brief Load home screen view
 *
 * \par
 *  <Longer description starts here>
 *
 *
 *
 * @return void
 *
 */

- (void)loadHomeScreen
{
    UIViewController *viewController = [ViewControllerFactory createViewControllerByContext:ViewControllerCustomTabBar];
    [[LocationPingManager sharedInstance] stopLocationPing];
    [[LocationPingManager sharedInstance] startLocationPing];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window setRootViewController:viewController];
    [self.window makeKeyAndVisible];
}
@end

