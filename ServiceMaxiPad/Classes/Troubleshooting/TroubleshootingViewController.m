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
#import "ProductManualViewController.h"
#import "SMActionSideBarViewController.h"
#import "StringUtil.h"
#import "ChatterViewController.h"
#import "FileManager.h"
#import "TroubleshootDataModel.h"
#import "SNetworkReachabilityManager.h"
#import "UIBarButtonItem+TKCategory.h"
#import "AlertViewHandler.h"

@interface TroubleshootingViewController ()
<SMActionSideBarViewControllerDelegate,ActionMenuDelegate>
{
    NSArray *list;
}

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) NSArray *productDetailsArray;
@property (nonatomic, strong) TroubleshootingMasterViewController *masterViewController;
@property (nonatomic, strong) SMActionSideBarViewController *mySideBar;
@property (nonatomic, strong) TroubleshootingDetailViewController *detailViewController;
@property (nonatomic) BOOL loadMask;

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
    self.loadMask = NO;
    [self addNavigationBarButtonItem];
}

- (void)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)addNavigationBarButtonItem
{
    UIBarButtonItem *productManual = [[UIBarButtonItem alloc] initWithTitle:[[TagManager sharedInstance] tagByName:kTagActions]
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(showMenu:)];
    [self showOptionsForActionButton];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:productManual, nil];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                                                    [UIFont fontWithName:kHelveticaNeueLight
                                                                                    size:kFontSize18], NSFontAttributeName, nil]
                                                          forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem  = [UIBarButtonItem  customNavigationBackButtonWithTitle:kTag_WorkOrder forTarget:self forSelector:@selector(backButtonClicked:)];
    
}

- (void)cancelButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)getProductDetails
{
    if (![StringUtil isStringEmpty:self.productName])
    {
        if ( [[SNetworkReachabilityManager sharedInstance] isNetworkReachable])        {
            if ([[AppManager sharedInstance] hasTokenRevoked])
            {
                
                [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeAccessTokenExpired
                                                                       message:nil
                                                                   andDelegate:nil];
                [self removeActivityAndLoadingLabel];
            }
            else
            {
                [TroubleshootingDataLoader makingRequestForDetailsByProductName:self.productName
                                                          withTheCallerDelegate:self];
            }
        }
        else
        {
            self.productDetailsArray = [TroubleshootingDataHelper fetchProductDetailsbyProductName:self.productName];
            self.masterViewController.productDetailsArray = self.productDetailsArray;
            
            if(([self.productDetailsArray count] > 0))
            {
                [self loadTableViewAndWebView];
                
            }
            [self removeActivityAndLoadingLabel];
            
        }
    }
}

- (void)addViewControllersToView
{
    self.navigationItem.titleView = [UILabel navBarTitleLabel:[[TagManager sharedInstance]
                                                               tagByName:kTagSfmTroubleShooting]];
    
    self.navigationController.navigationBar.barTintColor = [UIColor navBarBG]; //Only for iOS7.0 and more than 7.0
    self.navigationController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.masterViewController = [[TroubleshootingMasterViewController alloc]
                                 initWithNibName:@"TroubleshootingMasterViewController" bundle:nil];
    self.masterViewController.smSplitViewController = self;
    self.masterViewController.productId = self.productId;
    self.masterViewController.productName = self.productName;
    
    self.detailViewController = [[TroubleshootingDetailViewController alloc] initWithNibName:@"TroubleshootingDetailViewController" bundle:nil];
    self.detailViewController.smSplitViewController = self;
    self.delegate = self.detailViewController;
    self.viewControllers = @[self.masterViewController,self.detailViewController];
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
                        [self loadTableViewAndWebView];
                    }
                    else
                    {
                        AlertViewHandler *alert = [[AlertViewHandler alloc] init];
                        [alert showAlertViewWithTitle:[[TagManager sharedInstance]tagByName:kTagAlertTitleError] Message:[[TagManager sharedInstance]tagByName:kTagTroubleShootingError] Delegate:self cancelButton:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk ] andOtherButton:nil];
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
    if(self.loadMask == NO)
    {
        if(!([self.productName  length]) > 0)
        {
            
            //            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[[TagManager sharedInstance]tagByName:kTagAlertTitleError]
            //                                                               message:[[TagManager sharedInstance]tagByName:kTagTroubleShootingError]
            //                                                              delegate:self
            //                                                     cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk ]
            //                                                     otherButtonTitles:nil, nil];
            //            [alertView show];
            
            
            AlertViewHandler *alert = [[AlertViewHandler alloc] init];
            [alert showAlertViewWithTitle:[[TagManager sharedInstance]tagByName:kTagAlertTitleError]
                                  Message:[[TagManager sharedInstance]tagByName:kTagTroubleShootingError]
                                 Delegate:self cancelButton:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk ]
                           andOtherButton:nil];
            
            [self removeActivityAndLoadingLabel];
        }
        else
        {
            [self getProductDetails];
        }
        self.view.backgroundColor = [UIColor redColor];
        self.loadMask = YES;
    }
    
}
- (void)showProductManualForActions
{
    ProductManualViewController *controller = [[ProductManualViewController alloc] init];
    controller.productName = self.productName;
    controller.productId = self.productId;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:[[TagManager sharedInstance]tagByName:kTagSfmTroubleShooting] style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)showOptionsForActionButton
{
    [self AddProductManualViewController];
    self.mySideBar = [[SMActionSideBarViewController alloc] initWithDirectionFromRight:YES];
    self.mySideBar.sideBarWidth = 320;
    self.mySideBar.delegate = self;
    [self.mySideBar addChildViewController:self.tempViewController];
    self.tempViewController.sideMenu = self.mySideBar;
    [self.mySideBar setContentViewInSideBar:self.tempViewController.view];
    [self.tempViewController willMoveToParentViewController:self.mySideBar];
}

- (void)showMenu:(id)sender {
    
    if (self.mySideBar.hasShownSideBar) {
        [self.mySideBar dismissAnimated:YES];
    }
    [self.mySideBar showInViewController:self animated:YES];
}

- (void)AddProductManualViewController
{
    self.tempViewController = [[ActionDisplayTableViewController alloc]initWithNibName:@"ActionDisplayTableViewController" bundle:nil];
    self.tempViewController.delegate = self;
    self.tempViewController.list = [[NSMutableArray alloc] init];
    
    if(self.productId != nil)
    {
        [self.tempViewController.list addObject: [[TagManager sharedInstance] tagByName:kTagProductManualTitle]];
        [self.tempViewController.list addObject:[[TagManager sharedInstance] tagByName:kTagChatterTitle]];
    }
}

- (void)loadProductmanual
{
    if ( [StringUtil isStringEmpty:self.productId])
    {
        //        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[[TagManager sharedInstance]tagByName:kTagAlertTitleError]
        //                                                           message:[[TagManager sharedInstance] tagByName:kTagProductManualNotPresent]
        //                                                          delegate:self
        //                                                 cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk ]
        //                                                 otherButtonTitles:nil, nil];
        //
        //
        //
        //
        //        [alertView show];
        
        
        AlertViewHandler *alert = [[AlertViewHandler alloc] init];
        [alert showAlertViewWithTitle:[[TagManager sharedInstance]tagByName:kTagAlertTitleError]
                              Message:[[TagManager sharedInstance] tagByName:kTagProductManualNotPresent]
                             Delegate:self cancelButton:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk ]
                       andOtherButton:nil];
        
        
    }
    else
    {
        ProductManualViewController *controller = [[ProductManualViewController alloc] init];
        controller.productName = self.productName;
        controller.productId = self.productId;
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:[[TagManager sharedInstance] tagByName:kTagSfmTroubleShooting ]
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:nil action:nil];
        self.navigationItem.backBarButtonItem = backButton;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
}

- (void)loadTableViewAndWebView
{
    TroubleshootDataModel *model =  [self.masterViewController.productDetailsArray objectAtIndex:0];
    [self.masterViewController.troubleshootTableView reloadData];
    NSIndexPath *firstRowPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.masterViewController.troubleshootTableView selectRowAtIndexPath:firstRowPath animated:NO scrollPosition: UITableViewScrollPositionNone];
    [self.masterViewController setDetailButtonTitle:model.Name];
    if([model.Type isEqualToString:@"zip"])
    {
        [self.detailViewController loadWebViewForThedocId:model.Id andThedocName:model.Name];
    }
    else
    {
        //        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[[TagManager sharedInstance]tagByName:kTagAlertTitleError]
        //                                                           message:@"File format is incorrect"
        //                                                          delegate:nil
        //                                                 cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]
        //                                                 otherButtonTitles:nil, nil];
        
        
        AlertViewHandler *alert = [[AlertViewHandler alloc] init];
        [alert showAlertViewWithTitle:[[TagManager sharedInstance]tagByName:kTagAlertTitleError]
                              Message:@"File format is incorrect"
                             Delegate:self cancelButton:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk ]
                       andOtherButton:nil];
        
        // [alertView show];
    }
    
}


#pragma mark - Chatter
- (void)loadChatter
{
    
    if ([StringUtil isStringEmpty:self.productId]) {
        [[AlertMessageHandler sharedInstance] showCustomMessage:[[TagManager sharedInstance] tagByName:kTagTroubleShootingNoProductInfoError]
                                                   withDelegate:nil
                                                            tag:0
                                                          title:[[TagManager sharedInstance] tagByName:kTagAlertTitleError]
                                              cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]
                                           andOtherButtonTitles:nil];
    }
    else {
        ChatterViewController *chatterView = [[ChatterViewController alloc] initWithNibName:@"ChatterViewController"
                                                                                     bundle:nil];
        chatterView.productName = self.productName;
        chatterView.productId = self.productId;
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:[[TagManager sharedInstance] tagByName:kTagSfmTroubleShooting]
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:nil action:nil];
        self.navigationItem.backBarButtonItem = backButton;
        [self.navigationController pushViewController:chatterView animated:YES];
    }
}


#pragma mark - End


@end
