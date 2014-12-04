//
//  SFMPageDetailViewController.h
//  ServiceMaxMobile
//
//  Created by Aparna on 01/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMSplitViewController.h"
#import "SFMPageViewModel.h"
#import "SFMPageLayoutViewController.h"



@interface SFMPageDetailViewController : UIViewController<SMSplitViewControllerDelegate, UITextViewDelegate>
@property (nonatomic, assign) SMSplitViewController *smSplitViewController;
@property(nonatomic, strong) UIViewController *pageDetailChildViewController;

- (void)setContentWithItem:(id)item;

- (void)refreshSFmPageData:(SFMPageViewModel*)pageViewModel;

@end
