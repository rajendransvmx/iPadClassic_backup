//
//  TroubleshootingHomeViewController.h
//  ServiceMaxMobile
//
//  Created by Chinnababu on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SMSplitViewController.h"
#import <UIKit/UIKit.h>
#import "FlowNode.h"
#import "ActionDisplayTableViewController.h"


@interface TroubleshootingViewController: SMSplitViewController<FlowDelegate>

@property (nonatomic, strong) NSString *productId;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) UIPopoverController *popOver;
@property (nonatomic, strong) ActionDisplayTableViewController *tempViewController;



@end
