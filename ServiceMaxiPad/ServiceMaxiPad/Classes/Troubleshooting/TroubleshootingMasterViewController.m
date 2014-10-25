//
//  TroubleShootMasterViewController.m
//  ServiceMaxMobile
//
//  Created by Chinnababu on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "TroubleshootingMasterViewController.h"
#import "Reachability.h"
#import "TroubleshootingDatahelper.h"
#import "DatabaseConstant.h"
#import "DocumentModel.h"
#import "TroubleshootingDetailViewController.h"
#import "TroubleshootingDataLoader.h"
#import "CacheManager.h"
#import "TroubleshootingViewController.h"
#import "MBProgressHUD.h"
#import "FlowNode.h"
#import "SyncConstants.h"
#import "WebserviceResponseStatus.h"
#import "TaskModel.h"
#import "TaskGenerator.h"
#import "TaskManager.h"
#import "TagManager.h"
#import  "AlertMessageHandler.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import "TagConstant.h"

@interface TroubleshootingMasterViewController ()<FlowDelegate>

@property(nonatomic, strong)MBProgressHUD *HUD;
@property(nonatomic, strong)DocumentModel *docModel;


@end

@implementation TroubleshootingMasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.productName = @"Aqua ";
    self.productId = @"23";
    self.troubleshootTableView.delegate = self;
    self.troubleshootTableView.dataSource = self;
    self.searchBar.layer.borderWidth = 1;
    self.searchBar.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.searchBar.layer.cornerRadius = 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.productDetailsArray count] ;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    }
    if([self.productDetailsArray count] > 0)
    {
        DocumentModel *model =[self.productDetailsArray objectAtIndex:indexPath.row];
        cell.textLabel.text = model.name;
        return cell;
    }
    else
    {
        TagManager *tags = [TagManager sharedInstance];
        UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:[tags tagByName:kTagAlertTitleError]
                                                           message:[tags tagByName:kTagTroubleShootingError]
                                                          delegate:self
                                                 cancelButtonTitle:[tags tagByName:kTagAlertErrorOk] otherButtonTitles:nil, nil];
        [alertview show];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self getTroubleShootingDataForIndex:indexPath.row];
    [self addActivityAndLoadingLabel];
}

-(void)getTroubleShootingDataForIndex:(NSInteger)index
{
    DocumentModel *model = [self.productDetailsArray objectAtIndex:index];
    TroubleshootingDetailViewController *detailController = [self.smSplitViewController.viewControllers lastObject];
    [TroubleshootingDataLoader getTroubleshootingBodyFromTheServerWithTheDocId:model.Id AndCallerDelegate:self];
    [detailController loadwebViewForThedocId:model.Id andThedocName:model.name];
    [self removeActivityAndLoadingLabel];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    if ((self.searchBar.text != nil) || ([self.searchBar.text isEqualToString:@"nil"]))
    {
        if([Reachability connectivityStatus])
        {
            [self addActivityAndLoadingLabel];
            [TroubleshootingDataLoader fetchProductDetailsFromServerForTheProductName:self.searchBar.text WithTheCallerDelegate:self];
        }
        else
        {
            self.productDetailsArray = [TroubleshootingDatahelper getProductDetailsFromDbForProductName:self.searchBar.text];
            [self.troubleshootTableView reloadData];
        }
    }
    else
    {
        if([Reachability connectivityStatus])
        {
            [self addActivityAndLoadingLabel];
            [TroubleshootingDataLoader fetchProductDetailsFromServerForTheProductName: self.productName  WithTheCallerDelegate:self];
        }
        else
        {
            self.productDetailsArray = [TroubleshootingDatahelper getProductDetailsFromDbForProductName: self.productName ];
            [self.troubleshootTableView reloadData];
        }
    }
}

- (void)flowStatus:(id)status
{
    if([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *st = (WebserviceResponseStatus*)status;
        switch (st.category)
        {
            case CategoryTypeTroubleShooting:
            {
                if (st.syncStatus == SyncStatusSuccess)
                {
                    if ((self.searchBar.text != nil) || (![self.searchBar.text isEqualToString:@"nil"]))
                    {
                        self.productDetailsArray = [TroubleshootingDatahelper getProductDetailsFromDbForProductName:self.searchBar.text];
                    }
                    else
                    {
                        self.productDetailsArray = [TroubleshootingDatahelper getProductDetailsFromDbForProductName:self.productName];
                    }
                    [self.troubleshootTableView reloadData];
                }
                else if (st.syncStatus == SyncStatusFailed)
                {
                    [self removeActivityAndLoadingLabel];
                    [[AlertMessageHandler sharedInstance] showCustomMessage:[st.syncError errorEndUserMessage] withDelegate:nil title:@"Error" cancelButtonTitle:@"Ok" andOtherButtonTitles:nil];
                }
            }
            case CategoryTypeTroubleShootingDataDownload:
            {
                if  (st.syncStatus == SyncStatusSuccess)
                {
                    [self removeActivityAndLoadingLabel];
                }
                else if (st.syncStatus == SyncStatusFailed)
                {
                     [[AlertMessageHandler sharedInstance] showCustomMessage:[st.syncError errorEndUserMessage] withDelegate:nil title:@"Error" cancelButtonTitle:@"Ok" andOtherButtonTitles:nil];
                }
            }
            default:
                break;
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    _troubleshootTableView = nil;
    _searchBar = nil;
    //[super dealloc];
}
-(void)addActivityAndLoadingLabel
{
    if (!self.HUD) {
        self.HUD = [[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] keyWindow]];
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.HUD];
        self.HUD.mode = MBProgressHUDModeIndeterminate;
        self.HUD.labelText = @"Loading...";
        [self.HUD show:YES];
        
    }
}
- (void)removeActivityAndLoadingLabel;
{
    if (self.HUD) {
        [self.HUD hide:YES];
        self.HUD = nil;
    }
}

@end
