//
//  SignUpController.h
//  iService
//
//  Created by Samman Banerjee on 02/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SignUpController : UIViewController
<UIWebViewDelegate>
{
    IBOutlet UIWebView * webView;
    
    IBOutlet UIActivityIndicatorView * activity;
    
    IBOutlet UIButton * back, * forward;
}

- (IBAction) Close;

- (IBAction) goBack;

@end
