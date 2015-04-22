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
#import "TroubleshootDataModel.h"
#import "SNetworkReachabilityManager.h"

@interface TroubleshootingMasterViewController()

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) TroubleshootDataModel *docModel;
@property (nonatomic, strong) TroubleshootingDetailViewController *detailViewController;

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
    self.troubleshootTableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftPanelBG.png"]];
    self.troubleshootTableView.delegate = self;
    self.troubleshootTableView.dataSource = self;
    [self setSearchBarBackGround];
    self.searchBar.layer.borderColor = [UIColor colorWithHexString:kSeperatorLineColor].CGColor;
    self.troubleshootTableView.tableFooterView = [[UIView alloc] init] ;
    self.detailViewController = [self.smSplitViewController.viewControllers lastObject];

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
    return 60.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TroubleshootCell1";
     if ([self.productDetailsArray count] > 0)
     {
         UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
         
         if (cell == nil)
         {
             cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
             [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
         }
         
         TroubleshootDataModel *model =[self.productDetailsArray objectAtIndex:indexPath.row];
         cell.textLabel.text = model.Name;
         cell.textLabel.font = [UIFont fontWithName:kHelveticaNeueLight size:kFontSize18];
         cell.textLabel.textColor = [UIColor colorWithHexString:kOrangeColor];
         cell.textLabel.highlightedTextColor = [UIColor colorWithHexString:kWhiteColor];
         UIView *bgColorView = [[UIView alloc] init];
         [bgColorView setBackgroundColor:[UIColor colorWithHexString:kMasterSelectionColor]];
         [cell setSelectedBackgroundView:bgColorView];
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
    TroubleshootDataModel *model = [self.productDetailsArray objectAtIndex:index];
    
    if ((model.Id != nil) && (model.Name != nil) )
    {
        if([model.Type isEqualToString:@"zip"])
        {
            [self.detailViewController loadWebViewForThedocId:model.Id andThedocName:model.Name];
            
        }
        else
        {
            [self.detailViewController loadWebViewForThedocId:@"" andThedocName:@""];

            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[[TagManager sharedInstance]tagByName:kTagAlertTitleError] message:@"File format is incorrect" delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles:nil, nil];
            [alertView show];
        }
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
    if (([self.searchBar.text length ]) > 0)
    {
        if ( [[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
        {
            if ([[AppManager sharedInstance] hasTokenRevoked])
            {
                
                [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeAccessTokenExpired
                                                                       message:nil
                                                                   andDelegate:nil];
            }
            else
            {
                 [self addActivityAndLoadingLabel];
                [TroubleshootingDataLoader makingRequestForDetailsByProductName:self.searchBar.text
                                                          withTheCallerDelegate:self];
               
                
            }
            
        }
        else
        {
            self.productDetailsArray = [TroubleshootingDataHelper fetchProductDetailsbyProductName:self.searchBar.text];
            
            if (([self.productDetailsArray count] > 0))
            {
                TroubleshootDataModel *model = [self.productDetailsArray objectAtIndex:0];
                [self.troubleshootTableView reloadData];
                [self setDetailButtonTitle:model.Name];
                NSIndexPath *firstRowPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.troubleshootTableView selectRowAtIndexPath:firstRowPath animated:NO scrollPosition: UITableViewScrollPositionNone];
                [self tableView:self.troubleshootTableView didSelectRowAtIndexPath:firstRowPath];
                if([model.Type  isEqualToString:@"zip"])
                {
                    [self.detailViewController loadWebViewForThedocId:model.Id andThedocName:model.Name];
                    
                }
                else
                {
                    [self.detailViewController loadWebViewForThedocId:@"" andThedocName:@""];
                    
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[[TagManager sharedInstance]tagByName:kTagAlertTitleError] message:@"File format is incorrect" delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles:nil, nil];
                    [alertView show];
                }
                [self removeActivityAndLoadingLabel];
            }
            else
            {
                [self.troubleshootTableView reloadData];
                [self setDetailButtonTitle:@""];
                [self removeActivityAndLoadingLabel];
                [self.detailViewController loadWebViewForThedocId:@"" andThedocName:@""];
            }
        }
    }
}

- (void) setDetailButtonTitle:(NSString *)title
{
    [self.detailViewController setContentWithItem:title];

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
                    self.productDetailsArray = [TroubleshootingDataHelper fetchProductDetailsbyProductName:self.searchBar.text];
                    if(([self.productDetailsArray count]) > 0)
                    {
                        if (self.troubleshootTableView.window)
                        {
                            [self.troubleshootTableView reloadData];
                            TroubleshootDataModel *model = [self.productDetailsArray objectAtIndex:0];
                            [self setDetailButtonTitle:model.Name];
                            [self removeActivityAndLoadingLabel];
                            NSIndexPath *firstRowPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            [self.troubleshootTableView selectRowAtIndexPath:firstRowPath animated:NO scrollPosition: UITableViewScrollPositionNone];
                            if([model.Type isEqualToString:@"zip"])
                            {
                                [self.detailViewController loadWebViewForThedocId:model.Id andThedocName:model.Name];
                            }
                            else
                            {
                                [self.detailViewController loadWebViewForThedocId:@"" andThedocName:@""];
                                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[[TagManager sharedInstance]tagByName:kTagAlertTitleError] message:@"File format is incorrect" delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles:nil, nil];
                                [alertView show];
                            }
                            
                        }
                    }
                    else
                    {
                        if (self.troubleshootTableView.window) {
                            [self.troubleshootTableView reloadData];
                            [self removeActivityAndLoadingLabel];
                            [self setDetailButtonTitle:@""];
                            [self.detailViewController loadWebViewForThedocId:@"" andThedocName:@""];
                            
                        }
                    }
                }
                
                else if (st.syncStatus == SyncStatusFailed)
                {
                    [self setDetailButtonTitle:@""];
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

- (void)setSearchBarBackGround
{
    self.searchBar.backgroundColor = [UIColor whiteColor];
    self.searchBar.searchBarStyle = UIBarStyleBlackTranslucent;
    //self.searchBar.placeholder = @"search";
    self.searchBar.layer.cornerRadius = 5;
    self.searchBar.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.searchBar.layer.borderWidth = 1;
    [[NSClassFromString(@"UISearchBarTextField") appearanceWhenContainedIn:[UISearchBar class], nil] setBorderStyle:UITextBorderStyleNone];
    self.searchBar.layer.borderColor = [UIColor colorWithHexString:kSeperatorLineColor].CGColor;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

@end
