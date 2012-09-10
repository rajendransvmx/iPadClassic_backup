//
//  HelpController.h
//  iService
//
//  Created by Samman Banerjee on 02/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iServiceAppDelegate.h"

@interface HelpController : UIViewController
<UIWebViewDelegate>
{
    iServiceAppDelegate * appDelegate;
    
    IBOutlet UIWebView * webView;
    NSString * helpString;
    BOOL isPortrait;
    
    IBOutlet UIActivityIndicatorView * activity;
}

@property (nonatomic, retain) NSString * helpString;
@property BOOL isPortrait;

- (IBAction) Done;

@end
