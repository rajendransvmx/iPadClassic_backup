//
//  AppManager.m
//  ServiceMaxMobile
//
//  Created by AnilKumar on 3/21/14.
//  Copyright (c) 2013 ServiceMax. All rights reserved.
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


static dispatch_once_t _sharedAppManagerInstanceGuard = 0;
static AppManager *_instance;

@interface AppManager ()
{
    UserStatus          userStatus;
    ApplicationStatus   applicationStatus;
    NSString            *errorMessage;
}

- (void)serializeDatabaseConnection;

- (void)verifyUserAndApplicationStatus;

@end


@implementation AppManager


#pragma mark - Singleton class Implementation

- (id)init
{
    return [AppManager sharedInstance];
}


- (id)initializeAppManager
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

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


+ (AppManager *)sharedInstance
{
    dispatch_once(&_sharedAppManagerInstanceGuard,
                  ^{
                      _instance = [[AppManager alloc] initializeAppManager];
                  });
    return _instance;
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


- (id)retain
{
    return self;
}


- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}


- (oneway void)release
{
    // never release
}


- (id)autorelease
{
    return self;
}


- (void)dealloc
{
    // Should never be called, but just here for clarity really.
    [super dealloc];
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
        [self setApplicationStatus:ApplicationStatusInAuthenticationPage];
    }
    else
    {
        [self setApplicationStatus:[PlistManager getStoredApplicationStatus]];
        
        switch (applicationStatus)
        {
            case ApplicationStatusInAuthorizationPage:
            case ApplicationStatusInAuthorizationVerification:
            case ApplicationStatusAuthorizationFailedWithError:
            case ApplicationStatusFailedWithUnknownError:
            {
                [self setApplicationStatus:ApplicationStatusInAuthenticationPage];
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
    applicationStatus = status;
    [PlistManager storeApplicationStatus:status];
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
   [self setApplicationStatus:status];
    
    SMAppDelegate *appDelegate = (SMAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"completedLoginProcessWithStatus --- ");
    [[CustomerOrgInfo sharedInstance] explainMe];
    
   if (status == ApplicationStatusInAuthorizationVerificationCompleted)
   {
       // Verify user status
       // Go to Appdelegate
       [self setApplicationStatus:status];
       [appDelegate doPostLoggedInUserVerification];
       
   }
   else if (status == ApplicationStatusAuthorizationFailedWithError)
   {
      [appDelegate loadAuthenticationPage];
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
    
    /*** Lets go to Login page */
    SMAppDelegate *appDelegate = (SMAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate loadAuthenticationPage];
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
            
             SMAppDelegate *appDelegate =  (SMAppDelegate *) [[UIApplication sharedApplication] delegate];
            [appDelegate loadAuthenticationPage];
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


@end






