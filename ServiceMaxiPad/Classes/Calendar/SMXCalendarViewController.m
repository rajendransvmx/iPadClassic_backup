 //
//  SMXCalendarViewController.h.m
/**
 *  @file   FILE_NAME.m
 *  @class  CLASS_NAME
 *
 *  @brief  This class will provide .....
 *
 *
 *
 *  @author  AUTHOR_NAME
 *
 *  @bug     No known bugs
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import "SMXCalendarViewController.h"
#import "ViewControllerFactory.h"
#import "SMXCalendar.h"
#import "CalendarMonthViewController.h"
#import "MapViewController.h"
#import "MapHelper.h"
#import "TagManager.h"
#import "CalenderHelper.h"
#import "CalenderEventObjectModel.h"
#import "StyleManager.h"
#import "AlertMessageHandler.h"
#import "TagManager.h"
#import "CalenderHelper.h"
#import "EventTransactionObjectModel.h"

#import "SFMPageViewController.h"
#import "SFMPageViewManager.h"
#import "SMXBlueButton.h"
#import "CalendarPopupContent.h"
#import "TagManager.h"
#import "NonTagConstant.h"
#import "TransactionObjectDAO.h"
#import "SFMWizardComponentService.h"
#import "SFWizardService.h"
#import "SFProcessService.h"
#import "SFObjectModel.h"
#import "FactoryDAO.h"
#import "SFObjectDAO.h"
#import "SFMPageHelper.h"
#import "PageEditViewController.h"
#import "SFMPageMasterViewController.h"
#import "PlistManager.h"
#import "SyncManager.h"
#import "OPDocViewController.h"
#import "SMXCurrentDayButton.h"
#import "SyncProgressDetailModel.h"
#import "StringUtil.h"

#import "DODRecordsService.h"
#import "SFWizardModel.h"
#import "WizardComponentModel.h"
#import "CacheManager.h"
#import "CacheConstants.h"
#import "TaskManager.h"
#import "TaskGenerator.h"
#import "MobileDeviceSettingService.h"
#import "MobileDeviceSettingsModel.h"
#import "DateUtil.h"
#import "CalenderHelper.h"
#import "SFMCustomActionWebServiceHelper.h"
#import "SFMCustomActionHelper.h"
#import "MBProgressHUD.h"
#import "WebserviceResponseStatus.h"
#import "SNetworkReachabilityManager.h"

#import "ProductIQHomeViewController.h"
#import "ProductIQManager.h"
#import "MessageHandler.h"
#import "StringUtil.h"

//#import "FileManager.h"
//#import "UnzipUtility.h"

#define kLongFormat @"yyyy-MM-dd'T'HH:mm:ss.SSSSZ"
#define kLongFormatZulu @"yyyy-MM-dd'T'HH:mm:ss.SSSS'Z'"
#define kLongFormatStringFormat @"yyyy-MM-dd'T'HH:mm:ss.SSSSZZZZ"

#define NOTIFICATION_TYPE @"notification_Type"
//#define kUpdateEventNotification @"UpdateEventOnNotification"

@interface SMXCalendarViewController () <SMXButtonAddEventWithPopoverProtocol, SMXMonthCalendarViewProtocol, SMXWeekCalendarViewProtocol, SMXDayCalendarViewProtocol,SMActionSideBarViewControllerDelegate, PageEditViewControllerDelegate>
@property (nonatomic) BOOL boolDidLoad;
@property (nonatomic) BOOL boolYearViewIsShowing;
@property (nonatomic, strong) NSMutableDictionary *dictEvents;
@property (nonatomic, strong) UILabel *labelWithMonthAndYear;
@property (nonatomic, strong) NSArray *arrayCalendars;
@property (nonatomic, strong) SMXEditEventPopoverController *popoverControllerEditar;
@property (nonatomic, strong) SMXMonthCalendarView *viewCalendarMonth;
@property (nonatomic, strong) SMXWeekCalendarView *viewCalendarWeek;
@property (nonatomic, strong) SMXDayCalendarView *viewCalendarDay;
@property (nonatomic, strong) UISegmentedControl *cSegmentedControl;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic,strong) UIButton *grayCalenderBkView;
@property (nonatomic, strong) MapViewController *mapViewController;
@property (nonatomic, readwrite) NSInteger previousSelectedSegment;
@property (nonatomic, assign) UIInterfaceOrientation cPreviousDeviceOrientation;
@property(nonatomic,strong)SMXEvent *selectedEvent;
@property (nonatomic, strong) SMActionSideBarViewController *mySideBar;
@property (nonatomic, strong) WizardViewController *tempViewController;
@property (nonatomic, strong) NSTimer *cTimeLineTimer;
@property (nonatomic, strong) UIButton *addEventBtn;
@property (nonatomic,strong) SMXCurrentDayButton *currentWeekButton;
@property (nonatomic, strong) NSTimeZone *cPreviousTimeZone;
@property (nonatomic, assign) BOOL cDataFetchInProgress;
@property (nonatomic, strong)MBProgressHUD *HUD;
@end

@implementation SMXCalendarViewController

#pragma mark - Synthesize

@synthesize boolDidLoad;
@synthesize boolYearViewIsShowing;
@synthesize protocol;
@synthesize arrayWithEvents;
@synthesize dictEvents;
@synthesize labelWithMonthAndYear;
@synthesize arrayCalendars;
@synthesize popoverControllerEditar;
@synthesize viewCalendarMonth;
@synthesize viewCalendarWeek;
@synthesize viewCalendarDay;
@synthesize cSegmentedControl;
@synthesize leftButton;
@synthesize rightButton;
@synthesize monthCalender;
@synthesize grayCalenderBkView;
@synthesize cEventListArray;
@synthesize cPreviousDeviceOrientation;
@synthesize cTimeLineTimer;
@synthesize currentWeekButton;
@synthesize cPreviousTimeZone;
@synthesize cWODetailsDict;
@synthesize cCaseDetailsDict;
@synthesize cDataFetchInProgress;


#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //add observer for event updation notification
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateEventFromNotification:) name:kUpdateEventNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor navBarBG];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    [CalenderHelper alterSVMXEventTable];
    
    [self customNavigationBarLayout];
    [self setTheNotifications];
   
    cPreviousTimeZone = [[NSTimeZone localTimeZone] copy];

    [self getNavigationBarHeight];
//    [self performSelectorInBackground:@selector(fetchEventsFromDb) withObject:nil];
    [self fetchEventsFromDb];
    [self buttonYearMonthWeekDayAction:0];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.addEventBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.navigationController.navigationBar.barTintColor = [UIColor navBarBG];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    if (!boolDidLoad) {
        boolDidLoad = YES;
        [self buttonTodayAction:nil];
    }
    
    [self rightBarButtonItem];
    [self leftBarButtonItemAction];
    [self checkOrientationAndSetNavButtons];
    
    if ((self.cEventListArray == nil) || (self.arrayWithEvents == nil))
    {
        [self showDayCalender];
        [self changeSegementControlText];
        [[SMXDateManager sharedManager] setCurrentDate:[NSDate dateWithYear:[NSDate componentsOfCurrentDate].year
                                                                      month:[NSDate componentsOfCurrentDate].month
                                                                        day:[NSDate componentsOfCurrentDate].day]];
        [self fetchEventsFromDb];
        if (viewCalendarDay.viewDetail) {
            [viewCalendarDay.viewDetail removeFromSuperview];
            viewCalendarDay.viewDetail = nil;
        }
    }
    
    if (cSegmentedControl.selectedSegmentIndex == 0)
    {
        [self addEventForDay];
        [viewCalendarDay refreshDetailView];
         //[self fetchEventsFromDb];//HS 31Mar to just test
    }
    
    UIInterfaceOrientation lCurrentDeviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (!(cPreviousDeviceOrientation == lCurrentDeviceOrientation)) {
        [self resetAllViews];
    }
    
    if (rightButton.tag == 0)
    {
        if (self.selectedEvent)
        {
            [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            self.navigationItem.rightBarButtonItem.enabled = YES;
            
        }
        else
        {
            [rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
    else
    {
        
        
    }
    //HS 23 Jan
    [self updateAddEventBtnUI];
    //HS 23 Jan ends here
  
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components: NSCalendarUnitSecond fromDate:[NSDate date]];
    NSInteger second = [components second];
    NSTimeInterval tillNextMinute = (60 - second) % 60;
    
    [self performSelector:@selector(timerForResetingTheLine) withObject:nil afterDelay:tillNextMinute];
    
    
    
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadWizardData];
}


-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


//Method to update the events in calendar coming from notifications
-(void)updateEventFromNotification:(NSNotification *)notification
{
    [self eventDisplayReset:nil];
//  [self performSelectorInBackground:@selector(loadWizardData) withObject:nil];

    
}



//HS 23 Jan for fix:012843

-(NSArray *)checkForCreateNewEventAvailable
{
    NSString *eventType = [CalenderHelper getEventTypeFromMobileDeviceSettings];
    NSString *objectName = kEventObject;
    if (![eventType isEqualToString:kSalesforceEvent]) {
        objectName = kServicemaxEventObject;
    }
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldName:kobjectApiName operatorType:SQLOperatorEqual andFieldValue:objectName];
    DBCriteria * criteria2 = [[DBCriteria alloc] initWithFieldName:ktype operatorType:SQLOperatorEqual andFieldValue:kProcessTypeStandAloneCreate];
    
    id <SFProcessDAO> processTypeService = [FactoryDAO serviceByServiceType:ServiceTypeProcess];
    
    NSMutableArray *processArray = (NSMutableArray *)[processTypeService fetchSFProcessInfoByFields:nil andCriteria:[NSArray arrayWithObjects:criteria1,criteria2 ,nil] andExpression:nil];
    return processArray;
}


-(void)updateAddEventBtnUI
{
    NSArray *processArrayCount = [self checkForCreateNewEventAvailable];
    if ([processArrayCount count]!=0)
    {
        if (cSegmentedControl.selectedSegmentIndex == 0)
        {
            [self.addEventBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.addEventBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            self.addEventBtn.enabled = YES;
            
        }
        else if ((cSegmentedControl.selectedSegmentIndex == 1) ||(cSegmentedControl.selectedSegmentIndex == 2))
        {
            [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            rightButton.enabled = YES;
        }
    }
    else
    {
        if (cSegmentedControl.selectedSegmentIndex == 0)
        {
            [self.addEventBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            self.addEventBtn.enabled = NO;
            
        }
        else if ((cSegmentedControl.selectedSegmentIndex == 1) ||(cSegmentedControl.selectedSegmentIndex == 2))
        {
            [rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            rightButton.enabled = NO;
        }
        
    }

}
//HS 23 Jan ends here

-(void)setTheNotifications
{
    [self addObserver:self selector:@selector(dataSyncFinished:) withName:kUpadteWebserviceData AndObject:nil];
    [self addObserver:self selector:@selector(dataSyncFinished:) withName:kDataSyncStatusNotification AndObject:nil];
    [self addObserver:self selector:@selector(configSyncFinished:) withName:kConfigSyncStatusNotification AndObject:nil];
    [self addObserver:self selector:@selector(eventDisplayReset:) withName:EVENT_DISPLAY_RESET AndObject:nil];
    [self addObserver:self selector:@selector(removeCalender) withName:CALENDER_VIEW_REMOVE AndObject:nil];
    [self addObserver:self selector:@selector(dateChanged:) withName:DATE_MANAGER_DATE_CHANGED AndObject:nil];
    [self addObserver:self selector:@selector(checkForTimeZoneChange:) withName:CHECK_FOR_TIMEZONE_CHANGE AndObject:nil];
    [self addObserver:self selector:@selector(reloadCalendar:) withName:@"RefreshView_IOS" AndObject:nil];
    [self addObserver:self selector:@selector(refreshOnDayChange) withName:UIApplicationSignificantTimeChangeNotification AndObject:nil];//this is for if day change then we have to refresh calendar screen
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadWizardComponentActionAccordingToNetworkChangeNotification:)
                                                 name:kNetworkConnectionChanged
                                               object:nil];
}

-(void)refreshOnDayChange{
    [self refreshTheUI];
    [self resetTheCurrentTimeLine];
}

-(void)addObserver:(id)observer selector:(SEL)aSelector withName:(NSString *)aName AndObject:(id)anObject
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:aName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:aSelector name:aName object:anObject];
}

-(void)checkForTimeZoneChange:(NSNotification *) pNotification
{
    NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
    if (![currentTimeZone isEqualToTimeZone:cPreviousTimeZone]) {
        // If the timezone is chaged, then the events have to be feteched again from the db.
        cPreviousTimeZone = nil;
        cPreviousTimeZone = [[NSTimeZone localTimeZone] copy];
        [self getEventsFromDBAndRender];
    }
}

-(void)getEventsFromDBAndRender
{
    [self performSelectorInBackground:@selector(fetchEventsFromDb) withObject:nil];
    [self buttonYearMonthWeekDayAction:cSegmentedControl.selectedSegmentIndex];
}

-(void)eventDisplayReset:(NSNotification *)notification
{
    [self performSelectorInBackground:@selector(fetchEventsFromDb) withObject:nil];
}

-(void)dataSyncFinished:(NSNotification *)pNotification
{
    if ([pNotification.name isEqualToString:kUpadteWebserviceData])
    {
        [self eventDisplayReset:nil];
//        [self performSelectorInBackground:@selector(loadWizardData) withObject:nil];
    }
    else
    {
        SyncManager *lSyncManager = (SyncManager *) pNotification.object;
        
        //    BOOL syncStatus = [lSyncManager syncInProgress];
        SyncStatus syncStatus = [lSyncManager getSyncStatusFor:SyncTypeData];
        
        if(syncStatus == SyncStatusSuccess)
        {
            [self eventDisplayReset:nil];
            //[self performSelectorInBackground:@selector(eventDisplayReset:) withObject:nil];
        }
        //[self loadWizardData];
//        [self performSelectorInBackground:@selector(loadWizardData) withObject:nil];
        [self changeSegementControlText];
    }
    
    // IPAD-4505
    if(self.tempViewController != nil) {
        [self.tempViewController reloadTableView];
    }
}

-(void)reloadCalendar:(NSNotification*)notification{
    if (cSegmentedControl.selectedSegmentIndex == 1)
    {
        [self performSelector:@selector(update) withObject:nil afterDelay:2.0f];
    }
}
-(void)update{
    [self performSelectorInBackground:@selector(fetchEventsFromDb) withObject:nil ];
}
- (void)configSyncFinished:(NSNotification*)notification
{
    SyncProgressDetailModel *syncProgressDetailModel = [[notification userInfo]objectForKey:@"syncstatus"];
    SyncStatus status = syncProgressDetailModel.syncStatus;
    if (status == SyncStatusSuccess) {
//        [self loadWizardData];
        [self eventDisplayReset:nil];

    }
    
    [self changeSegementControlText];
    
}

-(void)resetTheCurrentTimeLine
{
    if (cSegmentedControl.selectedSegmentIndex == 0) {
        
        // call method in Day View to reset the line position.
        
        [[NSNotificationCenter defaultCenter]postNotificationName:CURRENT_TIME_LINE_MOVE object:nil];
    }
    else if(cSegmentedControl.selectedSegmentIndex == 1)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:CURRENT_TIME_LINE_MOVE_WEEK object:nil];
    }
}

-(void)reloadCalendarWeek:(NSNotification *)pNotification
{
    [viewCalendarWeek invalidateLayout];
}

-(void)eventSelected:(NSNotification *)pNotification
{
    SFMPageViewManager *pageManager;
    SFMPageViewController *pageViewController = [[SFMPageViewController alloc]init];
    
    if(pNotification.userInfo)
    {
        pageManager = [[SFMPageViewManager alloc] initWithObjectName:[pNotification.userInfo objectForKey:@"objectName"] recordId:[pNotification.userInfo objectForKey:@"contactID"]];
    }
    else
    {
        SMXEvent *eventData =pNotification.object;
        
        TransactionObjectModel *model = [CalenderHelper getRecordForEvent:eventData];

        pageManager = [[SFMPageViewManager alloc] initWithObjectName:[model objectAPIName] recordId:[[model getFieldValueDictionary] objectForKey:@"localId"]];
    }
    
    NSError *error = nil;
    BOOL isValidProcess = [pageManager isValidProcess:pageManager.processId objectName:nil recordId:nil error:&error];
    if (isValidProcess) {
        pageViewController.sfmPageView = [pageManager sfmPageView];
        if (self.addEventBtn)
        {
            [self.addEventBtn removeFromSuperview];
            self.addEventBtn = nil;
        }
        
         [self.navigationController pushViewController:pageViewController animated:YES];
        //[self.navigationController presentViewController:pageViewController animated:YES completion:nil];
    }
    else
    {
        if (error) {
            AlertMessageHandler *alertHandler = [AlertMessageHandler sharedInstance];
            NSString * buttonLOC = [[TagManager sharedInstance] tagByName:kTagAlertErrorOk];
            
            [alertHandler showCustomMessage:[error localizedDescription] withDelegate:nil title:[[TagManager sharedInstance] tagByName:kTagAlertIpadError] cancelButtonTitle:nil andOtherButtonTitles:[[NSArray alloc] initWithObjects:buttonLOC, nil]];
        }
    }
}

-(void)eventSelectedShare:(SMXEvent *)eventData userInfor:(NSDictionary *)contactId
{
    SFMPageViewManager *pageManager;
    SFMPageViewController *pageViewController = [[SFMPageViewController alloc]init];
    if(contactId)
    {
        pageManager = [[SFMPageViewManager alloc] initWithObjectName:[contactId objectForKey:@"objectName"] recordId:[contactId objectForKey:@"contactID"]];
    }
    else
    {
        //SMXEvent *eventData =eventData;
        TransactionObjectModel *model = [CalenderHelper getRecordForEvent:eventData];
        pageManager = [[SFMPageViewManager alloc] initWithObjectName:[model objectAPIName] recordId:[[model getFieldValueDictionary] objectForKey:@"localId"]];
    }
    NSError *error = nil;
    BOOL isValidProcess = [pageManager isValidProcess:pageManager.processId objectName:nil recordId:nil error:&error];
    if (isValidProcess) {
        pageViewController.sfmPageView = [pageManager sfmPageView];
        if (self.addEventBtn)
        {
            [self.addEventBtn removeFromSuperview];
            self.addEventBtn = nil;
        }
        [self.navigationController pushViewController:pageViewController animated:YES];
    }
    else
    {
        if (error) {
            AlertMessageHandler *alertHandler = [AlertMessageHandler sharedInstance];
            NSString * buttonLOC = [[TagManager sharedInstance] tagByName:kTagAlertErrorOk];
            
            [alertHandler showCustomMessage:[error localizedDescription] withDelegate:nil title:[[TagManager sharedInstance] tagByName:kTagAlertIpadError] cancelButtonTitle:nil andOtherButtonTitles:[[NSArray alloc] initWithObjects:buttonLOC, nil]];
        }
    }
}

-(void)dayEventSelected:(SMXBlueButton *)eventButton
{
//    NSLog(@"event Selected %@",pNotification.object);
    //SMXBlueButton *_button=pNotification.object;
    
    //    SMXBlueButton *eventButton = (SMXBlueButton *)pNotification.object;
    self.selectedEvent = eventButton.event;
    
    if (self.selectedEvent)
    {
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        rightButton.enabled = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        [self loadWizardData];
        
        if([ self.tempViewController.wizardsArray count]||
           [self.tempViewController.viewProcessArray count])
        {
            self.mySideBar = [[SMActionSideBarViewController alloc]initWithDirectionFromRight:YES];
            self.mySideBar.sideBarWidth = 320;
            self.mySideBar.delegate = self;
            [self.mySideBar addChildViewController:self.tempViewController];
            self.tempViewController.sideMenu = self.mySideBar;
            [self.mySideBar setContentViewInSideBar:self.tempViewController.view];
            [self.tempViewController willMoveToParentViewController:self.mySideBar];
        }
        else
        {
            [rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            rightButton.enabled = NO;

            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
    else
    {
        [rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
}


-(void)dayEventSelectedShare:(NSNotification *)pNotification
{
    //    NSLog(@"event Selected %@",pNotification.object);
    //SMXBlueButton *_button=pNotification.object;
    
    SMXBlueButton *eventButton = (SMXBlueButton *)pNotification.object;
    self.selectedEvent = eventButton.event;
    
    if (self.selectedEvent)
    {
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        [self loadWizardData];
        
        self.mySideBar = [[SMActionSideBarViewController alloc]initWithDirectionFromRight:YES];
        self.mySideBar.sideBarWidth = 320;
        self.mySideBar.delegate = self;
        [self.mySideBar addChildViewController:self.tempViewController];
        self.tempViewController.sideMenu = self.mySideBar;
        [self.mySideBar setContentViewInSideBar:self.tempViewController.view];
        [self.tempViewController willMoveToParentViewController:self.mySideBar];
    }
    else
    {
        [rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
}


- (void) refreshTheUI
{
//    NSLog(@"<<<<<<<<<<<<<<<<<<<<< STart refreshTheUI >>>>>>>>>>>>>>>>>>>>");
//    [self setEvents:self.cEventListArray]; //Has to be done in main Thread. So shifted here.

    [viewCalendarMonth setDictEvents:dictEvents];
    [viewCalendarWeek setDictEvents:dictEvents];
    [viewCalendarDay setDictEvents:dictEvents];
    
    [self resetAllViews];
    
//    NSLog(@"<<<<<<<<<<<<<<<<<<<<< END refreshTheUI >>>>>>>>>>>>>>>>>>>>");

}

-(void)resetAllViews
{
    [viewCalendarMonth invalidateLayout];
    [viewCalendarWeek invalidateLayout];
    [viewCalendarDay invalidateLayout];
}

-(void)resetloadAllView
{
    // getting called after the rescheduling.
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [viewCalendarMonth invalidateLayout];
        [viewCalendarWeek invalidateLayout];
        [viewCalendarDay.dayContainerScroll.collectionViewDay reloadData];
        [viewCalendarDay showViewDetailsWithEvent:nil cell:nil];

        
    });
}

- (void)loadWizardData
{
//    NSLog(@"Selected event is %@",self.selectedEvent);
    if (self.selectedEvent)
    {
        if (![self checkIfEventStillPresent]) {
            return;
        }
        
        SFObjectModel *objectModel =  [self getObjectNameForSelectedEvent:self.selectedEvent];
        NSString *recordId  = nil;
        //HS issue Fix :013140
        if (objectModel == nil)
        {
            objectModel = [SFObjectModel new];
            objectModel.objectName = self.selectedEvent.eventTableName;
            recordId = self.selectedEvent.localID;

        }
        else
        {
            recordId = [SFMPageHelper getLocalIdForSFID:self.selectedEvent.whatId objectName:objectModel.objectName];

        }
        //HS issue Fix :013140
      
        
        SFWizardService *wizardService = [[SFWizardService alloc]init];
        
        SFMWizardComponentService *wizardComponentService = [[SFMWizardComponentService alloc]init];
        
        NSMutableArray *allWizards = [wizardService getWizardsForObjcetName:objectModel.objectName andRecordId:recordId];
        [wizardComponentService getWizardComponentsForWizards:allWizards recordId:recordId];
        
        //HS 1 Jan to fix issue : 013302
        //RefreshFromSalesforce wizard was not coming for event created on DOD record from calendar
        //[self addUpdateDODBtninWizard:allWizards];
        
        //HS 23 Jan added for fix issue :013040
        [self addRescheduleBtninWizard:allWizards];

        //HS 23 Jan code ends here
        
        //HS 1 Jan code ends here
        
        /*If wizard step is not there for a wizard then it should not be shown in the tableView*/
        
        
        //show or hide ProductIQ
        self.viewPageManager = [[SFMPageViewManager alloc]initWithObjectName:objectModel.objectName recordId:recordId];
        
        //Show or Id product IQ wizard.
        if ([[ProductIQManager sharedInstance] isProductIQSettingEnable]) {
            
            //Disable create or edit process of IB or location objects.
            allWizards = [[ProductIQManager sharedInstance] disableCreateOrEditProcessOfLocationOrIBForAllWizardArray:allWizards withWizardComponetService:wizardComponentService];
            
            if ([[ProductIQManager sharedInstance] isProductIQEnabledForSFMPage:self.viewPageManager.sfmPageView]) {
                allWizards = [[ProductIQManager sharedInstance] addProductIQWizardForAllWizardArray:allWizards withWizardComponetService:wizardComponentService];
            }

        }

        
        SFProcessService *processService = [[SFProcessService alloc]init];
        
        if (self.tempViewController == nil) {
            self.tempViewController = [[WizardViewController alloc]initWithNibName:@"WizardViewController" bundle:nil];
        }
        self.tempViewController.delegate = self;
        self.tempViewController.wizardsArray = allWizards;
        self.tempViewController.viewProcessArray = [processService fetchAllViewProcessForObjectName:objectModel.objectName];
        //wizardController.shouldShowTroubleShooting = self.sfmPageView.sfmPage.process.pageLayout.headerLayout.enableTroubleShooting;
        
        //[self.tempViewController reloadTableView];
        [self performSelectorOnMainThread:@selector(loadWizardUI) withObject:nil waitUntilDone:YES];

    }
   
}

/*
 
 Method: checkIfEventStillPresent
 Paramaters: nil
 return Type: Bool
 Description: Everytime the Action button is displayed. Check if the Event is present in the Day. If the event is not present in the day. make the selectedEvent as nil and disable the Action button.
 Bug: 023634
 Date: 4-Jan-2016
 Autor: BSP
 
 */

-(BOOL)checkIfEventStillPresent
{
    NSDateComponents *comp = [NSDate componentsOfDate:self.selectedEvent.dateTimeBegin];
    NSDate *newDate = [NSDate dateWithYear:comp.year month:comp.month day:comp.day];
    
    NSMutableArray *arrayNew = [dictEvents objectForKey:newDate]; // Array containing all the events of one particular day.
    BOOL isEventPresent = NO;
    for (SMXEvent *event in arrayNew) {
        if ([event.localID isEqualToString:self.selectedEvent.localID]) {
            isEventPresent = YES;
            break;
        }
    }
    
    if (!isEventPresent) {
        self.selectedEvent = nil;
        [rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        rightButton.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [self.mySideBar removeContentViewInSideBar:self.tempViewController.view];
        
    }
    return isEventPresent;
}


//HS 23 Jan15 added for fix issue :013040
-(void)addRescheduleBtninWizard:(NSMutableArray *)allWizards
{
    SFWizardModel *wizardModel = [[SFWizardModel alloc]init];
    wizardModel.wizardName = [[TagManager sharedInstance]tagByName:kTag_Reschedule];
    
    WizardComponentModel *wizardCompModel = [[WizardComponentModel alloc]init];
    wizardCompModel.actionType = @"Reschedule";
    wizardCompModel.actionName = [[TagManager sharedInstance]tagByName:kTag_Reschedule];
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

    
    //TODO:Testing The ProductIQ START.
    
//    SFWizardModel *wizardModelProductIQ = [[SFWizardModel alloc]init];
//    wizardModelProductIQ.wizardName = @"PRODUCTIQ";
//    
//    WizardComponentModel *wizardCompModelProductIQ = [[WizardComponentModel alloc]init];
//    wizardCompModelProductIQ.actionType = @"ProductIQ";
//    wizardCompModelProductIQ.actionName = @"ProductIQActionName";
//    wizardCompModelProductIQ.isEntryCriteriaMatching = YES;
//    if (wizardModelProductIQ.wizardComponents == nil)
//    {
//        wizardModelProductIQ.wizardComponents = [[NSMutableArray alloc]init];
//    }
//    [wizardModelProductIQ.wizardComponents addObject:wizardCompModelProductIQ];
//    
//    if ([wizardModelProductIQ.wizardComponents count] >0)
//    {
//        [allWizards insertObject:wizardModelProductIQ atIndex:1];
//    }
//    
    //TODO:Testing The ProductIQ END.

}

//HS 23 Jan15 code ends here




//HS 1 Jan 2015

-(void)addUpdateDODBtninWizard:(NSMutableArray *)allWizards
{
    
    /* Check if object already exist */
    //NSString *sfIDValue = [self.sfmPageView.sfmPage getHeaderSalesForceId];
    
    NSString *sfIDValue = self.selectedEvent.whatId;
    
    
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

//HS 1 Jan 2015

- (void) loadWizardUI
{
    [self.tempViewController reloadTableView];
}

-(SFObjectModel *)getObjectNameForSelectedEvent:(SMXEvent *)event
{
    if ([event.whatId length] != 18) {
        return nil;
        
        
    }
    
    NSString *keyPrefix = [event.whatId substringToIndex:3];
    
    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:@"keyPrefix" operatorType:SQLOperatorEqual andFieldValue:keyPrefix];
    
    id <SFObjectDAO> objectService = [FactoryDAO serviceByServiceType:ServiceTypeSFObject];
    
    SFObjectModel *model = [objectService getSFObjectInfo:criteria fieldName:@[@"objectName"]];
    return model;
}

-(void)fetchEventsFromDb
{
    if (   ([[SyncManager sharedInstance] isConfigSyncInProgress])
        || ([[SyncManager sharedInstance] isInitalSyncOrResetApplicationInProgress])
        || ([[SyncManager sharedInstance] isConfigSyncInQueue])
        || ([[SyncManager sharedInstance] isInitialSyncInQueue]) || cDataFetchInProgress)
    {
        NSLog(@"Sync In progress, cal reload return or data is already being fetched.");
        return;
    }
    
//    NSLog(@"<<<<<<<<<<<<<<<<<<<<< Start fetchEventsFromDb >>>>>>>>>>>>>>>>>>>>");


    CalenderHelper *lCalenderHelper = [[CalenderHelper alloc] init];
    cDataFetchInProgress = YES;
    self.cEventListArray = [lCalenderHelper getEventDetailsForTheDay];
    cDataFetchInProgress = NO;
//    [self setEvents:self.cEventListArray]; //Has to be done in main Thread. So shifted out from here.

//    NSLog(@"<<<<<<<<<<<<<<<<<<<<< END fetchEventsFromDb >>>>>>>>>>>>>>>>>>>>");
    [self populateDataInMainThread];
//    [self performSelectorOnMainThread:@selector(populateDataInMainThread) withObject:nil waitUntilDone:YES];
}

-(void)populateDataInMainThread{
    
    [self setEvents:self.cEventListArray]; //Has to be done in main Thread. However, it was taking lot of time. hence not put on the main thread.
//    [self refreshTheUI];
    [self performSelectorOnMainThread:@selector(refreshTheUI) withObject:nil waitUntilDone:YES];
    [self performSelectorInBackground:@selector(loadWizardData) withObject:nil];
    
}

-(void)setEvents:(NSArray *) lEventArray
{
    NSMutableArray *lEventCollectionArray = [[NSMutableArray alloc] init];
    for ( EventTransactionObjectModel *lModel in lEventArray) {
        SMXEvent *lEvent;
        NSMutableDictionary *theDict = (NSMutableDictionary *) [lModel getFieldValueDictionary];
        NSString *SplitDayEvents = [theDict objectForKey:@"SplitDayEvents"];
        /* making multiday event after checking its a multiday event or not */
        if (lModel.isItMultiDay && ![StringUtil checkIfStringEmpty:SplitDayEvents]) {
           lEvent=[[SMXEvent alloc] initWithEventWithKeyValue:theDict EventTransactionObjectModel:lModel];
            [self makeEvent:lEvent withArray:lEventCollectionArray objectList:SplitDayEvents];
        }else{
            SMXEvent * lEvent = [[SMXEvent alloc] initWithEventTransactionObjectModel:lModel];
            [lEventCollectionArray addObject:lEvent];
        }
    }
    self.arrayWithEvents = [NSMutableArray arrayWithArray:lEventCollectionArray];
    [self sortTheDayContainers];
}

-(NSArray *)stringToArray:(NSString *)string{
    NSError *e = nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];
    return jsonArray;
}

//making event for multiday and adding into array, This is old function with event window.
//Currently we are not using this method, It was impleted for multiday event with given Date range.
-(void)makeEvent_EventWindow:(SMXEvent *)event withArray:(NSMutableArray *)array objectList:(NSString *)splitEventString {
    NSArray *lSplitArrayEvent = [self stringToArray:splitEventString];
    NSRange dateRange= [self eventWindow:event.dateTimeBegin_multi endDate:event.dateTimeEnd_multi];
    int length=(int)(dateRange.length);
    NSString *dateBegin, *dateEnd, *duration;
    if (length>=0) {
        /* Event sud start with DateWindow range */
        for (int i=(int)dateRange.location; i<([lSplitArrayEvent count]+length); i++) {
            NSDictionary *object=[lSplitArrayEvent objectAtIndex:i];
             /*Cloning event and making new refrensh */
            SMXEvent *newEvent =[[SMXEvent alloc] initWithCalendarModel_self:event];
            /* checking table for proper value */
            if ([newEvent.eventTableName isEqualToString:kSVMXTableName]){
                dateBegin = kSVMXStartDateTime;
                dateEnd = kSVMXEndDateTime;
                duration = kSVMXDurationInMinutes;
            }else{
                dateBegin = kStartDateTime;
                dateEnd = kEndDateTime;
                duration = kDurationInMinutes;
            }
            newEvent.dateTimeBegin = [self dateForTheString: [object objectForKey:dateBegin]];
            newEvent.dateTimeEnd =  [self dateForTheString: [object objectForKey:dateEnd]];
            newEvent.duration= [[object objectForKey:duration] intValue];
            newEvent.isMultidayEvent=YES;
            newEvent.eventIndex=[[object objectForKey:kEventIndex] intValue];
            newEvent.numberOfDays=[[object objectForKey:kEventNumber] intValue];
            [array addObject:newEvent];
        }
    }else{
        for (int i=(int)dateRange.location; i<([lSplitArrayEvent count]+length); i++) {
            NSDictionary *object=[lSplitArrayEvent objectAtIndex:i];
            SMXEvent *newEvent =[[SMXEvent alloc] initWithCalendarModel_self:event];
            /* checking table for proper value */
            if ([newEvent.eventTableName isEqualToString:kSVMXTableName]){
                dateBegin = kSVMXStartDateTime;
                dateEnd = kSVMXEndDateTime;
                duration = kSVMXDurationInMinutes;
            }else{
                dateBegin = kStartDateTime;
                dateEnd = kEndDateTime;
                duration = kDurationInMinutes;
            }
            newEvent.dateTimeBegin = [self dateForTheString: [object objectForKey:dateBegin]];
            newEvent.dateTimeEnd =  [self dateForTheString: [object objectForKey:dateEnd]];
            newEvent.duration= [[object objectForKey:duration] intValue];
            newEvent.isMultidayEvent=YES;
            newEvent.eventIndex=[[object objectForKey:kEventIndex] intValue];
            newEvent.numberOfDays=[[object objectForKey:kEventNumber] intValue];
            [array addObject:newEvent];
        }
    }
}

-(void)makeEvent:(SMXEvent *)event withArray:(NSMutableArray *)array objectList:(NSString *)splitEventString {
    NSArray *lSplitArrayEvent = [self stringToArray:splitEventString];
    NSString *dateBegin, *dateEnd, *duration;
    for (int i=0; i<[lSplitArrayEvent count]; i++) {
        NSDictionary *object=[lSplitArrayEvent objectAtIndex:i];
        /*Cloning event and making new refrensh */
        SMXEvent *newEvent =[[SMXEvent alloc] initWithCalendarModel_self:event];
        /* checking table for proper value */
        if ([newEvent.eventTableName isEqualToString:kSVMXTableName])
        {
            dateBegin = kSVMXStartDateTime;
            dateEnd = kSVMXEndDateTime;
            duration = kSVMXDurationInMinutes;
        }
        else
        {
            dateBegin = kStartDateTime;
            dateEnd = kEndDateTime;
            duration = kDurationInMinutes;
        }
        newEvent.dateTimeBegin = [self dateForTheString: [object objectForKey:dateBegin]];
        newEvent.dateTimeEnd =  [self dateForTheString: [object objectForKey:dateEnd]];
        newEvent.duration= [[object objectForKey:duration] intValue];
        newEvent.isMultidayEvent=YES;
        newEvent.eventIndex=[[object objectForKey:kEventIndex] intValue];
        newEvent.numberOfDays=[[object objectForKey:kEventNumber] intValue];
        [array addObject:newEvent];
    }
}
-(NSDate *)dateForTheString:(NSString *)dateString
{
    NSDateFormatter * lDF = [[NSDateFormatter alloc] init];
    
    [lDF setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    [lDF setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    lDF.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    lDF.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    return [lDF dateFromString:dateString];

}

-(void)sortTheDayContainers
{
    NSSortDescriptor *eventStartDateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateTimeBegin" ascending:YES];
    NSSortDescriptor *eventDurationSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"duration" ascending:NO];
    
    NSArray *allkeys = [dictEvents allKeys];
    
    for (int i = 0; i<allkeys.count; i++) {

        NSArray *dayArray = [dictEvents objectForKey:[allkeys objectAtIndex:i]];

        dayArray =  [dayArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:eventStartDateSortDescriptor, eventDurationSortDescriptor, nil]];
        NSMutableArray *sortedArray = [[NSMutableArray alloc]initWithArray:dayArray];
        [dictEvents setObject:sortedArray forKey:[allkeys objectAtIndex:i]];

    }
    
    [[SMXDateManager sharedManager] setDictEvents:dictEvents];

}

- (void)removeAllEvents
{
    self.cEventListArray = nil;
    self.arrayWithEvents = nil;
    
}

/* HS added for Add Event button for Day view */
-(void)addEventForDay
{
    if (self.addEventBtn) {
        [self.addEventBtn removeFromSuperview];
        self.addEventBtn = nil;
    }
    self.addEventBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect theFrame = rightButton.frame;
    theFrame.origin.x = theFrame.origin.x -theFrame.size.width +28;
    theFrame.size.width = theFrame.size.width - 5;
    
    self.addEventBtn.frame = theFrame;
    NSString *title = [NSString stringWithFormat:@"+ %@",[[TagManager sharedInstance]tagByName:kTag_Add]];
   // self.addEventBtn.backgroundColor = [UIColor redColor];//HS 2 Jan
    [self.addEventBtn setTitle:title forState:UIControlStateNormal];
    self.addEventBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    
    /* chinna changed color to gray for the add event button if no process exist */  //19 feb 15
    NSArray *processArrayCount = [self checkForCreateNewEventAvailable];
    if([processArrayCount count])
    {
        [self.addEventBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.addEventBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    }
    else
    {
        [self.addEventBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    self.addEventBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:18.0];
    [self.addEventBtn addTarget:self action:@selector(addEventForDayClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.addEventBtn.titleLabel.textAlignment=NSTextAlignmentRight;
    self.addEventBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.addEventBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    [self.navigationController.navigationBar addSubview:self.addEventBtn];
    
}

-(void)addEventForDayClicked:(id)inSender
{
    [self createNewEvent];
}

-(void)timerForResetingTheLine
{
    [self resetTheCurrentTimeLine];
    if (cTimeLineTimer) {
        [cTimeLineTimer invalidate];
        cTimeLineTimer = nil;
    }
    cTimeLineTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                      target:self
                                                    selector:@selector(resetTheCurrentTimeLine)
                                                    userInfo:nil
                                                     repeats:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    cPreviousDeviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    [cTimeLineTimer invalidate];
    cTimeLineTimer = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SMXDateManager Notification

- (void)dateChanged:(NSNotification *)notification {
    
    [self updateLabelWithMonthAndYear];
    self.selectedEvent = nil;
    if (cSegmentedControl.selectedSegmentIndex == 0) {
        if (self.selectedEvent)
        {
            [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [self loadWizardData];
            
        }
        else
        {
            [rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            self.navigationItem.rightBarButtonItem.enabled = NO;
            [self.mySideBar removeContentViewInSideBar:self.tempViewController.view];
        }
    }
    else {

        [self leftButtonTextChangeWith:[[SMXDateManager sharedManager] currentDate]];
        [leftButton setImage:[UIImage imageNamed:@"down-arrow-white.png"] forState:UIControlStateNormal];
        [leftButton.titleLabel sizeToFit];
        leftButton.imageEdgeInsets = UIEdgeInsetsMake(7, leftButton.titleLabel.frame.size.width+3, 0, -leftButton.titleLabel.frame.size.width);
    }
}

- (void)updateLabelWithMonthAndYear {
    
    NSDate *ldate = [[SMXDateManager sharedManager] currentDate];
    NSDateComponents *comp = [NSDate componentsOfDate:ldate];
    NSString *monthName = [CalenderHelper getTagValueForMonth:comp.month-1];
    NSString *string = boolYearViewIsShowing ? [NSString stringWithFormat:@"%li", (long)comp.year] : [NSString stringWithFormat:@"%@ %li", monthName, (long)comp.year];
    [labelWithMonthAndYear setText:string];
}

#pragma mark - Init dictEvents

//- (void)setArrayWithEvents:(NSMutableArray *)_arrayWithEvents {
//    arrayWithEvents = _arrayWithEvents;
//    dictEvents = [NSMutableDictionary new];
//    for (SMXEvent *event in _arrayWithEvents) {
//        NSDateComponents *comp = [NSDate componentsOfDate:event.dateTimeBegin];
//        NSDate *newDate = [NSDate dateWithYear:comp.year month:comp.month day:comp.day];
//        NSMutableArray *array = [dictEvents objectForKey:newDate];
//        if (!array) {
//            array = [NSMutableArray new];
//            [dictEvents setObject:array forKey:newDate];
//        }
//        if (![array containsObject:event]) {
//            [array addObject:event];
//        }
//    }
//    [[SMXDateManager sharedManager] setDictEvents:dictEvents];
//}

- (void)setArrayWithEvents:(NSMutableArray *)_arrayWithEvents {
    arrayWithEvents = _arrayWithEvents;
    dictEvents = [NSMutableDictionary new];
    for (SMXEvent *event in _arrayWithEvents) {
       /* int numberOfdays=[self isMultidayEvent:event];
        if (numberOfdays>0) {
            [self makingEvent:event numberOfDays:numberOfdays];
        }
        else{
            [self addEventIntoArray:event];
        }*/
        [self addEventIntoArray:event];
    }
    
//    [[SMXDateManager sharedManager] setDictEvents:dictEvents];

}

/*This method is responsible for multiday event condition*/
-(int)isMultidayEvent:(SMXEvent *)event{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"yyyy-MM-ddHH:mm:ss ZZZ"];
    NSDate *startDate = event.dateTimeBegin;
    NSDate *endDate = event.dateTimeEnd;
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:0];
    if (components.day>0) {
        return (int)components.day;
    }else{
        int i=(int)components.day;
        if(i==0){
            NSDateComponents *Scomp = [NSDate componentsOfDate:startDate];
            NSDateComponents *Ecomp = [NSDate componentsOfDate:endDate];
            if (Scomp.day!=Ecomp.day) {
                return 1;
            }
        }
    }
    return 0;
}
/*This method is responsible for filter event on event window range*/
-(NSRange )eventWindow:(NSDate *)startDate endDate:(NSDate *)endDate{
    
    int location=[self numberOfDate:startDate endDate:[[SMXDateManager sharedManager] getStartDateWindow]];
    int range=[self numberOfDate:endDate endDate:[[SMXDateManager sharedManager] getEndDateWindow]];
    if (location<0) {
        location=0;
    }
    if (range>0) {
        range=0;
    }else{
        NSLog(@"less range");
    }
    return NSMakeRange(location, range);
}

/*This method giving number of day diffrence beteen two date*/
-(int )numberOfDate:(NSDate *)startDate endDate:(NSDate *)endDate{
    startDate=[self changeTime:startDate];
    endDate=[self changeTime:endDate];
    if ((startDate !=nil) && (endDate!=nil)) {
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                            fromDate:startDate
                                                              toDate:endDate
                                                             options:0];
        int i=(int)components.day;
        if(i==0){
            NSDateComponents *Scomp = [NSDate componentsOfDate:startDate];
            NSDateComponents *Ecomp = [NSDate componentsOfDate:endDate];
            if (Scomp.day!=Ecomp.day) {
                return 1;
            }
        }
        return i;
    }
    return 0;
}
-(NSDate *)changeTime:(NSDate *)date{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp = [cal components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[date dateByAddingTimeInterval:0*24*60*60]];
    comp.hour = 00;
    comp.minute = 00;
    comp.second = 00;
    //NSDate *sevenDaysAgo = [cal dateFromComponents:comp];// dateByAddingTimeInterval:numberOfDay*24*60*60];
    return [cal dateFromComponents:comp];
}
/*Here we are spliting multiDay event and making each day event*/
-(void)makingEvent:(SMXEvent *)multiDayEvent numberOfDays:(int)numberOfDays{
    NSRange dateRange= [self eventWindow:multiDayEvent.dateTimeBegin endDate:multiDayEvent.dateTimeEnd];
    int length=(int)(dateRange.length);
    
    if (length>=0) {
        for (int i=(int)dateRange.location; i<(numberOfDays+length); i++) {
            SMXEvent *newEvent =[[SMXEvent alloc] initWithCalendarModel_self:multiDayEvent];
            newEvent.dateTimeBegin_multi=multiDayEvent.dateTimeBegin;
            newEvent.dateTimeEnd_multi=multiDayEvent.dateTimeEnd;
            newEvent.isMultidayEvent=YES;
            if (i==0) {
                newEvent.dateTimeBegin=multiDayEvent.dateTimeBegin;
                newEvent.dateTimeEnd=[self changeTime:multiDayEvent.dateTimeBegin newHour:23 newMin:59 numberOfday:i];
            }else{
                newEvent.dateTimeBegin=[self changeTime:multiDayEvent.dateTimeBegin newHour:0 newMin:0 numberOfday:i];
                newEvent.dateTimeEnd=[self changeTime:multiDayEvent.dateTimeBegin newHour:23 newMin:59 numberOfday:i];
            }
            newEvent.eventIndex=i;
            newEvent.numberOfDays=numberOfDays+1;
            newEvent.duration = [newEvent.dateTimeEnd timeIntervalSinceDate:newEvent.dateTimeBegin]/60;  //NEW BSP

            [self addEventIntoArray:newEvent];
        }
        SMXEvent *newEvent =[[SMXEvent alloc] initWithCalendarModel_self:multiDayEvent];
        newEvent.dateTimeBegin_multi=multiDayEvent.dateTimeBegin;
        newEvent.dateTimeEnd_multi=multiDayEvent.dateTimeEnd;
        newEvent.isMultidayEvent=YES;
        newEvent.dateTimeBegin=[self changeTime:multiDayEvent.dateTimeBegin newHour:0 newMin:0 numberOfday:numberOfDays];
        newEvent.dateTimeEnd=multiDayEvent.dateTimeEnd;
        newEvent.eventIndex=numberOfDays+1;
        newEvent.numberOfDays=numberOfDays;
        newEvent.duration = [newEvent.dateTimeEnd timeIntervalSinceDate:newEvent.dateTimeBegin]/60;  //NEW BSP

        [self addEventIntoArray:newEvent];
    }else{
        for (int i=(int)dateRange.location; i<=(numberOfDays+length); i++) {
            SMXEvent *newEvent =[[SMXEvent alloc] initWithCalendarModel_self:multiDayEvent];
            newEvent.dateTimeBegin_multi=multiDayEvent.dateTimeBegin;
            newEvent.dateTimeEnd_multi=multiDayEvent.dateTimeEnd;
            newEvent.isMultidayEvent=YES;
            if (i==0) {
                newEvent.dateTimeBegin=multiDayEvent.dateTimeBegin;
                newEvent.dateTimeEnd=[self changeTime:multiDayEvent.dateTimeBegin newHour:23 newMin:59 numberOfday:i];
            }else{
                newEvent.dateTimeBegin=[self changeTime:multiDayEvent.dateTimeBegin newHour:0 newMin:0 numberOfday:i];
                newEvent.dateTimeEnd=[self changeTime:multiDayEvent.dateTimeBegin newHour:23 newMin:59 numberOfday:i];
            }
            newEvent.eventIndex=i;
            newEvent.numberOfDays=numberOfDays+1;
            newEvent.duration = [newEvent.dateTimeEnd timeIntervalSinceDate:newEvent.dateTimeBegin]/60;  //NEW BSP

            [self addEventIntoArray:newEvent];
        }
    }
}

/*Here changing date , adding number of day*/
-(NSDate *)changeTime:(NSDate *)date newHour:(int )hour newMin:(int)min numberOfday:(int)numberOfDay{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp = [cal components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[date dateByAddingTimeInterval:numberOfDay*24*60*60]];
    comp.hour = hour;
    comp.minute = min;
    comp.second = 00;
    NSDate *sevenDaysAgo = [cal dateFromComponents:comp];// dateByAddingTimeInterval:numberOfDay*24*60*60];
    return sevenDaysAgo;
}

/*Adding event into array, if array is exist then adding event other wise creating*/
-(void)addEventIntoArray:(SMXEvent *)multiDayEvent{
    
    @synchronized(multiDayEvent)   // For mutux lock. this is used to avoid multiple addition of the events to the array.
    {
        NSDateComponents *comp = [NSDate componentsOfDate:multiDayEvent.dateTimeBegin];
        NSDate *newDate = [NSDate dateWithYear:comp.year month:comp.month day:comp.day];
        NSMutableArray *array = [dictEvents objectForKey:newDate];
        
        if (!array) {
            array = [NSMutableArray new];
            [dictEvents setObject:array forKey:newDate];
        }
        
        
        if (![array containsObject:multiDayEvent]) {
            [array addObject:multiDayEvent];
        }
    }

}

#pragma mark - Custom NavigationBar

- (void)customNavigationBarLayout
{
    if (cSegmentedControl == nil) {
          NSArray *itemArray = [NSArray arrayWithObjects: [[TagManager sharedInstance]tagByName:kTagDay], [[TagManager sharedInstance]tagByName:kTagWeek], [[TagManager sharedInstance]tagByName:kTagMonth],[[TagManager sharedInstance]tagByName:kTagMap], nil];
        cSegmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
        cSegmentedControl.frame = CGRectMake(0, 0, 290, 30);
        [cSegmentedControl addTarget:self action:@selector(MySegmentControlAction:) forControlEvents: UIControlEventValueChanged];
        cSegmentedControl.selectedSegmentIndex = 0;
        cSegmentedControl.layer.cornerRadius = 0.;
        cSegmentedControl.layer.borderColor = [UIColor whiteColor].CGColor;
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                               forKey:NSFontAttributeName];
        [cSegmentedControl setTitleTextAttributes:attributes
                                        forState:UIControlStateNormal];
        [cSegmentedControl sizeToFit];
        CGRect frame = cSegmentedControl.frame;
        frame.size.width = 380;
        cSegmentedControl.frame = frame;
        cSegmentedControl.tintColor = [UIColor whiteColor];
        self.navigationItem.titleView = cSegmentedControl;
    }
}

-(void)changeSegementControlText
{
    [cSegmentedControl setTitle:[[TagManager sharedInstance]tagByName:kTagDay] forSegmentAtIndex:0];
    [cSegmentedControl setTitle:[[TagManager sharedInstance]tagByName:kTagWeek] forSegmentAtIndex:1];
    [cSegmentedControl setTitle:[[TagManager sharedInstance]tagByName:kTagMonth] forSegmentAtIndex:2];
    [cSegmentedControl setTitle:[[TagManager sharedInstance]tagByName:kTagMap] forSegmentAtIndex:3];
}

- (void)MySegmentControlAction:(UISegmentedControl *)segment
{
    if (segment.selectedSegmentIndex == [segment numberOfSegments] -1)
    {
        NSDate *today = [NSDate dateWithYear:[NSDate componentsOfCurrentDate].year
                                       month:[NSDate componentsOfCurrentDate].month
                                         day:[NSDate componentsOfCurrentDate].day];
        NSDate *currentDate = (self.previousSelectedSegment == 0) ? [[SMXDateManager sharedManager] currentDate] : today;
        NSArray *currentDayWorkorders = [MapHelper workOrderSummaryArrayOfCurrentDay:currentDate];
        if (![currentDayWorkorders count]) {
            NSString * alert_title = [[TagManager sharedInstance] tagByName:kTagOnClickMapError];
            NSString * alert_ok = [[TagManager sharedInstance] tagByName:kTagAlertErrorOk];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:alert_title delegate:nil cancelButtonTitle:nil otherButtonTitles:alert_ok, nil];
            [alertView show];
            [self.cSegmentedControl setSelectedSegmentIndex:self.previousSelectedSegment];
            return;
        }
        
        if (!self.mapViewController) {
            [self removeUnNecessarySubviews];
            self.mapViewController = [ViewControllerFactory createViewControllerByContext:ViewControllerMap];
            self.mapViewController.selectedDate = currentDate;
            self.mapViewController.workOrderSummaryArray = [[NSMutableArray alloc] initWithArray:currentDayWorkorders];
            [self addChildViewController:self.mapViewController];
            self.mapViewController.view.frame = self.view.bounds;
            self.mapViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.view addSubview:self.mapViewController.view];
            [self.mapViewController didMoveToParentViewController:self];
            self.previousSelectedSegment = self.cSegmentedControl.selectedSegmentIndex;
            self.navigationItem.rightBarButtonItem.enabled = NO;
            self.navigationItem.rightBarButtonItem = nil;
            self.navigationItem.leftBarButtonItem.enabled = NO;
            leftButton.hidden=YES;
            if (self.addEventBtn) {
                [self.addEventBtn removeFromSuperview];
                self.addEventBtn = nil;
            }
        }
    }
    else {
        [self removeMapViewVC];
        [self resetTheCurrentTimeLine];
        [self buttonYearMonthWeekDayAction:segment.selectedSegmentIndex];
        if (!self.navigationItem.rightBarButtonItem.enabled) {
            [self rightBarButtonItem];
            if(self.cSegmentedControl.selectedSegmentIndex == 0)
                self.navigationItem.rightBarButtonItem.enabled = NO;
        }
        if (!self.navigationItem.leftBarButtonItem.enabled && segment.selectedSegmentIndex != 0)
        {
            [self leftBarButtonItemAction];
        }
        leftButton.hidden=NO;
        [self checkOrientationAndSetNavButtons];
        [self updateAddEventBtnUI];

        if (self.navigationItem.leftBarButtonItem.enabled && segment.selectedSegmentIndex != 0) {
            
            [self leftButtonTextChangeWith:[[SMXDateManager sharedManager] currentDate]];
            [leftButton setImage:[UIImage imageNamed:@"down-arrow-white.png"] forState:UIControlStateNormal];
            [leftButton.titleLabel sizeToFit];
            leftButton.imageEdgeInsets = UIEdgeInsetsMake(7, leftButton.titleLabel.frame.size.width+3, 0, -leftButton.titleLabel.frame.size.width);
        }
    }
}

- (void) removeMapViewVC
{
    if (self.mapViewController) {
        [self.mapViewController willMoveToParentViewController:nil];
        [self.mapViewController.view removeFromSuperview];
        [self.mapViewController removeFromParentViewController];
        self.mapViewController = nil;
    }
}

- (void)addLeftBarButtonItems {
    
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedItem.width = 30.;
    
    SMXRedAndWhiteButton *buttonToday = [[SMXRedAndWhiteButton alloc] initWithFrame:CGRectMake(0., 0., 80., 30)];
    [buttonToday addTarget:self action:@selector(buttonTodayAction:) forControlEvents:UIControlEventTouchUpInside];
    [buttonToday setTitle:@"today" forState:UIControlStateNormal];
    UIBarButtonItem *barButtonToday = [[UIBarButtonItem alloc] initWithCustomView:buttonToday];
    
    labelWithMonthAndYear = [[UILabel alloc] initWithFrame:CGRectMake(0., 0., 170., 30)];
    [labelWithMonthAndYear setTextColor:[UIColor orangeColor]];
    [labelWithMonthAndYear setFont:buttonToday.titleLabel.font];
    UIBarButtonItem *barButtonLabel = [[UIBarButtonItem alloc] initWithCustomView:labelWithMonthAndYear];
    
    [self.navigationItem setLeftBarButtonItems:@[barButtonLabel, fixedItem, barButtonToday]];
}

- (SMXRedAndWhiteButton *)calendarButtonWithTitle:(NSString *)title {
    
    SMXRedAndWhiteButton *button = [[SMXRedAndWhiteButton alloc] initWithFrame:CGRectMake(0., 0., 80., 30.)];
    [button addTarget:self action:@selector(buttonYearMonthWeekDayAction:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    return button;
}


-(void)removeUnNecessarySubviews
{
    [viewCalendarDay removeFromSuperview];
    viewCalendarDay = nil;
    
    [viewCalendarWeek removeFromSuperview];
    viewCalendarWeek = nil;
    
    [viewCalendarMonth removeFromSuperview];
    viewCalendarMonth = nil;
    
}

#pragma mark - Button Action
- (IBAction)buttonYearMonthWeekDayAction:(long)selectedIndex {
    
    [self removeCalender];
    [[NSNotificationCenter defaultCenter] postNotificationName:[CalendarPopupContent getNotificationKey] object:nil];
    self.previousSelectedSegment = self.cSegmentedControl.selectedSegmentIndex;
    [self removeUnNecessarySubviews];
    if (self.previousSelectedSegment == 0) {
        
        [[SMXDateManager sharedManager] setSelectedEvent:nil];
        [self setUpDayCalendarView];
        [self addEventForDay];

        rightButton.tag=self.previousSelectedSegment;
        leftButton.tag=0;
        [rightButton setTitle:[[TagManager sharedInstance] tagByName:kTagActions] forState:UIControlStateNormal];
//        if (self.selectedEvent)    // Bug: 014210 6-Mar-2015 BSP
        {
            self.selectedEvent = nil;
            [rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            rightButton.enabled = NO;
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
    else if (self.previousSelectedSegment == 1) {
        
        [self setUpWeekCalendarView];
        [self.addEventBtn removeFromSuperview];
        self.addEventBtn = nil;
        rightButton.tag=1;
        leftButton.tag=1;
       
        [rightButton setTitle:[NSString stringWithFormat:@"+ %@",[[TagManager sharedInstance]tagByName:kTag_AddEvent]] forState:UIControlStateNormal]; //Fix for Issue 013034
        rightButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //[rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
    }
    else if (self.previousSelectedSegment == 2){

        [self setUpMonthCalendarView];

        [self.addEventBtn removeFromSuperview];
        self.addEventBtn = nil;
        
        rightButton.tag=self.previousSelectedSegment;
        leftButton.tag=2;
        //[rightButton setTitle:[[TagManager sharedInstance] tagByName:kTagActions] forState:UIControlStateNormal];
        [rightButton setTitle:[NSString stringWithFormat:@"+ %@",[[TagManager sharedInstance]tagByName:kTag_AddEvent]] forState:UIControlStateNormal];
        rightButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;


        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        // 15/09/2014 Code for MAP Pending.
    }
    else if (self.previousSelectedSegment == 3){
       // self.addEventBtn.hidden = YES;
        
        [self.addEventBtn removeFromSuperview];
        self.addEventBtn = nil;

        rightButton.tag=self.previousSelectedSegment;
        leftButton.tag=3;
        [rightButton setTitle:@" " forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        return;  // 15/09/2014 Code for MAP Pending.
    }
    [self.view bringSubviewToFront:[self.arrayCalendars objectAtIndex:self.previousSelectedSegment]];
    
    [self updateLabelWithMonthAndYear];
    [self checkOrientationAndSetNavButtons];
}

- (IBAction)buttonTodayAction:(id)sender {
    
    [[SMXDateManager sharedManager] setCurrentDate:[NSDate dateWithYear:[NSDate componentsOfCurrentDate].year
                                                                  month:[NSDate componentsOfCurrentDate].month
                                                                    day:[NSDate componentsOfCurrentDate].day]];
}

#pragma mark - Add Calendars

-(void)setUpDayCalendarView
{
    CGRect frame=self.view.frame;
    frame = CGRectMake(0., 0., self.view.frame.size.width, self.view.frame.size.height);
    viewCalendarDay = [[SMXDayCalendarView alloc] initWithFrame:frame];
    [viewCalendarDay setProtocol:self];
    [viewCalendarDay setDictEvents:dictEvents];
    [self.view addSubview:viewCalendarDay];
    [self setForCalendarPopup:0];
}

-(void)setUpWeekCalendarView
{
    CGRect frame=self.view.frame;
    frame = CGRectMake(0., 0., self.view.frame.size.width, self.view.frame.size.height);
    viewCalendarWeek = [[SMXWeekCalendarView alloc] initWithFrame:frame];
    [viewCalendarWeek setProtocol:self];
    [viewCalendarWeek setDictEvents:dictEvents];
    [self.view addSubview:viewCalendarWeek];
    [self setForCalendarPopup:1];
}

-(void)setUpMonthCalendarView
{
    CGRect frame=self.view.frame;
    frame = CGRectMake(0., 0., self.view.frame.size.width, self.view.frame.size.height);
    viewCalendarMonth = [[SMXMonthCalendarView alloc] initWithFrame:frame];
    [viewCalendarMonth setProtocol:self];
    [viewCalendarMonth setDictEvents:dictEvents];
    [self.view addSubview:viewCalendarMonth];
    [self setForCalendarPopup:2];
}

-(void)setForCalendarPopup:(int)index{
    /*Here we are setting popup seting for day week month*/
    if (index==0) {
        [CalendarPopupContent setdayPopup:TRUE];
        [CalendarPopupContent setWeekIsActive:NO];
    }else if (index==1){
        [CalendarPopupContent setdayPopup:FALSE];
        [CalendarPopupContent setWeekIsActive:YES];
    }else if (index==2){
        [CalendarPopupContent setdayPopup:FALSE];
        [CalendarPopupContent setWeekIsActive:NO];
    }else if (index==3){
        
    }
}

#pragma mark - Interface Rotation

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:[CalendarPopupContent getNotificationKey] object:nil];
//    [self getNavigationBarHeight];
//    //    [viewCalendarYear invalidateLayout];
//    
//    
//    [viewCalendarMonth invalidateLayout];
//    [viewCalendarWeek invalidateLayout];
//    [viewCalendarDay invalidateLayout];
//    
//    [self checkOrientationAndSetNavButtons];
//    [viewCalendarMonth invalidateLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:[CalendarPopupContent getNotificationKey] object:nil];
    [self getNavigationBarHeight];
    //    [viewCalendarYear invalidateLayout];
    
    [self resetAllViews];
    [self checkOrientationAndSetNavButtons];
    
}

-(void)getNavigationBarHeight
{
    gNavBarHeight = self.navigationController.navigationBar.frame.size.height;
    //NSLog(@"%lf",gNavBarHeight);
}

-(void)checkOrientationAndSetNavButtons
{
    if ((leftButton.tag==0 || leftButton.tag==-1) && (cSegmentedControl.selectedSegmentIndex == 0)) {
        UIInterfaceOrientation lInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (lInterfaceOrientation == UIInterfaceOrientationPortrait || lInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            if (cSegmentedControl.selectedSegmentIndex == 0) {
                leftButton.tag=0;
                [leftButton setAttributedTitle:[self getString:@"" year:[[TagManager sharedInstance]tagByName:kTagHomeCalendar]] forState:UIControlStateNormal];
                [leftButton setAttributedTitle:[self getStringHighlighted:@"" year:[[TagManager sharedInstance]tagByName:kTagHomeCalendar]] forState:UIControlStateHighlighted];
                [leftButton setImage:nil forState:UIControlStateNormal];
                leftButton.titleEdgeInsets = UIEdgeInsetsMake(0, -leftButton.imageView.frame.size.width,0, leftButton.imageView.frame.size.width);
            }
        }
        else
        {
            if (cSegmentedControl.selectedSegmentIndex == 0) {
                leftButton.tag=-1;
                [leftButton setAttributedTitle:[self getString:@"" year:@""] forState:UIControlStateNormal];
                [leftButton setAttributedTitle:[self getStringHighlighted:@"" year:@""] forState:UIControlStateHighlighted];
                [leftButton setImage:nil forState:UIControlStateNormal];
                leftButton.titleEdgeInsets = UIEdgeInsetsMake(0, -leftButton.imageView.frame.size.width, 0, leftButton.imageView.frame.size.width);
            }
        }
    }else {
        [self leftBarButtonItemAction];
        [self leftButtonTextChangeWith:[[SMXDateManager sharedManager] currentDate]];
        [leftButton setImage:[UIImage imageNamed:@"down-arrow-white.png"] forState:UIControlStateNormal];
        [leftButton.titleLabel sizeToFit];
        leftButton.imageEdgeInsets = UIEdgeInsetsMake(7, leftButton.titleLabel.frame.size.width+3, 0, -leftButton.titleLabel.frame.size.width);
    }
//    }else if(cSegmentedControl.selectedSegmentIndex == 1){
//        [self leftBarButtonItemAction];
//        [self leftButtonTextChangeWith:[[SMXDateManager sharedManager] currentDate]];
//        [leftButton setImage:[UIImage imageNamed:@"down-arrow-white.png"] forState:UIControlStateNormal];
//        [leftButton sizeToFit];
//        leftButton.imageEdgeInsets = UIEdgeInsetsMake(7, leftButton.titleLabel.frame.size.width+3, 0, -leftButton.titleLabel.frame.size.width);
//    }else if(cSegmentedControl.selectedSegmentIndex == 2){
//        [self leftButtonTextChangeWith:[[SMXDateManager sharedManager] currentDate]];
//        [leftButton setImage:[UIImage imageNamed:@"down-arrow-white.png"] forState:UIControlStateNormal];
//        [leftButton sizeToFit];
//        leftButton.imageEdgeInsets = UIEdgeInsetsMake(7, leftButton.titleLabel.frame.size.width+3, 0, -leftButton.titleLabel.frame.size.width);
//    }else if(cSegmentedControl.selectedSegmentIndex == 3){
//        [self leftButtonTextChangeWith:[[SMXDateManager sharedManager] currentDate]];
//        [leftButton setImage:[UIImage imageNamed:@"down-arrow-white.png"] forState:UIControlStateNormal];
//        leftButton.imageEdgeInsets = UIEdgeInsetsMake(7, leftButton.titleLabel.frame.size.width+3, 0, -leftButton.titleLabel.frame.size.width);
//        [leftButton sizeToFit];
//    }
    
}

-(void)showDayLeftPanel:(id)sender{
    if (cSegmentedControl.selectedSegmentIndex==0) {
        [self removeCalender];
        UIInterfaceOrientation lInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (lInterfaceOrientation == UIInterfaceOrientationPortrait || lInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            [[NSNotificationCenter defaultCenter] postNotificationName:[CalendarPopupContent getNotificationKey] object:nil];
            leftButton.tag=0;
            [viewCalendarDay showLeftPanel];
        }else{
            
        }
    }else if (cSegmentedControl.selectedSegmentIndex==1) {
        [self addCalendar];
    }else if (cSegmentedControl.selectedSegmentIndex==2) {
        [self addCalendar];
    }else if (cSegmentedControl.selectedSegmentIndex==3) {
        [self addCalendar];
    }
}
-(void)addCalendar{
    if (grayCalenderBkView==nil) {
        [CalendarPopupContent setColor:[UIColor whiteColor]];
        [CalendarPopupContent setdayPopup:FALSE];
        if (cSegmentedControl.selectedSegmentIndex==1) {
            [CalendarPopupContent setWeekIsActive:YES];
        }else{
            [CalendarPopupContent setWeekIsActive:NO];
        }
        [CalendarPopupContent setWidth:100];
        [CalendarPopupContent setHight:100];
        [CalendarPopupContent setCalendarTopBarHeight:100];
        
        [CalendarPopupContent setTileWidth:64.0f];
        [CalendarPopupContent setTileHeightAdjustment:35.0f];
        [CalendarPopupContent setCalendarViewHeight:389.0f];
        [CalendarPopupContent setCalendarTopBarHeight:80.0f];
        [CalendarPopupContent setNotificationKey:CALENDER_VIEW_REMOVE];
        
        monthCalender=[[CalendarMonthViewController alloc] initWithSunday:YES];
        monthCalender.view.frame=CGRectMake(38, 0, 452, 439);
        monthCalender.view.backgroundColor=[UIColor  whiteColor];//anish
        [self calenderButton];
        [self currentDayButtonCall:monthCalender.view];
        [grayCalenderBkView addSubview:monthCalender.view];
        monthCalender.view.layer.shadowOpacity=0.50f;
        monthCalender.view.layer.shadowColor=[UIColor grayColor].CGColor;
        monthCalender.view.layer.masksToBounds = NO;
        monthCalender.view.layer.cornerRadius = 0.f;
        monthCalender.view.layer.shadowOffset = CGSizeMake(7.0f,7.5f);
        monthCalender.view.layer.shadowRadius = 1.5f;
        [monthCalender.view addSubview:[self grayLine:CGRectMake(15, 80, 430, 1)]];
        [monthCalender.view addSubview:[self grayLine:CGRectMake(15, 389, 430, 1)]];
    }else{
        [monthCalender.view removeFromSuperview];
        monthCalender=nil;
        [grayCalenderBkView removeFromSuperview];
        grayCalenderBkView=nil;
    }
}

-(void)currentDayButtonCall:(UIView *)parent{
    currentWeekButton = [[SMXCurrentDayButton alloc] initWithFrame:CGRectMake(0., 0., 120., 35.)];
    [currentWeekButton initialsetup:parent];
    [currentWeekButton setDelegate:self];
    [parent addSubview:currentWeekButton];
}

-(UIImageView *)grayLine:(CGRect)rect{
    UIImageView *grayLine=[[UIImageView alloc] initWithFrame:rect];
    grayLine.backgroundColor=[UIColor colorWithHexString:@"D7D7D7"];
    return grayLine;
}
#pragma mark - SMXButtonAddEventWithPopover Protocol
- (void)addNewEvent:(SMXEvent *)eventNew {
    
    NSMutableArray *arrayNew = [dictEvents objectForKey:eventNew.ActivityDateDay];
    if (!arrayNew) {
        arrayNew = [NSMutableArray new];
        [dictEvents setObject:arrayNew forKey:eventNew.ActivityDateDay];
    }
    [arrayNew addObject:eventNew];
    
    [self setNewDictionary:dictEvents];
}

#pragma mark - SMXMonthCalendarView, SMXWeekCalendarView and SMXDayCalendarView Protocols

- (void)setNewDictionary:(NSDictionary *)dict {
    
    dictEvents = (NSMutableDictionary *)dict;
    
    [viewCalendarMonth setDictEvents:dictEvents];
    [viewCalendarWeek setDictEvents:dictEvents];
    [viewCalendarDay setDictEvents:dictEvents];
    
    [self arrayUpdatedWithAllEvents];
}

#pragma mark - Sending Updated Array to SMXCalendarViewController Protocol

- (void)arrayUpdatedWithAllEvents {
    
    NSMutableArray *arrayNew = [NSMutableArray new];
    
    NSArray *arrayKeys = dictEvents.allKeys;
    for (NSDate *date in arrayKeys) {
        NSArray *arrayOfDate = [dictEvents objectForKey:date];
        for (SMXEvent *event in arrayOfDate) {
            [arrayNew addObject:event];
        }
    }
    
    if (protocol != nil && [protocol respondsToSelector:@selector(arrayUpdatedWithAllEvents:)]) {
        [protocol arrayUpdatedWithAllEvents:arrayNew];
    }
}

-(void)rightBarButtonItem{
    
    if (self.cSegmentedControl.selectedSegmentIndex != [self.cSegmentedControl numberOfSegments] -1) {
        if (!rightButton) {
            
            rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            rightButton.frame = CGRectMake(0, 0, 100, 25);
            [rightButton setTitle:[[TagManager sharedInstance]tagByName:kTagActions] forState:UIControlStateNormal];
            [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            rightButton.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:18.0];
            [rightButton addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            rightButton.titleLabel.textAlignment=NSTextAlignmentRight;
            rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithCustomView:rightButton];
    }
}

-(void)leftBarButtonItemAction{
    if (self.cSegmentedControl.selectedSegmentIndex != [self.cSegmentedControl numberOfSegments] -1) {
        leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(0, 0, 130, 40);
        NSString *calender=[NSString stringWithFormat:@"  %@",[[TagManager sharedInstance] tagByName:kTagHomeCalendar]];
        [leftButton setAttributedTitle:[self getString:@"" year:calender] forState:UIControlStateNormal];
        [leftButton setAttributedTitle:[self getStringHighlighted:@"" year:calender] forState:UIControlStateHighlighted];
        [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [leftButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        leftButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0];
        [leftButton addTarget:self action:@selector(showDayLeftPanel:) forControlEvents:UIControlEventTouchUpInside];
        leftButton.titleLabel.textAlignment=NSTextAlignmentRight;
        leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [leftButton setImage:[UIImage imageNamed:@"down-arrow-white.png"] forState:UIControlStateNormal];
        leftButton.titleEdgeInsets = UIEdgeInsetsMake(0, -leftButton.imageView.frame.size.width,0, leftButton.imageView.frame.size.width);
        self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc] initWithCustomView:leftButton];
        self.navigationItem.leftBarButtonItem.enabled = YES;
        [ self.navigationItem.leftBarButtonItem setBackgroundImage:[UIImage imageNamed:@"down-arrow-white.png"] forState:UIControlStateNormal barMetrics:0];
        [leftButton sizeToFit];
        leftButton.imageEdgeInsets = UIEdgeInsetsMake(7, leftButton.titleLabel.frame.size.width+3, 0, -leftButton.titleLabel.frame.size.width);
    }
}
-(void)calenderButton{
    grayCalenderBkView = [UIButton buttonWithType:UIButtonTypeCustom];
    grayCalenderBkView.frame = CGRectMake(0,0,1024,1024);
    [grayCalenderBkView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [grayCalenderBkView addTarget:self action:@selector(hideCalender:) forControlEvents:UIControlEventTouchUpInside];
    grayCalenderBkView.backgroundColor=[UIColor clearColor];
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width,self.view.frame.size.height-0)];
    imageView.backgroundColor=[UIColor colorWithHexString:@"434343"];
    imageView.alpha=0.3;
    [grayCalenderBkView addSubview:imageView];
    [self.view addSubview:grayCalenderBkView];
}


-(NSAttributedString *)getString:(NSString *)month year:(NSString *)year{
    if (month==nil && year==nil) {
        return [[NSAttributedString alloc] init];
    }
    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",month,year]];
    NSInteger _stringLength=[month length];
    NSDictionary *attrDict = @{
                               NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:20.0],
                               NSForegroundColorAttributeName : [UIColor whiteColor]
                               };
    [attString addAttributes:attrDict range:NSMakeRange(0,[attString length])];
    [attString addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0]
                      range:NSMakeRange(0, _stringLength)];
    return attString;
}
-(NSAttributedString *)getStringHighlighted:(NSString *)month year:(NSString *)year{
    if (month==nil && year==nil) {
        return [[NSAttributedString alloc] init];
    }
    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",month,year]];
    NSInteger _stringLength=[month length];
    NSDictionary *attrDict = @{
                               NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:18.0],
                               NSForegroundColorAttributeName : [UIColor grayColor]
                               };
    [attString addAttributes:attrDict range:NSMakeRange(0,[attString length])];
    [attString addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0]
                      range:NSMakeRange(0, _stringLength)];
    return attString;
}

-(void)actionButtonClicked:(id)sender{
    UIButton *senderButton=(UIButton *)sender;
    if (senderButton.tag==0) {
        if (self.mySideBar.hasShownSideBar) {
            [self.mySideBar dismissAnimated:YES];
        }
        [self.mySideBar showInViewController:self animated:YES];
    }
    else if (senderButton.tag==1) {
        [self createNewEvent]; //HS
        
    }else if (senderButton.tag==2){
        [self createNewEvent];//HS issue no - 013034
        
    }else if (senderButton.tag==3){
    }
}

-(void)createNewEvent
{
    NSString *eventType = [CalenderHelper getEventTypeFromMobileDeviceSettings];
    NSString *objectName = kEventObject;
    if (![eventType isEqualToString:kSalesforceEvent]) {
        objectName = kServicemaxEventObject;
    }
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldName:kobjectApiName operatorType:SQLOperatorEqual andFieldValue:objectName];
    
    DBCriteria * criteria2 = [[DBCriteria alloc] initWithFieldName:ktype operatorType:SQLOperatorEqual andFieldValue:kProcessTypeStandAloneCreate];
    
    id <SFProcessDAO> processTypeService = [FactoryDAO serviceByServiceType:ServiceTypeProcess];
    
    NSMutableArray *processArray = (NSMutableArray *)[processTypeService fetchSFProcessInfoByFields:nil andCriteria:[NSArray arrayWithObjects:criteria1,criteria2 ,nil] andExpression:nil];
    
    
    if ([processArray count]!=0)
    {
        SFProcessModel *processModel = [processArray objectAtIndex:0];
        
        PageEditViewController *editViewController = [[PageEditViewController alloc]initWithProcessId:processModel.sfID andObjectName:processModel.objectApiName];
        editViewController.editViewControllerDelegate = self;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:editViewController];
        [self.navigationController presentViewController:navigationController animated:YES completion:^{}];
        
    }
    //HS added 23 Jan to fix issue
    else
    {
        //[self.addEventBtn setEnabled:NO];
    }
    
    
    
    
}

#pragma mark --------Wizard Delegate Method---------
//Actions Wizard Delegate method to handle process selction for Action
- (void)editProcessTapped:(NSString*)processId
{
    //load edit page
    
    SFObjectModel *objectModel =  [self getObjectNameForSelectedEvent:self.selectedEvent];
    NSString *recordId  = nil;
    //HS issue Fix :013140
    if (objectModel == nil)
    {
        objectModel = [SFObjectModel new];
        objectModel.objectName = self.selectedEvent.eventTableName;
        recordId = self.selectedEvent.localID;
        
    }
    else
    {
        recordId = [SFMPageHelper getLocalIdForSFID:self.selectedEvent.whatId objectName:objectModel.objectName];
        
    }
    
    
    SFMPageViewManager *viewPageManager = [[SFMPageViewManager alloc]initWithObjectName:objectModel.objectName recordId:recordId];
    
    NSString *processType = [viewPageManager getProcessTypeForProcessId:processId];
    
    if ([processType isEqualToString:kProcessTypeOutputDocument])
    {
        NSError *error = nil;
        BOOL isValidProcess = [viewPageManager isValidOPDocProcess:processId error:&error];
        if (isValidProcess)
        {
            [self loadOPDocViewController:processId objectName:objectModel.objectName recLocalId:recordId];
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
    
}

//HS 1 Jan added delegate to handle RefreshFromSalesforce
-(void)updateDODRecordFromSalesforce
{
    NSString *sfIDValue = self.selectedEvent.whatId;
    SFObjectModel *objectModel =  [self getObjectNameForSelectedEvent:self.selectedEvent];

    NSString *objectName = objectModel.objectName;
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
//HS 1 Jan ends here

-(void)rescheduleEvent
{
    self.selectedEvent = [[SMXDateManager sharedManager] selectedEvent];
       [viewCalendarDay rescheduleEvent:self.selectedEvent];

    
}


- (void)loadOPDocViewController:(NSString *)processId objectName:(NSString*)objName recLocalId:(NSString*)recLocId
{
    SFProcessService* processSrvc = (SFProcessService*)[FactoryDAO serviceByServiceType:ServiceTypeProcess];
    
    SFProcessModel *processModel = nil;
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:@"sfID" operatorType:SQLOperatorEqual andFieldValue:processId];
    
    if ([processSrvc conformsToProtocol:@protocol(SFProcessDAO)])
        processModel = [processSrvc getSFProcessInfo:criteria];
    
    OPDocViewController *sfmopdoc = [[OPDocViewController alloc] initWithNibName:@"OPDocViewController"
                                                                          bundle:nil
                                                                       forObject:objName
                                                                     forRecordId:recLocId
                                                                      andLocalId:recLocId
                                                                    andProcessId:processModel.processId
                                                                  andProcessSFId:processModel.sfID];
    
    NSString *field = [SFMPageHelper getNameFieldForObject:objName];
    
    id<TransactionObjectDAO> service = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    TransactionObjectModel *model = [service getDataForObject:objName fields:@[field] recordId:recLocId];
    NSString *nameFieldValue = [model valueForField:field];
    
    sfmopdoc.opdocTitleString = nameFieldValue;
    sfmopdoc.modalPresentationStyle = UIModalPresentationFullScreen;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:sfmopdoc];
    navController.delegate = sfmopdoc;
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    navController.navigationBar.hidden = NO;
    navController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#FF6633"];
    navController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)loadViewControllerForProcessId:(NSString *)processId andProcessType:(NSString *)processType{
    
    PageEditViewController *editViewController = nil;
    SFObjectModel *objectModel =  [self getObjectNameForSelectedEvent:self.selectedEvent];
    NSString *recordId  = nil;
    //HS issue Fix :013140
    if (objectModel == nil)
    {
        objectModel = [SFObjectModel new];
        objectModel.objectName = self.selectedEvent.eventTableName;
        recordId = self.selectedEvent.localID;
        
    }
    else
    {
        recordId = [SFMPageHelper getLocalIdForSFID:self.selectedEvent.whatId objectName:objectModel.objectName];
        
    }
    
    if ([processType isEqualToString:kProcessTypeStandAloneEdit]) {
        
        //NSString *recordId = [SFMPageHelper getLocalIdForSFID:self.selectedEvent.whatId objectName:objectModel.objectName];
        
        editViewController = [[PageEditViewController alloc] initWithProcessId:processId withObjectName:objectModel.objectName andRecordId:recordId];
    }
    else if ([processType isEqualToString:kProcessTypeSRCToTargetAll]) {
        
        //NSString *recordId = [SFMPageHelper getLocalIdForSFID:self.selectedEvent.whatId objectName:objectModel.objectName];
        
        editViewController = [[PageEditViewController alloc] initWithProcessId:processId sourceObjectName:objectModel.objectName andSourceRecordId:recordId];
    }
    if ([processType isEqualToString:kProcessTypeStandAloneCreate]) {
        
        editViewController = [[PageEditViewController alloc] initWithProcessId:processId andObjectName:nil];
    }
    else if ([processType isEqualToString:kProcessTypeSRCToTargetChild]) {
        
        //NSString *recordId = [SFMPageHelper getLocalIdForSFID:self.selectedEvent.whatId objectName:objectModel.objectName];
        editViewController = [[PageEditViewController alloc] initWithProcessIdForSTC:processId withObjectName:objectModel.objectName andRecordId:recordId];
    }
    
    if (editViewController != nil) {
        editViewController.editViewControllerDelegate = self;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:editViewController];
        [self.navigationController presentViewController:navigationController animated:YES completion:^{}];
    }
}

- (void)viewProcessTapped:(SFProcessModel*)sfProcess
{
    if (self.addEventBtn)
    {
        [self.addEventBtn removeFromSuperview];
        self.addEventBtn = nil;
    }
    SFObjectModel *objectModel =  [self getObjectNameForSelectedEvent:self.selectedEvent];
    NSString *recordId  = nil;
    //HS issue Fix :013140
    if (objectModel == nil)
    {
        objectModel = [SFObjectModel new];
        objectModel.objectName = self.selectedEvent.eventTableName;
        recordId = self.selectedEvent.localID;
    }
    else
    {
        recordId = [SFMPageHelper getLocalIdForSFID:self.selectedEvent.whatId objectName:objectModel.objectName];
        
    }
    SFMPageViewController *pageViewController = [[SFMPageViewController alloc]init];
    SFMPageViewManager *pageManager = [[SFMPageViewManager alloc] initWithObjectName:objectModel.objectName recordId:recordId processSFId:sfProcess.sfID];
                                           NSError *error = nil;
        BOOL isValidProcess = [pageManager isValidProcess:pageManager.processId objectName:nil recordId:nil error:&error];
    if (isValidProcess) {
        pageViewController.sfmPageView = [pageManager sfmPageView];
        //UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pageViewController];
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = [UIColor navBarBG]; //Only for iOS7.0 and more than 7.0
        self.navigationController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
       // pageViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[[TagManager sharedInstance] tagByName:kTagCancelButton] style:UIBarButtonItemStyleDone target:pageViewController action:@selector(cancelButtonClicked:)];
        
        //[self setTextAttributesForBarButtonItem:self.navigationController.navigationItem.leftBarButtonItem];
        [self.navigationController pushViewController:pageViewController animated:NO];
        //[self.navigationController presentViewController:navigationController animated:YES completion:^{}];
        self.tempViewController.shouldShowTroubleShooting = NO;
      
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
- (void)setTextAttributesForBarButtonItem:(UIBarButtonItem*)barButtonItem
{
    [barButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIColor whiteColor],NSForegroundColorAttributeName,
                                           [UIFont fontWithName:kHelveticaNeueLight size:kFontSize16], NSFontAttributeName, nil] forState:UIControlStateNormal];
}

#pragma mark --------Wizard Delegate Method ends here---------

-(void)hideCalender:(id)sender{
    [monthCalender.view removeFromSuperview];
    monthCalender=nil;
    [grayCalenderBkView removeFromSuperview];
    grayCalenderBkView=nil;
}
-(void)removeCalender
{
    if (grayCalenderBkView!=nil) {
        [monthCalender.view removeFromSuperview];
        monthCalender=nil;
        [grayCalenderBkView removeFromSuperview];
        grayCalenderBkView=nil;
    }
}
-(void)leftactionButtonClicked:(id)sender{
    
}
- (void) showDayCalender:(NSNotification *) notification
{
    cSegmentedControl.selectedSegmentIndex = 0;
    [self buttonYearMonthWeekDayAction:cSegmentedControl.selectedSegmentIndex];
}
/*Here we are loading dayview*/
- (void) showDayCalender
{
    cSegmentedControl.selectedSegmentIndex = 0;
    [self buttonYearMonthWeekDayAction:cSegmentedControl.selectedSegmentIndex];
}

- (void) leftButtonTextChange:(NSNotification *) notification
{
    NSDate *date= [notification object];

    [self setMonthAndYearValue:date];


}
- (void)leftButtonTextChangeOnDateChange:(NSDate *) date
{
    
    [self setMonthAndYearValue:date];

}
- (void) leftButtonTextChangeWith:(NSDate *) date
{
    [self setMonthAndYearValue:date];
}

-(void)setMonthAndYearValue:(NSDate *)date
{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *lComponent = [cal components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSString *monthName = [CalenderHelper getTagValueForMonth:lComponent.month-1];
    NSString *year = [NSString stringWithFormat:@"%ld", (long)lComponent.year];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    
//    dateFormatter.dateFormat=@"YYYY";
    [leftButton setAttributedTitle:[self getString:monthName year:[year capitalizedString]] forState:UIControlStateNormal];
    [leftButton setAttributedTitle:[self getStringHighlighted:monthName year:[year capitalizedString]] forState:UIControlStateHighlighted];
    [leftButton sizeToFit];
    leftButton.imageEdgeInsets = UIEdgeInsetsMake(7, leftButton.titleLabel.frame.size.width+3, 0, -leftButton.titleLabel.frame.size.width);

}

#pragma mark - Linked SFM
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
#pragma mark - Refresh Event
- (void)refreshEventInCalendarView
{
    [self performSelectorInBackground:@selector(fetchEventsFromDb) withObject:nil];
}

#pragma mark - End

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kConfigSyncStatusNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kUpdateEventNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNetworkConnectionChanged
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpadteWebserviceData object:nil];
}
#pragma mark - End

+ (instancetype) sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initInstance];
    });
    return sharedInstance;
}

- (instancetype) initInstance {
    self = [super init];
    // Do any other initialisation stuff here
    // ...
    return self;
}
/* Load url from with parameters */
-(void)makeCustomUrlCall:(WizardComponentModel *)model{
    SFMPage *sfmPage = [self getSFMPageModel];
    if (sfmPage)
    {
        /* load url with params */
        SFMCustomActionHelper *customActionHelper=[[SFMCustomActionHelper alloc] initWithSFMPage:sfmPage wizardComponent:model];
        UIApplication *ourApplication = [UIApplication sharedApplication];
        NSString *string = [customActionHelper loadURL];
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
}
-(NSString *)removeSpaceFromUrl:(NSString *)url{
    if (url) {
        return [url stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    return @"";
}

/* Call webservice call from with parameters */
-(void)makeWebserviceCall:(WizardComponentModel *)model{
    SFMPage *sfmPage = [self getSFMPageModel];
    if (sfmPage)
    {
        SFMCustomActionWebServiceHelper *webserviceHelper=[[SFMCustomActionWebServiceHelper alloc] initWithSFMPage:sfmPage wizardComponent:model];
        [self addActivityAndLoadingLabel];
        [webserviceHelper performSelectorInBackground:@selector(initiateCustomWebServiceWithDelegate:) withObject:self];
    }
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

-(SFMPage*)getSFMPageModel
{
    //load edit page
    SFObjectModel *objectModel =  [self getObjectNameForSelectedEvent:self.selectedEvent];
    NSString *recordId  = nil;
    if (objectModel == nil)
    {
        objectModel = [SFObjectModel new];
        objectModel.objectName = self.selectedEvent.eventTableName;
        recordId = self.selectedEvent.localID;
    }
    else
    {
        recordId = [SFMPageHelper getLocalIdForSFID:self.selectedEvent.whatId objectName:objectModel.objectName];
    }
    SFMPageViewManager *viewPageManager = [[SFMPageViewManager alloc]initWithObjectName:objectModel.objectName recordId:recordId];
    SFMPage *sfmPage = viewPageManager.sfmPageView.sfmPage;
    NSError *error = nil;
    BOOL isValidProcess = [viewPageManager isValidProcess:viewPageManager.processId objectName:nil recordId:nil error:&error];
    if (isValidProcess)
    {
        return sfmPage;
    }
    else
    {
        AlertMessageHandler *alertHandler = [AlertMessageHandler sharedInstance];
        NSString * buttonLOC = [[TagManager sharedInstance] tagByName:kTagAlertErrorOk];
        
        [alertHandler showCustomMessage:[error localizedDescription] withDelegate:nil title:[[TagManager sharedInstance] tagByName:kTagAlertIpadError] cancelButtonTitle:nil andOtherButtonTitles:[[NSArray alloc] initWithObjects:buttonLOC, nil]];
        return nil;
    }
}
#pragma mark - Flow Delegate methods
- (void)flowStatus:(id)status
{
    [[CacheManager sharedInstance] clearCacheByKey:kCustomWebServiceAction];
    [self removeActivityAndLoadingLabel];
    if([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *st = (WebserviceResponseStatus*)status;
        switch (st.category)
        {
            case CategoryTypeCustomWebServiceCall:
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
-(void)showNoProcessAlert
{
//    //alert
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Action unavailable"
//                                                    message:@"The action cannot be completed due to a configuration error. Please contact your administrator."
//                                                   delegate:nil
//                                          cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]
//                                          otherButtonTitles:nil];
//    [alert show];
}

-(void)showDataSyncAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Custom Action"
                                                    message:@"Sync is In Progress. Try after sync completion."
                                                   delegate:nil
                                          cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]
                                          otherButtonTitles:nil];
    [alert show];
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
-(void)reloadWizardComponentActionAccordingToNetworkChangeNotification:(NSNotification *)notification{
    [self removeActivityAndLoadingLabel];
    if (self.tempViewController != nil) {
        [self.tempViewController reloadTableView];
    }
}

#pragma mark -
#pragma mark PRODUCTIQ

-(void)displayProductIQViewController;
{
    /*
    ProductIQHomeViewController *lProductIQcontroller = [[ProductIQHomeViewController alloc] initWithNibName:@"ProductIQHomeViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:lProductIQcontroller];
    navController.delegate = lProductIQcontroller;
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    navController.navigationBar.hidden = NO;
    navController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#FF6633"];
    navController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
    */
    
    
    ProductIQHomeViewController *lProductIQcontroller = [[ProductIQHomeViewController alloc] initWithNibName:@"ProductIQHomeViewController" bundle:nil];
    lProductIQcontroller.responseDictionary = [MessageHandler getMessageHandlerResponeDictionaryForSFMPage:self.viewPageManager.sfmPageView];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:lProductIQcontroller];
    navController.delegate = lProductIQcontroller;
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    navController.navigationBar.hidden = NO;
    navController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#FF6633"];
    navController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
    
}


@end
