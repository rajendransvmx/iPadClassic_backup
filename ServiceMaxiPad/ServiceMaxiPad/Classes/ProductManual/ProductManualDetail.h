//
//  ProductManualDetail.h
//  ServiceMaxiPad
//
//  Created by Chinnababu on 06/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMSplitViewController.h"
#import "FlowNode.h"


@interface ProductManualDetail : UIViewController<SMSplitViewControllerDelegate, FlowDelegate, UIWebViewDelegate>


@property (nonatomic, strong) IBOutlet UIButton *masterViewButton;
@property (nonatomic, strong) IBOutlet UIWebView *webView;

@property (nonatomic, strong) SMSplitViewController *smSplitViewController;

- (void)loadWebViewForTheProductName:(NSString *)productName;
- (void)setContentWithItem:(id)item;

@end
