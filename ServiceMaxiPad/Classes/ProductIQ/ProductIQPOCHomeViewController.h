//
//  ProductIQPOCHomeViewController.h
//  ServiceMaxiPad
//
//  Created by Admin on 25/08/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bridge.h"

@interface ProductIQPOCHomeViewController : UIViewController <UIWebViewDelegate, UINavigationControllerDelegate>
{
    NSString *clientId;
    NSString *callbackUrl;
    NSString *nativeCallUrl;
    NSString *loginUrl;
    UIWebView *webview;
    
    BOOL authenticated;
    Bridge *bridge;
    
    NSString *accessToken, *instanceUrl;
}

@property(nonatomic,retain) NSMutableDictionary *responseDictionary;

+(ProductIQPOCHomeViewController *) getInstance;
-(NSString *) getAccessToken;
-(NSString *) getInstanceUrl;
-(UIWebView *) getBrowser;


@end
