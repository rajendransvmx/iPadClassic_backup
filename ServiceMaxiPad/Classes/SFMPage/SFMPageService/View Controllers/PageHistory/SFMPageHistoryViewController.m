//
//  SFMPageHistoryViewController.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 16/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPageHistoryViewController.h"
#import "SFMPageHistoryHeaderSectionView.h"
#import "SFMPageHistoryInfo.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import "SFMPageHistoryCell.h"
#import "TagManager.h"
#import "StringUtil.h"
#import "SFMPageViewModel.h"
#import "TaskGenerator.h"
#import "TaskModel.h"
#import "CacheManager.h"
#import "FlowDelegate.h"
#import "TaskManager.h"
#import "SFMPageHistoryHelper.h"
#import "NonTagConstant.h"
#import "WebserviceResponseStatus.h"
#import "MBProgressHUD.h"
#import "AlertMessageHandler.h"
#import "SNetworkReachabilityManager.h"

#define kIncludeOnlineResultItemsButtonTag 999

@interface SFMPageHistoryViewController () <FlowDelegate>

@property(nonatomic, strong)MBProgressHUD *HUD;

@end

@implementation SFMPageHistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.shouldScrollContent = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect tableViewFrame = [self getTableViewFrame];
    
    self.historyTableView.frame = tableViewFrame;
    
    
    self.historyTableView.layer.borderColor = [UIColor getUIColorFromHexValue:kSeperatorLineColor].CGColor;
    self.historyTableView.layer.borderWidth = 1.0;
    self.historyTableView.layer.cornerRadius = 5.00;

    
    self.historyTableView.backgroundColor = [UIColor clearColor];
    self.historyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.historyTableView.tableHeaderView = [self viewForTableHeader];
    self.historyTableView.tableFooterView = [self viewForTableFooter];
    
    self.historyTableView.scrollEnabled = self.shouldScrollContent;
    
   // [self registerNetoworkNotification];
    
}

- (CGRect)getTableViewFrame
{
    CGRect tableViewFrame = self.view.frame;
    tableViewFrame.origin.x = 10;
    tableViewFrame.size.width = self.view.frame.size.width - 20;
    tableViewFrame.origin.y = 10;
    tableViewFrame.size.height = self.view.frame.size.height - 40;
    
    return tableViewFrame;
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setTableViewFrame];
}

- (void)setTableViewFrame
{
    
    CGFloat tableViewHeight = 0;
    CGFloat tableViewFooterHeight = CGRectGetHeight(self.historyTableView.tableFooterView.bounds);
    CGFloat tableViewHeaderHeight = CGRectGetHeight(self.historyTableView.tableHeaderView.bounds);
    tableViewHeight = tableViewFooterHeight+tableViewHeaderHeight;
    NSInteger numberOfRows = [self.historyInfo count] * 2;
    for (int rowIndex = 0; rowIndex<numberOfRows; rowIndex++) {
        tableViewHeight += 60;
    }
    
    CGFloat viewHeight = CGRectGetHeight(self.view.bounds);
    if (tableViewHeight<viewHeight-20) {
        CGRect frame = self.historyTableView.frame;
        frame.size.height = tableViewHeight+20;
        self.historyTableView.frame = frame;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)dealloc {
    self.historyTableView = nil;
   // [[NSNotificationCenter defaultCenter] removeObserver:self name:kNetworkConnectionChanged object:nil];
}

#pragma mark - UITableView Delegate and DataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.historyInfo count] * 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFMPageHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    if (cell == nil) {
        cell = [[SFMPageHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    
    cell.descriptionTitle.text = [self getDescriptionDataForIndex:indexPath.row];
    cell.descriptionTitle.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize16];
    
    cell.descriptionData.text = [self getDataForIndex:indexPath.row];
    cell.descriptionData.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize14];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UIView *)viewForTableHeader
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 06.0, self.historyTableView.frame.size.width, 60.0)];
  
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:headerView.frame];
    headerLabel.text = [self titleForHeaderInSection];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize20];
    headerLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [headerView addSubview:headerLabel];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}


- (UIView *) viewForTableFooter
{
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.historyTableView.frame.size.width, 60)];
    
    CGRect frame = CGRectMake(10, 15, 200, 40);
    
    UIButton *seeMore = [[UIButton alloc] initWithFrame:frame];
    [seeMore setTitle:[[TagManager sharedInstance]tagByName:kTag_IncludeOnlineItems] forState:UIControlStateNormal];
    seeMore.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    seeMore.titleLabel.font = [UIFont fontWithName:kHelveticaNeueRegular  size:kFontSize16];
    [seeMore addTarget:self action:@selector(seeMoreClicked) forControlEvents:UIControlEventTouchUpInside];
    seeMore.tag = kIncludeOnlineResultItemsButtonTag;
    
    [self checkStatusForSeeMore:seeMore];
    [footerView addSubview:seeMore];
    
    return footerView;
}


- (void)checkStatusForSeeMore:(UIButton *)seeMore
{
    BOOL status = YES;
    if (self.historyInfoType == HistoryTypeProduct) {
        if (![self isProdutExists]) {
            status = NO;
        }
    }
    else if (self.historyInfoType == HistoryTypeAccount) {
        if (![self isAccountExists]) {
            status = NO;
        }
    }
    [self grayOutSeeMore:seeMore status:status];

}

- (void)grayOutSeeMore:(UIButton *)seeMore status:(BOOL)status
{
    if (status) {
        seeMore.userInteractionEnabled = YES;
        seeMore.backgroundColor = [UIColor getUIColorFromHexValue:@"#FF6633"];
        [seeMore setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else {
        seeMore.userInteractionEnabled = NO;
        seeMore.layer.borderColor =[UIColor getUIColorFromHexValue:@"#AEAEAE"].CGColor;
        [seeMore setBackgroundColor:[UIColor getUIColorFromHexValue:@"#AEAEAE"]];
        [seeMore setTitleColor:[UIColor getUIColorFromHexValue:@"#FFFFFF"] forState:UIControlStateNormal];

    }
}

- (void)registerNetoworkNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkDidChangeNotification:) name:kNetworkConnectionChanged object:nil];
}

-(void)networkDidChangeNotification:(NSNotification *)notification {
    NSNumber *networkStatus = (NSNumber *)[notification object];
    UIButton *includeOnlineBtn = (UIButton *)[self.view viewWithTag:kIncludeOnlineResultItemsButtonTag];
    switch ([networkStatus intValue]) {
        case 0:
            [includeOnlineBtn setUserInteractionEnabled:NO];
            [includeOnlineBtn setAlpha:0.5];
            break;
        case 1:
            [includeOnlineBtn setUserInteractionEnabled:YES];
            [includeOnlineBtn setAlpha:1.0];
            break;
        default:
            break;
    }
}

- (void)seeMoreClicked
{
    if (self.historyInfoType == HistoryTypeAccount) {
        [self startAccountHistoryRequestOnline];
    }
    else if (self.historyInfoType == HistoryTypeProduct) {
        [self startProductHistoryRequstOnline];
    }
}

- (BOOL)isAccountExists
{
    BOOL result = NO;
    
    TransactionObjectModel *model = [SFMPageHistoryHelper getAccountHistoryInfo:self.sfPage.objectName
                                                                       recordId:self.sfPage.recordId];
    
    if ([[model valueForField:kWorkOrderCompanyId] length ] > 0) {
        result  = YES;
    }
    
    return result;
    
    
}

- (BOOL)isProdutExists
{
    BOOL result = NO;
    
    TransactionObjectModel *model = [SFMPageHistoryHelper getProductHistoryInfo:self.sfPage.objectName
                                                                       recordId:self.sfPage.recordId];

    if ([[model valueForField:kComponentId] length] > 0) {
        result = YES;
    }
    else if ([[model valueForField:kTopLevelId] length] > 0) {
        result = YES;
    }
    
    return result;
}
- (void)startAccountHistoryRequestOnline
{
    TransactionObjectModel *model = [SFMPageHistoryHelper getAccountHistoryInfo:self.sfPage.objectName
                                                                       recordId:self.sfPage.recordId];
    NSString *sfId = [model valueForField:kId];
    NSString *acccountId = [model valueForField:kWorkOrderCompanyId];
    NSString *createdDate = [model valueForField:kTextCreateDate];
    
    if ([sfId length] > 0 && [acccountId length] > 0 && [createdDate length] > 0) {
        [self pushPageHistoryDetailsToCache:kAccHistory model:model];
        [self performSelectorInBackground:@selector(createTaskForAccHistory) withObject:nil];
    }
}

- (void)startProductHistoryRequstOnline
{
    TransactionObjectModel *model = [SFMPageHistoryHelper getProductHistoryInfo:self.sfPage.objectName
                                                                       recordId:self.sfPage.recordId];
    NSString *sfId = [model valueForField:kId];
    NSString *productId = [model valueForField:kComponentId];
    NSString *topLevelTd = [model valueForField:kTopLevelId];
    NSString *createdDate = [model valueForField:kTextCreateDate];
    
    if ([sfId length] > 0 &&
        ([productId length] > 0 || [topLevelTd length] >0)
        && [createdDate length] > 0) {
        [self pushPageHistoryDetailsToCache:kProHistory model:model];
        [self createTaskForProHistory];
    }
}

- (void)createTaskForAccHistory
{
    [self performSelectorOnMainThread:@selector(showAnimator) withObject:nil waitUntilDone:YES];
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeAccountHistory
                                             requestParam:nil
                                           callerDelegate:self];
    
    [[TaskManager sharedInstance] addTask:taskModel];
}

- (void)createTaskForProHistory
{
    [self performSelectorOnMainThread:@selector(showAnimator) withObject:nil waitUntilDone:YES];
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeProductHistory
                                             requestParam:nil
                                           callerDelegate:self];
    
    [[TaskManager sharedInstance] addTask:taskModel];
}

- (void)pushPageHistoryDetailsToCache:(NSString *)key model:(TransactionObjectModel *)data
{
    [[CacheManager sharedInstance] pushToCache:data byKey:key];
}

- (void)clearCacheByKey:(NSString *)key
{
    [[CacheManager sharedInstance] clearCacheByKey:key];
}

#pragma mark -END

- (NSString *)titleForHeaderInSection
{
    NSString *title = @"";
    
    if (self.historyInfoType == HistoryTypeAccount) {
        title = [[TagManager sharedInstance] tagByName:kTag_AcHistoryAndRecords];//[[TagManager sharedInstance] tagByName:kTag_AccountHistory];
    }
    else if (self.historyInfoType == HistoryTypeProduct){
        title = [[TagManager sharedInstance] tagByName:kTag_ProductHistoryAndRecords];//[[TagManager sharedInstance] tagByName:kTag_ProductHistory_Records];
    }
    return title;
}

- (NSString *)getDescriptionDataForIndex:(NSInteger)index
{
    NSInteger modValue = index % 2;
    if (modValue == 0) {
        return [[TagManager sharedInstance] tagByName:kTagServiceReportProblemDescription];
    }
    else{
        return [[TagManager sharedInstance] tagByName:kTagSfmCreatedDate];
    }
    return nil;
}


- (NSString *)getDataForIndex:(NSInteger)index
{
    NSString *string = @"";
    
    NSInteger modValue = index % 2;
    
    NSInteger value = index;
    if (index != 0) {
        value = index / 2;
    }
    
    SFMPageHistoryInfo *model = (SFMPageHistoryInfo *)[self.historyInfo objectAtIndex:value];
    
    if (modValue == 0) {
        string = model.problemDescription;
    }
    else{
        string = model.createdDate;
    }
    if ([StringUtil isStringEmpty:string]){
        string = @"--";
    }
    
    return string;
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self setTableViewFrame];
    
}

-(CGFloat)contentViewHeight
{
    CGFloat tableViewHeight = 0;
    CGFloat tableViewFooterHeight = 60;
    CGFloat tableViewHeaderHeight = 60;
    tableViewHeight = tableViewFooterHeight+tableViewHeaderHeight;
    NSInteger numberOfRows = [self.historyInfo count] * 2;
    for (int rowIndex = 0; rowIndex<numberOfRows; rowIndex++) {
        tableViewHeight += 60;
    }
    return tableViewHeight + 50;
}

- (void)resetViewPage:(SFMPageViewModel*)sfmViewPageModel
{
    if (self.historyInfoType == HistoryTypeProduct) {
        self.historyInfo = sfmViewPageModel.productHistory;
    }else if (self.historyInfoType == HistoryTypeAccount)
        self.historyInfo = sfmViewPageModel.accountHistory;
    [self reloadTable];
    [self performSelector:@selector(reloadFooter) withObject:nil afterDelay:0.1];
}

- (void)reloadTable
{
    [self.historyTableView reloadData];
}

- (void)reloadFooter
{
    UIView *footerView =  [self.historyTableView tableFooterView];
    
    UIButton *includeOnlineBtn = (UIButton *)[footerView viewWithTag:kIncludeOnlineResultItemsButtonTag];
    [self performSelectorOnMainThread:@selector(checkStatusForSeeMore:) withObject:includeOnlineBtn waitUntilDone:YES];
}

- (void)hideAnimator
{
    if (self.HUD) {
        [self.HUD hide:YES];
        self.HUD = nil;
    }
}

- (void)showAnimator
{
    if (!self.HUD) {
        self.HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
        [self.view.window addSubview:self.HUD];
        // Set determinate mode
        self.HUD.mode = MBProgressHUDModeIndeterminate;
        [self.HUD show:YES];
    }
}


#pragma mark - Flow node delegate
- (void)flowStatus:(id)status
{
    if([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *st = (WebserviceResponseStatus*)status;
        switch (st.category)
        {
            case CategoryTypeProductHistory:
            {
                if  (st.syncStatus == SyncStatusSuccess) {
                    [self requestSucess:kProHistory];
                }
                else if (st.syncStatus == SyncStatusFailed) {
                    [self requestFialedWithError:st.syncError key:kProHistory];
                }
            }
            break;
            case CategoryTypeAccountHistory:
            {
                if  (st.syncStatus == SyncStatusSuccess) {
                    [self requestSucess:kAccHistory];
                }
                else if (st.syncStatus == SyncStatusFailed) {
                    [self requestFialedWithError:st.syncError key:kAccHistory];
                }
            }
            break;
            default:
                break;
        }
    }
}
#pragma mark - End


- (void)requestFialedWithError:(NSError *)error key:(NSString *)requestKey
{
    if (error ) {
        [[AlertMessageHandler sharedInstance] showCustomMessage:[error errorEndUserMessage]
                                                   withDelegate:nil
                                                            tag:0
                                                          title:[[TagManager sharedInstance] tagByName:kTagSyncErrorMessage]
                                              cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]
                                           andOtherButtonTitles:nil];
    }
    [self hideAnimator];
    [self clearCacheByKey:requestKey];
    
}

- (void)requestSucess:(NSString *)requestKey
{
    [self hideAnimator];
    [self clearCacheByKey:requestKey];
    [self reloadDataWithOnineResults];
}

- (void)reloadDataWithOnineResults
{
    @synchronized (self) {
        NSArray *results = [self getOnlineResultSetFromCache];
        
        if (self.historyInfoType == HistoryTypeProduct) {
            self.historyInfo = results;
        }
        else if (self.historyInfoType == HistoryTypeAccount) {
            self.historyInfo = results;
        }
        [self resetView];
    }
}

- (void)resetView
{
    [self resetTableViewFrame];
    [self reloadTable];
    [self notifyParentView];
    [self clearCacheByKey:@"PageHistoryResults"];
}

- (void)resetTableViewFrame
{
    CGRect tableViewFrame = [self getTableViewFrame];
    self.historyTableView.frame = tableViewFrame;
}

- (NSArray *)getOnlineResultSetFromCache
{
    return (NSArray *)[[CacheManager sharedInstance] getCachedObjectByKey:@"PageHistoryResults"];
}

- (void)notifyParentView
{
    if ([self.pageHistoryDelegate conformsToProtocol:@protocol(SFMPageHistoryDelegate)]) {
        [self.pageHistoryDelegate reloadPageHistoryParentView];
    }
}

-(void)setScrollEnabled:(BOOL)state
{
    self.historyTableView.scrollEnabled = state;
}
@end
