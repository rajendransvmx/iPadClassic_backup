//
//  AppManager.m
//  ServiceMaxMobile
//
//  Created by AnilKumar on 3/21/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "AppManager.h"
#import "SNetworkReachabilityManager.h"
#import "PlistManager.h"
#import "FileManager.h"
#import "TagManager.h"
#import "AppMetaData.h"
#import "CustomerOrgInfo.h"
#import "StringUtil.h"
#import "SMAppDelegate.h"
#import "OAuthService.h"
#import "AlertMessageHandler.h"
#import "ViewControllerFactory.h"
#import "OAuthLoginViewController.h"
#import "DatabaseConfigurationManager.h"
#import "CacheManager.h"
#import "LocationPingManager.h"

@interface AppManager ()
{
    UserStatus          userStatus;
    ApplicationStatus   applicationStatus;
    ApplicationStatus   applicationFailedStatus;
    NSString            *errorMessage;
}

- (void)serializeDatabaseConnection;

- (void)verifyUserAndApplicationStatus;

@end


@implementation AppManager

/**
 * @name   sharedInstance
 *
 * @author Vipindas Palli
 *
 * @brief  Shared instance of the application manager.
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Shared Object of application manager class.
 *
 */


#pragma mark Singleton Methods

+ (instancetype) sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initInstance];
    });
    return sharedInstance;
}

- (instancetype) initInstance {
    self = [super init];
    // Do any other initialisation stuff here
    // ...
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

#pragma mark - Manage status

/**
 * @name   verifyUserAndApplicationStatus
 * @author Vipindas
 *
 * @brief  verification of user status
 *
 * \par
 *  Check user status and application status
 *
 *
 * @return void
 */

- (void)verifyUserAndApplicationStatus
{
    NSString *storedUserName = [[CustomerOrgInfo sharedInstance] userName];
    
    /** User status verification  */
    if ([StringUtil isStringEmpty:storedUserName])
    {
        [self setLoggedInUserStatus:UserStatusLoggedOut];
    }
    else
    {
        UserStatus status =  (UserStatus) [PlistManager getStoredUserStatus];
        [self setLoggedInUserStatus:status];
    }
    
    /** Application status verification */
    
    if (userStatus ==  UserStatusLoggedOut)
    {
        // User logout from application - Lets start with login page
        //[self setApplicationStatus:ApplicationStatusInAuthenticationPage];
        
        [self setApplicationStatus:ApplicationStatusInLaunchScreen];
    }
    else
    {
        [self setApplicationStatus:[PlistManager getStoredApplicationStatus]];
        
        switch (applicationStatus)
        {
            case ApplicationStatusInAuthorizationPage:
            case ApplicationStatusFailedWithUnknownError:
            {
                [self setApplicationStatus:ApplicationStatusInLaunchScreen];
            }
            break;
                
            case ApplicationStatusInAuthorizationVerification:
            case ApplicationStatusAuthorizationFailedWithError:
            {
                [self setApplicationStatus:ApplicationStatusInLaunchScreen];
            }
            break;
                
            case ApplicationStatusInitialSyncInProgress:
            case ApplicationStatusInAuthorizationVerificationCompleted:
            case ApplicationStatusInitialSyncFailed:
            {
                [self setApplicationStatus:ApplicationStatusInitialSyncYetToStart];
            }
            break;
                
            /** Reset of the state we are assuming that stable and help in application launching */
                
            default:
                break;
        }
    }
}


#pragma mark - Initialize application

/**
 * @name  initializeApplication
 *
 * @author Vipindas Palli
 *
 * @brief Initialize application with configuration values
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Void
 *
 */

- (void)initializeApplication
{
    NSLog(@" initializeApplication ");
    // Lets do network call initialization
    [[SNetworkReachabilityManager sharedInstance] reachabilityStatus];
    
    // Seriliazing database connection
    [self serializeDatabaseConnection];
    
    // Check whether application dictionary exist if not create it and remove iCloud back-up feature.
    [FileManager createApplicationDirectory];
    
    // Register application settings value to User default settings
    [PlistManager registerDefaultAppSettings];
    
    // Move/Install JavaScript Files
    [FileManager installJavascriptFiles];
    
    // Load tags to memory - this helps localization/internationalization of the application
    [[TagManager sharedInstance] loadTags];
    
    // Load Application metadata like OSversion, appVersion, device model, type, etc...
    [AppMetaData sharedInstance];
    
    // Load Existing customer org info
    [PlistManager loadCustomerOrgInfo];
    
    [self verifyUserAndApplicationStatus];
}


#pragma mark - User status management

/**
 * @name  loggedInUserStatus
 *
 * @author Vipindas Palli
 *
 * @brief User logged in status
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return UserStatus - enum type
 *
 */

- (UserStatus)loggedInUserStatus
{
    return userStatus;
}

/**
 * @name  setLoggedInUserStatus
 *
 * @author Vipindas Palli
 *
 * @brief Set user status
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param status - new user status
 *
 * @return void
 *
 */

- (void)setLoggedInUserStatus:(UserStatus)status
{
    NSLog(@" user status  %d", status);
    
    if (   (userStatus != status)
        && (status == UserStatusInactiveUser))
    {
        [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeInactiveUser];
    }

    userStatus = status;
    [PlistManager storeUserStatus:status];
}


#pragma mark - Application status management

/**
 * @name  applicationStatus
 *
 * @author Vipindas Palli
 *
 * @brief Application current status
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return ApplicationStatus application current status returned
 *
 */

- (ApplicationStatus)applicationStatus
{
    return applicationStatus;
}

/**
 * @name  setApplicationStatus:
 *
 * @author Vipindas Palli
 *
 * @brief Set application current status
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param status - new application status
 *
 * @return void
 *
 */

- (void)setApplicationStatus:(ApplicationStatus)status
{
    NSLog(@" app status  %d", status);
    
    if (   (applicationStatus != status)
        && ( (status == ApplicationStatusAccessTokenExpired) || (status == ApplicationStatusTokenRevoked)))
    {
        [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeAccessTokenExpired];
    }
    
    if (status == ApplicationStatusInitialSyncFailed)
    {
        [self setApplicationFailedStatus:ApplicationStatusInitialSyncFailed];
    }
    
    applicationStatus = status;
    [PlistManager storeApplicationStatus:status];
}

#pragma mark - Application status management
         
/**
 * @name  applicationFailedStatus
 *
 * @author Vipindas Palli
 *
 * @brief Application current status
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return ApplicationStatus application failed status returned
 *
 */
 
 - (ApplicationStatus)applicationFailedStatus
{
    return applicationFailedStatus;
}
 
/**
 * @name  setApplicationFailedStatus:
 *
 * @author Vipindas Palli
 *
 * @brief Set application current status
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param status - new application status
 *
 * @return void
 *
 */
 
 - (void)setApplicationFailedStatus:(ApplicationStatus)status
{
    NSLog(@" app failed status  %d", status);
    
    applicationFailedStatus = status;
    
    [PlistManager storeApplicationFailedStatus:status];
}

         
#pragma mark - Permission verifications

/**
 * @name  isWebServicePermitted
 *
 * @author Vipindas Palli
 *
 * @brief Has permission to make web service call.
 *
 * \par
 *  If access token permitted or network is not reachable will return NO. Otherwise YES.
 *
 *
 * @return BOOL value
 *
 */

- (BOOL)isWebServicePermitted
{
    // Web services permitted only if Network Connection and non-revoked token is available.
    return  ( (![self hasTokenRevoked])
             && ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable]));
}

/**
 * @name  isWebServicePermitted
 *
 * @author Vipindas Palli
 *
 * @brief Has Access Token revoked.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return BOOL value
 *
 */

- (BOOL)hasTokenRevoked
{
    return (applicationStatus == ApplicationStatusTokenRevoked);
}


#pragma mark - Error Message management
/**
 * @name setErrorMessage
 *
 * @author Vipindas Palli
 *
 * @brief record last error message
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param  anErrorMessage Error message description
 *
 * @return void
 *
 */
- (void)setErrorMessage:(NSString *)anErrorMessage
{
    errorMessage = anErrorMessage;
}

/**
 * @name  lastErrorMessage
 *
 * @author Vipindas Palli
 *
 * @brief Last report error message
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return last reported error message
 *
 */

- (NSString *)lastErrorMessage
{
    return errorMessage;
}

#pragma mark - Login process completed

/**
 * @name   completedLoginProcessWithStatus
 *
 * @author Vipindas Palli
 *
 * @brief  Validate on completion of login process
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param  status ApplicationStatus value
 *
 * @return void
 *
 */

- (void)completedLoginProcessWithStatus:(ApplicationStatus)status
{
    NSLog(@"completedLoginProcessWithStatus --- ");
   
    [self setApplicationStatus:status];
    
   if (status == ApplicationStatusInAuthorizationVerificationCompleted)
   {
       // Verify user status
       [self doPostLoggedInUserVerification];
   }
   else if (status == ApplicationStatusAuthorizationFailedWithError)
   {
       [self setApplicationStatus:ApplicationStatusInAuthenticationPage];
       [self loadScreen];
   }
}


#pragma mark - Logout process completed

/**
 * @name   completedLogoutProcess
 *
 * @author Vipindas Palli
 *
 * @brief  Call on completion of logout process
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return void
 *
 */

- (void)completedLogoutProcess
{
    [self setLoggedInUserStatus:UserStatusLoggedOut];
    
    /*** Lets delete all sales force coockies */
    [OAuthService deleteSalesForceCookies];
    
    //[OAuthService ];
    [self setApplicationStatus:ApplicationStatusInAuthenticationPage];
    
    [self loadScreen];
}


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
    
    NSLog(@" LoggedInUserVerification \n\n %@ => %@  [  %@ => %@ ]", previousUserName, loggedInUserName,  previousOrg, currentOrg);
    if ([StringUtil isStringEmpty:previousUserName])
    {
        [[AppManager sharedInstance] setLoggedInUserStatus:UserStatusFirstTimeLoggedIn];
        [[AppManager sharedInstance] setApplicationStatus:ApplicationStatusInitialSyncYetToStart];
        
        [[CustomerOrgInfo sharedInstance] setUserLoggedInHost:currentOrg];
        
        /** Store current username and org as previous username and org respectively */
        [PlistManager storePreviousUserName:loggedInUserName];
        [PlistManager storeUserPreferedLastPlatformName:currentOrg];
        
        [self loadScreen];
    }
    else
    {
        if (   ([loggedInUserName isEqualToString:previousUserName])
            && ([currentOrg isEqualToString:previousOrg]))
        {
            /** Same user logged in  */
            [[AppManager sharedInstance] setLoggedInUserStatus:UserStatusSameUserLoggedIn];
            [[CustomerOrgInfo sharedInstance] setUserLoggedInHost:currentOrg];
            
            [[AppManager sharedInstance] setApplicationFailedStatus:[PlistManager getStoredApplicationFailedStatus]];
            
            if ([[AppManager sharedInstance] applicationFailedStatus] == ApplicationStatusInitialSyncFailed)
            {
                // Woo there is sync failure. Lets start from Initial Sync
                [[AppManager sharedInstance] setApplicationStatus:ApplicationStatusInitialSyncYetToStart];
                [[AppManager sharedInstance] setApplicationFailedStatus:ApplicationStatusUnknown];
            }
            else
            {
                [[AppManager sharedInstance] setApplicationStatus:ApplicationStatusInitialSyncCompleted];
            }

            [self loadScreen];
        }
        else
        {
            [[AppManager sharedInstance] setLoggedInUserStatus:UserStatusDifferentUserLoggedIn];
            [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeSwitchUser andDelegate:self
             ];
        }
    }
}



#pragma mark - Database Serilization

/**
 * @name   serializeDatabaseConnection
 *
 * @author Vipindas Palli
 *
 * @brief  Configuring SQLite database
 *
 * \par
 *  Configuring SQLite database for serialising database connection.
 *  This will be one time configuration at the time of application launch,
 *  on successful of this, multiple thread can use same database connection.
 *
 * @return void
 *
 */

- (void)serializeDatabaseConnection
{
    NSLog(@"  serializeDatabaseConnection ");
    int configResult = sqlite3_config(SQLITE_CONFIG_SERIALIZED);
    if (configResult == SQLITE_OK)
    {
        NSLog(@"[OPMX] - 1 Use sqlite on multiple threads, using the same connection");
    }
    else
    {
        NSLog(@"[OPMX] - 1 Single connection single thread - configResult : %d", configResult);
    }
}

/**
 * @name   verifyPlatformPreferenceChanges
 *
 * @author Vipindas Palli
 *
 * @brief  Verify user platfrom preference changes and make action accordingly
 *
 * \par
 *      If user already logged in or login process in progress, the settings changes for platform perefernce
 *   become invalid and revert back to login status preference value. Other than this, if user is logged out or in authentication page or preference with custom url application will reload the authentication web page
 *
 *
 * @return void
 *
 */

- (void)verifyPlatformPreferenceChanges
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString * currentPreference = [userDefaults valueForKey:kPreferenceIdentifier];
    
    if ( (applicationStatus == ApplicationStatusInAuthenticationPage) || (userStatus == UserStatusLoggedOut))
    {
        if ( (! [[[CustomerOrgInfo sharedInstance] userLoggedInHost] isEqualToString:currentPreference])
            || ([[[CustomerOrgInfo sharedInstance] userLoggedInHost] isEqualToString:kPreferenceOrganizationCustom])
            || (applicationStatus == ApplicationStatusInAuthenticationPage))
        {
            /**
             * User status is loggedout or in authentication page.
             * User preference host has been changed
             * Reload authentication page - Since there is change in host preference or custom url
             */
            
            //[self setApplicationStatus:ApplicationStatusInAuthenticationPage];
            [self setApplicationStatus:ApplicationStatusInLaunchScreen];
            [self loadScreen];
             //SMAppDelegate *appDelegate =  (SMAppDelegate *) [[UIApplication sharedApplication] delegate];
            //[appDelegate loadAuthenticationPage];
        }
    }
    else
    {
        /**
         * State of user is either logged-in or in progress.
         * User preference host has been changed, we have to revert back the user preference to actual/older one.
         * Since the login process is going on or already logged in
         */
        
		if (! [[[CustomerOrgInfo sharedInstance] userLoggedInHost] isEqualToString:currentPreference])
		{
			//Rewrite the user's actual org to settings :
			[userDefaults setValue:[[CustomerOrgInfo sharedInstance] userLoggedInHost] forKey:kPreferenceIdentifier];
		}
    }
}

+ (NSString *)generateUniqueId
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    
    // Mem_leak_fix - Vipindas 9493 Jan 18
    // return ( NSString *)string;
    return CFBridgingRelease(string);
}



/**
 * @name  loadInitialSyncScreen
 *
 * @author Damodar
 *
 * @brief Load Initial sync screen view
 *
 * \par
 *  <Longer description starts here>
 *
 *
 *
 * @return void
 *
 */

- (void)loadInitialSyncScreen
{
    id controller = [ViewControllerFactory createViewControllerByContext:ViewControllerInitialSync];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [[self applicationDelegate] loadWithController:navController];
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
    [[LocationPingManager sharedInstance] stopLocationPing];
    [[LocationPingManager sharedInstance] startLocationPing];
    [[self applicationDelegate] loadWithController:[ViewControllerFactory createViewControllerByContext:ViewControllerCustomTabBar]];
}

/**
 * @name  loadLaunchScreen
 *
 * @author Vipindas Palli
 *
 * @brief Load application Launch screen view
 *
 * \par
 *  <Longer description starts here>
 *
 *
 *
 * @return void
 *
 */

- (void)loadLaunchScreen
{
    [[self applicationDelegate] loadWithController:[ViewControllerFactory createViewControllerByContext:ViewControllerLaunchScreen]];
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
    id controller = [ViewControllerFactory createViewControllerByContext:ViewControllerLogin];
    [[self applicationDelegate] loadWithController:nil];
    [[self applicationDelegate] loadWithController:controller];

    if ([controller isKindOfClass:[OAuthLoginViewController class]])
    {
        [(OAuthLoginViewController *)controller  makeUserAuthorizationRequest];
    }
}


- (SMAppDelegate *)applicationDelegate
{
    return (SMAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)loadScreen
{
    if (self.applicationStatus == ApplicationStatusInitialSyncCompleted)
    {
        /** Completed Initial Sync - Lets go to home screen  */
        [self loadHomeScreen];
    }
    else if (self.applicationStatus == ApplicationStatusInAuthenticationPage)
    {
        if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
        {
            /** Yet to complete user Authentication - Go to Login page  */
            [self loadAuthenticationPage];
        }
        else
        {
             /**<---- Network not reachable, lets go to launch Screen ---->*/
             self.applicationStatus = ApplicationStatusInLaunchScreen;
             [self loadLaunchScreen];
        }
    }
    else if ( self.applicationStatus == ApplicationStatusInitialSyncYetToStart)
    {
        /** Not completed Initial Sync - Lets go to home screen and load sync screen */
      
        [self loadInitialSyncScreen];
        
        /**<---- Load Sync screen here ---->*/
    }
    else if (self.applicationStatus == ApplicationStatusTokenRevoked)
    {
        /** Not completed Initial Sync - Lets go to home screen and show token revoked message */
        
        [self loadHomeScreen];
        
        /**<---- Load Sync screen here ---->*/
    }
    else
    {
        [self loadLaunchScreen];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( [alertView isKindOfClass:[UIAlertView class]])
	{
        // Opted for user switching...
		if ( buttonIndex == 0 )
		{
            NSString *loggedInUserName = [[CustomerOrgInfo sharedInstance] userName];
            NSString *currentOrg       = [[CustomerOrgInfo sharedInstance] userPreferenceHost];
            
            [[CustomerOrgInfo sharedInstance] setUserLoggedInHost:currentOrg];
            
            /** Store current username and org as previous username and org respectively */
            [PlistManager storePreviousUserName:loggedInUserName];
            [PlistManager storeUserPreferedLastPlatformName:currentOrg];
            
            [self resetApplicationContentsForNewUser];
        }
        else
        {
            [self setLoggedInUserStatus:UserStatusLoggedOut];
            [self setApplicationStatus:ApplicationStatusInAuthenticationPage];
            [self loadScreen];
        }
    }
}

- (void)resetApplicationContents
{
    /*
     1. Reset application Database --- Done
     1.1 Reset Tags ---- Done
     1.2 Reset Cache --  In Logout
     2. Remove downloaded Attachment
     3. Clear document directory
     4. Move Javascript files
     5. Remove sync history
     */
    
    [[TagManager sharedInstance] loadTags];
    [[DatabaseConfigurationManager sharedInstance] performDatabaseConfigurationForSwitchUser];
}

- (void)resetApplicationContentsForNewUser
{
    [self resetApplicationContents];
    [self setApplicationStatus:ApplicationStatusInitialSyncYetToStart];
    [self loadScreen];
}

@end






