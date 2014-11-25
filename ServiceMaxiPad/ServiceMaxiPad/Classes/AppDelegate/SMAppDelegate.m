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
#import "SMLocalNotificationManager.h"
#import "SyncManager.h"

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
     
     
     /***************************************************
      * Handle launching from a notification
      */
      [[SMLocalNotificationManager sharedInstance] clearBadgeCount];
     if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
         [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
     }
     UILocalNotification *localNotif =
     [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
     if (localNotif) {
         [[SMLocalNotificationManager sharedInstance] handleReceivedLocalNotification:localNotif
                                                            triggeredWhenAppIsRunning:NO];
         NSLog(@"Recieved Notification %@",localNotif);
     }
     /**************************************************/
     
     
     /***  Will remove  this  part  --- vipindas  21 March 2014 */
     
     self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
     // Override point for customization after application launch.
     self.window.backgroundColor = [UIColor whiteColor];
     [self.window makeKeyAndVisible];
     
     [self testLogin];
     
     //[[SyncManager sharedInstance] scheduleSync];
     
     if([UINavigationBar conformsToProtocol:@protocol(UIAppearanceContainer)])
     {
         [UINavigationBar appearance].tintColor = [UIColor whiteColor];
     }
     
     NSLog(@"------ AapplicationLaunching -------");
     
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
#pragma mark - Local Notification methods
- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
    
    /*
     * Handle the notificaton when the app is running
     */
    [[SMLocalNotificationManager sharedInstance] clearBadgeCount];
    [[SMLocalNotificationManager sharedInstance] handleReceivedLocalNotification:notif
                                                       triggeredWhenAppIsRunning:YES];
    NSLog(@"Recieved Notification %@",notif);
}
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forLocalNotification:(UILocalNotification *)notification
  completionHandler:(void(^)())completionHandler{
    
    /*
     * Handle the notificaton when the app is running
     */
    [[SMLocalNotificationManager sharedInstance] clearBadgeCount];
    [[SMLocalNotificationManager sharedInstance] handleReceivedLocalNotification:notification
                                                       triggeredWhenAppIsRunning:YES];
    NSLog(@"Recieved Notification %@",notification);
}

#pragma mark - End
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [LocationPingManager sharedInstance].isApplicationInBackground = YES;
    [[SyncManager sharedInstance] invalidateScheduleSync];
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"  ------AapplicationWillEnterForeground -------");
    [[AppManager  sharedInstance]verifyPlatformPreferenceChanges];
    ConfigureLoggerAccordingToSettings();
    [[SyncManager sharedInstance] scheduleSync];
    [LocationPingManager sharedInstance].isApplicationInBackground = NO;
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

#pragma mark - Backgrounding Methods -
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)())completionHandler
{
    self.backgroundSessionCompletionHandler = completionHandler;
}

@end

