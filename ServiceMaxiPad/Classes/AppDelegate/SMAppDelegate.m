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
#import "AttachmentsUploadManager.h"
#import "PushNotificationUtility.h"
#import "PushNotificationManager.h"
#import <NewRelicAgent/NewRelic.h>


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
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
     [FileManager createApplicationDirectory];
//     [self disableIdleTimerForApplication];
     //self.window.tintColor = [UIColor whiteColor];
/*
     if([UINavigationBar conformsToProtocol:@protocol(UIAppearanceContainer)]) {
         [UINavigationBar appearance].tintColor = [UIColor whiteColor];
     }
*/
     
     //IPAD-4283 Back Porting Sync error reporting for WIN 16
     NSMutableArray *arr = [[NSMutableArray alloc]init];
     self.syncErrorDataArray = arr;
     
     NSMutableArray *arr2 = [[NSMutableArray alloc]init];
     self.syncDataArray = arr2;
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
     [[NSNotificationCenter defaultCenter] addObserverForName:NSUserDefaultsDidChangeNotification
                                                       object:nil
                                                        queue:[NSOperationQueue mainQueue]
                                                   usingBlock:^(NSNotification *note) {
                                                       [PlistManager updateServerURLFromManagedConfig];
                                                   }];
     
     if([PlistManager enableAnalytics]) {
         [NewRelicAgent startWithApplicationToken:kNewRelicAnalyticsKey];
     }

     //[[SyncManager sharedInstance] scheduleSync];
    NSLog(@"------ AapplicationLaunching -------");
     
     return YES;
}


- (void)disableIdleTimerForApplication
{
//    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
//    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
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
    [[AttachmentsUploadManager sharedManager] modelUnderUploadProcess];
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

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([[url scheme] isEqualToString:@"svmxmobilepulsesum15"])
    {
        NSDictionary *queryStringDictionary = [PushNotificationUtility getDictionaryFromSharedURL:url];
     
        BOOL isValidUser = [PushNotificationUtility validateOrg:queryStringDictionary];
        if (isValidUser)
        {
            [[PushNotificationManager sharedInstance] loadNotification:queryStringDictionary];
        }
    }
    return YES; 
}


@end

