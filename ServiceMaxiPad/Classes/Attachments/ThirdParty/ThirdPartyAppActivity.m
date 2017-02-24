//
//  ThirdPartyAppActivity.m
//  ServiceMaxiPad
//
//  Created by Krishna Shanbhag on 18/05/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "ThirdPartyAppActivity.h"
#import "Base64.h"
#import "SFMPageHelper.h"
#import "StringUtil.h"

@implementation ThirdPartyAppActivity

- (instancetype)initWithThirdPartyApp:(ThirdPartyApp *)appInfo {
    if(self = [super init]) {
        
        _thirdPartyApp = appInfo;
    }
    return self;
}

- (NSString *)activityType
{
    return @"";
}

- (NSString *)activityTitle
{
    return _thirdPartyApp.appDisplayName;
}

- (UIImage *)activityImage
{
    // Note: These images need to have a transparent background and I recommend these sizes:
    // iPadShare@2x should be 126 px, iPadShare should be 53 px, iPhoneShare@2x should be 100
    // px, and iPhoneShare should be 50 px. I found these sizes to work for what I was making.
    
    UIImage *image  = [UIImage imageNamed:@"orangeCircle.png"];
    return image;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
}

- (UIViewController *)activityViewController
{
    return nil;
}


@end
