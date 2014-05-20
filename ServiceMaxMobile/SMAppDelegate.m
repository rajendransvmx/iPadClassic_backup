//
//  SMAppDelegate.m
//  ServiceMaxMobile
//
//  Created by AnilKumar on 3/21/14.
//  Copyright (c) 2013 ServiceMax. All rights reserved.
//
#import "SMAppDelegate.h"
#import <SystemConfiguration/SystemConfiguration.h>

#import "SMDataPurgeManager.h"
#import "SMAttachmentRequestManager.h"

#import "CustomerOrgInfo.h"
#import "StringUtil.h"
#import "AlertMessageHandler.h"
#import "ViewControllerFactory.h"
#import "PlistManager.h"

#import "AppManager.h"
#import "OAuthLoginViewController.h"



@implementation SMAppDelegate

@synthesize _OAuthController;
@synthesize oauthClient;
@synthesize window;
@synthesize isUserOnAuthenticationPage;
@synthesize refresh_token;
@synthesize userOrg;
@synthesize language;
@synthesize apiURl;
@synthesize currentServerUrl;
@synthesize current_userId;
@synthesize organization_Id;
@synthesize currentUserName;
@synthesize loggedInUserId;
@synthesize session_Id;
@synthesize username;
@synthesize userDisplayFullName;
@synthesize loggedInOrg;

@synthesize didLoginAgain;

@synthesize homeScreenView;
@synthesize IsSSL_error;
@synthesize IsLogedIn;
@synthesize isForeGround;
@synthesize isBackground;
@synthesize connection_error;
@synthesize _continueFalg;
@synthesize errorDescription;
@synthesize logoutFlag;
@synthesize password, savedReference, kRestoreLocationKey;

@synthesize controller;
@synthesize appManager;


SMAppDelegate *smappDelegate;

/**
 * @name   doPostLoggedInUserVerification
 *
 * @author Vipindas Palli
 *
 * @brief  This will do verification for logged in user like whether same user, new user or different user.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return Description of the return value
 *
 */

- (void)doPostLoggedInUserVerification
{
    NSString *previousUserName = [[CustomerOrgInfo sharedInstance] previousUserName];
    NSString *previousOrg      = [[CustomerOrgInfo sharedInstance] previousOrg];
    
    NSString *loggedInUserName = [[CustomerOrgInfo sharedInstance] userName];
    NSString *currentOrg       = [[CustomerOrgInfo sharedInstance] userPreferenceHost];
    
    if ([StringUtil isStringEmpty:previousUserName])
    {
        [[AppManager sharedInstance] setLoggedInUserStatus:UserStatusFirstTimeLoggedIn];
        [[AppManager sharedInstance] setApplicationStatus:ApplicationStatusInitialSyncYetToStart];
        
        [[CustomerOrgInfo sharedInstance] setUserLoggedInHost:currentOrg];
        
        /** Store current username and org as previous username and org respectively */
        [PlistManager storePreviousUserName:loggedInUserName];
        [PlistManager storeUserPreferedLastPlatformName:currentOrg];

        [self loadHomeScreen];
    }
    else
    {
        if (   ([loggedInUserName isEqualToString:previousUserName])
            && ([currentOrg isEqualToString:previousOrg]))
        {
            /** Same user logged in  */
            [[AppManager sharedInstance] setLoggedInUserStatus:UserStatusSameUserLoggedIn];
            [[CustomerOrgInfo sharedInstance] setUserLoggedInHost:currentOrg];
            
            [self loadHomeScreen];
        }
        else
        {
            [[AppManager sharedInstance] setLoggedInUserStatus:UserStatusDifferentUserLoggedIn];
            [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeSwitchUser andDelegate:self
             ];
        }
    }
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
    self.controller = [ViewControllerFactory createViewControllerByContext:ViewControllerHomeScreen];
    window.backgroundColor = [UIColor whiteColor];
    [window setRootViewController:controller];
    [window makeKeyAndVisible];
}

/**
 * @name  loadAuthenticationPage
 *
 * @author Vipindas Palli
 *
 * @brief Load or reload authentication page
 *
 * \par
 *
 *
 * @return Void
 *
 */

- (void)loadAuthenticationPage
{
    if (! [self.controller isKindOfClass:[OAuthLoginViewController class]])
    {
        /** Woooh! have to load authentication page here */
        self.controller = [ViewControllerFactory createViewControllerByContext:ViewControllerLogin];
        [window setRootViewController:controller];
        [window makeKeyAndVisible];
        window.backgroundColor = [UIColor whiteColor];
        [controller makeUserAuthorizationRequest];
    }
    else
    {
        /** Woooh! we have to reload authentication page */
        [controller reloadAuthorization];
    }
}

- (void)testLogin
{
    AppManager *_appManager = [AppManager sharedInstance];
    [_appManager initializeApplication];
    self.appManager = _appManager;

    if ([appManager applicationStatus] == ApplicationStatusInitialSyncCompleted)
    {
        /** Completed Initial Sync - Lets go to home screen  */
        [self loadHomeScreen];
    }
    else if ([appManager applicationStatus] == ApplicationStatusInAuthenticationPage)
    {
        /** Yet to complete user Authentication - Go to Login page  */
        
        [self loadAuthenticationPage];
    }
    else if ([appManager applicationStatus] == ApplicationStatusInitialSyncYetToStart)
    {
      /** Not completed Initial Sync - Lets go to home screen and load sync screen */
      
      [self loadHomeScreen];
       
      /**<---- Load Sync screen here ---->*/
    }
    else if ([appManager applicationStatus] == ApplicationStatusTokenRevoked)
    {
        /** Not completed Initial Sync - Lets go to home screen and show token revoked message */
        
        [self loadHomeScreen];
        
        /**<---- Load Sync screen here ---->*/
    }
    else
    {
        /** I am clueless what to do... Help me......*/
    }
}

#pragma mark - Application Life Cycle Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 {
     /***  Will remove  this  part  --- vipindas  21 March 2014 */
     self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
     // Override point for customization after application launch.
     self.window.backgroundColor = [UIColor whiteColor];
     [self.window makeKeyAndVisible];
     smappDelegate = self;
     
     [self testLogin];
     
     return YES;
     
   /***  Will remove  this  part  --- vipindas  21 March 2014 */
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
   self.window.backgroundColor = [UIColor whiteColor];
   [self.window makeKeyAndVisible];
    smappDelegate = self;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
     
    self.isUserOnAuthenticationPage = FALSE;
    //self.refreshHomeIcons = NO;
    
   oauthClient = [[OAuthClientInterface alloc] initWithFrame:window.frame];
    _OAuthController = [[OAuthController alloc] init];
    
   [window setRootViewController:_OAuthController];
   [window makeKeyAndVisible];
   
   
   //Auto Login incase user has already authorized.
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
	NSString *accessToken  = [userDefaults valueForKey:ACCESS_TOKEN];
	NSString *refreshToken = [SFHFKeychainUtils getValueForIdentifier:KEYCHAIN_SERVICE];
	NSString *preference   = [userDefaults valueForKey:@"preference_identifier"];
   [userDefaults setObject:nil forKey:@"checkSessionTimeStamp"];
	userOrg = [userDefaults valueForKey:USER_ORG]; //Read the user org here to check for correct org :
	
//	NSMutableDictionary * temp_dict = [self.wsInterface getDefaultTags];
	//self.wsInterface.tagsDictionary = temp_dict;
   /* iOS7_Support Kirti */
   window.backgroundColor=[UIColor whiteColor];
    
	//Auto Login
	if ( accessToken != nil )
	{
	    NSString *local_Id = [userDefaults valueForKey:LOCAL_ID];
		NSString *userName = [appDelegate.dataBase getUserNameFromUserTable:local_Id];
		
		
		NSLog(@"User Full Name %@", [userDefaults valueForKey:@"UserFullName"]);
		
		if ( userName == nil || [userName isEqualToString:@""])
		{
			userName = [userDefaults valueForKey:_USERNAME];
			[userDefaults setValue:userName forKey:@"UserFullName"];
           
		}
        
		//Initializing the varibales for Auto Login:
		self.language         = [userDefaults valueForKey:@"UserLanguage"];
		self.apiURl           = [userDefaults valueForKey:API_URL];
		self.currentServerUrl = [userDefaults valueForKey:SERVERURL];
		self.current_userId   = [userDefaults valueForKey:CURRENT_USER_ID];
		self.organization_Id  = [userDefaults valueForKey:ORGANIZATION_ID];
		self.currentUserName  = [userDefaults valueForKey:@"UserFullName"];
		self.loggedInUserId   = [userDefaults valueForKey:CURRENT_USER_ID];
		self.refresh_token    = refreshToken;
		self.session_Id       = accessToken;
		self.username         = [userDefaults valueForKey:@"UserFullName"];
		self.userDisplayFullName = [userDefaults valueForKey:USERFULLNAME];
       
       //  : Getting user display name
		
		//Re-write the users org incase he has changed it accidently :
		if ( ![userOrg isEqualToString:preference] )
		{
			[userDefaults setValue:userOrg forKey:@"preference_identifier"];
		}
		BOOL retVal = [appDelegate.calDataBase isUsernameValid:userName];
       
       if ( retVal == FALSE )
		{
           // Close and reopen the main database - since existing data is valid for current user or corrupted
           // Vipind-db-optmz - 3
           //[appDelegate.dataBase closeDatabase:appDelegate.db];
           // [appDelegate releaseMainDatabase];
           
			//[appDelegate.dataBase deleteDatabase:DATABASENAME1];
           
     /*     if(db == NULL)
            {
                [appDelegate initWithDBName:DATABASENAME1 type:DATABASETYPE1];
            }
   
			[self removeSyncHistoryPlist];
			[self updateSyncFailedFlag:SFALSE];
   
			self.do_meta_data_sync = ALLOW_META_AND_DATA_SYNC;
			
			[window setRootViewController:_OAuthController];
			[window makeKeyAndVisible];
			
			self.wasPerformInitialSycn = TRUE;
			
			[self addBackgroundImageAndLogo];
			[self performSelectorInBackground:@selector(performInitialSynchronization) withObject:nil];
			
			return TRUE;
   
		}
   
		else
		{
			self.IsLogedIn = ISLOGEDIN_TRUE;
			
			ZKServerSwitchboard *switchBoard = [ZKServerSwitchboard switchboard];
			switchBoard.logXMLInOut =  [appDelegate enableLogs];
			
			homeScreenView = nil;
			//Changed
			self.serviceReportLogo = [[[UIImage alloc] initWithData:[self.dataBase serviceReportLogoInDB]]autorelease];
			
			if ( homeScreenView == nil )
			{
				[window setRootViewController:_OAuthController];
				[window makeKeyAndVisible];
			
				homeScreenView = [[iPadScrollerViewController alloc] initWithNibName:@"iPadScrollerViewController" bundle:nil];
				homeScreenView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
				homeScreenView.modalPresentationStyle = UIModalPresentationFullScreen;
				[_OAuthController presentViewController:homeScreenView animated:YES completion:nil];
      return TRUE;
      }*/
      
      }
      
      return TRUE;
      }
      
      [oauthClient updateWithClientID:CLIENT_ID secret:CLIENT_SECRET redirectURL:REDIRECT_URL];
  //   [self performAuthorization];
      
      return YES;
 }
 

- (void)applicationWillResignActive:(UIApplication *)application
{

}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[AppManager  sharedInstance]verifyPlatformPreferenceChanges];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

#pragma mark - Show screen

-(void)showScreen
{
	//[self addBackgroundImageAndLogo];
	[_OAuthController.view addSubview:oauthClient.webview];
	[window setRootViewController:_OAuthController];
	[window makeKeyAndVisible];
	
}

-(void)showSalesforcePage
{
	//Revoke the Tokens in Case user decides to cancel switching to a new user OR Incase user denies Access.
	[oauthClient deleteAllCookies];
	if ( smappDelegate.refresh_token )
	{
		[smappDelegate.oauthClient revokeExistingToken:smappDelegate.refresh_token];
	}
	
	[self.oauthClient.webview removeFromSuperview];
	//[self addBackgroundImageAndLogo];
	[self.oauthClient updateWithClientID:CLIENT_ID secret:CLIENT_SECRET redirectURL:REDIRECT_URL];
	[self.oauthClient userAuthorizationRequestWithParameters:nil];
	
	[self._OAuthController.view addSubview:self.oauthClient.webview];
}


-(void)didLoginWithOAuth
{
	NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
	
	[userDefaults setObject:self.currentServerUrl forKey:SERVERURL];
	[userDefaults setObject:self.currentUserName forKey:@"UserFullName"];
	[userDefaults setObject:self.currentUserName forKey:_USERNAME];
    [userDefaults setObject:self.language forKey:@"UserLanguage"];
	[userDefaults setObject:self.session_Id forKey:ACCESS_TOKEN];
	[userDefaults setObject:self.current_userId forKey:CURRENT_USER_ID];
	[userDefaults setObject:self.organization_Id forKey:ORGANIZATION_ID];
	[userDefaults setObject:self.apiURl forKey:API_URL];
	[userDefaults setObject:self.userOrg forKey:USER_ORG];
	[userDefaults setObject:self.userDisplayFullName forKey:USERFULLNAME];
    [userDefaults synchronize];
	
	[SFHFKeychainUtils deleteKeychainValue:KEYCHAIN_SERVICE];
	[SFHFKeychainUtils createKeychainValue:self.refresh_token forIdentifier:KEYCHAIN_SERVICE];
	
	self.refresh_token = [SFHFKeychainUtils getValueForIdentifier:KEYCHAIN_SERVICE];
	NSLog(@"Refresh Token : %@", self.refresh_token);
	
    self.didLoginAgain = TRUE;
	
	[self.oauthClient.webview removeFromSuperview];
	[self.oauthClient.webview release];
	self.oauthClient.webview = nil;
	
	[self performInitialLogin];
}
    

-(void)performInitialLogin
{
	if ( homeScreenView )
	{
		homeScreenView = nil;
	}
	
	self.IsSSL_error = FALSE;
	self.IsLogedIn = ISLOGEDIN_TRUE;
	
  //  self.wsInterface.didOpComplete = FALSE;
	
	self.connection_error = FALSE; //CHANGED FOR DEFECT #5786 --> 29/JAN/2013
	
    if (self.isBackground == TRUE)
        self.isBackground = FALSE;
    
    if (self.isForeGround == TRUE)
        self.isForeGround = FALSE;
    
  //  self.last_initial_data_sync_time = nil;
	
	
	_continueFalg = TRUE;
	
  //  [self checkSwitchUser];
}


// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    // TODO :-vipindas  We have to handle switch user efficiently -
    /***
        - Remove data base 
        - Remove old user data-files attachment
        - Clean the tags from cache
     */
    
    if (buttonIndex == 0)
    {
        NSLog(@" Index 0 - pressed Yes - going to home screen ");
        
        NSString *loggedInUserName = [[CustomerOrgInfo sharedInstance] userName];
        NSString *currentOrg       = [[CustomerOrgInfo sharedInstance] userPreferenceHost];
        
        [[CustomerOrgInfo sharedInstance] setUserLoggedInHost:currentOrg];
        
        /** Store current username and org as previous username and org respectively */
        [PlistManager storePreviousUserName:loggedInUserName];
        [PlistManager storeUserPreferedLastPlatformName:currentOrg];
        
        [self loadHomeScreen];
    }
    else
    {
        NSLog(@" Index 1 - pressed Cancel - going to Authentication");
        [self loadAuthenticationPage];
    }
}


@end

