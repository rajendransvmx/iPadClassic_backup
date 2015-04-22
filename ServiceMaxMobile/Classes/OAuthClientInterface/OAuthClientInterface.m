//
//  OAuthClientInterface.m
//  iService
//
//  Created by Shrinivas Desai on 03/01/13.
//
//

#import "OAuthClientInterface.h"
#import "Utility.h"

/*Accessibilty*/
#import "AccessibilityOAuthLoginConstants.h"

@interface OAuthClientInterface ()

@end

@implementation OAuthClientInterface

@synthesize clientID;
@synthesize clientSecret;
@synthesize redirectURL;
@synthesize cancelURL;
@synthesize userURL;
@synthesize tokenURL;
@synthesize delegate;
@synthesize debug;
@synthesize responseData;
@synthesize webview;
@synthesize _accessToken;
@synthesize identityURL;
@synthesize isVerifying;


- (void)dealloc;
{
	[clientID release];
	[clientSecret release];
	[userURL release];
	[redirectURL release];
	[cancelURL release];
	[webview release];
	[servicemaxLogo release];
	[super dealloc];
	
}

/*
 The Appdelegate was initializing this object twice. Once with init method and next using the below method.
 Now Anish has prevented the 2nd initialization and the 1st initialization is changed to use initWithFrame method rather than just 'init'
 
 - (id)initWithClientID:(NSString *)_clientID
                secret:(NSString *)_secret
           redirectURL:(NSString *)url;
{
	appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (self)
    {
		clientID = [_clientID copy];
		clientSecret = [_secret copy];
		redirectURL = [url copy];
		debug = NO;
        self.backgroundColor = [UIColor blackColor];
	}
	
	return self;
}*/

- (id)updateWithClientID:(NSString *)_clientID
                secret:(NSString *)_secret
           redirectURL:(NSString *)url;
{
	appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (self)
    {
		clientID = [_clientID copy];
		clientSecret = [_secret copy];
		redirectURL = [url copy];
		debug = NO;
	}
	
	return self;
}

#pragma mark -
#pragma mark Authorization

//Constructing POST Request for Authorization.
- (void)userAuthorizationRequestWithParameters:(NSDictionary *)additionalParameters;
{
	if ( appDelegate == nil )
		 appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	//Radha Defect Fix 7238
	
	
	if ( [appDelegate isInternetConnectionAvailable] && (appDelegate.activity==nil))
		[appDelegate addBackgroundImageAndLogo];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	//Read the custom url :  //For Defect #7085
	NSString * preference = [userDefaults valueForKey:@"preference_identifier"];
	if ( [preference isEqualToString:@"Custom"] )
		appDelegate.customURLValue = [ZKServerSwitchboard baseURL];

	
	NSString *post = nil;
	
	post = [NSString stringWithFormat:@"redirect_uri=%@&client_id=%@&response_type=token&state=mystate",
					  redirectURL,
					  clientID];
	
	tokenURL = [NSString stringWithFormat:@"%@%@?%@",[ZKServerSwitchboard baseURL], _TOKEN_URL, post];

    if (self.webview)
	{
        [self.webview removeFromSuperview];
		[self.webview release];
		self.webview = nil;
	}
    
    //Anish: Part of Fix 008481. iOS 7: Keyboard keeps on retracting when user tries to enter the username on login screen
    if([Utility notIOS7])
    {
        self.webview=[[UIWebView alloc]initWithFrame:CGRectMake(0,0,1024,768)];
        [self.webview setScalesPageToFit:YES];
    }
    else
        self.webview=[[UIWebView alloc]initWithFrame:CGRectMake(0,0,1024,450)];
	
    self.webview.backgroundColor = [UIColor clearColor];
    self.webview.opaque = NO;
    
    
	[self addSubview:self.webview];
	self.webview.delegate = self;
    
    
    
	NSURL *url = [NSURL URLWithString:tokenURL];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	
    [self.webview loadRequest:request];
   
    
	
	_webViewDidFail = FALSE;
//	while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
//	{
//		if (![appDelegate isInternetConnectionAvailable])
//		{
//			appDelegate.shouldShowConnectivityStatus = YES;
//			[appDelegate displayNoInternetAvailable];
//			
//			return;
//		}
//		
//		if ( webViewDidFinishLoadBool == YES || _webViewDidFail == TRUE )
//			break;
//	}

	
	
	
	//self.webview.frame = CGRectMake(0, 0, 1024, 768);
	
	
	appDelegate.isUserOnAuthenticationPage = TRUE;
	
	appDelegate.logoutFlag = FALSE;
	
	appDelegate.userOrg = [userDefaults valueForKey:@"preference_identifier"]; //Capture user org if Success :a
	
	
	//Fix for Defect #7079 : 16/May/2013 : Changed  code for adding service max logo.
	servicemaxLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
	servicemaxLogo.contentMode = UIViewContentModeScaleAspectFit;
    if(![Utility notIOS7])
        servicemaxLogo.bounds = CGRectMake(0, 0, 330, 96);
    else
     	servicemaxLogo.bounds = CGRectMake(0, 0, 350, 96);
   
//	CGPoint center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame)+150);
	int maxy = CGRectGetMaxY(self.frame);
	int logoY = maxy;
    logoY = logoY-180;
	int logoX = 48;
	CGPoint center = CGPointMake(logoY, logoX);
	servicemaxLogo.center = center;
    
    /*Accessibility Changes*/
    [self setAccessibilityIdentifierForInstanceVariable];
    
	//view.scrollView.scrollEnabled = NO;
	[self.webview.scrollView addSubview:servicemaxLogo];
	//[servicemaxLogo release];
}

/*Accessibility Changes*/
- (void) setAccessibilityIdentifierForInstanceVariable
{
    self.webview.scrollView.isAccessibilityElement = NO;
    [self.webview.scrollView setAccessibilityIdentifier:kAccWebview];
    
    servicemaxLogo.isAccessibilityElement = YES;
    [servicemaxLogo setAccessibilityIdentifier:kAccServiceMaxLogo];
}


- (void)verifyAuthorizationWithAccessCode:(NSString *)_identityURL
{
	self.isVerifying = YES;
	
	NSString *post = [NSString stringWithFormat:@"oauth_token=%@",appDelegate.session_Id];
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:_identityURL]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
    /*
     Vipindas - 22 / Sep / 2014
     Fixed defect #012051 -  Unable to login to the app, tapping on 'Allow' in salesforce authentication page app logs out
     Refernce : https://help.salesforce.com/HTViewHelpDoc?id=remoteaccess_using_openid.htm&language=en_US
    */
    if (appDelegate.session_Id != nil)
    {
        NSString *tokenWithPrefix = [@"OAuth " stringByAppendingString:appDelegate.session_Id];
        [request setValue:tokenWithPrefix forHTTPHeaderField:@"Authorization"];
    }
    
	NSError *error = nil;
	NSURLResponse *response = nil;
	
	SMLog(kLogLevelVerbose,@"%@", request);
	
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if ( error )
	{
		[appDelegate removeBackgroundImageAndLogo];
		[appDelegate showAlertForSyncFailure];
		return;
	}

	
	NSString *data=[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
	SMLog(kLogLevelVerbose,@"%@", data);
    
    //NSLog(@"Authorizatio verification response - %@", data);
	
	self.isVerifying = NO;
	if ( data )
	{
		[self getEndPointUrlFromResponse:data];
	}
		
}


- (void)getEndPointUrlFromResponse:(NSString *)jsonResponse
{
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *dict = [parser objectWithString:jsonResponse];
	
	NSDictionary *urlDict = [dict objectForKey:@"urls"];
	
	appDelegate.apiURl = [[urlDict objectForKey:@"partner"] stringByReplacingOccurrencesOfString:@"{version}" withString:PREFFERED_API_VERSION];
	
	//Fix for defect #7092 : 15/May/2013
	NSArray *pathComponentsArray = [[urlDict objectForKey:@"partner"] pathComponents];
	NSString *protocol = [pathComponentsArray objectAtIndex:0];
	NSString *appendToProtocol = @"//";
	NSString *hostName = [pathComponentsArray objectAtIndex:1];
	
	appDelegate.currentServerUrl = [NSString stringWithFormat:@"%@%@%@", protocol, appendToProtocol, hostName];
	
	appDelegate.current_userId  = [dict objectForKey:@"user_id"];
	appDelegate.userProfileId   = [dict objectForKey:@"user_id"];
	appDelegate.currentUserName = [dict valueForKey:@"username"];
	appDelegate.username		= [dict valueForKey:@"username"];
	appDelegate.language		= [dict valueForKey:@"language"];
	appDelegate.loggedInUserId  = [dict objectForKey:@"user_id"];
	appDelegate.organization_Id = [dict valueForKey:@"organization_id"];
	appDelegate.userDisplayFullName = [dict valueForKey:@"display_name"];
	
	appDelegate.isUserOnAuthenticationPage = FALSE;
	[appDelegate didLoginWithOAuth];
}


- (void)setUserLanguage:(NSString *)identity_URL
{	
	NSString *post = [NSString stringWithFormat:@"oauth_token=%@", appDelegate.session_Id];
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:identity_URL]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
	NSError *error = nil;
	NSURLResponse *response = nil;
	
	SMLog(kLogLevelVerbose,@"%@", request);
	
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if ( error )
	{
		UIAlertView *OAuthAlert = [[UIAlertView alloc] initWithTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:alert_application_error] message:[error localizedDescription] delegate:self cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK] otherButtonTitles:nil, nil];
		
		[OAuthAlert show];
		[OAuthAlert release];
	}
	
	NSString *data=[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
	//SMLog(kLogLevelVerbose,@"%@", data);
		
	if ( data )
	{
		SBJsonParser *parser = [[SBJsonParser alloc] init];
		NSDictionary *dict = [parser objectWithString:data];
		
		appDelegate.language = [dict valueForKey:@"language"];
		
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setObject:appDelegate.language forKey:@"UserLanguage"];
		[userDefaults synchronize];
	}

}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
	//Fix for defect #7081
	if ( navigationType == UIWebViewNavigationTypeLinkClicked )
	{
		if ( [[request.URL absoluteString] Contains:@"forgotpassword.jsp"] )
		{
			[[UIApplication sharedApplication] openURL:request.URL];
			return NO;
		}
	}
	
	if ( ![appDelegate isInternetConnectionAvailable] )
	{
		//Defect Fix 7238
		[appDelegate removeBackgroundImageAndLogo];
//		appDelegate.shouldShowConnectivityStatus = TRUE;
//		[appDelegate displayNoInternetAvailable];
		
		//return NO;
	}
	
	//Set flag to indicated if its on the authorization page. - 24/May/2013.
	if ( [[request.URL absoluteString] Contains:@"frontdoor.jsp"] )
	{
		[servicemaxLogo removeFromSuperview]; //Fix for defect #7539.
		SMLog(kLogLevelVerbose,@"%@", [[request.URL absoluteString] pathComponents]);
		appDelegate.isUserOnAuthenticationPage = FALSE;
	}
	
	SMLog(kLogLevelVerbose,@"%@", request);
	
	if ([[request.URL absoluteString] hasPrefix:redirectURL])
	{
		[webView stopLoading];
		[self extractAccessCodeFromCallbackURL:request.URL];
		return NO;
	}
	
	if ( [[request.URL absoluteString] Contains:@"oauth_error_code=1800"] )
	{
		//Change for : App renders 2 login screen if kept idle for around 30 mins.
		//Fix for Defect #007179
		//Defect Fix 7238
		[appDelegate removeBackgroundImageAndLogo];

		[appDelegate showSalesforcePage];
	}
	
	if ( [[request.URL absoluteString] Contains:@"logout.jsp"] )
	{
		appDelegate.isUserOnAuthenticationPage = TRUE;
		[appDelegate showSalesforcePage];
	}
		
	return YES;
}


- (void)extractAccessCodeFromCallbackURL:(NSURL *)callbackURL;
{
	NSString *url  = [callbackURL absoluteString];
	
	if ( [url Contains:@"error=access_denied"] )
	{
		NSLog(@"END USER DENIED AUTHORIZATION...");		
		[self deleteAllCookies];
		[appDelegate showSalesforcePage];
	}
	else
	{
		if ( url )
		{
			
			NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
			
			NSArray *array = [url componentsSeparatedByString:@"&"];
			
			appDelegate.session_Id = [[[array objectAtIndex:0] componentsSeparatedByString:@"="] objectAtIndex:1];
			appDelegate.session_Id = [appDelegate.session_Id stringByReplacingOccurrencesOfString:@"%21" withString:@"!"];
			
			appDelegate.refresh_token = [[[array objectAtIndex:1] componentsSeparatedByString:@"="] objectAtIndex:1];
			appDelegate.refresh_token = [appDelegate.refresh_token stringByReplacingOccurrencesOfString:@"%3D" withString:@"="];
			
			identityURL = [[[array objectAtIndex:3] componentsSeparatedByString:@"="] objectAtIndex:1];
			identityURL = [identityURL stringByReplacingOccurrencesOfString:@"%3A" withString:@":"];
			identityURL = [identityURL stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
			[userDefaults setObject:identityURL forKey:IDENTITY_URL];
			[userDefaults synchronize];
			
			[self verifyAuthorizationWithAccessCode:identityURL];

		}

	}
	
}

//POST REQUEST TO REFRESH THE ACCESS TOKENS USING REFRESH TOKENS.
- (BOOL)refreshAccessToken:(NSString *)refresh_Token isInvokeByBackgroundProcess:(BOOL)isBackgroundProcess
{
	if ( appDelegate == nil )
		 appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
    /** Pushpak 10734  : GE issue - 13942 */
    /** Method is called from many places other than dochecksession */
    /** return if remote access is revoked */
    if ([appDelegate isRemoteAccessRevoked])
    {
        return NO;
    }

	NSString *orgURL = [NSString stringWithFormat:@"%@/services/oauth2/token", [ZKServerSwitchboard baseURL]];
	NSString *post = [NSString stringWithFormat:@"grant_type=refresh_token&client_id=%@&client_secret=%@&refresh_token=%@",CLIENT_ID,CLIENT_SECRET,refresh_Token];
					  
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:orgURL]];
	[request setHTTPMethod:@"POST"];
	
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
	NSError *error = nil;
	NSURLResponse *response = nil;
	
    NSLog(@"Request %@", request);
	
	NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if ( error && [appDelegate isInternetConnectionAvailable])
	{
        if(![error.domain  Contains:@"NSURLErrorDomain"] || !isBackgroundProcess)
        {
            UIAlertView *OAuthAlert = [[UIAlertView alloc] initWithTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:alert_application_error] message:[error localizedDescription] delegate:self cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK] otherButtonTitles:nil, nil];

            [OAuthAlert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
            [OAuthAlert release];
		}
	}

	NSString *data = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
	
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *dict = [parser objectWithString:data];
    [parser release];
    parser = nil;
	[data release];
    data = nil;
    
	NSLog(@"RESPONSE WITH NEW ACCESS TOKENS : %@", dict);

	//Alert user incase of inability to get new access tokens via refresh token.
	if ( [[dict valueForKey:@"error"] isEqualToString:@"invalid_grant"] )
	{
		/*Shrini fix for defect 7189*/
		if ([[dict valueForKey:@"error_description"] isEqualToString:@"inactive user"])
		{
			return NO;
		}
		
		NSException *exp = nil;
		NSString *ExpName  = [appDelegate.wsInterface.tagsDictionary valueForKey:alert_connection_error];
		NSString *ExpReason = [appDelegate.wsInterface.tagsDictionary valueForKey:remote_access_error];
        //009666
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"" forKey:@"userInfo"];
		
		NSArray *errKeys = [NSArray arrayWithObjects:@"ExpName",@"ExpReason",@"userInfo", nil];
		NSArray *errObjs = [NSArray arrayWithObjects:ExpName, ExpReason, userInfo, nil];
    
		NSMutableDictionary *errDict = [NSMutableDictionary dictionaryWithObjects:errObjs forKeys:errKeys];
		
		[appDelegate CustomizeAletView:nil alertType:RES_ERROR Dict:errDict exception:exp];
		
        /** Pushpak 10734 : GE issue - 13942  */
        /** Set the value in NSUserDefaults so that we can check in dochecksession */
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RemoteAccessRevoked"];
        [[NSUserDefaults standardUserDefaults] synchronize];

		return NO;
		
	}
	if ( dict && [dict valueForKey:@"access_token"] )
	{
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		appDelegate.userOrg = [userDefaults valueForKey:@"preference_identifier"]; //Capture user org if Success :
		appDelegate.session_Id = nil;
		appDelegate.session_Id = [dict valueForKey:@"access_token"];
		
		//Replace the session Id in the user defaults :
		[userDefaults setObject:appDelegate.session_Id forKey:ACCESS_TOKEN];
		[userDefaults synchronize];
		
		return TRUE;
	}

	appDelegate.connection_error = TRUE; //Please verify.
	return FALSE;

	
}

//POST REQUEST TO REVOKE EXISTING TOKENS:
/*- (void)revokeExistingToken:(NSString *)refresh_token
{
	NSString *revokeURl = REVOKE_URL;
	NSString *orgURL = [NSString stringWithFormat:@"%@%@", [ZKServerSwitchboard baseURL], revokeURl];
	NSString *post = [NSString stringWithFormat:@"token=%@", refresh_token];
	
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:orgURL]];
	[request setHTTPMethod:@"POST"];
	
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
	NSError *error = nil;
	NSHTTPURLResponse *response = nil;
	
	SMLog(kLogLevelVerbose,@"%@", request);
	
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if ( error )
	{
		UIAlertView *OAuthAlert = [[UIAlertView alloc] initWithTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:alert_application_error] message:[error localizedDescription] delegate:self cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK] otherButtonTitles:nil, nil];
		
		[OAuthAlert show];
		[OAuthAlert release];
		
	}

	NSString *data=[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
	
	SMLog(kLogLevelVerbose,@"%@ REVOKE STATUS : %d", data, [response statusCode]);
	
	if ( [response statusCode] == 200)
	{
		SMLog(kLogLevelVerbose,@"Sucessfully Revoked the Tokens..");
		
		//Delete the default values for the user incase logged out :
		[SFHFKeychainUtils deleteKeychainValue:KEYCHAIN_SERVICE];
		
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults removeObjectForKey:ACCESS_TOKEN];
		[userDefaults removeObjectForKey:SERVERURL];
		[userDefaults removeObjectForKey:ORGANIZATION_ID];
		[userDefaults removeObjectForKey:API_URL];
		[userDefaults removeObjectForKey:USER_ORG];
		[userDefaults removeObjectForKey:IDENTITY_URL];
		[userDefaults synchronize];
		[self deleteAllCookies];
	}
	else
		SMLog(kLogLevelVerbose,@"Failed Revoking the Tokens...");

}*/

- (BOOL)revokeExistingToken:(NSString *)refresh_token
{
	NSString *revokeURl = REVOKE_URL;
	NSString *orgURL = [NSString stringWithFormat:@"%@%@", [ZKServerSwitchboard baseURL], revokeURl];
	NSString *post = [NSString stringWithFormat:@"token=%@", refresh_token];
	
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:orgURL]];
	[request setHTTPMethod:@"POST"];
	
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
	NSError *error = nil;
	NSHTTPURLResponse *response = nil;
	
	SMLog(kLogLevelVerbose,@"%@", request);
	
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if ( error )
	{
		UIAlertView *OAuthAlert = [[UIAlertView alloc] initWithTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:alert_application_error] message:[error localizedDescription] delegate:self cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK] otherButtonTitles:nil, nil];
		
		[OAuthAlert show];
		[OAuthAlert release];
		
	}
	
	NSString *data=[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
	
	SMLog(kLogLevelVerbose,@"%@ REVOKE STATUS : %d", data, [response statusCode]);
	
	if ( ([response statusCode] == 200) || (refresh_token == nil) || ([response statusCode] == 404))
	{
		SMLog(kLogLevelVerbose,@"Sucessfully Revoked the Tokens...");
		
		//Delete the default values for the user incase logged out :
		[SFHFKeychainUtils deleteKeychainValue:KEYCHAIN_SERVICE];
		
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults removeObjectForKey:ACCESS_TOKEN];
		[userDefaults removeObjectForKey:SERVERURL];
		[userDefaults removeObjectForKey:ORGANIZATION_ID];
		[userDefaults removeObjectForKey:API_URL];
		[userDefaults removeObjectForKey:USER_ORG];
		[userDefaults removeObjectForKey:IDENTITY_URL];
        
        /** Pushpak 10734  : GE issue - 13942 */
        /** Reset the value in NSUserDefaults so that we can allow webservice in dochecksession */
        [userDefaults removeObjectForKey:@"RemoteAccessRevoked"];
        [userDefaults synchronize];

		[self deleteAllCookies];

		return TRUE; //Fix for #007177
	}
	else
	{
		SMLog(kLogLevelError,@"Failed Revoking the Tokens. StatusCode = %d",[response statusCode]);
		return FALSE;//Fix for #007177
	}
	
}

-(void)deleteAllCookies
{	
	for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
	{
		SMLog(kLogLevelVerbose,@"Cookie domain: %@", [cookie domain]);
		if([[cookie domain] Contains:@".salesforce.com"])
		{
			SMLog(kLogLevelVerbose,@"FOUND AND DELETED COOKIE");
			[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
		}
	}
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == 0 )
	{
		
    }
	
}


@end

@implementation OAuthClientInterface (UIWebViewIntegration)

- (void)authorizeUsingWebView:(UIWebView *)webView;
{
	[self authorizeUsingWebView:webView additionalParameters:nil];
}

- (void)authorizeUsingWebView:(UIWebView *)webView additionalParameters:(NSDictionary *)additionalParameters;
{
	[webView setDelegate:self];
	[self userAuthorizationRequestWithParameters:nil];
}


/**
 * custom URL schemes will typically cause a failure so we should handle those here
 */
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_3_2
	NSString *failingURLString = [error.userInfo objectForKey:NSErrorFailingURLStringKey];
#else
	NSString *failingURLString = [error.userInfo objectForKey:NSURLErrorFailingURLStringErrorKey];
	NSString *failureReason = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
#endif
	
	//Radha Defect Fix 7238
	[appDelegate removeBackgroundImageAndLogo];

	
	NSString *msg;
	if ( failureReason )
	{
		msg = failureReason;
	}else {
		msg = [NSString stringWithFormat:@"%d %@",[error code], [error localizedDescription]];
	}
	
	if ([failingURLString hasPrefix:self.redirectURL])
	{
		[webView stopLoading];
		[self extractAccessCodeFromCallbackURL:[NSURL URLWithString:failingURLString]];
	}
	else if ( [error code] != NSURLErrorCancelled )
	{
        if ( ![appDelegate isInternetConnectionAvailable] )
        {
            appDelegate.shouldShowConnectivityStatus = TRUE;
            [appDelegate displayNoInternetAvailable];
        }
        else
        {
            //Fix for Defect #:7089 - 15/May/2013
            NSString *cannotFindHostMsg = @"A server with the specified hostname could not be found.";
            
            if ([appDelegate.userOrg caseInsensitiveCompare:@"Custom"] == NSOrderedSame)
            {
                cannotFindHostMsg = @"A server with the specified hostname could not be found. Please check your custom host URL settings.";
            }
            
            _webViewDidFail = TRUE;
            UIAlertView *OAuthAlert = [[UIAlertView alloc] initWithTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:alert_application_error] message:cannotFindHostMsg delegate:self cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK] otherButtonTitles:nil, nil];
            
            [OAuthAlert show];
            [OAuthAlert release];
        }
		
		
	}
	loadFailedBool = YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	loadFailedBool = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	//Radha Defect Fix 7238
	if ( appDelegate.isUserOnAuthenticationPage == TRUE )
		[appDelegate removeBackgroundImageAndLogo];
    else if(![Utility notIOS7])
    {
        self.webview.frame = CGRectMake(0, 0, 1024, 768);
    }
        
	
	if ( !loadFailedBool )
		webViewDidFinishLoadBool = YES;
	
}


@end