//
//  TroubleShootMasterViewController.h
//  ServiceMaxMobile
//
//  Created by Chinnababu on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMSplitViewController.h"

@interface TroubleshootingMasterViewController: UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property(nonatomic,assign)SMSplitViewController *smSplitViewController;
@property (strong, nonatomic) IBOutlet UITableView *troubleshootTableView;
@property(nonatomic,strong) NSString *productId;
@property(nonatomic,strong) NSString *productName;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property(nonatomic, strong)NSArray *productDetailsArray;

@end
