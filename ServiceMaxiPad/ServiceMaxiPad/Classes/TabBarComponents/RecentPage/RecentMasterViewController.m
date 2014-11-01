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
#import "RecentDaoService.h"
#import "RecentModel.h"

#define limit 100

@interface RecentMasterViewController ()

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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftPanelBG.png"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self refreshData];
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
    self.selectedIndexPath = indexPath;
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
    cell.textLabel.text = [self.recentObjects objectAtIndex:indexPath.row];
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
    RecentDetailViewController *detailViewController = [self.smSplitViewController.viewControllers objectAtIndex:1];
    self.smSplitViewController.delegate = detailViewController;
    NSString *selectedObject = [self.recentObjects objectAtIndex:index];
    NSMutableArray *recentModelArray = [self.recentRecordDictionary objectForKey:selectedObject];
    detailViewController.recentItems = recentModelArray;
    [detailViewController reloaData];
}

- (void)refreshData
{
    RecentDaoService *recentService = [[RecentDaoService alloc]init];
    NSArray *listOfRecentRecord;
    if ([recentService conformsToProtocol:@protocol(RecentsDao)]) {
        listOfRecentRecord = [recentService getRecentRecordInfo];
    }
    listOfRecentRecord = [recentService getRecentRecordInfo];
    
    NSMutableDictionary *recentRecordDict = [[NSMutableDictionary alloc]init];
    
    for (RecentModel *recentModel in listOfRecentRecord ) {
        
        NSMutableArray *recentModelArray;
        NSString *nameField = [SFMPageHelper getNameFieldForObject:recentModel.objectName];
        
        NSString *label = nil;
        SFObjectService *sfObjectService = [[SFObjectService alloc]init];
        if ([sfObjectService conformsToProtocol:@protocol(SFObjectDAO)]) {
            label = [sfObjectService getLabelForObjectApiName:recentModel.objectName];
        }
        TransactionObjectService *service = [[TransactionObjectService alloc]init];
        recentModel.nameFieldValue = [service getFieldValueForObjectName:recentModel.objectName nameFiled:nameField andLocalId:recentModel.localId];

        if ( [recentRecordDict objectForKey:label]!= nil) {
            recentModelArray = [recentRecordDict objectForKey:label];
        } else {
            recentModelArray = [[NSMutableArray alloc]init];
        }
        [recentModelArray addObject:recentModel];
        [recentRecordDict setObject:recentModelArray forKey:label];
    }
    
    self.recentRecordDictionary = recentRecordDict;
    //  NSMutableDictionary *recentDictionary = [RecentsPlistUtility getRecentsFromPlist];
    self.recentObjects = [NSMutableArray arrayWithArray:[recentRecordDict allKeys]];
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:self.selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
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
