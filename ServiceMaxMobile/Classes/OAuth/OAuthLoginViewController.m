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
#import "Utility.h"
#import "StringUtil.h"
#import "SNetworkReachabilityManager.h"
#import "AppManager.h"
#import "OAuthService.h"
#import "SMAppDelegate.h"
#import "AlertMessageHandler.h"


@interface OAuthLoginViewController ()
{
    BOOL loadFailedBool;
}

@property (nonatomic, strong)UIWebView *webview;
@property (nonatomic, strong)UILabel   *loadingLabel;
@property (nonatomic, strong)UIActivityIndicatorView *activity;
@property (nonatomic, strong)UIImageView *servicemaxLogo;


- (void)addActivityAndLoadingLabel;
- (void)removeActivityAndLoadingLabel;

- (void)addServiceMaxLogo;
- (void)removeServiceMaxLogo;

@end

@implementation OAuthLoginViewController

@synthesize webview;
@synthesize loadingLabel;
@synthesize activity;
@synthesize servicemaxLogo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
    
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![Utility notIOS7])
    {
        self.view.backgroundColor = [UIColor colorWithRed:42.0/255.0 green:148.0/255.0 blue:214.0/255.0 alpha:1.0];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	if ( (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft )
        || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight ) )
    {
        return YES;
    }
	else
    {
		return NO;
    }
}


- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}


- (void)addServiceMaxLogo
{
    if (self.servicemaxLogo == nil)
    {
        //  Changed code for adding service max logo.
        self.servicemaxLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    }
	servicemaxLogo.contentMode = UIViewContentModeScaleAspectFit;
    
    if ( ![Utility notIOS7])
    {
        servicemaxLogo.bounds = CGRectMake(0, 0, 330, 96);
    }
    else
    {
     	servicemaxLogo.bounds = CGRectMake(0, 0, 350, 96);
    }
    
    //	CGPoint center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame)+150);
	int maxY = CGRectGetMaxY(self.view.frame);
	int logoY = maxY;
    logoY = logoY-180;
	int logoX = 48;
	CGPoint center = CGPointMake(logoY, logoX);
	servicemaxLogo.center = center;
	[self.webview.scrollView addSubview:servicemaxLogo];
}


- (void)removeServiceMaxLogo
{
    if (self.servicemaxLogo != nil)
    {
        [servicemaxLogo removeFromSuperview];
        self.servicemaxLogo = nil;
    }
}

/*
 1. User Authorization Request
 2. VerifyAuthorization Access code
 */

- (void)makeUserAuthorizationRequest
{
    [[AppManager sharedInstance] setApplicationStatus:ApplicationStatusInAuthenticationPage];
    
    // If webview exist lets remove it from the view
    if (self.webview != nil)
	{
        self.webview.delegate = nil;
        [self.webview removeFromSuperview];
		self.webview = nil;
	}
    
    // Non-iOS 7.0 UI changes
    if ([Utility notIOS7])
    {
        self.webview = [[UIWebView alloc]initWithFrame:CGRectMake(0,0,1024,768)];
        [self.webview setScalesPageToFit:YES];
    }
    else
    {
        self.webview = [[UIWebView alloc]initWithFrame:CGRectMake(0,0,1024,450)];
    }
	
    self.webview.backgroundColor = [UIColor clearColor];
    self.webview.opaque = NO;
    
	[self.view addSubview:self.webview];
	self.webview.delegate = self;
    
    
	NSURL *url = [NSURL URLWithString:[OAuthService authorizationURLString]];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	
    [self.webview loadRequest:request];
    
    [self addServiceMaxLogo];
    [self addActivityAndLoadingLabel];
}

/*
- (BOOL)isLoadingAuthorizationPage:(NSString *)urlString
{
    BOOL authorizationPage = NO;
    
    if ([StringUtil containsString:@"frontdoor.jsp" inString:urlString])
	{
		[servicemaxLogo removeFromSuperview];
		//SMLog(kLogLevelVerbose,@"%@", [[request.URL absoluteString] pathComponents]);
		//appDelegate.isUserOnAuthenticationPage = FALSE;
        [[AppManager sharedInstance] setApplicationStatus:ApplicationStatusInAuthorizationPage];
        authorizationPage = YES;
	}
    return authorizationPage;
}


- (BOOL)shouldLoadRedirectionPage:(NSString *)urlString
{
    BOOL redirectPageLoading = YES;

    if ([urlString hasPrefix:kRedirectURL])
	{
		[webview stopLoading];
		//[self extractAccessCodeFromCallbackURL:request.URL];
		//redirectPageLoading = NO;
	}

    return redirectPageLoading;
}


- (BOOL)hasWebPageLoadingErrorOccured:(NSString *)urlString
{
    BOOL errorOccured = NO;
    
    if ([StringUtil containsString:@"oauth_error_code=1800" inString:urlString])
	{
		//Change for : App renders 2 login screen if kept idle for around 30 mins.
		 [self removeActivityAndLoadingLabel];
        
	//	[appDelegate showSalesforcePage];
        
        errorOccured = YES;
	}
    return errorOccured;
}

- (BOOL)shouldLoadLgoutPage:(NSString *)urlString
{
    BOOL loadWebPage = NO;
    
    if ([StringUtil containsString:@"logout.jsp" inString:urlString])
	{
		//appDelegate.isUserOnAuthenticationPage = TRUE;
		//[appDelegate showSalesforcePage];
        //loadWebPage = YES;
	}
    
    return loadWebPage;
}
*/

#pragma mark - Webview Delegate Methods
/*
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
                                                 navigationType:(UIWebViewNavigationType)navigationType
{
    
    BOOL startLoading = YES;
    
	if (navigationType == UIWebViewNavigationTypeLinkClicked)
	{
        if ([StringUtil containsString:@"forgotpassword.jsp" inString:[request.URL absoluteString]])
		{
			[[UIApplication sharedApplication] openURL:request.URL];
			startLoading = NO;
		}
	}
    
    /*
    if (startLoading)
    {
        NSString *urlString = [request.URL absoluteString];
        
        if ([self isLoadingAuthorizationPage:urlString])
        {
            
        }
        else if ([self shouldLoadRedirectionPage:urlString])
        {
        
        }
        else if ([self hasWebPageLoadingErrorOccured:urlString])
        {
            
        }
        else if ([self shouldLoadLgoutPage:urlString])
        {
            
        }
    }
    
    return startLoading;

    
	if (! [[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
	{
        // We have to remove logo here...since no network connection
		[self removeActivityAndLoadingLabel];
	}
	
    /*
    // 1. FrontDoor
    // 2. RedirectURL
    // 3. OAuth Error code 1800
    // 4. Logout.jsp
    */
    
    /*
	//Set flag to indicated if its on the authorization page. - 24/May/2013.
    if ([StringUtil containsString:@"frontdoor.jsp" inString:[request.URL absoluteString]])
	{
		[servicemaxLogo removeFromSuperview];
	//	SMLog(kLogLevelVerbose,@"%@", [[request.URL absoluteString] pathComponents]);
		//appDelegate.isUserOnAuthenticationPage = FALSE;
        startLoading = NO;
	}
	
	SMLog(kLogLevelVerbose,@"%@", request);
	
	if ([[request.URL absoluteString] hasPrefix:kRedirectURL])
	{
		[webView stopLoading];
		[OAuthService extractAccessCodeFromCallbackURL:request.URL];
		return NO;
	}
	
    if ([StringUtil containsString:@"oauth_error_code=1800" inString:[request.URL absoluteString]])
	{
		//Change for : App renders 2 login screen if kept idle for around 30 mins.
		[self removeBackgroundImageAndLogo];
        
		//[appDelegate showSalesforcePage];
	}
	
    if ([StringUtil containsString:@"logout.jsp" inString:[request.URL absoluteString]])
	{
		//appDelegate.isUserOnAuthenticationPage = TRUE;
		//[appDelegate showSalesforcePage];
	}
    
	return YES;

}
*/

/**
 * custom URL schemes will typically cause a failure so we should handle those here
 */
/*
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	NSString *failingURLString = [error.userInfo objectForKey:NSURLErrorFailingURLStringErrorKey];
	NSString *failureReason    = [error.userInfo objectForKey:NSLocalizedDescriptionKey];

    [self removeActivityAndLoadingLabel];
    
    // Change here
	
	NSString *message = failureReason;
	
    if ([StringUtil isStringEmpty:failureReason])
	{
		message = [NSString stringWithFormat:@"%d %@",[error code], [error localizedDescription]];
	}
	
	if ([failingURLString hasPrefix:kRedirectURL])
	{
		[webView stopLoading];
        
		[OAuthService extractAccessCodeFromCallbackURL:[NSURL URLWithString:failingURLString]];
	}
	else if ([error code] != NSURLErrorCancelled )
	{
        */
        // TODO :- Vipin
        /*
        
//        if ( ![appDelegate isInternetConnectionAvailable] )
//        {
//            appDelegate.shouldShowConnectivityStatus = TRUE;
//            [appDelegate displayNoInternetAvailable];
//        }
//        else
        {
            NSString *cannotFindHostMsg = @"A server with the specified hostname could not be found.";
            
            if ([appDelegate.userOrg caseInsensitiveCompare:@"Custom"] == NSOrderedSame)
            {
                cannotFindHostMsg = @"A server with the specified hostname could not be found. Please check your custom host URL settings.";
            }
            
            _webViewDidFail = TRUE;
            UIAlertView *OAuthAlert = [[UIAlertView alloc] initWithTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:alert_application_error]
                                                                 message:cannotFindHostMsg
                                                                delegate:self
                                                       cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK]
                                                       otherButtonTitles:nil, nil];
            [OAuthAlert show];
            [OAuthAlert release];
        }
         
         *//*
	}
    
	//loadFailedBool = YES;
}
*/

/*
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	//loadFailedBool = NO;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	//if ( [[AppManager sharedInstance] applicationStatus] ==  ApplicationStatusInAuthenticationPage )
    if (YES)
    {
		[self removeActivityAndLoadingLabel];
    }
    else if (![Utility notIOS7])
    {
        self.webview.frame = CGRectMake(0, 0, 1024, 768);
    }
    
    /*
	if ( appDelegate.isUserOnAuthenticationPage == TRUE )
    {
		[appDelegate removeBackgroundImageAndLogo];
    }
    else if(![Utility notIOS7])
    {
        self.webview.frame = CGRectMake(0, 0, 1024, 768);
    }
    
	if ( !loadFailedBool )
    {
		webViewDidFinishLoadBool = YES;
    }

     */
//}


#pragma mark Activity Management

- (void)addActivityAndLoadingLabel
{
    if (loadingLabel == nil)
    {
        loadingLabel = [[UILabel alloc] init];
        loadingLabel.text = @"Loading...";
        loadingLabel.backgroundColor = [UIColor clearColor];
        loadingLabel.textColor = [UIColor whiteColor];
        loadingLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    
     CGSize constraint = CGSizeMake(self.view.frame.size.width, 20);
     
     CGSize textSize = [loadingLabel.text sizeWithFont:[UIFont systemFontOfSize:18]
                                     constrainedToSize:constraint
                                         lineBreakMode:NSLineBreakByWordWrapping];
    
     CGFloat widthByTwo = textSize.width/2;
     
     CGFloat x = CGRectGetMidY(self.view.frame);
     
     CGFloat placeAtX =  (x - widthByTwo);
     
     activity = [[UIActivityIndicatorView alloc] init];
     activity.frame = CGRectMake(placeAtX, 456, textSize.width, 35);
     activity.contentMode = UIViewContentModeScaleAspectFit;
     [activity setBackgroundColor:[UIColor clearColor]];
     [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
     activity.color = [UIColor whiteColor];
     [self.view addSubview:activity];
     loadingLabel.textColor = [UIColor whiteColor];
     loadingLabel.frame = CGRectMake(placeAtX + widthByTwo + 20, 456, 100, 35);
     [self.view addSubview:loadingLabel];
     [activity startAnimating];
}


- (void)removeActivityAndLoadingLabel
{
    //Defect #7238
	if (activity)
	{
		[activity stopAnimating];
		[activity removeFromSuperview];
		[activity release];
		activity = nil;
	}
	
	if (loadingLabel)
	{
		[loadingLabel removeFromSuperview];
		[loadingLabel release];
		loadingLabel = nil;
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
	NSString *failingURLString = [error.userInfo objectForKey:NSURLErrorFailingURLStringErrorKey];
    
	NSString *failureReason = [error.userInfo objectForKey:NSLocalizedDescriptionKey];

    NSLog(@" didFailLoadWithError : %@ \n %@", failureReason, failingURLString);

    [self removeActivityAndLoadingLabel];
    
	NSString *message;
    
	if (failureReason == nil)
	{
		message = failureReason;
	}
    else
    {
		message = [NSString stringWithFormat:@"%d %@",[error code], [error localizedDescription]];
	}
	
    /**  Verifying  */
	if ([failingURLString hasPrefix:kRedirectURL])
	{
		[webView stopLoading];
        
        NSLog(@" didFailLoadWithError : kRedirectURL");
        
        [OAuthService extractAccessCodeFromCallbackURL:[NSURL URLWithString:failingURLString]];
         
	}
	else if ( [error code] != NSURLErrorCancelled )
	{
        if ( ! [[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
        {
            /**  Wooohh Internet not reachable */
            [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeInternetNotReachable
                                                               andDelegate:self];
        }
        else
        {
            //NSString *cannotFindHostMsg = @"A server with the specified hostname could not be found.";
            
            if ([appDelegate.userOrg caseInsensitiveCompare:kPreferenceOrganizationCustom] == NSOrderedSame)
            {
                //cannotFindHostMsg = @"A server with the specified hostname could not be found. Please check your custom host URL settings.";
                
                [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeCannotFindCustomHost
                                                                   andDelegate:self];
            }
            else
            {
                [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeCannotFindHost
                                                                   andDelegate:self];
            }
            
            [[AppManager sharedInstance] completedLoginProcessWithStatus:ApplicationStatusAuthorizationFailedWithError];
            /*
           // _webViewDidFail = TRUE;
            UIAlertView *OAuthAlert = [[UIAlertView alloc] initWithTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:alert_application_error] message:cannotFindHostMsg delegate:self cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK] otherButtonTitles:nil, nil];
            
            [OAuthAlert show];
            [OAuthAlert release];
             */
        }
	}
    
	loadFailedBool = YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	loadFailedBool = NO;
    
    NSLog(@" webViewDidStartLoad --- ");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	NSLog(@" webViewDidFinishLoad --- ");
    
    if (![Utility notIOS7])
    {
        self.webview.frame = CGRectMake(0, 0, 1024, 768);
    }
    
    if (   ([[AppManager sharedInstance] applicationStatus] == ApplicationStatusInAuthenticationPage)
        || ([[AppManager sharedInstance] applicationStatus] == ApplicationStatusInAuthorizationPage))
    {
        [self removeActivityAndLoadingLabel];
    }
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@" navigationType  :%d", navigationType);
    NSLog(@" absoluteString  :%@", [request.URL absoluteString]);
    
    /**
     *  1. Forgot Password
     *  2. Authorization Page
     *  3. On success response
     *  4. Error code 1800 - inn case of app idle
     *  5. Logout
     */
    
	if (navigationType == UIWebViewNavigationTypeLinkClicked)
	{
        if ([StringUtil containsString:@"forgotpassword.jsp" inString:[request.URL absoluteString]])
		{
            /**  User in forgot password page, lets redirect to mobile safari */
            
			[[UIApplication sharedApplication] openURL:request.URL];
            
             NSLog(@"Return NO : kRedirectURL forgotpassword.jsp");
			return NO;
		}
	}
    
    if ([[request.URL absoluteString] hasPrefix:kRedirectURL])
	{
		[webView stopLoading];
        NSLog(@"Return NO : kRedirectURL matches sfdc://success ");
        
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
        NSLog(@" OAuth : frontdoor.jsp");
        
        /** Loading Authorization web page now - user expect to press Allow or Deny */
        
        [[AppManager sharedInstance] setApplicationStatus:ApplicationStatusInAuthorizationPage];
        [self removeServiceMaxLogo];
	}
    else if ([StringUtil containsString:@"oauth_error_code=1800" inString:[request.URL absoluteString]])
	{
        NSLog(@" OAuth :  oauth_error_code - 1800");
        [self removeActivityAndLoadingLabel];
        [self reloadAuthorization];
	}
	else if ([StringUtil containsString:@"logout.jsp" inString:[request.URL absoluteString]])
	{
        NSLog(@" OAuth :  logout.jsp");
        [self reloadAuthorization];
	}
    else
    {
        NSLog(@"  OAuth - Yes. for url %@", [request.URL absoluteString]);
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
    
        NSLog(@" AlertView for button ");
    }
}

@end



#pragma mark UIWebViewIntegration implementation

@implementation OAuthClientInterface (UIWebViewIntegration)

- (void)authorizeUsingWebView:(UIWebView *)webView
{
    NSLog(@" UIWebViewIntegration -  authorizeUsingWebView ");
    
	[self authorizeUsingWebView:webView additionalParameters:nil];
}


- (void)authorizeUsingWebView:(UIWebView *)webView
         additionalParameters:(NSDictionary *)additionalParameters
{
    NSLog(@" UIWebViewIntegration -  authorizeUsingWebView - 2 ");
	[webView setDelegate:self];
	[self userAuthorizationRequestWithParameters:nil];
}


@end

