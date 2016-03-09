//
//  DB.m
//  ProductIQ
//
//  Created by Indresh M S on 4/19/15.
//  Copyright (c) 2015 ServiceMax. All rights reserved.
//

#import "DB.h"
#import "DBManager.h"
#import "ProductIQHomeViewController.h"
#import "MobileDataUsageExecuter.h"

@implementation DB

-(void)executeQuery:(NSString *)params {
    
    NSDictionary *d = [self parse:params];
    NSString *callback = d[@"nativeCallbackHandler"];
    NSString *requestId = d[@"requestId"];
    NSString *type = d[@"type"];
    NSString *methodName = d[@"methodName"];
    NSString *jsCallback = d[@"jsCallback"];
    NSString *query = d[@"query"];
    NSMutableArray *rows = [[DBManager getSharedInstance] executeQuery:query];
    NSMutableDictionary *resp = [[NSMutableDictionary alloc] init];
    [resp setObject:requestId forKey:@"requestId"];
    [resp setObject:type forKey:@"type"];
    [resp setObject:methodName forKey:@"methodName"];
    [resp setObject:rows forKey:@"rows"];
    [resp setObject:callback forKey:@"nativeCallbackHandler"];
    [resp setObject:jsCallback forKey:@"jsCallback"];
    [self respondOnMethod:callback withParams:resp];
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
    if (browser == nil)
    {
        browser = [[MobileDataUsageExecuter getInstance] getBrowser];
        
    }
    NSString *js = [NSString stringWithFormat:@"%@(%@)", methodName, resp];
    SXLogDebug(@"&&& %@", js);
    [browser stringByEvaluatingJavaScriptFromString:js];
}

@end
