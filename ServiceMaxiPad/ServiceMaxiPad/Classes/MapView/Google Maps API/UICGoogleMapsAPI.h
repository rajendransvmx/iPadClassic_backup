//
//  UICGoogleMapsAPI.h
//  ServiceMaxMobile
//
//  Created by Anoop on 9/15/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UICGPolyline, UICGoogleMapsAPI;

@protocol UICGoogleMapsAPIDelegate<NSObject>
@optional
- (void)goolgeMapsAPI:(UICGoogleMapsAPI *)goolgeMapsAPI didGetObject:(NSObject *)object;
- (void)goolgeMapsAPI:(UICGoogleMapsAPI *)goolgeMapsAPI didFailWithMessage:(NSString *)message;
@end

@interface UICGoogleMapsAPI : UIWebView<UIWebViewDelegate>
- (void)makeAvailable;
@end
