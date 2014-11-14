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

@interface TroubleshootingViewController: SMSplitViewController<FlowDelegate>

@property(nonatomic,strong) NSString *productId;
@property(nonatomic,strong) NSString *productName;

@end
