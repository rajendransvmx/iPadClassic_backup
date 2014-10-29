//
//  RecentDetailViewController.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   RecentDetailViewController.h
 *  @class  RecentDetailViewController
 *
 *  @brief
 *
 *   This is the detail view controller for recents
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <UIKit/UIKit.h>
#import "SMSplitViewController.h"
#import "SFObjectModel.h"

@interface RecentDetailViewController : UITableViewController<SMSplitViewControllerDelegate>

@property(nonatomic,assign)SMSplitViewController *smSplitViewController;
@property(nonatomic,strong)SFObjectModel *selectedObject;

- (void)reloaData;

@end
