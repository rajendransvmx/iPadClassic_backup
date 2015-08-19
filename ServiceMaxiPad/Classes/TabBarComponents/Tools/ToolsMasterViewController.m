//
//  ToolsMasterViewController.m
//  ServiceMaxiPad
//
//  Created by Padmashree on 01/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ToolsMasterViewController.h"
#import "TagManager.h"
#import "SyncStatusDetailViewController.h"
#import "ResolveConflictsDetailViewController.h"
#import "PurgeDataDetailViewController.h"
#import "JobLogViewController.h"
#import "ViewControllerFactory.h"
#import "NotificationHistoryDetailViewController.h"
#import "TextSizeDetailViewController.h"
#import "AboutViewController.h"
#import "ResetAppDetailViewController.h"
#import "SignOutDetailViewController.h"
#import "BadgeTableViewCell.h"
#import "ResolveConflictsHelper.h"
#import "SyncProgressDetailModel.h"
#import "SyncManager.h"
#import "NSNotificationCenter+UniqueNotif.h"
#import "AppManager.h"

@interface ToolsMasterViewController ()

@property (nonatomic, strong) NSArray *masterItems;
@property (nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation ToolsMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self setUpMasterData];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftPanelBG.png"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = NO;
    
    [self updateTheTabBarBadges];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSelectedRow) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
   
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView selectRowAtIndexPath:self.selectedIndexPath animated:NO scrollPosition:(UITableViewScrollPositionNone)];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addUniqueObserver:self
                                             selector:@selector(receivedDataSyncStatusNotification:)
                                                 name:kDataSyncStatusNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addUniqueObserver:self
                                             selector:@selector(receivedSyncConflictChangeNotification:)
                                                 name:kSyncConflictChangeNotification
                                               object:nil];

}

#pragma mark - Data Sync Status Update
- (void)receivedDataSyncStatusNotification:(NSNotification *)notification
{
    /*
     * Commented due to issue in syncmanager not sending notification properly.
     */
    //    id statusObject = [notification.userInfo objectForKey:@"syncstatus"];
    //    if ([statusObject isKindOfClass:[SyncProgressDetailModel class]]) {
    //        SyncProgressDetailModel *progressObject = [notification.userInfo objectForKey:@"syncstatus"];
    //        if ((progressObject.syncStatus == SyncStatusSuccess)||
    //            (progressObject.syncStatus == SyncStatusFailed) ||
    //            (progressObject.syncStatus == SyncStatusConflict))
    //        {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadTableView];
        [self updateTheTabBarBadges];
 
    //        }
    //    }
    });
}
- (void)receivedSyncConflictChangeNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadTableView];
        [self updateTheTabBarBadges];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - End


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.masterItems count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[self.masterItems objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    BadgeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[BadgeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        UIView *bgColorView = [[UIView alloc] init];
        [bgColorView setBackgroundColor:[UIColor colorWithHexString:kMasterSelectionColor]];
        [cell setSelectedBackgroundView:bgColorView];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor colorWithHexString:kOrangeColor];
        cell.textLabel.font = [UIFont fontWithName:kHelveticaNeueLight size:kFontSize18];
        cell.textLabel.highlightedTextColor = [UIColor colorWithHexString:kWhiteColor];
    }
    
    cell.textLabel.text = [[self.masterItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    /*
     * Check for resolve conflicts using tags, and set accordingly.
     */
    if ([cell.textLabel.text isEqualToString:[[TagManager sharedInstance]tagByName:kTag_ResolveConflicts]]) {
        /*
         * Fetch the conflict count from helper class.
         */
        NSInteger recordCount = [ResolveConflictsHelper getConflictsCount];
        if (recordCount<0) {
            recordCount = 0;
        }
        cell.badgeNumber = recordCount;
//      [AppManager updateTabBarBadges];
    }
    
    return cell;
}

-(void)updateTheTabBarBadges
{
    [AppManager updateTabBarBadges];
}

#pragma mark - Table view delegate

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle = @"";
    switch (section) {
        case 0:
            sectionTitle = [[TagManager sharedInstance]tagByName:kTagIpadSyncLabel];
            break;
        case 1:
            sectionTitle = [[TagManager sharedInstance]tagByName:KTagSettingsTitle];
            break;
        default:
            break;
    }
    
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    
    CGRect frame = CGRectMake(10, 0, self.tableView.frame.size.width - 10, 35.0);
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:frame];
    titleLbl.backgroundColor = [UIColor clearColor];
    titleLbl.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize18];
    titleLbl.text = sectionTitle;
    [headerView addSubview:titleLbl];
    
    frame = titleLbl.frame;
    frame.origin.y = frame.size.height - 1.0;
    frame.size.height = 1.0;
    UIView *separatorLine = [[UIView alloc] initWithFrame:frame];
    [separatorLine setBackgroundColor:[UIColor colorWithHexString:kMasterSelectionColor]];
    [headerView addSubview:separatorLine];
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35.0;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedIndexPath = indexPath;
    switch (indexPath.section) {
        case 0:
            [self syncItemTappedAtIndex:indexPath.row];
            break;
        case 1:
            [self settingsItemTappedAtIndex:indexPath.row];
            break;
        default:
            break;
    }
}

- (void)reloadTableView
{
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    [self.tableView reloadData];
    for (NSIndexPath *path in indexPaths) {
        [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

-(void) updateSelectedRow{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView selectRowAtIndexPath:self.selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        
    });
}
-(void)setUpMasterData {
    NSArray *syncItems = @[[[TagManager sharedInstance]tagByName:kTag_StatusAndManualSync], [[TagManager sharedInstance]tagByName:kTag_ResolveConflicts],
                           [[TagManager sharedInstance]tagByName:kTagPurgeData],
                           [[TagManager sharedInstance]tagByName:kTagPushLogs]];
    
    NSArray *settingsItems = @[[[TagManager sharedInstance]tagByName:kTagAbout],
                               [[TagManager sharedInstance]tagByName:kTagResetApp],
                               [[TagManager sharedInstance]tagByName:kTagSignOut]];
    
    self.masterItems = [NSArray arrayWithObjects:syncItems,
                        settingsItems,
                        nil];
}


-(void)syncItemTappedAtIndex:(NSInteger)aIndex {
    switch (aIndex) {
        case 0:
            [self syncStatusTapped];
            break;
        case 1:
            [self resolveConflictsTapped];
            break;
        case 2:
            [self purgeDataTapped];
            break;
        case 3:
            [self pushLogTapped];
            break;
        default:
            break;
    }
}

-(void)settingsItemTappedAtIndex:(NSInteger)aIndex {
    switch (aIndex) {
        case 0:
            [self aboutTapped];
            break;
        case 1:
            [self resetAppTapped];
            break;
        case 2:
            [self signOutTapped];
            break;
        default:
            break;
    }
}

-(void)syncStatusTapped {
    SyncStatusDetailViewController *syncStatusVC = [ViewControllerFactory createViewControllerByContext:ViewControllerSyncStatusDetail];
    syncStatusVC.smSplitViewController = self.smSplitViewController;
    UINavigationController *navController = [self.smSplitViewController.viewControllers objectAtIndex:1];
    syncStatusVC.smPopover = ((DetailParentViewController *)[navController.viewControllers lastObject]).smPopover;
    navController.viewControllers = @[syncStatusVC];
    self.smSplitViewController.delegate = syncStatusVC;
}

-(void)resolveConflictsTapped {
    ResolveConflictsDetailViewController *resolveConflictVC = [ViewControllerFactory createViewControllerByContext:ViewControllerResolveConflictsDetail];
    resolveConflictVC.smSplitViewController = self.smSplitViewController;
    UINavigationController *navController = [self.smSplitViewController.viewControllers objectAtIndex:1];
    self.smSplitViewController.delegate = resolveConflictVC;
    resolveConflictVC.smPopover = ((DetailParentViewController *)[navController.viewControllers lastObject]).smPopover;
    navController.viewControllers = @[resolveConflictVC];
    self.smSplitViewController.delegate = resolveConflictVC;
}

-(void)purgeDataTapped {
    PurgeDataDetailViewController *purgeDataVC = [ViewControllerFactory createViewControllerByContext:ViewControllerPurgeDataDetail];
    purgeDataVC.smSplitViewController = self.smSplitViewController;
    UINavigationController *navController = [self.smSplitViewController.viewControllers objectAtIndex:1];
    self.smSplitViewController.delegate = purgeDataVC;
    purgeDataVC.smPopover = ((DetailParentViewController *)[navController.viewControllers lastObject]).smPopover;
    navController.viewControllers = @[purgeDataVC];
    self.smSplitViewController.delegate = purgeDataVC;
}

-(void)pushLogTapped {
    JobLogViewController *jobLogVC = [ViewControllerFactory createViewControllerByContext:ViewControllerJobLog];
    jobLogVC.smSplitViewController = self.smSplitViewController;
    UINavigationController *navController = [self.smSplitViewController.viewControllers objectAtIndex:1];
    self.smSplitViewController.delegate = jobLogVC;
    jobLogVC.smPopover = ((DetailParentViewController *)[navController.viewControllers lastObject]).smPopover;
    navController.viewControllers = @[jobLogVC];
    self.smSplitViewController.delegate = jobLogVC;
}


-(void)notificationHistoryTapped {
    NotificationHistoryDetailViewController *notificationVC = [ViewControllerFactory createViewControllerByContext:ViewControllerNotificationHistoryDetail];
    notificationVC.smSplitViewController = self.smSplitViewController;
    UINavigationController *navController = [self.smSplitViewController.viewControllers objectAtIndex:1];
    self.smSplitViewController.delegate = notificationVC;
    notificationVC.smPopover = ((DetailParentViewController *)[navController.viewControllers lastObject]).smPopover;
    navController.viewControllers = @[notificationVC];
    self.smSplitViewController.delegate = notificationVC;
}

- (void)textSizeTapped {
    TextSizeDetailViewController *textSizeVC = [ViewControllerFactory createViewControllerByContext:ViewControllerTextSizeDetail];
    textSizeVC.smSplitViewController = self.smSplitViewController;
    UINavigationController *navController = [self.smSplitViewController.viewControllers objectAtIndex:1];
    self.smSplitViewController.delegate = textSizeVC;
    textSizeVC.smPopover = ((DetailParentViewController *)[navController.viewControllers lastObject]).smPopover;
    navController.viewControllers = @[textSizeVC];
    self.smSplitViewController.delegate = textSizeVC;
}

- (void)aboutTapped {
    AboutViewController *aboutAppVC = [ViewControllerFactory createViewControllerByContext:ViewControllerAboutView];
    aboutAppVC.smSplitViewController = self.smSplitViewController;
    UINavigationController *navController = [self.smSplitViewController.viewControllers objectAtIndex:1];
    aboutAppVC.smPopover = ((DetailParentViewController *)[navController.viewControllers lastObject]).smPopover;
    navController.viewControllers = @[aboutAppVC];
    self.smSplitViewController.delegate = aboutAppVC;
}

- (void)resetAppTapped {
    ResetAppDetailViewController *resetAppVC = [ViewControllerFactory createViewControllerByContext:ViewControllerResetAppDetail];
    resetAppVC.smSplitViewController = self.smSplitViewController;
    UINavigationController *navController = [self.smSplitViewController.viewControllers objectAtIndex:1];
    resetAppVC.smPopover = ((DetailParentViewController *)[navController.viewControllers lastObject]).smPopover;
    navController.viewControllers = @[resetAppVC];
    self.smSplitViewController.delegate = resetAppVC;
}


- (void)signOutTapped {
    SignOutDetailViewController *signOutVC = [ViewControllerFactory createViewControllerByContext:ViewControllerSignOutDetail];;
    signOutVC.smSplitViewController = self.smSplitViewController;
    UINavigationController *navController = [self.smSplitViewController.viewControllers objectAtIndex:1];
    signOutVC.smPopover = ((DetailParentViewController *)[navController.viewControllers lastObject]).smPopover;
    navController.viewControllers = @[signOutVC];
    self.smSplitViewController.delegate = signOutVC;
}


@end
