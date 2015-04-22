//
//  AppManager.h
//  ServiceMaxMobile
//
//  Created by AnilKumar on 3/21/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

/** 
 *  @file  AppManager.h
 *  @brief Manage application level values
 *  @class AppManager
 *
 *  This class manage application level constants and states.
 *
 *  @author AnilKumar
 *  @author Vipindas Palli
 *
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 **/

#import <Foundation/Foundation.h>
#include <sqlite3.h>

/**
 *  User status
 *
 *  Enum represetation of user logged status
 *
 */

typedef enum UserStatus : NSUInteger
{
    UserStatusLoggedOut = -1,
    UserStatusFirstTimeLoggedIn = 1,
    UserStatusSameUserLoggedIn = 2,
    UserStatusDifferentUserLoggedIn = 3,
    UserStatusInactiveUser = 4,
}
UserStatus;


/**
 *  Application status
 *  
 *  Enum represetation of Application status.
 *
 */

typedef enum ApplicationStatus : NSUInteger
{
    ApplicationStatusUnknown = -1,
    ApplicationStatusInLaunchScreen = 0,         /** Application Launch Screen*/
    ApplicationStatusInAuthenticationPage = 1,   /** Login Page, waiting for user input*/
    ApplicationStatusInAuthorizationPage = 2,    /** In Authorization page waiting for user to press "Allow" or "Disallow"  */
    ApplicationStatusInAuthorizationVerification = 3, /** Authorization token verification in progress  */
    ApplicationStatusInAuthorizationVerificationCompleted = 4, /** Authorization token verification process completed  */
    
    ApplicationStatusInitialSyncYetToStart = 21,
    ApplicationStatusInitialSyncInProgress = 22,
    ApplicationStatusInitialSyncCompleted  = 23,
    
    ApplicationStatusFailedWithUnknownError = 100,
    ApplicationStatusAuthorizationFailedWithError = 101,
    ApplicationStatusInitialSyncFailed = 102,
    ApplicationStatusTokenRevoked = 111,
    ApplicationStatusAccessTokenExpired = 112,
}
ApplicationStatus;




@interface AppManager : NSObject <UIAlertViewDelegate>
{
    
}

// ...

 // + (instancetype) sharedInstance;

+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));

// ...

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

+ (instancetype)sharedInstance;

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

- (void)initializeApplication;

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

- (UserStatus)loggedInUserStatus;

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

- (void)setLoggedInUserStatus:(UserStatus)status;

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

- (ApplicationStatus)applicationStatus;

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

- (void)setApplicationStatus:(ApplicationStatus)status;

/**
 * @name  setApplicationStatusTokenExpired:
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

- (void)setApplicationStatusTokenExpired:(ApplicationStatus)status;

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

- (void)setApplicationFailedStatus:(ApplicationStatus)status;

#pragma mark - Permission verifications

/**
 * @name  isWebServicePermitted
 *
 * @author Vipindas Palli
 *
 * @brief Has permission to make web service call.
 *
 * \par
 *  If access token pernitted or network is not reachable will return NO. Otherwise YES.
 *
 *
 * @return BOOL value
 *
 */

- (BOOL)isWebServicePermitted;

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

- (BOOL)hasTokenRevoked;

#pragma mark - Error Message management

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
 * @param  Description of method's or function's input parameter
 *
 * @return last reported error message
 *
 */

- (NSString *)lastErrorMessage;

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
 * @param  Description of method's or function's input parameter
 * @param  ...
 *
 * @return Description of the return value
 *
 */

- (void)setErrorMessage:(NSString *)anErrorMessage;

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

- (void)completedLoginProcessWithStatus:(ApplicationStatus)status;

/**
 * @name   verifyPlatformPreferenceChanges
 *
 * @author Vipindas Palli
 *
 * @brief  Verify user platfrom preference and make action accordingly
 *
 * \par
 *      If user already logged in or login process in progress, the settings changes for platform perefernce
 *   become invalid and revert back to login status preference value. Other than this, if user is logged out or in authentication page or preference with custom url application will reload the authentication web page.
 *     
 *      This will called as and when application come to the foreground mode.
 *
 *
 * @return void
 *
 */


- (void)verifyPlatformPreferenceChanges;

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

- (void)completedLogoutProcess;

/**
 * @name   generateUniqueId
 *
 * @author Sahana
 *
 * @brief To get unique Identifier
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return unique Identifier
 *
 */

+ (NSString *)generateUniqueId;


/**
 * @name   loadScreen
 *
 * @author Vipindas Palli
 *
 * @brief Load the applicatiion base screen by application status
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return void
 *
 */

- (void)loadScreen;

/**
 * @name   resetApplicationContents
 *
 * @author Vipindas Palli
 *
 * @brief Reset Application contents
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return void
 *
 */

- (void)resetApplicationContents;



- (void)loadHomeScreen;

- (NSInteger)currentSelectedTab;

@end
