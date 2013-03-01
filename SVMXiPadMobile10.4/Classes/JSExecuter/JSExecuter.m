//
//  JSExecuter.m
//  JavascriptInterface
//
//  Created by Shravya shridhar on 2/15/13.
//  Copyright (c) 2013 Shravya shridhar. All rights reserved.
//

#import "JSExecuter.h"

@interface JSExecuter()

- (void)createWebview;
- (void)passEventToDelegate:(NSURL *)absoluteUrl andScheme:(NSString *)scheme;

@end

@implementation JSExecuter

@synthesize jsWebView;
@synthesize codeSnippet;
@synthesize delegate;
@synthesize parentView;

- (void)dealloc {
    [jsWebView release];
    [codeSnippet release];
    delegate = nil;
    [parentView release];
    [super dealloc];
}

#pragma mark-
#pragma mark Init method
- (id)initWithParentView:(UIView *)newParentView andCodeSnippet:(NSString *)newCodeSnippet andDelegate:(id)newDelegate {
    
    if (newParentView == nil) {
        [self release];
        self = nil;
        return nil;
    }
    self = [super init];
    if (self != nil) {
        
        [self createWebview];
        self.codeSnippet = newCodeSnippet;
        self.parentView = newParentView;
        self.delegate = newDelegate;
        
        if (newCodeSnippet != nil && newCodeSnippet.length > 3) {
            [self executeJavascriptCode:newCodeSnippet];
        }
    }
    return self;
}

#pragma mark -
#pragma mark Webview creation and loading 

- (void)createWebview {
    
    UIWebView *webview = [[UIWebView alloc]initWithFrame:CGRectZero];
    self.jsWebView = webview;
    webview.delegate = self;
    [self.parentView addSubview:webview];
    [webview release];
    webview = nil;
}

- (void)executeJavascriptCode:(NSString *)jsCodeSnippet {
    //NSString *urlString =  [[NSBundle mainBundle]pathForResource:@"HomePage" ofType:@"html"];
   // NSURL *mainUrl =  [NSURL fileURLWithPath:urlString];
   // [self.jsWebView loadRequest:[NSURLRequest requestWithURL:mainUrl]];
    [self.jsWebView loadHTMLString:jsCodeSnippet baseURL:[[NSBundle mainBundle]resourceURL]];
}

#pragma mark-
#pragma mark utility methods
- (BOOL)shouldContiueLoading:(NSString *)scheme {
    
    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"] || [scheme isEqualToString:@"file"] || [scheme isEqualToString:@"about"] || scheme.length <= 3) {
        return YES;
    }
    return NO;
}

- (void)passEventToDelegate:(NSURL *)absoluteUrl andScheme:(NSString *)scheme {
    
    if ([delegate conformsToProtocol:@protocol(JSExecuterDelegate)]) {
        
        NSString *parameterString =  [[absoluteUrl absoluteString] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@://params?",scheme] withString:@""];
        NSString *paramString=  [parameterString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [self.delegate eventOccured:scheme andParameter:paramString];
    }
}
 
#pragma mark -
#pragma mark Webview delegates
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
   
    NSString *scheme = [[request URL] scheme];
    BOOL shouldConinue = [self shouldContiueLoading:scheme];
     NSLog(@"Scheme is %@",scheme);
    if (!shouldConinue) {
        
        /* Pass the event to delegate with request */
        [self passEventToDelegate:[request URL] andScheme:scheme];
    }
    return shouldConinue;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
     NSLog(@"webViewDidFinishLoad");
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"Error: %@",[error description]);
}

#pragma mark -
#pragma mark Interaction with webview 
- (NSString *)response:(NSString *)responseJsonString   forEventName:(NSString *)eventName{
    
    NSString *function =  [[[NSString alloc] initWithFormat:@"$EXPR.responseReceivedForEventName(\"%@\",%@)",eventName,responseJsonString] autorelease];
    NSString *result = [jsWebView stringByEvaluatingJavaScriptFromString:function];
    return result;
}

@end
