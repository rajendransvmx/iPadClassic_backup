//
//  TroubleShootMasterViewController.m
//  ServiceMaxMobile
//
//  Created by Chinnababu on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "TroubleshootingMasterViewController.h"
#import "Reachability.h"
#import "TroubleshootingDataHelper.h"
#import "DatabaseConstant.h"
#import "DocumentModel.h"
#import "TroubleshootingDetailViewController.h"
#import "TroubleshootingDataLoader.h"
#import "CacheManager.h"
#import "TroubleshootingViewController.h"
#import "MBProgressHUD.h"
#import "SyncConstants.h"
#import "WebserviceResponseStatus.h"
#import "TaskModel.h"
#import "TaskGenerator.h"
#import "TaskManager.h"
#import "TagManager.h"
#import "AlertMessageHandler.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import "TagConstant.h"

@interface TroubleshootingMasterViewController()

@property(nonatomic, strong) MBProgressHUD *HUD;
@property(nonatomic, strong) DocumentModel *docModel;

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
    self.troubleshootTableView.delegate = self;
    self.troubleshootTableView.dataSource = self;
    self.searchBar.layer.borderWidth = 1;
    self.searchBar.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.searchBar.layer.cornerRadius = 5;
}

#pragma mark - TableView delegate methods

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
    return 50.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TroubleshootCell";
     if ([self.productDetailsArray count] > 0)
     {
         UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
         
         if (cell == nil)
         {
             cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
             [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
         }
         
         DocumentModel *model =[self.productDetailsArray objectAtIndex:indexPath.row];
         cell.textLabel.text = model.Name;
         return cell;
     }
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self getTroubleshootingDataForIndex:indexPath.row];
}


- (void)getTroubleshootingDataForIndex:(NSInteger)index
{
    DocumentModel *model = [self.productDetailsArray objectAtIndex:index];
    TroubleshootingDetailViewController *detailController = [self.smSplitViewController.viewControllers lastObject];
   
    if ((model.Id != nil) && (model.Name != nil) )
    {   
        [detailController loadWebViewForThedocId:model.Id andThedocName:model.Name];
        [self setDetailButtonTitle:model.Name];
    }
    else
    {
        [self removeActivityAndLoadingLabel];
    }
}


#pragma mark -Searchbar delegate Method

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
     [self addActivityAndLoadingLabel];
   
    if (([self.searchBar.text length ]) > 0)
    {
        if([Reachability connectivityStatus])
        {
            [TroubleshootingDataLoader makingRequestForDetailsByProductName:self.searchBar.text
                                                      withTheCallerDelegate:self];
        }
        else
        {
             TroubleshootingDetailViewController *detailController = [self.smSplitViewController.viewControllers lastObject];
            self.productDetailsArray = [TroubleshootingDataHelper fetchProductDetailsbyProductName:self.searchBar.text];
            
            if (([self.productDetailsArray count] > 0))
            {
               
                DocumentModel *model = [self.productDetailsArray objectAtIndex:0];
                [self.troubleshootTableView reloadData];
                [self setDetailButtonTitle:model.Name];
                [detailController loadWebViewForThedocId:@"" andThedocName:@""];
                [self removeActivityAndLoadingLabel];
            }
            else
            {
                [self.troubleshootTableView reloadData];
                [self setDetailButtonTitle:@""];
                [detailController loadWebViewForThedocId:@"" andThedocName:@""];
                [self removeActivityAndLoadingLabel];
                
            }
        }
    }
}

- (void) setDetailButtonTitle:(NSString *)title
{
    TroubleshootingDetailViewController *detailViewController = [self.smSplitViewController.viewControllers lastObject];
    [detailViewController setContentWithItem:title];
}


#pragma mark -Flow node delegate method

- (void)flowStatus:(id)status
{
    if([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *st = (WebserviceResponseStatus*)status;
        switch (st.category)
        {
            case CategoryTypeTroubleShooting:
            {
                 TroubleshootingDetailViewController *detailController = [self.smSplitViewController.viewControllers lastObject];
                if (st.syncStatus == SyncStatusSuccess)
                {
                    self.productDetailsArray = [TroubleshootingDataHelper fetchProductDetailsbyProductName:self.searchBar.text];
                    if(([self.productDetailsArray count]) > 0)
                    {
                        [self.troubleshootTableView reloadData];
                        DocumentModel *model = [self.productDetailsArray objectAtIndex:0];
                        [self setDetailButtonTitle:model.Name];
                        [self removeActivityAndLoadingLabel];
                        [detailController loadWebViewForThedocId:@"" andThedocName:@""];
                    }
                    else
                    {
                        [self.troubleshootTableView reloadData];
                        [self setDetailButtonTitle:@""];
                        [self removeActivityAndLoadingLabel];
                        [detailController loadWebViewForThedocId:@"" andThedocName:@""];
                    }
                }
                
                else if (st.syncStatus == SyncStatusFailed)
                {
                    [self removeActivityAndLoadingLabel];
                    [[AlertMessageHandler sharedInstance] showCustomMessage:[st.syncError errorEndUserMessage] withDelegate:nil title:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage] cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] andOtherButtonTitles:nil];
                }
                break;
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
- (void)addActivityAndLoadingLabel
{
    if (!self.HUD) {
        self.HUD = [[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] keyWindow]];
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.HUD];
        self.HUD.mode = MBProgressHUDModeIndeterminate;
        self.HUD.labelText = [[TagManager sharedInstance]tagByName:kTagLoading];
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
