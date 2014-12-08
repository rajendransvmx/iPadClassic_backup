//
//  DetailParentViewController.h
//  FloatingTabTest
//
//  Created by Himanshi Sharma on 02/09/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMSplitViewController.h"
#import "StyleManager.h"


@interface DetailParentViewController : UIViewController<SMSplitViewControllerDelegate>

@property (nonatomic, weak) SMSplitViewController *smSplitViewController;
@property (nonatomic, strong) SMSplitPopover *smPopover;


@end
