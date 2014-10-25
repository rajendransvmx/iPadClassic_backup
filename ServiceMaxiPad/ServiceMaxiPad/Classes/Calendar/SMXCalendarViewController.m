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

@interface SMXCalendarViewController () <SMXButtonAddEventWithPopoverProtocol, SMXMonthCalendarViewProtocol, SMXWeekCalendarViewProtocol, SMXDayCalendarViewProtocol>
@property (nonatomic) BOOL boolDidLoad;
@property (nonatomic) BOOL boolYearViewIsShowing;
@property (nonatomic, strong) NSMutableDictionary *dictEvents;
@property (nonatomic, strong) UILabel *labelWithMonthAndYear;
@property (nonatomic, strong) NSArray *arrayButtons;
@property (nonatomic, strong) NSArray *arrayCalendars;
@property (nonatomic, strong) SMXEditEventPopoverController *popoverControllerEditar;
//@property (nonatomic, strong) SMXYearCalendarView *viewCalendarYear;
@property (nonatomic, strong) SMXMonthCalendarView *viewCalendarMonth;
@property (nonatomic, strong) SMXWeekCalendarView *viewCalendarWeek;
@property (nonatomic, strong) SMXDayCalendarView *viewCalendarDay;
//@property (nonatomic, strong) UIBarButtonItem *actionButton;
//@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong) UISegmentedControl *cSegmentedControl;
@property (nonatomic, strong) UIButton *leftButton;
//@property (nonatomic, strong) UILabel *leftLable;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic,strong) UIButton *grayCalenderBkView;
@property (nonatomic, strong) MapViewController *mapViewController;
@property (nonatomic, readwrite) NSInteger previousSelectedSegment;
@end

@implementation SMXCalendarViewController

#pragma mark - Synthesize

@synthesize boolDidLoad;
@synthesize boolYearViewIsShowing;
@synthesize protocol;
@synthesize arrayWithEvents;
@synthesize dictEvents;
@synthesize labelWithMonthAndYear;
@synthesize arrayButtons;
@synthesize arrayCalendars;
@synthesize popoverControllerEditar;
//@synthesize viewCalendarYear;
@synthesize viewCalendarMonth;
@synthesize viewCalendarWeek;
@synthesize viewCalendarDay;
@synthesize cSegmentedControl;
//@synthesize actionButton;
//@synthesize leftBarButtonItem;
//@synthesize leftLable;
@synthesize leftButton;
@synthesize rightButton;
@synthesize monthCalender;
@synthesize grayCalenderBkView;
@synthesize cEventListArray;

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadEvents
{
    SMXEvent *event1 = [[SMXEvent alloc] init];
    [event1 setStringCustomerName: @"Concord CAT Scans"];
    [event1 setNumCustomerID:@1];
    [event1 setActivityDateDay:[NSDate dateWithYear:[NSDate componentsOfCurrentDate].year month:[NSDate componentsOfCurrentDate].month day:[NSDate componentsOfCurrentDate].day]];
    [event1 setDateTimeBegin:[NSDate dateWithHour:06 min:00]];
    [event1 setDateTimeEnd:[NSDate dateWithHour:8 min:13]];
    [event1 setArrayWithGuests:[NSMutableArray arrayWithArray:@[@[@111, @"Guest 2", @"email2@email.com"], @[@111, @"Guest 4", @"email4@email.com"], @[@111, @"Guest 5", @"email5@email.com"], @[@111, @"Guest 7", @"email7@email.com"]]]];
    
    SMXEvent *event2 = [SMXEvent new];
    [event2 setStringCustomerName: @"Good Samaritan Hospital"];
    [event2 setNumCustomerID:@2];
    [event2 setActivityDateDay:[NSDate dateWithYear:[NSDate componentsOfCurrentDate].year month:[NSDate componentsOfCurrentDate].month day:[NSDate componentsOfCurrentDate].day]];
    [event2 setDateTimeBegin:[NSDate dateWithHour:9 min:15]];
    [event2 setDateTimeEnd:[NSDate dateWithHour:12 min:38]];
    [event2 setArrayWithGuests:[NSMutableArray arrayWithArray:@[@[@111, @"Guest 2", @"email2@email.com"], @[@111, @"Guest 4", @"email4@email.com"], @[@111, @"Guest 5", @"email5@email.com"], @[@111, @"Guest 7", @"email7@email.com"]]]];
    
    SMXEvent *event3 = [SMXEvent new];
    [event3 setStringCustomerName: @"Concord CAT Scans"];
    [event3 setNumCustomerID:@3];
    [event3 setActivityDateDay:[NSDate dateWithYear:[NSDate componentsOfCurrentDate].year month:[NSDate componentsOfCurrentDate].month day:[NSDate componentsOfCurrentDate].day]];
    [event3 setDateTimeBegin:[NSDate dateWithHour:16 min:00]];
    [event3 setDateTimeEnd:[NSDate dateWithHour:17 min:13]];
    [event3 setArrayWithGuests:[NSMutableArray arrayWithArray:@[@[@111, @"Guest 2", @"email2@email.com"], @[@111, @"Guest 4", @"email4@email.com"], @[@111, @"Guest 5", @"email5@email.com"], @[@111, @"Guest 7", @"email7@email.com"]]]];
    
    SMXEvent *event4 = [SMXEvent new];
    [event4 setStringCustomerName: @"Beta Test General"];
    [event4 setNumCustomerID:@4];
    [event4 setActivityDateDay:[NSDate dateWithYear:[NSDate componentsOfCurrentDate].year month:[NSDate componentsOfCurrentDate].month day:[NSDate componentsOfCurrentDate].day]];
    [event4 setDateTimeBegin:[NSDate dateWithHour:18 min:00]];
    [event4 setDateTimeEnd:[NSDate dateWithHour:19 min:13]];
    [event4 setArrayWithGuests:[NSMutableArray arrayWithArray:@[@[@111, @"Guest 2", @"email2@email.com"], @[@111, @"Guest 4", @"email4@email.com"], @[@111, @"Guest 5", @"email5@email.com"], @[@111, @"Guest 7", @"email7@email.com"]]]];
    
    SMXEvent *event5 = [SMXEvent new];
    [event5 setStringCustomerName: @"Fremont Free Clinic"];
    [event5 setNumCustomerID:@5];
    [event5 setActivityDateDay:[NSDate dateWithYear:[NSDate componentsOfCurrentDate].year month:[NSDate componentsOfCurrentDate].month day:[NSDate componentsOfCurrentDate].day]];
    [event5 setDateTimeBegin:[NSDate dateWithHour:20 min:00]];
    [event5 setDateTimeEnd:[NSDate dateWithHour:21 min:13]];
    [event5 setArrayWithGuests:[NSMutableArray arrayWithArray:@[@[@111, @"Guest 2", @"email2@email.com"], @[@111, @"Guest 4", @"email4@email.com"], @[@111, @"Guest 5", @"email5@email.com"], @[@111, @"Guest 7", @"email7@email.com"]]]];
    
    SMXEvent *event6 = [SMXEvent new];
    [event6 setStringCustomerName: @"Concord CAT Scans"];
    [event6 setNumCustomerID:@6];
    [event6 setActivityDateDay:[NSDate dateWithYear:[NSDate componentsOfCurrentDate].year month:[NSDate componentsOfCurrentDate].month day:25]];
    [event6 setDateTimeBegin:[NSDate dateWithHour:20 min:00]];
    [event6 setDateTimeEnd:[NSDate dateWithHour:21 min:13]];
    [event6 setArrayWithGuests:[NSMutableArray arrayWithArray:@[@[@111, @"Guest 2", @"email2@email.com"], @[@111, @"Guest 4", @"email4@email.com"], @[@111, @"Guest 5", @"email5@email.com"], @[@111, @"Guest 7", @"email7@email.com"]]]];
    
    SMXEvent *event7 = [SMXEvent new];
    [event7 setStringCustomerName: @"Beta Test General"];
    [event7 setNumCustomerID:@7];
    [event7 setActivityDateDay:[NSDate dateWithYear:[NSDate componentsOfCurrentDate].year month:[NSDate componentsOfCurrentDate].month day:1]];
    [event7 setDateTimeBegin:[NSDate dateWithHour:20 min:00]];
    [event7 setDateTimeEnd:[NSDate dateWithHour:21 min:13]];
    [event7 setArrayWithGuests:[NSMutableArray arrayWithArray:@[@[@111, @"Guest 2", @"email2@email.com"], @[@111, @"Guest 4", @"email4@email.com"], @[@111, @"Guest 5", @"email5@email.com"], @[@111, @"Guest 7", @"email7@email.com"]]]];
    
    SMXEvent *event8 = [SMXEvent new];
    [event8 setStringCustomerName: @"Good Samaritan Hospital"];
    [event8 setNumCustomerID:@8];
    [event8 setActivityDateDay:[NSDate dateWithYear:[NSDate componentsOfCurrentDate].year month:[NSDate componentsOfCurrentDate].month day:2]];
    [event8 setDateTimeBegin:[NSDate dateWithHour:20 min:00]];
    [event8 setDateTimeEnd:[NSDate dateWithHour:21 min:13]];
    [event8 setArrayWithGuests:[NSMutableArray arrayWithArray:@[@[@111, @"Guest 2", @"email2@email.com"], @[@111, @"Guest 4", @"email4@email.com"], @[@111, @"Guest 5", @"email5@email.com"], @[@111, @"Guest 7", @"email7@email.com"]]]];
    
    SMXEvent *event9 = [SMXEvent new];
    [event9 setStringCustomerName: @"event9 CAT Scans"];
    [event9 setNumCustomerID:@1];
    [event9 setActivityDateDay:[NSDate dateWithYear:[NSDate componentsOfCurrentDate].year month:[NSDate componentsOfCurrentDate].month day:[NSDate componentsOfCurrentDate].day]];
    [event9 setDateTimeBegin:[NSDate dateWithHour:06 min:00]];
    [event9 setDateTimeEnd:[NSDate dateWithHour:8 min:13]];
    [event9 setArrayWithGuests:[NSMutableArray arrayWithArray:@[@[@111, @"Guest 2", @"email2@email.com"], @[@111, @"Guest 4", @"email4@email.com"], @[@111, @"Guest 5", @"email5@email.com"], @[@111, @"Guest 7", @"email7@email.com"]]]];
    
    self.arrayWithEvents = [NSMutableArray arrayWithArray:@[event1, event2, event3, event4, event5, event6, event7, event8,event9]];
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
//    [self loadEvents];
    
    NSLog(@"Documents Directory%@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);

    [self fetchEventsFromDb];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventRescheduled:) name:EVENT_RESCHEDULED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftButtonTextChange:) name:DATE_MONTH_TEXT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDayCalender:) name:SHOW_DAY_CALENDAR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeCalender) name:CALENDER_VIEW_REMOVE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dateChanged:) name:DATE_MANAGER_DATE_CHANGED object:nil];
    [self addCalendars];
    [self buttonYearMonthWeekDayAction:[arrayButtons objectAtIndex:0]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventSelected:) name:EVENT_CLICKED_WEEK object:nil];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components: NSSecondCalendarUnit fromDate:[NSDate date]];
    NSInteger second = [components second];
    NSTimeInterval tillNextMinute = (60 - second) % 60;

    [NSTimer scheduledTimerWithTimeInterval:tillNextMinute
                                     target:self
                                   selector:@selector(resetTheCurrentTimeLine)
                                   userInfo:nil
                                    repeats:YES];

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
    NSLog(@"event Selected %@",pNotification.object);
    //SMXBlueButton *_button=pNotification.object;
    
    SMXEvent *eventData =pNotification.object;
    
    //  NSString *eventId = eventData.IDString;
    TransactionObjectModel *model = [CalenderHelper getRecordForSalesforceId:eventData.whatId];
    SFMPageViewController *pageViewController = [[SFMPageViewController alloc]init];
    SFMViewPageManager *pageManager = [[SFMViewPageManager alloc] initWithObjectName:[model objectAPIName] recordId:[[model getFieldValueDictionary] objectForKey:@"localId"]];
    
    NSError *error = nil;
    BOOL isValidProcess = [pageManager isValidProcess:pageManager.processId error:&error];
    if (isValidProcess) {
        pageViewController.sfmPageView = [pageManager sfmPageView];
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


-(void)eventRescheduled:(NSNotification *)notification
{
    [self fetchEventsFromDb];
    
    [viewCalendarMonth setDictEvents:dictEvents];
    [viewCalendarWeek setDictEvents:dictEvents];
    [viewCalendarDay setDictEvents:dictEvents];
    
    [viewCalendarMonth invalidateLayout];
    [viewCalendarWeek invalidateLayout];
    [viewCalendarDay invalidateLayout];

    
}

-(void)fetchEventsFromDb
{

    CalenderHelper *lCalenderHelper = [[CalenderHelper alloc] init];
    self.cEventListArray = [lCalenderHelper getEventDetailsForTheDay];

    
    [self setEvents:self.cEventListArray];
    
}

-(void)setEvents:(NSArray *) lEventArray
{
    NSMutableArray *lEventCollectionArray = [[NSMutableArray alloc] init];
    for (CalenderEventObjectModel *lModel in lEventArray) {
        SMXEvent *lEvent = [[SMXEvent alloc] init];

        [lEvent setLocalID:lModel.localId];
        [lEvent setIDString:lModel.Id];
        
        [lEvent setStringCustomerName: lModel.subject];
        [lEvent setDescription:lModel.description];
        [lEvent setWhatId:lModel.WhatId];
        NSDateFormatter * lDF = [[NSDateFormatter alloc] init];
        [lDF setDateFormat: @"yyyy-MM-dd 00:00:00"];
        NSDate * lEventDate = [lDF dateFromString:lModel.activityDate];
        
        [lEvent setActivityDateDay:lEventDate];
        
        NSString *lStartDateTime = lModel.startDateTime;
        lStartDateTime = [lStartDateTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        lStartDateTime = [lStartDateTime stringByReplacingOccurrencesOfString:@".000Z" withString:@""];
        //8945
        lStartDateTime = [CalenderHelper localTimeFromGMT:lStartDateTime];
        lStartDateTime = [lStartDateTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        lStartDateTime = [lStartDateTime stringByReplacingOccurrencesOfString:@"Z" withString:@""];
        
        [lDF setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        NSDate * lEventStartDateTime = [lDF dateFromString:lStartDateTime];
        NSLog(@"lModel.startDateTime : %@ ==> lEventStartDateTime : %@", lModel.startDateTime, lEventStartDateTime);

        
        NSString *lEndDateTime = lModel.endDateTime;
        lEndDateTime = [lEndDateTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        lEndDateTime = [lEndDateTime stringByReplacingOccurrencesOfString:@".000Z" withString:@""];
        lEndDateTime = [CalenderHelper localTimeFromGMT:lEndDateTime];
        lEndDateTime = [lEndDateTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        lEndDateTime = [lEndDateTime stringByReplacingOccurrencesOfString:@"Z" withString:@""];
        
        NSDate * lEventEndDateTime = [lDF dateFromString:lEndDateTime];
        NSLog(@"lModel.endDateTime : %@ ==> lEventStartDateTime : %@", lModel.endDateTime, lEventEndDateTime);

        [lEvent setDateTimeBegin:lEventStartDateTime];
        [lEvent setDateTimeEnd:lEventEndDateTime];
        lEvent.cWorkOrderSummaryModel = lModel.cWorkOrderSummaryModel;
        [lEventCollectionArray addObject:lEvent];
    }
    
    
    
    // For testing for today.
    
   /* SMXEvent *event8 = [SMXEvent new];
    [event8 setStringCustomerName: @"event8 CAT Scans"];
    [event8 setNumCustomerID:@1];
    [event8 setActivityDateDay:[NSDate dateWithYear:[NSDate componentsOfCurrentDate].year month:[NSDate componentsOfCurrentDate].month day:[NSDate componentsOfCurrentDate].day]];
    [event8 setDateTimeBegin:[NSDate dateWithHour:13 min:00]];
    [event8 setDateTimeEnd:[NSDate dateWithHour:14 min:00]];
    [event8 setArrayWithGuests:[NSMutableArray arrayWithArray:@[@[@111, @"Guest 2", @"email2@email.com"], @[@111, @"Guest 4", @"email4@email.com"], @[@111, @"Guest 5", @"email5@email.com"], @[@111, @"Guest 7", @"email7@email.com"]]]];
    event8.description = @"The script uses a helper function cutHex() to check if the # character is present in the beginning of the input hexadecimal value. If so, the cutHex() function cuts off the # so that only the hexadecimal digits are left in the input value. We use the standard JavaScript method substring() to get the R, G, B (red, green, blue) hex substrings from the input hexadecimal value. Finally, the script parses the R, G, B values from hexadecimal string to number using the standard function parseInt(string,16); the second argument 16 specifies that the string must be parsed as a hexadecimal (base-16) value.";
    
    SMXEvent *event9 = [SMXEvent new];
    [event9 setStringCustomerName: @"event9 CAT Scans"];
    [event9 setNumCustomerID:@1];
    [event9 setLocalID:@"1234-4567-7890-1234"];
    [event9 setIDString:@"zaq123wsx"];
    [event9 setActivityDateDay:[NSDate dateWithYear:[NSDate componentsOfCurrentDate].year month:[NSDate componentsOfCurrentDate].month day:[NSDate componentsOfCurrentDate].day]];
    [event9 setDateTimeBegin:[NSDate dateWithHour:13 min:00]];
    [event9 setDateTimeEnd:[NSDate dateWithHour:14 min:00]];
    [event9 setArrayWithGuests:[NSMutableArray arrayWithArray:@[@[@111, @"Guest 2", @"email2@email.com"], @[@111, @"Guest 4", @"email4@email.com"], @[@111, @"Guest 5", @"email5@email.com"], @[@111, @"Guest 7", @"email7@email.com"]]]];
    
    SMXEvent *event10 = [SMXEvent new];
    [event10 setStringCustomerName: @"event10 CAT Scans"];
    [event10 setLocalID:@"4321-4567-7890-1234"];
    [event10 setIDString:@"qaz-zaq123wsx"];
    [event10 setActivityDateDay:[NSDate dateWithYear:[NSDate componentsOfCurrentDate].year month:[NSDate componentsOfCurrentDate].month day:[NSDate componentsOfCurrentDate].day]];
    [event10 setDateTimeBegin:[NSDate dateWithHour:13 min:00]];
    [event10 setDateTimeEnd:[NSDate dateWithHour:14 min:00]];
    [event10 setArrayWithGuests:[NSMutableArray arrayWithArray:@[@[@111, @"Guest 2", @"email2@email.com"], @[@111, @"Guest 4", @"email4@email.com"], @[@111, @"Guest 5", @"email5@email.com"], @[@111, @"Guest 7", @"email7@email.com"]]]];
    
    SMXEvent *event11 = [SMXEvent new];
    [event11 setStringCustomerName: @"event11 CAT Scans"];
    [event11 setNumCustomerID:@1];
    [event11 setActivityDateDay:[NSDate dateWithYear:[NSDate componentsOfCurrentDate].year month:[NSDate componentsOfCurrentDate].month day:[NSDate componentsOfCurrentDate].day]];
    [event11 setDateTimeBegin:[NSDate dateWithHour:15 min:00]];
    [event11 setDateTimeEnd:[NSDate dateWithHour:18 min:00]];
    [event11 setArrayWithGuests:[NSMutableArray arrayWithArray:@[@[@111, @"Guest 2", @"email2@email.com"], @[@111, @"Guest 4", @"email4@email.com"], @[@111, @"Guest 5", @"email5@email.com"], @[@111, @"Guest 7", @"email7@email.com"]]]];
    
    

    SMXEvent *event12 = [SMXEvent new];
    [event12 setStringCustomerName: @"event12 CAT Scans"];
    [event12 setNumCustomerID:@1];
    [event12 setActivityDateDay:[NSDate dateWithYear:[NSDate componentsOfCurrentDate].year month:[NSDate componentsOfCurrentDate].month day:[NSDate componentsOfCurrentDate].day]];
    [event12 setDateTimeBegin:[NSDate dateWithHour:15 min:00]];
    [event12 setDateTimeEnd:[NSDate dateWithHour:18 min:00]];
    [event12 setArrayWithGuests:[NSMutableArray arrayWithArray:@[@[@111, @"Guest 2", @"email2@email.com"], @[@111, @"Guest 4", @"email4@email.com"], @[@111, @"Guest 5", @"email5@email.com"], @[@111, @"Guest 7", @"email7@email.com"]]]];
    

    SMXEvent *event13 = [SMXEvent new];
    [event13 setStringCustomerName: @"event13 CAT Scans"];
    [event13 setNumCustomerID:@1];
    [event13 setActivityDateDay:[NSDate dateWithYear:[NSDate componentsOfCurrentDate].year month:[NSDate componentsOfCurrentDate].month day:[NSDate componentsOfCurrentDate].day]];
    [event13 setDateTimeBegin:[NSDate dateWithHour:16 min:00]];
    [event13 setDateTimeEnd:[NSDate dateWithHour:17 min:00]];
    [event13 setArrayWithGuests:[NSMutableArray arrayWithArray:@[@[@111, @"Guest 2", @"email2@email.com"], @[@111, @"Guest 4", @"email4@email.com"], @[@111, @"Guest 5", @"email5@email.com"], @[@111, @"Guest 7", @"email7@email.com"]]]];
    
    SMXEvent *event14 = [SMXEvent new];
    [event14 setStringCustomerName: @"event14 CAT Scans"];
    [event14 setNumCustomerID:@1];
    [event14 setActivityDateDay:[NSDate dateWithYear:[NSDate componentsOfCurrentDate].year month:[NSDate componentsOfCurrentDate].month day:[NSDate componentsOfCurrentDate].day]];
    [event14 setDateTimeBegin:[NSDate dateWithHour:17 min:00]];
    [event14 setDateTimeEnd:[NSDate dateWithHour:18 min:00]];
    [event14 setArrayWithGuests:[NSMutableArray arrayWithArray:@[@[@111, @"Guest 2", @"email2@email.com"], @[@111, @"Guest 4", @"email4@email.com"], @[@111, @"Guest 5", @"email5@email.com"], @[@111, @"Guest 7", @"email7@email.com"]]]];
    
    [lEventCollectionArray addObject:event8];
    [lEventCollectionArray addObject:event9];
    [lEventCollectionArray addObject:event10];
    [lEventCollectionArray addObject:event11];
    [lEventCollectionArray addObject:event12];

    [lEventCollectionArray addObject:event13];
    [lEventCollectionArray addObject:event14];*/

    
    self.arrayWithEvents = [NSMutableArray arrayWithArray:lEventCollectionArray];

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self customNavigationBarLayout];
    
    if (self.navigationController) {
        NSLog(@"navigationBar: %@", self.navigationController.navigationBar);
    }
    self.navigationController.navigationBar.barTintColor = [UIColor navBarBG];
    self.navigationController.navigationBar.translucent = NO;
    
    NSLog(@"navigationBar: %@", self.navigationController.navigationBar.tintColor);
    
    if (!boolDidLoad) {
        boolDidLoad = YES;
        [self buttonTodayAction:nil];
    }
    [self rightBarButtonItem];
    [self leftBarButtonItemAction];
    [self checkOrientationAndSetNavButtons];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SMXDateManager Notification

- (void)dateChanged:(NSNotification *)notification {
    
    [self updateLabelWithMonthAndYear];
}

- (void)updateLabelWithMonthAndYear {
    
    NSDate *ldate = [[SMXDateManager sharedManager] currentDate];
    NSDateComponents *comp = [NSDate componentsOfDate:ldate];
    
    NSString *string = boolYearViewIsShowing ? [NSString stringWithFormat:@"%li", comp.year] : [NSString stringWithFormat:@"%@ %li", [arrayMonthName objectAtIndex:comp.month-1], (long)comp.year];
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
        NSArray *itemArray = [NSArray arrayWithObjects: kTagDayTitle, kTagWeekTitle, KTagMonthTitle,kTextMapValue, nil];
        cSegmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
        cSegmentedControl.frame = CGRectMake(0, 0, 290, 30);
        cSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
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
    //    int index = 0;//[arrayButtons indexOfObject:sender];
    
    
    
    /* Commmented 15/09/2014
     
     [self.view bringSubviewToFront:segment.selectedSegmentIndex];
     
     boolYearViewIsShowing = NO;
     [self updateLabelWithMonthAndYear];
     
     */
    
    
    if (segment.selectedSegmentIndex == [segment numberOfSegments] -1) {
        
        if (![[MapHelper workOrderSummaryArrayOfCurrentDay] count]) {
            NSString * alert_title = [[TagManager sharedInstance] tagByName:kTagOnClickMapError];
            NSString * alert_ok = [[TagManager sharedInstance] tagByName:kTagAlertErrorOk];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:alert_title delegate:nil cancelButtonTitle:nil otherButtonTitles:alert_ok, nil];
            [alertView show];
            [self.cSegmentedControl setSelectedSegmentIndex:self.previousSelectedSegment];
            return;
        }
        
        if (!self.mapViewController) {
            self.mapViewController = [ViewControllerFactory createViewControllerByContext:ViewControllerMap];
            [self addChildViewController:self.mapViewController];
            self.mapViewController.view.frame = self.view.bounds;
            self.mapViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.view addSubview:self.mapViewController.view];
            [self.mapViewController didMoveToParentViewController:self];
            self.previousSelectedSegment = self.cSegmentedControl.selectedSegmentIndex;
            self.navigationItem.rightBarButtonItem.enabled = NO;
            self.navigationItem.rightBarButtonItem = nil;
            self.navigationItem.leftBarButtonItem.enabled = NO;
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
    else {
        [self removeMapViewVC];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = segment.selectedSegmentIndex;
        [self buttonYearMonthWeekDayAction:button];
        self.previousSelectedSegment = self.cSegmentedControl.selectedSegmentIndex;
        if (!self.navigationItem.rightBarButtonItem.enabled) {
            [self rightBarButtonItem];
        }
        if (!self.navigationItem.leftBarButtonItem.enabled && segment.selectedSegmentIndex != 0)
        {
            [self leftBarButtonItemAction];
        }
    }
    
    
    //    for (UIButton *button in arrayButtons) {
    //        button.selected = (button == sender);
    //    }
    
    
    
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

- (void)addRightBarButtonItems {
    
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedItem.width = 30.;
    
    SMXRedAndWhiteButton *buttonYear = [self calendarButtonWithTitle:@"year"];
    SMXRedAndWhiteButton *buttonMonth = [self calendarButtonWithTitle:@"month"];
    SMXRedAndWhiteButton *buttonWeek = [self calendarButtonWithTitle:@"week"];
    SMXRedAndWhiteButton *buttonDay = [self calendarButtonWithTitle:@"day"];
    
    UIBarButtonItem *barButtonYear = [[UIBarButtonItem alloc] initWithCustomView:buttonYear];
    UIBarButtonItem *barButtonMonth = [[UIBarButtonItem alloc] initWithCustomView:buttonMonth];
    UIBarButtonItem *barButtonWeek = [[UIBarButtonItem alloc] initWithCustomView:buttonWeek];
    UIBarButtonItem *barButtonDay = [[UIBarButtonItem alloc] initWithCustomView:buttonDay];
    
    SMXButtonAddEventWithPopover *buttonAdd = [[SMXButtonAddEventWithPopover alloc] initWithFrame:CGRectMake(0., 0., 30., 44)];
    [buttonAdd setProtocol:self];
    UIBarButtonItem *barButtonAdd = [[UIBarButtonItem alloc] initWithCustomView:buttonAdd];
    
    arrayButtons = @[buttonYear, buttonMonth, buttonWeek, buttonDay];
    [self.navigationItem setRightBarButtonItems:@[barButtonAdd, fixedItem, barButtonYear, barButtonMonth, barButtonWeek, barButtonDay]];
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

#pragma mark - Add Calendars

- (void)addCalendars {
    
    CGRect frame = CGRectMake(0., 0., self.view.frame.size.width, self.view.frame.size.height);
    
    //    viewCalendarYear = [[SMXYearCalendarView alloc] initWithFrame:frame];
    //    [viewCalendarYear setProtocol:self];
    //    [self.view addSubview:viewCalendarYear];
    [self getNavigationBarHeight];
    
    viewCalendarMonth = [[SMXMonthCalendarView alloc] initWithFrame:frame];
    [viewCalendarMonth setProtocol:self];
    [viewCalendarMonth setDictEvents:dictEvents];
    [self.view addSubview:viewCalendarMonth];
    
    viewCalendarWeek = [[SMXWeekCalendarView alloc] initWithFrame:frame];
    [viewCalendarWeek setProtocol:self];
    [viewCalendarWeek setDictEvents:dictEvents];
    [self.view addSubview:viewCalendarWeek];
    
    viewCalendarDay = [[SMXDayCalendarView alloc] initWithFrame:frame];
    [viewCalendarDay setProtocol:self];
    [viewCalendarDay setDictEvents:dictEvents];
    [self.view addSubview:viewCalendarDay];
    
    self.arrayCalendars = @[viewCalendarDay,viewCalendarWeek, viewCalendarMonth];
    
}

#pragma mark - Button Action

- (IBAction)buttonYearMonthWeekDayAction:(id)sender {
    
    [self removeCalender];
    [[NSNotificationCenter defaultCenter] postNotificationName:[CalendarPopupContent getNotificationKey] object:nil];
    int index = [sender tag];//[arrayButtons indexOfObject:sender];
    
    if (index == 0) {
        rightButton.tag=index;
        leftButton.tag=0;
        [rightButton setTitle:[[TagManager sharedInstance] tagByName:kTagActions] forState:UIControlStateNormal];
    }
    else if (index == 1) {
        rightButton.tag=1;
        leftButton.tag=1;
        [rightButton setTitle:@"+ Add Event" forState:UIControlStateNormal];
    }
    else if (index == 2){
        rightButton.tag=index;
        leftButton.tag=2;
        [rightButton setTitle:[[TagManager sharedInstance] tagByName:kTagActions] forState:UIControlStateNormal];
        // 15/09/2014 Code for MAP Pending.
    }
    else if (index == 3){
        rightButton.tag=index;
        leftButton.tag=3;
        [rightButton setTitle:@" " forState:UIControlStateNormal];
        return;  // 15/09/2014 Code for MAP Pending.
    }
    [self.view bringSubviewToFront:[self.arrayCalendars objectAtIndex:index]];
    
    for (UIButton *button in arrayButtons) {
        button.selected = (button == sender);
    }
    [self updateLabelWithMonthAndYear];
    [self checkOrientationAndSetNavButtons];
}

- (IBAction)buttonTodayAction:(id)sender {
    
    [[SMXDateManager sharedManager] setCurrentDate:[NSDate dateWithYear:[NSDate componentsOfCurrentDate].year
                                                                  month:[NSDate componentsOfCurrentDate].month
                                                                    day:[NSDate componentsOfCurrentDate].day]];
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
    
    
    [viewCalendarMonth invalidateLayout];
    [viewCalendarWeek invalidateLayout];
    [viewCalendarDay invalidateLayout];
    
    [self checkOrientationAndSetNavButtons];
    
}

-(void)getNavigationBarHeight
{
    gNavBarHeight = self.navigationController.navigationBar.frame.size.height;
    NSLog(@"%lf",gNavBarHeight);
}

-(void)checkOrientationAndSetNavButtons
{
    if ((leftButton.tag==0 || leftButton.tag==-1) && (cSegmentedControl.selectedSegmentIndex == 0)) {
        UIInterfaceOrientation lInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (lInterfaceOrientation == UIInterfaceOrientationPortrait || lInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            if (cSegmentedControl.selectedSegmentIndex == 0) {
                leftButton.tag=0;
                [leftButton setAttributedTitle:[self getString:@"" year:@"  Calender"] forState:UIControlStateNormal];
                [leftButton setAttributedTitle:[self getStringHighlighted:@"" year:@"  Calender"] forState:UIControlStateHighlighted];
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
        UIInterfaceOrientation lInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (lInterfaceOrientation == UIInterfaceOrientationPortrait || lInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            leftButton.tag=0;
            [viewCalendarDay showLeftPanel];
        }else{
            
        }
    }else if (cSegmentedControl.selectedSegmentIndex==1) {
        [self addCalender];
    }else if (cSegmentedControl.selectedSegmentIndex==2) {
        [self addCalender];
    }else if (cSegmentedControl.selectedSegmentIndex==3) {
        [self addCalender];
    }
}
-(void)addCalender{
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
        
        [CalendarPopupContent setTileWidth:65.0f];
        [CalendarPopupContent setTileHeightAdjustment:35.0f];
        [CalendarPopupContent setCalendarViewHeight:389.0f];
        [CalendarPopupContent setCalendarTopBarHeight:80.0f];
        [CalendarPopupContent setNotificationKey:CALENDER_VIEW_REMOVE];
        
        monthCalender=[[CalendarMonthViewController alloc] initWithSunday:YES];
        monthCalender.view.frame=CGRectMake(38, 0, 452, 389);
        monthCalender.view.backgroundColor=[UIColor  yellowColor];//anish
        [self calenderButton];
        [grayCalenderBkView addSubview:monthCalender.view];
        monthCalender.view.layer.shadowOpacity=0.50f;
        monthCalender.view.layer.shadowColor=[UIColor grayColor].CGColor;
        monthCalender.view.layer.masksToBounds = NO;
        monthCalender.view.layer.cornerRadius = 10.f;
        monthCalender.view.layer.shadowOffset = CGSizeMake(7.0f,7.5f);
        monthCalender.view.layer.shadowRadius = 1.5f;
        [monthCalender.view addSubview:[self grayLine:CGRectMake(15, 80, 430, 1)]];
    }else{
        [monthCalender.view removeFromSuperview];
        monthCalender=nil;
        [grayCalenderBkView removeFromSuperview];
        grayCalenderBkView=nil;
    }
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

#pragma mark - SMXYearCalendarView Protocol

- (void)showMonthCalendar {
    
    [self buttonYearMonthWeekDayAction:[arrayButtons objectAtIndex:1]];
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
            rightButton.frame = CGRectMake(0, 0, 120, 25);
            [rightButton setTitle:@"Actions" forState:UIControlStateNormal];
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
        [leftButton setAttributedTitle:[self getString:@"" year:@"  Calender"] forState:UIControlStateNormal];
        [leftButton setAttributedTitle:[self getStringHighlighted:@"" year:@"  Calender"] forState:UIControlStateHighlighted];
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
        NSLog(@"Day window");
    }else if (senderButton.tag==1) {
        NSLog(@"Week window");
    }else if (senderButton.tag==2){
        NSLog(@"Month window");
    }else if (senderButton.tag==3){
        NSLog(@"Map window");
    }
}
-(void)hideCalender:(id)sender{
    [monthCalender.view removeFromSuperview];
    monthCalender=nil;
    [grayCalenderBkView removeFromSuperview];
    grayCalenderBkView=nil;
}
-(void)removeCalender{
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
    [self buttonYearMonthWeekDayAction:[arrayButtons objectAtIndex:0]];
}

- (void) leftButtonTextChange:(NSNotification *) notification
{
    NSDate *date= [notification object];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMdd";
    // set swedish locale
    //dateFormatter.locale=[[NSLocale alloc] initWithLocaleIdentifier:@"sv_SE"];;
    
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
    // NSDate *date= [notification object];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMdd";
    // set swedish locale
    //dateFormatter.locale=[[NSLocale alloc] initWithLocaleIdentifier:@"sv_SE"];;
    
    dateFormatter.dateFormat=@"MMMM";
    NSString * monthString = [[dateFormatter stringFromDate:date] capitalizedString];
    dateFormatter.dateFormat=@"YYYY";
    [leftButton setAttributedTitle:[self getString:monthString year:[[dateFormatter stringFromDate:date] capitalizedString]] forState:UIControlStateNormal];
    [leftButton setAttributedTitle:[self getStringHighlighted:monthString year:[[dateFormatter stringFromDate:date] capitalizedString]] forState:UIControlStateHighlighted];
    [leftButton sizeToFit];
    leftButton.imageEdgeInsets = UIEdgeInsetsMake(7, leftButton.titleLabel.frame.size.width+3, 0, -leftButton.titleLabel.frame.size.width);
}
@end
