//
//  HelpController.h
//  iService
//
//  Created by Samman Banerjee on 02/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface HelpController : UIViewController
<UIWebViewDelegate>
{
    AppDelegate * appDelegate;
    
    IBOutlet UIWebView * webView;
    NSString * helpString;
    BOOL isPortrait;
    
    IBOutlet UIActivityIndicatorView * activity;
    IBOutlet UIImageView *navigationBarImgView;
    IBOutlet UIImageView *logoImageView;
    IBOutlet UIButton *backButton;
    IBOutlet UIImageView *backGroundImageView;
}

@property (nonatomic, retain) NSString * helpString;
@property BOOL isPortrait;
@property (nonatomic,retain)IBOutlet UIImageView *navigationBarImgView;
@property (nonatomic,retain) IBOutlet UIImageView *logoImageView;
@property (nonatomic,retain) IBOutlet UIButton *backButton;
@property (nonatomic,retain) IBOutlet UIImageView *backGroundImageView;

- (IBAction) Done;

@end
