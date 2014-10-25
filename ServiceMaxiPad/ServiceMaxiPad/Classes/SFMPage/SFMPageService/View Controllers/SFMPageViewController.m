//
//  SFMPageViewController.m
//  ServiceMaxMobile
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
    
	[self loadWizardData];
    self.mySideBar = [[SMActionSideBarViewController alloc]initWithDirectionFromRight:YES];
    self.mySideBar.sideBarWidth = 320;
    self.mySideBar.delegate = self;
    [self.mySideBar addChildViewController:self.tempViewController];
    self.tempViewController.sideMenu = self.mySideBar;
    [self.mySideBar setContentViewInSideBar:self.tempViewController.view];
    [self.tempViewController willMoveToParentViewController:self.mySideBar];
}

- (void)loadWizardData
{
    SFWizardService *wizardService = [[SFWizardService alloc]init];
    
    SFMWizardComponentService *wizardComponentService = [[SFMWizardComponentService alloc]init];
    
    
    NSMutableArray *allWizards = [wizardService getWizardsForObjcetName:self.sfmPageView.sfmPage.objectName andRecordId:self.sfmPageView.sfmPage.recordId];
    [wizardComponentService getWizardComponentsForWizards:allWizards recordId:self.sfmPageView.sfmPage.recordId];
    
    /*If wizard step is not there for a wizard then it should not be shown in the tableView*/
    SFProcessService *processService = [[SFProcessService alloc]init];
    
    self.tempViewController = [[WizardViewController alloc]initWithNibName:@"WizardViewController" bundle:nil];
    self.tempViewController.delegate = self;
    self.tempViewController.wizardsArray = allWizards;
    self.tempViewController.viewProcessArray = [processService fetchAllViewProcessForObjectName:self.sfmPageView.sfmPage.objectName];
    self.tempViewController.shouldShowTroubleShooting = self.sfmPageView.sfmPage.process.pageLayout.headerLayout.enableTroubleShooting;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.navigationItem.rightBarButtonItem) {
        UIBarButtonItem *rightNavButton = [[UIBarButtonItem alloc]init];
        rightNavButton.title = @"Actions";
        rightNavButton.action = @selector(showMenu:);
        rightNavButton.target = self;
        self.navigationItem.rightBarButtonItems = @[rightNavButton];
    }
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
    
    NSError *error = nil;
    BOOL isValidProcess = [viewPageManager isValidProcess:processId error:&error];
    if (isValidProcess) {
        
        NSString *processType = [viewPageManager getProcessTypeForProcessId:processId];
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


- (void)loadViewControllerForProcessId:(NSString *)processId andProcessType:(NSString *)processType{
    
    PageEditViewController *editViewController = nil;
    if ([processType isEqualToString:kProcessTypeStandAloneEdit]) {
        editViewController = [[PageEditViewController alloc] initWithProcessId:processId withObjectName:self.sfmPageView.sfmPage.objectName andRecordId:self.sfmPageView.sfmPage.recordId];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:editViewController];
        [self.navigationController presentViewController:navigationController animated:YES completion:^{}];
    }
//    else if ([processType isEqualToString:kProcessTypeSRCToTargetAll]) {
//        
//    }
//    else if ([processType isEqualToString:kProcessTypeSRCToTargetChild]) {
//        
//    }

    
}

- (void)loadTroublShootingViewForProduct:(NSString *)productName
{
    TroubleshootingViewController *controller = [[TroubleshootingViewController alloc] init];
    controller.productName = productName;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Work Order" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
   // [self.navigationController presentViewController:navigationController animated:YES completion:^{}];
    [self.navigationController pushViewController:controller animated:YES];
    
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


@end
