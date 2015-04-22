//
//  TroubleShootDetailViewController.h
//  ServiceMaxMobile
//
//  Created by Chinnababu on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMSplitViewController.h"
#import "FlowNode.h"

@interface TroubleshootingDetailViewController : UIViewController
<SMSplitViewControllerDelegate, FlowDelegate, UIWebViewDelegate>

@property(strong, nonatomic) IBOutlet UIButton *masterViewButton;
@property(strong, nonatomic) IBOutlet UIWebView *webView;

@property(nonatomic,assign) SMSplitViewController *smSplitViewController;

- (void)loadWebViewForThedocId:(NSString *)docId
        andThedocName:(NSString *)docName;
- (void)setContentWithItem:(id)item;

@end
