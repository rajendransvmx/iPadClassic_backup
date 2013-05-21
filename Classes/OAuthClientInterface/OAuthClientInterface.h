//
//  OAuthClientInterface.h
//  iService
//
//  Created by Shrinivas Desai on 03/01/13.
//
//

#import <UIKit/UIKit.h>
#import "iServiceAppDelegate.h"
#import "SBJsonParser.h"
#import "SFHFKeychainUtils.h"


@protocol OAuth2ClientDelegate;

@interface OAuthClientInterface : UIView <UIWebViewDelegate, NSURLConnectionDelegate, UIAlertViewDelegate>
{
	NSString *clientID;
	NSString *clientSecret;
	NSString *redirectURL;
	NSURL *cancelURL;
	NSURL *userURL;
	NSString *tokenURL;
	NSMutableArray *requests;
	NSString *_accessToken;
	id<OAuth2ClientDelegate> delegate;
	UIWebView *view;
	iServiceAppDelegate *appDelegate;

	BOOL debug;
	NSMutableData *responseData;
	NSString *identityURL;
	
	BOOL loadFailedBool;
	BOOL webViewDidFinishLoadBool;
	BOOL _webViewDidFail;
	
@private
	BOOL isVerifying;

}


@property (nonatomic, retain) NSString *identityURL;
@property (nonatomic, retain) NSString *_accessToken;
@property (nonatomic, retain) UIWebView *view;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, copy) NSString *clientID;
@property (nonatomic, copy) NSString *clientSecret;
@property (nonatomic, copy) NSString *redirectURL;
@property (nonatomic, copy) NSURL *cancelURL;
@property (nonatomic, copy) NSURL *userURL;
@property (nonatomic, copy) NSString *tokenURL;
@property (nonatomic, assign) id<OAuth2ClientDelegate> delegate;

@property (nonatomic, assign) BOOL debug;


- (id)initWithClientID:(NSString *)_clientID
                secret:(NSString *)_secret
           redirectURL:(NSString *)url;

- (void)userAuthorizationRequestWithParameters:(NSDictionary *)additionalParameters;
- (void)verifyAuthorizationWithAccessCode:(NSString *)identityURL;
- (BOOL)refreshAccessToken:(NSString *)refresh_Token;
- (void)getEndPointUrlFromResponse:(NSString *)jsonResponse;
- (void)revokeExistingToken:(NSString *)refresh_token;
- (void)extractAccessCodeFromCallbackURL:(NSURL *)url;
- (void)setUserLanguage:(NSString *)identity_URL;
- (void)deleteAllCookies;

@end

@interface OAuthClientInterface (UIWebViewIntegration) <UIWebViewDelegate>

- (void)authorizeUsingWebView:(UIWebView *)webView;
- (void)authorizeUsingWebView:(UIWebView *)webView additionalParameters:(NSDictionary *)additionalParameters;


@end

@protocol OAuth2ClientDelegate <UIWebViewDelegate>

@required
- (void)oauthClientDidReceiveAccessToken:(OAuthClientInterface *)client;
- (void)oauthClientDidRefreshAccessToken:(OAuthClientInterface *)client;

@optional
- (void)oauthClientDidReceiveAccessCode:(OAuthClientInterface *)client;
- (void)oauthClientDidCancel:(OAuthClientInterface *)client;

@end
