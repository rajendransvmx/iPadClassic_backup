//
//  Utils.m
//  ProductIQ
//
//  Created by Indresh M S on 4/19/15.
//  Copyright (c) 2015 ServiceMax. All rights reserved.
//

#import "Utils.h"
#import "ProductIQPOCHomeViewController.h"

@implementation Utils

-(void)respondWithLoginDetails:(NSString *)params {
    NSString *accessToken = [[ProductIQPOCHomeViewController getInstance] getAccessToken];
    NSString *instanceUrl = [[ProductIQPOCHomeViewController getInstance] getInstanceUrl];
    NSMutableDictionary *resp = [[NSMutableDictionary alloc] init];
    [resp setObject:accessToken forKey:@"access_token"];
    [resp setObject:instanceUrl forKey:@"instance_url"];
    
    NSDictionary *d = [self parse:params];
    NSString *methodName = d[@"callback"];
    
    [self respondOnMethod:methodName withParams:resp];
    
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
    
    UIWebView *browser = [[ProductIQPOCHomeViewController getInstance] getBrowser];
    [browser stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)", methodName, resp]];
}

@end
