//
//  TroubleShootMasterViewController.h
//  ServiceMaxMobile
//
//  Created by Chinnababu on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMSplitViewController.h"
#import "FlowNode.h"

@interface TroubleshootingMasterViewController: UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,FlowDelegate>

@property(nonatomic,assign) SMSplitViewController *smSplitViewController;

@property(nonatomic,strong) NSString *productId;
@property(nonatomic,strong) NSString *productName;
@property(nonatomic,strong) NSArray  *productDetailsArray;

@property(nonatomic,strong) IBOutlet UISearchBar *searchBar;
@property(nonatomic,strong) IBOutlet UITableView *troubleshootTableView;

- (void)setDetailButtonTitle:(NSString *)title;

@end
