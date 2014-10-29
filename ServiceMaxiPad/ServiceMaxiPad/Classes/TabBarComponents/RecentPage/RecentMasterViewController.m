//
//  RecentMasterViewController.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   RecentMasterViewController.m
 *  @class  RecentMasterViewController
 *
 *  @brief
 *
 *   This is the masterview controller for recents
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "RecentMasterViewController.h"
#import "SFObjectService.h"
#import "SFObjectModel.h"
#import "SFMPageHelper.h"
#import "TransactionObjectService.h"
#import "RecentDetailViewController.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"

@interface RecentMasterViewController ()

@property(nonatomic,strong) NSMutableArray *recentObjects;

@end

@implementation RecentMasterViewController

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
    [self refreshData];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftPanelBG.png"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
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
    [self loadDetailViewControllerForIndex:indexPath.row];
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
    
    SFObjectModel *sfObject = [self.recentObjects objectAtIndex:indexPath.row];
    cell.textLabel.text = sfObject.label;
    cell.textLabel.textColor = [UIColor colorWithHexString:kOrangeColor];
    cell.textLabel.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize16];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.recentObjects count];
}

#pragma mark - private method

- (void)loadDetailViewControllerForIndex:(NSInteger)index
{
    SFObjectModel *sfObject = [self.recentObjects objectAtIndex:index];
    RecentDetailViewController *detailViewController = [self.smSplitViewController.viewControllers objectAtIndex:1];
    detailViewController.selectedObject = sfObject;
    self.smSplitViewController.delegate = detailViewController;
    [detailViewController reloaData];
}

- (void)refreshData
{
    SFObjectService *sfobjectService = [[SFObjectService alloc]init];
    if ([sfobjectService conformsToProtocol:@protocol(SFObjectDAO)]) {
        
        self.recentObjects = [NSMutableArray arrayWithArray:[sfobjectService getDistinctObjects]];
    }
    
    //keep the recent object only which has fieldValue
    
    NSMutableArray *updateRecents = [[NSMutableArray alloc]init];
    
    for (int i = 0; i<[self.recentObjects count]; i++) {
        SFObjectModel *sfObject = [self.recentObjects objectAtIndex:i];
        NSString *nameField = [SFMPageHelper getNameFieldForObject:sfObject.objectName];
        TransactionObjectService *service = [[TransactionObjectService alloc]init];
        NSArray *recents = [service getFieldValueForObjectName:sfObject.objectName andNameFiled:nameField];
        if ([recents count] != 0) {
            [updateRecents addObject:[self.recentObjects objectAtIndex:i]];
        }
    }
    self.recentObjects = updateRecents;
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
