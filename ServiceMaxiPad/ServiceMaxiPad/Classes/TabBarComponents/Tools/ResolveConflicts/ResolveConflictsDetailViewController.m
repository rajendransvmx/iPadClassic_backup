//
//  ResolveConflictsDetailViewController.m
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 22/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "ResolveConflictsDetailViewController.h"
#import "ResolveConflictsHelper.h"
#import "SyncErrorConflictModel.h"
#import "ResolveConflictCell.h"
#import "ResolveConflictActionVC.h"
#import "StringUtil.h"
#import "SyncManager.h"
#import "SyncProgressDetailModel.h"
#import "SFMPageViewController.h"
#import "SFMViewPageManager.h"
#import "AlertMessageHandler.h"
#import "TagManager.h"

static NSString *kConflictCellIdentifier = @"ConflictCellIdentifier";

@interface ResolveConflictsDetailViewController ()<UITableViewDataSource,
                                                   UITableViewDelegate,
                                                   ResolveConflictActionDelegate>

@property (nonatomic, strong) NSArray *conflictsArray;
@property (nonatomic, weak)IBOutlet UITableView *conflictsListView;
@property (nonatomic, strong) ResolveConflictActionVC *resolveConflictActionVC;

@end

@implementation ResolveConflictsDetailViewController

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
    // Do any additional setup after loading the view from its nib.
    //self.smSplitViewController.navigationItem.titleView = [UILabel navBarTitleLabel:@"Resolve Conflicts"];
    [self.smPopover dismissPopoverAnimated:YES];
    
    [self setUpTableView];
    [self loadConfictsList];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedDataSyncStatusNotification:)
                                                 name:kDataSyncStatusNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedSyncConflictChangeNotification:)
                                                 name:kSyncConflictChangeNotification
                                               object:nil];
}
#pragma mark - Data Sync Status Update
- (void)receivedDataSyncStatusNotification:(NSNotification *)notification
{
/*
 * Commented due to issue in syncmanager not sending notification properly.
 */
//    id statusObject = [notification.userInfo objectForKey:@"syncstatus"];
//    if ([statusObject isKindOfClass:[SyncProgressDetailModel class]]) {
//        SyncProgressDetailModel *progressObject = [notification.userInfo objectForKey:@"syncstatus"];
//        if ((progressObject.syncStatus == SyncStatusSuccess)||
//            (progressObject.syncStatus == SyncStatusFailed) ||
//            (progressObject.syncStatus == SyncStatusConflict))
//        {
            [self reloadResolveConflictScreenOnNotification];
//        }
//    }
}

- (void)receivedSyncConflictChangeNotification:(NSNotification *)notification {
    [self reloadResolveConflictScreenOnNotification];
}

- (void)reloadResolveConflictScreenOnNotification {
    
    if (self.resolveConflictActionVC) {
        [self.resolveConflictActionVC dismissViewControllerAnimated:YES completion:nil];
        self.resolveConflictActionVC = nil;
    }
    [self loadConfictsList];
    [self.conflictsListView reloadData];

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - End

-(void)setUpTableView {
    
    self.conflictsListView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
}


-(void)loadConfictsList {
    
    self.conflictsArray = [ResolveConflictsHelper getConflictsRecords];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.conflictsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ResolveConflictCell *cell = [tableView dequeueReusableCellWithIdentifier:kConflictCellIdentifier];
    if (cell == nil) {
        
        UINib *nib = [UINib nibWithNibName:@"ResolveConflictCell" bundle:[NSBundle mainBundle]];
        [self.conflictsListView registerNib:nib forCellReuseIdentifier:kConflictCellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:kConflictCellIdentifier];
    }

    [self configureCell:cell forConflictModel:[self.conflictsArray objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)configureCell:(ResolveConflictCell *)cell forConflictModel:(SyncErrorConflictModel *)model {
    
    NSAssert(cell  != NULL, @"configureCell:forConflictModel: cell passed must not be NULL!");
    NSAssert(model != NULL, @"configureCell:forConflictModel: model passed must not be NULL!");
    
    cell.objectLabel.text     = model.objectLabel;
    cell.objectNameLabel.text = model.recordValue;
    if ([StringUtil isStringEmpty:model.recordValue]) {
        cell.objectNameLabel.text = @"- - - -";
    }

    if ([StringUtil isStringEmpty:model.overrideFlag]) {
        
        [cell configureCellForResolve];
    } else {
        
        [cell configureCellForResolutionWithUserResolution:[ResolveConflictsHelper getLocalizedUserResolutionStringForDatabaseString:model.overrideFlag]];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView         = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor whiteColor];
    CGRect frame      = self.conflictsListView.frame;
    frame.origin.x    = 10;
    frame.size.height = 35;
    
    UILabel *headerLbl = [[UILabel alloc] initWithFrame:frame];
    headerLbl.font     = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize18];
    headerLbl.text     = [@"" stringByAppendingFormat:@"Sync Conflicts (%ld)", (long)self.conflictsArray.count];
    [headerView addSubview:headerLbl];
    
    frame.origin.y    = frame.size.height - 1;
    frame.size.height = 1;
    
    UIView *separatorLine = [[UIView alloc] initWithFrame:frame];
    separatorLine.backgroundColor = [UIColor grayColor];
    [headerView addSubview:separatorLine];
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self displayConflictActionsDetailForConflict:[self.conflictsArray objectAtIndex:indexPath.row]];
}

-(void)displayConflictActionsDetailForConflict:(SyncErrorConflictModel *)conflict {
    
    /*
     * Just in case old instance is still in edit.
     */
    [self dismissResolveConflictActionIfNeeded];
    self.resolveConflictActionVC = [[ResolveConflictActionVC alloc]initWithNibName:@"ResolveConflictActionVC" bundle:[NSBundle mainBundle]];
    self.resolveConflictActionVC.modalPresentationStyle = UIModalPresentationFormSheet;
    self.resolveConflictActionVC.delegate = self;
    [self.resolveConflictActionVC configureAndShowActionsForConflict:conflict];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ResolveConflictActionDelegate methods
- (void)resolveConflictActionVC:(ResolveConflictActionVC *)resolveConflictActionVC userPressedApplyForConflict:(SyncErrorConflictModel *)conflict {
    
    [ResolveConflictsHelper saveConflict:conflict];
    [self reloadResolveConflictScreenOnNotification];
}

- (void)resolveConflictActionVC:(ResolveConflictActionVC *)resolveConflictActionVC userPressedCancelForConflict:(SyncErrorConflictModel *)conflict {
    /*
     * Do nothing as user has presed cancel.
     */
    [self dismissResolveConflictActionIfNeeded];
}

- (void)resolveConflictActionVC:(ResolveConflictActionVC *)resolveConflictActionVC userPressedNavigateForConflict:(SyncErrorConflictModel *)conflict {
    
    [self dismissResolveConflictActionIfNeeded];
    [self navigateToObjectForConflict:conflict];
    
}
#pragma mark - End

- (void)dismissResolveConflictActionIfNeeded {
    
    if (self.resolveConflictActionVC && self.resolveConflictActionVC.isBeingPresented) {
        /*
         * We know for some reason its still presented, lets dismiss it.
         * Ideally this woundn't get called. But still just to be safe.
         */
        [self.resolveConflictActionVC dismissViewControllerAnimated:YES
                                                         completion:nil];
        self.resolveConflictActionVC.delegate = nil;
        self.resolveConflictActionVC = nil;
    }
}

- (void)navigateToObjectForConflict:(SyncErrorConflictModel *)conflict {
    
    
    [self dismissResolveConflictActionIfNeeded];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Resolve Conflicts" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.smSplitViewController.navigationItem.backBarButtonItem = backButton;

    SFMPageViewController *pageViewController = [[SFMPageViewController alloc]init];
    SFMViewPageManager *pageManager = [[SFMViewPageManager alloc] initWithObjectName:conflict.objectName
                                                                            recordId:conflict.localId];
    
    NSError *error = nil;
    BOOL isValidProcess = [pageManager isValidProcess:pageManager.processId
                                                error:&error];
    if (isValidProcess) {
        pageViewController.sfmPageView = [pageManager sfmPageView];
        [self.smSplitViewController.navigationController pushViewController:pageViewController
                                                                   animated:YES];
    }
    else
    {
        if (error) {
            AlertMessageHandler *alertHandler = [AlertMessageHandler sharedInstance];
            NSString * button = [[TagManager sharedInstance] tagByName:kTagAlertErrorOk];
            
            [alertHandler showCustomMessage:[error localizedDescription]
                               withDelegate:nil
                                      title:[[TagManager sharedInstance] tagByName:kTagAlertIpadError]
                          cancelButtonTitle:nil
                       andOtherButtonTitles:[[NSArray alloc] initWithObjects:button, nil]];
        }
    }
}

@end
