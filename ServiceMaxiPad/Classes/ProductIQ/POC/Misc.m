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
    
    UIWebView *browser = [[ProductIQHomeViewController getInstance] getBrowser];
    NSString *js = [NSString stringWithFormat:@"%@(%@)", methodName, resp];
    SXLogDebug(@"&&& %@", js);
    [browser stringByEvaluatingJavaScriptFromString:js];
}

@end
