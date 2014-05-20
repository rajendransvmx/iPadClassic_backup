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
#import "SFHFKeychainUtils.h"
#import "AppManager.h"
#import "StringUtil.h"


static NSString *const kEmptyString                  = @"";

static NSString *const kOAuthResponseUserId          = @"user_id";
static NSString *const kOAuthResponseUserName        = @"username";
static NSString *const kOAuthResponseUserLanguage    = @"language";
static NSString *const kOAuthResponseUserOrgId       = @"organization_id";
static NSString *const kOAuthResponseUserDisplayName = @"display_name";

static NSString *const kOAuthResponseAccessToken    = @"access_token";
static NSString *const kOAuthResponseIdentityURL    = @"id";
static NSString *const kOAuthResponseRefreshToken   = @"refresh_token";


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
static NSString *const kPersistanceStoreUserStatus      = @"ps_usr_st";

static NSString *const kPersistanceStoreServerPackage   = @"ps_cur_srvr_pkg";
static NSString *const kPersistanceStoreApiUrl          = @"ps_cur_api_url";
static NSString *const kPersistanceStoreInstanceUrl     = @"ps_cur_instance_url";

static NSString *const kPersistanceStorePreferenceId    = @"preference_identifier";
static NSString *const kPersistanceStoreCustomUrl       = @"custom_url";

static NSString *const kPersistanceStoreLastPreferenceId = @"ps_last_pr_id";
static NSString *const kPersistanceStoreLastUserName     = @"ps_last_usr_name";

/* Login URLs for different platform */
static NSString *const kProductionOrg     = @"https://login.salesforce.com";
static NSString *const kSandboxOrg        = @"https://test.salesforce.com";
static NSString *const kDefaultBaseOrg    = @"https://www.salesforce.com";


/** Public constant declaration */

NSString *const kPreferenceIdentifier  = @"preference_identifier";

NSString *const kPreferenceOrganizationCustom  = @"Custom";
NSString *const kPreferenceOrganizationSandbox  = @"Sandbox";
NSString *const kPreferenceOrganizationProduction  = @"Production";


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
            NSLog(@" preferenceSpecification - %@ ", [preferenceSpecification description]);
            
            /** Must use 'Key' to get the key-value */
            NSString *key = [preferenceSpecification objectForKey:@"Key"];
            
            if (key != nil)
            {
                [defaultsToRegister setObject:[preferenceSpecification objectForKey:@"DefaultValue"] forKey:key];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
        [defaultsToRegister release];
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
    NSString *plistFilePath = [FileManager getFilePathForPlist:plistFileName];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistFilePath];
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
    
    NSLog(@" saveCustomerOrganisationInfo ");
    [[CustomerOrgInfo sharedInstance] explainMe];
}


+ (void)saveCallBackInformation:(NSDictionary *)infoDictionary
{
    NSLog(@"  infoDictionary :%@", infoDictionary);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *accessToken  = [infoDictionary objectForKey:kOAuthResponseAccessToken];
    NSString *identityURL  = [infoDictionary objectForKey:kOAuthResponseIdentityURL];
    NSString *refreshToken = [infoDictionary objectForKey:kOAuthResponseRefreshToken];

    accessToken  = [accessToken stringByReplacingOccurrencesOfString:@"%21" withString:@"!"];
    
    refreshToken = [refreshToken stringByReplacingOccurrencesOfString:@"%3D" withString:@"="];
    
    identityURL  = [identityURL stringByReplacingOccurrencesOfString:@"%3A" withString:@":"];
    identityURL  = [identityURL stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
    
    [userDefaults setObject:identityURL forKey:kPersistanceStoreIdentityUrl];
    [userDefaults setObject:accessToken forKey:kPersistanceStoreAccessToken];
    
    [userDefaults synchronize];
    
    /*** Lets remove existing refresh token and store new one in key chain utils. */
    [SFHFKeychainUtils deleteRefreshToken];
    [SFHFKeychainUtils storeRefreshToken:refreshToken];
    
    [[CustomerOrgInfo sharedInstance] setRefreshToken:refreshToken];
    [[CustomerOrgInfo sharedInstance] setAccessToken:accessToken];
    [[CustomerOrgInfo sharedInstance] setIdentityURL:identityURL];
    
    NSLog(@" save call back information ======== \n ");
    [[CustomerOrgInfo sharedInstance] explainMe];
}


+ (NSString *)userLanguage
{
   NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
   return [userDefaults valueForKey:kPersistanceStoreUserLanguage];
}


+ (NSString *)serverURL
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:API_URL];
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
    
    [[CustomerOrgInfo sharedInstance] setRefreshToken:[SFHFKeychainUtils getRefreshToken]];

    NSLog(@" ----------------- org reloading ----------- ");
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
       
        NSString *customURL = [defaults valueForKey:@"custom_url"];
        
		if ( ([customURL hasPrefix:@"http://"]) || ([customURL hasPrefix:@"https://"]) )
        {
            // Yes, network protocol like http or https has added. Good to go
        }
		else
        {
			customURL = [NSString stringWithFormat:@"https://%@",customURL];
        }
        
        [self storeCustomURLString:customURL];
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


@end
