//
//  SFMPageMasterViewController.h
//  ServiceMaxMobile
//
//  Created by Aparna on 01/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFMPageViewModel.h"
#import "SMSplitViewController.h"

@interface SFMPageMasterViewController : UIViewController

@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property(nonatomic, strong) SFMPageViewModel *sfmPageView;
@property(nonatomic, assign) SMSplitViewController *smSplitViewController;

- (void)resetData;

@end
