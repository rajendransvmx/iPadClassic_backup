//
//  OAuthLoginViewController.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 4/3/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   OAuthLoginViewController.h
 *  @class  OAuthLoginViewController
 *
 *  @brief  Load OAuth authentication page.
 *
 *
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <Foundation/Foundation.h>

@interface OAuthLoginViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate, UIAlertViewDelegate>


/**
 * @name  makeUserAuthorizationRequest
 *
 * @author Vipindas Palli
 *
 * @brief Make OAuth authorization request.
 *
 * \par
 *  <Longer description starts here>
 *
 * @return void
 *
 */

- (void)makeUserAuthorizationRequest;

/**
 * @name  reloadAuthorization
 *
 * @author Vipindas Palli
 *
 * @brief Reload OAuth authentication page
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return void
 *
 */

- (void)reloadAuthorization;

@end


@interface OAuthLoginViewController (UIWebViewIntegration) <UIWebViewDelegate>

- (void)authorizeUsingWebView:(UIWebView *)webView;
- (void)authorizeUsingWebView:(UIWebView *)webView additionalParameters:(NSDictionary *)additionalParameters;

@end


@protocol OAuth2ClientDelegate <UIWebViewDelegate>

@required
- (void)oauthClientDidReceiveAccessToken:(OAuthLoginViewController *)client;
- (void)oauthClientDidRefreshAccessToken:(OAuthLoginViewController *)client;

@optional
- (void)oauthClientDidReceiveAccessCode:(OAuthLoginViewController *)client;
- (void)oauthClientDidCancel:(OAuthLoginViewController *)client;

@end

