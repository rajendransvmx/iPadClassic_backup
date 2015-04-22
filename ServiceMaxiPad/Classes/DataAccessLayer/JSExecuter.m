//
//  JSExecuter.m
//  JavascriptInterface
//
//  Created by Shravya shridhar on 2/15/13.
//  Copyright (c) 2013 Shravya shridhar. All rights reserved.
//

#import "JSExecuter.h"
#import "SVMXDatabaseMaster.h"
#import "Utility.h"

#define kDataRequest @"darequest"

@interface JSExecuter()

- (void)createWebviewWithFrame:(CGRect)newFrame ;
- (void)passEventToDelegate:(NSURL *)absoluteUrl andScheme:(NSString *)scheme;

@end

@implementation JSExecuter

#pragma mark-
#pragma mark Init method
- (id)initWithParentView:(UIView *)newParentView
          andCodeSnippet:(NSString *)newCodeSnippet
             andDelegate:(id)newDelegate
                andFrame:(CGRect)newFrame  {
    
    if (newParentView == nil) {
       
        self = nil;
        return nil;
    }
    self = [super init];
    self.jsWebView.backgroundColor = [UIColor whiteColor];
    if (self != nil) {
        
        self.codeSnippet = newCodeSnippet;
        self.parentView = newParentView;
        self.delegate = newDelegate;
        [self createWebviewWithFrame:newFrame];

       
        
        if (newCodeSnippet != nil && newCodeSnippet.length > 3) {
            [self executeJavascriptCode:newCodeSnippet];
        }
    }
    return self;
}

- (id)initWithParentView:(UIView *)newParentView andCodeSnippet:(NSString *)newCodeSnippet andDelegate:(id)newDelegate {
    
    if (newParentView == nil) {
        self = nil;
        return nil;
    }
    self = [super init];
    if (self != nil) {
        
        self.codeSnippet = newCodeSnippet;
        self.parentView = newParentView;
        self.delegate = newDelegate;
        [self createWebviewWithFrame:CGRectZero]; //shravya Getprice
        
        if (newCodeSnippet != nil && newCodeSnippet.length > 3) {
            [self executeJavascriptCode:newCodeSnippet];
        }
    }
    return self;
}

#pragma mark -
#pragma mark Webview creation and loading 

- (void)createWebviewWithFrame:(CGRect)newFrame {
    
    UIWebView *webview = [[UIWebView alloc]initWithFrame:newFrame];
    webview.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.jsWebView = webview;
    webview.delegate = self;
    [self.parentView addSubview:webview];
    webview = nil;
}

- (void)executeJavascriptCode:(NSString *)jsCodeSnippet {
    //NSString *urlString =  [[NSBundle mainBundle]pathForResource:@"HomePage" ofType:@"html"];
   // NSURL *mainUrl =  [NSURL fileURLWithPath:urlString];
   // [self.jsWebView loadRequest:[NSURLRequest requestWithURL:mainUrl]];
    [self.jsWebView loadHTMLString:jsCodeSnippet baseURL:[[NSBundle mainBundle]resourceURL]];
}

- (void)loadHTMLFileFromPath:(NSString *)htmlFilePath
{
    [self.jsWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlFilePath]]];
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
    
    NSString *parameterString =  [[absoluteUrl absoluteString] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@://params?",scheme] withString:@""];
    NSString *paramString=  [parameterString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if ([scheme hasPrefix:kDataRequest]) {
        
        if (paramString == nil) {
            paramString = @"";
        }
        NSDictionary *parmDict =  [NSDictionary dictionaryWithObjectsAndKeys:paramString,@"param",scheme,@"scheme",nil];
        [self performSelectorOnMainThread:@selector(passPreRegisteredEventWithData:) withObject:parmDict waitUntilDone:NO];
    }
    else {
        if ([self.delegate conformsToProtocol:@protocol(JSExecuterDelegate)]) {
            [self.delegate eventOccured:scheme andParameter:paramString];
        }
    }
}
 
#pragma mark -
#pragma mark Webview delegates
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
   
    NSString *scheme = [[request URL] scheme];
    BOOL shouldConinue = [self shouldContiueLoading:scheme];
     SXLogInfo(@"Scheme is %@",scheme);
    if (!shouldConinue) {
        
        /* Pass the event to delegate with request */
        [self passEventToDelegate:[request URL] andScheme:scheme];
    }
    return shouldConinue;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    SXLogDebug(@"webViewDidStartLoad");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
     SXLogDebug(@"webViewDidFinishLoad");
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    SXLogError(@"Error: %@",[error description]);
}

#pragma mark -
#pragma mark Interaction with webview 
- (NSString *)response:(NSString *)responseJsonString   forEventName:(NSString *)eventName{
    
    NSString *function = nil;
    if ([eventName isEqualToString:@"pricebook"]) {
        function =  [[NSString alloc] initWithFormat:@"$EXPR.responseReceivedForEventName(\"%@\",%@)",eventName,responseJsonString];
    }
    else{
        function =  [[NSString alloc] initWithFormat:@"$COMM.responseReceivedForEventName(\"%@\",%@)",eventName,responseJsonString];
    }
    NSString *result = [self.jsWebView stringByEvaluatingJavaScriptFromString:function];
    return result;
}


#pragma mark - Pre registered event
- (void)passPreRegisteredEventWithData:(NSDictionary *)parameterDict {
    
    NSString *paramString = [parameterDict objectForKey:@"param"];
    NSString *eventName = [parameterDict objectForKey:@"scheme"];
    NSString *responseData = [[SVMXDatabaseMaster sharedDataBaseMaterObject] getDataForParams:paramString andEventName:eventName];
    NSString *eventt =  [self response:responseData forEventName:eventName];
    SXLogInfo(@"Return value is %@",eventt);
}

@end
