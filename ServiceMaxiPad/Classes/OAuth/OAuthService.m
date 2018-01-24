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
#import "PlistManager.h"
#import "CustomerOrgInfo.h"
#import "NSData+DDData.h"
#import "Utility.h"
#import "TagManager.h"

NSString *const kRedirectURL                        = @"sfdc://success";

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


static NSString *const kOAuthAccessToken            = @"access_token";
static NSInteger const kOAuthAccessTokenRefreshDurationInSec = 300; // 300 Seconds, Five minutes duration between two successfull refresh token

@implementation OAuthService


/**
 * @name   authorizationURLString
 *
 * @author Vipindas Palli
 *
 * @brief  Generate url string for make OAuth Authorization service call
 *
 * \par
 *  https://test.salesforce.com/services/oauth2/authorize?redirect_uri=sfdc://success&client_id=3MVG9VmVOCGHKYBRKMhA_p09I9xzela3emYDXjFy8a9UOXbcwI2nGsrOGc3RGGA08q4Q8X94lyZ.tIn.WWW71&response_type=token&state=mystate
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
        SXLogWarning(@" ServiceName :  %@ , uri : %@", serviceName, post);
    }
    else if ([kOAuthServiceAuthorization isEqualToString:serviceName])
    {
        NSString *post = [NSString stringWithFormat:@"oauth_token=%@",[[CustomerOrgInfo sharedInstance] accessToken]];
        postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        orgURL   = [[CustomerOrgInfo sharedInstance] identityURL];
        SXLogWarning(@" ServiceName :  %@ , uri : %@", serviceName, post);
    }
    else
    {
        // Refresh Access Token
        serviceURI = kRefreshTokenURL;
        NSString *refreshToken = [[CustomerOrgInfo sharedInstance] refreshToken];
        
        if (([StringUtil isStringEmpty:refreshToken]) || (refreshToken.length < 10))
        {
            SXLogWarning(@"Refresh token - invalid : %@", refreshToken);
            refreshToken = @"";
        }
        
        NSString *post   = [NSString stringWithFormat:kRefreshTokenParamURLString, kClientID, kClientSecret, refreshToken];
    
         postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
         SXLogWarning(@" ServiceName :  %@ , uri : %@", serviceName, post);
    }

    if (orgURL == nil)
    {
        orgURL =  [NSString stringWithFormat:@"%@%@", [PlistManager baseURLString], serviceURI];
    }
    
	NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:orgURL]];
	[request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
   
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
     if ([kOAuthServiceAuthorization isEqualToString:serviceName])
     {
         [request setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
         //NSData *compressedData = [postData gzipDeflate];
         //[request setHTTPBody:compressedData]; //IPAD-4597
     }
     else
     {
        [request setHTTPBody:postData];
     }
    
    // [request setHTTPBody:postData];
    if ([[CustomerOrgInfo sharedInstance] accessToken] != nil)
    {
        NSString *tokenWithPrefix = [@"OAuth " stringByAppendingString:[[CustomerOrgInfo sharedInstance] accessToken]];
        [request setValue:tokenWithPrefix forHTTPHeaderField:@"Authorization"];
    }
        
    [[self class] explainRequest:request
                 andResponseData:@"Request made. Waiting for response"];
    
    return request;
}



/**
 * @name   validateAndRefreshAccessToken:(NSError *)error
 *
 * @author Vipindas Palli
 *
 * @brief  Validate existing access token, if it is quiet old one make request for getting new one
 *
 * \par
 *  <Longer description starts here>
 *
 * @return bool value
 *
 */

+ (BOOL)validateAndRefreshAccessToken
{
    BOOL hasTokenValid = NO;
    
    BOOL shouldRefreshToken = [PlistManager shouldValidateAccessToken];
    
    if (!shouldRefreshToken) {
        hasTokenValid = YES;
        SXLogInfo(@"Do not validate");
    }
    else
    {
        NSInteger savedTokenBornTime = [PlistManager storedAccessTokenGeneratedTime];
        long long timeNow = (long long)[[NSDate date] timeIntervalSince1970];
        
        int diffTime  = (unsigned int)  (timeNow - savedTokenBornTime);
        
        SXLogInfo(@"Access token validity - %lld - %lld = %d", savedTokenBornTime, timeNow, diffTime);
        
        //if ((abs((NSInteger) timeNow - savedTokenBornTime) >  kOAuthAccessTokenRefreshDurationInSec)
        if ((abs(diffTime) >  kOAuthAccessTokenRefreshDurationInSec)
            || (savedTokenBornTime == 0))
        {
            SXLogInfo(@"Requesting for new access token");
            hasTokenValid = [self refreshAccessToken];
            
            if (hasTokenValid) {SXLogInfo(@"New  Access token recieved");}
            else {SXLogInfo(@"Access token failed");}
        }
        else
        {
            hasTokenValid = YES;
            
            SXLogInfo(@"Has valid token--");
        }
        
    }
    
    
    return hasTokenValid;
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

    @autoreleasepool {
        
        NSData *urlData = [NSURLConnection sendSynchronousRequest:[[self class] getRequestForService:kOAuthServiceRefreshAccToken]
                                                returningResponse:&response
                                                            error:&error];
        
        if ( (error != nil) && [StringUtil containsString:@"NSURLErrorDomain" inString:error.domain])
        {
            [PlistManager storeOAuthErrorMessage:error];
            
            NSString *responseString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
            
            SXLogInfo(@"Refresh Access Token failed response : %@", responseString);
        }
        else
        {
            NSString *responseString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
            NSDictionary *responseDictionary = [Utility objectFromJsonString:responseString];
            responseString = nil;
            
            SXLogInfo(@"Refresh Access Token response : %@", responseDictionary);
            
            //Alert user incase of inability to get new access tokens via refresh token.
            if ([[responseDictionary valueForKey:@"error"] isEqualToString:@"invalid_grant"] )
            {
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                
                [userInfo setObject:@"OAuthErrorDomain"   forKey:@"error_domain"];
                [userInfo setObject:@"invalid_grant"      forKey:@"error"];
                [userInfo setObject:@"RefreshAccessToken" forKey:@"ServiceType"];
                [userInfo setObject:@"Your remote access has been revoked. Please signout and re-authenticate." forKey:NSLocalizedDescriptionKey];
                
                if ([[responseDictionary valueForKey:@"error_description"] isEqualToString:@"inactive user"])
                {
                    [userInfo setObject:@"inactive user" forKey:@"error_description"];
                    
                    [[AppManager sharedInstance] setLoggedInUserStatus:UserStatusInactiveUser];
                }
                else if ([[responseDictionary valueForKey:@"error_description"] isEqualToString:@"expired access/refresh token"])
                {
                    [userInfo setObject:@"expired access/refresh token" forKey:@"error_description"];
                    [[AppManager sharedInstance] setApplicationStatusTokenExpired:ApplicationStatusTokenRevoked];
                }
                else
                {
                    [userInfo setObject:[responseDictionary valueForKey:@"error_description"] forKey:@"error_description"];
                    [[AppManager sharedInstance] setApplicationStatusTokenExpired:ApplicationStatusTokenRevoked];
                }
                
                NSError *error = [[NSError alloc] initWithDomain:@"OAuthErrorDomain"
                                                            code:2000
                                                        userInfo:userInfo];
                
                [PlistManager storeOAuthErrorMessage:error];
                
                userInfo = nil;
                error = nil;
            }
            
            //SXLogInfo(@"Refresh Token response : %@ ", [responseDictionary description]);
            
            if (   (responseDictionary != nil)
                && ([responseDictionary valueForKey:kOAuthAccessToken] != nil))
            {
                NSString *accessToken = [responseDictionary valueForKey:kOAuthAccessToken];
                
                [PlistManager saveAccessToken:accessToken];
                hasRefreshedToken = YES;
            }
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
    
    @autoreleasepool {
        
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
            
            if ( (error != nil) && [StringUtil containsString:@"NSURLErrorDomain" inString:error.domain])
            {
                [PlistManager storeOAuthErrorMessage:error];
            }
            else
            {
                NSString *data = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
                
                SXLogInfo(@"%@ Revoke Status : %d", data, [response statusCode]);
                
                if (([response statusCode] == 200)
                    || ([response statusCode] == 401)
                    || ([response statusCode] == 403))
                {
                    data = nil;
                    hasRevokedToken = YES;
                }
                else
                {
                    hasRevokedToken = NO;
                    
                    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                    
                    [userInfo setObject:@"OAuthErrorDomain"     forKey:@"error_domain"];
                    [userInfo setObject:@"RevokeAccessToken"    forKey:@"ServiceType"];
                    
                    [userInfo setObject:data        forKey:@"error"];
                    [userInfo setObject:response    forKey:@"response"];
                    
                    NSError *error = [[NSError alloc] initWithDomain:@"OAuthErrorDomain"
                                                                code:2100
                                                            userInfo:userInfo];
                    [PlistManager storeOAuthErrorMessage:error];
                    
                    userInfo = nil;
                    error = nil;
                    data = nil;
                    
                }
            }
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
    
    @autoreleasepool {
     
        for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
        {
            if ([StringUtil containsString:@".salesforce.com" inString:[cookie domain]])
            {
                deleted = YES;
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }
        }
    }

    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return deleted;
}


+ (NSDictionary *)paramDictionaryFromParametersComponents:(NSArray *)components
{
    NSMutableDictionary *paramDictionary = [[NSMutableDictionary alloc] init];
    
    @autoreleasepool {
        
        for (NSString *paramString in components)
        {
            NSArray *paramDetails = [paramString componentsSeparatedByString:@"="];
            NSString *key   = [paramDetails objectAtIndex:0];
            
            if ([key hasSuffix:kOAuthAccessToken])
            {
                key = kOAuthAccessToken;
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
    }
    
    //SXLogInfo(@"ParamDictionary :\n %@", paramDictionary);
    
   return paramDictionary;
}


+ (void)parseAndSaveCustomerOrgInfoFromResponse:(NSDictionary *)responseDictionary
{
    SXLogInfo(@"Parse n Save customer org Info from Response ----- %@", responseDictionary);
	//SBJsonParser *parser = [[SBJsonParser alloc] init];
    
	//NSDictionary *responseDictionary = [parser objectWithString:jsonResponse];
    
    if (responseDictionary != nil && [responseDictionary count] > 1)
    {
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
    else
    {
        
    }
}

+ (void)explainRequest:(NSMutableURLRequest *)request andResponseData:(NSString *)response
{
    NSString *requestData = [[NSString alloc]initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
    
    if (requestData == nil)
    {
        requestData = [[NSString alloc]initWithData:[request HTTPBody] encoding:NSASCIIStringEncoding];
    }
    
    SXLogInfo(@"Explain Request \n headers : %@  ", [[request allHTTPHeaderFields] description]);
    SXLogInfo(@"body : %@  ", requestData);
    SXLogInfo(@"url : %@  ", [[request URL] absoluteString]);
    SXLogInfo(@"Response : %@  ", response);
    requestData = nil;
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
    /**
     
     Sample Authorisation response data
     
     {"id":"https://test.salesforce.com/id/00DJ0000003KhyyMAC/005J0000001gwIyIAI",
     "asserted_user":true,
     "user_id":"005J0000001gwIyIAI",
     "organization_id":"00DJ0000003KhyyMAC",
     "username":"himanshi@qa11.com.cfg1",
     "nick_name":"himanshi.sharma",
     "display_name":"QA11 Cfg1 Himanshi",
     "email":"himanshi.sharma@servicemax.com",
     "email_verified":true,
     "first_name":"QA11 Cfg1",
     "last_name":"Himanshi",
     "timezone":"Asia/Kolkata",
     "photos":{"picture":"https://c.cs10.content.force.com/profilephoto/005/F",
     "thumbnail":"https://c.cs10.content.force.com/profilephoto/005T"},
     "addr_street":null,
     "addr_city":null,
     "addr_state":null,
     "addr_country":null,
     "addr_zip":null,
     "mobile_phone":null,
     "mobile_phone_verified":false,
     "status":{"created_date":null,"body":null},
     "urls":{"enterprise":"https://cs10.salesforce.com/services/Soap/c/{version}/00DJ0000003Khyy",
     "metadata":"https://cs10.salesforce.com/services/Soap/m/{version}/00DJ0000003Khyy",
     "partner":"https://cs10.salesforce.com/services/Soap/u/{version}/00DJ0000003Khyy",
     "rest":"https://cs10.salesforce.com/services/data/v{version}/",
     "sobjects":"https://cs10.salesforce.com/services/data/v{version}/sobjects/",
     "search":"https://cs10.salesforce.com/services/data/v{version}/search/",
     "query":"https://cs10.salesforce.com/services/data/v{version}/query/",
     "recent":"https://cs10.salesforce.com/services/data/v{version}/recent/",
     "profile":"https://cs10.salesforce.com/005J0000001gwIyIAI",
     "feeds":"https://cs10.salesforce.com/services/data/v{version}/chatter/feeds",
     "groups":"https://cs10.salesforce.com/services/data/v{version}/chatter/groups",
     "users":"https://cs10.salesforce.com/services/data/v{version}/chatter/users",
     "feed_items":"https://cs10.salesforce.com/services/data/v{version}/chatter/feed-items"},
     "active":true,
     "user_type":"STANDARD",
     "language":"en_US",
     "locale":"en_US",
     "utcOffset":19800000,
     "last_modified_date":"2014-07-18T09:25:01.000+0000",
     "is_app_installed":true}

     **/
    
	NSError *error = nil;
	NSURLResponse *response = nil;
    
    NSMutableURLRequest *request = [[self class] getRequestForService:kOAuthServiceAuthorization];
		
	NSData *urlData = [NSURLConnection sendSynchronousRequest:request
                                            returningResponse:&response
                                                        error:&error];
	if (error != nil)
	{
        [[AppManager sharedInstance] setErrorMessage:[error debugDescription]];
        [[AppManager sharedInstance] completedLoginProcessWithStatus:ApplicationStatusAuthorizationFailedWithError];
	}
    else
    {
        NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];

        if (responseData != nil)
        {
            [[self class] explainRequest:request andResponseData:responseData];
        
            NSDictionary *responseDictionary = [Utility objectFromJsonString:responseData];
            
            if ( (responseDictionary != nil) && ([responseDictionary count] > 1))
            {
                [self parseAndSaveCustomerOrgInfoFromResponse:responseDictionary];
                [PlistManager loadCustomerOrgInfo];
                [[AppManager sharedInstance] completedLoginProcessWithStatus:ApplicationStatusInAuthorizationVerificationCompleted];
            }
            else
            {
                [[self class] explainRequest:request andResponseData:responseData];
                [[AppManager sharedInstance] completedLoginProcessWithStatus:ApplicationStatusAuthorizationFailedWithError];
                
                // Vipin :  TODO whether to display error message or not ?
            }
            responseData = nil;
        }
        else
        {
            [[self class] explainRequest:request andResponseData:responseData];
            [[AppManager sharedInstance] completedLoginProcessWithStatus:ApplicationStatusAuthorizationFailedWithError];
        }
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

    //SXLogInfo(@" callbackURL :%@", [callbackURL absoluteString]);
    
    if ([StringUtil containsString:@"error=access_denied" inString:callBackURLString])
	{
		SXLogDebug(@"END USER DENIED AUTHORIZATION");
		[[self class] deleteSalesForceCookies];
        [[AppManager sharedInstance] completedLoginProcessWithStatus:ApplicationStatusAuthorizationFailedWithError];
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
            @autoreleasepool
            {
                NSArray *callBackParameters = [callBackURLString componentsSeparatedByString:@"&"];
                NSDictionary *paramDictionary = [[self class] paramDictionaryFromParametersComponents:callBackParameters];
                [PlistManager saveCallBackInformation:paramDictionary];
                [[self class]verifyAuthorization];
            }
		}
	}
}

/**
 * @name   lastError
 *
 * @author Vipindas Palli
 *
 * @brief  Last OAuth Error Message
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Error
 *
 */

+ (NSError *)lastError
{
    return [PlistManager lastOAuthErrorMessage];
}

/**
 * @name   authorizationURLString
 *
 * @author Vipindas Palli
 *
 * @brief  Clear stored OAuth error message
 *
 * \par
 *  <Longer description starts here>
 *
 * @return void
 *
 */

+ (void)clearOAuthErrorMessage
{
     [PlistManager resetOAuthError];
}

@end
