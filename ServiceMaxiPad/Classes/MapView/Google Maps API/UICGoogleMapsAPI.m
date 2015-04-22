//
//  UICGoogleMapsAPI.m
//  ServiceMaxMobile
//
//  Created by Anoop on 9/15/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "UICGoogleMapsAPI.h"
#import "AlertMessageHandler.h"
#import "ResponseConstants.h"
#import "TagManager.h"
#import "TagConstant.h"
#import "AppManager.h"

@interface UIWebView(JavaScriptEvaluator)

- (void)webView:(UIWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame;

@end


@implementation UICGoogleMapsAPI

- (id)init
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
		self.delegate = self;
		[self makeAvailable];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Nothing to do.
}

- (void)makeAvailable {

    NSString *path = [[NSBundle mainBundle] pathForResource:@"api" ofType:@"html"];
    NSError * error = nil;
    NSString * htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *bundlePath = [bundle bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:bundlePath];
   [self loadHTMLString:htmlString baseURL:baseURL];
    path = nil;
    error = nil;
    htmlString = nil;
    bundle = nil;
    bundlePath = nil;
    baseURL = nil;
}

- (void)webView:(UIWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame {
    
    NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
    id JSONValue = nil;
    if (jsonData != nil && ![jsonData isKindOfClass:[NSNull class]])
    {
        JSONValue = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
        
        if (JSONValue != nil && ![JSONValue isKindOfClass:[NSNull class]])
        {
            NSString *errorString = [JSONValue valueForKey:@"error"];
            if (errorString != nil && ![errorString isKindOfClass:[NSNull class]])
            {
                if ([[AppManager sharedInstance] currentSelectedTab] == 0 || [[AppManager sharedInstance] currentSelectedTab] == 1)
                {
                    [self showErrorMessage:errorString];
                }
                return;
            }
        }
    }
    
    if (!JSONValue) {
		if ([self.delegate respondsToSelector:@selector(goolgeMapsAPI:didFailWithMessage:)]) {
            SXLogError(@"Google api failed:%@",message);
			[(id<UICGoogleMapsAPIDelegate>)self.delegate goolgeMapsAPI:self didFailWithMessage:message];
		}
		return;
	}
	if ([self.delegate respondsToSelector:@selector(goolgeMapsAPI:didGetObject:)]) {
		[(id<UICGoogleMapsAPIDelegate>)self.delegate goolgeMapsAPI:self didGetObject:JSONValue];
	}
    jsonData = nil;
    JSONValue = nil;
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)showErrorMessage:(NSString*)errorString
{
    if ([errorString isEqualToString:kMapErrorNotFound])
    {
        [[AlertMessageHandler sharedInstance] showCustomMessage:@"At least one of the locations specified in the request's origin, destination, or waypoints could not be geocoded." withDelegate:self title:[[TagManager sharedInstance] tagByName:KTagAlertResponceError] cancelButtonTitle:[[TagManager sharedInstance] tagByName:kTagAlertErrorOk] andOtherButtonTitles:nil];
    }
    else if ([errorString isEqualToString:kMapErrorZeroResults])
    {
        [[AlertMessageHandler sharedInstance] showCustomMessage:@"No route could be found between the origin and destination." withDelegate:self title:[[TagManager sharedInstance] tagByName:KTagAlertResponceError] cancelButtonTitle:[[TagManager sharedInstance] tagByName:kTagAlertErrorOk] andOtherButtonTitles:nil];
    }
    else if ([errorString isEqualToString:kMapErrorWayPointsExceeded])
    {
        [[AlertMessageHandler sharedInstance] showCustomMessage:@"Too many DirectionsWaypoints were provided, Waypoints are not supported for transit directions." withDelegate:self title:[[TagManager sharedInstance] tagByName:KTagAlertResponceError] cancelButtonTitle:[[TagManager sharedInstance] tagByName:kTagAlertErrorOk] andOtherButtonTitles:nil];
    }
    else if ([errorString isEqualToString:kMapErrorInvalidRequest])
    {
        [[AlertMessageHandler sharedInstance] showCustomMessage:@"Invalid requests that are missing either an origin or destination, or a transit request that includes waypoints." withDelegate:self title:[[TagManager sharedInstance] tagByName:KTagAlertResponceError] cancelButtonTitle:[[TagManager sharedInstance] tagByName:kTagAlertErrorOk] andOtherButtonTitles:nil];
    }
    else if ([errorString isEqualToString:kMapErrorOverQueryLimit])
    {
        [[AlertMessageHandler sharedInstance] showCustomMessage:@"Your device has sent too many requests within the allowed time period." withDelegate:self title:[[TagManager sharedInstance] tagByName:KTagAlertResponceError] cancelButtonTitle:[[TagManager sharedInstance] tagByName:kTagAlertErrorOk] andOtherButtonTitles:nil];
    }
    else if ([errorString isEqualToString:kMapErrorRequestDenied])
    {
        [[AlertMessageHandler sharedInstance] showCustomMessage:@"Your device is not allowed to use the directions service." withDelegate:self title:[[TagManager sharedInstance] tagByName:KTagAlertResponceError] cancelButtonTitle:[[TagManager sharedInstance] tagByName:kTagAlertErrorOk] andOtherButtonTitles:nil];
    }
    else //if([errorString isEqualToString:kMapErrorUnknownError])
    {
        [[AlertMessageHandler sharedInstance] showCustomMessage:@"Your request could not be processed due to a server error. The request may succeed if you try again." withDelegate:self title:[[TagManager sharedInstance] tagByName:KTagAlertResponceError] cancelButtonTitle:[[TagManager sharedInstance] tagByName:kTagAlertErrorOk] andOtherButtonTitles:nil];
    }
}

- (void) dealloc {
    self.delegate = nil;
}

@end