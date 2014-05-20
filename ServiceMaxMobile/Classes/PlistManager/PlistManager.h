//
//  Plist Manager.h
//  ServiceMaxMobile
//
//  Created by Naveen Vasu on 21/03/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppManager.h"

extern  NSString *const kPreferenceIdentifier;
extern  NSString *const kPreferenceOrganizationProduction;
extern  NSString *const kPreferenceOrganizationSandbox;
extern  NSString *const kPreferenceOrganizationCustom;

@interface PlistManager : NSObject

+ (void)registerDefaultAppSettings;
+ (NSMutableDictionary *)getDefaultTags;
+ (NSDictionary *)getDictionaryFromPlistWithName:(NSString *)plistFileName;


// User Default Storage

+ (void)saveCustomerOrganisationInfo:(NSDictionary *)infoDictionary;
+ (void)loadCustomerOrgInfo;
+ (void)saveCallBackInformation:(NSDictionary *)infoDictionary;

+ (void)storeUserPreferedPlatformName:(NSString *)platformName;
+ (NSString *)userPreferedPlatformName;

+ (void)storeCustomURLString:(NSString *)urlString;
+ (NSString *)customURLString;

+ (NSString *)baseURLString;

+ (void)storeApplicationStatus:(ApplicationStatus)status;
+ (NSUInteger)getStoredApplicationStatus;

+ (void)storeUserStatus:(UserStatus)status;
+ (NSUInteger)getStoredUserStatus;

+ (void)storeCurrentServerPackage:(NSString *)newPackage;
+ (NSString *)getStoredCurrentServerPackage;

+ (void)storePreviousUserName:(NSString *)userName;
+ (NSString *)getStoredPreviousUserName;

+ (void)storeUserPreferedLastPlatformName:(NSString *)platformName;
+ (NSString *)userPreferedLastPlatformName;

+ (void)storeApiUrl:(NSString *)urlString;
+ (NSString *)getStoredApiUrl;

+ (void)storeInstanceUrl:(NSString *)urlString;
+ (NSString *)getStoredInstanceUrl;

@end
