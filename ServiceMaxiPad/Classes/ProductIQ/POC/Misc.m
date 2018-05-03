//
//  Misc.m
//  ServiceMaxiPad
//
//  Created by Rahman Sab C on 02/10/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "Misc.h"
#import "ProductIQHomeViewController.h"
#import "SNetworkReachabilityManager.h"
#import "CustomerOrgInfo.h"
#import "MobileDataUsageExecuter.h"

@implementation Misc

- (void)checkNetworkReachability:(NSString*)params {
    
    @autoreleasepool {
        NSDictionary *requestParams = [self parse:params];
        NSString *callback = requestParams[@"nativeCallbackHandler"];
        NSString *requestId = requestParams[@"requestId"];
        NSString *type = requestParams[@"type"];
        NSString *methodName = requestParams[@"methodName"];
        NSString *jsCallback = requestParams[@"jsCallback"];
        
        BOOL isNetworkReachable = [[SNetworkReachabilityManager sharedInstance] isNetworkReachable];
        NSMutableDictionary *networkDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        [networkDictionary setObject:[NSNumber numberWithBool:isNetworkReachable] forKey:@"ResultAsString"];
        [networkDictionary setObject:[NSNumber numberWithBool:isNetworkReachable] forKey:@"IsSuccessful"];
        
        
        NSMutableDictionary *responseDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        [responseDictionary setObject:requestId forKey:@"requestId"];
        [responseDictionary setObject:type forKey:@"type"];
        [responseDictionary setObject:methodName forKey:@"methodName"];
        [responseDictionary setObject:callback forKey:@"nativeCallbackHandler"];
        [responseDictionary setObject:jsCallback forKey:@"jsCallback"];
        [responseDictionary setObject:networkDictionary forKey:@"networkStatus"];
        [self respondOnMethod:callback withParams:responseDictionary];

    }
    
}
- (void)getLoginUserInfo:(NSString*)params {
    @autoreleasepool {
        NSDictionary *requestParams = [self parse:params];
        NSString *callback = requestParams[@"nativeCallbackHandler"];
        NSString *requestId = requestParams[@"requestId"];
        NSString *type = requestParams[@"type"];
        NSString *methodName = requestParams[@"methodName"];
        NSString *operation = requestParams[@"operation"];
        NSString *jsCallback = requestParams[@"jsCallback"];
        
        NSMutableDictionary *loginUserInfoDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        NSString *userName = [CustomerOrgInfo sharedInstance].userName;
        NSString *userDisplayName = [CustomerOrgInfo sharedInstance].userDisplayName;
        
        if (userName != nil) {
            [loginUserInfoDictionary setObject:userName forKey:@"userName"];
        }
        if (userDisplayName != nil) {
            [loginUserInfoDictionary setObject:userDisplayName forKey:@"userDisplayName"];
        }
        //Added below values for SyncErrorReporting
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        //[loginUserInfoDictionary setObject:@"00DZ00012005JD6MAM" forKey:@"OrgId"];
        [loginUserInfoDictionary setObject:[userDefaults objectForKey:@"ps_organization_id"] forKey:@"OrgId"];
        
        [loginUserInfoDictionary setObject:appVersion forKey:@"AppVersion"];
        [loginUserInfoDictionary setObject:[userDefaults objectForKey:@"ps_cur_username"] forKey:@"UserName"];
        [loginUserInfoDictionary setObject:[userDefaults objectForKey:@"ps_language"] forKey:@"Language"];
        [loginUserInfoDictionary setObject:@"" forKey:@"IsSyncOnLogin"];
        [loginUserInfoDictionary setObject:@"" forKey:@"TimeZone"];
        [loginUserInfoDictionary setObject:@"" forKey:@"Locale"];
        [loginUserInfoDictionary setObject:[userDefaults objectForKey:@"ps_loggedIn_user_id"] forKey:@"UserID"];//SFUserID

        [loginUserInfoDictionary setObject:[userDefaults valueForKey:@"preference_identifier"] forKey:@"EnvDefault"];
        [loginUserInfoDictionary setObject:@"" forKey:@"EnvTag"];
        [loginUserInfoDictionary setObject:@"" forKey:@"TimeZoneOffSet"];
         //Hs SyncReporting additional values ends here..

        
        NSMutableDictionary *responseDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        [responseDictionary setObject:requestId forKey:@"requestId"];
        [responseDictionary setObject:type forKey:@"type"];
        [responseDictionary setObject:methodName forKey:@"methodName"];
        if (operation != nil) {
            [responseDictionary setObject:operation forKey:@"operation"];
        }
        [responseDictionary setObject:callback forKey:@"nativeCallbackHandler"];
        [responseDictionary setObject:jsCallback forKey:@"jsCallback"];
        [responseDictionary setObject:loginUserInfoDictionary forKey:@"loginUserInfo"];
        [self respondOnMethod:callback withParams:responseDictionary];
    }
}

-(NSDictionary *)parse:(NSString *) str {
    NSError *error = nil;
    NSDictionary *ret =
    [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    return ret;
}

-(void)respondOnMethod:(NSString *) methodName withParams:(NSDictionary *)params {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    NSString *resp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
     dispatch_async(dispatch_get_main_queue(), ^{
        UIWebView *browser = [[ProductIQHomeViewController getInstance] getBrowser];
        if (browser == nil)
        {
            browser = [[MobileDataUsageExecuter getInstance] getBrowser];
        }
        NSString *js = [NSString stringWithFormat:@"%@(%@)", methodName, resp];
        [browser stringByEvaluatingJavaScriptFromString:js];

     });
}

@end
