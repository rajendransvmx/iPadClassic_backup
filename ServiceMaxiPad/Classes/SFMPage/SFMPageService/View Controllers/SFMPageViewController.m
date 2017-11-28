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
#import "SFMPageViewManager.h"
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
#import "CacheConstants.h"
#import "WebserviceResponseStatus.h"
#import "PushNotificationManager.h"
#import "CalenderHelper.h"
#import "MBProgressHUD.h"
#import "SFMCustomActionHelper.h"
#import "SFMCustomActionWebServiceHelper.h"
#import "SNetworkReachabilityManager.h"
#import "ProductIQHomeViewController.h"
#import "ProductIQManager.h"
#import "MessageHandler.h"
#import "UnzipUtility.h"


@interface SFMPageViewController ()<SMActionSideBarViewControllerDelegate>
@property (nonatomic, strong) SMActionSideBarViewController *mySideBar;
@property (nonatomic, strong) WizardViewController *tempViewController;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, assign) BOOL isOpenTreeviewButtonTapped; //If its true then we have to open productIQ.
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadWizardComponentActionAccordingToNetworkChangeNotification:)
                                                 name:kNetworkConnectionChanged
                                               object:nil];
    
    //add observer for event updation notification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(openProductIQWindowIfLoading) name:KBlockScreenForProductIQ object:nil];
    [self leftBarButtonItemCustomization];
}

-(void)leftBarButtonItemCustomization
{
    UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OPDocBackArrow.png"]];
    
    UILabel *backLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 180, arrow.frame.size.height)];
    backLabel.text = [[TagManager sharedInstance]tagByName:kTagtBackButtonTitle];
    backLabel.font = [UIFont systemFontOfSize:17];
    backLabel.textColor = [UIColor whiteColor];
    backLabel.backgroundColor = [UIColor clearColor];
    backLabel.textAlignment = NSTextAlignmentLeft;
    backLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (arrow.frame.size.width + backLabel.frame.size.width), arrow.frame.size.height)];
    backView.backgroundColor = [UIColor clearColor];
    [backView addSubview:arrow];
    [backView addSubview:backLabel];
    backView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backView)];
    [backView addGestureRecognizer:tap];
    
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:backView];
    self.navigationItem.leftBarButtonItem = barBtn;
}
- (void)backView
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)processNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PushNotificationProcessRequest object:nil];
}

- (void)updateWizardData
{
    SFWizardService *wizardService = [[SFWizardService alloc]init];
    SFMWizardComponentService *wizardComponentService = [[SFMWizardComponentService alloc]init];
    NSMutableArray *allWizards = [wizardService getWizardsForObjcetName:self.sfmPageView.sfmPage.objectName andRecordId:self.sfmPageView.sfmPage.recordId];
    [wizardComponentService getWizardComponentsForWizards:allWizards recordId:self.sfmPageView.sfmPage.recordId];
    
    [self addUpdateDODBtninWizard:allWizards];
    [self addEventAndServicemaxEventProcessWizard:allWizards];
    /*If wizard step is not there for a wizard then it should not be shown in the tableView*/
    
    //show or hide ProductIQ
    
    if ([[ProductIQManager sharedInstance] isProductIQSettingEnable]) {
        
        //Disable create or edit process of IB or location objects.
        allWizards = [[ProductIQManager sharedInstance] disableCreateOrEditProcessOfLocationOrIBForAllWizardArray:allWizards withWizardComponetService:wizardComponentService];
        
        if ([[ProductIQManager sharedInstance] isProductIQEnabledForSFMPage:self.sfmPageView]) {
            allWizards = [[ProductIQManager sharedInstance] addProductIQWizardForAllWizardArray:allWizards withWizardComponetService:wizardComponentService];
        }
    }
    
    
    SFProcessService *processService = [[SFProcessService alloc]init];
    
    if (self.tempViewController == nil) {
        self.tempViewController = [[WizardViewController alloc]initWithNibName:@"WizardViewController" bundle:nil];
    }
    self.tempViewController.delegate = self;
    self.tempViewController.wizardsArray = allWizards;
    self.tempViewController.viewProcessArray = [processService fetchAllViewProcessForObjectName:self.sfmPageView.sfmPage.objectName];
    self.tempViewController.shouldShowTroubleShooting = self.sfmPageView.sfmPage.process.pageLayout.headerLayout.enableTroubleShooting;
    [self.tempViewController reloadTableView];
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
    if (isOnlineRecordExist && self.invokedFromSearch)
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

-(void)addEventAndServicemaxEventProcessWizard:(NSMutableArray *)addEventWizard{
    NSString *eventType = [CalenderHelper getEventTypeFromMobileDeviceSettings];
    if ([eventType isEqualToString:kSalesforceEvent]) {
        [self addEventWizard:addEventWizard targetObject:kEventObject];
    }else {
    [self addEventWizard:addEventWizard targetObject:kServicemaxEventObject];
    }
}

-(void)addEventWizard:(NSMutableArray *)addEventWizard  targetObject:(NSString *)targetObjectName
{
    if( self.invokedFromSearch  && [self.sfmPageView.sfmPage.objectName stringContains:@"Service_Order__c"])
    {
        SFWizardModel * wizrd = [[SFWizardModel alloc] init];
        wizrd.wizardName = [[TagManager sharedInstance]tagByName:kTag_CreateEvent];
        
        
        NSArray *s2tprocess = [self getS2tProcessForTargetObjectName:targetObjectName];
        
        
        NSMutableArray * removeableWizard = nil;

        /* delete existing events process From the Wizard array */
        for (SFProcessModel * processModel  in s2tprocess) {
            
            for (SFWizardModel * subWizard in addEventWizard) {
                
                NSMutableArray * removeableReferences = nil;
                
                for (WizardComponentModel * compModel in  subWizard.wizardComponents) {
                    
                    if([compModel.processId isEqualToString:processModel.sfID]){
                        if(removeableReferences == nil){
                            removeableReferences = [NSMutableArray array];
                        }
                        [removeableReferences addObject:compModel];
                    }
                }
                
                for (WizardComponentModel * removeModel in removeableReferences) {
                    [subWizard.wizardComponents removeObject:removeModel];
                }
                
                if([subWizard.wizardComponents count] == 0){
                    if(removeableWizard == nil){
                        removeableWizard  = [NSMutableArray array];
                    }
                    [removeableWizard addObject:subWizard];
                }
            }
        }
        
        for (SFWizardModel * subWizard  in removeableWizard) {
            [addEventWizard removeObject:subWizard];
        }
        
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

-(NSArray *)getS2tProcessForTargetObjectName:(NSString *)targetObjectName
{
    id <SFProcessDAO> processTypeService = [FactoryDAO serviceByServiceType:ServiceTypeProcess];
    NSArray  *s2tProcess = [processTypeService getS2TEventProcessForObject:self.sfmPageView.sfmPage.objectName targetObjectNAme:targetObjectName];
    return s2tProcess;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  //  fix for defect 018448 - chinna;
    [self refreshPageData];

    if (self.tempViewController)
    {
        [self.tempViewController reloadTableView];
    }
    if ([ProductIQManager sharedInstance].isRecordDeleted == YES) { //deleted record from productIQ.Hence navigate to root view (024507).
        //reset it again to NO.
        [ProductIQManager sharedInstance].isRecordDeleted = NO;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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


       //HS 5 Jan ends here
    
    [self addNotificationObserver];
    [self processNotification];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeNotificationObserver];
}

- (void) addNotificationObserver{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSyncFinished) name:kUpadteWebserviceData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSyncFinished) name:kDataSyncStatusNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configSyncFinished:) name:kConfigSyncStatusNotification object:nil];
}

- (void) removeNotificationObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpadteWebserviceData object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDataSyncStatusNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kConfigSyncStatusNotification object:nil];
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
    
    CGSize navButtonSixe = [StringUtil getSizeOfText:[[TagManager sharedInstance] tagByName:kTagActions] withFont:font];

    CGFloat textWidth = self.navigationController.view.frame.size.width;
    textWidth -= ((navButtonSixe.width *2) + 200);
    
    
    SMNavigationTitleView *titleView = [[SMNavigationTitleView alloc]initWithFrame:CGRectZero];
    titleView.isTitleImagePresent = self.sfmPageView.isConflictPresent;
    
    if (sizeOfText.width < textWidth) {
        textWidth = sizeOfText.width;
    }
    
    titleView.titleWidth = textWidth;
    
    if (titleView.isTitleImagePresent) {
        titleView.titleImageView.image = [UIImage imageNamed:@"Sync_Error_White"];
        titleView.frame = CGRectMake(0, 0,textWidth+50,45);
    } else {
        titleView.frame = CGRectMake(0, 0,textWidth,45);
    }
    titleView.titleLabel.text = titleValue;
        titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
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
    SFMPageViewManager *viewPageManager = [[SFMPageViewManager alloc]initWithObjectName:sfProcess.objectApiName recordId:self.sfmPageView.sfmPage.recordId processSFId:sfProcess.sfID];
    
    NSError *error = nil;
        BOOL isValidProcess = [viewPageManager isValidProcess:viewPageManager.processId objectName:nil recordId:nil error:&error];
    if (isValidProcess) {
        self.sfmPageView.sfmPage = [viewPageManager sfmPage];
        SFMPageMasterViewController *tempMasterViewController = (SFMPageMasterViewController*)self.masterViewController;
        tempMasterViewController.sfmPageView = self.sfmPageView;
        [tempMasterViewController resetData];
        self.tempViewController.shouldShowTroubleShooting = self.sfmPageView.sfmPage.process.pageLayout.headerLayout.enableTroubleShooting;
//        [self.tempViewController.tableView reloadData];
        [self refreshPageData];
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
    
    SFMPageViewManager *viewPageManager = [[SFMPageViewManager alloc]initWithObjectName:self.sfmPageView.sfmPage.objectName recordId:self.sfmPageView.sfmPage.recordId processSFId:processId];
    
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
         BOOL isValidProcess = [viewPageManager isValidProcess:processId objectName:nil recordId:nil error:&error];
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
    //refresh the action menu item.
//    [self refreshPageData];
//    [self.tempViewController.tableView reloadData];
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

#pragma mark -
#pragma mark ProductIQ

-(void)displayProductIQViewController;
{
    /*
     ProductIQHomeViewController *lProductIQcontroller = [[ProductIQHomeViewController alloc] initWithNibName:@"ProductIQHomeViewController" bundle:nil];
     UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:lProductIQcontroller];
     navController.delegate = lProductIQcontroller;
     navController.modalPresentationStyle = UIModalPresentationFullScreen;
     navController.navigationBar.hidden = NO;
     navController.navigationBar.barTintColor = [UIColor getUIColorFromHexValue:@"#FF6633"];
     navController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
     [self.navigationController presentViewController:navController animated:YES completion:nil];
     */
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    }
    
    /* Here checking for file zipping and unzipping, if its unzipping then show load window */
    if(![UnzipUtility isFileIsUnZipping]){
        self.isOpenTreeviewButtonTapped = NO;
        [self openProductIQWindow];
    }else{
        self.isOpenTreeviewButtonTapped = YES;
        [self addActivityAndLoadingLabel];
    }
    
}

/* If productIQ button is tapped, then open PIQ */
-(void)openProductIQWindowIfLoading{
    if(self.isOpenTreeviewButtonTapped){
        [self openProductIQWindow];
        self.isOpenTreeviewButtonTapped = NO;
    }
    [self removeActivityAndLoadingLabel];
}

/* opening productIQ from here */
-(void)openProductIQWindow{
    ProductIQHomeViewController *lProductIQcontroller = [[ProductIQHomeViewController alloc] initWithNibName:@"ProductIQHomeViewController" bundle:nil];
    lProductIQcontroller.responseDictionary = [MessageHandler getMessageHandlerResponeDictionaryForSFMPage:self.sfmPageView];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:lProductIQcontroller];
    navController.delegate = lProductIQcontroller;
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    navController.navigationBar.hidden = NO;
    navController.navigationBar.barTintColor = [UIColor getUIColorFromHexValue:@"#FF6633"];
    navController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Flow Delegate methods
- (void)flowStatus:(id)status {
    
    [[CacheManager sharedInstance] clearCacheByKey:kCustomWebServiceAction];
    [self removeActivityAndLoadingLabel];
    if([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *st = (WebserviceResponseStatus*)status;
        switch (st.category)
        {
            case CategoryTypeDOD:
            {
                if  (st.syncStatus == SyncStatusSuccess)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self refreshPageData];
                        if (self.mySideBar.hasShownSideBar) {
                            [self.tempViewController reloadTableView];
                        }
                    });
                    
                }
                else if (st.syncStatus == SyncStatusFailed)
                {

                }
                else if (st.syncStatus == SyncStatusInCancelled)
                {

                }
                break;
            }
            case CategoryTypeCustomWebServiceCall:
            {
                if  (st.syncStatus == SyncStatusSuccess
                     || st.syncStatus == SyncStatusInProgress) {
                    
                }
                else if (st.syncStatus == SyncStatusFailed) {
                    [self requestFialedWithError:st.syncError shouldShow:YES];
                }
                else if (st.syncStatus == SyncStatusNetworkError
                         || st.syncStatus == SyncStatusRefreshTokenFailedWithError) {
                    [self requestFialedWithError:st.syncError shouldShow:YES];
                }
                
                else if (st.syncStatus == SyncStatusInCancelled) {
                    
                }
            }
                break;
            default:
                break;
        }
    }
}

- (void)requestFialedWithError:(NSError *)error shouldShow:(BOOL)shouldShow
{
    if (shouldShow) {
        [self performSelectorOnMainThread:@selector(showAlert:) withObject:error waitUntilDone:NO];
    }
    else {
        if ([error actionCategory] == SMErrorActionCategoryAuthenticationReopenSession) {
            [self performSelectorOnMainThread:@selector(showAlert:) withObject:error waitUntilDone:NO];
        } else if ([[error errorEndUserMessage] custContainsString:@"request timed out"]) {
            [self performSelectorOnMainThread:@selector(showAlert:) withObject:error waitUntilDone:NO];
        }
    }
}

- (void)showAlert:(NSError *)error
{
    if (error ) {
        [[AlertMessageHandler sharedInstance] showCustomMessage:[error errorEndUserMessage]
                                                   withDelegate:nil
                                                            tag:0
                                                          title:[[TagManager sharedInstance] tagByName:kTagSyncErrorMessage]
                                              cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]
                                           andOtherButtonTitles:nil];
    }
}

#pragma mark - Flow Delegate methods ends here

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
    navController.navigationBar.barTintColor = [UIColor getUIColorFromHexValue:@"#FF6633"];
    navController.navigationBar.tintColor = [UIColor whiteColor];
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
    
    /* defect:020264, TroubleshootingViewController VC will add the custom back button */
   // UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:[[TagManager sharedInstance]tagByName:kTag_WorkOrder] style:UIBarButtonItemStyleBordered target:nil action:nil];
    //self.navigationItem.backBarButtonItem = backButton;
    
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)refreshPageData
{
    SFMPageDetailViewController *detailViewController = (SFMPageDetailViewController*)self.detailViewController;
    SFMPageMasterViewController *masterViewController = (SFMPageMasterViewController*)self.masterViewController;
    SFProcessModel *sfProcess = self.sfmPageView.sfmPage.process.processInfo;
    SFMPageViewManager *viewPageManager = [[SFMPageViewManager alloc]initWithObjectName:sfProcess.objectApiName recordId:self.sfmPageView.sfmPage.recordId processSFId:sfProcess.sfID];
    NSError *error = nil;
    if ([viewPageManager isValidProcess:sfProcess.sfID objectName:nil recordId:nil error:&error]) {
        self.sfmPageView = [viewPageManager sfmPageView];
        if ([detailViewController respondsToSelector:@selector(refreshSFmPageData:)]) {
            [detailViewController refreshSFmPageData:self.sfmPageView];
        }
        masterViewController.sfmPageView = self.sfmPageView;       
    }
    else{
        SFMPageViewManager *viewPageManager = [[SFMPageViewManager alloc]initWithObjectName:sfProcess.objectApiName recordId:self.sfmPageView.sfmPage.recordId];
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
    
    // IPAD-4505
    if(self.tempViewController != nil) {
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
    SFMPageViewManager *pageManager = [[SFMPageViewManager alloc] initWithObjectName:objectName recordId:recordId];
    if (recordId) {
        pageManager.recordId = recordId;
    }
    NSError *error = nil;
    BOOL isValidProcess = [pageManager isValidProcess:pageManager.processId objectName:nil recordId:nil error:&error];
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
    SFMPageViewManager *viewPageManager = [[SFMPageViewManager alloc]initWithObjectName:process.objectName recordId:process.recordId processSFId:process.processId];
    
    NSError *error;
    
    BOOL isValidProcess = [viewPageManager isValidProcess:process.processId objectName:nil recordId:nil error:&error];
    
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

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   //[self refreshPageData];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
 
    [self setTitleAndImageForTitleView];
}

/* Load url from with parameters */
-(void)makeCustomUrlCall:(WizardComponentModel *)model
{
    /* load url with params */
    SFMCustomActionHelper *customActionHelper = [[SFMCustomActionHelper alloc] initWithSFMPage:self.sfmPageView.sfmPage wizardComponent:model];
    UIApplication *ourApplication = [UIApplication sharedApplication];
    NSString *string = [customActionHelper loadURL];//[self removeSpaceFromUrl:[customActionHelper loadURL]];
    string =[string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *ourURL = [NSURL URLWithString:string];
    if ([ourApplication canOpenURL:ourURL])
    {
        [ourApplication openURL:ourURL];
    }
    else
    {
        /* This check for, If url starting with http then invoke url if not then attach http:// then try to launch */
        if ([string hasPrefix:@"http"])
        {
            [ourApplication openURL:ourURL];
        }
        else
        {
            string = [NSString stringWithFormat:@"http://%@",string];
            [ourApplication openURL:[NSURL URLWithString:string]];
        }
    }
}

/* Call webservice call from with parameters */
-(void)makeWebserviceCall:(WizardComponentModel *)model
{
    SFMCustomActionWebServiceHelper *webserviceHelper=[[SFMCustomActionWebServiceHelper alloc] initWithSFMPage:self.sfmPageView.sfmPage wizardComponent:model];
    [self addActivityAndLoadingLabel];
    [webserviceHelper performSelectorInBackground:@selector(initiateCustomWebServiceWithDelegate:) withObject:self];
}

-(void)showWrongURLAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Custom Action"
                                                    message:@"Invalid URL"
                                                   delegate:nil
                                          cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark Activity Management

- (void)addActivityAndLoadingLabel
{
    if (!self.HUD) {
        self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.HUD];
        // Set determinate mode
        self.HUD.mode = MBProgressHUDModeIndeterminate;
        self.HUD.labelText = [[TagManager sharedInstance]tagByName:kTagLoading];
        [self.HUD show:YES];
    }
}

- (void)removeActivityAndLoadingLabel
{
    if (self.HUD) {
        [self.HUD hide:YES];
        self.HUD = nil;
    }
}

-(void)reloadWizardComponentActionAccordingToNetworkChangeNotification:(NSNotification *)notification{
    [self removeActivityAndLoadingLabel];
    if (self.tempViewController != nil) {
        [self.tempViewController reloadTableView];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNetworkConnectionChanged
                                                  object:nil];
}
@end
