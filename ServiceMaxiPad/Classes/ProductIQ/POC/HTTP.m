//
//  HTTP.m
//  ProductIQ
//
//  Created by Indresh M S on 4/19/15.
//  Copyright (c) 2015 ServiceMax. All rights reserved.
//

#import "HTTP.h"
#import "ProductIQHomeViewController.h"

@implementation HTTP

-(void)callServer:(NSString *)params {
    NSString *accessToken = [[ProductIQHomeViewController getInstance] getAccessToken];
    NSString *instanceUrl = [[ProductIQHomeViewController getInstance] getInstanceUrl];
    
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
        NSLog(@"Unsupported method! %@", method);
        return;
    }
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate: self];
    responseData = [[NSMutableData alloc]init];
    
    [connection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data {
    [self->responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"HTTP Error! %@", [error localizedDescription]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *responseText = [[NSString alloc] initWithData:self->responseData encoding:NSUTF8StringEncoding];
    NSLog(@"didfinishLoading: %@",responseText);
    
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
    NSString *js = [NSString stringWithFormat:@"%@(%@)", methodNameLocal, resp];
    NSLog(@"&&& %@", js);
    [browser stringByEvaluatingJavaScriptFromString:js];
}
@end


