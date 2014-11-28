//
//  SFMPageViewController.m
//  ServiceMaxiPad
//
//  Created by Aparna on 01/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPageViewController.h"
#import "SFMPageMasterViewController.h"
#import "SFMPageDetailViewController.h"
#import "TagManager.h"
#import "TagConstant.h"
#import "SMActionSideBarViewController.h"
#import "WizardViewController.h"
#import "SFWizardService.h"
#import "SFMWizardComponentService.h"
#import "SFWizardModel.h"
#import "WizardComponentModel.h"
#import "SFProcessService.h"
#import "SMNavigationTitleView.h"
#import "StringUtil.h"
#import "StyleGuideConstants.h"
#import "PlistManager.h"
#import "SFMViewPageManager.h"
#import "AlertMessageHandler.h"
#import "TagManager.h"
#import "PageEditViewController.h"
#import "TroubleshootingViewController.h"
#import "SFMRecordFieldData.h"
#import "SyncManager.h"
#import "StyleManager.h"
#import "OPDocViewController.h"
#import "FactoryDAO.h"
#import "SFProcessService.h"
#import "DocumentsViewController.h"
#import "AttachmentHelper.h"
#import "SyncProgressDetailModel.h"
#import "DODRecordsDAO.h"
#import "DODRecordsService.h"
#import "TaskGenerator.h"
#import "TaskModel.h"
#import "TaskManager.h"
#import "CacheManager.h"


@interface SFMPageViewController ()<SMActionSideBarViewControllerDelegate>
@property (nonatomic, strong) SMActionSideBarViewController *mySideBar;
@property (nonatomic, strong) WizardViewController *tempViewController;

@end

@implementation SFMPageViewController

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
    
    // Do any additional setup after loading the view.
    
    SFMPageMasterViewController *masterViewController = [[SFMPageMasterViewController alloc] initWithNibName:@"SFMPageMasterViewController" bundle:nil];
    masterViewController.sfmPageView = self.sfmPageView;
    masterViewController.smSplitViewController = self;
    
    SFMPageDetailViewController *detailViewController = [[SFMPageDetailViewController alloc] initWithNibName:@"SFMPageDetailViewController" bundle:nil];
    detailViewController.smSplitViewController = self;
    self.delegate = detailViewController;
    self.viewControllers = @[masterViewController, detailViewController];
    
    //setting title and conflict indicator image
    [self setTitleAndImageForTitleView];
    
	[self updateWizardData];
    [self setUpActionSideBar];
}

- (void)updateWizardData
{
    SFWizardService *wizardService = [[SFWizardService alloc]init];
    
    SFMWizardComponentService *wizardComponentService = [[SFMWizardComponentService alloc]init];
    
    NSMutableArray *allWizards = [wizardService getWizardsForObjcetName:self.sfmPageView.sfmPage.objectName andRecordId:self.sfmPageView.sfmPage.recordId];
    [wizardComponentService getWizardComponentsForWizards:allWizards recordId:self.sfmPageView.sfmPage.recordId];
    
    [self addUpdateDODBtninWizard:allWizards];

    [self addEventWizard:allWizards];
    /*If wizard step is not there for a wizard then it should not be shown in the tableView*/
    SFProcessService *processService = [[SFProcessService alloc]init];
    
    if (self.tempViewController == nil) {
        self.tempViewController = [[WizardViewController alloc]initWithNibName:@"WizardViewController" bundle:nil];
    }
    self.tempViewController.delegate = self;
    self.tempViewController.wizardsArray = allWizards;
    self.tempViewController.viewProcessArray = [processService fetchAllViewProcessForObjectName:self.sfmPageView.sfmPage.objectName];
    self.tempViewController.shouldShowTroubleShooting = self.sfmPageView.sfmPage.process.pageLayout.headerLayout.enableTroubleShooting;
    
    
}


-(void)addUpdateDODBtninWizard:(NSMutableArray *)allWizards
{
   
    /* Check if object already exist */
    NSString *sfIDValue = [self.sfmPageView.sfmPage getHeaderSalesForceId];
    //id <DODRecordsService>
    DODRecordsService *dodRecordService = [FactoryDAO serviceByServiceType:ServiceTypeDOD];
    //BOOL alreadyExist =  [dodRecordService doesRecordAlreadyExist:sfProcess.sfID inTable:@"DODRecords"];
    //doesRecordAlreadyExist:(NSString *)fieldName inTable:(NSString *)tableName;
    
    BOOL isOnlineRecordExist = [dodRecordService doesRecordAlreadyExistWithfieldName:@"sfId" withFieldValue:sfIDValue inTable:@"DODRecords"];
    if (isOnlineRecordExist)
    {
        SFWizardModel *wizardModel = [[SFWizardModel alloc]init];
        wizardModel.wizardName = [[TagManager sharedInstance]tagByName:kTagRefreshFromSalesForce];
        
        WizardComponentModel *wizardCompModel = [[WizardComponentModel alloc]init];
        wizardCompModel.actionType = @"DODUpdate";
        wizardCompModel.actionName = [[TagManager sharedInstance]tagByName:kTagRefreshFromSalesForce];
        wizardCompModel.isEntryCriteriaMatching = YES;
        if (wizardModel.wizardComponents == nil)
        {
            wizardModel.wizardComponents = [[NSMutableArray alloc]init];
        }
        [wizardModel.wizardComponents addObject:wizardCompModel];
        
        if ([wizardModel.wizardComponents count] >0)
        {
            [allWizards insertObject:wizardModel atIndex:0];
        }
        
    }
    
}



- (void)setUpActionSideBar
{
    if (![self.mySideBar hasShownSideBar]) {
        self.mySideBar = [[SMActionSideBarViewController alloc]initWithDirectionFromRight:YES];
        self.mySideBar.sideBarWidth = 320;
        self.mySideBar.delegate = self;
        [self.mySideBar addChildViewController:self.tempViewController];
        self.tempViewController.sideMenu = self.mySideBar;
        [self.mySideBar setContentViewInSideBar:self.tempViewController.view];
        [self.tempViewController willMoveToParentViewController:self.mySideBar];
    }
}


-(void)addEventWizard:(NSMutableArray *)addEventWizard
{
    if( self.invokedFromSearch  && [self.sfmPageView.sfmPage.objectName stringContains:@"Service_Order__c"])
    {
        SFWizardModel * wizrd = [[SFWizardModel alloc] init];
        wizrd.wizardName = @"Create Event";
        
        
        NSArray *s2tprocess = [self getS2tProcessForevent];
        
        for(SFProcessModel *processModel in s2tprocess){
            
            WizardComponentModel * compModel = [[WizardComponentModel alloc] init];
            compModel.actionDescription = processModel.processDescription;
            compModel.isEntryCriteriaMatching = YES;
            compModel.actionName = processModel.processName;
            compModel.processId = processModel.sfID;
            if(wizrd.wizardComponents == nil){
                wizrd.wizardComponents = [[NSMutableArray alloc] init];
            }
            [wizrd.wizardComponents addObject:compModel];
        }
        
        if([wizrd.wizardComponents count] > 0){
            [addEventWizard insertObject:wizrd atIndex:0];
        }
    }
    
}

-(NSArray *)getS2tProcessForevent
{
    id <SFProcessDAO> processTypeService = [FactoryDAO serviceByServiceType:ServiceTypeProcess];
    NSArray  *s2tProcess = [processTypeService getS2TEventProcessForObject:self.sfmPageView.sfmPage.objectName];
    return s2tProcess;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.navigationItem.rightBarButtonItem) {
        UIBarButtonItem *rightNavButton = [[UIBarButtonItem alloc]init];
        rightNavButton.title = [[TagManager sharedInstance]tagByName:kTagActions];
        rightNavButton.action = @selector(showMenu:);
        rightNavButton.target = self;
        self.navigationItem.rightBarButtonItems = @[rightNavButton];
    }

    [self refreshPageData];
    [self addNotificationObserver];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeNotificationObserver];
}

- (void) addNotificationObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSyncFinished) name:kDataSyncStatusNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configSyncFinished:) name:kConfigSyncStatusNotification object:nil];
}

- (void) removeNotificationObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDataSyncStatusNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kConfigSyncStatusNotification object:nil];

}

-(void)cancelButtonClicked:(id)inSender
{
    //[self dismissViewControllerAnimated:YES completion:^{}];
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)showMenu:(id)sender {

    if (self.mySideBar.hasShownSideBar) {
        [self.mySideBar dismissAnimated:YES];
    }
    [self.mySideBar showInViewController:self animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark - private method

/**
 * @name - (void)setTitleForTitleView
 *
 * @author Shubha
 *
 * @brief set title and image for titlle view.
 * @param
 * @param
 *
 * @return
 *
 */

- (void)setTitleAndImageForTitleView
{
    //Append name field value with objectlabel
    NSString *titleValue = [self.sfmPageView.sfmPage.objectLabel stringByAppendingString:@": "];
    NSString *title = self.sfmPageView.sfmPage.nameFieldValue;
    if ([title length] > 0) {
        titleValue = [titleValue stringByAppendingString:self.sfmPageView.sfmPage.nameFieldValue];
    }
    
    UIFont *font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize16];
    CGSize sizeOfText = [StringUtil getSizeOfText:titleValue withFont:font];
    
    SMNavigationTitleView *titleView = [[SMNavigationTitleView alloc]initWithFrame:CGRectZero];
    
    //based on this width title label sets frame
    titleView.titleWidth = sizeOfText.width;
    
    if (titleView.isTitleImagePresent) {
        titleView.frame = CGRectMake(0, 0,sizeOfText.width + 50,45);
    } else {
        titleView.frame = CGRectMake(0, 0,sizeOfText.width,45);
    }
    titleView.titleLabel.text = titleValue;
    self.navigationItem.titleView = titleView;
    
    //TO:DO set conflict image
}

#pragma mark - wizard delegate

/**
 * - (void)viewProcessTapped:(SFProcessModel*)sfProcess
 *
 * @author Shubha,Aparna
 *
 * @brief This delegate method gets called when a view process is tapped
 *
 * @param sfProcess
 * @param
 *
 * @return
 *
 */

- (void)viewProcessTapped:(SFProcessModel*)sfProcess
{
    SFMViewPageManager *viewPageManager = [[SFMViewPageManager alloc]initWithObjectName:sfProcess.objectApiName recordId:self.sfmPageView.sfmPage.recordId processSFId:sfProcess.sfID];
    
    NSError *error = nil;
    BOOL isValidProcess = [viewPageManager isValidProcess:viewPageManager.processId error:&error];
    if (isValidProcess) {
        self.sfmPageView.sfmPage = [viewPageManager sfmPage];
        SFMPageMasterViewController *tempMasterViewController = (SFMPageMasterViewController*)self.masterViewController;
        tempMasterViewController.sfmPageView = self.sfmPageView;
        [tempMasterViewController resetData];
        self.tempViewController.shouldShowTroubleShooting = self.sfmPageView.sfmPage.process.pageLayout.headerLayout.enableTroubleShooting;
        [self.tempViewController.tableView reloadData];
        [PlistManager storeLastUsedViewProcess:sfProcess.sfID objectName:sfProcess.objectApiName];
    }
    else
    {
        if (error) {
            AlertMessageHandler *alertHandler = [AlertMessageHandler sharedInstance];
            NSString * button = [[TagManager sharedInstance] tagByName:kTagAlertErrorOk];
            
            [alertHandler showCustomMessage:[error localizedDescription] withDelegate:nil title:[[TagManager sharedInstance] tagByName:kTagAlertIpadError] cancelButtonTitle:nil andOtherButtonTitles:[[NSArray alloc] initWithObjects:button, nil]];
        }
    }
    
}

/**
 *- (void)editProcessTapped:(NSString*)processId
 *
 * @author Shubha
 *
 * @brief This delegate method gets called when a edit process is tapped
 *
 * @param processId
 * @param
 *
 * @return
 *
 */

- (void)editProcessTapped:(NSString*)processId
{
    //load edit page
    
    SFMViewPageManager *viewPageManager = [[SFMViewPageManager alloc]initWithObjectName:self.sfmPageView.sfmPage.objectName recordId:self.sfmPageView.sfmPage.recordId processSFId:processId];
    
    NSString *processType = [viewPageManager getProcessTypeForProcessId:processId];

    if ([processType isEqualToString:kProcessTypeOutputDocument])
    {
        NSError *error = nil;
        BOOL isValidProcess = [viewPageManager isValidOPDocProcess:processId error:&error];
        if (isValidProcess)
        {
            [self loadOPDocViewController:processId];
        }
        else
        {
            if (error)
            {
                AlertMessageHandler *alertHandler = [AlertMessageHandler sharedInstance];
                NSString * button = [[TagManager sharedInstance] tagByName:kTagAlertErrorOk];
                
                [alertHandler showCustomMessage:[error localizedDescription] withDelegate:nil title:[[TagManager sharedInstance] tagByName:kTagAlertIpadError] cancelButtonTitle:nil andOtherButtonTitles:[[NSArray alloc] initWithObjects:button, nil]];
            }
        }

    }
   
    else
    {
        NSError *error = nil;
        BOOL isValidProcess = [viewPageManager isValidProcess:processId error:&error];
        if (isValidProcess) {
            
            [self loadViewControllerForProcessId:processId andProcessType:processType];
        }
        else
        {
            if (error) {
                AlertMessageHandler *alertHandler = [AlertMessageHandler sharedInstance];
                NSString * button = [[TagManager sharedInstance] tagByName:kTagAlertErrorOk];
                
                [alertHandler showCustomMessage:[error localizedDescription] withDelegate:nil title:[[TagManager sharedInstance] tagByName:kTagAlertIpadError] cancelButtonTitle:nil andOtherButtonTitles:[[NSArray alloc] initWithObjects:button, nil]];
            }
        }
    }
}

-(void)updateDODRecordFromSalesforce
{
    NSString *sfIDValue = [self.sfmPageView.sfmPage getHeaderSalesForceId];
    NSString *objectName = self.sfmPageView.sfmPage.objectName;
    CacheManager *cache = [CacheManager sharedInstance];
    [cache pushToCache:sfIDValue byKey:@"searchSFID"];
    [cache pushToCache:objectName byKey:@"searchObjectName"];
    
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeDOD
                                             requestParam:nil
                                           callerDelegate:self];
    
    //self.progressView.progress = .5f;
    //self.dodTaskID = taskModel.taskId;
    [[TaskManager sharedInstance] addTask:taskModel];
    
}


- (void)loadOPDocViewController:(NSString *)processId
{
    SFProcessService* processSrvc = (SFProcessService*)[FactoryDAO serviceByServiceType:ServiceTypeProcess];
    
    SFProcessModel *processModel = nil;
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:@"sfID" operatorType:SQLOperatorEqual andFieldValue:processId];
    
    if ([processSrvc conformsToProtocol:@protocol(SFProcessDAO)])
        processModel = [processSrvc getSFProcessInfo:criteria];
    
    OPDocViewController *sfmopdoc = [[OPDocViewController alloc] initWithNibName:@"OPDocViewController"
                                                                          bundle:nil
                                                                       forObject:self.sfmPageView.sfmPage.objectName
                                                                     forRecordId:self.sfmPageView.sfmPage.recordId
                                                                      andLocalId:self.sfmPageView.sfmPage.recordId
                                                                    andProcessId:processModel.processId
                                                                  andProcessSFId:processModel.sfID];
    
    sfmopdoc.opdocTitleString = self.sfmPageView.sfmPage.nameFieldValue;
    sfmopdoc.modalPresentationStyle = UIModalPresentationFullScreen;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:sfmopdoc];
    navController.delegate = sfmopdoc;
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    navController.navigationBar.hidden = NO;
    navController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#FF6633"];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)loadViewControllerForProcessId:(NSString *)processId andProcessType:(NSString *)processType{
    
    PageEditViewController *editViewController = nil;
    if ([processType isEqualToString:kProcessTypeStandAloneEdit]) {
      
        editViewController = [[PageEditViewController alloc] initWithProcessId:processId withObjectName:self.sfmPageView.sfmPage.objectName andRecordId:self.sfmPageView.sfmPage.recordId];
    }
    else if ([processType isEqualToString:kProcessTypeSRCToTargetAll]) {
       
        editViewController = [[PageEditViewController alloc] initWithProcessId:processId sourceObjectName:self.sfmPageView.sfmPage.objectName andSourceRecordId:self.sfmPageView.sfmPage.recordId];
    }
    else if ([processType isEqualToString:kProcessTypeStandAloneCreate]) {
        
        editViewController = [[PageEditViewController alloc] initWithProcessId:processId andObjectName:nil];
    }
    else if ([processType isEqualToString:kProcessTypeSRCToTargetChild]) {
        
        editViewController = [[PageEditViewController alloc] initWithProcessIdForSTC:processId withObjectName:self.sfmPageView.sfmPage.objectName andRecordId:self.sfmPageView.sfmPage.recordId];
    }
    if (editViewController != nil) {
        editViewController.editViewControllerDelegate = self;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:editViewController];
        [self.navigationController presentViewController:navigationController animated:YES completion:^{}];
    }
}

- (void)loadTroublShootingViewForProduct
{
    TroubleshootingViewController *controller = [[TroubleshootingViewController alloc] init];
    controller.productName = [self getProductNameFromSFmPage];
    controller.productId = [self getProductIdFromSFmPage];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Work Order" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)refreshPageData
{
    SFMPageDetailViewController *detailViewController = (SFMPageDetailViewController*)self.detailViewController;
    SFMPageMasterViewController *masterViewController = (SFMPageMasterViewController*)self.masterViewController;
    SFProcessModel *sfProcess = self.sfmPageView.sfmPage.process.processInfo;
    SFMViewPageManager *viewPageManager = [[SFMViewPageManager alloc]initWithObjectName:sfProcess.objectApiName recordId:self.sfmPageView.sfmPage.recordId processSFId:sfProcess.sfID];
    NSError *error = nil;
    if ([viewPageManager isValidProcess:sfProcess.sfID error:&error]) {
        self.sfmPageView = [viewPageManager sfmPageView];
        if ([detailViewController respondsToSelector:@selector(refreshSFmPageData:)]) {
            [detailViewController refreshSFmPageData:self.sfmPageView];
        }
        masterViewController.sfmPageView = self.sfmPageView;       
    }
    else{
        SFMViewPageManager *viewPageManager = [[SFMViewPageManager alloc]initWithObjectName:sfProcess.objectApiName recordId:self.sfmPageView.sfmPage.recordId];
        self.sfmPageView = [viewPageManager sfmPageView];
        masterViewController.sfmPageView = self.sfmPageView;
        [masterViewController resetData];
    }
    [self updateWizardData];
    [self setUpActionSideBar];
    [self setTitleAndImageForTitleView];
}

-(NSString *)getProductNameFromSFmPage
{
    NSString *productname = @"";
    SFMRecordFieldData *recordData = [self.sfmPageView.sfmPage.headerRecord objectForKey:kProductField];
    if (recordData != nil) {
        productname = recordData.displayValue;
    }
    return productname;
    
}
-(NSString *)getProductIdFromSFmPage
{
    NSString *productId = @"";
    SFMRecordFieldData *recordData = [self.sfmPageView.sfmPage.headerRecord objectForKey:kProductField];
    if (recordData != nil) {
        productId = recordData.internalValue;
    }
    return productId;
    
}

#pragma mark - sync notification

- (void)dataSyncFinished
{
    [self refreshPageData];
    if (self.mySideBar.hasShownSideBar) {
        [self.tempViewController reloadTableView];
    }
   // [self.mySideBar showInViewController:self animated:YES];
}

- (void)configSyncFinished:(NSNotification*)notification
{
    SyncProgressDetailModel *syncProgressDetailModel = [[notification userInfo]objectForKey:@"syncstatus"];
    SyncStatus status = syncProgressDetailModel.syncStatus;
    if (status == SyncStatusSuccess) {
        [self refreshPageData];
        if (self.mySideBar.hasShownSideBar) {
            [self.tempViewController reloadTableView];
        }
    }
}
#pragma mark end



#pragma mark - edit delegate

- (void)loadSFMViewPageLayoutForRecordId:(NSString *)recordId andObjectName:(NSString *)objectName
{
    SFMPageViewController *pageViewController = [[SFMPageViewController alloc] init];
    SFMViewPageManager *pageManager = [[SFMViewPageManager alloc] initWithObjectName:objectName recordId:recordId];
    if (recordId) {
        pageManager.recordId = recordId;
    }
    NSError *error = nil;
    BOOL isValidProcess = [pageManager isValidProcess:pageManager.processId error:&error];
    if (isValidProcess) {
        pageViewController.sfmPageView = [pageManager sfmPageView];
        [self.navigationController pushViewController:pageViewController animated:YES];
    }
    else
    {
        if (error) {
            AlertMessageHandler *alertHandler = [AlertMessageHandler sharedInstance];
            NSString * button = [[TagManager sharedInstance] tagByName:kTagAlertErrorOk];
            
            [alertHandler showCustomMessage:[error localizedDescription] withDelegate:nil title:[[TagManager sharedInstance] tagByName:kTagAlertIpadError] cancelButtonTitle:nil andOtherButtonTitles:[[NSArray alloc] initWithObjects:button, nil]];
        }
    }

}

#pragma mark - Linked Process
- (void)invokeLinkedSFMEDitProcess:(LinkedProcess *)process
{
    PageEditViewController *editViewController = nil;
    if ([process.processType isEqualToString:kProcessTypeStandAloneEdit]) {
        
        editViewController = [[PageEditViewController alloc] initWithProcessId:process.processId withObjectName:process.objectName andRecordId:process.recordId];
    }
    else if ([process.processType isEqualToString:kProcessTypeSRCToTargetAll]) {
        
        editViewController = [[PageEditViewController alloc] initWithProcessId:process.processId sourceObjectName:process.objectName andSourceRecordId:process.recordId];
    }
    else if ([process.processType isEqualToString:kProcessTypeStandAloneCreate]) {
        
        editViewController = [[PageEditViewController alloc] initWithProcessId:process.processId andObjectName:nil];
    }
    else if ([process.processType isEqualToString:kProcessTypeSRCToTargetChild]) {
        
        editViewController = [[PageEditViewController alloc] initWithProcessIdForSTC:process.processId withObjectName:process.objectName andRecordId:process.recordId];
    }
    
    if (editViewController != nil) {
        editViewController.editViewControllerDelegate = self;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:editViewController];
        [self.navigationController presentViewController:navigationController animated:YES completion:^{}];
    }
}

- (void)loadLinkedSFMViewProcess:(NSString *)recordId andObjectName:(NSString *)objectName
{
    if (![self.sfmPageView.sfmPage.objectName isEqualToString:objectName]) {
        [self loadSFMViewPageLayoutForRecordId:recordId andObjectName:objectName];
    }
}

- (BOOL)isEntrtCriteriaMatchesForProcessId:(LinkedProcess *)process
{
    SFMViewPageManager *viewPageManager = [[SFMViewPageManager alloc]initWithObjectName:process.objectName recordId:process.recordId processSFId:process.processId];
    
    NSError *error;
    
    BOOL isValidProcess = [viewPageManager isValidProcess:process.processId error:&error];
    
    if (!isValidProcess) {
        if (error) {
            AlertMessageHandler *alertHandler = [AlertMessageHandler sharedInstance];
            NSString * button = [[TagManager sharedInstance] tagByName:kTagAlertErrorOk];
            
            [alertHandler showCustomMessage:[error localizedDescription] withDelegate:nil title:[[TagManager sharedInstance] tagByName:kTagAlertIpadError] cancelButtonTitle:nil andOtherButtonTitles:[[NSArray alloc] initWithObjects:button, nil]];
        }
    }
    return isValidProcess;
}

#pragma mark - END
/*

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
