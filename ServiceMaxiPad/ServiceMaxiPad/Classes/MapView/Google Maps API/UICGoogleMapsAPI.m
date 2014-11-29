//
//  UICGoogleMapsAPI.m
//  ServiceMaxMobile
//
//  Created by Anoop on 9/15/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "UICGoogleMapsAPI.h"

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
    if ([jsonData length])
	    JSONValue = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
	
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

- (void) dealloc {
    self.delegate = nil;
}

@end