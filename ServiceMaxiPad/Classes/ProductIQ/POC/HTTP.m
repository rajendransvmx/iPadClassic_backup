//
//  HTTP.m
//  ProductIQ
//
//  Created by Indresh M S on 4/19/15.
//  Copyright (c) 2015 ServiceMax. All rights reserved.
//

#import "HTTP.h"
#import "ProductIQHomeViewController.h"
#import "CustomerOrgInfo.h"
#import "MobileDataUsageExecuter.h"

@implementation HTTP

-(void)callServer:(NSString *)params {
    //NSString *accessToken = [[ProductIQHomeViewController getInstance] getAccessToken];
    //NSString *instanceUrl = [[ProductIQHomeViewController getInstance] getInstanceUrl];
    
    NSString *accessToken = [[CustomerOrgInfo sharedInstance] accessToken];
    NSString *instanceUrl = [[CustomerOrgInfo sharedInstance] instanceURL];
    
    instanceUrl = [instanceUrl stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    instanceUrl = [instanceUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    accessToken = [accessToken stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    accessToken = [accessToken stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *d = [self parse:params];
    NSString *uri = d[@"uri"];
    NSString *method = d[@"method"];
    NSString *body = d[@"body"];
    callback = d[@"nativeCallbackHandler"];
    requestId = d[@"requestId"];
    type = d[@"type"];
    methodName = d[@"methodName"];
    jsCallback = d[@"jsCallback"];
    NSArray *HttpRequestHeaders = d[@"httpRequestHeaders"];
    BOOL isNonSalesforceURL = (BOOL) d[@"isNonSalesforceUrl"];
    
    NSMutableURLRequest *request = nil;
    if (isNonSalesforceURL)
    {
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",uri]]
                                          cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                      timeoutInterval:120.0];
    }
    else{
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",instanceUrl, uri]]
                                          cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                      timeoutInterval:120.0];
        [request setValue:[NSString stringWithFormat:@"OAuth %@",accessToken] forHTTPHeaderField:@"Authorization"];
    }
    
    [request setHTTPMethod:method];
    /*for (NSDictionary *headerDict in HttpRequestHeaders)
     {
     
     NSString *headerField = [headerDict objectForKey:@"Header"];
     NSString *headerValue = [headerDict objectForKey:@"Value"];
     if ([headerField isEqual:@"Content-Type"]) {
     continue;
     }
     [request setValue:headerValue forHTTPHeaderField:headerField];
     }*/
    
    
    if([method isEqual:@"GET"]){
        
    }else if([method isEqual:@"POST"]){
        NSData *bodyAsData = [body dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:bodyAsData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"ServiceMaxNow" forHTTPHeaderField:@"referer"];//Hardcoded, need to take dynamic from HTTPRequestHeader
        [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[bodyAsData length]]
       forHTTPHeaderField:@"Content-Length"];
    }else{
        SXLogError(@"Unsupported method! %@", method);
        return;
    }
    
    //check here ....
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate: self];
    responseData = [[NSMutableData alloc]init];
    
    [connection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data {
    [self->responseData appendData:data];
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    SXLogError(@"HTTP Error! %@", [error localizedDescription]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *responseText = [[NSString alloc] initWithData:self->responseData encoding:NSUTF8StringEncoding];
    SXLogDebug(@"didfinishLoading: %@",responseText);
    
    NSMutableDictionary *resp = [[NSMutableDictionary alloc] init];
    [resp setObject:self->requestId forKey:@"requestId"];
    [resp setObject:self->type forKey:@"type"];
    [resp setObject:self->methodName forKey:@"methodName"];
    [resp setObject:self->callback forKey:@"nativeCallbackHandler"];
    [resp setObject:self->jsCallback forKey:@"jsCallback"];
    [resp setObject:responseText forKey:@"responseText"];
    [self respondOnMethod:callback withParams:resp];
}

-(NSDictionary *)parse:(NSString *) str {
    NSError *error = nil;
    NSDictionary *ret =
    [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    return ret;
}

-(void)respondOnMethod:(NSString *) methodNameLocal withParams:(NSDictionary *)params {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    NSString *resp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    UIWebView *browser = [[ProductIQHomeViewController getInstance] getBrowser];
    if (browser == nil)
    {
        browser = [[MobileDataUsageExecuter getInstance] getBrowser];
        
    }
    NSString *js = [NSString stringWithFormat:@"%@(%@)", methodNameLocal, resp];
    SXLogDebug(@"&&& %@", js);
    [browser stringByEvaluatingJavaScriptFromString:js];
    
    browser = nil;
    
}
@end


