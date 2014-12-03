//
//  PageEditViewController.m
//  ServiceMaxMobile
//
//  Created by shravya on 29/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "PageEditViewController.h"
#import "PageEditDetailViewController.h"
#import "PageEditMasterViewController.h"
#import "DatabaseConstant.h"
#import "StringUtil.h"
#import "StyleGuideConstants.h"
#import "SMNavigationTitleView.h"
#import "StyleManager.h"
#import "SFMHeaderLayout.h"
#import "SFPageButton.h"
#import "TagManager.h"
#import "SFMHeaderSection.h"
#import "SFMPageField.h"
#import "SFMRecordFieldData.h"
#import "AlertMessageHandler.h"
#import "SyncManager.h"
#import "SNetworkReachabilityManager.h"
#import "PlistManager.h"
#import "BusinessRuleResult.h"
#import "AttachmentHelper.h"
#import "AttachmentsUploadManager.h"
#import "ChildEditViewController.h"

@interface PageEditViewController ()

@property(nonatomic,strong)SFMPageEditManager   *sfmEditPageManager;
@property(nonatomic,strong)SFMPage              *sfmPage;
@property(nonatomic,strong)UIActivityIndicatorView *activityIndicator;
@property(nonatomic,strong)NSString             *processType;
@property(nonatomic,strong)NSString             *processId;
@property(nonatomic,strong)PriceCalculationManager *priceCalculationManager;
@property(nonatomic,strong)NSString                 *getPriceButtonText;
@property(nonatomic, strong) BusinessRuleManager *ruleManager;
@property(nonatomic, assign) BOOL isLinkedSfmProcess;
@property(nonatomic, strong) LinkedProcess *linkedSfmProcess;
@property(nonatomic, strong) NSIndexPath *requiredFieldIndexPath;
@property(nonatomic, assign) BOOL isHeader;
@end

@implementation PageEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithProcessId:(NSString *)processId
         withObjectName:(NSString *)objectName
           andRecordId:(NSString *)recordId {
    
    self = [super initWithNibName:@"PageEditViewController"  bundle:nil];
    if (self) {
        // Custom initialization
        
        SFMPage *aPage = [[SFMPage  alloc] initWithObjectName:objectName andRecordId:recordId];
        self.sfmPage = aPage;
        self.processId = processId;
        self.processType =  kProcessTypeStandAloneEdit;
        
    }
    return self;
}

- (id)initWithProcessId:(NSString *)processId
       sourceObjectName:(NSString *)srcObjName
      andSourceRecordId:(NSString *)srcRecordId
{
    
    if (self = [super init]) {
        SFMPage *sfmPage = [[SFMPage alloc] initWithSourceObjectName:srcObjName andSourceRecordId:srcRecordId];
        self.sfmPage = sfmPage;
        self.processId = processId;
        self.processType = kProcessTypeSRCToTargetAll;
    }
    return self;
}

- (id)initWithProcessId:(NSString *)processId
          andObjectName:(NSString *)objectName {
    self = [super initWithNibName:@"PageEditViewController"  bundle:nil];
    if (self) {

        SFMPage *aPage = [[SFMPage  alloc] initWithObjectName:objectName andRecordId:nil];
        self.sfmPage = aPage;
        self.processId = processId;
        self.processType =  kProcessTypeStandAloneCreate;

    }
    return self;
}


- (id)initWithProcessIdForSTC:(NSString *)processId
               withObjectName:(NSString *)objectName
                  andRecordId:(NSString *)recordId
{
    self = [super initWithNibName:@"PageEditViewController"  bundle:nil];
    if (self) {
        // Custom initialization
        
        SFMPage *aPage = [[SFMPage  alloc] initWithObjectName:objectName andRecordId:recordId];
        self.sfmPage = aPage;
        self.processId = processId;
        self.processType =  kProcessTypeSRCToTargetChild;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self loadChildViewControllers];
    [self loadData];
    [self setUpNavigationBarButtonItems];
    [self invalidateLinkedSfm];
}

- (void)viewDidAppear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -View Set up
- (void)setNavigationPropertiesAndButtons
{
    NSString *titleValue = self.sfmPage.process.processInfo.processName;
    
    NSInteger maximumCharInTitle = 48 - [self getAllRightBarButtonTitleTotalLength];
    if ([titleValue length] > maximumCharInTitle)
    {
        titleValue = [titleValue substringToIndex:maximumCharInTitle];
        titleValue = [titleValue stringByAppendingString:@".."];
    }
    self.navigationItem.titleView = [UILabel navBarTitleLabel:titleValue];
}


#pragma mark - Loading child view Controllers 
- (void)loadChildViewControllers {
    
    PageEditMasterViewController *masterViewController = [[PageEditMasterViewController alloc] initWithNibName:@"PageEditMasterViewController" bundle:nil];
    masterViewController.containerViewControlerDelegate = self;
    self.navigationController.navigationBar.barTintColor = [UIColor navBarBG]; //Only for iOS7.0 and more than 7.0
    self.navigationController.navigationBar.translucent = NO;

    
    PageEditDetailViewController *detailViewController = [[PageEditDetailViewController alloc] initWithNibName:@"PageEditDetailViewController" bundle:nil];
    [detailViewController.navigationController setNavigationBarHidden:YES];
    detailViewController.containerViewControlerDelegate = self;
    self.viewControllers = @[masterViewController, detailViewController];
    self.delegate = detailViewController;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[[TagManager sharedInstance]tagByName:kTagCancelButton] style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonClicked:)];
    [self setTextAttributesForBarButtonItem:self.navigationItem.leftBarButtonItem];
}


#pragma mark End


#pragma mark - Loading Data

- (void)loadData {
    /* Start activity indicator */
    
    /*Create page edit manager*/
    SFMPageEditManager *editManager = [[SFMPageEditManager alloc] initWithObjectName:self.sfmPage.objectName recordId:self.sfmPage.recordId processSFId:self.processId];
    self.sfmEditPageManager = editManager;
    
    /*Pass all the information to page manager and let it fill up sfpage*/
    [self.sfmEditPageManager fillSfmPage:self.sfmPage andProcessType:self.processType];
    
    /*Reload both master and child data*/
    [self performSelectorOnMainThread:@selector(refreshAllViews) withObject:nil waitUntilDone:NO];
    
    /* Stop activity indicator */
    
}

#pragma mark End

- (void)cancelButtonClicked:(id)sender
{
    if (self.sfmPage.process.pageLayout.headerLayout.enableAttachment) {
        [AttachmentHelper revertImagesAndVideosForUpload];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Refresh views

- (void)refreshAllViews {
     [self setNavigationPropertiesAndButtons];
     [self refreshMasterAndDetailViews:NO];
}
- (void)refreshMasterAndDetailViews:(BOOL)isDetailOnly {
    if ([self.childViewControllers count] < 2) {
        return;
    }
    
   if (!isDetailOnly) {
        PageEditMasterViewController *masterViewController = [self.childViewControllers objectAtIndex:0];
        masterViewController.sfmPage = self.sfmPage;
        if ([masterViewController conformsToProtocol:@protocol(PageEditViewControllerDelegate)]) {
            [masterViewController reloadData];
        }
       
    }
//    PageEditDetailViewController *detailViewController = [self.childViewControllers objectAtIndex:1];
//    detailViewController.sfmPage = self.sfmPage;
//    if ([detailViewController conformsToProtocol:@protocol(PageEditViewControllerDelegate)]) {
//        [detailViewController reloadData];
//    }
   
}

#pragma mark End

#pragma mark - private methods

- (void)setUpNavigationBarButtonItems
{
    SFMHeaderLayout *headeLayout = self.sfmPage.process.pageLayout.headerLayout;
    NSMutableArray *righBarButtonItems = [[NSMutableArray alloc]init];
    if (!headeLayout.hideSave) {

        [self addSaveButtonToRightBarButtonItems:righBarButtonItems];
    }
    
    [self addOtherButtonsToRightBarButtonItems:righBarButtonItems];
    if (!self.navigationItem.rightBarButtonItem) {
        self.navigationItem.rightBarButtonItems = righBarButtonItems;
    }
}

- (NSInteger)getNumberOfButtons
{
    SFMHeaderLayout *headeLayout = self.sfmPage.process.pageLayout.headerLayout;
    
    //set number of button to 3
    int numberOfButton = 3;
    
    //if save button present set number of buttons to 2
    if (!(headeLayout.hideSave)) {
        numberOfButton = 2;
    }
    //if buttons count in headelayout is less than 2 set number of buttons
    
    if ([headeLayout.buttons count] < 2) {
        numberOfButton = [headeLayout.buttons count];
    }
    return numberOfButton;
}

- (NSInteger)getAllRightBarButtonTitleTotalLength
{
    SFMHeaderLayout *headeLayout = self.sfmPage.process.pageLayout.headerLayout;
    int maximumCharLimit = 28;
    if (!headeLayout.hideSave) {
        maximumCharLimit = 28 - [[TagManager sharedInstance]tagByName:kTagSfmActionButtonSave].length;
    }
    
    //Find out total length of all the button title
    NSInteger buttonTitleLength = 0;
    for (int i = 0; i < [self getNumberOfButtons]; i++) {
        SFPageButton *pageButton = [headeLayout.buttons objectAtIndex:i];
        buttonTitleLength += [pageButton.title length];
    }
    
    if (buttonTitleLength > maximumCharLimit) {
        buttonTitleLength = maximumCharLimit;
    }
    return buttonTitleLength;
}

- (void)addSaveButtonToRightBarButtonItems:(NSMutableArray*)rightBarButtonItems
{
    //include save button
    UIBarButtonItem *rightNavButton = [[UIBarButtonItem alloc] init];
    rightNavButton.title = [[TagManager sharedInstance]tagByName:kTagSfmActionButtonSave];
    rightNavButton.target = self;
    rightNavButton.action = @selector(saveButtonTapped:);
    [self setTextAttributesForBarButtonItem:rightNavButton];
    [rightBarButtonItems addObject:rightNavButton];
    
    //adding space
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedItem.width = 20.0;
    [rightBarButtonItems addObject:fixedItem];
}

- (void)addOtherButtonsToRightBarButtonItems:(NSMutableArray*)rightBarButtonItems
{
    SFMHeaderLayout *headeLayout = self.sfmPage.process.pageLayout.headerLayout;

    for (int i = 0 ; i < [self getNumberOfButtons]; i++) {
        
        SFPageButton * pageButton = [headeLayout.buttons objectAtIndex:i];
        UIBarButtonItem *rightNavButton = [[UIBarButtonItem alloc] init];
        rightNavButton.title = pageButton.title;
        if ([pageButton.title length] > [self getMaximumCharacterInEachButton])
        {
            rightNavButton.title = [pageButton.title substringToIndex:[self getMaximumCharacterInEachButton] - 2];
            rightNavButton.title = [rightNavButton.title stringByAppendingString:@".."];
        }
        rightNavButton.target = self;
        rightNavButton.action = @selector(barButtonTapped:);
        rightNavButton.tag = i;
        [self setTextAttributesForBarButtonItem:rightNavButton];
        [rightBarButtonItems addObject:rightNavButton];
        
        //adding space betwwen buttons
        UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixedItem.width = 20.0;
        [rightBarButtonItems addObject:fixedItem];
    }
}

- (NSInteger)getMaximumCharacterInEachButton
{
    NSInteger maximumCharInEachButton = 0;
    
    if ([self getAllRightBarButtonTitleTotalLength] != 0) {
        maximumCharInEachButton = [self getAllRightBarButtonTitleTotalLength] / [self getNumberOfButtons];
    }
    return maximumCharInEachButton;
}

- (void)setTextAttributesForBarButtonItem:(UIBarButtonItem*)barButtonItem
{
    [barButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIColor whiteColor],NSForegroundColorAttributeName,
                                           [UIFont fontWithName:kHelveticaNeueLight size:kFontSize16], NSFontAttributeName, nil] forState:UIControlStateNormal];
}

#pragma mark - button action

- (void)saveButtonTapped:(id)sender
{
    [self invalidateLinkedSfm];
    if ([self.sfmPage isAttachmentEnabled]) {
        [[AttachmentsUploadManager sharedManager] startAttachmentFileUploadProcess];
    }
    [self refreshBizRule];
    
    [self disableUI];
    [self updateRespondersIfAny];
    [self performSelectorOnMainThread:@selector(showActivityIndicator) withObject:nil waitUntilDone:YES];
    /* Show activity indicator */
    
    [self executeBusinessRules];

    //[self performSelectorInBackground:@selector(saveRecord) withObject:nil];
}

- (void)barButtonTapped:(id)sender
{
    SFMHeaderLayout *headeLayout = self.sfmPage.process.pageLayout.headerLayout;
    SFPageButton * pageButton = [headeLayout.buttons objectAtIndex:((UIBarButtonItem*)sender).tag];
    [self updateRespondersIfAny];
    if ([pageButton.eventCallBackType isEqualToString:SFPageButtonTypeJavascript]) {
        self.getPriceButtonText = pageButton.title;
        [self performSelector:@selector(calculatePrice) withObject:nil afterDelay:0.01];
    }
    
    NSLog(@"%@",pageButton.title);
}
#pragma mark -End

#pragma mark - Save actions
- (void)saveRecord {
    @synchronized([self class]){
        
        /* Check field level validation */
        if ([self validatePageData]) {
            
            [self.sfmEditPageManager saveHeaderRecord:self.sfmPage];
            
            [self.sfmEditPageManager saveDetailRecords:self.sfmPage];
            
            
            if([self isSourceToTargetProcess] || [self isSourceToTargetChildOnlyProcess]){
                [self.sfmEditPageManager performSourceUpdate:self.sfmPage];
            }
            
            if ( [[SNetworkReachabilityManager sharedInstance] isNetworkReachable]){
                [[SyncManager sharedInstance] performSyncWithType:SyncTypeData];
            }
            
            [self performSelectorOnMainThread:@selector(dismissUI) withObject:self waitUntilDone:NO];
            
        } else {
            [self performSelectorOnMainThread:@selector(showAlert) withObject:self waitUntilDone:NO];
        }
        [self performSelectorOnMainThread:@selector(enableUI) withObject:self waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(stopActivityIndicator) withObject:nil waitUntilDone:YES];
    }
}

#pragma mark End

#pragma mark -
#pragma mark Activity Indicator methods
- (void)showActivityIndicator
{
    if (self.activityIndicator == nil) {
        self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator.backgroundColor = [UIColor clearColor];
        self.activityIndicator.color = [UIColor blackColor];
        [self.detailViewController.view addSubview:self.activityIndicator];
    }
    self.activityIndicator.center = CGPointMake(CGRectGetMidX(self.detailViewController.view.bounds), CGRectGetMidY(self.detailViewController.view.bounds));
    
    [self.activityIndicator startAnimating];
    
}

- (void)stopActivityIndicator
{
    if ([self.activityIndicator isAnimating]) {
        [self.activityIndicator stopAnimating];
    }
}

#pragma mark - Handling UI

-(void)enableUI
{
    self.view.window.userInteractionEnabled = YES;
}

-(void)disableUI
{
    self.view.window.userInteractionEnabled = NO;
}

-(void)dismissUI
{
    [self enableUI];
    if ([self isSourceToTargetProcess] || [self isStandAloneCreateProcess] ) {
        [self dismissViewControllerAnimated:NO completion:nil];
        if ([self.editViewControllerDelegate respondsToSelector:@selector(loadSFMViewPageLayoutForRecordId:andObjectName:)]) {
            [self.editViewControllerDelegate loadSFMViewPageLayoutForRecordId:self.sfmPage.recordId andObjectName:self.sfmPage.objectName];
            self.sfmPage = nil;
        }
        if ([self.editViewControllerDelegate respondsToSelector:@selector(refreshEventInCalendarView)]) {
            [self.editViewControllerDelegate refreshEventInCalendarView];
        }
    }
    else if ([self isEditProcess] || [self isSourceToTargetChildOnlyProcess]) {
        [self dismissViewControllerAnimated:NO completion:nil];
        if ([self.editViewControllerDelegate respondsToSelector:@selector(loadLinkedSFMViewProcess:andObjectName:)]) {
            [self.editViewControllerDelegate loadLinkedSFMViewProcess:self.sfmPage.recordId andObjectName:self.sfmPage.objectName];
        }
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - validate page data

- (BOOL)validatePageData {
    
    BOOL validHeaderRecord = [self fieldValidationForHeaderRecord];
    
    BOOL  validateChildRecord = [self fieldValidationForDetailRecords];
    
    if (validHeaderRecord && validateChildRecord) {
        return YES;
    }
    return NO;
}

-(BOOL)fieldValidationForHeaderRecord
{
    NSArray *headerSections = self.sfmPage.process.pageLayout.headerLayout.sections;
    
    int requiredFieldRow = -1;
    for(  SFMHeaderSection *pageHdrSection in headerSections)
    {
        requiredFieldRow ++;
        for(SFMPageField * pageField in [pageHdrSection sectionFields] )
        {
            if (pageField.isRequired)
            {
                SFMRecordFieldData *recordField = [self.sfmPage.headerRecord objectForKey:pageField.fieldName];
                if (recordField.internalValue ==nil || [recordField.internalValue length] == 0)
                {
                    self.requiredFieldIndexPath = [NSIndexPath indexPathForRow:requiredFieldRow inSection:0];
                    self.isHeader = YES;
                    return NO;
                    
                } else {
                    self.isHeader = NO;
                }
            }
        }
    }
    
    return YES;
}

- (BOOL)fieldValidationForDetailRecords {
    
    NSArray *alldDtailLayouts =   self.sfmPage.process.pageLayout.detailLayouts;
    
    int section = -1;
   
    for (SFMDetailLayout *detailLayout in alldDtailLayouts) {
        
        section++;
        if (detailLayout.processComponentId == nil) {
            continue;
        }
        NSArray *allFields = [detailLayout detailSectionFields];
        NSArray *allRecords = [self.sfmPage.detailsRecord objectForKey:detailLayout.processComponentId];
        if ([allRecords count] > 0) {
            
            for (SFMPageField *pageField in allFields) {
                
                if (pageField.isRequired) {
                    int row = -1;
                    for (NSDictionary *recordDictionary in allRecords) {
                       
                        row++;
                        
                        SFMRecordFieldData *recordField = [recordDictionary objectForKey:pageField.fieldName];
                        if ([StringUtil isStringEmpty:recordField.internalValue]) {
                            if (![recordField.internalValue isKindOfClass:[NSNumber class]]) {
                                if (!self.isHeader) {
                                    self.requiredFieldIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
                                    self.isHeader = NO;
                                }
                                return NO;
                            }
                        }
                        
                        
                    }

                }
            }
        }
        
    }
    
    return YES;
}
#pragma mark - show alert
-(void)showAlert
{
    [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeRequiredFieldWarning andDelegate:self];
}


#pragma mark - checking process type
- (BOOL)isSourceToTargetProcess{ 
    if ([self.sfmPage.process.processInfo.processType isEqualToString:kProcessTypeSRCToTargetAll]){
        return YES;
    }
    return NO;
}


- (BOOL)isStandAloneCreateProcess{
    if ([self.sfmPage.process.processInfo.processType isEqualToString:kProcessTypeStandAloneCreate]){
        return YES;
    }
    return NO;
}

- (BOOL)isSourceToTargetChildOnlyProcess{
    if ([self.sfmPage.process.processInfo.processType isEqualToString:kProcessTypeSRCToTargetChild]){
        return YES;
    }
    return NO;
}

- (BOOL)isEditProcess{
    if ([self.sfmPage.process.processInfo.processType isEqualToString:kProcessTypeStandAloneEdit]){
        return YES;
    }
    return NO;
}


#pragma mark -Get Price calculation creation and delegates

- (void)calculatePrice {
    

    if (![PlistManager canPerformGetPrice]) {
        NSString *message = [[TagManager sharedInstance] tagByName:kTagGetPriceObjectsNotFound];
        [self showPriceAlertView:message];
        return;
    }
    [self disableUI];
    [self performSelectorOnMainThread:@selector(showActivityIndicator) withObject:nil waitUntilDone:YES];
    
    self.priceCalculationManager = [[PriceCalculationManager alloc] initWithCodeSnippetId:@"Standard Get Price" andParentView:self.view];
    self.priceCalculationManager.managerDelegate = self;
    [self.priceCalculationManager beginPriceCalculationForTargetRecord:self.sfmPage];
}
- (void)priceCalculationFinishedSuccessFully:(SFMPage *)sfPage {
    
    [self enableUI];
    [self performSelectorOnMainThread:@selector(stopActivityIndicator) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(reloadDataToFirstSection) withObject:nil waitUntilDone:NO];
}
- (void)shouldShowAlertMessage:(NSString *)message {
    [self enableUI];
    [self performSelectorOnMainThread:@selector(stopActivityIndicator) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(showPriceAlertView:) withObject:message waitUntilDone:NO];
}


- (void)showPriceAlertView:(NSString *)message {

    NSString *buttonText = self.getPriceButtonText;
    NSString *okayText = [[TagManager sharedInstance] tagByName:kTagAlertErrorOk];
    UIAlertView * _alert = [[UIAlertView alloc] initWithTitle:buttonText message:message delegate:nil cancelButtonTitle:okayText otherButtonTitles:nil];
    
    [_alert show];
}

- (void)reloadDataToFirstSection {
     [self refreshMasterAndDetailViews:NO];
}
#pragma mark End


#pragma mark -
- (void)updateRespondersIfAny {
    
    if ([self.childViewControllers count] < 2) {
        return;
    }
    PageEditDetailViewController *detailViewController = [self.childViewControllers objectAtIndex:1];
    if ([detailViewController conformsToProtocol:@protocol(PageEditViewControllerDelegate)]) {
            [detailViewController resignAnyFirstResponders];
    }
}

#pragma mark - Linked SFM -Save Action
- (void)showLinkedSFMProcessForProcessInfo:(LinkedProcess *)process
{
    self.isLinkedSfmProcess = YES;
    self.linkedSfmProcess = process;
    [self refreshBizRule];
    [self executeBizRuleForLinkedSFM];
//    [self saveAndLaunchLinkedSfm:process];
}

- (void) saveAndLaunchLinkedSfm:(LinkedProcess *)process
{
    if ([self saveRecordBeforeInvokingLinkedProcess]) {
        if ([self.editViewControllerDelegate isEntrtCriteriaMatchesForProcessId:process]) {
            [self dismissViewAndLauchLinkedProcess:process];
            //[self.editViewControllerDelegate invokeLinkedSFMEDitProcess:process];
        }
    }
}

- (BOOL)saveRecordBeforeInvokingLinkedProcess
{
    BOOL didSave = NO;
    
    @synchronized([self class]){
        
        /* Check field level validation */
        if ([self validatePageData]) {
            
            [self.sfmEditPageManager saveHeaderRecord:self.sfmPage];
            [self.sfmEditPageManager saveDetailRecords:self.sfmPage];
            
            if([self isSourceToTargetProcess] || [self isSourceToTargetChildOnlyProcess]){
                [self.sfmEditPageManager performSourceUpdate:self.sfmPage];
            }
            
            if ( [[SNetworkReachabilityManager sharedInstance] isNetworkReachable]){
                [[SyncManager sharedInstance] performSyncWithType:SyncTypeData];
            }
            didSave = YES;
            
            if ([self isEditProcess]) {
                [self loadData];
            }
            
        } else {
            [self performSelectorOnMainThread:@selector(showAlert) withObject:self waitUntilDone:NO];
        }
    }
    return didSave;
}

- (void)dismissViewAndLauchLinkedProcess:(LinkedProcess *)process
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self.editViewControllerDelegate invokeLinkedSFMEDitProcess:process];
    }];
}
#pragma mark - End

#pragma mark - Biz Rule Methods

- (void) executeBusinessRules
{
    if (nil == self.ruleManager) {
        PageEditMasterViewController *detailViewController = [self.childViewControllers objectAtIndex:0];
        
        self.ruleManager = [[BusinessRuleManager alloc] initWithProcessId:self.processId sfmPage:self.sfmPage];
        self.ruleManager.parentView = detailViewController.view;
         self.ruleManager.delegate = self;
        
    }
    
    BOOL shouldExecuteBizRule = [self.ruleManager executeBusinessRules];
    if (!shouldExecuteBizRule) {
        [self saveRecordData];
    }
}

- (void)businessRuleFinishedWithResults:(NSMutableArray *)resultArray
{
    [(PageEditDetailViewController *)self.detailViewController  initiateBuissRulesData:resultArray];

    if (([resultArray count]== 0) || (resultArray == nil) || ([self.ruleManager allWarningsAreConfirmed] && ([self.ruleManager numberOfErrorsInResult] == 0))) {
        [self saveRecordData];
        return;
    }
    [self performSelectorOnMainThread:@selector(stopActivityIndicator) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(enableUI) withObject:self waitUntilDone:NO];
    
}

-(void)refreshBizRuleData
{
    [self.ruleManager updateWarningDict];
}

-(void)refreshBizRule
{
    [(PageEditDetailViewController *)self.detailViewController  refreshDetailView];
    [self refreshBizRuleData];
}

#pragma mark -
#pragma mark Biz Rule Linked SFM

- (void) executeBizRuleForLinkedSFM
{
    [self performSelectorOnMainThread:@selector(showActivityIndicator) withObject:nil waitUntilDone:YES];
    [self executeBusinessRules];
}


- (void) invalidateLinkedSfm{
    self.isLinkedSfmProcess = NO;
    self.linkedSfmProcess = nil;
}

- (void)saveRecordData
{
    if (!self.isLinkedSfmProcess) {
        [self performSelectorInBackground:@selector(saveRecord) withObject:nil];
    }
    else{
        [self performSelectorOnMainThread:@selector(stopActivityIndicator) withObject:nil waitUntilDone:YES];
        [self saveAndLaunchLinkedSfm:self.linkedSfmProcess];
    }
    [self invalidateLinkedSfm];

}

#pragma mark - alert message delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"indexPath: %@",self.requiredFieldIndexPath);
        
        if (self.isHeader) {
            [self selectMasterTableCellWithIndexPath:self.requiredFieldIndexPath];
        } else {
            NSIndexPath *tempIndexPath  = [NSIndexPath indexPathForRow:self.requiredFieldIndexPath.section inSection:1];
            
            [self selectMasterTableCellWithIndexPath:tempIndexPath];
            
            PageEditDetailViewController *detailViewController = [self.viewControllers objectAtIndex:1];
            ChildEditViewController *childEditListViewController = nil;
            if ([[detailViewController allChildViewController] count] > 0 ) {
                childEditListViewController = [[detailViewController allChildViewController] objectAtIndex:0];
            }
            if (childEditListViewController) {
                [childEditListViewController expandRecordWithIndexPath:self.requiredFieldIndexPath];
            }
        }
        self.requiredFieldIndexPath = nil;
    }
}

- (void)selectMasterTableCellWithIndexPath:(NSIndexPath*)indexPath
{
    PageEditMasterViewController *masterViewController;
    if ([self.viewControllers count] > 0) {
        masterViewController = [self.viewControllers objectAtIndex:0];
    }
    [masterViewController selectMasterTableViewCellWithIndexPath:indexPath];
}
@end
