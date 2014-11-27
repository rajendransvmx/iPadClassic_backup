//
//  SearchMasterViewController.h
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 07/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFMSearchViewController.h"

@interface SearchMasterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SearchViewControllerDelegate>

@property (nonatomic,weak)id  containerViewControlerDelegate;
@property (strong, nonatomic) IBOutlet UITableView *searchMasterTableView;
@property (strong, nonatomic) NSArray  *searchProcessArray;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

- (void)reloadData;

@end
