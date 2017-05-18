//
//  OauthConnectionHandler.m
//  ServiceMaxiPad
//
//  Created by Padmashree on 5/18/17.
//  Copyright © 2017 ServiceMax Inc. All rights reserved.
//

#import "OauthConnectionHandler.h"
#import "AFSecurityPolicy.h"
#import "CustomerOrgInfo.h"
#import "StringUtil.h"
#import "OAuthService.h"
#import "Utility.h"
#import "PlistManager.h"

@interface OauthConnectionHandler () {
    OauthConnectionType connectionType;
    NSMutableData *oauthResponseData;
}

@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;
@property (nonatomic, copy) authCheckCompletion authCheckCompletionHandler;
@property (nonatomic, copy) revokeOauthCompletion revokeOauthCompletionHandler;
@property (nonatomic, copy) refreshTokenCompletion refreshTokenCompletionHandler;
@property (nonatomic, strong) NSURLResponse *logoutResponse;

@end

@implementation OauthConnectionHandler

-(void)makeDummyCallForAuthenticationCheck:(NSURLRequest *)request andCompletion:(authCheckCompletion)completeBlock
{
    self.authCheckCompletionHandler = completeBlock;
    connectionType = OauthConnectionLogin;
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}



-(void)revokeAccessTokenWithCompletion:(revokeOauthCompletion)completeBlock
{
    self.revokeOauthCompletionHandler = completeBlock;
    
    NSString *refreshToken = [[CustomerOrgInfo sharedInstance] refreshToken];
    
    if ([StringUtil isStringEmpty:refreshToken])
    {
        self.revokeOauthCompletionHandler(YES, nil);
    }
    else
    {
        
        // PS SP revoke token
        NSMutableURLRequest *urlRequest = [OAuthService getRequestForService:kOAuthServiceRevokeToken];
        [self performSelectorOnMainThread:@selector(makeLogOutCallOnMainThread:) withObject:urlRequest waitUntilDone:NO];
    }
    
}

-(void)makeLogOutCallOnMainThread:(NSURLRequest *)request {
    connectionType = OauthConnectionLogout;
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];}


-(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if (!self.securityPolicy) {
            
            BOOL isPinningEnabled = [Utility isSSLPinningEnabled];
            
            if(isPinningEnabled) {
                self.securityPolicy = [AFSecurityPolicy policyWithPinningMode:(AFSSLPinningModePublicKey)];
            }
            else {
                self.securityPolicy = [AFSecurityPolicy defaultPolicy];
            }
        }
        if ([self.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust]) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
        } else {
            [[challenge sender] cancelAuthenticationChallenge:challenge];
            
        }
    } else {
        [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}


-(void)verifyAuthorization
{
    // PCRD-220
    NSMutableURLRequest *request = [OAuthService getRequestForService:kOAuthServiceAuthorization];
    
    connectionType = OauthConnectionVerifyAuth;
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}


-(void)refreshAccessTokenWithCompletion:(refreshTokenCompletion)completeBlock
{
    // PS SP refresh token
    
    self.refreshTokenCompletionHandler = completeBlock;
    
    NSMutableURLRequest *request = [OAuthService getRequestForService:kOAuthServiceRefreshAccToken];
    [self performSelectorOnMainThread:@selector(makeRefreshTokenCallOnMainThread:) withObject:request waitUntilDone:NO];
}

-(void)makeRefreshTokenCallOnMainThread:(NSURLRequest *)request
{
    connectionType = OauthConenctionRefreshToken;
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    switch (connectionType) {
        case OauthConnectionLogin:
        {
            self.authCheckCompletionHandler(NO, [error localizedDescription]);
        }
            break;
        case OauthConnectionLogout:
        {
            if ((error != nil) && [StringUtil containsString:@"NSURLErrorDomain" inString:error.domain])
            {
                [PlistManager storeOAuthErrorMessage:error];
            }
            self.revokeOauthCompletionHandler(NO, error);
        }
            break;
        case OauthConenctionRefreshToken:
        {
            if ( (error != nil) && [StringUtil containsString:@"NSURLErrorDomain" inString:error.domain])
            {
                [PlistManager storeOAuthErrorMessage:error];
                SXLogInfo(@"Refresh Access Token failed response : %@", [error localizedDescription]);
            }
            self.refreshTokenCompletionHandler(NO, [error localizedDescription]);
            oauthResponseData = nil;
        }
            break;
        case OauthConnectionVerifyAuth:
        {
            [[AppManager sharedInstance] setErrorMessage:[error debugDescription]];
            [[AppManager sharedInstance] completedLoginProcessWithStatus:ApplicationStatusAuthorizationFailedWithError];
            oauthResponseData = nil;
        }
            break;
        default:
            break;
    }
    connectionType = OauthConnectionNone;
    
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    switch (connectionType) {
        case OauthConnectionLogin:
        {
            self.authCheckCompletionHandler(YES, nil);
            [connection cancel];
            connection = nil;
        }
            break;
        case OauthConnectionLogout:
        {
            self.logoutResponse = response;
        }
            
            break;
        case OauthConenctionRefreshToken:
        {
            
            
        }
            break;
        case OauthConnectionVerifyAuth:
        {
            
        }
            break;
        default:
            break;
    }
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    switch (connectionType) {
        case OauthConnectionLogin:
            break;
        case OauthConnectionLogout:
            break;
        case OauthConenctionRefreshToken:
        {
            if (!oauthResponseData) {
                oauthResponseData = [[NSMutableData alloc] init];
            }
            [oauthResponseData appendData:data];
        }
            break;
        case OauthConnectionVerifyAuth:
        {
            if (!oauthResponseData) {
                oauthResponseData = [[NSMutableData alloc] init];
            }
            [oauthResponseData appendData:data];
        }
            break;
        default:
            break;
    }
    
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    switch (connectionType) {
        case OauthConnectionLogin:
            
            break;
        case OauthConnectionLogout:
        {
            if (self.logoutResponse) {
                
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)self.logoutResponse;
                NSString *responseMessage = [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode];
                SXLogInfo(@"%@ REVOKE STATUS : %ld", responseMessage, (long)[httpResponse statusCode]);
                
                if (([httpResponse statusCode] == 200)
                    || ([httpResponse statusCode] == 401)
                    || ([httpResponse statusCode] == 403))
                {
                    responseMessage = nil;
                    self.revokeOauthCompletionHandler(true, nil);
                }
                else
                {
                    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                    
                    [userInfo setObject:@"OAuthErrorDomain"     forKey:@"error_domain"];
                    [userInfo setObject:@"RevokeAccessToken"    forKey:@"ServiceType"];
                    
                    [userInfo setObject:responseMessage        forKey:@"error"];
                    [userInfo setObject:httpResponse    forKey:@"response"];
                    
                    NSError *error = [[NSError alloc] initWithDomain:@"OAuthErrorDomain"
                                                                code:2100
                                                            userInfo:userInfo];
                    [PlistManager storeOAuthErrorMessage:error];
                    
                    userInfo = nil;
                    error = nil;
                    
                    self.revokeOauthCompletionHandler(false, nil);
                }
            }
            else {
                self.revokeOauthCompletionHandler(false, nil);
            }
            
            self.logoutResponse = nil;
            
        }
            break;
        case OauthConenctionRefreshToken:
        {
            if (oauthResponseData)
            {
                NSString *responseString = [[NSString alloc] initWithData:oauthResponseData encoding:NSUTF8StringEncoding];
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
                    self.refreshTokenCompletionHandler(NO, [responseDictionary valueForKey:@"error_description"]);

                }
                else
                {
                    //SXLogInfo(@"Refresh Token response : %@ ", [responseDictionary description]);
                    
                    if ((responseDictionary != nil) && ([responseDictionary valueForKey:kOAuthAccessToken] != nil))
                    {
                        NSString *accessToken = [responseDictionary valueForKey:kOAuthAccessToken];
                        [PlistManager saveAccessToken:accessToken];
                    }
                    self.refreshTokenCompletionHandler(YES, nil);
                }
            }
            else
            {
                self.refreshTokenCompletionHandler(NO, @"error");

            }
            oauthResponseData = nil;
        }
            
            break;
        case OauthConnectionVerifyAuth:
        {
            if (oauthResponseData)
            {
                
                NSString *responseData = [[NSString alloc]initWithData:oauthResponseData encoding:NSUTF8StringEncoding];
                
                if (responseData != nil)
                {
                    NSDictionary *responseDictionary = [Utility objectFromJsonString:responseData];
                    
                    if ( (responseDictionary != nil) && ([responseDictionary count] > 1))
                    {
                        [OAuthService parseAndSaveCustomerOrgInfoFromResponse:responseDictionary];
                        [PlistManager loadCustomerOrgInfo];
                        [[AppManager sharedInstance] completedLoginProcessWithStatus:ApplicationStatusInAuthorizationVerificationCompleted];
                    }
                    else
                    {
                        [[AppManager sharedInstance] completedLoginProcessWithStatus:ApplicationStatusAuthorizationFailedWithError];
                        // Vipin :  TODO whether to display error message or not ?
                    }
                    responseData = nil;
                }
                else
                {
                    [[AppManager sharedInstance] completedLoginProcessWithStatus:ApplicationStatusAuthorizationFailedWithError];
                }
            }
            else
            {
                
            }
            oauthResponseData = nil;
        }
            break;
        default:
            break;
    }
    connectionType = OauthConnectionNone;
}



@end
