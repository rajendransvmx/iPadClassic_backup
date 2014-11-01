//
//  RecentHomeViewController.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   SMSplitViewController.h
 *  @class  SMSplitViewController.m
 *
 *  @brief
 *
 *   To show the recently created objects.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "RecentHomeViewController.h"
#import "RecentDetailViewController.h"
#import "RecentMasterViewController.h"
#import "StyleManager.h"
#import "SyncManager.h"

@interface RecentHomeViewController ()

@end

@implementation RecentHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshRecent];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSyncFinished) name:kDataSyncStatusNotification object:nil];
    self.navigationItem.titleView = [UILabel navBarTitleLabel:@"Recents"];
    
    self.navigationController.navigationBar.barTintColor = [UIColor navBarBG]; //Only for iOS7.0 and more than 7.0
    self.navigationController.navigationBar.translucent = NO;
    
    RecentMasterViewController *masterViewController = [[RecentMasterViewController alloc]initWithStyle:UITableViewStylePlain];
    masterViewController.smSplitViewController = self;
    
    RecentDetailViewController *detailViewController = [[RecentDetailViewController alloc] initWithNibName:nil bundle:nil];
    detailViewController.smSplitViewController = self;
    
    UINavigationController *detailNavController = [[UINavigationController alloc]initWithRootViewController:detailViewController];
    detailNavController.navigationBar.hidden = YES;
    //detailNavController.navigationBar.translucent = NO;
    self.delegate = detailViewController;
    self.viewControllers = @[masterViewController,detailViewController];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dataSyncFinished
{
    [self refreshRecent];
}

- (void)refreshRecent
{
    RecentMasterViewController *recentMasterViewController = (RecentMasterViewController*)[self.viewControllers objectAtIndex:0];
    [recentMasterViewController refreshData];
    
    NSString *selectedObject = [recentMasterViewController.recentObjects objectAtIndex:recentMasterViewController.selectedIndexPath.row];
    NSMutableArray *recentModelArray = [recentMasterViewController.recentRecordDictionary objectForKey:selectedObject];
    
    RecentDetailViewController *recentDetailViewController = [self.viewControllers objectAtIndex:1];
    recentDetailViewController.recentItems = recentModelArray;
    [recentDetailViewController reloaData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
