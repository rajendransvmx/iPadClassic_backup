//
//  RecentDetailViewController.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   RecentDetailViewController.m
 *  @class  RecentDetailViewController
 *
 *  @brief
 *
 *   This is the detail view controller for recents
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "RecentDetailViewController.h"
#import "TransactionObjectModel.h"
#import "SFMPageViewController.h"
#import "SFMViewPageManager.h"
#import "StyleManager.h"
#import "StyleGuideConstants.h"
#import "AlertMessageHandler.h"
#import "TagManager.h"
#import "TagConstant.h"
#import "SFMPageHelper.h"
#import "TransactionObjectService.h"
#import "RecentModel.h"
#import "StringUtil.h"
#import "DateUtil.h"


@interface RecentDetailViewController ()
@property(nonatomic, retain) SMSplitPopover *masterPopoverController;

@end

@implementation RecentDetailViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:kPageViewMasterBGColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SMSplitViewControllerDelegate

- (void)splitViewController:(SMSplitViewController *)splitViewController willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem popover:(SMSplitPopover *)popover
{
    barButtonItem.title = [[TagManager sharedInstance]tagByName:kTagRecents];
    //splitViewController.navigationItem.rightBarButtonItem = barButtonItem;
    splitViewController.navigationItem.leftBarButtonItem = barButtonItem;
    self.masterPopoverController = popover;
}

- (void)splitViewController:(SMSplitViewController *)splitViewController willShowViewController:(UIViewController *)aViewController barButtonItem:(UIBarButtonItem *)barButtonItem
{
    splitViewController.navigationItem.leftBarButtonItem = nil;
}

#pragma mark UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecentModel *recentModel;
    if ([self.recentItems count] > indexPath.row) {
        recentModel = [self.recentItems objectAtIndex:indexPath.row];
    }
    SFMPageViewController *pageViewController = [[SFMPageViewController alloc]init];
    SFMViewPageManager *pageManager = [[SFMViewPageManager alloc] initWithObjectName:recentModel.objectName recordId:recentModel.localId];
    
    NSError *error = nil;
    BOOL isValidProcess = [pageManager isValidProcess:pageManager.processId error:&error];
    if (isValidProcess) {
        pageViewController.sfmPageView = [pageManager sfmPageView];
        [self.navigationController pushViewController:pageViewController animated:YES];
    }
    else
    {
        if (error) {
            AlertMessageHandler *alertHandler = [AlertMessageHandler sharedInstance];
            NSString * button = [[TagManager sharedInstance] tagByName:kTagAlertErrorOk];
            
            [alertHandler showCustomMessage:[error localizedDescription] withDelegate:nil title:[[TagManager sharedInstance] tagByName:kTagAlertIpadError] cancelButtonTitle:nil andOtherButtonTitles:[[NSArray alloc] initWithObjects:button, nil]];
        }
    }
}

#pragma mark UITableViewDataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    }
    for (UIView *view in [cell.contentView subviews]) {
      
        [view removeFromSuperview];
    }
    RecentModel *recentModel = [self.recentItems objectAtIndex:indexPath.row];
    NSString *cellText;
    if (recentModel.nameFieldValue != nil) {
        cellText = recentModel.nameFieldValue;
        cellText = [cellText stringByAppendingString:@"   "];
        cellText = [cellText stringByAppendingString:[DateUtil getUserReadableDateForDateBaseDate:recentModel.createdDate]];
    }else {
        cellText = [DateUtil getUserReadableDateForDateBaseDate:recentModel.createdDate];
    }

    //Add one pixel seperator line to each cell
    UIView *seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(5,49
                                                                    , self.tableView.frame.size.width, 1)];
    seperatorLine.backgroundColor = [UIColor colorWithHexString:kSeperatorLineColor];
    [cell.contentView addSubview:seperatorLine];
    
    cell.textLabel.text = cellText;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize14];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.recentItems count];
}

- (void)reloaData
{
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
    [self.tableView reloadData];
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
