//
//  CustomerOrgInfo.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 4/4/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   CustomerOrgInfo.h
 *  @class  CustomerOrgInfo
 *
 *  @brief  To store and maintain customer and org details
 *
 *
 *  This contains the prototypes for the console
 *  driver and eventually any macros, constants,
 *  or global variables you will need.
 *
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import <Foundation/Foundation.h>


@interface CustomerOrgInfo : NSObject
{
    
}

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *currentUserName;
@property (nonatomic, copy) NSString *userLanguage;
@property (nonatomic, copy) NSString *userOrgId;
@property (nonatomic, copy) NSString *userDisplayName;
@property (nonatomic, copy) NSString *currentUserId;
@property (nonatomic, copy) NSString *loggedUserId;
@property (nonatomic, copy) NSString *profileId;

@property (nonatomic, copy) NSString *previousUserName;     /** Last logged in user name */
@property (nonatomic, copy) NSString *previousOrg;          /** Preference Host name, in which user logged in last time */

@property (nonatomic, copy) NSString *userPreferenceHost;   /** Host name, user can change this from app settings */
@property (nonatomic, copy) NSString *userLoggedInHost;     /** host name, where user successfully logged in */


/**
 * serverVersion
 * Used to validate availability of features in client and server
 * This will recieved as part of SVMX version check web service call.
 *
 */

@property (nonatomic, copy) NSString *serverVersion;

/**
 * refreshToken
 * Used to refresh access token and revoke exisitng access token.
 * This will recieved as part of user authentication service call in OAuth session.
 * Also will recieved in refresh access token web service call.
 *
 *
 * eg:- 5Aep861i3pidIObecE0.CywcjNt80JnmXnx_voOMhOUPBZLz.vnAJMETPuMGPLZaBAr9VNKczXJ6jw_ZXsnZ22v
 */


@property (nonatomic, copy) NSString *refreshToken;

/**
 * accessToken
 * Other names : Session_id / Access_Token / OAuth_Token
 * Used in Webservice calls.
 * This will recieved as part of user authentication service call in OAuth session.
 *
 * Also will recieved in refresh access token web service call.
 *
 * eg:- 00De0000001JIxe!AQcAQE1GpPQLk0IDfkkLyywwmBLq1_ZZeklVP5LwiB3G1BFmgQuBvzUsLBJSRU7VCehEe_6MBdLQO0gZYJeTJ3G.6xcRlDaQ
 */

@property (nonatomic, copy) NSString *accessToken;

/**
 * apiURL
 * Used for ZKS calls.
 * This will obtained as part of user identity verification calls in OAuth session.
 *
 *  eg:- https://cs15.salesforce.com/services/Soap/u/20/00De0000001JIxe
 */

@property (nonatomic, copy) NSString *apiURL;

/**
 * instanceURL
 * Other names : CurrentServer URL / Server URL
 * Used for web service calls.
 * This will obtained as part of user identity verification calls in OAuth session
 *
 *  eg:- https://cs15.salesforce.com
 */

@property (nonatomic, copy) NSString *instanceURL;

/**
 * identityURL
 * Used to get logged in user details.
 * This will be obtained as part of Callback url in OAuth session.
 *
 *  eg:-  https://test.salesforce.com/id/00De0000001JIxeEAG/005e00000013J6EAAU
 */

@property (nonatomic, copy) NSString *identityURL;


+ (CustomerOrgInfo *)sharedInstance;


- (void)reloadOrgInfo;

- (void)explainMe;

@end
