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
#import "SMXConstants.h"
#import "TestFlight.h"

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

/*
 My Apps Custom uncaught exception catcher, we do special stuff here, and TestFlight takes care of the rest
 */
void HandleExceptions(NSException *exception) {
    // Save application data on crash
}
/*
 My Apps Custom signal catcher, we do special stuff here, and TestFlight takes care of the rest
 */
void SignalHandler(int sig) {
    // Save application data on crash
}

#pragma mark - Application Life Cycle Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 {
     [FileManager createApplicationDirectory];
     [self disableIdleTimerForApplication];
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
         SXLogInfo(@"Recieved Notification %@",localNotif);
     }
     [[SMLocalNotificationManager sharedInstance] cancelAllLocalNotifications];
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
     
     /*
        TESTFLIGHT configuration and intialization
      */
     // installs HandleExceptions as the Uncaught Exception Handler
     NSSetUncaughtExceptionHandler(&HandleExceptions);
     // create the signal action structure
     struct sigaction newSignalAction;
     // initialize the signal action structure
     memset(&newSignalAction, 0, sizeof(newSignalAction));
     // set SignalHandler as the handler in the signal action structure
     newSignalAction.sa_handler = &SignalHandler;
     // set SignalHandler as the handlers for SIGABRT, SIGILL and SIGBUS
     sigaction(SIGABRT, &newSignalAction, NULL);
     sigaction(SIGILL, &newSignalAction, NULL);
     sigaction(SIGBUS, &newSignalAction, NULL);
     
     [TestFlight setOptions:@{ TFOptionDisableInAppUpdates : @YES }];
     [TestFlight setOptions:@{ TFOptionLogToConsole : @NO }];
     [TestFlight setOptions:@{ TFOptionLogToSTDERR : @NO }];
     [TestFlight takeOff:TESTFLIGHTTOKEN];
     NSLog(@"------ AapplicationLaunching -------");
     
     return YES;
}


- (void)disableIdleTimerForApplication
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
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
    SXLogInfo(@"Recieved Notification %@",notif);
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
    SXLogInfo(@"Recieved Notification %@",notification);
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
    if ([AppManager sharedInstance].applicationStatus == ApplicationStatusInitialSyncCompleted) {
        [[SyncManager sharedInstance] scheduleSync];
    }
    [LocationPingManager sharedInstance].isApplicationInBackground = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:CHECK_FOR_TIMEZONE_CHANGE object:nil];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[SMLocalNotificationManager sharedInstance] clearBadgeCount];
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

