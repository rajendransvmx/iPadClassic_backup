
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
#import "CacheManager.h"
#import "StringUtil.h"
#import "SNetworkReachabilityManager.h"
#import "SVMXSystemConstant.h"

@interface ProductManualViewController ()

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) ProductManualMaster *masterViewController;
@property (nonatomic, strong) ProductManualDetail *detailViewController;

@end

@implementation ProductManualViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addViewControllersToView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addViewControllersToView
{
    self.navigationItem.titleView = [UILabel navBarTitleLabel:@"Product Manual"];
    self.navigationController.navigationBar.barTintColor = [UIColor navBarBG]; //Only for iOS7.0 and more than 7.0
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
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
    if (![StringUtil isStringEmpty:self.productId])
    {
        if ( [[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
            
        {
            if ([[AppManager sharedInstance] hasTokenRevoked])
            {
                
                [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeAccessTokenExpired
                                                                       message:nil
                                                                   andDelegate:nil];
                [self removeActivityAndLoadingLabel];
            }
            else
            {
                [ProductManualDataLoader makingRequestForDetailsByProductId:self.productId
                                                      withTheCallerDelegate:self];
            }
        }
        
        else
        {
            self.productDetailsArray = [ProductManualDataHelper fetchProductDetailsbyProductID:self.productId];
            self.masterViewController .productDetailsArray = self.productDetailsArray;
            
            if(([self.productDetailsArray count] > 0))
            {
                [self loadTableViewAndWebView];
                
            }
            else
            {

                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[TagManager sharedInstance]tagByName:kTagAlertTitleError] message:@"Product manual not present" delegate:self cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles:nil, nil];
                [alertView show];
            }
            [self removeActivityAndLoadingLabel];
        }
    }
    else
    {

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[TagManager sharedInstance]tagByName:kTagAlertTitleError] message:@"Product manual not present" delegate:self cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles:nil, nil];
        [alertView show];
        
        [self removeActivityAndLoadingLabel];
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
                    if([self.productDetailsArray  count] >0)
                    {
                        [self loadTableViewAndWebView];
                    }
                    else{
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[TagManager sharedInstance]tagByName:kTagAlertTitleError] message:@"Product manual not present" delegate:self cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles:nil, nil];
                        [alertView show];
                        
                    }
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
                break;
            default:
                break;
        }
    }
}

-(NSArray *)getPdfFileNamesOnlyFromTheArray:(NSArray *)modelArray
{
    NSMutableArray *fileNameArray = [[NSMutableArray alloc] init];
    for (ProductManualModel *model in modelArray)
    {
        NSString *fileName = model.prod_manual_name;
        if(fileName != nil)
        {
            if( [[[fileName lastPathComponent] pathExtension]  isEqual:@"pdf"] )
            {
                [fileNameArray addObject:model];
            }
        }
    }
    return fileNameArray;
}

- (void)dealloc
{
    [self removeProductIdAndProductNameFromeCache];
}

- (void)removeProductIdAndProductNameFromeCache
{
    [[CacheManager sharedInstance] clearCacheByKey:@"pMId"];
    [[CacheManager sharedInstance] clearCacheByKey:@"ProductManual"];
}

- (void)loadTableViewAndWebView
{
    self.masterViewController.productDetailsArray = self.productDetailsArray;
    ProductManualModel *model =  [self.masterViewController.productDetailsArray objectAtIndex:0];
    
    NSString *title = kEmptyString;
    if(model.prod_manual_name != nil)
    {
        title = [[model.prod_manual_name lastPathComponent] stringByDeletingPathExtension];
    }
    
    [self.masterViewController.tableView reloadData];
    NSIndexPath *firstRowPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.masterViewController.tableView selectRowAtIndexPath:firstRowPath animated:NO
                                               scrollPosition: UITableViewScrollPositionNone];
    [self.detailViewController setContentWithItem:title];
    [self.detailViewController loadWebViewForTheProductName:model.prod_manual_name
                                         AndProductManualID:model.prod_manual_Id];
}



@end


