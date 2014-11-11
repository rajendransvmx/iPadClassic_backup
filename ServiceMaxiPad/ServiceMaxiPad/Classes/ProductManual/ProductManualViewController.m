
//  ProductManualViewController.m
//  ServiceMaxiPad
//
//  Created by Chinnababu on 06/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ProductManualViewController.h"
#import "ProductManualDetail.h"
#import "ProductManualMaster.h"
#import "StyleManager.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "TagManager.h"
#import "CacheManager.h"
#import "TaskManager.h"
#import "TaskModel.h"
#import "TaskGenerator.h"
#import "SyncConstants.h"
#import "WebserviceResponseStatus.h"
#import "AlertMessageHandler.h"
#import "TagConstant.h"
#import "ProductManualDataLoader.h"
#import "ProductManualDataHelper.h"
#import "ProductManualModel.h"
#import "ProductManualDataLoader.h"
#import "ProductManualDetail.h"

@interface ProductManualViewController ()

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) ProductManualMaster *masterViewController;
@property (nonatomic, strong) ProductManualDetail *detailViewController ;
@end

@implementation ProductManualViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addViewControllersToView];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)addViewControllersToView
{
    self.navigationItem.titleView = [UILabel navBarTitleLabel:@"ProductManual"];
    
    self.navigationController.navigationBar.barTintColor = [UIColor navBarBG]; //Only for iOS7.0 and more than 7.0
    self.navigationController.navigationBar.translucent = NO;
    self.masterViewController = [[ProductManualMaster alloc]
                                 initWithNibName:@"ProductManualMaster" bundle:nil];
    self.masterViewController.smSplitViewController = self;
    self.detailViewController = [[ProductManualDetail alloc]
                                 initWithNibName:@"ProductManualDetail" bundle:nil];
    self.detailViewController.smSplitViewController = self;
    self.delegate = self.detailViewController;
    self.viewControllers = @[self.masterViewController ,self.detailViewController];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)getProductDetails
{
    if (![self.productName isKindOfClass:[NSNull class]]
        && ![self.productName isEqualToString:@""])
    {
        if ([Reachability connectivityStatus])
        {
            [ProductManualDataLoader makingRequestForDetailsByProductId:self.productId
                                                  withTheCallerDelegate:self];
        }
        else
        {
            self.productDetailsArray = [ProductManualDataHelper fetchProductDetailsbyProductID:self.productId];
           self.masterViewController .productDetailsArray = self.productDetailsArray;
            
            if(([self.productDetailsArray count] > 0))
            {
                [self.masterViewController.tableView reloadData];
                ProductManualModel *model = [self.productDetailsArray objectAtIndex:0];
                [self.detailViewController loadWebViewForTheProductName:model.prod_manual_name];
                
            }
            [self removeActivityAndLoadingLabel];
        }
    }
}

- (void)removeActivityAndLoadingLabel;
{
    if (self.HUD) {
        [self.HUD hide:YES];
        self.HUD = nil;
    }
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addActivityAndLoadingLabel];
    [self getProductDetails];
    
}

- (void)flowStatus:(id)status
{
    if([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *st = (WebserviceResponseStatus*)status;
        switch (st.category)
        {
            case CategoryTypeProductManual:
            {
                [self removeActivityAndLoadingLabel];
                if (st.syncStatus == SyncStatusSuccess)
                {
                    [self removeActivityAndLoadingLabel];
                    
                    self.productDetailsArray = [ProductManualDataHelper fetchProductDetailsbyProductID:self.productId];
                    
                    self.masterViewController .productDetailsArray = self.productDetailsArray;
                    
                    if([self.productDetailsArray count] >0)
                    {
                        [self.masterViewController .tableView reloadData];
                        ProductManualModel *model =  [self.masterViewController.productDetailsArray objectAtIndex:0];
                        NSString *title = [model.prod_manual_name substringToIndex:
                                               [model.prod_manual_name length]-4]  ;
                        [self.detailViewController setContentWithItem:title];
                        
                        [self.detailViewController loadWebViewForTheProductName:model.prod_manual_name];

                    }
                    else if(st.syncStatus == SyncStatusFailed)
                    {
                        [self removeActivityAndLoadingLabel];
                        [[AlertMessageHandler sharedInstance] showCustomMessage:[st.syncError errorEndUserMessage]
                                                                   withDelegate:nil
                                                                          title:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage]
                                                              cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]
                                                           andOtherButtonTitles:nil];
                    }
                }
            }
                break;
            default:
                break;
        }
    }
}




@end


