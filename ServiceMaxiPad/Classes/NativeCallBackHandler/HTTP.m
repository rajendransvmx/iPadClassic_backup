//
//  HTTP.m
//  ProductIQ
//
//  Created by Indresh M S on 4/19/15.
//  Copyright (c) 2015 ServiceMax. All rights reserved.
//

#import "HTTP.h"
#import "CustomerOrgInfo.h"
#import "MobileDataUsageExecuter.h"
#import "SMAppDelegate.h"
#import "SyncManager.h"

@implementation HTTP

/*
-(void)callServer:(NSString *)params {
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
    
    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",instanceUrl, uri]]
        cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
        timeoutInterval:120.0];
    
    [request setHTTPMethod:method];
    [request setValue:[NSString stringWithFormat:@"OAuth %@",accessToken] forHTTPHeaderField:@"Authorization"];
    
    if([method isEqual:@"GET"]){
        
    }else if([method isEqual:@"POST"]){
        NSData *bodyAsData = [body dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:bodyAsData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[bodyAsData length]]
                                forHTTPHeaderField:@"Content-Length"];
    }else{
        SXLogError(@"Unsupported method! %@", method);
        return;
    }
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate: self];
    responseData = [[NSMutableData alloc]init];
    
    [connection start];
}
 */

-(void)callServer:(NSString *)params {
    
    
    NSString *accessToken = [[CustomerOrgInfo sharedInstance] accessToken];
    NSString *instanceUrl = [[CustomerOrgInfo sharedInstance] instanceURL];
    
    instanceUrl = [instanceUrl stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    instanceUrl = [instanceUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    accessToken = [accessToken stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    accessToken = [accessToken stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *d = [self parse:params];
    NSString *uri = d[@"uri"];
    NSString *method;
    
    //NSString *body = d[@"body"];
    NSString *body;
    callback = d[@"nativeCallbackHandler"];
    requestId = d[@"requestId"];
    type = d[@"type"];
    methodName = d[@"methodName"];
    jsCallback = d[@"jsCallback"];
    
  
  
    
    BOOL isNonSalesforceURL;
    
    if (self.tempStr == nil)
    {
        self.tempStr = [NSMutableString string];
        
    }
    
    //Part2
    //RequestMethod":"POST","HttpRequestHeaders":"[{\"Header\":\"Referer\",\"Value\":\"ServiceMaxNow\"},{\"Header\":\"Content-Type\",\"Value\":\"application/json\"}]"}
    
    
    paramStr = d[@"parameterString"];
    totalPages = d[@"totalPages"];
    currentPage = d[@"currentPage"];
    
    if ([totalPages intValue] != [currentPage intValue])
    {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"tempStr"])
        {
            
            NSMutableString *appendStr = [[[NSUserDefaults standardUserDefaults]objectForKey:@"tempStr"]mutableCopy];
            [appendStr appendString:paramStr];
            [[NSUserDefaults standardUserDefaults]setObject:appendStr forKey:@"tempStr"];
            
        }
        else
        {
            [self.tempStr appendString:paramStr];
            [[NSUserDefaults standardUserDefaults]setObject:self.tempStr forKey:@"tempStr"];
        }
        
    }
    else
    {
        [[SyncManager sharedInstance] handleSyncCompletion];
        NSMutableString *finalStr = [[[NSUserDefaults standardUserDefaults]objectForKey:@"tempStr"]mutableCopy];
        if (finalStr == nil)
        {
            finalStr = [NSMutableString string];
        }
        [finalStr appendString:paramStr];
        paramStr = finalStr;
        NSDictionary *dict = [self parse:paramStr];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"tempStr"];
        uri = dict[@"Uri"];
        isNonSalesforceURL = (BOOL) dict[@"isNonSalesforceUrl"];
        body = dict[@"RequestBody"];
        method = dict[@"RequestMethod"];
        NSError *err = nil;
        NSArray *HttpRequestHeaders = (NSArray *)[NSJSONSerialization JSONObjectWithData:[dict[@"HttpRequestHeaders"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&err];
        
        if (method == nil)
        {
            method = @"POST";
        }
        
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
      
        
        
        if([method isEqual:@"GET"]){
            
        }else if([method isEqual:@"POST"]){
            NSData *bodyAsData = [body dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:bodyAsData];
            
            NSLog(@"Final http data Size in bytes : %lu,", (unsigned long)[bodyAsData length]);

            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            for (NSDictionary *headerDict in HttpRequestHeaders)
            {
                
                NSString *headerField = [headerDict objectForKey:@"Header"];
                NSString *headerValue = [headerDict objectForKey:@"Value"];
                if ([headerField isEqual:@"Content-Type"]) {
                    continue;
                }
                if (headerValue)
                {
                    [request setValue:headerValue forHTTPHeaderField:headerField];

                }
            }
            [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[bodyAsData length]]
           forHTTPHeaderField:@"Content-Length"];
        }else{
            SXLogError(@"Unsupported method! %@", method);
            return;
        }
        
        //check here ....
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate: self];
            responseData = [[NSMutableData alloc]init];
            
            [connection start];
        });
        
        
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data {
    [self->responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *responseText = [[NSString alloc] initWithData:self->responseData encoding:NSUTF8StringEncoding];
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIWebView *browser = [[MobileDataUsageExecuter getInstance] getBrowser];

        NSString *js = [NSString stringWithFormat:@"%@(%@)", methodNameLocal, resp];
        [browser stringByEvaluatingJavaScriptFromString:js];

    });
}
@end


