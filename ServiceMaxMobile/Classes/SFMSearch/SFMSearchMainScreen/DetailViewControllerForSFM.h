//
//  DetailViewControllerForSFM.h
//  SFMSearchTemplate
//
//  Created by Siva Manne on 10/04/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterViewController.h"
#define SectionHeaderHeight      45 
@class MasterViewController;
@class MainViewController;
@protocol DetailViewControllerMainDelegate;
@interface DetailViewControllerForSFM : UIViewController <UISplitViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (retain, nonatomic) id detailItem;
@property (nonatomic, retain) IBOutlet UITableView *detailTable;
@property (nonatomic, assign) id<DetailViewControllerMainDelegate> splitViewDelegate;
@property (nonatomic, retain) MasterViewController *masterView;
@property (nonatomic, assign) MainViewController *mainView;
- (void) searchButtonTapped:(id)sender withEvent:(UIEvent *) event;
@end
@protocol DetailViewControllerMainDelegate
@optional
- (void) DismissSplitViewController;
@end