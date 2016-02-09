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
#import "SMXConstants.h"
#import "MobileDeviceSettingService.h"
#import "MobileDeviceSettingsModel.h"
#import "SFMPageHelper.h"
#import "SFObjectFieldModel.h"
#import "DateUtil.h"
#import "AttachmentLocalModel.h"
#import "PushNotificationManager.h"
#import "ModifiedRecordModel.h"
#import "PageEventProcessManager.h"
#import "TransactionObjectModel.h"
#import "CacheManager.h"
#import "ObjectNameFieldValueService.h"
#import "CacheConstants.h"


typedef NS_ENUM(NSInteger, SaveFlow ) {
    SaveFlowOnSaveTapped,
    SaveFlowFromPushNotification
};

@interface PageEditViewController ()<PageEventProcessManagerDelegate> {
    
    // app freeze workaround
    int jsExeCount;
    BOOL jsExecuted;
}

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
@property(nonatomic, strong)PageEventProcessManager *pageEventProManager;
@property(nonatomic, strong) UIAlertView *alertViewBiz;

@property (nonatomic) SaveFlow saveflow;
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

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startFormula];
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
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
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
    [self showActivityIndicator];
    
    [self performSelector:@selector(checkForChanges) withObject:self afterDelay:0.01];
}
- (void)checkForChanges
{
    
    NSString *modifiedFieldAsJsonString = nil;
    [self disableUI];
    self.sfmEditPageManager.dataDictionaryAfterModification = self.sfmPage.headerRecord;
    NSString *headerSfid = [SFMPageHelper getSfIdForLocalId:self.sfmPage.recordId objectName:self.sfmPage.objectName];
    
    modifiedFieldAsJsonString = [self.sfmEditPageManager getJsonStringAfterComparisionForObject:self.sfmPage.objectName recordId:self.sfmPage.recordId sfid:headerSfid andSettingsFlag:NO];
    self.sfmEditPageManager.dataDictionaryAfterModification = nil;
    if(!modifiedFieldAsJsonString)
    {
        NSString *modifiedChildString = [self getTheModifiedString];
        [self enableUI];
        self.sfmEditPageManager.dataDictionaryAfterModification = nil;
        
        if(!modifiedChildString)
        {
            NSString *parentId = nil;
            if ([self.sfmPage isAttachmentEnabled])
            {
                parentId = [SFMPageHelper getSfIdForLocalId:self.sfmPage.recordId objectName:self.sfmPage.objectName];
                if ([StringUtil isStringEmpty:parentId])
                {
                    parentId = self.sfmPage.recordId;
                }
                NSArray *recentlyAddedAttachments = [AttachmentHelper getRecentlyAddedImagesAndVideosForParentId:parentId];
                
                if ([recentlyAddedAttachments count]) {
                    self.sfmPage.isAttachmentEdited = YES;
                }
            }
            
            if(!self.sfmPage.isAttachmentEdited)
            {
                if([self.sfmPage isAttachmentEnabled])
                {
                    [AttachmentHelper revertImagesAndVideosForUploadForParentId:parentId];
                    NSArray *imagesAndVideosArray = [AttachmentHelper getImagesAndVideosForUploadForParentId:parentId];
                    if ([parentId isEqualToString:self.sfmPage.recordId] && ![imagesAndVideosArray count])
                    {
                        [AttachmentHelper deleteAttachmentLocalModelFromDB:parentId];
                    }
                    BOOL status = [AttachmentHelper revertDeleteAttachmentsFromModifiedRecordsForParentId:parentId andLocalIds:[AttachmentHelper modifiedRecordLocalIds]];
                    if (status) {
                        [AttachmentHelper removeModifiedRecordLocalIds];
                    }
                }
                [self stopActivityIndicator];
                
                [self dismissViewControllerAnimated:YES completion:nil];
                [self enableUI];
                
            }
            else
            {
                [self stopActivityIndicator];
                
                [self showConfirmationMessage];
            }
        }
        else
        {
            [self stopActivityIndicator];
            
            [self showConfirmationMessage];
            
        }
    }
    else
    {
        [self stopActivityIndicator];
        
        [self showConfirmationMessage];
        
    }
    
}

- (void)showConfirmationMessage
{
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[[TagManager sharedInstance] tagByName:kTag_SaveChanges]
                                                       delegate:@"self"
                                              cancelButtonTitle:[[TagManager sharedInstance] tagByName:kTag_AbandonChanges]
                                              otherButtonTitles:[[TagManager sharedInstance] tagByName:kTagSfmActionButtonSave], nil];
    alertview.tag = 10;
    alertview.delegate = self;
    [alertview show];
    
}

- (NSString *)getTheModifiedString
{
    NSMutableArray * newlyCreatedRecordIds = [[NSMutableArray alloc] init];
    NSMutableArray * deletedRecordIds = [[NSMutableArray alloc] init];
    NSString *modifiedFieldAsJsonString = nil;
    NSDictionary * processComponents = self.sfmPage.process.component;
    NSArray * allDetailProcessComponents = [processComponents allKeys];
    for(NSString * processCompId in allDetailProcessComponents)
    {
        id addedObject = [self.sfmPage.newlyCreatedRecordIds objectForKey:processCompId];
        if(addedObject != nil)
        {
            [newlyCreatedRecordIds   addObject:addedObject];
        }
        
        
        id deletedObject = [self.sfmPage.deletedRecordIds objectForKey:processCompId];
        if(deletedObject != nil)
        {
            [deletedRecordIds addObject:deletedObject];
        }
        NSMutableArray * detailRecordsArray = [self.sfmPage.detailsRecord
                                               objectForKey:processCompId];
        SFProcessComponentModel * processComponent = [processComponents objectForKey:processCompId];
        
        NSString * parentColumnName = processComponent.parentColumnName;
        NSString * parentSfId =  [self.sfmPage  getHeaderSalesForceId ];
        for (NSMutableDictionary * eachDetailDict in detailRecordsArray)
        {
            self.sfmEditPageManager.dataDictionaryAfterModification = eachDetailDict;
            
            [self.sfmEditPageManager updateRecordIfEventObject:eachDetailDict andObjectName:processComponent.objectName andHeaderObjectName:self.sfmPage.objectName];
            
            SFMRecordFieldData * localIdField = [eachDetailDict objectForKey:kLocalId];
            SFMRecordFieldData * idField = [eachDetailDict objectForKey:kId];
            SFMRecordFieldData * parentField = [eachDetailDict objectForKey:parentColumnName];
            
            if(parentField != nil && [parentSfId length] > 0)
            {
                parentField.internalValue = parentSfId;
                parentField.displayValue = parentSfId;
            }
            modifiedFieldAsJsonString = [self.sfmEditPageManager getJsonStringAfterComparisionForObject:processComponent.objectName recordId:localIdField.internalValue sfid:idField.internalValue andSettingsFlag:NO];
            
            if(modifiedFieldAsJsonString)
            {
                return modifiedFieldAsJsonString;
            }
        }
    }
    if(([newlyCreatedRecordIds count] >0) || ([deletedRecordIds count] >0 ))
    {
        modifiedFieldAsJsonString = @"changes are there";
    }
    newlyCreatedRecordIds = nil;
    deletedRecordIds = nil;
    return  modifiedFieldAsJsonString;
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
        numberOfButton = (int)[headeLayout.buttons count];
    }
    return numberOfButton;
}

- (NSInteger)getAllRightBarButtonTitleTotalLength
{
    SFMHeaderLayout *headeLayout = self.sfmPage.process.pageLayout.headerLayout;
    int maximumCharLimit = 28;
    if (!headeLayout.hideSave) {
        maximumCharLimit = (int)(28 - [[TagManager sharedInstance]tagByName:kTagSfmActionButtonSave].length);
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
    //self.saveflow = SaveFlowOnSaveTapped;
    
    NSString *technicianId;
    if ([self.sfmPage.objectName isEqualToString:kServicemaxEventObject]) {
        technicianId = [PlistManager getTechnicianId];
    }
    if (![self.sfmPage.objectName isEqualToString:kServicemaxEventObject] || technicianId != nil) {
        [self invalidateLinkedSfm];
        
        if ([self.sfmPage isAttachmentEnabled]) {
            
            NSString *parentId = [SFMPageHelper getSfIdForLocalId:self.sfmPage.recordId objectName:self.sfmPage.objectName];
            if ([StringUtil isStringEmpty:parentId]) {
                parentId = self.sfmPage.recordId;
            }
            NSArray *recentlyAddedAttachments = [AttachmentHelper getRecentlyAddedImagesAndVideosForParentId:parentId];
            if ([recentlyAddedAttachments count]) {
                self.sfmPage.isAttachmentEdited = YES;
            }
            [AttachmentHelper updateLastModifiedDateOfAttachmentForParentId:parentId];
            NSArray *localIds = [AttachmentHelper getLocalIdsOfDeleteAttachmentsFromModifiedRecordsForParentId:parentId];
            BOOL status = [AttachmentHelper deleteAttachmentsWithLocalIds:localIds];
            if (status)
            {
                [AttachmentHelper removeModifiedRecordLocalIds];
            }
            NSArray *imagesAndVideosArray = [AttachmentHelper getImagesAndVideosForUploadForParentId:parentId];
            if ([parentId isEqualToString:self.sfmPage.recordId] && ![imagesAndVideosArray count])
            {
                [AttachmentHelper deleteAttachmentLocalModelFromDB:parentId];
            }
            
        }
        if (![self isValidEvent]) {
            return;
        }else {
            [self refreshBizRule];
            [self disableUI];
            [self updateRespondersIfAny];
            [self performSelectorOnMainThread:@selector(showActivityIndicator) withObject:nil waitUntilDone:YES];
            [self executeBusinessRules];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshView_IOS" object:nil];
        }
    }else {
        UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"" message:[[TagManager sharedInstance] tagByName:kTagNoTechnicianAssociatedError] delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles: nil];
        
        [lAlert show];
    }
    
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
    
    SXLogInfo(@"%@",pageButton.title);
}
#pragma mark -End

#pragma mark - Save actions
- (void)saveRecord {
    @synchronized([self class]){
        
        /* Check field level validation */
        if ([self validatePageData]) {
            
            BOOL canUpdateHeader = [self.sfmEditPageManager saveHeaderRecord:self.sfmPage];
            BOOL canUpdateDetail = [self.sfmEditPageManager saveDetailRecords:self.sfmPage];
            
            
            [self saveOnlineLookupDataIntoObjectFieldNameValue];
            
            if([self isSourceToTargetProcess] || [self isSourceToTargetChildOnlyProcess]){
                [self.sfmEditPageManager performSourceUpdate:self.sfmPage];
            }
            
            if (canUpdateDetail || canUpdateHeader) {
                [[SyncManager sharedInstance] performDataSyncIfNetworkReachable];
            }
            
            if(self.saveflow == SaveFlowOnSaveTapped)
            {
                [self performSelectorOnMainThread:@selector(dismissUI) withObject:self waitUntilDone:NO];
            }
            else if (self.saveflow == SaveFlowFromPushNotification)
            {
                [self notifyNotificationManager:NotificationEditSaveStatusSuccess];
                [self performSelectorOnMainThread:@selector(dismissUIPushNotification) withObject:self waitUntilDone:NO];
            }
            
        } else {
            [self performSelectorOnMainThread:@selector(showAlert) withObject:self waitUntilDone:NO];
        }
        [self performSelectorOnMainThread:@selector(enableUI) withObject:self waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(stopActivityIndicator) withObject:nil waitUntilDone:YES];
    }
    
    //    [self checkIfObjectIsEvent:self.sfmPage.objectName];
}
/*
 Method Name:saveOnlineLookupDataIntoObjectFieldNameValue
 Description: This method is used to save online lookup data into ObjectFieldNameValue table.
 */
- (void)saveOnlineLookupDataIntoObjectFieldNameValue {
    
    @autoreleasepool {
        NSMutableDictionary *dataOnlineDataArray = [[CacheManager sharedInstance] getCachedObjectByKey:kObjectNameFieldValueCacheData];
        NSArray *transactionObjects = [dataOnlineDataArray allValues];
        
        if (transactionObjects.count > 0) {
            ObjectNameFieldValueService *service = [[ObjectNameFieldValueService alloc] init];
            if([service updateOrInsertTransactionObjects:transactionObjects]) {
                [[CacheManager sharedInstance] clearCacheByKey:kObjectNameFieldValueCacheData];
            }
        }
    }
}



-(void)checkIfObjectIsEvent:(NSString *)objectName
{
    if ([objectName isEqualToString:kEventObject] ||[objectName isEqualToString:kServicemaxEventObject]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_DISPLAY_RESET object:nil];
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
        
        [self performSelector:@selector(changViewControl) withObject:nil afterDelay:0.2];
        
        
        
        //Commnented on 16-dec. Cause Notification is getting called. BSP
        //        if ([self.editViewControllerDelegate respondsToSelector:@selector(refreshEventInCalendarView)]) {
        //            [self.editViewControllerDelegate refreshEventInCalendarView];
        //        }
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

-(void)changViewControl {
    if ([self.editViewControllerDelegate respondsToSelector:@selector(loadSFMViewPageLayoutForRecordId:andObjectName:)]) {
        [self.editViewControllerDelegate loadSFMViewPageLayoutForRecordId:self.sfmPage.recordId andObjectName:self.sfmPage.objectName];
        self.sfmPage = nil;
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
    
    NSInteger section = -1;
    
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
                    NSInteger row = -1;
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
-(void)showAlert {
    // 25274
    if (SYSTEM_VERSION < 8.0) {
        
        if (![self.alertViewBiz isVisible]) {
            if (self.alertViewBiz == nil)
                self.alertViewBiz = [[UIAlertView alloc] initWithTitle:[AlertMessageHandler titleByType:AlertMessageTypeRequiredFieldWarning]
                                                               message:[AlertMessageHandler messageByType:AlertMessageTypeRequiredFieldWarning]
                                                              delegate:self
                                                     cancelButtonTitle:[AlertMessageHandler cancelButtonTitleByType:AlertMessageTypeRequiredFieldWarning]
                                                     otherButtonTitles:[AlertMessageHandler otherButtonTitleByType:AlertMessageTypeRequiredFieldWarning], nil];
            [self.alertViewBiz performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
        }
    }
    
    else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[AlertMessageHandler titleByType:AlertMessageTypeRequiredFieldWarning] message:[AlertMessageHandler messageByType:AlertMessageTypeRequiredFieldWarning] preferredStyle:(UIAlertControllerStyleAlert)];
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:[AlertMessageHandler cancelButtonTitleByType:AlertMessageTypeRequiredFieldWarning] style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
            [self requiredFieldsAlertTapped];
        }];
        
        [alertController addAction:alertAction];
        [self presentViewController:alertController animated:YES completion:^{}];
    }
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
            [[SyncManager sharedInstance] performDataSyncIfNetworkReachable];
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
    if (![self.sfmEditPageManager executeFieldUpdateRulesOnload:self.sfmPage andView:self.view andDelegate:self forEvent:@"onSave"]) {
        
        [self startBizRule];
    }
    else {
        // app freeze workaround
        jsExeCount = 1;
        jsExecuted = NO;
        [self performSelector:@selector(reloadFormula:) withObject:@"onSave" afterDelay:3.0];
    }
}



-(void)startFormula {
    BOOL formulaExists = [self.sfmEditPageManager executeFieldUpdateRulesOnload:self.sfmPage andView:self.view andDelegate:self forEvent:@"onLoad"];
    if (formulaExists) {
        [self disableUI];
        [self performSelectorOnMainThread:@selector(showActivityIndicator) withObject:nil waitUntilDone:YES];
        jsExeCount = 1;
        jsExecuted = NO;
        [self performSelector:@selector(reloadFormula:) withObject:@"onLoad" afterDelay:3.0];
    }
}

-(void)startBizRule {
    
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
    else {
        // app freeze workaround
        jsExecuted = NO;
        jsExeCount = 1;
        [self performSelector:@selector(reloadBizRule) withObject:nil afterDelay:3.0];
    }
}

-(void)reloadBizRule {
    if(jsExecuted == NO && jsExeCount < 3) {
        NSLog(@"Biz rule hanged count: %d", jsExeCount);
        [self.ruleManager executeBusinessRules];
        jsExeCount++;
        [self performSelector:@selector(reloadBizRule) withObject:nil afterDelay:3.0];
    }
    else {
        [self enableUI];
        [self performSelectorOnMainThread:@selector(stopActivityIndicator) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(showBizRuleAlertMessage) withObject:nil waitUntilDone:YES];
    }
}

-(void)reloadFormula:(NSString *)event {
    if (jsExecuted == NO && jsExeCount < 3) {
        NSLog(@"Formula %@ hanged count : %d", event, jsExeCount);
        [self.sfmEditPageManager executeFieldUpdateRulesOnload:self.sfmPage andView:self.view andDelegate:self forEvent:event];
        jsExeCount++;
    }
    else {
        [self enableUI];
        [self performSelectorOnMainThread:@selector(stopActivityIndicator) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(showBizRuleAlertMessage) withObject:nil waitUntilDone:YES];
    }
}

-(void)showBizRuleAlertMessage {
    NSString *title = @"Data Validation Rule Execution Failed";
    NSString *message = @"Do you wish to discard the changes or continue editing?";
    NSString *discardChanges = [[TagManager sharedInstance] tagByName:kTag_AbandonChanges];
    NSString *continueStr = @"Continue Editing"; //[[TagManager sharedInstance] tagByName:kTag_SaveChanges];
    
    if (SYSTEM_VERSION < 8.0) {
        UIAlertView * _alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",title] message:message delegate:self cancelButtonTitle:discardChanges otherButtonTitles:continueStr,nil];
        _alert.tag = kAlertViewTagBizRuleWarning;
        [_alert show];
    }
    else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@",title] message:message preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *discardAction = [UIAlertAction actionWithTitle:discardChanges style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action) {
            [self alertActionEventForTag:kAlertViewTagBizRuleWarning andButtonIndex:0];
        }];
        UIAlertAction *continueAction = [UIAlertAction actionWithTitle:continueStr style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
            [self alertActionEventForTag:kAlertViewTagBizRuleWarning andButtonIndex:1];
        }];
        [alertController addAction:discardAction];
        [alertController addAction:continueAction];
        [self presentViewController:alertController animated:YES completion:^{
        }];
    }
}


-(void)showFormulaAlertMessage {
    NSString *title = @"ServiceMax Formula Execution Failed";
    NSString *message = @"Do you wish to discard the changes or continue editing?";
    NSString *discardChanges = [[TagManager sharedInstance] tagByName:kTag_AbandonChanges];
    NSString *continueStr = @"Continue Editing"; //[[TagManager sharedInstance] tagByName:kTag_SaveChanges];
    
    if (SYSTEM_VERSION < 8.0) {
        UIAlertView * _alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",title] message:message delegate:self cancelButtonTitle:discardChanges otherButtonTitles:continueStr,nil];
        _alert.tag = kAlertViewTagFormulaWarning;
        [_alert show];
    }
    else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@",title] message:message preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *discardAction = [UIAlertAction actionWithTitle:discardChanges style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action) {
            [self alertActionEventForTag:kAlertViewTagFormulaWarning andButtonIndex:0];
        }];
        UIAlertAction *continueAction = [UIAlertAction actionWithTitle:continueStr style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
            [self alertActionEventForTag:kAlertViewTagFormulaWarning andButtonIndex:1];
        }];
        [alertController addAction:discardAction];
        [alertController addAction:continueAction];
        [self presentViewController:alertController animated:YES completion:^{
        }];
    }
}


-(void)alertActionEventForTag:(int)alertTag andButtonIndex:(int)buttonIndex {
    if (alertTag == kAlertViewTagBizRuleWarning ) {
        switch (buttonIndex) {
            case 0:
                [self cancelButtonTappedInAlert:nil];
                break;
            default:
                break;
        }
    }
    else if (alertTag == kAlertViewTagFormulaWarning) {
        switch (buttonIndex) {
            case 0:
                [self cancelButtonTappedInAlert:nil];
                break;
            case 1:
                [self startFormula];
            default:
                break;
        }
    }
}

- (void)businessRuleFinishedWithResults:(NSMutableArray *)resultArray
{
    // app freeze workaround
    jsExecuted = YES;
    jsExeCount = 0;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadBizRule) object:nil];
    
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
    
    if (![self performBeforeOrAfterSaveEventIfExists]) {
        
        if (!self.isLinkedSfmProcess) {
            [self performSelectorInBackground:@selector(saveRecord) withObject:nil];
        }
        else{
            [self performSelectorOnMainThread:@selector(stopActivityIndicator) withObject:nil waitUntilDone:YES];
            [self saveAndLaunchLinkedSfm:self.linkedSfmProcess];
        }
        [self invalidateLinkedSfm];
        
    }
}

#pragma mark - alert message delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 10)
    {
        [self enableUI];
        if(buttonIndex == 1)
        {
            [self saveButtonTapped:nil];
        }
        else
        {
            [self cancelButtonTappedInAlert:nil];
        }
    }
    else if (alertView.tag == kAlertViewTagBizRuleWarning)
    {
        [self alertActionEventForTag:alertView.tag andButtonIndex:buttonIndex];
    }
    else
    {
        if(buttonIndex == 0)
        {
            [self requiredFieldsAlertTapped];
        }
    }
}


-(void)cancelButtonTappedInAlert:(id)sender {
    if ([self.sfmPage isAttachmentEnabled])
    {
        NSString *parentId = [SFMPageHelper getSfIdForLocalId:self.sfmPage.recordId objectName:self.sfmPage.objectName];
        if ([StringUtil isStringEmpty:parentId])
        {
            parentId = self.sfmPage.recordId;
        }
        [AttachmentHelper revertImagesAndVideosForUploadForParentId:parentId];
        NSArray *imagesAndVideosArray = [AttachmentHelper getImagesAndVideosForUploadForParentId:parentId];
        if ([parentId isEqualToString:self.sfmPage.recordId] && ![imagesAndVideosArray count])
        {
            [AttachmentHelper deleteAttachmentLocalModelFromDB:parentId];
        }
        BOOL status = [AttachmentHelper revertDeleteAttachmentsFromModifiedRecordsForParentId:parentId andLocalIds:[AttachmentHelper modifiedRecordLocalIds]];
        if (status) {
            [AttachmentHelper removeModifiedRecordLocalIds];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    return;
}

//25274
-(void)requiredFieldsAlertTapped {
    
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

- (void)selectMasterTableCellWithIndexPath:(NSIndexPath*)indexPath
{
    PageEditMasterViewController *masterViewController;
    if ([self.viewControllers count] > 0) {
        masterViewController = [self.viewControllers objectAtIndex:0];
    }
    [masterViewController selectMasterTableViewCellWithIndexPath:indexPath];
}

/*This method giving number of day diffrence beteen two date*/
-(int )numberOfDaysFromDate:(NSDate *)startDate andEndDate:(NSDate *)endDate{
    if ((startDate !=nil) && (endDate!=nil)) {
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                            fromDate:startDate
                                                              toDate:endDate
                                                             options:0];
        int i=(int)components.day;
        return i;   //TODO:NEED TO CHECK THIS FOR EVENT WHICH IS JUST CROSSING THE MIDNIGHT MARK. Eg: 1130PM to 1230AM
    }
    return 0;
}

- (BOOL)isValidEvent
{
    BOOL isEventValid = YES;
    NSDictionary *eventDictionary = self.sfmPage.headerRecord;
    
    if ([self.sfmPage.objectName isEqualToString:kEventObject]) {
        SFMRecordFieldData *startDateRecordFieldData = [eventDictionary objectForKey:kStartDateTime];
        SFMRecordFieldData *endDateRecordFieldData = [eventDictionary objectForKey:kEndDateTime];
        NSDate *startDate;
        NSDate *endDate;
        if (startDateRecordFieldData.internalValue != nil && startDateRecordFieldData.internalValue.length) {
            startDate = [DateUtil getDateFromDatabaseString:startDateRecordFieldData.internalValue];
        }
        if (endDateRecordFieldData.internalValue != nil && endDateRecordFieldData.internalValue.length) {
            endDate = [DateUtil getDateFromDatabaseString:endDateRecordFieldData.internalValue];
        }
        
        if ([self numberOfDaysFromDate:startDate andEndDate:endDate] > 14) {
            UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"" message:[[TagManager sharedInstance] tagByName:kTagFourteenDaysEventError] delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles: nil];
            
            [lAlert show];
            lAlert = nil;
            [self performSelectorOnMainThread:@selector(stopActivityIndicator) withObject:nil waitUntilDone:YES];
            [self performSelectorOnMainThread:@selector(enableUI) withObject:self waitUntilDone:NO];
            isEventValid = NO;
        }
    }
    if ([self.sfmPage.objectName isEqualToString:kServicemaxEventObject]) {
        /*
         SFMRecordFieldData *startDateRecordFieldData = [eventDictionary objectForKey:kSVMXStartDateTime];
         SFMRecordFieldData *endDateRecordFieldData = [eventDictionary objectForKey:kSVMXEndDateTime];
         if (startDateRecordFieldData.internalValue != nil && endDateRecordFieldData.internalValue != nil) {
         if ([startDateRecordFieldData.internalValue compare:endDateRecordFieldData.internalValue] == NSOrderedSame || [startDateRecordFieldData.internalValue compare:endDateRecordFieldData.internalValue] == NSOrderedDescending) {
         UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"Invalid event" message:[[TagManager sharedInstance] tagByName:kTagEventTimeError] delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles: nil];
         [lAlert show];
         lAlert = nil;
         [self performSelectorOnMainThread:@selector(stopActivityIndicator) withObject:nil waitUntilDone:YES];
         [self performSelectorOnMainThread:@selector(enableUI) withObject:self waitUntilDone:NO];
         isEventValid = NO;
         }
         }
         */
    }
    return isEventValid;
}

#pragma mark - PushNotification Save implementaion


- (void)saveFromPushNotification
{
    
    self.saveflow = SaveFlowFromPushNotification;
    [self performSelectorOnMainThread:@selector(savePushNotification) withObject:self waitUntilDone:YES];
}

- (void)savePushNotification
{
    NSString *technicianId;
    if ([self.sfmPage.objectName isEqualToString:kServicemaxEventObject]) {
        technicianId = [PlistManager getTechnicianId];
    }
    if (![self.sfmPage.objectName isEqualToString:kServicemaxEventObject] || technicianId != nil) {
        [self invalidateLinkedSfm];
        if ([self.sfmPage isAttachmentEnabled]) {
            
            NSString *parentId = [SFMPageHelper getSfIdForLocalId:self.sfmPage.recordId objectName:self.sfmPage.objectName];
            if ([StringUtil isStringEmpty:parentId]) {
                parentId = self.sfmPage.recordId;
            }
            [AttachmentHelper updateLastModifiedDateOfAttachmentForParentId:parentId];
            NSArray *localIds = [AttachmentHelper getLocalIdsOfDeleteAttachmentsFromModifiedRecordsForParentId:parentId];
            BOOL status = [AttachmentHelper deleteAttachmentsWithLocalIds:localIds];
            if (status)
            {
                [AttachmentHelper removeModifiedRecordLocalIds];
            }
            NSArray *imagesAndVideosArray = [AttachmentHelper getImagesAndVideosForUploadForParentId:parentId];
            if ([parentId isEqualToString:self.sfmPage.recordId] && ![imagesAndVideosArray count])
            {
                [AttachmentHelper deleteAttachmentLocalModelFromDB:parentId];
            }
            
        }
        if (![self isValidEvent]) {
            
        }
        else
        {
            [self refreshBizRule];
            [self disableUI];
            [self updateRespondersIfAny];
            [self performSelectorOnMainThread:@selector(showActivityIndicator) withObject:nil waitUntilDone:YES];
            [self executeBusinessRules];
            
            return;
        }
    }else {
        UIAlertView *lAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Unable to create event since there is no technician associated." delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles: nil];
        
        [lAlert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    }
    
}



- (void)saveRecordDataPushNotification
{
    if (!self.isLinkedSfmProcess) {
        [self performSelectorInBackground:@selector(saveRecordPushNotification) withObject:nil];
    }
    else{
        [self performSelectorOnMainThread:@selector(stopActivityIndicator) withObject:nil waitUntilDone:YES];
        [self notifyNotificationManager:NotificationEditSaveStatusFailure];
        
    }
    [self invalidateLinkedSfm];
    
}
- (void)saveRecordPushNotification {
    @synchronized([self class]){
        
        /* Check field level validation */
        if ([self validatePageData]) {
            
            BOOL canUpdateHeader = [self.sfmEditPageManager saveHeaderRecord:self.sfmPage];
            BOOL canUpdateDetail = [self.sfmEditPageManager saveDetailRecords:self.sfmPage];
            
            if([self isSourceToTargetProcess] || [self isSourceToTargetChildOnlyProcess]){
                [self.sfmEditPageManager performSourceUpdate:self.sfmPage];
            }
            
            if (canUpdateDetail || canUpdateHeader) {
                [[SyncManager sharedInstance] performDataSyncIfNetworkReachable];
            }
            
            
            [self notifyNotificationManager:NotificationEditSaveStatusSuccess];
            [self performSelectorOnMainThread:@selector(dismissUIPushNotification) withObject:self waitUntilDone:NO];
            
        }
        
        else {
            
            [self notifyNotificationManager:NotificationEditSaveStatusFailure];
            [self performSelectorOnMainThread:@selector(showAlert) withObject:self waitUntilDone:NO];
        }
        [self performSelectorOnMainThread:@selector(enableUI) withObject:self waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(stopActivityIndicator) withObject:nil waitUntilDone:YES];
    }
    
}

-(void)dismissUIPushNotification
{
    [self enableUI];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)notifyNotificationManager:(NotificationEditSaveStatus)status
{
    if(status == NotificationEditSaveStatusSuccess)
    {
        [self performSelectorOnMainThread:@selector(notifyNotificationManager_) withObject:nil waitUntilDone:NO];
    }
    
}

-(void)notifyNotificationManager_
{
    [[PushNotificationManager sharedInstance] onEditSaveSuccess];
}


#pragma mark - Before Save


-(BOOL)performBeforeOrAfterSaveEventIfExists {
    BOOL pageEventProcessExists = NO;
    self.pageEventProManager = [[PageEventProcessManager alloc] initWithSFMPage:self.sfmPage];
    self.pageEventProManager.managerDelegate = self;
    if([self.pageEventProManager pageEventProcessExists]) {
        pageEventProcessExists = YES;
        BOOL status = [self.pageEventProManager startPageEventProcessWithParentView:self.view];
        
        if (!status) {
            pageEventProcessExists = NO;
        }
    }
    return pageEventProcessExists;
}

-(void)pageEventProcessCalculationFinishedSuccessFully:(SFMPage *)sfPage {
    SXLogDebug(@"beforeSaveProcessCalculationFinishedSuccessFully");
    
    if (!self.isLinkedSfmProcess) {
        [self performSelectorInBackground:@selector(saveRecord) withObject:nil];
    }
    else{
        [self performSelectorOnMainThread:@selector(stopActivityIndicator) withObject:nil waitUntilDone:YES];
        [self saveAndLaunchLinkedSfm:self.linkedSfmProcess];
    }
    [self invalidateLinkedSfm];
    
    
}

-(void)shouldShowAlertMessageForPageEventProcess:(NSString *)message {
    SXLogDebug(@"before save failed");
    
    if (!self.isLinkedSfmProcess) {
        [self performSelectorInBackground:@selector(saveRecord) withObject:nil];
    }
    else{
        [self performSelectorOnMainThread:@selector(stopActivityIndicator) withObject:nil waitUntilDone:YES];
        [self saveAndLaunchLinkedSfm:self.linkedSfmProcess];
    }
    [self invalidateLinkedSfm];
    
    
}

-(void)refreshSFMPageWithFieldUpdateRuleResults:(NSString *)responseString forEvent:(NSString *)event {
    
    // app freeze workaround
    jsExecuted = YES;
    jsExeCount = 0;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadFormula:) object:event];
    
    [self performSelectorOnMainThread:@selector(updateTheSFMPage:) withObject:responseString waitUntilDone:YES];
    
    
    if ([event isEqualToString:@"onLoad"]) {
        [self enableUI];
        [self performSelectorOnMainThread:@selector(stopActivityIndicator) withObject:nil waitUntilDone:YES];
    }
    [self performSelectorOnMainThread:@selector(reloadDataToFirstSection) withObject:nil waitUntilDone:YES];
    
    
    if ([event isEqualToString:@"onSave"]) {
        [self performSelector:@selector(startBizRule) withObject:nil afterDelay:0.0];
    }
}

-(void)updateTheSFMPage:(NSString *)responseString
{
    [self.sfmEditPageManager updateSFMPageWithFieldUpdateResponse:responseString andSFMPage:self.sfmPage];
    
}

- (void)bizRuleExecute {
    if (nil == self.ruleManager) {
        PageEditMasterViewController *detailViewController = [self.childViewControllers objectAtIndex:0];
        
        self.ruleManager = [[BusinessRuleManager alloc] initWithProcessId:self.processId sfmPage:self.sfmPage];
        self.ruleManager.parentView = detailViewController.view;
        self.ruleManager.delegate = self;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL shouldExecuteBizRule = [self.ruleManager executeBusinessRules];
        if (!shouldExecuteBizRule) {
            [self saveRecordData];
        }
    });
    
}


-(void)dealloc
{
    self.alertViewBiz.delegate = nil;
    self.alertViewBiz = nil;
}

@end
