//
//  OAuthClientInterface.h
//  iService
//
//  Created by Shrinivas Desai on 03/01/13.
//
//

/*#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SBJsonParser.h"
#import "SFHFKeychainUtils.h"
#import "SVMXSystemConstant.h"


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
	UIWebView *webview;
	AppDelegate *appDelegate;
	UIImageView *servicemaxLogo; //Fix for defect #7539

	BOOL debug;
	NSMutableData *responseData;
	NSString *identityURL;
	
	BOOL loadFailedBool;
	BOOL webViewDidFinishLoadBool;
	BOOL _webViewDidFail;
	
	BOOL isVerifying;
    
   

}


@property (nonatomic, assign) BOOL isVerifying;
@property (nonatomic, strong) NSString *identityURL;
@property (nonatomic, strong) NSString *_accessToken;
@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) NSMutableData *responseData;

@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSString *clientSecret;
@property (nonatomic, strong) NSString *redirectURL;
@property (nonatomic, strong) NSURL *cancelURL;
@property (nonatomic, strong) NSURL *userURL;
@property (nonatomic, strong) NSString *tokenURL;
@property (nonatomic, assign) id<OAuth2ClientDelegate> delegate;
@property (nonatomic, assign) BOOL debug;

- (id)updateWithClientID:(NSString *)_clientID
                  secret:(NSString *)_secret
             redirectURL:(NSString *)url;

- (void)userAuthorizationRequestWithParameters:(NSDictionary *)additionalParameters;
- (void)verifyAuthorizationWithAccessCode:(NSString *)identityURL;
- (BOOL)refreshAccessToken:(NSString *)refresh_Token isInvokeByBackgroundProcess:(BOOL)isBackgroundProcess;
- (void)getEndPointUrlFromResponse:(NSString *)jsonResponse;
- (BOOL)revokeExistingToken:(NSString *)refresh_token; //7177
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

@end */
