//
//  ProductManualMaster.h
//  ServiceMaxiPad
//
//  Created by Chinnababu on 06/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMSplitViewController.h"

@interface ProductManualMaster : UIViewController
<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) SMSplitViewController *smSplitViewController;
@property (nonatomic, strong) NSArray *productDetailsArray;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
