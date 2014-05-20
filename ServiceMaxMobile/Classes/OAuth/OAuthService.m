//
//  OAuthService.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 4/15/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//
/**
 *  @file   OAuthService.h
 *  @class  OAuthService
 *
 *  @brief  OAuth related service implementations
 *
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "OAuthService.h"
#import "StringUtil.h"
#import "SBJsonParser.h"
#import "PlistManager.h"
#import "CustomerOrgInfo.h"

NSString *const kRedirectURL                 = @"sfdc://success";

static NSString *const kClientID                    = @"3MVG9VmVOCGHKYBRKMhA_p09I9xzela3emYDXjFy8a9UOXbcwI2nGsrOGc3RGGA08q4Q8X94lyZ.tIn.WWW71";
static NSString *const kClientSecret                = @"780972445943803573";
static NSString *const kAuthorizeTokenURL           = @"/services/oauth2/authorize";
static NSString *const kRevokeTokenURL              = @"/services/oauth2/revoke";
static NSString *const kRefreshTokenURL             = @"/services/oauth2/token";
static NSString *const kAuthorizationParamURLString = @"redirect_uri=%@&client_id=%@&response_type=token&state=mystate";
static NSString *const kRefreshTokenParamURLString  = @"grant_type=refresh_token&client_id=%@&client_secret=%@&refresh_token=%@";


// Service Names
static NSString *const kOAuthServiceRevokeToken     = @"revoke";
static NSString *const kOAuthServiceRefreshAccToken = @"refresh";
static NSString *const kOAuthServiceAuthorization   = @"Authorize";

@implementation OAuthService


/**
 * @name   authorizationURLString
 *
 * @author Vipindas Palli
 *
 * @brief  Generate url string for make OAuth Authorization service call
 *
 * \par
 *  <Longer description starts here>
 *
 * @return String value
 *
 */

+ (NSString *)authorizationURLString
{
    NSString *paramURLString = [NSString stringWithFormat:kAuthorizationParamURLString, kRedirectURL, kClientID];
    NSString *urlString      = [NSString stringWithFormat:@"%@%@?%@", [PlistManager baseURLString], kAuthorizeTokenURL, paramURLString];
    
    return urlString;
}

/**
 * @name   getRequestForService
 *
 * @author Vipindas Palli
 *
 * @brief  Service Request generator
 *
 * \par
 *  <Longer description starts here>
 *
 * @param serviceName Service Name
 *
 * @return NSMutableURLRequest object
 *
 */

+ (NSMutableURLRequest *)getRequestForService:(NSString *)serviceName
{
    NSString *serviceURI = nil;
    NSData     *postData = nil;
    NSString     *orgURL = nil;
    
    if ([kOAuthServiceRevokeToken isEqualToString:serviceName])
    {
        // Revoke Token
        serviceURI = kRevokeTokenURL;
        NSString *post      = [NSString stringWithFormat:@"token=%@", [[CustomerOrgInfo sharedInstance] refreshToken]];
        postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    }
    else if ([kOAuthServiceAuthorization isEqualToString:serviceName])
    {
        NSString *post = [NSString stringWithFormat:@"oauth_token=%@",[[CustomerOrgInfo sharedInstance] accessToken]];
        postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        orgURL   = [[CustomerOrgInfo sharedInstance] identityURL];
    }
    else
    {
        // Refresh Access Token
        serviceURI = kRefreshTokenURL;
        NSString *post   = [NSString stringWithFormat:kRefreshTokenParamURLString, kClientID, kClientSecret, [[CustomerOrgInfo sharedInstance] refreshToken]];
        
         postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    }

    if (orgURL == nil)
    {
        orgURL =  [NSString stringWithFormat:@"%@/%@", [PlistManager baseURLString], serviceURI];
    }
    
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:orgURL]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];

    return request;
}

/**
 * @name   refreshAccessToken
 *
 * @author Vipindas Palli
 *
 * @brief  Make Webservice call for refresh access token
 *
 * \par
 *  <Longer description starts here>
 *
 * @return bool value
 *
 */

+ (BOOL)refreshAccessToken
{
    BOOL hasRefreshedToken = NO;
    
	NSError          *error = nil;
	NSURLResponse *response = nil;

	NSData *urlData = [NSURLConnection sendSynchronousRequest:[[self class] getRequestForService:kOAuthServiceRefreshAccToken]
                                            returningResponse:&response
                                                        error:&error];
	
    if ( (error != nil) && [StringUtil containsString:@"NSURLErrorDomain" inString:error.domain])
    {
        /*
        UIAlertView *OAuthAlert = [[UIAlertView alloc] initWithTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:alert_application_error]
                                                             message:[error localizedDescription]
                                                            delegate:self
                                                   cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK]
                                                   otherButtonTitles:nil, nil];
        
        [OAuthAlert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
         */
        
        // TODO :- Vipin lets handle
    }
    else
    {
        NSString *responseString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *responseDictionary = [parser objectWithString:responseString];
        [parser release];
        parser = nil;
        [responseString release];
        responseString = nil;
        
         NSLog(@"RESPONSE WITH NEW ACCESS TOKENS : %@", responseDictionary);
         
         //Alert user incase of inability to get new access tokens via refresh token.
         if ([[responseDictionary valueForKey:@"error"] isEqualToString:@"invalid_grant"] )
         {
             if ([[responseDictionary valueForKey:@"error_description"] isEqualToString:@"inactive user"])
             {
                 return NO;
             }
             
             /*
             NSException *exp = nil;
             NSString *expName  = [appDelegate.wsInterface.tagsDictionary valueForKey:alert_connection_error];
             NSString *expReason = [appDelegate.wsInterface.tagsDictionary valueForKey:remote_access_error];
             
             NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"" forKey:@"userInfo"];
             
             NSArray *errKeys = [NSArray arrayWithObjects:@"ExpName",@"ExpReason",@"userInfo", nil];
             NSArray *errObjs = [NSArray arrayWithObjects:expName, expReason, userInfo, nil];
             
             NSMutableDictionary *errDict = [NSMutableDictionary dictionaryWithObjects:errObjs forKeys:errKeys];
             
             [appDelegate CustomizeAletView:nil alertType:RES_ERROR Dict:errDict exception:exp];
             */
             return NO;
         }
                 
         if ( responseDictionary && [responseDictionary valueForKey:@"access_token"] )
         {
             /*
             NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
             appDelegate.userOrg = [userDefaults valueForKey:@"preference_identifier"]; //Capture user org if Success :
             appDelegate.session_Id = nil;
             appDelegate.session_Id = [dict valueForKey:@"access_token"];
             
             //Replace the session Id in the user defaults :
             [userDefaults setObject:appDelegate.session_Id forKey:ACCESS_TOKEN];
             [userDefaults synchronize];
             
             hasRefreshedToken = YES;
              */
         }
    }
    
    return hasRefreshedToken;
}


/**
 * @name   revokeAccessToken
 *
 * @author Vipindas Palli
 *
 * @brief  Make Webservice call for revoke access token
 *
 * \par
 * Mentioned below error code 
 * 1. Code 200 - OK
 * 2. Code 401 - The session ID or OAuth token used has expired or is invalid.
 *  The response body contains the message and errorCode.
 * 3. Code 403 - The request has been refused. Verify that the logged-in user has appropriate permissions.
 *
 * Rest of the error code/message will inform user with response error message.
 * More details about error code:
 *   http://www.salesforce.com/us/developer/docs/api_rest/index_Left.htm#CSHID=errorcodes.htm|StartTopic=Content%2Ferrorcodes.htm|SkinName=webhelp
 *
 * @return bool value
 *
 */

+ (BOOL)revokeAccessToken
{
    BOOL hasRevokedToken = NO;

    NSString *refreshToken = [[CustomerOrgInfo sharedInstance] refreshToken];
    
    if ([StringUtil isStringEmpty:refreshToken])
    {
         // Yes, sending 'Yes' since we donot have existing token
        hasRevokedToken = YES;
    }
    else
    {
        NSError *error = nil;
        NSHTTPURLResponse *response = nil;
        
        NSData *urlData = [NSURLConnection sendSynchronousRequest:[[self class] getRequestForService:kOAuthServiceRevokeToken]
                                                returningResponse:&response
                                                            error:&error];
        
        if ( error )
        {
            /*
            UIAlertView *OAuthAlert = [[UIAlertView alloc] initWithTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:alert_application_error] message:[error localizedDescription] delegate:self cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK] otherButtonTitles:nil, nil];
            
            [OAuthAlert show];
            [OAuthAlert release];
            */
            // TODO :- vipin
        }
        
        NSString *data = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@ REVOKE STATUS : %d", data, [response statusCode]);
        
        if (([response statusCode] == 200)
            || ([response statusCode] == 401)
            || ([response statusCode] == 403))
        {
            hasRevokedToken = YES;
        }
        else
        {
            hasRevokedToken = NO;
            
            /*
            
            UIAlertView *OAuthRevokeAlert = [[UIAlertView alloc] initWithTitle:@"Application Error"
                                                                       message:@""
                                                                      delegate:self
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles:nil, nil];
            
            [OAuthRevokeAlert show];
            [OAuthRevokeAlert release];
             */
            
            // TODO :- vipin
        }
    }
    
    return hasRevokedToken;
}

/**
 * @name  deleteSalesForceCookies
 *
 * @author Vipindas Palli
 *
 * @brief Delete all salesforce related cookies from cookie storage
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Yes in case of success otherwise No
 *
 */

+ (BOOL)deleteSalesForceCookies
{
    BOOL deleted = NO;
    
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
	{
        if ([StringUtil containsString:@".salesforce.com" inString:[cookie domain]])
		{
            deleted = YES;
			[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
		}
	}
    
    return deleted;
}


+ (NSDictionary *)paramDictionaryFromParametersComponents:(NSArray *)components
{
    NSMutableDictionary *paramDictionary = [[NSMutableDictionary alloc] init];
    
    for (NSString *paramString in components)
    {
       NSArray *paramDetails = [paramString componentsSeparatedByString:@"="];
       NSString *key   = [paramDetails objectAtIndex:0];
        
       if ([key hasSuffix:@"access_token"])
       {
           key = @"access_token";
       }
        
       NSMutableString *value = [[NSMutableString alloc] init];
        
        for (int i = 1; i < [paramDetails count]; i++)
        {
            [value appendString:[paramDetails objectAtIndex:i]];
        }

        if (key != nil && value != nil)
        {
            [paramDictionary setObject:value forKey:key];
        }
        
        value = nil;
    }
    
    NSLog(@" paramDictionary :\n %@", paramDictionary);
    
   return paramDictionary;
}


+ (void)parseAndSaveCustomerOrgInfoFromResponse:(NSString *)jsonResponse
{
    NSLog(@" parseAndSaveCustomerOrgInfoFromResponse ----- %@", jsonResponse);
	SBJsonParser *parser = [[SBJsonParser alloc] init];
    
	NSDictionary *responseDictionary = [parser objectWithString:jsonResponse];
	
	NSDictionary *urlDict = [responseDictionary objectForKey:@"urls"];
	
	NSString *apiURL = [[urlDict objectForKey:@"partner"] stringByReplacingOccurrencesOfString:@"{version}"
                                                                                    withString:PREFFERED_API_VERSION];
	NSArray  *pathComponentsArray = [apiURL pathComponents];
    
	NSString *protocol = [pathComponentsArray objectAtIndex:0];
	NSString *hostName = [pathComponentsArray objectAtIndex:1];
	
	NSString *currentServerUrl = [NSString stringWithFormat:@"%@//%@", protocol, hostName];
    
    [PlistManager saveCustomerOrganisationInfo:responseDictionary];
    [PlistManager storeApiUrl:apiURL];
    [PlistManager storeInstanceUrl:currentServerUrl];
}

/**
 * @name   verifyAuthorization
 *
 * @author Vipindas Palli
 *
 * @brief  Make Web service call by using identity url and accessToken to verify authorization
 *
 * \par
 *  <Longer description starts here>
 *
 * @return void
 *
 */

+ (void)verifyAuthorization
{
    NSLog(@" verifyAuthorization -----");
	NSError *error = nil;
	NSURLResponse *response = nil;
		
	NSData *urlData = [NSURLConnection sendSynchronousRequest:[[self class] getRequestForService:kOAuthServiceAuthorization]
                                            returningResponse:&response
                                                        error:&error];
	if ( error != nil)
	{
		//[appDelegate removeBackgroundImageAndLogo];
		//[appDelegate showAlertForSyncFailure];

        [[AppManager sharedInstance] setErrorMessage:[error debugDescription]];
        [[AppManager sharedInstance] completedLoginProcessWithStatus:ApplicationStatusAuthorizationFailedWithError];
        NSLog(@" verifyAuthorization ----- return due to error");
		return;
	}
    
	NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
	NSLog(@" responseData - %@", responseData);

	if (responseData != nil)
	{
		[self parseAndSaveCustomerOrgInfoFromResponse:responseData];
        [PlistManager loadCustomerOrgInfo];
        [[AppManager sharedInstance] completedLoginProcessWithStatus:ApplicationStatusInAuthorizationVerificationCompleted];
	}
    else
    {
        [[AppManager sharedInstance] completedLoginProcessWithStatus:ApplicationStatusAuthorizationFailedWithError];
    }
}

/**
 * @name   extractAccessCodeFromCallbackURL
 *
 * @author Vipindas Palli
 *
 * @brief  Extract values from call back url
 *
 * \par
 *  <Longer description starts here>
 *
 * @return void
 *
 */

+ (void)extractAccessCodeFromCallbackURL:(NSURL *)callbackURL
{
	NSString *callBackURLString  = [callbackURL absoluteString];

    NSLog(@" callbackURL :%@", [callbackURL absoluteString]);
    
    if ([StringUtil containsString:@"error=access_denied" inString:callBackURLString])
	{
		NSLog(@"END USER DENIED AUTHORIZATION...");
		[[self class] deleteSalesForceCookies];
        
//		[appDelegate showSalesforcePage];
        // TODO :- vipin
	}
	else
	{
        /*
          Sample callback url Parameter array
         ---------------------------------
         
         "sfdc://success#access_token=00De0000001JIxe%21AQcAQAiueMAgzihv1Ybl_sKlIsu1rHMYPHhd3mN022Etf4O1eLCcwZmR7Z1pUU_wuM24Mr2cUxtq3x.POlgOoxKZFvfB5SPV",
         "refresh_token=5Aep861i3pidIObecE0.CywcjNt80JnmXnx_voOFptq400pynqBU9YC0ZczbY1jWV5.Tu9lDsuXaqnIUogWlgvd",
         "instance_url=https%3A%2F%2Fcs15.salesforce.com",
         "id=https%3A%2F%2Ftest.salesforce.com%2Fid%2F00De0000001JIxeEAG%2F005e00000013J6EAAU",
         "issued_at=1398495345039",
         "signature=or5oqm5FFH9AE5JWqsumgJzGryObLdyg9Z9cbzHKWGU%3D",
         "state=mystate",
         "scope=id+api+web+chatter_api+refresh_token",
         "token_type=Bearer"
        
         */
        
		if ( callBackURLString != nil)
		{
            NSArray *callBackParameters = [callBackURLString componentsSeparatedByString:@"&"];
            NSDictionary *paramDictionary = [[self class] paramDictionaryFromParametersComponents:callBackParameters];
            [PlistManager saveCallBackInformation:paramDictionary];
            [[self class]verifyAuthorization];
		}
	}
}

@end
