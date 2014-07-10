//
//  HTMLBrowser.h
//  iService
//
//  Created by Samman Banerjee on 02/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HTMLBrowser : UIViewController
<UIWebViewDelegate>
{
    IBOutlet UIWebView * webView;
    
    IBOutlet UIActivityIndicatorView * activity;
    
    IBOutlet UIButton * back, * forward;
    
    NSString * url;
}

@property (nonatomic, retain) NSString * url;

- (id) initWithURLString:(NSString *)_url;

- (IBAction) Close;

- (IBAction) goBack;
- (IBAction) goForward;

@end
