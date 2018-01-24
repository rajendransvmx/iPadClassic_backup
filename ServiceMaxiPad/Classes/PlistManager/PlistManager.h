//
//  Plist Manager.h
//  ServiceMaxMobile
//
//  Created by Naveen Vasu on 21/03/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppManager.h"
#import <CoreLocation/CoreLocation.h>

extern  NSString *const kPreferenceIdentifier;
extern  NSString *const kPreferenceOrganizationProduction;
extern  NSString *const kPreferenceOrganizationSandbox;
extern  NSString *const kPreferenceOrganizationCustom;

@interface PlistManager : NSObject

+ (void)registerDefaultAppSettings;
+ (void)updateServerURLFromManagedConfig;
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

+ (void)storeApplicationPreviousSyncStatus:(ApplicationStatus)status;
+ (NSUInteger)getStoredApplicationPreviousSyncStatus;

+ (void)storeApplicationFailedStatus:(ApplicationStatus)status;
+ (NSUInteger)getStoredApplicationFailedStatus;

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

+ (NSString *)getLoggedInUserName;

+ (NSString *)getLastUsedViewProcessForObjectName:(NSString *)objectName;
+ (void) storeLastUsedViewProcess:(NSString *)processId objectName:(NSString *)objectName;

+ (void)deleteAccessTokenGeneratedTimeEntry;
+ (void)saveAccessTokenGeneratedTime;
+ (NSUInteger)storedAccessTokenGeneratedTime;

+ (void)saveAccessToken:(NSString *)newAccesToken;

+ (void)saveApplicationInstalledTime;
+ (NSUInteger)storedApplicationInstalledTime;

+ (void)saveApplicationWakeupTime;
+ (NSUInteger)storedApplicationWakeupTime;

+ (void)saveApplicationUpdatedTime;
+ (NSUInteger)storedApplicationUpdatedTime;

+ (void)recordApplicationVersion;
+ (NSString *)storedrecordApplicationVersion;

+ (void)recordApplicationLaunchPoint;

+ (NSString *)getOneCallSyncTime;
+ (void)storeOneCallSyncTime:(NSString *)time;

+ (NSString *)getPutUpdateTime;
+ (void)storePutUpdateTime:(NSString *)time;

+ (NSString *)getTempOneCallSyncTime;
+ (void)storeTempOneCallSyncTime:(NSString *)time;

+ (void)storeLastLocalIdnDefaults:(NSString *)lastSyncTime;
+ (NSInteger )getLastLocalIdFromDefaults ;
+ (void )removeLastLocalIdFromDefaults;

+ (void)moveDataSyncTimeFromTemp;

+ (NSError *)lastOAuthErrorMessage;
+ (void)storeOAuthErrorMessage:(NSError *)error;
+ (void)resetOAuthError;

+ (NSInteger)storedCheckBoxValueForDataSyncConfirmMessage;
+ (void)storeDataSyncConfirmMessageCheckBoxValue:(NSInteger)value;

#pragma mark -Last Sync Time And Status
+ (NSString *)getLastConfigSyncGMTTime;
+ (void)storeLastConfigSyncGMTTime:(NSString *)lastConfigSyncTime;
+ (NSString *)getLastConfigSyncStatus;
+ (void)storeLastConfigSyncStatus:(NSString *)lastConfigSyncStatus;

+ (NSString *)getLastDataSyncGMTTime;
+ (void)storeLastDataSyncGMTTime:(NSString *)lastDataSyncTime;
+ (NSString *)getLastDataSyncStatus;
+ (void)storeLastDataSyncStatus:(NSString *)lastDataSyncStatus;

+ (NSString *)getLastDataSyncStartGMTTime;
+ (void)storeLastDataSyncStartGMTTime:(NSString *)lastDataSyncTime;
+ (void )removeLastDataSyncStartGMTTime;

+ (NSString *)getLastResetAppOrInitialSyncGMTTime;
+ (void)storeLastResetAppOrInitialSyncGMTTime:(NSString *)lastConfigSyncTime;

+ (NSString *)getLastScheduledConfigSyncGMTTime;
+ (void)storeLastScheduledConfigSyncGMTTime:(NSString *)lastConfigSyncTime;

+ (NSString *)getLastScheduledDataSyncGMTTime;
+ (void)storeLastScheduledDataSyncGMTTime:(NSString *)lastConfigSyncTime;


//Push Log related.
+ (NSString *)getLastPushLogGMTTime;
+ (void)storeLastPushLogGMTTime:(NSString *)lastPushLogTime;
+ (NSString *)getLastPushLogStatus;
+ (void)storeLastPushLogStatus:(NSString *)lastPushLogStatus;
#pragma mark - End

+(BOOL)isFirstTimeLogin;

+ (NSMutableDictionary *) getSwitchLayoutDict;
+ (void)updateSwitchLayoutDictionary:(NSMutableDictionary *)dict;

#pragma mark - Location Ping methods
+ (CLLocation *)getTechnicianCLLocation;
+ (void)storeTechnicianCLLocation:(CLLocation *)location;

+ (NSDictionary *)getTechnicianLastLocationStatus;
+ (void)storeTechnicianLastLocationStatus:(NSDictionary *)statusDict;
#pragma mark - End

+ (void)storeObjectName:(NSString *)objectName
                  forId:(NSString *)localId;
+ (NSString *)objectNameForId:(NSString *)whatId;
+ (void)clearAllWhatIdObjectInformation;

+ (void)writeIntoPlist:(NSString *)plistName data:(NSMutableDictionary *)dataInDict;

+ (void)saveJobLogsEnabled:(BOOL)enabled;
+ (BOOL)storedJobLogsEnabledValue;

+ (void)storePriceCaluclationHasPermission:(BOOL)hasPermission ;
+ (void)removeGetPricePermission;
+ (BOOL)canPerformGetPrice;

+ (NSString *)getTechnicianLocation;
+ (NSString *)getTechnicianLocationId;
+ (void)storeTechnicianLocation:(NSString *)currentLocation;
+ (void)storeTechnicianLocationId:(NSString *)currentLocationId;
+ (void)removeUserTechnicianLocation;
+ (void)storeTechnicianId:(NSString *)technicianId;
+ (NSString *)getTechnicianId;

+ (NSString *)getInitialSyncTime;
+ (void)storeInitiaSyncSyncTimeForDP:(NSString *)time;

+ (void)setRefreshToken:(NSString*)refreshToken;
+ (NSString*)getRefreshToken;

//017609
+ (BOOL) shouldValidateAccessToken;

+ (BOOL)enableAnalytics;

@end
