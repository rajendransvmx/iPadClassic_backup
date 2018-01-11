//
//  SMKeychain.m
//  ServiceMaxiPad
//
//  Created by Pushpak on 23/01/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "SMKeychain.h"
#import <Security/Security.h>

static NSString *ServiceMaxKeyChainIdenitifier = @"ServiceMaxMobile";
static NSString *ServiceMaxKeyChainAccessIdenitifier = @"ServiceMaxMobileAccess";

@implementation SMKeychain

+ (instancetype)sharedKeychain {
    static SMKeychain *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SMKeychain alloc] init];
    });
    return instance;
}

+ (NSDictionary *)keychainQueryWithClientId:(NSString *)clientId {
    if (clientId == nil || clientId.length == 0) {
        NSAssert(NO, @"client id could not be nil");
    }
    NSData *encodedIdentifier = [clientId dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *keychainQuery =
    @{(__bridge id)kSecClass          : (__bridge id)kSecClassGenericPassword,
      // use clientId to "invalidate" access token if developer changed clientId
      (__bridge id)kSecAttrAccount    : encodedIdentifier,
      (__bridge id)kSecAttrService    : clientId,
      (__bridge id)kSecAttrGeneric    : encodedIdentifier};
    /*
     * Removing this key as to keep it same with old keychain access.
     * (__bridge id)kSecAttrAccessible :(__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly};
     */
    return keychainQuery;
}

- (void)removeRefreshTokenFromKeychainWithClientId:(NSString *)clientId {
    NSDictionary *keychainQuery = [self.class keychainQueryWithClientId:clientId];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    if (status != errSecSuccess && status != errSecItemNotFound) {
        NSLog(@"Error deleting access token from keyching %li", (long int)status);
    }
}

- (void)saveRefreshTokenInKeychain:(NSString *)refreshToken forClientId:(NSString *)clientId {
    if (refreshToken == nil || refreshToken.length == 0) {
        return;
    }
    
    [self removeRefreshTokenFromKeychainWithClientId:clientId];
    NSMutableDictionary *keychainQuery = [[self.class keychainQueryWithClientId:clientId] mutableCopy];
    NSData *passwordData = [refreshToken dataUsingEncoding:NSUTF8StringEncoding];
    [keychainQuery setObject:passwordData forKey:(__bridge id)kSecValueData];
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
    if (status != noErr) {
        NSLog(@"Error saving access token in keyching %li", (long int)status);
    }
}

- (NSString *)readRefreshTokenFromKeychainWithClientId:(NSString *)clientId {
    NSMutableDictionary *keychainQuery = [[self.class keychainQueryWithClientId:clientId] mutableCopy];
    [keychainQuery setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    CFDataRef passwordData = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery,
                                          (CFTypeRef *)&passwordData);
    NSString *acessToken = nil;
    if (status == noErr && 0 < [(__bridge NSData *)passwordData length]) {
        acessToken = [[NSString alloc] initWithData:(__bridge NSData *)passwordData
                                           encoding:NSUTF8StringEncoding];
    }
    if (passwordData != NULL) {
        CFRelease(passwordData);
    }
    return acessToken;
}

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

+ (NSString*)getRefreshToken
{
    return [[SMKeychain sharedKeychain] readRefreshTokenFromKeychainWithClientId:ServiceMaxKeyChainIdenitifier];
}

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

+ (void)storeRefreshToken:(NSString *)refreshToken
{
    [[SMKeychain sharedKeychain] saveRefreshTokenInKeychain:refreshToken
                                                      forClientId:ServiceMaxKeyChainIdenitifier];
}

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

+ (void)deleteRefreshToken
{
    return [[SMKeychain sharedKeychain] removeRefreshTokenFromKeychainWithClientId:ServiceMaxKeyChainIdenitifier];
}

#pragma mark Access Token

+ (NSString*)getAccessToken
{
    return [[SMKeychain sharedKeychain] readRefreshTokenFromKeychainWithClientId:ServiceMaxKeyChainAccessIdenitifier];
}

+ (void)storeAccessToken:(NSString *)accessToken
{
    [[SMKeychain sharedKeychain] saveRefreshTokenInKeychain:accessToken
                                                forClientId:ServiceMaxKeyChainAccessIdenitifier];
}

+ (void)deleteAccessToken
{
    return [[SMKeychain sharedKeychain] removeRefreshTokenFromKeychainWithClientId:ServiceMaxKeyChainAccessIdenitifier];
}

@end
