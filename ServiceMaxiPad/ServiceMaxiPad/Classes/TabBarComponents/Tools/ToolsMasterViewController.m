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

@interface ToolsMasterViewController ()

@property (nonatomic, strong) NSArray *masterItems;

@end

@implementation ToolsMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // set up Tools master items list ..
    [self setUpMasterData];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftPanelBG.png"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = NO;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:(UITableViewScrollPositionNone)];
}

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        UIView *bgColorView = [[UIView alloc] init];
        [bgColorView setBackgroundColor:[UIColor colorWithHexString:kMasterSelectionColor]];
        [cell setSelectedBackgroundView:bgColorView];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor colorWithHexString:kOrangeColor];
        cell.textLabel.font = [UIFont fontWithName:kHelveticaNeueLight size:kFontSize18];
        cell.textLabel.highlightedTextColor = [UIColor colorWithHexString:kWhiteColor];
    }
    
    cell.textLabel.text = [[self.masterItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    // Configure the cell...
    
    return cell;
}


#pragma mark - Table view delegate

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle = @"";
    switch (section) {
        case 0:
            sectionTitle = @"Sync";
            break;
        case 1:
            sectionTitle = @"Notifications";
            break;
        case 2:
            sectionTitle = @"Settings";
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
    switch (indexPath.section) {
        case 0:
            [self syncItemTappedAtIndex:indexPath.row];
            break;
        case 1:
            [self notificationItemTappedAtIndex:indexPath.row];
            break;
        case 2:
            [self settingsItemTappedAtIndex:indexPath.row];
            break;
        default:
            break;
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)setUpMasterData {
    NSArray *syncItems = @[@"Status and Manual Sync", @"Resolve Conflicts", [[TagManager sharedInstance]tagByName:kTagPurgeData], [[TagManager sharedInstance]tagByName:kTagPushLogs]];
    NSArray *notificationItems = @[@"Notification History"];
    NSArray *settingsItems = @[@"Text Size", [[TagManager sharedInstance]tagByName:kTagAbout], [[TagManager sharedInstance]tagByName:kTagResetApp], [[TagManager sharedInstance]tagByName:kTagSignOut]];
    self.masterItems = [NSArray arrayWithObjects:syncItems, notificationItems, settingsItems, nil];
}


-(void)syncItemTappedAtIndex:(int)aIndex {
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


-(void)notificationItemTappedAtIndex:(int)aIndex {
    switch (aIndex) {
        case 0:
            [self notificationHistoryTapped];
            break;
        default:
            break;
    }
}


-(void)settingsItemTappedAtIndex:(int)aIndex {
    switch (aIndex) {
        case 0:
            [self textSizeTapped];
            break;
        case 1:
            [self aboutTapped];
            break;
        case 2:
            [self resetAppTapped];
            break;
        case 3:
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
