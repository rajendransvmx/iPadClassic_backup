//
//  OauthConnectionHandler.h
//  ServiceMaxiPad
//
//  Created by Padmashree on 5/18/17.
//  Copyright © 2017 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    OauthConnectionNone,
    OauthConnectionLogin,
    OauthConnectionLogout,
    OauthConenctionRefreshToken,
    OauthConnectionVerifyAuth
} OauthConnectionType;

typedef void(^authCheckCompletion)(BOOL isSuccess, NSString *errorMsg);
typedef void(^revokeOauthCompletion)(BOOL isSuccess, NSError *error);
typedef void(^refreshTokenCompletion)(BOOL isSuccess, NSString *errorMsg);

@interface OauthConnectionHandler : NSObject<NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    
    
}

-(void)makeDummyCallForAuthenticationCheck:(NSURLRequest *)request andCompletion:(authCheckCompletion)completeBlock;
-(void)revokeAccessTokenWithCompletion:(revokeOauthCompletion)completeBlock;
-(void)verifyAuthorization;
-(void)refreshAccessTokenWithCompletion:(refreshTokenCompletion)completeBlock;

@end
