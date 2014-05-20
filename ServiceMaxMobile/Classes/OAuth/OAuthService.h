//
//  OAuthService.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 4/15/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//
/**
 *  @file   OAuthService.h
 *  @class  OAuthService
 *
 *  @brief  OAuth related service implementations
 *
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <Foundation/Foundation.h>

extern NSString *const kRedirectURL;

@interface OAuthService : NSObject


/**
 * @name   revokeAccessToken
 *
 * @author Vipindas Palli
 *
 * @brief  Make Webservice call for revoke access token
 *
 * \par
 *
 * 1. Code 200 - OK
 * 2. Code 401 - The session ID or OAuth token used has expired or is invalid.
 *  The response body contains the message and errorCode.
 * 3. Code 403 - The request has been refused. Verify that the logged-in user has appropriate permissions.
 *
 * Rest of the error code/message will inform user with response error message.
 * More details about error code:
 *   http://www.salesforce.com/us/developer/docs/api_rest/index_Left.htm#CSHID=errorcodes.htm|StartTopic=Content%2Ferrorcodes.htm|SkinName=webhelp
 *
 * @return bool
 *
 */

+ (BOOL)revokeAccessToken;


/**
 * @name   refreshAccessToken
 *
 * @author Vipindas Palli
 *
 * @brief  Make Webservice call to refresh access token
 *
 * \par
 *  <Longer description starts here>
 *
 * @return bool value
 *
 */

+ (BOOL)refreshAccessToken;

/**
 * @name  deleteSalesForceCookies
 *
 * @author Vipindas Palli
 *
 * @brief Delete all salesforce related cookies from cookie storage
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Yes in case of success otherwise No
 *
 */

+ (BOOL)deleteSalesForceCookies;


/**
 * @name   authorizationURLString
 *
 * @author Vipindas Palli
 *
 * @brief  Generate url string for make OAuth authorization service call
 *
 * \par
 *  <Longer description starts here>
 *
 * @return String value
 *
 */

+ (NSString *)authorizationURLString;

+ (void)extractAccessCodeFromCallbackURL:(NSURL *)callbackURL;

@end
