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
    NSLog(@"%s", __FUNCTION__);
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    NSLog(@"%s",__FUNCTION__);
}

- (UIViewController *)activityViewController
{
    NSLog(@"%s",__FUNCTION__);
    return nil;
}

- (void)performActivity
{
    
//    if ([_thirdPartyApp.urlParameters containsString:_thirdPartyApp.schemeName]) {
    if ([StringUtil containsString:_thirdPartyApp.schemeName inString:_thirdPartyApp.urlParameters]) {

        _thirdPartyApp.urlParameters = [_thirdPartyApp.urlParameters stringByReplacingOccurrencesOfString:_thirdPartyApp.schemeName withString:@""];
    }
    
//    if ([_thirdPartyApp.schemeName containsString:@"://"]) {
    if ([StringUtil containsString:@"://" inString:_thirdPartyApp.schemeName]) {

        _thirdPartyApp.schemeName =[_thirdPartyApp.schemeName stringByReplacingOccurrencesOfString:@"://" withString:@""];
    }
    
    NSData *pdfData = [NSData dataWithContentsOfFile:_thirdPartyApp.urlParameters];
    NSString *pdfString = [pdfData base64EncodedStringWithOptions:0];
    NSString *URLEncodedText = [pdfString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *string = [NSString stringWithFormat:@"%@://pdf?%@",_thirdPartyApp.schemeName,URLEncodedText];
    
    for (NSString *key in [_thirdPartyApp.parameterValueDict allKeys]) {
        
        
        string = [string stringByReplacingOccurrencesOfString:key withString:_thirdPartyApp.parameterValueDict[key]];
        
    }
    
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:string]])
    {

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];

        [self activityDidFinish:YES];
    }
    else
    {
        NSString *message = [NSString stringWithFormat:@"Please download %@ application to perform the task",_thirdPartyApp.appDisplayName];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Application found"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [self activityDidFinish:YES];
}

@end
