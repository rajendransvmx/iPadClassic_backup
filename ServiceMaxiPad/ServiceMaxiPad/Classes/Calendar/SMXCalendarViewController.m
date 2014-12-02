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
#import "TransactionObjectModel.h"
#import "SFMPageViewController.h"
#import "SFMViewPageManager.h"
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

#define kLongFormat @"yyyy-MM-dd'T'HH:mm:ss.SSSSZ"
#define kLongFormatZulu @"yyyy-MM-dd'T'HH:mm:ss.SSSS'Z'"
#define kLongFormatStringFormat @"yyyy-MM-dd'T'HH:mm:ss.SSSSZZZZ"

#define NOTIFICATION_TYPE @"notification_Type"

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
@property (nonatomic, assign) UIDeviceOrientation cPreviousDeviceOrientation;
@property(nonatomic,retain)SMXEvent *selectedEvent;
@property (nonatomic, strong) SMActionSideBarViewController *mySideBar;
@property (nonatomic, strong) WizardViewController *tempViewController;
@property (nonatomic, strong) NSTimer *cTimeLineTimer;
@property (nonatomic, strong) UIButton *addEventBtn;
@property (nonatomic,strong) SMXCurrentDayButton *currentWeekButton;
@property (nonatomic, strong) NSTimeZone *cPreviousTimeZone;
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

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}




- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor navBarBG];
    self.navigationController.navigationBar.translucent = NO;
    
    [self customNavigationBarLayout];
    [self setTheNotifications];
   
    cPreviousTimeZone = [[NSTimeZone localTimeZone] copy];

    [self getNavigationBarHeight];
    [self performSelectorInBackground:@selector(fetchEventsFromDb) withObject:nil];
    [self buttonYearMonthWeekDayAction:0];
}

-(void)setTheNotifications
{
    //TODO: Work on Removing the Notifications and replacing them with delegates. BSP
    
    [self addObserver:self selector:@selector(dataSyncFinished:) withName:kDataSyncStatusNotification AndObject:nil];
    [self addObserver:self selector:@selector(configSyncFinished:) withName:kConfigSyncStatusNotification AndObject:nil];
    
    
    [self addObserver:self selector:@selector(eventDisplayReset:) withName:EVENT_DISPLAY_RESET AndObject:nil];
    [self addObserver:self selector:@selector(leftButtonTextChange:) withName:DATE_MONTH_TEXT_NOTIFICATION AndObject:nil];
    [self addObserver:self selector:@selector(showDayCalender:) withName:SHOW_DAY_CALENDAR AndObject:nil];
    [self addObserver:self selector:@selector(removeCalender) withName:CALENDER_VIEW_REMOVE AndObject:nil];
    [self addObserver:self selector:@selector(dateChanged:) withName:DATE_MANAGER_DATE_CHANGED AndObject:nil];
    [self addObserver:self selector:@selector(eventSelected:) withName:EVENT_CLICKED_WEEK AndObject:nil];
    [self addObserver:self selector:@selector(dayEventSelected:) withName:EVENT_CLICKED AndObject:nil];
    [self addObserver:self selector:@selector(reloadCalendarWeek:) withName:RELOAD_CALENDAR_WEEK AndObject:nil];
    [self addObserver:self selector:@selector(checkForTimeZoneChange:) withName:CHECK_FOR_TIMEZONE_CHANGE AndObject:nil];

}

-(void)notificationHandler:(NSNotification *)pNotitfication
{
    NSString *notificationType = [pNotitfication.userInfo objectForKey:NOTIFICATION_TYPE];
    
    if ([notificationType isEqualToString:EVENT_DISPLAY_RESET]) {
        [self eventDisplayReset:pNotitfication];
    }
    else if ([notificationType isEqualToString:DATE_MONTH_TEXT_NOTIFICATION]) {
        [self leftButtonTextChange:pNotitfication];
    }
    else if ([notificationType isEqualToString:SHOW_DAY_CALENDAR]) {
        [self showDayCalender:pNotitfication];
    }
    else if ([notificationType isEqualToString:CALENDER_VIEW_REMOVE]) {
//        [self removeCalender:pNotitfication];
    }
    else if ([notificationType isEqualToString:DATE_MANAGER_DATE_CHANGED]) {
        [self dateChanged:pNotitfication];
    }
    else if ([notificationType isEqualToString:EVENT_CLICKED_WEEK]) {
        [self eventSelected:pNotitfication];
    }
    else if ([notificationType isEqualToString:EVENT_CLICKED]) {
        [self dayEventSelected:pNotitfication];
    }
    else if ([notificationType isEqualToString:RELOAD_CALENDAR_WEEK]) {
        [self reloadCalendarWeek:pNotitfication];
    }
    else if ([notificationType isEqualToString:CHECK_FOR_TIMEZONE_CHANGE]) {
        [self checkForTimeZoneChange:pNotitfication];
    }
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
    SyncManager *lSyncManager = (SyncManager *) pNotification.object;
    
//    BOOL syncStatus = [lSyncManager syncInProgress];
    BOOL syncStatus = [lSyncManager getSyncStatusFor:SyncTypeData];

    if(syncStatus)
    {
        [self eventDisplayReset:nil];
        //[self performSelectorInBackground:@selector(eventDisplayReset:) withObject:nil];
    }
    //[self loadWizardData];
    [self performSelectorInBackground:@selector(loadWizardData) withObject:nil];
    
}

- (void)configSyncFinished:(NSNotification*)notification
{
    SyncProgressDetailModel *syncProgressDetailModel = [[notification userInfo]objectForKey:@"syncstatus"];
    SyncStatus status = syncProgressDetailModel.syncStatus;
    if (status == SyncStatusSuccess) {
        [self loadWizardData];
        
    }
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
//    NSLog(@"event Selected %@",pNotification.object);
//    NSLog(@"userinfo %@",pNotification.userInfo);

    //SMXBlueButton *_button=pNotification.object;
    
    SFMViewPageManager *pageManager;
    SFMPageViewController *pageViewController = [[SFMPageViewController alloc]init];
    
    if(pNotification.userInfo)
    {
        pageManager = [[SFMViewPageManager alloc] initWithObjectName:[pNotification.userInfo objectForKey:@"objectName"] recordId:[pNotification.userInfo objectForKey:@"contactID"]];
    }
    else
    {
        SMXEvent *eventData =pNotification.object;
        TransactionObjectModel *model = [CalenderHelper getRecordForSalesforceId:eventData.whatId];

        pageManager = [[SFMViewPageManager alloc] initWithObjectName:[model objectAPIName] recordId:[[model getFieldValueDictionary] objectForKey:@"localId"]];
    }
    

    NSError *error = nil;
    BOOL isValidProcess = [pageManager isValidProcess:pageManager.processId error:&error];
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

-(void)dayEventSelected:(NSNotification *)pNotification
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
    [viewCalendarMonth setDictEvents:dictEvents];
    [viewCalendarWeek setDictEvents:dictEvents];
    [viewCalendarDay setDictEvents:dictEvents];
    
    [self resetAllViews];
    
}

-(void)resetAllViews
{
    [viewCalendarMonth invalidateLayout];
    [viewCalendarWeek invalidateLayout];
    [viewCalendarDay invalidateLayout];
}

- (void)loadWizardData
{
    if (self.selectedEvent)
    {
        SFObjectModel *objectModel =  [self getObjectNameForSelectedEvent:self.selectedEvent];
        
        NSString *recordId = [SFMPageHelper getLocalIdForSFID:self.selectedEvent.whatId objectName:objectModel.objectName];
        
        SFWizardService *wizardService = [[SFWizardService alloc]init];
        
        SFMWizardComponentService *wizardComponentService = [[SFMWizardComponentService alloc]init];
        
        NSMutableArray *allWizards = [wizardService getWizardsForObjcetName:objectModel.objectName andRecordId:recordId];
        [wizardComponentService getWizardComponentsForWizards:allWizards recordId:recordId];
        
        /*If wizard step is not there for a wizard then it should not be shown in the tableView*/
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

    CalenderHelper *lCalenderHelper = [[CalenderHelper alloc] init];
    self.cEventListArray = [lCalenderHelper getEventDetailsForTheDay];
    [self setEvents:self.cEventListArray];
    [self performSelectorOnMainThread:@selector(refreshTheUI) withObject:nil waitUntilDone:YES];

}

-(void)setEvents:(NSArray *) lEventArray
{
    NSMutableArray *lEventCollectionArray = [[NSMutableArray alloc] init];
    for (CalenderEventObjectModel *lModel in lEventArray) {
        
        SMXEvent *lEvent = [[SMXEvent alloc] initWithCalendarModel:lModel];

        [lEventCollectionArray addObject:lEvent];
    }
    self.arrayWithEvents = [NSMutableArray arrayWithArray:lEventCollectionArray];

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    if (!boolDidLoad) {
        boolDidLoad = YES;
        [self buttonTodayAction:nil];
    }
    
    [self rightBarButtonItem];
    [self leftBarButtonItemAction];
    [self checkOrientationAndSetNavButtons];
    
    if (cSegmentedControl.selectedSegmentIndex == 0)
    {
        [self addEventForDay];
        
        [viewCalendarDay refreshDetailView];
    }
     
    UIDeviceOrientation lCurrentDeviceOrientation = [[UIDevice currentDevice] orientation];

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
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components: NSSecondCalendarUnit fromDate:[NSDate date]];
    NSInteger second = [components second];
    NSTimeInterval tillNextMinute = (60 - second) % 60;
    
    [self performSelector:@selector(timerForResetingTheLine) withObject:nil afterDelay:tillNextMinute];

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
    theFrame.origin.x = theFrame.origin.x -theFrame.size.width - 5;
    self.addEventBtn.frame = theFrame;
    NSString *title = [NSString stringWithFormat:@"+ %@",[[TagManager sharedInstance]tagByName:kTag_Add]];
    [self.addEventBtn setTitle:title forState:UIControlStateNormal];
    [self.addEventBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.addEventBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
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
    
    cPreviousDeviceOrientation = [[UIDevice currentDevice] orientation];
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
}

- (void)updateLabelWithMonthAndYear {
    
    NSDate *ldate = [[SMXDateManager sharedManager] currentDate];
    NSDateComponents *comp = [NSDate componentsOfDate:ldate];
    NSString *string = boolYearViewIsShowing ? [NSString stringWithFormat:@"%li", (long)comp.year] : [NSString stringWithFormat:@"%@ %li", [arrayMonthName objectAtIndex:comp.month-1], (long)comp.year];
    [labelWithMonthAndYear setText:string];
}

#pragma mark - Init dictEvents

- (void)setArrayWithEvents:(NSMutableArray *)_arrayWithEvents {
    arrayWithEvents = _arrayWithEvents;
    dictEvents = [NSMutableDictionary new];
    for (SMXEvent *event in _arrayWithEvents) {
        NSDateComponents *comp = [NSDate componentsOfDate:event.ActivityDateDay];
        NSDate *newDate = [NSDate dateWithYear:comp.year month:comp.month day:comp.day];
        NSMutableArray *array = [dictEvents objectForKey:newDate];
        if (!array) {
            array = [NSMutableArray new];
            [dictEvents setObject:array forKey:newDate];
        }
        [array addObject:event];
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
        self.previousSelectedSegment = self.cSegmentedControl.selectedSegmentIndex;
        if (!self.navigationItem.rightBarButtonItem.enabled) {
            [self rightBarButtonItem];
        }
        if (!self.navigationItem.leftBarButtonItem.enabled && segment.selectedSegmentIndex != 0)
        {
            [self leftBarButtonItemAction];
        }
        leftButton.hidden=NO;
        [self checkOrientationAndSetNavButtons];
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
    long index = selectedIndex;
    [self removeUnNecessarySubviews];
    if (index == 0) {
        
        [self setUpDayCalendarView];
        [self addEventForDay];

        rightButton.tag=index;
        leftButton.tag=0;
        [rightButton setTitle:[[TagManager sharedInstance] tagByName:kTagActions] forState:UIControlStateNormal];
        if (!self.selectedEvent)
        {
            [rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
      
    }
    else if (index == 1) {
        
        [self setUpWeekCalendarView];
        [self.addEventBtn removeFromSuperview];
        self.addEventBtn = nil;
        rightButton.tag=1;
        leftButton.tag=1;
       
        [rightButton setTitle:[NSString stringWithFormat:@"+ %@",[[TagManager sharedInstance]tagByName:kTag_AddEvent]] forState:UIControlStateNormal]; //Fix for Issue 013034
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //[rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
    }
    else if (index == 2){

        [self setUpMonthCalendarView];

        [self.addEventBtn removeFromSuperview];
        self.addEventBtn = nil;
        
        rightButton.tag=index;
        leftButton.tag=2;
        //[rightButton setTitle:[[TagManager sharedInstance] tagByName:kTagActions] forState:UIControlStateNormal];
        [rightButton setTitle:[NSString stringWithFormat:@"+ %@",[[TagManager sharedInstance]tagByName:kTag_AddEvent]] forState:UIControlStateNormal];

        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        // 15/09/2014 Code for MAP Pending.
    }
    else if (index == 3){
       // self.addEventBtn.hidden = YES;
        
        [self.addEventBtn removeFromSuperview];
        self.addEventBtn = nil;

        rightButton.tag=index;
        leftButton.tag=3;
        [rightButton setTitle:@" " forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        return;  // 15/09/2014 Code for MAP Pending.
    }
    [self.view bringSubviewToFront:[self.arrayCalendars objectAtIndex:index]];
    
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
    }else if(cSegmentedControl.selectedSegmentIndex == 1){
        [self leftButtonTextChangeWith:[[SMXDateManager sharedManager] currentDate]];
        [leftButton setImage:[UIImage imageNamed:@"down-arrow-white.png"] forState:UIControlStateNormal];
        [leftButton sizeToFit];
        leftButton.imageEdgeInsets = UIEdgeInsetsMake(7, leftButton.titleLabel.frame.size.width+3, 0, -leftButton.titleLabel.frame.size.width);
    }else if(cSegmentedControl.selectedSegmentIndex == 2){
        [self leftButtonTextChangeWith:[[SMXDateManager sharedManager] currentDate]];
        [leftButton setImage:[UIImage imageNamed:@"down-arrow-white.png"] forState:UIControlStateNormal];
        [leftButton sizeToFit];
        leftButton.imageEdgeInsets = UIEdgeInsetsMake(7, leftButton.titleLabel.frame.size.width+3, 0, -leftButton.titleLabel.frame.size.width);
    }else if(cSegmentedControl.selectedSegmentIndex == 3){
        [self leftButtonTextChangeWith:[[SMXDateManager sharedManager] currentDate]];
        [leftButton setImage:[UIImage imageNamed:@"down-arrow-white.png"] forState:UIControlStateNormal];
        leftButton.imageEdgeInsets = UIEdgeInsetsMake(7, leftButton.titleLabel.frame.size.width+3, 0, -leftButton.titleLabel.frame.size.width);
        [leftButton sizeToFit];
    }
    
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
        }
        self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithCustomView:rightButton];
        self.navigationItem.rightBarButtonItem.enabled = YES;
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
        [ self.navigationItem.leftBarButtonItem setBackgroundImage:[UIImage imageNamed:@"down-arrow-white.png"] forState:UIControlStateNormal barMetrics:nil];
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
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldName:kobjectApiName operatorType:SQLOperatorEqual andFieldValue:kEventObject];
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
    
    
    

    
}

#pragma mark --------Wizard Delegate Method---------
//Actions Wizard Delegate method to handle process selction for Action
- (void)editProcessTapped:(NSString*)processId
{
    //load edit page
    
    SFObjectModel *objectModel =  [self getObjectNameForSelectedEvent:self.selectedEvent];
    
    NSString *recordId = [SFMPageHelper getLocalIdForSFID:self.selectedEvent.whatId objectName:objectModel.objectName];
    
    SFMViewPageManager *viewPageManager = [[SFMViewPageManager alloc]initWithObjectName:objectModel.objectName recordId:recordId];
    
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
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)loadViewControllerForProcessId:(NSString *)processId andProcessType:(NSString *)processType{
    
    PageEditViewController *editViewController = nil;
    SFObjectModel *objectModel =  [self getObjectNameForSelectedEvent:self.selectedEvent];
    
    if ([processType isEqualToString:kProcessTypeStandAloneEdit]) {
        
        NSString *recordId = [SFMPageHelper getLocalIdForSFID:self.selectedEvent.whatId objectName:objectModel.objectName];
        
        editViewController = [[PageEditViewController alloc] initWithProcessId:processId withObjectName:objectModel.objectName andRecordId:recordId];
    }
    else if ([processType isEqualToString:kProcessTypeSRCToTargetAll]) {
        
        NSString *recordId = [SFMPageHelper getLocalIdForSFID:self.selectedEvent.whatId objectName:objectModel.objectName];
        
        editViewController = [[PageEditViewController alloc] initWithProcessId:processId sourceObjectName:objectModel.objectName andSourceRecordId:recordId];
    }
    if ([processType isEqualToString:kProcessTypeStandAloneCreate]) {
        
        editViewController = [[PageEditViewController alloc] initWithProcessId:processId andObjectName:nil];
    }
    else if ([processType isEqualToString:kProcessTypeSRCToTargetChild]) {
        
        NSString *recordId = [SFMPageHelper getLocalIdForSFID:self.selectedEvent.whatId objectName:objectModel.objectName];
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
    NSString *recordId = [SFMPageHelper getLocalIdForSFID:self.selectedEvent.whatId objectName:objectModel.objectName];
        SFMPageViewController *pageViewController = [[SFMPageViewController alloc]init];
    SFMViewPageManager *pageManager = [[SFMViewPageManager alloc] initWithObjectName:objectModel.objectName recordId:recordId processSFId:sfProcess.sfID];
                                           NSError *error = nil;
        BOOL isValidProcess = [pageManager isValidProcess:pageManager.processId error:&error];
    if (isValidProcess) {
        pageViewController.sfmPageView = [pageManager sfmPageView];
        //UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pageViewController];
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = [UIColor navBarBG]; //Only for iOS7.0 and more than 7.0
        
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

- (void) leftButtonTextChange:(NSNotification *) notification
{
    NSDate *date= [notification object];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMdd";
    dateFormatter.dateFormat=@"MMMM";
    NSString * monthString = [[dateFormatter stringFromDate:date] capitalizedString];
    dateFormatter.dateFormat=@"YYYY";
    [leftButton setAttributedTitle:[self getString:monthString year:[[dateFormatter stringFromDate:date] capitalizedString]] forState:UIControlStateNormal];
    [leftButton setAttributedTitle:[self getStringHighlighted:monthString year:[[dateFormatter stringFromDate:date] capitalizedString]] forState:UIControlStateHighlighted];
    [leftButton sizeToFit];
    leftButton.imageEdgeInsets = UIEdgeInsetsMake(7, leftButton.titleLabel.frame.size.width+3, 0, -leftButton.titleLabel.frame.size.width);

}
- (void) leftButtonTextChangeWith:(NSDate *) date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMdd";
    dateFormatter.dateFormat=@"MMMM";
    NSString * monthString = [[dateFormatter stringFromDate:date] capitalizedString];
    dateFormatter.dateFormat=@"YYYY";
    [leftButton setAttributedTitle:[self getString:monthString year:[[dateFormatter stringFromDate:date] capitalizedString]] forState:UIControlStateNormal];
    [leftButton setAttributedTitle:[self getStringHighlighted:monthString year:[[dateFormatter stringFromDate:date] capitalizedString]] forState:UIControlStateHighlighted];
    [leftButton sizeToFit];
    leftButton.imageEdgeInsets = UIEdgeInsetsMake(7, leftButton.titleLabel.frame.size.width+3, 0, -leftButton.titleLabel.frame.size.width);
}

#pragma mark - Linked SFM
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EVENT_CLICKED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EVENT_CLICKED_WEEK object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kConfigSyncStatusNotification object:nil];
}
#pragma mark - End


@end
