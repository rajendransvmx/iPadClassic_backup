//
//  TroubleshootingHomeViewController.m
//  ServiceMaxMobile
//
//  Created by Chinnababu on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "TroubleshootingViewController.h"
#import "TroubleshootingDetailViewController.h"
#include "TroubleshootingMasterViewController.h"
#import "StyleManager.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "TagManager.h"
#import "CacheManager.h"
#import "TaskManager.h"
#import "TaskModel.h"
#import "TaskGenerator.h"
#import "TroubleshootingDataLoader.h"
#import "TroubleshootingDataHelper.h"
#import "SyncConstants.h"
#import "WebserviceResponseStatus.h"
#import "AlertMessageHandler.h"
#import "DocumentModel.h"
#import "TagConstant.h"

@interface TroubleshootingViewController ()

@property (nonatomic, strong)MBProgressHUD *HUD;
@property(nonatomic,strong)NSArray *productDetailsArray;
@property(nonatomic,strong) TroubleshootingMasterViewController *masterViewController;

@end


@implementation TroubleshootingViewController

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
    [self addViewControllersToView];
    [self addActivityAndLoadingLabel];
}

- (void)addNavigationBarButtonItem
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[[TagManager sharedInstance]tagByName:kTagActions] style:UIBarButtonItemStyleDone target:self action:nil];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIColor whiteColor],NSForegroundColorAttributeName,
                                           [UIFont fontWithName:kHelveticaNeueLight size:kFontSize18], NSFontAttributeName, nil] forState:UIControlStateNormal];
}

- (void)cancelButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)getProductDetails
{
    if (![self.productName isKindOfClass:[NSNull class]] && ![self.productName isEqualToString:@""])
    {
        if ([Reachability connectivityStatus])
        {
            [TroubleshootingDataLoader makingRequestForDetailsByProductName:self.productName
                                                      withTheCallerDelegate:self];
        }
        else
        {
            self.productDetailsArray = [TroubleshootingDataHelper fetchProductDetailsbyProductName:self.productName];
            self.masterViewController.productDetailsArray = self.productDetailsArray;
            
            if(([self.productDetailsArray count] > 0))
               {
                   DocumentModel *model = [self.productDetailsArray objectAtIndex:0];
                   [self.masterViewController.troubleshootTableView reloadData];
                   [self.masterViewController setDetailButtonTitle:model.name];
                   
               }
            [self removeActivityAndLoadingLabel];

               
        }
    }
}


- (void)addViewControllersToView
{
    self.navigationItem.titleView = [UILabel navBarTitleLabel:@"Troubleshooting"];
    
    self.navigationController.navigationBar.barTintColor = [UIColor navBarBG]; //Only for iOS7.0 and more than 7.0
    self.navigationController.navigationBar.translucent = NO;
    self.masterViewController = [[TroubleshootingMasterViewController alloc]
                                 initWithNibName:@"TroubleshootingMasterViewController" bundle:nil];
    self.masterViewController.smSplitViewController = self;
    self.masterViewController.productId = self.productId;
    self.masterViewController.productName = self.productName;
    
    TroubleshootingDetailViewController *detailViewController = [[TroubleshootingDetailViewController alloc] initWithNibName:@"TroubleshootingDetailViewController" bundle:nil];
    detailViewController.smSplitViewController = self;
    self.delegate = detailViewController;
    self.viewControllers = @[self.masterViewController,detailViewController];
    self.view.backgroundColor = [UIColor whiteColor];
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
                if (st.syncStatus == SyncStatusSuccess)
                {
                    [self removeActivityAndLoadingLabel];
                    self.productDetailsArray = [TroubleshootingDataHelper fetchProductDetailsbyProductName:self.productName];
                    self.masterViewController.productDetailsArray = self.productDetailsArray;
                    
                    if([self.productDetailsArray count] >0)
                    {
                        DocumentModel *model =  [self.masterViewController.productDetailsArray objectAtIndex:0];
                        [self.masterViewController.troubleshootTableView reloadData];
                        [self.masterViewController setDetailButtonTitle:model.name];
                    }
                }
                else if(st.syncStatus == SyncStatusFailed)
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

- (void)dealloc
{
    [self removeDocIdAndDocNameFromeCache];
}

- (void)removeDocIdAndDocNameFromeCache
{
    [[CacheManager sharedInstance]clearCacheByKey:@"docId"];
    [[CacheManager sharedInstance]clearCacheByKey:@"docName"];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(!([self.productName  length]) > 0)
    {
       
        UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:[[TagManager sharedInstance]tagByName:kTagAlertTitleError]
                                                           message:[[TagManager sharedInstance]tagByName:kTagTroubleShootingError]
                                                          delegate:self
                                                 cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk ] otherButtonTitles:nil, nil];
        [alertview show];
        [self removeActivityAndLoadingLabel];
    }
    else
    {
        [self getProductDetails];
    }
    self.view.backgroundColor = [UIColor redColor];
    [self addNavigationBarButtonItem];
}


@end
