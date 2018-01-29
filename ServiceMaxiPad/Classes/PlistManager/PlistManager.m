//
//  Plist Manager.m
//  ServiceMaxMobile
//
//  Created by Naveen Vasu on 21/03/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "PlistManager.h"
#import "FileManager.h"
#import "CustomerOrgInfo.h"
#import "SMKeychain.h"
#import "AppManager.h"
#import "StringUtil.h"
#import "AppMetaData.h"
#import "NSString+StringUtility.h"
#import "SVMXSystemConstant.h"


static NSString *const kIsFirstTimeLogin                    = @"FIRST_TIME_LOGIN";

//static NSString *const kEmptyString                  = @"";

static NSString *const kOAuthResponseUserId          = @"user_id";
static NSString *const kOAuthResponseUserName        = @"username";
static NSString *const kOAuthResponseUserLanguage    = @"language";
static NSString *const kOAuthResponseUserOrgId       = @"organization_id";
static NSString *const kOAuthResponseUserDisplayName = @"display_name";

static NSString *const kOAuthResponseAccessToken    = @"access_token";
static NSString *const kOAuthResponseIdentityURL    = @"id";
static NSString *const kOAuthResponseRefreshToken   = @"refresh_token";
static NSString *const kOAuthResponseInstanceURL    = @"instance_url";


// Key for User Default storage (Persistnace Store)
static NSString *const kPersistanceStoreUserId          = @"ps_user_id";
static NSString *const kPersistanceStoreUserName        = @"ps_username";
static NSString *const kPersistanceStoreCurrentUserName = @"ps_cur_username";
static NSString *const kPersistanceStoreUserLanguage    = @"ps_language";
static NSString *const kPersistanceStoreUserOrgId       = @"ps_organization_id";
static NSString *const kPersistanceStoreUserDisplayName = @"ps_display_name";
static NSString *const kPersistanceStoreProfileId       = @"ps_profile_id";
static NSString *const kPersistanceStoreCurrentUserId   = @"ps_cur_user_id";
static NSString *const kPersistanceStoreLoggedInUserId  = @"ps_loggedIn_user_id";

static NSString *const kPersistanceStoreAccessToken     = @"ps_ac_token";
static NSString *const kPersistanceStoreIdentityUrl     = @"ps_id_url";

static NSString *const kPersistanceStoreAppStatus       = @"ps_app_st";
static NSString *const kPersistanceStoreAppPreSyncStatus = @"ps_app_prv_sync_st";
static NSString *const kPersistanceStoreAppFailedStatus = @"ps_app_failed_st";
static NSString *const kPersistanceStoreUserStatus      = @"ps_usr_st";

static NSString *const kPersistanceStoreServerPackage   = @"ps_cur_srvr_pkg";
static NSString *const kPersistanceStoreApiUrl          = @"ps_cur_api_url";
static NSString *const kPersistanceStoreInstanceUrl     = @"ps_cur_instance_url";

static NSString *const kPersistanceStorePreferenceId    = @"preference_identifier";
static NSString *const kPersistanceStoreCustomUrl       = @"custom_url";

static NSString *const kPersistanceStoreLastPreferenceId = @"ps_last_pr_id";
static NSString *const kPersistanceStoreLastUserName     = @"ps_last_usr_name";

static NSString *const kPersistanceStoreTokenStoredTime = @"ps_access_token_time";
static NSString *const kPersistanceStoreJobLogEnabled   = @"ps_job_log_enabled";

static NSString *const kPersistanceStoreAppInstallTime  = @"ps_install_time";
static NSString *const kPersistanceStoreAppUpdatedTime  = @"ps_update_time";
static NSString *const kPersistanceStoreAppWakeUpTime   = @"ps_wakeup_time";
static NSString *const kPersistanceStoreAppVersions     = @"ps_versions";

static NSString *const kPersistanceStoreOAuthError      = @"ps_OAuth_err";

static NSString *const kTechnicianCurrentLocation       = @"TechnicianLocation";
static NSString *const kTechnicianCurrentLocationId     = @"TechnicianLocationId";
static NSString *const kUserFullName                    = @"USERFULLNAME";
static NSString *const kTechnicianId                    = @"serviceGroupMemberId";

static NSString *const kPersistanceStoreChkBoxValueDataSync   = @"ps_dsync_chk_box";

static NSString *const kLastConfigSyncGMTTime           = @"LastConfigSyncGMTTime";
static NSString *const kLastConfigSyncStatus            = @"LastConfigSyncStatus";
static NSString *const kLastDataSyncGMTTime             = @"LastDataSyncGMTTime";
static NSString *const kLastDataSyncStatus              = @"LastDataSyncStatus";
static NSString *const KLastReportSyncGMTTime           = @"LastReportSyncGMTTime";
static NSString *const KLastReportSyncStatus            = @"LastReportSyncStatus";

static NSString *const kLastDataSyncStartTime           = @"LastDataSyncStartGMTTime";

static NSString *const kInitialsSyncOrResetAppGMTTime   = @"ps_init_sync_time";
static NSString *const kLastScheduledConfigSyncGMTTime  = @"ps_last_confg_sync_time";
static NSString *const kLastScheduledDataSyncGMTTime    = @"ps_last_data_sync_time";

static NSString *const kLastPushLogGMTTime              = @"LastPushLogGMTTime";
static NSString *const kLastPushLogStatus               = @"LastPushLogStatus";

static NSString *const kTechnicianCLLocation            = @"TechnicianCLLocation";
static NSString *const kTechnicianLastLocationStatus    = @"TechnicianLastLocationStatus";

/* Login URLs for different platform */
static NSString *const kProductionOrg     = @"https://login.salesforce.com";
static NSString *const kSandboxOrg        = @"https://test.salesforce.com";

/*
 Fixed Issue :023391
 HS 7Oct2016 Changed BaseURL from "www.salesforce.com" to "https://login.salesforce.com" as per Salesforce confirmation under below statement
 As of January 1, 2016, the internal routing will be retired, and any API endpoints will need to be changed if from www.salesforce.com to https://login.salesforce.com.
 */
//static NSString *const kDefaultBaseOrg    = @"https://www.salesforce.com";

static NSString *const kDefaultBaseOrg    = @"https://login.salesforce.com";



static NSString *const kPersistantStorageOneCallSyncTime              = @"one_call_sync_time";
static NSString *const kPersistantStorageOneCallSyncPutUpdateTime     = @"one_call_sync_put_update_time";
static NSString *const kPersistantStorageOneCallSyncTemporaryTime     = @"one_call_sync_temp_time";
static NSString *const kOneCallLastLocalid                            = @"kOneCallLastLocalid";
static NSString *const kPersistantStorageInitialSyncTime              = @"InitailSyncTime";
static NSString *const kPersistantStorageGetPriceSyncTime             = @"GetPriceSyncTime";
static NSString *const kPersistantStorageProdIQSyncTime               = @"ProdIQSyncTime";

static NSString *const kRefreshToken    = @"rfrt";



/** Public constant declaration */

NSString *const kPreferenceIdentifier  = @"preference_identifier";
NSString *const kPreferenceOrganizationCustom  = @"Custom";
NSString *const kPreferenceOrganizationSandbox  = @"Sandbox";
NSString *const kPreferenceOrganizationProduction  = @"Production";

//017609
NSString *const kPreferenceAccessToken = @"Session Auto Refresh";

static NSString *const kSwitchLayout = @"SwitchLayout";
static NSString * const kEventWhatIdToObjectName = @"EventWhatIdToObjectName";
static NSUInteger const kRefreshTokenSplitIndex      = 10;        /** Refresh token split index  */

// The Managed app configuration dictionary pushed down from an MDM server are stored in this key.
static NSString * const kConfigurationKey = @"com.apple.configuration.managed";
static NSString * const kConfigurationServerURLKey = @"serverURL";

/** Sync Profiling **/
NSString *const kSalesForceProfileId = @"SalesForceProfileId";
NSString *const kSalesForceOrgName = @"SalesForceOrgName";
NSString *const kSalesForceOrgId = @"SalesForceOrgId";
NSString *const kSyncProfileEnabled = @"SyncProfileEnabled";
NSString *const kGroupProfileId = @"ServiceMaxGroupProfileId";
NSString *const kSPTypeStart = @"SPTypeStart";
NSString *const kSPTypeEnd = @"SPTypeEnd";
NSString *const kGroupProfileName = @"ServiceMaxGroupProfileName";
NSString *const kSPSyncTime = @"SPSyncTime";

//New Relic integration
NSString *const kEnableNewRelicAnalytics = @"Enable Analytics";

@implementation PlistManager

+ (void)registerDefaultAppSettings
{
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    
    if (settingsBundle != nil)
    {
        NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
        NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
        
        NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
        
        /**
         *  Sample preferenceSpecification data structure.
         *
         *  {
         *       DefaultValue = Production;
         *       Key = "preference_identifier";
         *       Title = "Login Host";
         *       Titles =     (
         *               Production,
         *               Sandbox,
         *               "Custom Host"
         *           );
         *       Type = PSMultiValueSpecifier;
         *       Values =     (
         *                       Production,
         *                       Sandbox,
         *                       Custom
         *                   );
         *   }
         *
         *
         */
        
        for (NSDictionary *preferenceSpecification in preferences)
        {
//            NSLog(@" preferenceSpecification - %@ ", [preferenceSpecification description]);
            
            /** Must use 'Key' to get the key-value */
            NSString *key = [preferenceSpecification objectForKey:@"Key"];
            
            if (key != nil)
            {
                [defaultsToRegister setObject:[preferenceSpecification objectForKey:@"DefaultValue"] forKey:key];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
        defaultsToRegister = nil;
        [self updateServerURLFromManagedConfig];
    }
}

+(void)updateServerURLFromManagedConfig
{
    NSDictionary *serverConfig = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kConfigurationKey];
    NSString *serverURLString = serverConfig[kConfigurationServerURLKey];
    
    // If validation fails, be sure to set a sensible default value as a fallback, even if it is nil.
    if (serverURLString && [serverURLString isKindOfClass:[NSString class]] && ![serverURLString isEqualToString:[PlistManager customURLString]]) {
        [PlistManager storeCustomURLString:serverURLString];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:kPreferenceOrganizationCustom forKey:kPreferenceIdentifier];
        [userDefaults synchronize];
    }
}

+ (NSMutableDictionary *)getDefaultTags
{
    static NSString *const DefaultLocalizationFileName = @"LocalizationDefaults.plist";
    
    NSString *pathForLocalisation = [[NSBundle mainBundle] bundlePath];
    NSString *localisationPlistPath = [pathForLocalisation stringByAppendingPathComponent:DefaultLocalizationFileName];
    NSMutableDictionary *tags = [NSMutableDictionary dictionaryWithContentsOfFile:localisationPlistPath];
    return tags;
}


+ (NSDictionary *)getDictionaryFromPlistWithName:(NSString *)plistFileName
{
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:[FileManager getFilePathForPlist:plistFileName]];
    return plistDictionary;
}


+ (void)saveCustomerOrganisationInfo:(NSDictionary *)infoDictionary
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // User Id
    NSString * userId  = kEmptyString;
    
    if ([infoDictionary objectForKey:kOAuthResponseUserId] != nil)
    {
        userId  = [infoDictionary objectForKey:kOAuthResponseUserId];
    }
    
    [userDefaults setObject:userId forKey:kPersistanceStoreUserId];
    [userDefaults setObject:userId forKey:kPersistanceStoreProfileId];
    [userDefaults setObject:userId forKey:kPersistanceStoreCurrentUserId];
    [userDefaults setObject:userId forKey:kPersistanceStoreLoggedInUserId];
    
    
    // User Name
    NSString * userName  = kEmptyString;

    if ([infoDictionary objectForKey:kOAuthResponseUserName] != nil)
    {
        userName  = [infoDictionary objectForKey:kOAuthResponseUserName];
    }
    [userDefaults setObject:userName forKey:kPersistanceStoreUserName];
    [userDefaults setObject:userName forKey:kPersistanceStoreCurrentUserName];
   
    // User Language
    NSString * userLangauge  = kEmptyString;
    
    if ([infoDictionary objectForKey:kOAuthResponseUserLanguage] != nil)
    {
        userLangauge  = [infoDictionary objectForKey:kOAuthResponseUserLanguage];
    }
    [userDefaults setObject:userLangauge forKey:kPersistanceStoreUserLanguage];
    
    // User Org ID
    NSString * orgId  = kEmptyString;
    
    if ([infoDictionary objectForKey:kOAuthResponseUserOrgId] != nil)
    {
        orgId  = [infoDictionary objectForKey:kOAuthResponseUserOrgId];
    }
    [userDefaults setObject:orgId forKey:kPersistanceStoreUserOrgId];

    
    // User Display Name
    NSString * displayName  = kEmptyString;
    
    if ([infoDictionary objectForKey:kOAuthResponseUserDisplayName] != nil)
    {
        displayName  = [infoDictionary objectForKey:kOAuthResponseUserDisplayName];
    }
    [userDefaults setObject:displayName forKey:kPersistanceStoreUserDisplayName];
    
    [userDefaults synchronize];
    [PlistManager loadCustomerOrgInfo];
    
    //Defect Fix:035387
    [[AppMetaData sharedInstance] loadApplicationMetaData];

    [[CustomerOrgInfo sharedInstance] explainMe];
}


+ (void)saveCallBackInformation:(NSDictionary *)infoDictionary
{
   // SXLogInfo(@"  infoDictionary :%@", infoDictionary);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *accessToken  = [infoDictionary objectForKey:kOAuthResponseAccessToken];
    NSString *identityURL  = [infoDictionary objectForKey:kOAuthResponseIdentityURL];
    NSString *refreshToken = [infoDictionary objectForKey:kOAuthResponseRefreshToken];
    NSString *instanceURL = [infoDictionary objectForKey:kOAuthResponseInstanceURL];

    accessToken  = [accessToken stringByReplacingOccurrencesOfString:@"%21" withString:@"!"];
    
    refreshToken = [refreshToken stringByReplacingOccurrencesOfString:@"%3D" withString:@"="];
    
    identityURL  = [identityURL stringByReplacingOccurrencesOfString:@"%3A" withString:@":"];
    identityURL  = [identityURL stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
    
    instanceURL  = [instanceURL stringByReplacingOccurrencesOfString:@"%3A" withString:@":"];
    instanceURL  = [instanceURL stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
    
    
    [userDefaults setObject:identityURL forKey:kPersistanceStoreIdentityUrl];
    [userDefaults setObject:accessToken forKey:kPersistanceStoreAccessToken];
    [userDefaults setObject:instanceURL forKey:kPersistanceStoreInstanceUrl];
    
    if (accessToken != nil)
    {
        [self saveAccessTokenGeneratedTime];
    }
    
    [userDefaults synchronize];
    
    /*** Lets remove existing refresh token and store new one in key chain utils. */
    [SMKeychain deleteRefreshToken];
    [SMKeychain storeRefreshToken:refreshToken];
    /* Lets store refresh token in plist as well as back up plan */
    [PlistManager setRefreshToken:refreshToken];
    
    [[CustomerOrgInfo sharedInstance] setRefreshToken:refreshToken];
    [[CustomerOrgInfo sharedInstance] setAccessToken:accessToken];
    [[CustomerOrgInfo sharedInstance] setIdentityURL:identityURL];
    
    [[CustomerOrgInfo sharedInstance] setInstanceURL:instanceURL];
    //[[CustomerOrgInfo sharedInstance] explainMe];
}


+ (NSString *)userLanguage
{
   NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
   return [userDefaults valueForKey:kPersistanceStoreUserLanguage];
}


+ (NSString *)serverURL
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:@"api_url"];
}


+ (void)storeUserPreferedPlatformName:(NSString *)platformName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:platformName forKey:kPersistanceStorePreferenceId];
    [userDefaults synchronize];
}


+ (NSString *)userPreferedPlatformName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kPersistanceStorePreferenceId];
}


+ (void)storeCustomURLString:(NSString *)urlString
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:urlString forKey:kPersistanceStoreCustomUrl];
    [userDefaults synchronize];
}


+ (NSString *)customURLString
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kPersistanceStoreCustomUrl];
}


+ (void)loadCustomerOrgInfo
{
    
    CustomerOrgInfo *orgInfo = [CustomerOrgInfo sharedInstance];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    /**
     *  User Name
     *  Current User Name
     *  User  Display Name
     *  Previous User Name
     *
     */

    [orgInfo setUserName:[userDefaults objectForKey:kPersistanceStoreUserName]];
    [orgInfo setCurrentUserName:[userDefaults objectForKey:kPersistanceStoreCurrentUserName]];
    [orgInfo setUserDisplayName:[userDefaults objectForKey:kPersistanceStoreUserDisplayName]];
    [orgInfo setPreviousUserName:[userDefaults objectForKey:kPersistanceStoreLastUserName]];
    
    /**
     *  UserId
     *  Logged User Id
     *  Current User Id
     *  User Org Id
     *  Profile Id
     */

    [orgInfo setUserId:[userDefaults objectForKey:kPersistanceStoreUserId]];
    [orgInfo setLoggedUserId:[userDefaults objectForKey:kPersistanceStoreLoggedInUserId]];
    [orgInfo setCurrentUserId:[userDefaults objectForKey:kPersistanceStoreCurrentUserId]];
    [orgInfo setUserOrgId:[userDefaults objectForKey:kPersistanceStoreUserOrgId]];
    [orgInfo setProfileId:[userDefaults objectForKey:kPersistanceStoreProfileId]];
    
    /** User Language  */
    
    [orgInfo setUserLanguage:[userDefaults objectForKey:kPersistanceStoreUserLanguage]];
    
    /** Access Token  */
    
    [orgInfo setAccessToken:[userDefaults objectForKey:kPersistanceStoreAccessToken]];

     /** 
      *  ApiURL
      *  Intance URL
      *
      */
    
    [orgInfo setApiURL:[userDefaults objectForKey:kPersistanceStoreApiUrl]];
    [orgInfo setInstanceURL:[userDefaults objectForKey:kPersistanceStoreInstanceUrl]];
    
    
    /** Server Version  */
    
    [orgInfo setServerVersion:[userDefaults objectForKey:kPersistanceStoreServerPackage]];
    
    /**
     *  Platform prefernce Host ex:- Production, Sandbox and Custom
     *   
     *   1. User Logged In host
     *   2. User previous logged in host
     *
     */

    [orgInfo setPreviousOrg:[userDefaults objectForKey:kPersistanceStoreLastPreferenceId]];
    [orgInfo setUserLoggedInHost:[userDefaults objectForKey:kPersistanceStoreLastPreferenceId]];
    
    NSString *refreshToken = [SMKeychain getRefreshToken];
    
    if ([StringUtil isStringEmpty:refreshToken]) {
        SXLogWarning(@"Key Chain token is invalid            : %@ ", refreshToken);
        refreshToken = [PlistManager getRefreshToken];
        SXLogWarning(@"Stored Plist Token            : %@ ", refreshToken);
    }
    else
    {
        NSString * storedToken = [PlistManager getRefreshToken];
        if ([StringUtil isStringEmpty:storedToken])
        {
            [PlistManager setRefreshToken:refreshToken];
        }
    }
    
    [[CustomerOrgInfo sharedInstance] setRefreshToken:refreshToken];
    [[CustomerOrgInfo sharedInstance] explainMe];
}


+ (NSString *)baseURLString
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSString *preference = [defaults valueForKey:kPreferenceIdentifier];
    
    NSString *baseUrlString = kDefaultBaseOrg;
    
    if ([StringUtil isStringEmpty:preference])
    {
        /**  In case of invalid string will use production org as default preference org */
        preference = kPreferenceOrganizationProduction;
    }
    
    if ([preference isEqualToString:kPreferenceOrganizationProduction] )
    {
        baseUrlString = kProductionOrg;
    }
    else if ( [preference isEqualToString:kPreferenceOrganizationSandbox] )
    {
        baseUrlString = kSandboxOrg;
    }
    else
    {
        preference = kPreferenceOrganizationCustom;
       
        //NSString *customURL = [defaults valueForKey:@"custom_url"];
        //SecScan-582
        
        if ( ([[defaults valueForKey:@"custom_url"] hasPrefix:@"http://"]) || ([[defaults valueForKey:@"custom_url"] hasPrefix:@"https://"]) )
        {
            // Yes, network protocol like http or https has added. Good to go
            [self storeCustomURLString:[defaults valueForKey:@"custom_url"]];

        }
		else
        {
            [self storeCustomURLString:[NSString stringWithFormat:@"https://%@",[defaults valueForKey:@"custom_url"]]];
        }
        
        baseUrlString = [self customURLString];
    }
    
    /**
     *  Store user prefered platform name.
     *  This platform name will used by other component in the application - Ex- User status view in calendar view
     *  Also used to check whether user has been changing org while checking Switch user
     */
    
    [[CustomerOrgInfo sharedInstance] setUserPreferenceHost:preference];
    [self storeUserPreferedPlatformName:preference];
    
    return baseUrlString;
}


+ (void)storeApplicationStatus:(ApplicationStatus)status
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:status forKey:kPersistanceStoreAppStatus];
    [userDefaults synchronize];
}


+ (NSUInteger)getStoredApplicationStatus
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return  [userDefaults integerForKey:kPersistanceStoreAppStatus];
}


+ (void)storeApplicationPreviousSyncStatus:(ApplicationStatus)status
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:status forKey:kPersistanceStoreAppPreSyncStatus];
    [userDefaults synchronize];
}


+ (NSUInteger)getStoredApplicationPreviousSyncStatus
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return  [userDefaults integerForKey:kPersistanceStoreAppPreSyncStatus];
}




+ (void)storeApplicationFailedStatus:(ApplicationStatus)status
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:status forKey:kPersistanceStoreAppFailedStatus];
    [userDefaults synchronize];
}


+ (NSUInteger)getStoredApplicationFailedStatus
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return  [userDefaults integerForKey:kPersistanceStoreAppFailedStatus];
}



+ (void)storeUserStatus:(UserStatus)status
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:status forKey:kPersistanceStoreUserStatus];
    [userDefaults synchronize];
}


+ (NSUInteger)getStoredUserStatus
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return  [userDefaults integerForKey:kPersistanceStoreUserStatus];
}


+ (void)storeCurrentServerPackage:(NSString *)newPackage
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:newPackage forKey:kPersistanceStoreServerPackage];
    [userDefaults synchronize];
    [[CustomerOrgInfo sharedInstance] setServerVersion:newPackage];
}


+ (NSString *)getStoredCurrentServerPackage
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return  [userDefaults stringForKey:kPersistanceStoreServerPackage];
}


+ (void)storeUserPreferedLastPlatformName:(NSString *)platformName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:platformName forKey:kPersistanceStoreLastPreferenceId];
    [userDefaults synchronize];
    [[CustomerOrgInfo sharedInstance] setPreviousOrg:platformName];
}


+ (NSString *)userPreferedLastPlatformName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kPersistanceStoreLastPreferenceId];
}


+ (void)storePreviousUserName:(NSString *)userName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:userName forKey:kPersistanceStoreLastUserName];
    [userDefaults synchronize];
    [[CustomerOrgInfo sharedInstance] setPreviousUserName:userName];
}


+ (NSString *)getStoredPreviousUserName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kPersistanceStoreLastUserName];
}


+ (void)storeApiUrl:(NSString *)urlString
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:urlString forKey:kPersistanceStoreApiUrl];
    [userDefaults synchronize];
    [[CustomerOrgInfo sharedInstance] setApiURL:urlString];
}


+ (NSString *)getStoredApiUrl
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kPersistanceStoreApiUrl];
}


+ (void)storeInstanceUrl:(NSString *)urlString
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:urlString forKey:kPersistanceStoreInstanceUrl];
    [userDefaults synchronize];
    [[CustomerOrgInfo sharedInstance] setInstanceURL:urlString];
}


+ (NSString *)getStoredInstanceUrl
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kPersistanceStoreInstanceUrl];
}

+ (NSMutableDictionary *) getSwitchLayoutDict
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:kSwitchLayout];
}

+ (void)updateSwitchLayoutDictionary:(NSMutableDictionary *)dict
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:dict forKey:kSwitchLayout];
    [userDefaults synchronize];
}


+ (NSString *)getLoggedInUserName{
    NSString *userFullName=@"";
   /* NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([[userDefaults objectForKey:kUserFullName] length]>0)
    {
        userFullName = [userDefaults objectForKey:kUserFullName];  //To get user display name not email id
    }
    else
    {
        userFullName = nil;//TODO//[appDelegate.dataBase getLoggedInUser:appDelegate.username];
    }
    if (userFullName == nil) {
        userFullName = @"";
    }*/
    
    CustomerOrgInfo *customerOrgInfo = [CustomerOrgInfo sharedInstance];
    
    userFullName = customerOrgInfo.userDisplayName;
    
    if ([userFullName length] == 0) {
        userFullName = nil;  //TODO//[appDelegate.dataBase getLoggedInUser:appDelegate.username];
    }
    
    return userFullName;
}

#pragma mark - Technician Location

+ (NSString *)getTechnicianLocation
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *location = [userDefaults objectForKey:kTechnicianCurrentLocation];
    if ([StringUtil isStringEmpty:location]) {
        location = @"";
    }
    return location;
}

+ (NSString *)getTechnicianLocationId
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *location = [userDefaults objectForKey:kTechnicianCurrentLocationId];
    return location;
}

+ (NSString *)getTechnicianId
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *technicianId = [userDefaults objectForKey:kTechnicianId];
    return technicianId;
}

+ (void)storeTechnicianLocation:(NSString *)currentLocation
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:currentLocation forKey:kTechnicianCurrentLocation];
    [userDefaults synchronize];
}

+ (void)storeTechnicianLocationId:(NSString *)currentLocationId
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:currentLocationId forKey:kTechnicianCurrentLocationId];
    [userDefaults synchronize];
}

+ (void)removeUserTechnicianLocation {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kTechnicianCurrentLocation];
    [userDefaults synchronize];
    
    [userDefaults removeObjectForKey:kTechnicianCurrentLocationId];
    [userDefaults synchronize];
}

+ (void)storeTechnicianId:(NSString *)technicianId
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:technicianId forKey:kTechnicianId];
    [userDefaults synchronize];
}
#pragma mark - End


+ (NSString *)getLastUsedViewProcessForObjectName:(NSString *)objectName
{
    NSString *viewProcess = nil;
    NSMutableDictionary *switchLayoutDict = [self getSwitchLayoutDict];
    if (switchLayoutDict != nil){
        viewProcess = [switchLayoutDict objectForKey:objectName];
    }
    return viewProcess;

}


+ (void) storeLastUsedViewProcess:(NSString *)processId objectName:(NSString *)objectName
{
    NSMutableDictionary * layoutDict = [[NSMutableDictionary alloc]initWithDictionary:[self getSwitchLayoutDict]];
    if (layoutDict == nil){
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
        layoutDict = dict;
    }
    [layoutDict setObject:processId forKey:objectName];
    [self updateSwitchLayoutDictionary:layoutDict];
}

+ (void)deleteAccessTokenGeneratedTimeEntry
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPersistanceStoreTokenStoredTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)saveAccessTokenGeneratedTime
{
    long long time = (long long)[[NSDate date] timeIntervalSince1970];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(time) forKey:kPersistanceStoreTokenStoredTime];
    [userDefaults synchronize];
}

+ (NSUInteger)storedAccessTokenGeneratedTime
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return  ((NSNumber *)[userDefaults objectForKey:kPersistanceStoreTokenStoredTime]).integerValue;
}

+ (void)saveAccessToken:(NSString *)newAccesToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:newAccesToken forKey:kPersistanceStoreAccessToken];
    [userDefaults synchronize];
    [self saveAccessTokenGeneratedTime];
    [self loadCustomerOrgInfo];
}


+ (void)saveApplicationInstalledTime
{
    NSInteger storedTime = [PlistManager storedApplicationInstalledTime];
    if (storedTime < 1)
    {
        long long time = (long long)[[NSDate date] timeIntervalSince1970];
        
       // SXLogInfo(@" InstalledTime stored : %lld ", time);
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@(time) forKey:kPersistanceStoreAppInstallTime];
        [userDefaults synchronize];
    }
}

+ (NSUInteger)storedApplicationInstalledTime
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return  ((NSNumber *)[userDefaults objectForKey:kPersistanceStoreAppInstallTime]).integerValue;
}

+ (void)saveApplicationWakeupTime
{
    long long time = (long long)[[NSDate date] timeIntervalSince1970];
    
    //SXLogInfo(@"ApplicationWakeupTime time stored : %lld ", time);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(time) forKey:kPersistanceStoreAppWakeUpTime];
    [userDefaults synchronize];
}

+ (NSUInteger)storedApplicationWakeupTime
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return  ((NSNumber *)[userDefaults objectForKey:kPersistanceStoreAppWakeUpTime]).integerValue;
}

+ (void)saveApplicationUpdatedTime
{
    long long time = (long long)[[NSDate date] timeIntervalSince1970];
    
    //SXLogInfo(@"UpdatedTime time stored : %lld ", time);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(time) forKey:kPersistanceStoreAppUpdatedTime];
    [userDefaults synchronize];
}

+ (NSUInteger)storedApplicationUpdatedTime
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return  [userDefaults integerForKey:kPersistanceStoreAppUpdatedTime];
}

+ (void)recordApplicationVersion
{
    NSString *storedVersionString = [PlistManager storedrecordApplicationVersion];
   
    NSString *storedVersion = nil;
    NSArray *versions = nil;
   
    if (versions != nil)
    {
        versions = [storedVersionString componentsSeparatedByString:@","];
        storedVersion = [versions lastObject];
    }
    
    NSString *currentVersion =  [[AppMetaData sharedInstance] getApplicationVersion];
    
    NSString *storingVersion = nil;
    
    if (storedVersion != nil)
    {
        if (![storedVersion isEqualToString:currentVersion])
        {
            storingVersion = [NSString custAppend:storedVersionString,currentVersion,@","];
        }
    }
    else
    {
        storingVersion = [NSString custAppend:currentVersion,@","];
    }
    
    if (storingVersion != nil)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:storingVersion forKey:kPersistanceStoreAppVersions];
        [userDefaults synchronize];
        [PlistManager saveApplicationUpdatedTime];
    }
}

+ (NSString *)storedrecordApplicationVersion
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return  [userDefaults stringForKey:kPersistanceStoreAppVersions];
}


+ (void)recordApplicationLaunchPoint
{
    [PlistManager recordApplicationVersion];
    [PlistManager saveApplicationWakeupTime];
    [PlistManager saveApplicationInstalledTime];
}


+ (NSError *)lastOAuthErrorMessage
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    id someObject = [userDefaults objectForKey:kPersistanceStoreOAuthError];
    
    if ([someObject isKindOfClass:[NSString class]])
    {
        return  nil;
    }
    else
    {
        id objectTemp = [PlistManager unArchiveObject:someObject];
        
        if ([objectTemp isKindOfClass:[NSError class]]) {
            return objectTemp;
        }
        return nil;
    }
}

+ (void)storeOAuthErrorMessage:(NSError *)error
{
    
    id objectTemp = [PlistManager archiveObject:error];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (objectTemp != nil) {
            [userDefaults setObject:objectTemp forKey:kPersistanceStoreOAuthError];
    }
    [userDefaults synchronize];
}

+ (void)resetOAuthError
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"" forKey:kPersistanceStoreOAuthError];
    [userDefaults synchronize];
}


+ (NSInteger)storedCheckBoxValueForDataSyncConfirmMessage
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return  [userDefaults integerForKey:kPersistanceStoreChkBoxValueDataSync];
}

+ (void)storeDataSyncConfirmMessageCheckBoxValue:(NSInteger)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:value forKey:kPersistanceStoreChkBoxValueDataSync];
    [userDefaults synchronize];
}


#pragma mark - Get/Set datetime for one call sync

+ (NSString *)getGetPriceSyncTime {
    
    return [[NSUserDefaults standardUserDefaults] stringForKey:kPersistantStorageGetPriceSyncTime];
}

+ (void)storeGetPriceSyncTime:(NSString *)time {
    
    if (time != nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:time forKey:kPersistantStorageGetPriceSyncTime];
        [[NSUserDefaults standardUserDefaults]  synchronize];
    }
}

+ (NSString *)getOneCallSyncTime {

      return [[NSUserDefaults standardUserDefaults] stringForKey:kPersistantStorageOneCallSyncTime];
}

+ (void)storeOneCallSyncTime:(NSString *)time {
    if (time != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:time forKey:kPersistantStorageOneCallSyncTime];
        [[NSUserDefaults standardUserDefaults]  synchronize];
    }
}


+ (NSString *)getInitialSyncTime {
    
    return  [[NSUserDefaults standardUserDefaults] stringForKey:kPersistantStorageInitialSyncTime];
}
+ (void)storeInitiaSyncSyncTimeForDP:(NSString *)time {
    if (time != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:time forKey:kPersistantStorageInitialSyncTime];
        [[NSUserDefaults standardUserDefaults]  synchronize];
    }
}

+ (NSString *)getPutUpdateTime {
    return  [[NSUserDefaults standardUserDefaults] stringForKey:kPersistantStorageOneCallSyncPutUpdateTime];
}

+ (void)storePutUpdateTime:(NSString *)time{
    if (time != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:time forKey:kPersistantStorageOneCallSyncPutUpdateTime];
        [[NSUserDefaults standardUserDefaults]  synchronize];
    }
}

+ (NSString *)getTempOneCallSyncTime {
     return  [[NSUserDefaults standardUserDefaults] stringForKey:kPersistantStorageOneCallSyncTemporaryTime];
}

+ (void)storeTempOneCallSyncTime:(NSString *)time {
    if (time != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:time forKey:kPersistantStorageOneCallSyncTemporaryTime];
        [[NSUserDefaults standardUserDefaults]  synchronize];
    }
}

+ (void )removTempDataSyncTimeFromDefaults {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPersistantStorageOneCallSyncTemporaryTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



#pragma mark - End

#pragma mark - Get/Set last sync time for incremental sync
+ (void)storeLastLocalIdnDefaults:(NSString *)lastSyncTime{
    [[NSUserDefaults standardUserDefaults] setObject:lastSyncTime forKey:kOneCallLastLocalid];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSInteger )getLastLocalIdFromDefaults {
    return   [[[NSUserDefaults standardUserDefaults] objectForKey:kOneCallLastLocalid] intValue];
}

+ (void )removeLastLocalIdFromDefaults {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kOneCallLastLocalid];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark - End


+ (void)moveDataSyncTimeFromTemp {
    NSString *newTime = [PlistManager getTempOneCallSyncTime];
    if (newTime != nil) {
        [PlistManager storeOneCallSyncTime:newTime];
    }
    [PlistManager removTempDataSyncTimeFromDefaults];
}

#pragma mark -Last Sync Time And Status
+ (NSString *)getLastConfigSyncGMTTime {
    return  [[NSUserDefaults standardUserDefaults] stringForKey:kLastConfigSyncGMTTime];
}

+ (void)storeLastConfigSyncGMTTime:(NSString *)lastConfigSyncTime {
    if (lastConfigSyncTime != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:lastConfigSyncTime
                                                  forKey:kLastConfigSyncGMTTime];
        [[NSUserDefaults standardUserDefaults]  synchronize];
    }
}

+ (NSString *)getLastConfigSyncStatus {
    return  [[NSUserDefaults standardUserDefaults] stringForKey:kLastConfigSyncStatus];
}

+ (void)storeLastConfigSyncStatus:(NSString *)lastConfigSyncStatus {
    if (lastConfigSyncStatus != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:lastConfigSyncStatus
                                                  forKey:kLastConfigSyncStatus];
        [[NSUserDefaults standardUserDefaults]  synchronize];
    }
}

+ (NSString *)getLastDataSyncGMTTime {
    return  [[NSUserDefaults standardUserDefaults] stringForKey:kLastDataSyncGMTTime];
}

+ (void)storeLastDataSyncGMTTime:(NSString *)lastDataSyncTime {
    if (lastDataSyncTime != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:lastDataSyncTime
                                                  forKey:kLastDataSyncGMTTime];
        [[NSUserDefaults standardUserDefaults]  synchronize];
    }
}

+ (NSString *)getLastDataSyncStatus {
    return  [[NSUserDefaults standardUserDefaults] stringForKey:kLastDataSyncStatus];
}

+ (void)storeLastDataSyncStatus:(NSString *)lastDataSyncStatus {
    if (lastDataSyncStatus != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:lastDataSyncStatus
                                                  forKey:kLastDataSyncStatus];
        [[NSUserDefaults standardUserDefaults]  synchronize];
    }
}

+ (NSString *)getLastDataSyncStartGMTTime
{
    return  [[NSUserDefaults standardUserDefaults] stringForKey:kLastDataSyncStartTime];
}


+ (void)storeLastDataSyncStartGMTTime:(NSString *)lastDataSyncTime
{
    if (lastDataSyncTime != nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:lastDataSyncTime
                                                  forKey:kLastDataSyncStartTime];
        [[NSUserDefaults standardUserDefaults]  synchronize];
    }
}


+ (void )removeLastDataSyncStartGMTTime {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastDataSyncStartTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


//Push Log related.
+ (NSString *)getLastPushLogGMTTime {
    return  [[NSUserDefaults standardUserDefaults] stringForKey:kLastPushLogGMTTime];
}

+ (void)storeLastPushLogGMTTime:(NSString *)lastPushLogTime {
    if (lastPushLogTime != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:lastPushLogTime
                                                  forKey:kLastPushLogGMTTime];
        [[NSUserDefaults standardUserDefaults]  synchronize];
    }
}

+ (NSString *)getLastPushLogStatus {
    return  [[NSUserDefaults standardUserDefaults] stringForKey:kLastPushLogStatus];
}

+ (void)storeLastPushLogStatus:(NSString *)lastPushLogStatus {
    if (lastPushLogStatus != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:lastPushLogStatus
                                                  forKey:kLastPushLogStatus];
        [[NSUserDefaults standardUserDefaults]  synchronize];
    }
}

+ (NSString*)getLastReportSyncGMTTime {
    return [[NSUserDefaults standardUserDefaults] stringForKey:KLastReportSyncGMTTime];
}
+ (void)storeLastReportSyncGMTTime:(NSString*)lastReportSyncTime {
    [[NSUserDefaults standardUserDefaults] setObject:lastReportSyncTime forKey:KLastReportSyncGMTTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSString*)getLastReportSyncStatus {
    return [[NSUserDefaults standardUserDefaults] stringForKey:KLastReportSyncStatus];
}
+ (void)storeLastReportSyncStatus:(NSString*)lastReportSyncStatus {
    [[NSUserDefaults standardUserDefaults] setObject:lastReportSyncStatus forKey:KLastReportSyncStatus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -End

+(BOOL)isFirstTimeLogin{
    
    NSUserDefaults * usrDefaults  = [NSUserDefaults standardUserDefaults];
    
    NSString * flag  = [usrDefaults objectForKey:kIsFirstTimeLogin];
    
    if(flag == nil){
        [usrDefaults setObject:kIsFirstTimeLogin forKey:kIsFirstTimeLogin];
        return YES;
    }
    return NO;
}

#pragma mark - Location Ping methods
+ (CLLocation *)getTechnicianCLLocation {
    
    CLLocation *result;
    id archivedObj = [[NSUserDefaults standardUserDefaults] objectForKey:kTechnicianCLLocation];
    if (archivedObj) {
        result = [NSKeyedUnarchiver unarchiveObjectWithData:archivedObj];
    }
    return result;
}

+ (void)storeTechnicianCLLocation:(CLLocation *)location {
    if (location) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:location]
                                                  forKey:kTechnicianCLLocation];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
+ (NSDictionary *)getTechnicianLastLocationStatus {
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kTechnicianLastLocationStatus];
    return  dict;
}

+ (void)storeTechnicianLastLocationStatus:(NSDictionary *)statusDict {
    if (statusDict) {
        
        [[NSUserDefaults standardUserDefaults] setObject:statusDict forKey:kTechnicianLastLocationStatus];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
#pragma mark - End

#pragma mark - Handling Event WHATID refernce
+ (void)storeObjectName:(NSString *)objectName
                  forId:(NSString *)localId {
    
    if (localId != nil && objectName != nil) {
        NSMutableDictionary *whatIdToObjectNameDictionary = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:kEventWhatIdToObjectName]];
        [whatIdToObjectNameDictionary setObject:objectName forKey:localId];
        
        [[NSUserDefaults standardUserDefaults] setObject:whatIdToObjectNameDictionary forKey:kEventWhatIdToObjectName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

+ (NSString *)objectNameForId:(NSString *)whatId {
    if (whatId != nil) {
        
        NSDictionary *whatIdToObjectNameDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:kEventWhatIdToObjectName];
        return  [whatIdToObjectNameDictionary objectForKey:whatId];
    }
    return nil;
}

+ (void)clearAllWhatIdObjectInformation {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kEventWhatIdToObjectName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)writeIntoPlist:(NSString *)plistName data:(NSMutableDictionary *)dataInDict
{
    [dataInDict writeToFile:[FileManager getFilePathForPlist:plistName] atomically:YES];
}

+ (void)saveJobLogsEnabled:(BOOL)enabled
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:enabled forKey:kPersistanceStoreJobLogEnabled];
    [userDefaults synchronize];
}

+ (BOOL)storedJobLogsEnabledValue
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return  [userDefaults boolForKey:kPersistanceStoreJobLogEnabled];
}

#pragma End


+ (NSString *)getLastResetAppOrInitialSyncGMTTime
{
    return  [[NSUserDefaults standardUserDefaults] stringForKey:kInitialsSyncOrResetAppGMTTime];
}


+ (void)storeLastResetAppOrInitialSyncGMTTime:(NSString *)lastConfigSyncTime
{
    if (lastConfigSyncTime != nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:lastConfigSyncTime
                                                  forKey:kInitialsSyncOrResetAppGMTTime];
        [[NSUserDefaults standardUserDefaults]  synchronize];
    }
}


+ (NSString *)getLastScheduledConfigSyncGMTTime
{
    return  [[NSUserDefaults standardUserDefaults] stringForKey:kLastScheduledConfigSyncGMTTime];
}


+ (void)storeLastScheduledConfigSyncGMTTime:(NSString *)lastConfigSyncTime
{
    if (lastConfigSyncTime != nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:lastConfigSyncTime
                                                  forKey:kLastScheduledConfigSyncGMTTime];
        [[NSUserDefaults standardUserDefaults]  synchronize];
    }
}


+ (NSString *)getLastScheduledDataSyncGMTTime
{
    return  [[NSUserDefaults standardUserDefaults] stringForKey:kLastScheduledDataSyncGMTTime];
}


+ (void)storeLastScheduledDataSyncGMTTime:(NSString *)lastConfigSyncTime
{
    if (lastConfigSyncTime != nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:lastConfigSyncTime
                                                  forKey:kLastScheduledDataSyncGMTTime];
        [[NSUserDefaults standardUserDefaults]  synchronize];
    }
}


#pragma mark - PriceCalcualtion

+ (void)storePriceCaluclationHasPermission:(BOOL)hasPermission {
    [[NSUserDefaults standardUserDefaults] setBool:hasPermission forKey:@"GET_PRICE_PERMISSION"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void)removeGetPricePermission {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GET_PRICE_PERMISSION"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
+ (BOOL)canPerformGetPrice{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"GET_PRICE_PERMISSION"];
}
#pragma mark end

#pragma mark
+ (id)archiveObject:(id)objectToBeArchived {
   return [NSKeyedArchiver archivedDataWithRootObject:objectToBeArchived];
}
+ (id)unArchiveObject:(id)objecttoBeUnArchived {
    return [NSKeyedUnarchiver unarchiveObjectWithData:objecttoBeUnArchived];
}


+ (NSString *)reformedTokenFromRefreshToken:(NSString *)token
{
    // Yes, token should not be null and token length should be greater than split length
    if (([StringUtil isStringEmpty:token]) || (token.length < kRefreshTokenSplitIndex + 1)) {
        return token;
    }
    
    NSString * secondPartOfString  = [token substringFromIndex:kRefreshTokenSplitIndex];
    NSString * firstPartOfString   = [token substringToIndex:kRefreshTokenSplitIndex];

    NSMutableString *reformedString = [[NSMutableString alloc] initWithFormat:@"%@%@", secondPartOfString, firstPartOfString];
    
    return reformedString;
}


+ (NSString *)recreatedRefreshTokenFromStoredToken:(NSString *)storedToken
{
    // Yes, stored token should not be null and token length should be greater than split length
    if (([StringUtil isStringEmpty:storedToken]) || (storedToken.length < kRefreshTokenSplitIndex + 1)) {
        return storedToken;
    }

    NSUInteger range = storedToken.length - kRefreshTokenSplitIndex;
    
    NSString * secondPartOfString = [storedToken substringFromIndex:range];
    NSString * firstPartOfString   = [storedToken substringToIndex:range];
    
    NSMutableString *reconstructedToken = [[NSMutableString alloc] initWithFormat:@"%@%@", secondPartOfString, firstPartOfString];
    
    return reconstructedToken;
}


+ (void)setRefreshToken:(NSString*)refreshToken
{
    NSString *reformedToken = [self reformedTokenFromRefreshToken:refreshToken];
    
    if ([StringUtil isStringEmpty:reformedToken]) {
        reformedToken = kEmptyString;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:reformedToken
                                              forKey:kRefreshToken];
    [[NSUserDefaults standardUserDefaults]  synchronize];
}


+ (NSString*)getRefreshToken
{
    NSString *storedToken = [[NSUserDefaults standardUserDefaults] objectForKey:kRefreshToken];
    
    NSString *reconstructedToken = [self recreatedRefreshTokenFromStoredToken:storedToken];
    
    if ([StringUtil isStringEmpty:reconstructedToken]) {
        reconstructedToken = kEmptyString;
    }

    return reconstructedToken;
}


+(BOOL) shouldValidateAccessToken
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kPreferenceAccessToken] boolValue];
    
}



#pragma mark - Product IQ

+(NSString *)getProdIQDataSyncTime {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kPersistantStorageProdIQSyncTime];
}

+(void)storeProdIQDataSyncTime:(NSString *)time {
    if (time != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:time forKey:kPersistantStorageProdIQSyncTime];
        [[NSUserDefaults standardUserDefaults]  synchronize];
    }
}

+ (BOOL)enableAnalytics
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kEnableNewRelicAnalytics] boolValue];
}

@end
