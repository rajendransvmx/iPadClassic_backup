//
//  MobileDataUsageExecuter.m
//  ServiceMaxiPad
//
//  Created by Himanshi Sharma on 01/03/16.
//  Copyright © 2016 ServiceMax Inc. All rights reserved.
//

#import "MobileDataUsageExecuter.h"
#import "FileManager.h"
#import "CustomerOrgInfo.h"
#import "AppMetaData.h"
#import "SyncManager.h"

static  MobileDataUsageExecuter *instance;

@implementation MobileDataUsageExecuter

- (id)initWithParentView:(UIView *)newParentView
                andFrame:(CGRect)newFrame
{
    
   
    self = [super init];
    
    if (self != nil) {
        self.parentView = newParentView;
        instance = self;
        
        bridge = [[Bridge alloc]init];
        //    webview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 20, 1024,748)];
        [self createWebviewWithFrame:newFrame];
        
       
        
        nativeCallUrl = @"native-call://";
        clientId = @"3MVG9VmVOCGHKYBRKMhA_p09I93C_GY2N1wz8gvNtsZnJ0SE4cNbqfNLqBV5vFIT8E.Exhq8e0qBlRE3zezAb";
        callbackUrl = @"SVMX://";
        loginUrl = @"https://test.salesforce.com/services/oauth2/authorize?response_type=token&client_id=%@&redirect_uri=%@&display=touch&login_hint=shivaranjini@qa7.com.cfg2";
    }
    
      return self;
}


+(MobileDataUsageExecuter *)getInstance {
    return instance;
}

-(NSString *) getAccessToken {
    return [[CustomerOrgInfo sharedInstance] accessToken];
    //    return accessToken;
}

-(NSString *) getInstanceUrl {
    return [[CustomerOrgInfo sharedInstance] instanceURL];
    //    return instanceUrl;
}

-(UIWebView *)getBrowser
{
    return mdWebView;
}

-(void)execute
{
    [self loadMobileDataUsage];
}

#pragma mark -
#pragma mark Webview creation and loading

- (void)createWebviewWithFrame:(CGRect)newFrame {
    
     dispatch_sync(dispatch_get_main_queue(), ^{
        UIWebView *webview = [[UIWebView alloc]initWithFrame:newFrame];
        webview.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        mdWebView = webview;
        webview.delegate = self;
     });
}


-(void)loadMobileDataUsage
{
    accessToken = [[CustomerOrgInfo sharedInstance] accessToken];
    instanceUrl = [[CustomerOrgInfo sharedInstance] instanceURL];
    
    NSURL *url = [NSURL fileURLWithPath:[self htmlPath]];
    [mdWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

-(NSString *)htmlPath
{
    NSString *rootDir = [FileManager getRootPath];
    NSString *htmlfilepath = [rootDir stringByAppendingPathComponent:@"usage-index.html"];
    return htmlfilepath;
}

// START - webview events
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"Should start navigation" );
    NSString *url = request.URL.absoluteString;
    
    // if this is a native call
    BOOL isNativeCall = [url hasPrefix:nativeCallUrl];
    if(isNativeCall){
        [self handleNativeCall:url];
        return NO;
    }
    
    // if user is already athenticated
    if(authenticated) return YES;
    
    BOOL isSuccess = [url hasPrefix:[callbackUrl lowercaseString]];
    
    SXLogDebug(@"Checking for the callback prefix :%d", isSuccess);
    
    if(isSuccess == false){
        return YES;
    }
    
    authenticated = true;
    
    // user was successfully authenticated, load the app.
    [self startApplicationload:url];
    return NO;
    
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"Started Loading" );
    
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    NSLog(@"Finish Load ");
    
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"Failed to load with error :%@",[error debugDescription]);
    
}

- (void)handleNativeCall:(NSString *)url {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), [[SyncManager sharedInstance] getSyncErrorReportQueue], ^{
        [bridge invoke: url];
    });
}



- (void)startApplicationload:(NSString *)successUrl {
    
    NSURL *url = [NSURL fileURLWithPath:[self htmlPath]];
    
    //    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"installigence-index" ofType:@"html" inDirectory:@"www"]];
    
    NSURL *u = [[NSURL alloc]initWithString:successUrl];
    NSString *f = u.fragment;
    NSArray *p = [f componentsSeparatedByString:@"&"];
    NSString *item;
    for (item in p) {
        NSArray *itemData = [item componentsSeparatedByString:@"="];
        if([itemData[0] isEqualToString:@"access_token"]){
            accessToken = itemData[1];
        }else if([itemData[0] isEqualToString:@"instance_url"]){
            instanceUrl = itemData[1];
        }
    }
    
    [mdWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

// END - webview events

@end
