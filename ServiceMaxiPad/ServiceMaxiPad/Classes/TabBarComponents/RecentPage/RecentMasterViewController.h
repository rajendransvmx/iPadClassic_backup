//
//  RecentMasterViewController.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   RecentMasterViewController.h
 *  @class  RecentMasterViewController
 *
 *  @brief
 *
 *   This is the masterview controller for recents
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <UIKit/UIKit.h>
#import "SMSplitViewController.h"

@interface RecentMasterViewController : UITableViewController

@property(nonatomic,assign)SMSplitViewController *smSplitViewController;
@property(nonatomic,strong) NSMutableArray *recentObjects;
@property(nonatomic,strong) NSMutableDictionary *recentRecordDictionary;
@property(nonatomic,strong) NSIndexPath *selectedIndexPath;

- (id)initWithStyle:(UITableViewStyle)style;

- (void)refreshData;

@end
