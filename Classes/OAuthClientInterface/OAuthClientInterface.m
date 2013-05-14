//
//  OAuthClientInterface.m
//  iService
//
//  Created by Shrinivas Desai on 03/01/13.
//
//

#import "OAuthClientInterface.h"


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
@synthesize view;
@synthesize _accessToken;
@synthesize identityURL;


- (void)dealloc;
{
	[clientID release];
	[clientSecret release];
	[userURL release];
	[redirectURL release];
	[cancelURL release];
	[view release];
	[super dealloc];
	
}


- (id)initWithClientID:(NSString *)_clientID
                secret:(NSString *)_secret
           redirectURL:(NSString *)url;
{
	appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (self = [super init]) {
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
		 appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *post = nil;
	
	post = [NSString stringWithFormat:@"redirect_uri=%@&client_id=%@&response_type=token&state=mystate",
					  redirectURL,
					  clientID];
	
	tokenURL = [NSString stringWithFormat:@"%@%@?%@",[ZKServerSwitchboard baseURL], _TOKEN_URL, post];

	if (self.view)
	{
		[self.view release];
		self.view = nil;
	}
	
	self.view = [[UIWebView alloc] init];	
	view.delegate = self;

	NSURL *url = [NSURL URLWithString:tokenURL];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	
	[view setScalesPageToFit:YES];
	[view loadRequest:request]; 
	while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
	{
		if (![appDelegate isInternetConnectionAvailable])
		{
			appDelegate.shouldShowConnectivityStatus = YES;
			[appDelegate displayNoInternetAvailable];
			
			return;
		}
		
		if ( webViewDidFinishLoadBool == YES )
			break;
	}

	view.backgroundColor = [UIColor clearColor];
	self.view.opaque = NO;
	
	view.frame = CGRectMake(0, 0, 1024, 785);
	appDelegate.isUserOnAuthenticationPage = TRUE;
	appDelegate.userOrg = [userDefaults valueForKey:@"preference_identifier"]; //Capture user org if Success :
		
}


- (void)verifyAuthorizationWithAccessCode:(NSString *)_identityURL;
{
	@synchronized(self) {
		if (isVerifying) return; // don't allow more than one oauth request
		
		isVerifying = YES;
		
		NSString *post = [NSString stringWithFormat:@"oauth_token=%@",appDelegate.session_Id];
		NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
		NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
		
		NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
		[request setURL:[NSURL URLWithString:_identityURL]];
		[request setHTTPMethod:@"POST"];
		[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		[request setHTTPBody:postData];
		
		NSError *error = nil;
		NSURLResponse *response = nil;
		
		NSLog(@"%@", request);
		
		NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		
		if ( error )
		{
			UIAlertView *OAuthAlert = [[UIAlertView alloc] initWithTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:alert_application_error] message:[error localizedDescription] delegate:self cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK] otherButtonTitles:nil, nil];
			
			[OAuthAlert show];
			[OAuthAlert release];
			
		}

		NSString *data=[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
		NSLog(@"%@", data);
		
		isVerifying = NO;
		if ( data )
		{
			[self getEndPointUrlFromResponse:data];
		}
		
	}
}


- (void)getEndPointUrlFromResponse:(NSString *)jsonResponse
{
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *dict = [parser objectWithString:jsonResponse];
	NSLog(@"JSON RESPNSE WITH END POINT URLS : %@", dict);
	
	NSDictionary *urlDict = [dict objectForKey:@"urls"];
	
	appDelegate.apiURl = [[urlDict objectForKey:@"partner"] stringByReplacingOccurrencesOfString:@"{version}" withString:PREFFERED_API_VERSION];
	appDelegate.currentServerUrl =[[urlDict objectForKey:@"partner"] substringToIndex:31];
	appDelegate.current_userId = [dict objectForKey:@"user_id"];
	appDelegate.userProfileId = [dict objectForKey:@"user_id"];
	appDelegate.currentUserName = [dict valueForKey:@"username"];
	appDelegate.username = [dict valueForKey:@"username"];
	appDelegate.organization_Id = [dict valueForKey:@"organization_id"];
	appDelegate.language = [dict valueForKey:@"language"];
	appDelegate.loggedInUserId = [dict objectForKey:@"user_id"];
	
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
	
	NSLog(@"%@", request);
	
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if ( error )
	{
		UIAlertView *OAuthAlert = [[UIAlertView alloc] initWithTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:alert_application_error] message:[error localizedDescription] delegate:self cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK] otherButtonTitles:nil, nil];
		
		[OAuthAlert show];
		[OAuthAlert release];
	}
	
	NSString *data=[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
	NSLog(@"%@", data);
		
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
	
	if ( ![appDelegate isInternetConnectionAvailable] )
	{
		appDelegate.shouldShowConnectivityStatus = TRUE;
		[appDelegate displayNoInternetAvailable];
		
		return NO;
	}
	
	NSLog(@"%@", request);
	
	if ([[request.URL absoluteString] hasPrefix:redirectURL])
	{
		[webView stopLoading];
		[self extractAccessCodeFromCallbackURL:request.URL];
		return NO;
	}
	
	if ( [[request.URL absoluteString] Contains:@"oauth_error_code=1800"] )
	{
		[self deleteAllCookies];
		[self userAuthorizationRequestWithParameters:nil];
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
			NSArray *array = [url componentsSeparatedByString:@"&"];
			
			appDelegate.session_Id = [[[array objectAtIndex:0] componentsSeparatedByString:@"="] objectAtIndex:1];
			appDelegate.session_Id = [appDelegate.session_Id stringByReplacingOccurrencesOfString:@"%21" withString:@"!"];
			
			appDelegate.refresh_token = [[[array objectAtIndex:1] componentsSeparatedByString:@"="] objectAtIndex:1];
			appDelegate.refresh_token = [appDelegate.refresh_token stringByReplacingOccurrencesOfString:@"%3D" withString:@"="];
			
			identityURL = [[[array objectAtIndex:3] componentsSeparatedByString:@"="] objectAtIndex:1];
			identityURL = [identityURL stringByReplacingOccurrencesOfString:@"%3A" withString:@":"];
			identityURL = [identityURL stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
			
			[self verifyAuthorizationWithAccessCode:identityURL];

		}

	}
	
}

//POST REQUEST TO REFRESH THE ACCESS TOKENS USING REFRESH TOKENS.
- (BOOL)refreshAccessToken:(NSString *)refresh_Token;
{
	if ( appDelegate == nil )
		 appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
	
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
	
	NSLog(@"%@", request);
	
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if ( error && [appDelegate isInternetConnectionAvailable])
	{
		UIAlertView *OAuthAlert = [[UIAlertView alloc] initWithTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:alert_application_error] message:[error localizedDescription] delegate:self cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK] otherButtonTitles:nil, nil];
		
		[OAuthAlert show];
		[OAuthAlert release];
		
	}

	NSString *data=[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
	NSLog(@"%@", data);
	
	SBJsonParser *parser = [[SBJsonParser alloc] init];
	NSDictionary *dict = [parser objectWithString:data];
	
	NSLog(@"RESPONSE WITH NEW ACCESS TOKENS : %@", dict);

	//Alert user incase of inability to get new access tokens via refresh token.
	if ( [[dict valueForKey:@"error"] isEqualToString:@"invalid_grant"] )
	{
		NSException *exp;
		NSString *ExpName = [appDelegate.wsInterface.tagsDictionary valueForKey:alert_connection_error];
		NSString *ExpReason = @"Your remote access has been revoked.Please navigate back to the home screen to logout and re-authenticate.";
		NSString *userInfo = [NSDictionary dictionaryWithObject:@"" forKey:@"userInfo"];
		
		NSArray *errKeys = [NSArray arrayWithObjects:@"ExpName",@"ExpReason",@"userInfo", nil];
		NSArray *errObjs = [NSArray arrayWithObjects:ExpName, ExpReason, userInfo, nil];
		
		NSMutableDictionary *errDict = [NSMutableDictionary dictionaryWithObjects:errObjs forKeys:errKeys];
		
		[appDelegate CustomizeAletView:nil alertType:RES_ERROR Dict:errDict exception:exp];
		
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
- (void)revokeExistingToken:(NSString *)refresh_token
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
	
	NSLog(@"%@", request);
	
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if ( error )
	{
		UIAlertView *OAuthAlert = [[UIAlertView alloc] initWithTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:alert_application_error] message:[error localizedDescription] delegate:self cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK] otherButtonTitles:nil, nil];
		
		[OAuthAlert show];
		[OAuthAlert release];
		
	}

	NSString *data=[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
	
	NSLog(@"%@ REVOKE STATUS : %d", data, [response statusCode]);
	
	if ( [response statusCode] == 200)
	{
		NSLog(@"Sucessfully Revoked the Tokens..");
		
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
		NSLog(@"Failed Revoking the Tokens...");

}

-(void)deleteAllCookies
{	
	for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
	{
		NSLog(@"Cookie domain: %@", [cookie domain]);
		if([[cookie domain] Contains:@".salesforce.com"])
		{
			NSLog(@"FOUND AND DELETED COOKIE");
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
	
	NSString *msg;
	if ( failureReason )
	{
		msg = failureReason;
	}else {
		msg = [NSString stringWithFormat:@"%@. %d %@",[appDelegate.wsInterface.tagsDictionary valueForKey:@"Operation could not be completed."], [error code], [error localizedDescription]];
	}
	
	if ([failingURLString hasPrefix:self.redirectURL])
	{
		[webView stopLoading];
		[self extractAccessCodeFromCallbackURL:[NSURL URLWithString:failingURLString]];
	}
	else if ( [error code] != NSURLErrorCancelled )
	{
		UIAlertView *OAuthAlert = [[UIAlertView alloc] initWithTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:alert_application_error] message:msg delegate:self cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_retry] otherButtonTitles:nil, nil];
		
		[OAuthAlert show];
		[OAuthAlert release];
		
	}
	loadFailedBool = YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	loadFailedBool = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	
	if ( !loadFailedBool )
		webViewDidFinishLoadBool = YES;
	
}


@end
