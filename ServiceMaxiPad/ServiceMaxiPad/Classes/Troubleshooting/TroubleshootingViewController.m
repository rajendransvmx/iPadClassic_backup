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
#import "TroubleshootingDatahelper.h"
#import "FlowNode.h"
#import "SyncConstants.h"
#import "WebserviceResponseStatus.h"
#import "AlertMessageHandler.h"
#import "TagConstant.h"

@interface TroubleshootingViewController ()<FlowDelegate>
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
    self.productName = @"Product 1";
   [self addViewControllersToView];
    if(([self.productName isEqualToString:@""]) || (self.productName == nil))
       {
           TagManager *tags = [TagManager sharedInstance];
           UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:[tags tagByName:kTagAlertTitleError]
                                                              message:[tags tagByName:kTagTroubleShootingError]
                                                             delegate:self
                                                    cancelButtonTitle:[tags tagByName:kTagAlertErrorOk] otherButtonTitles:nil, nil];
        [alertview show];
       }
       else
       {
           [self getProductDetails];
       }
    self.view.backgroundColor = [UIColor redColor];
    
    [self addNavigationBarButtonItem];

}

- (void)addNavigationBarButtonItem
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Actions" style:UIBarButtonItemStyleDone target:self action:nil];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIColor whiteColor],NSForegroundColorAttributeName,
                                           [UIFont fontWithName:kHelveticaNeueLight size:kFontSize18], NSFontAttributeName, nil] forState:UIControlStateNormal];
}



-(void)cancelButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)getProductDetails
{
    if (![self.productId isKindOfClass:[NSNull class]] && ![self.productId isEqualToString:@""])
    {
        if(![self.productName isKindOfClass:[NSNull class]] && ![self.productName isEqualToString:@""])
        {
            if([Reachability connectivityStatus])
            {
                [self addActivityAndLoadingLabel];
                [TroubleshootingDataLoader fetchProductDetailsFromServerForTheProductName:self.productName WithTheCallerDelegate:self];
            }
            else
            {
                self.productDetailsArray = [TroubleshootingDatahelper
                                            getProductDetailsFromDbForProductName:self.productName];
            }
        }
    }
    
}
-(void)addViewControllersToView
{
    self.navigationItem.titleView = [UILabel navBarTitleLabel:@"TroubleShooting"];
    
    self.navigationController.navigationBar.barTintColor = [UIColor navBarBG]; //Only for iOS7.0 and more than 7.0
    self.navigationController.navigationBar.translucent = NO;
    self.masterViewController = [[TroubleshootingMasterViewController alloc]initWithNibName:@"TroubleshootingMasterViewController" bundle:nil];
    self.masterViewController.smSplitViewController = self;
    self.masterViewController.productId = self.productId;
    self.masterViewController.productName = self.productName;
    
    TroubleshootingDetailViewController *detailViewController = [[TroubleshootingDetailViewController alloc] initWithNibName:@"TroubleshootingDetailViewController" bundle:nil];
    detailViewController.smSplitViewController = self;
    self.delegate = detailViewController;
    self.viewControllers = @[self.masterViewController,detailViewController];
}

- (void)addActivityAndLoadingLabel
{
    if (!self.HUD) {
        self.HUD = [[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] keyWindow]];
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.HUD];
        self.HUD.mode = MBProgressHUDModeIndeterminate;
        self.HUD.labelText = @"Loading Details...";
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
                    self.productDetailsArray = [TroubleshootingDatahelper getProductDetailsFromDbForProductName:self.productName];
                    self.masterViewController.productDetailsArray = self.productDetailsArray;
                    [self.masterViewController.troubleshootTableView reloadData];
                     [self removeActivityAndLoadingLabel];
                }
                else if(st.syncStatus == SyncStatusFailed)
                    case SyncStatusNetworkError:
                {
                    [self removeActivityAndLoadingLabel];
                    
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
- (void)dealloc
{
    [self removeDocIdAndDocNameFromeCache];
}
-(void)removeDocIdAndDocNameFromeCache
{
    [[CacheManager sharedInstance]clearCacheByKey:@"docId"];
    [[CacheManager sharedInstance]clearCacheByKey:@"docName"];

}



@end
