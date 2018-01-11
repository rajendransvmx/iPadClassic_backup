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
 method Name: showlaunchScreenWithCalendarAlert
 Description: If the Calendar of the Device is not gregorian. The app should be taken to the Login screen and a Alert view should be displayed to ask user to change the Calendar Type to GREGORIAN.
 Defect#: 025869
 author: BSP
 Date: 11-Mar-2016
 */

-(void)showlaunchScreenWithCalendarAlert{
  
    AppManager *appManager = [AppManager sharedInstance];
    ApplicationStatus previousStatus  = [PlistManager getStoredApplicationPreviousSyncStatus]; //get the previous status of the app. This will have to be again set to the app when the login screen with Calendar error is displayed so that once the calendar is corrected, the app is launched in the previous status.
    [appManager setApplicationStatus:ApplicationStatusInLaunchScreen];

    [appManager loadScreen];
    [appManager setApplicationStatus:previousStatus]; // Assigning the previous app status to the app.

    return;
}

/**
 * @name   loadCookies
 *
 * @author Madhusudhan HK
 *
 * @brief update all saved cookies to NSHTTPCookieStorage instance.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return void
 *
 */
- (void)loadCookies
{
    NSArray             *cookies       = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: @"cookies"]];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in cookies)
    {
        [cookieStorage setCookie: cookie];
    }
}

#pragma mark - Application Life Cycle Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 {
     NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler); // IPAD-4585
     
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
     [FileManager createApplicationDirectory];
//     [self disableIdleTimerForApplication];
     //self.window.tintColor = [UIColor whiteColor];
/*
     if([UINavigationBar conformsToProtocol:@protocol(UIAppearanceContainer)]) {
         [UINavigationBar appearance].tintColor = [UIColor whiteColor];
     }
*/
     
     /** Setup Logger  */
     //HS 29Fev added one key
     NSMutableArray *arr = [[NSMutableArray alloc]init];
     self.syncErrorDataArray = arr;
     
     NSMutableArray *arr2 = [[NSMutableArray alloc]init];
     self.syncDataArray = arr2;
     //self.syncReportingType = @"error";
     
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

     NSString *calendarIdentifier = [NSCalendar autoupdatingCurrentCalendar].calendarIdentifier;

     if (![calendarIdentifier caseInsensitiveCompare:@"gregorian"]==NSOrderedSame) {
         [self showlaunchScreenWithCalendarAlert];
         [self showAlert];
     }
     else{
         [self testLogin];
         [self loadCookies];
         
         [[NSNotificationCenter defaultCenter] addObserverForName:NSUserDefaultsDidChangeNotification
                                                           object:nil
                                                            queue:[NSOperationQueue mainQueue]
                                                       usingBlock:^(NSNotification *note) {
                                                           [PlistManager updateServerURLFromManagedConfig];
                                                       }];
     }

     //[[SyncManager sharedInstance] scheduleSync];
    NSLog(@"------ AapplicationLaunching -------");
     
     return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0);
{
    if(alertView.tag == 1001 && buttonIndex == 0)
        [self showAlert];
}

/*
 method Name: showAlert
 Description: If the Calendar of the Device is not gregorian. Display the AlertView asking the user to change the Calendar.
 Defect#: 025869
 author: BSP
 Date: 11-Mar-2016
 */


-(void)showAlert{
    
    if (SYSTEM_VERSION < 8.0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[[TagManager sharedInstance]tagByName:kTag_GregorianCalendarOnlyAlert] delegate:self cancelButtonTitle:@"Reload" otherButtonTitles: nil];
        alertView.tag = 1001;
        [alertView show];
    }
    else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[[TagManager sharedInstance]tagByName:kTag_GregorianCalendarOnlyAlert] preferredStyle:(UIAlertControllerStyleAlert)];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Reload" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
            [self checkForCalendarType];
        }];
        
        
        [alertController addAction:okAction];

        if (self.window.rootViewController.presentedViewController) {
            self.window.rootViewController = self.window.rootViewController.presentedViewController;
        }
        
        [self.window.rootViewController presentViewController:alertController animated:YES completion:^{}];
    }

}

-(void)checkForCalendarType{
    NSString *calendarIdentifier = [NSCalendar autoupdatingCurrentCalendar].calendarIdentifier;
//    NSString *TheCalendarIdentifier = [NSCalendar autoupdatingCurrentCalendar].calendarIdentifier;

    if (![calendarIdentifier caseInsensitiveCompare:@"gregorian"]==NSOrderedSame) {
        
        [self showAlert];
    }
    else{
        [self testLogin];
        [self loadCookies];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:NSUserDefaultsDidChangeNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          [PlistManager updateServerURLFromManagedConfig];
                                                      }];
    }
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
 /* This was introduced to help Automation team for Identifying the title of the App. Should not go in App store Build. Hence reverting.
  
    NSString *projectTitle = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    rootController.title = projectTitle;
 */
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window setRootViewController:rootController];
    [self.window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSString *splashImage;
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        splashImage = @"LaunchImagePortrait";
    }
    else {
        splashImage = @"LaunchImageLandscape";
    }
    
    splashImageView = [[UIImageView alloc]initWithFrame:[self.window frame]];
    [splashImageView setImage:[UIImage imageNamed:splashImage]];
    [self.window addSubview:splashImageView];
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
    [[SyncManager sharedInstance] setEndTimeForSyncProfiling]; // IPAD-4585
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
    [[SyncManager sharedInstance] clearEndTimeForSyncProfiling]; // IPAD-4585
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"  ------AapplicationDidBecomeActive -------");
    if(splashImageView != nil) {
        [splashImageView removeFromSuperview];
        splashImageView = nil;
    }
    [[SMLocalNotificationManager sharedInstance] clearBadgeCount];
    [[AttachmentsUploadManager sharedManager] modelUnderUploadProcess];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    [[SyncManager sharedInstance] setEndTimeForSyncProfiling]; // IPAD-4585
}

#pragma mark - Backgrounding Methods -

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)())completionHandler
{
    self.backgroundSessionCompletionHandler = completionHandler;
}


//Fix: SecScan-814
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options NS_AVAILABLE_IOS(9_0)
{
    BOOL openURL = NO;
    NSString *sourceKey = @"UIApplicationOpenURLOptionsSourceApplicationKey";
    if ([options objectForKey:sourceKey])
    {
      if([[options objectForKey:sourceKey] isEqualToString:@"com.servicemaxinc.pushnotification1stAct"])
      {
          //Defect Fix:026723
          if ([[url scheme] containsString:@"svmxmobilepulse"])
          {
              NSDictionary *queryStringDictionary = [PushNotificationUtility getDictionaryFromSharedURL:url];
              
              BOOL isValidUser = [PushNotificationUtility validateOrg:queryStringDictionary];
              if (isValidUser)
              {
                  [[PushNotificationManager sharedInstance] loadNotification:queryStringDictionary];
              }
          }
         
          openURL = YES;
      }
       else
          {
              
              UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Servicemax" message:@"Unauthorized Request" preferredStyle:(UIAlertControllerStyleAlert)];
              
              UIAlertAction *alertAction = [UIAlertAction actionWithTitle:[[TagManager sharedInstance] tagByName:kTagAlertErrorOk] style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
              }];
              
              [alertController addAction:alertAction];
              UIViewController *controller = self.window.rootViewController;
              if(controller.presentedViewController != nil)
              {
                  controller = controller.presentedViewController;

              }
              [controller presentViewController:alertController animated:YES completion:^{}];
          }
      
    }
  
    return openURL;
}

// IPAD-4585
void uncaughtExceptionHandler(NSException *exception)
{
    [[SyncManager sharedInstance] setEndTimeForSyncProfiling];
}

@end

