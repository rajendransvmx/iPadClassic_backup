//
//  OAuthLoginViewController.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 4/3/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//
/**
 *  @file   OAuthLoginViewController.m
 *  @class  OAuthLoginViewController
 *
 *  @brief  Load OAuth authentication page.
 *
 *
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import "OAuthLoginViewController.h"
#import "PlistManager.h"
#import "StringUtil.h"
#import "SNetworkReachabilityManager.h"
#import "AppManager.h"
#import "OAuthService.h"
#import "SMAppDelegate.h"
#import "AlertMessageHandler.h"
#import "TagManager.h"
#import "MBProgressHUD.h"
#import "OauthConnectionHandler.h"

@interface OAuthLoginViewController ()
{
    BOOL loadFailedBool;
}

@property (nonatomic, strong)UIWebView *webview;
@property (nonatomic, strong)UIImageView *servicemaxLogo;
@property (nonatomic, strong)MBProgressHUD *HUD;
@property (nonatomic) CFTimeInterval startTime;

- (void)addActivityAndLoadingLabel;
- (void)removeActivityAndLoadingLabel;

- (void)addServiceMaxLogo;
- (void)removeServiceMaxLogo;

@end

@implementation OAuthLoginViewController

NSInteger webViewLoadCounter;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:42.0/255.0 green:148.0/255.0 blue:214.0/255.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)addServiceMaxLogo
{
    if (self.servicemaxLogo == nil)
    {
        self.servicemaxLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-servicemax-logo.png"]];
    }
    //CGFloat imageWidth = 350;
    CGFloat imageHeight = 66;
    //rectForImageLogo.origin = CGPointMake(self.view.bounds.size.width-imageWidth, 0);
    //rectForImageLogo.origin = CGPointMake(self.view.center.x-(imageWidth/2), 0);
    //rectForImageLogo.size = CGSizeMake(imageWidth, imageHeight);
    CGRect rectForImageLogo = CGRectMake(0, 20, self.view.bounds.size.width,imageHeight);
    self.servicemaxLogo.frame = rectForImageLogo;
    self.servicemaxLogo.contentMode = UIViewContentModeScaleAspectFit;
    self.servicemaxLogo.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.servicemaxLogo.layer.borderColor = [UIColor greenColor].CGColor;
	[self.view addSubview:self.servicemaxLogo];
}


- (void)removeServiceMaxLogo
{
    if (self.servicemaxLogo != nil)
    {
        [self.servicemaxLogo removeFromSuperview];
        self.servicemaxLogo = nil;
    }
}

/*
 1. User Authorization Request
 2. VerifyAuthorization Access code
 */

- (void)makeUserAuthorizationRequest
{
    [OAuthService deleteSalesForceCookies];
    
    [[AppManager sharedInstance] setApplicationStatus:ApplicationStatusInAuthenticationPage];
    
    @autoreleasepool {
        
        if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
        {
            // If webview exist lets remove it from the view
            if (self.webview)
            {
                self.webview.delegate = nil;
                [self.webview removeFromSuperview];
                webViewLoadCounter = 0;
                self.webview = nil;
            }
            CGRect viewRect = self.view.bounds;
            viewRect.origin.y = 86; //Space for servicemaxlogo.
            //defect 23630: As Y position has moved 86px down, we sould reduce height by 86px.
            viewRect.size.height = viewRect.size.height - viewRect.origin.y;
            self.webview = [[UIWebView alloc]initWithFrame:viewRect];
            self.webview.delegate = self;
            [self.webview setScalesPageToFit:YES];
            self.webview.autoresizesSubviews = YES;
            self.webview.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            self.webview.backgroundColor = [UIColor clearColor];
            self.webview.opaque = NO;
            
            [self.view addSubview:self.webview];
            [self addServiceMaxLogo];
            
            /* HS commented for SECSCAN-727
            NSURL *url = [NSURL URLWithString:[OAuthService authorizationURLString]];
            //NSURLRequest *request = [NSURLRequest requestWithURL:url];
            webViewLoadCounter = 0;
            
            
            self.startTime = CFAbsoluteTimeGetCurrent();
            __block NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            [request setValue:@"gzip; deflate" forHTTPHeaderField:@"Accept-Encoding"];//Accept-Encoding: gzip, deflate
            
            // SECSCAN-260
            OauthConnectionHandler *service = [[OauthConnectionHandler alloc] init];
            [service makeDummyCallForAuthenticationCheck:request andCompletion:^(BOOL isSuccess, NSString *errorMsg) {
                if (isSuccess)
                {
                    [self performSelectorOnMainThread:@selector(loadWebViewOnAuthenticationComplete:) withObject:request waitUntilDone:NO];
                }
                else
                {
                    [self performSelectorOnMainThread:@selector(showAlertOnAuthenticationComplete:) withObject:nil waitUntilDone:NO];
                }
            }];
            HS ends here  */
            
            //Fix:SECSCAN-727
            
            NSArray *domainsCheck = @[@"salesforce.com",
                                         @"servicemax.com",
                                         @"force.com"];
            NSURL *url = [NSURL URLWithString:[OAuthService authorizationURLString]];

            
            NSString *host = [url host]; //where URL is some NSURL object
            
            BOOL hostMatches = NO;
            
            for (NSString *testHost in domainsCheck) {
                if ([[host lowercaseString] isEqualToString:testHost]) hostMatches = YES;  // matches salesforce.com exectly
                
                NSString *testSubdomain = [NSString stringWithFormat:@".%@",testHost];  // matches www.salesforce.com but not fakesalesforce..com
                if ([[host lowercaseString] rangeOfString:testSubdomain].location != NSNotFound) hostMatches = YES;
            }
            
            if (hostMatches) {
                webViewLoadCounter = 0;
                
                
                self.startTime = CFAbsoluteTimeGetCurrent();
                __block NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
                [request setValue:@"gzip; deflate" forHTTPHeaderField:@"Accept-Encoding"];//Accept-Encoding: gzip, deflate
                
                // SECSCAN-260
                OauthConnectionHandler *service = [[OauthConnectionHandler alloc] init];
                [service makeDummyCallForAuthenticationCheck:request andCompletion:^(BOOL isSuccess, NSString *errorMsg) {
                    if (isSuccess)
                    {
                        [self performSelectorOnMainThread:@selector(loadWebViewOnAuthenticationComplete:) withObject:request waitUntilDone:NO];
                    }
                    else
                    {
                        [self performSelectorOnMainThread:@selector(showAlertOnAuthenticationComplete:) withObject:nil waitUntilDone:NO];
                    }
                }];
            }
             
            
        }
        else
        {
            // Network is not reachable will go back to Launch Page
            [self handleRequestFailedWithNetworkErrorEvent];
        }
    }
}


-(void)loadWebViewOnAuthenticationComplete:(NSMutableURLRequest *)request
{
    [self.webview loadRequest:request];
    [self addActivityAndLoadingLabel];
}


-(void)showAlertOnAuthenticationComplete:(NSObject *)sender
{
    [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeInternetNotReachable
                                                       andDelegate:nil];
    [[AppManager sharedInstance] setApplicationStatus:ApplicationStatusInLaunchScreen];
    [[AppManager sharedInstance] loadScreen];
}

#pragma mark Activity Management

- (void)addActivityAndLoadingLabel
{
    if (!self.HUD) {
        self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.HUD];
        // Set determinate mode
        self.HUD.mode = MBProgressHUDModeIndeterminate;
        self.HUD.labelText = [[TagManager sharedInstance]tagByName:kTagLoading];
        [self.HUD show:YES];
    }
}

- (void)removeActivityAndLoadingLabel
{
    if (self.HUD) {
        [self.HUD hide:YES];
        self.HUD = nil;
        
        CFTimeInterval endTime = CFAbsoluteTimeGetCurrent();
        //NSLog(@"Diff - %f",endTime - self.startTime);
    }
}

- (void)verifyCallBackURL:(NSURL *)callBackURL
{
    [self addActivityAndLoadingLabel];
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        [OAuthService extractAccessCodeFromCallbackURL:callBackURL];
    });
}

- (void)handleRequestFailedWithNetworkErrorEvent
{
    /**  Wooohh Internet not reachable */
    [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeInternetNotReachable
                                                       andDelegate:nil];
    [[AppManager sharedInstance] setApplicationStatus:ApplicationStatusInLaunchScreen];
    [[AppManager sharedInstance] loadScreen];
}

#pragma mark UIWebViewDelegate implementation

/**
 * @name  webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
 *
 * @author Vipindas Palli
 *
 * @brief Load authentication web page with failure error
 *
 * \par
 *  Custom URL schemes will typically cause a failure so we should handle those here
 *
 *
 * @param  webView UIWebView Object
 * @param  error NSError object
 *
 * @return void
 *
 */

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    webViewLoadCounter--;
    
	NSString *failingURLString = [error.userInfo objectForKey:NSURLErrorFailingURLStringErrorKey];
    
	NSString *failureReason = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
    
    SXLogError(@" OAuth didFailLoadWithError : %@ \n %@", failureReason, failingURLString);
    
    [self removeActivityAndLoadingLabel];
    
	NSString *message;
    
	if (failureReason == nil)
	{
		message = failureReason;
	}
    else
    {
		message = [NSString stringWithFormat:@"%d %@",(int)[error code], [error localizedDescription]];
	}
	
    /**  Verifying  */
	if ([failingURLString hasPrefix:kRedirectURL])
	{
		[webView stopLoading];
        
        SXLogError(@" OAuth didFailLoadWithError : kRedirectURL");
        
        [OAuthService extractAccessCodeFromCallbackURL:[NSURL URLWithString:failingURLString]];
        
	}
	else if ( [error code] != NSURLErrorCancelled )
	{
        if ( ! [[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
        {
            /**  Wooohh Internet not reachable */
            [self handleRequestFailedWithNetworkErrorEvent];
        }
        else
        {
            if ([[PlistManager userPreferedPlatformName] caseInsensitiveCompare:kPreferenceOrganizationCustom] == NSOrderedSame)
            {
                
                [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeCannotFindCustomHost
                                                                   andDelegate:nil];
            }
            else
            {
                [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeCannotFindHost
                                                                   andDelegate:nil];
            }
            [[AppManager sharedInstance] completedLoginProcessWithStatus:ApplicationStatusAuthorizationFailedWithError];
        }
	}
    
	loadFailedBool = YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	loadFailedBool = NO;
    webViewLoadCounter++;
    SXLogDebug(@" webViewDidStartLoad --- ");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    webViewLoadCounter--;
    [self performSelector:@selector(webViewFinishLoadWithCondition) withObject:nil afterDelay:0.05];
	SXLogDebug(@" webViewDidFinishLoad --- ");
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    SXLogInfo(@" navigationType  :%d", navigationType);
    SXLogInfo(@" absoluteString  :%@", [request.URL absoluteString]);
    
    /**
     *  1. Forgot Password
     *  2. Authorization Page
     *  3. On success response
     *  4. Error code 1800 - inn case of app idle
     *  5. Logout
     */
    
	if (navigationType == UIWebViewNavigationTypeLinkClicked)
	{
        // Krishna : Fixed With reference to defect 011758.
        // Apart from Custom domain lets redirect to mobile safari.
        // logout.jsp, because 'Not you?' in confirmation page should not redirect to mobile safari
        
        if ([StringUtil containsString:@"forgotpassword.jsp" inString:[request.URL absoluteString]] ) // Defect#025424. Only coded for Forgot Password. Other links will open up in the App itself. Have to be handled as and when they appear in future in Salesforce Login Page.
        {
            /**  User in forgot password page, lets redirect to mobile safari */
            [[UIApplication sharedApplication] openURL:request.URL];
            SXLogInfo(@"Return NO : kRedirectURL %@", request.URL);
            
            return NO;
        }
        
  /*
        if (![StringUtil containsString:@"logout.jsp" inString:[request.URL absoluteString]] )
		{
            //  User in forgot password page, lets redirect to mobile safari
			[[UIApplication sharedApplication] openURL:request.URL];
            SXLogInfo(@"Return NO : kRedirectURL %@", request.URL);
            
			return NO;
		}
   */
	}
    
    if ([[request.URL absoluteString] hasPrefix:kRedirectURL])
	{
		[webView stopLoading];
        SXLogDebug(@"Return NO : kRedirectURL matches sfdc://success ");
        
        if ([[request.URL absoluteString] hasPrefix:@"sfdc://success?error=access_denied"])
        {
            /** User denied access. Lets go back to Authenitcation Page */
            [self reloadAuthorization];
        }
        else
        {
            //[OAuthService extractAccessCodeFromCallbackURL:request.URL];
            [self verifyCallBackURL:request.URL];
        }
		return NO;
	}
	
    if ([StringUtil containsString:@"frontdoor.jsp" inString:[request.URL absoluteString]])
	{
        SXLogDebug(@" OAuth : frontdoor.jsp");
        
        /** Loading Authorization web page now - user expect to press Allow or Deny */
        
        [[AppManager sharedInstance] setApplicationStatus:ApplicationStatusInAuthorizationPage];
        NSLog(@"authorization failed 45");

        [self removeServiceMaxLogo];
	}
    else if ([StringUtil containsString:@"oauth_error_code=1800" inString:[request.URL absoluteString]])
	{
        SXLogError(@" OAuth :  oauth_error_code - 1800");
        [self removeActivityAndLoadingLabel];
        [self reloadAuthorization];
	}
	else if ([StringUtil containsString:@"logout.jsp" inString:[request.URL absoluteString]])
	{
        SXLogDebug(@" OAuth :  logout.jsp");
//        [webView stopLoading];
        [self reloadAuthorization];
        return NO;
	}
    else
    {
        SXLogInfo(@"  OAuth - Yes. for url %@", [request.URL absoluteString]);
    }
    
	return YES;
}

/**
 * @name  reloadAuthorization
 *
 * @author Vipindas Palli
 *
 * @brief Reload OAuth authentication page
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return void
 *
 */
- (void)reloadAuthorization
{
    [OAuthService deleteSalesForceCookies];
    [self makeUserAuthorizationRequest];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0 )
	{
        //SXLogDebug(@"AlertView for button");
    }
}

-(void)webViewFinishLoadWithCondition
{
    //if(webViewLoadCounter==0){
        //We can be safe to treat this as place where everything is loaded.
        if (([[AppManager sharedInstance] applicationStatus] == ApplicationStatusInAuthenticationPage))
        {
            [self removeActivityAndLoadingLabel];
        }
    //}
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.webview.delegate = nil;
}

- (void)dealloc
{
    if (self.webview)
    {
        self.webview.delegate = nil;
        [self.webview removeFromSuperview];
    }
    webViewLoadCounter = 0;
    self.webview = nil;
    self.servicemaxLogo = nil;
    self.HUD = nil;
}

@end
