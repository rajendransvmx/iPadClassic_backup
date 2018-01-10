//
//  SMKeychain.h
//  ServiceMaxiPad
//
//  Created by Pushpak on 23/01/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMKeychain : NSObject
+ (instancetype)sharedKeychain;
- (NSString *)readRefreshTokenFromKeychainWithClientId:(NSString *)clientId;
- (void)saveRefreshTokenInKeychain:(NSString *)refreshToken forClientId:(NSString *)clientId;
- (void)removeRefreshTokenFromKeychainWithClientId:(NSString *)clientId;

/**
 * @name  getRefreshToken
 *
 * @author Vipindas Palli
 *
 * @brief Get refresh token from key chain store
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return refreshToken
 *
 */

+ (NSString*)getRefreshToken;

/**
 * @name  storeRefreshToken:
 *
 * @author Vipindas Palli
 *
 * @brief Store new refresh token value in key chain store
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param  refreshToken new refresh token
 *
 * @return bool value
 *
 */

+ (void)storeRefreshToken:(NSString *)refreshToken;

/**
 * @name  deleteRefreshToken
 *
 * @author Vipindas Palli
 *
 * @brief delete existing refresh token value in key chain store
 *
 * \par
 *  <Longer description starts here>
 *
 *
 *
 * @return bool value
 *
 */

+ (void)deleteRefreshToken;

//access token

+ (NSString*)getAccessToken;
+ (void)storeAccessToken:(NSString *)accessToken;
+ (void)deleteAccessToken;

@end
