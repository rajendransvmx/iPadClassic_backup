//
//  SMAppDelegate.h
//  ServiceMaxMobile
//
//  Created by AnilKumar on 3/21/14.
//  Copyright (c) 2013 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthController.h"
#import "OAuthClientInterface.h"
#import <SystemConfiguration/SystemConfiguration.h>

#import "iPadScrollerViewController.h"
#import "WSInterface.h"

@class OAuthLoginViewController;
@class AppManager;

@interface SMAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate>
{
    OAuthController *_OAuthController;
    OAuthClientInterface *oauthClient;
    UIWindow *window;
    NSString *refresh_token;
    NSString *userOrg;
    
    NSString *session_Id;
    NSString *apiURl;
    NSString *organization_Id;
    NSString * currentServerUrl;
    NSMutableString * currentUserName, * loggedInOrg;
    NSString *userDisplayFullName;
     NSString * username, * password;
    //iPadScrollerViewController * homeScreenView;
    HomeScreen * homeScreenView;
    
     BOOL IsSSL_error;
    ISLOGEDIN IsLogedIn;
    
    BOOL isBackground;
    BOOL isForeGround;
    
    BOOL connection_error;
    BOOL _continueFalg;
    BOOL logoutFlag;
}


@property (nonatomic, strong)OAuthController *_OAuthController;
@property (nonatomic, strong)OAuthClientInterface *oauthClient;
@property (nonatomic, assign)BOOL isUserOnAuthenticationPage;
@property (nonatomic, strong)NSString *refresh_token;
@property (nonatomic, strong)NSString *userOrg;

@property (nonatomic, assign) NSString *language;
@property (nonatomic, strong)NSString *organization_Id;

@property (nonatomic, strong)NSString *apiURl;
@property (nonatomic, strong)NSString *session_Id;
@property (nonatomic, strong) NSString * current_userId;
@property (nonatomic, strong) NSString * currentServerUrl;
@property (nonatomic, strong) NSMutableString * currentUserName, * loggedInOrg;
@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong)NSString *userDisplayFullName;
@property (nonatomic, strong) NSString * loggedInUserId;
@property (nonatomic, assign) NSString *errorDescription;
@property (nonatomic) BOOL logoutFlag;

@property (nonatomic, strong) OAuthLoginViewController *controller;
@property (nonatomic, strong) AppManager *appManager;

//@property (nonatomic, strong)iPadScrollerViewController * homeScreenView;
@property (nonatomic, strong)HomeScreen * homeScreenView;
@property (nonatomic) BOOL IsSSL_error;
@property (nonatomic) ISLOGEDIN IsLogedIn;

@property (nonatomic) BOOL isBackground;
@property (nonatomic) BOOL isForeGround;
@property (nonatomic) BOOL connection_error;
@property (nonatomic, assign)BOOL _continueFalg;


@property (nonatomic, strong) NSString * password;
@property (nonatomic, strong) NSMutableArray * savedReference;
@property (nonatomic, strong) NSString * kRestoreLocationKey;


@property BOOL didLoginAgain;

@property (nonatomic, strong) IBOutlet UIWindow *window;




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

- (void)loadHomeScreen;

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

- (void)loadAuthenticationPage;

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

- (void)doPostLoggedInUserVerification;

@end
