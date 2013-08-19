//
//  ModalViewController.m
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 11/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ModalViewController.h"
#import "FirstDetailViewController.h"
#import "LoginController.h"
#import "HTMLBrowser.h"
#import "LocalizationGlobals.h"
#import "About.h"
#import "zkSObject.h"
#import "Reachability.h"
#import "ManualDataSync.h"
#import "SFMPageController.h"
#import "ManualDataSync.h"
#import "Utility.h"
extern void SVMXLog(NSString *format, ...);


#define VAL 2

@implementation ModalViewController
@synthesize Continue_rescheduling;
@synthesize weekView;
@synthesize eventDetails, activity;
@synthesize eventView;
@synthesize HomeButton;
@synthesize offline;
@synthesize updateStartTime, updateEndTime;
@synthesize Event_edit_flag;
@synthesize Add_event_Button;
@synthesize didDismissalertview;
@synthesize isDayButtonClicked;
@synthesize rescheduledAnEvent;
@synthesize shouldRedrawWeekView;

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.view addSubview:appDelegate.SyncProgress];
    if( isShowingDailyView )
    {
        //sahana  dec 14th
        NSString * version = [appDelegate serverPackageVersion];
        int _stringNumber = [version intValue];
        
        if(_stringNumber >=  (KMinPkgForScheduleEvents * 100000))
        {
            appDelegate.SyncProgress.frame = CGRectMake(776, 5, 35, 35);
        }
        else
        {
            appDelegate.SyncProgress.frame = CGRectMake(834, 5, 35, 35);
        }

    }
    else
    {
        NSString * version = [appDelegate serverPackageVersion];
        int _stringNumber = [version intValue];
        
        if(_stringNumber >=  (KMinPkgForScheduleEvents * 100000))
        {
              appDelegate.SyncProgress.frame = CGRectMake(826, 5, 35, 35);
        }
        else
        {
            appDelegate.SyncProgress.frame = CGRectMake(876, 5, 35, 35);
        }
    }
	
}

/* Shravya-Calendar 7751*/
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     NSLog(@"MODAL VIEW WILL APPEAR");
    if ([Utility getRefreshCalendarView]) {
        NSLog(@"Reloading the events on save");
        [self performSelector:@selector(reloadCalendar) withObject:nil afterDelay:0];
        [Utility clearRefreshCalendarView];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self enableUI];
    // Samman 09 April, 2011
    if (appDelegate.refreshCalendar)
    {
        [self refreshViews];
        appDelegate.refreshCalendar = NO;
    }
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
		// [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInternetConnectionChange:) name:kInternetConnectionChanged object:nil];
    }
    
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:NOTIFICATION_EVENT_DATA_SYNC object:nil];
    [Utility clearRefreshCalendarView]; /* Shravya-Calendar 7751*/
    [self disableUI];
	
    isActive = YES;
    appDelegate.showUI = TRUE;   //btn merge
    
	
	//pavaman 12th Jan 2011
	didFirstTimeLoad = TRUE;
	
	//pavaman 16th Jan 2011
	workOrderArray = [[NSMutableArray alloc] initWithCapacity:0];
	eventViewArray = [[NSMutableArray alloc] initWithCapacity:0];
    eventPositionArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.wsInterface.refreshModalStatusButton = self;
    
    if (iOSObject == nil)
        iOSObject = [[iOSInterfaceObject alloc] initWithCaller:self];
	
    if (calendar == nil)
    {   
        calendar = [[CalendarController alloc] initWithNibName:@"CalendarController" bundle:nil];
        calendar.delegate = self;
        calendar.view.tag = CALENDARTAG;
    }
    
    if (appDelegate.didDayViewUnload)
    {
        appDelegate.didDayViewUnload = NO;
        calendar.didReloadCalendar = YES;
        calendar.view.tag = CALENDARTAG;
        [calendar RefreshCalendar];
        
        if (!isShowingDailyView)
        {
            isShowingDailyView = YES;
            segmentButton.selectedSegmentIndex = 1;
        }
    }
    
    [leftPane addSubview:calendar.view];
	
    if (tasks == nil)
        tasks = [[NSMutableArray alloc] initWithCapacity:0];
    else
        [tasks removeAllObjects];
    
    if (taskView == nil)
        taskView = [[TaskViewController alloc] initWithNibName:@"TaskViewController" bundle:nil];
    taskView.calendar = calendar;
    taskView.view.frame = CGRectMake(20, 298, taskView.view.frame.size.width, taskView.view.frame.size.height);
    [leftPane addSubview:taskView.view];
    
    [_tableView setEditing:YES animated:YES];
    
    isShowingDailyView = YES;
    
    // Set slider for landscape orientation
    [slider setThumbImage:[UIImage imageNamed:@"slider.png"] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage imageNamed:@"slider.png"] forState:UIControlStateHighlighted];
	
    [slider setMinimumTrackImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateNormal];
    [slider setMinimumTrackImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateHighlighted];
    [slider setMaximumTrackImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateNormal];
    [slider setMaximumTrackImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateHighlighted];
    
    // Set slider for portrait orientation
    [portraitSlider setThumbImage:[UIImage imageNamed:@"slider.png"] forState:UIControlStateNormal];
    [portraitSlider setThumbImage:[UIImage imageNamed:@"slider.png"] forState:UIControlStateHighlighted];
    
    [portraitSlider setMinimumTrackImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateNormal];
    [portraitSlider setMinimumTrackImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateHighlighted];
    [portraitSlider setMaximumTrackImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateNormal];
    [portraitSlider setMaximumTrackImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateHighlighted];
	
    // Changes for localization
    //Radha 20th April 2011
    ltaskLabel.text = [appDelegate.wsInterface.tagsDictionary objectForKey:LTASKLABEL];
    ltaskLabel.textColor = [appDelegate colorForHex:@"2d5d83"];
    
    
    //Radha 21st April 2011
    rscheduleLabel.text = [appDelegate.wsInterface.tagsDictionary objectForKey:RSCHDULELABEL];
    rscheduleLabel.textColor = [appDelegate colorForHex:@"2d5d83"];
    
    NSString * str = [appDelegate.wsInterface.tagsDictionary objectForKey:SEGMTDAYBTN];
    [segmentButton setTitle:str forSegmentAtIndex:0];
    str = [appDelegate.wsInterface.tagsDictionary objectForKey:SEGMTWEEKBTN];
    [segmentButton setTitle:str forSegmentAtIndex:1];
    str = [appDelegate.wsInterface.tagsDictionary objectForKey:SLIDERTODAYBTN];
    [todayBtn setTitle:str forState:UIControlStateNormal];
	//Defect Fix :- 7454
	[todayBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
	todayBtn.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    
    [segmentButton setImage:[UIImage imageNamed:@"iService-Day-Button-Down-State.png"] forSegmentAtIndex:0];
    [segmentButton setImage:[UIImage imageNamed:@"iService-Week-Button-Up-State.png"] forSegmentAtIndex:1];
    
    /*statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
	 statusButton.frame = CGRectMake(815, 8, 26, 26);
	 [statusButton setBackgroundImage:[self getStatusImage] forState:UIControlStateNormal];
	 [statusButton addTarget:self action:@selector(showManualSyncUI) forControlEvents:UIControlEventTouchUpInside];
	 statusButton.enabled = NO;*/
	
    //[appDelegate setSyncStatus:appDelegate.SyncStatus];
    
    NSString * version = [appDelegate serverPackageVersion];
	int _stringNumber = [version intValue];    
    if(_stringNumber  < (KMinPkgForScheduleEvents * 100000))
    {
        //sahana dec 14th
        Add_event_Button.enabled = NO;
        Add_event_Button.alpha = 0.0;
        [Add_event_Button setHidden:true];
    }

    
	
}

- (void) didInternetConnectionChange:(NSNotification *)notification
{
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber * currentReach = (NSNumber *) notification.object;
    BOOL isReachable = [currentReach boolValue];
    if (isReachable)
    {
        SMLog(@"ModalViewController Internet Reachable");
        // Special Handling
        // Enable slider
        [slider setUserInteractionEnabled:YES];
    }
    else
    {
        SMLog(@"ModalViewController Internet Not Reachable");
        // Special Handling
        // Disable slider
        [slider setUserInteractionEnabled:NO];
        if (didRunOperation)
        {
            [activity stopAnimating];
            //[appDelegate displayNoInternetAvailable];
            didRunOperation = NO;
        }
    }
}

- (void) didAllDataLoad
{
    if (tasksDidLoad && calendarDidLoad)
    {
        [self removeCrashProtector];
    }
    
    didRunOperation = NO;
}

- (void) removeCrashProtector
{
    SMLog(@"Removed Crash Protector");
    
    [self enableUI];
}

- (IBAction) Help;
{
    HelpController * help = [[HelpController alloc] initWithNibName:@"HelpController" bundle:nil];
    help.modalPresentationStyle = UIModalPresentationFullScreen;
    help.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    NSString *lang=[appDelegate.dataBase checkUserLanguage];
    NSString *calView=@"";
    if (isShowingDailyView)
        calView = @"day-view";
    else
        calView = @"week-view";
    
    NSString *isfileExists = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_%@",calView,lang] ofType:@"html"];
    if((isfileExists == NULL) || [lang isEqualToString:@"en_US"] ||  !([lang length]>0))
    {
        help.helpString=[NSString stringWithFormat:@"%@.html",calView];
    }
    else
    {
        help.helpString = [NSString stringWithFormat:@"%@_%@.html",calView,lang];
    }

    [self presentViewController:help animated:YES completion:nil];
    [help release];
}

#pragma mark -
#pragma mark Setup Tasks
- (void) setupTasksForDate:(NSString *)date
{
    SMLog(@"SetupTask");
    //[iOSObject queryTasksForDate:date];
    
    //Shrinivas
    NSMutableArray * _tasks = [[[NSMutableArray alloc] initWithCapacity:0]autorelease]; 
    _tasks = [appDelegate.calDataBase didGetTaskFromDB:date];
    SMLog(@"%@", _tasks);
    if (taskView == nil)
        taskView = [[TaskViewController alloc] initWithNibName:@"TaskViewController" bundle:nil];
    [taskView refreshWithTasks:_tasks];
}

// Callback Method
- (void) didQueryTasksForDate:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    SMLog(@"didQueryTasks");
    @try{
    NSMutableArray * _tasks = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray * taskArray = [result records];
    NSArray * taskObject;
    for (int i = 0; i < [taskArray count]; i++)
    {
        ZKSObject * obj = [taskArray objectAtIndex:i]; //Radha 11th august 2011
        taskObject = [NSArray arrayWithObjects:
                      [[[obj fields] objectForKey:TASKPRIORITY] isKindOfClass:[NSString class]]?[[obj fields] objectForKey:TASKPRIORITY]:@"",
                      [[[obj fields] objectForKey:TASKSUBJECT] isKindOfClass:[NSString class]]?[[obj fields] objectForKey:TASKSUBJECT]:@"",
                      [[[obj fields] objectForKey:TASKID]isKindOfClass:[NSString class]]?[[obj fields] objectForKey:TASKID]:@"",
                      nil];
        [_tasks addObject:taskObject];
    }
    
    [taskView refreshWithTasks:_tasks];
    [_tasks release];
    
    [self performSelector:@selector(didGetAllTasks) withObject:nil afterDelay:0.3];
    }@catch (NSException *exp) {
        SMLog(@"Exception Name ModalViewController :didQueryTasksForDate %@",exp.name);
        SMLog(@"Exception Reason ModalViewController :didQueryTasksForDate %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
}

- (void) didGetAllTasks
{
    tasksDidLoad = YES;
    [self didAllDataLoad];
}

#pragma mark -
#pragma mark Setup Events
- (void) setupEventsOnView:(UIView *)theView
{
    [self PopulateEventsOnView:(UIView *)theView ByDate:[calendar getTodayString]];
}

- (void) PopulateEventsOnView:(UIView *)theView ByDate:(NSString *)date
{
    // Start a seperate thread and show activity indicator
    [activity startAnimating];
	
    [self setupTasksForDate:date];
}

- (void) stopActivity;
{
    NSArray * array = [rightPane subviews];
    for (int i = 0; i < [array count]; i++)
    {
        [[array objectAtIndex:i] removeFromSuperview];
    }    
    
    [eventViewArray removeAllObjects];
    [eventPositionArray removeAllObjects];
	
    [activity stopAnimating];
}

- (void) setEventDetails:(NSArray *)_eventDetails
{
    eventDetails = [_eventDetails retain];
}

- (NSUInteger) getPriorityColorByPriority:(NSString *)priority
{
    if ([priority isKindOfClass:[NSString class]])
    {
        if ([priority isEqualToString:@"High"])
            return cRED;
        if ([priority isEqualToString:@"Medium"])
            return cBLUE;
        if ([priority isEqualToString:@"Low"])
            return cGREEN;
    }
    return cPURPLE;
}

#pragma mark -
#pragma mark EventViewControllerDelegate Methods

- (void) movedEvent:(EventViewController *)event
{
    [activity startAnimating];
    @try{
    NSDictionary * startEndTime = [event getEventStartEndTime];
    SMLog(@"%@", startEndTime);
    
    NSString * startTime = [startEndTime objectForKey:STARTTIME];
    NSString * endTime = [startEndTime objectForKey:ENDTIME];
    
    NSString * time = endTime;
    
    NSString * startDate = [eventView.startDate substringToIndex:11];
	
    startTime = [NSString stringWithFormat:@"%@ %@", startDate, startTime];
    endTime = [NSString stringWithFormat:@"%@ %@", startDate, endTime];
    
    if ([time isEqualToString:@"00:00:00"])
    {
        NSString * oldString = [startTime substringToIndex:10];
        NSString * newString = [startTime substringToIndex:8];
        NSString * date = [NSString stringWithFormat:@"%@", [endTime substringFromIndex:8]];
        NSInteger value = [date integerValue];
        ++value;
        date = [NSString stringWithFormat:@"%d", value];
        newString = [newString stringByAppendingFormat:@"%@", date];
        endTime = [endTime stringByReplacingOccurrencesOfString:oldString withString:newString];
        
    }
	
    updateStartTime = startTime;
    updateEndTime = endTime;
    
    
    startTime = [iOSInterfaceObject getGMTFromLocalTime:startTime];
    endTime = [iOSInterfaceObject getGMTFromLocalTime:endTime];
    
    updatestartDateTime = startTime;
    updateendDateTime = endTime;
    
    updateendDateTime = [updateendDateTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    updateendDateTime = [updateendDateTime stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    
    updatestartDateTime = [updatestartDateTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    updatestartDateTime = [updatestartDateTime stringByReplacingOccurrencesOfString:@"Z" withString:@""];
	}@catch (NSException *exp) {
        SMLog(@"Exception Name ModalViewController :movedEvent %@",exp.name);
        SMLog(@"Exception Reason ModalViewController :movedEvent %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];;
    }
} 
//sahana 12th sept 2011
- (void) Continuetherescheduling:(BOOL)continue_rescheduling;
{
    Continue_rescheduling = continue_rescheduling;
}

-(void) EditEvent:(BOOL)edit_flag
{
    Event_edit_flag = edit_flag;
}
- (void) refreshCacheData
{
    [weekView setupWeeks];
    // Event setup
    [weekView setUpDayRect];
    [weekView setupEvents];
    didSetupWeekView = YES;
}

- (void) updateCacheInfo:(NSMutableDictionary *)_workOrderDetails
{
    eventView.workOrderDetail = _workOrderDetails;
    
}

- (void) deleteCacheDate
{
    
}

- (IBAction) refreshViews;
{
    [self disableUI];
	/* if (![appDelegate isInternetConnectionAvailable] && (offline == YES))
	 {
	 [activity stopAnimating];
	 [appDelegate displayNoInternetAvailable];
	 return;
	 }*/
    
    didRunOperation = YES;
    didRefresh = YES;
	
    if (!isShowingDailyView)
    {
        [weekView.activity startAnimating];
        [weekView clearWeekView];
        [weekView setupEvents];
    }
    else 
    {
        [activity startAnimating];
        NSArray * array = [rightPane subviews];
        for (int i = 0; i < [array count]; i++)
        {
            [[array objectAtIndex:i] removeFromSuperview];
        } 
		
        [self refresh];
        
        // Samman - 24 Sep, 2011 - Removed below code as it calls refresh twice. A MAJOR reason for crash scenarios 
		//        [NSThread detachNewThreadSelector:@selector(refresh) toTarget:self withObject:nil];
    }
    
    
}

- (void) refresh
{
    [self disableUI];
    
    /*Shravya-Calendar view 7408 */
    //Shravya - @synchronized is needed as refresh gets called from multiple threads during Sync
    @synchronized(self){
    
    //7751
    [Utility clearRefreshCalendarView];
        
    // Need to call WSInterface Method to perform an actual REFRESH
        
    NSMutableArray * currentDateRange = [[appDelegate getWeekdates:currentDate] retain];
    
    [self setupTasksForDate:appDelegate.dateClicked];
    
    /*Shravya-Calendar view 7408 */
    NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
    appDelegate.wsInterface.eventArray = [appDelegate.calDataBase GetEventsFromDBWithStartDate:[currentDateRange objectAtIndex:0]  endDate:[currentDateRange objectAtIndex:1]];
    [aPool drain];
	[currentDateRange release];
    [self reloadCalendar];
        
    }
}

- (void) reloadCalendar
{
	//    [rightPaneParent setUserInteractionEnabled:NO];
    [self enableUI];
    SMLog(@"currentdate =  %@", currentDate);
    [self setEventsView:currentDate];
    if ((weekView != nil) && ([weekView retainCount] > 0))
    {
        //[weekView populateWeekView];
	/*Shravya-Calendar view 7408 */
        if (!isDayButtonClicked) {
            [weekView setupEvents];
            isDayButtonClicked = NO;
        }
        else {
            [weekView.activity stopAnimating];
        }
            
    }
	//    [rightPaneParent setUserInteractionEnabled:YES];
    [self enableUI];
}

- (void) didUpdateObjects:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
{
    SMLog(@"Updated objects");
	
	[self refreshCacheData];
    [self setupEventsOnView:rightPane];
}

#pragma mark -
#pragma mark Local IBActions

- (IBAction) ShowMap
{
	@try{	
    //Radha - 24/March  
    [self refresh];
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
	
    NSString * serviceMax = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_TITLE];
    NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    NSString * noEvents = [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_NO_EVENTS];
    
    if (appDelegate.wsInterface.eventArray == nil || [appDelegate.wsInterface.eventArray count] == 0)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:serviceMax message:noEvents delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    if (appDelegate.workOrderEventArray && [appDelegate.workOrderEventArray count] > 0)
    {
        [appDelegate.workOrderEventArray removeAllObjects];
    }
	
    // Add events to workOrderEventArray based on today
    for (int i = 0; i < [appDelegate.wsInterface.eventArray count]; i++)
    {
        NSDictionary * dict = [appDelegate.wsInterface.eventArray objectAtIndex:i];
        
        NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString * activityDate = [dateFormatter stringFromDate:[dict objectForKey:STARTDATETIME]];
        NSString * apiName = [dict objectForKey:OBJECTAPINAME];
		
        if ([appDelegate.dateClicked isEqualToString:activityDate])
        {
            if ([apiName isEqualToString:WORKORDER])
            {
                [appDelegate.workOrderEventArray addObject:dict];
            }
        }
    }
    
    // Sort workOrderEventArray
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    for (int i = 0; i < [appDelegate.workOrderEventArray count]; i++)
    {
        for (int j = i+1; j < [appDelegate.workOrderEventArray count]; j++)
        {
            NSDictionary * obji = [appDelegate.workOrderEventArray objectAtIndex:i];
            NSDictionary * objj = [appDelegate.workOrderEventArray objectAtIndex:j];
			
            NSString * objiDate = [dateFormatter stringFromDate:[obji objectForKey:STARTDATETIME]];
            NSString * objjDate = [dateFormatter stringFromDate:[objj objectForKey:STARTDATETIME]];
			
            NSString * iDateStr = [objiDate isKindOfClass:[NSString class]]?objiDate:@"1970-01-01T00:00:00Z";
            NSString * jDateStr = [objjDate isKindOfClass:[NSString class]]?objjDate:@"1970-01-01T00:00:00Z";
			
            iDateStr = [iOSInterfaceObject getLocalTimeFromGMT:iDateStr];
            iDateStr = [iDateStr stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            iDateStr = [iDateStr stringByReplacingOccurrencesOfString:@"Z" withString:@""];
            
            jDateStr = [iOSInterfaceObject getLocalTimeFromGMT:jDateStr];
            jDateStr = [jDateStr stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            jDateStr = [jDateStr stringByReplacingOccurrencesOfString:@"Z" withString:@""];
            
            NSDate * iDate = [dateFormatter dateFromString:iDateStr];
            NSDate * jDate = [dateFormatter dateFromString:jDateStr];
            
            // Compare the dates, if iDate > jDate interchange
            if ([iDate timeIntervalSince1970] > [jDate timeIntervalSince1970])
            {
                [appDelegate.workOrderEventArray exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
    
    //Shrinivas
    
    for ( int i=0; i<[appDelegate.workOrderEventArray count];i++ )
    {
        for (int j= i + 1; j<=[appDelegate.workOrderEventArray count]-1;j++) 
        {
            NSDate * iobjDate = [[appDelegate.workOrderEventArray objectAtIndex:i] objectForKey:STARTDATETIME];
            NSString * istartDate = [self dateStringConversion:iobjDate];
            NSDate * jobjDate = [[appDelegate.workOrderEventArray objectAtIndex:j] objectForKey:STARTDATETIME];
            NSString * jstartDate = [self dateStringConversion:jobjDate];
            
            if ([istartDate isEqualToString:jstartDate])
            {
                NSString * iWhatId = [[appDelegate.workOrderEventArray objectAtIndex:i] objectForKey:WHATID];
                NSString * jWhatId = [[appDelegate.workOrderEventArray objectAtIndex:j] objectForKey:WHATID];
                
                NSString * iObjectName = [[appDelegate.workOrderEventArray objectAtIndex:i] objectForKey:OBJECTAPINAME];
				NSString * jObjectname = [[appDelegate.workOrderEventArray objectAtIndex:j] objectForKey:OBJECTAPINAME];
                
                NSString * iPriority = [appDelegate.calDataBase getPriorityForWhatId:iWhatId objectname:iObjectName];
                NSString * jPriority = [appDelegate.calDataBase getPriorityForWhatId:jWhatId objectname:jObjectname];
                
                if ([iPriority isEqualToString:@"High"] && ([jPriority isEqualToString:@"Medium"]||[jPriority isEqualToString:@"Low"]))
                {
                    [appDelegate.workOrderEventArray removeObjectAtIndex:j];
                }
                else if([iPriority isEqualToString:@"Medium"] && [jPriority isEqualToString:@"Low"])
                {
                    [appDelegate.workOrderEventArray removeObjectAtIndex:j];
                }
                else if([iPriority isEqualToString:@"Low"]&&([jPriority isEqualToString:@"High"]||[jPriority isEqualToString:@"Medium"]))
                {
                    [appDelegate.workOrderEventArray removeObjectAtIndex:j];
                }
                else if([iPriority isEqualToString:jPriority])
                {
                    if (strcmp((const char*)iWhatId, (const char *)jWhatId) > 0)
                    {
                        [appDelegate.workOrderEventArray removeObjectAtIndex:i];
                    }
                    else
                    {
                        [appDelegate.workOrderEventArray removeObjectAtIndex:j];
                    }
                }
                
            }
        }
        
    }
	
	
    SMLog(@"%@", appDelegate.workOrderEventArray);
	
    if ([appDelegate.workOrderEventArray count] == 0)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:serviceMax message:noEvents delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    else
    {
        if (appDelegate.workOrderInfo)
        {
            appDelegate.workOrderInfo = nil;
            appDelegate.workOrderInfo = [[NSMutableArray alloc] initWithCapacity:0];
        }
		
        BOOL status;
        status = [Reachability connectivityStatus];
        //write a query to retrieve the work order info 
        for (int i = 0; i < [appDelegate.workOrderEventArray count]; i++)
        {
            
            NSDictionary * dict = [appDelegate.workOrderEventArray objectAtIndex:i];
            NSString * local_id = [appDelegate.databaseInterface getLocalIdFromSFId:[dict objectForKey:WHATID] tableName:[dict objectForKey:OBJECTAPINAME]];
            NSMutableDictionary *  infoDict  = [appDelegate.databaseInterface queryForMapWorkOrderInfo:local_id tableName:[dict objectForKey:OBJECTAPINAME]];
            [appDelegate.workOrderInfo addObject:infoDict];
        }
        FirstDetailViewController * mapView = [[FirstDetailViewController alloc] initWithNibName:@"FirstDetailView" bundle:nil];
        mapView.currentDate = [calendar getTodayString];
        mapView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        mapView.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:mapView animated:YES completion:nil];
        [mapView release];
    }
	}@catch (NSException *exp) {
	SMLog(@"Exception Name ModalViewController :ShowMap %@",exp.name);
	SMLog(@"Exception Reason ModalViewController :ShowMap %@",exp.reason);
	 [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

}

- (IBAction) ToggleLandscapeView
{
	/* if (![appDelegate isInternetConnectionAvailable] && (offline == YES))
	 {
	 //[appDelegate displayNoInternetAvailable];
	 //return;
	 }*/
    if (didTogglePortraitView)
    {
        didTogglePortraitView = NO;
        return;
    }
    didToggleLandscapeView = YES;
    
    if ((weekView != nil) && !isShowingDailyView)
    {
        if (isViewDirty)
        {
            [UIView beginAnimations:@"ShowWeeklyView" context:nil];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationDelegate:self];
            weekView.view.alpha = 0.0;
            showMapButton.enabled = YES;
            showMapButton.alpha = 1.0;
            refreshButton.enabled = YES;
            refreshButton.alpha = 1.0;
            HomeButton.frame = homeButtonRect;
            refreshButton.frame = refreshButtontRect;
            //statusButton.frame = CGRectMake(815, 8, 26, 26);
            NSString * version = [appDelegate serverPackageVersion];
            int _stringNumber = [version intValue];
            
            if(_stringNumber >=  (KMinPkgForScheduleEvents * 100000))
            {
                Add_event_Button.frame = AddEventButtonRect;
                appDelegate.SyncProgress.frame = CGRectMake(776, 5, 35, 35);
            }
            else
            {
                appDelegate.SyncProgress.frame = CGRectMake(834, 5, 35, 35);
            }
            [UIView commitAnimations];
            isViewDirty = NO;
        }
        else
        {
            [UIView beginAnimations:@"ShowWeeklyView" context:nil];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationDelegate:self];
            weekView.view.alpha = 0.0;
            showMapButton.enabled = YES;
            showMapButton.alpha = 1.0;
            refreshButton.enabled = YES;
            refreshButton.alpha = 1.0;
            HomeButton.frame = homeButtonRect;
            refreshButton.frame = refreshButtontRect;
            //statusButton.frame = CGRectMake(815, 8, 26, 26);
            
            NSString * version = [appDelegate serverPackageVersion];
            int _stringNumber = [version intValue];
            
            if(_stringNumber >=  (KMinPkgForScheduleEvents * 100000))
            {
                Add_event_Button.frame = AddEventButtonRect;
                appDelegate.SyncProgress.frame = CGRectMake(776, 5, 35, 35);
            }
            else
            {
                appDelegate.SyncProgress.frame = CGRectMake(834, 5, 35, 35);
            }
            
          
            [UIView commitAnimations];
        }
        
        [segmentButton setImage:[UIImage imageNamed:@"iService-Day-Button-Up-State.png"] forSegmentAtIndex:0];
        [segmentButton setImage:[UIImage imageNamed:@"iService-Week-Button-Down-State.png"] forSegmentAtIndex:1];
        
        [self enableUI];
    }
    
    if (isShowingDailyView)
    {
        isDayButtonClicked = NO;
        if (restoreDate)
            [restoreDate release];
        restoreDate = [[calendar getCalendarDate] retain];
        isShowingDailyView = NO;
        // Show weekly view
        if (weekView == nil)
        {
            weekView = [[WeeklyViewController alloc] initWithNibName:@"WeeklyViewController" bundle:nil];
            weekView.delegate = self;
            weekView.calendar = [calendar retain];
            
            // [weekView setupWeeks];
            weekView.view.alpha = 0;
            weekView.view.frame = CGRectMake(0, 44, weekView.view.frame.size.width, weekView.view.frame.size.height);
            [self.view addSubview:weekView.view];
            [weekView.activity startAnimating];/*Shravya-Calendar view 7408 */
        }
        else
        {
            weekView.view.frame = CGRectMake(0, 44, weekView.view.frame.size.width, weekView.view.frame.size.height);
            [weekView setupWeeks];
			//3rd Jan 2011 pavaman
			if ([weekView isViewDirty] == YES)
				isViewDirty = [weekView isViewDirty];
			
            if (isViewDirty) {
                if (!didSetupWeekView)
                {
                    [weekView.activity startAnimating];/*Shravya-Calendar view 7408 */
                    [weekView setupEvents];
                    didSetupWeekView = NO;
                }
                shouldRedrawWeekView = NO;
            }
            else if(shouldRedrawWeekView){
                [weekView.activity startAnimating];/*Shravya-Calendar view 7408 */
                [weekView setupEvents];
                didSetupWeekView = NO;
                shouldRedrawWeekView = NO;
            }
            
        }
		
        [self.view addSubview:weekView.view];
        
        [UIView beginAnimations:@"ShowWeeklyView" context:nil];
        [UIView setAnimationDuration:0.3];
        weekView.view.alpha = 1.0;
        showMapButton.enabled = NO;
        showMapButton.alpha = 0.0;
        refreshButton.enabled = YES;
        refreshButton.alpha = 1.0;
        homeButtonRect = HomeButton.frame;
        HomeButton.frame = showMapButton.frame;
        refreshButtontRect = refreshButton.frame;
        refreshButton.frame = refreshButtontRect;
        //statusButton.frame = CGRectMake(855, 8, 26, 26); //Check This
        NSString * version = [appDelegate serverPackageVersion];
        int _stringNumber = [version intValue];
        
        if(_stringNumber >=  (KMinPkgForScheduleEvents * 100000))
        {
            AddEventButtonRect  = Add_event_Button.frame;
            syncindicatorRect = appDelegate.SyncProgress.frame;
            Add_event_Button.frame = homeButtonRect;
            appDelegate.SyncProgress.frame = CGRectMake(826, 5, 35, 35);
            
        }
        else
        {
             appDelegate.SyncProgress.frame = CGRectMake(876, 5, 35, 35);
        }
       
       
        [UIView commitAnimations];
        
        [self disableUI];
        
        [segmentButton setImage:[UIImage imageNamed:@"iService-Day-Button-Up-State.png"] forSegmentAtIndex:0];
        [segmentButton setImage:[UIImage imageNamed:@"iService-Week-Button-Down-State.png"] forSegmentAtIndex:1];
    }
    else
    {
        isShowingDailyView = YES;
        // Show daily view
        [weekView RefreshLandscape];
        
        /*Shravya-Calendar view 7408 */
        // Shravya below comments applies to this line as well
        
        //[calendar setCalendarDate:[[restoreDate objectAtIndex:0] intValue] Month:[[restoreDate objectAtIndex:1] intValue] Year:[[restoreDate objectAtIndex:2] intValue]];
        //isDayButtonClicked = YES;
        
         /*Shravya-Calendar view 7408 */
        //Shravya- If there is any reorder of events in the weekview , then reload the day view on toggle
        if (rescheduledAnEvent) {
            [self setEventsView:currentDate];
            rescheduledAnEvent = NO;
        }
        if (weekView.isViewDirty)
        {
             /*Shravya-Calendar view 7408 */
            // Shravya - Below line are commented: Reasons are below
            // Shravya - We dont have to load the day view every time.
            // Shravya - Day view will be reloaded automatically whenver user changes or sync finishes by external entities.
            // Shravya - Same comments applies to "else" part of this "if".
           
            //[self setDate:[calendar getSelDate]];
            weekView.isViewDirty = NO;
        }
		else {
			
			//[self setDate:[calendar getSelDate]];
			
		}
        
        [segmentButton setImage:[UIImage imageNamed:@"iService-Day-Button-Down-State.png"] forSegmentAtIndex:0];
        [segmentButton setImage:[UIImage imageNamed:@"iService-Week-Button-Up-State.png"] forSegmentAtIndex:1];
        
        [self enableUI];
    }
}

- (IBAction) goToHomePage:(id)sender
{
    isActive = NO;
    appDelegate.didDayViewUnload = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)removeWeekView:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [weekView.view removeFromSuperview];
    weekView = nil;
}

- (IBAction) AddTask:(id)sender
{
	/* if (![appDelegate isInternetConnectionAvailable] && (offline == YES))
	 {
	 [activity stopAnimating];
	 [appDelegate displayNoInternetAvailable];
	 return;
	 }*/
    addTaskView = [[AddTaskController alloc] initWithNibName:@"AddTaskController" bundle:nil];
    addTaskView.taskView = taskView;
    UIPopoverController * popOver = [[UIPopoverController alloc] initWithContentViewController:addTaskView];
    popOver.delegate = self;
    addTaskView.popOverController = popOver;
    [popOver setPopoverContentSize:CGSizeMake(320, 430)];
    UIButton * button = (UIButton *) sender;
    [popOver presentPopoverFromRect:button.frame inView:leftPane permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    popOverController = popOver;
}

-(IBAction)AddEvent:(id)sender
{
    if ([appDelegate.SFMPage retainCount] > 0)
    {
        appDelegate.SFMPage = nil;
    }
    
    NSArray * processids_array = [appDelegate.databaseInterface getEventProcessIdForProcessType:STANDALONECREATE SourceObject:@""];
    
    if([processids_array count] > 0)
    {
        NSString * process_id = [processids_array objectAtIndex:0];
        appDelegate.sfmPageController = [[[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:NO] autorelease];
        appDelegate.sfmPageController.processId = process_id;
        appDelegate.sfmPageController.recordId = nil;
        //sahana offline
        appDelegate.sfmPageController.objectName = @"Event";
        
        [appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
        [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        
        [self presentViewController:appDelegate.sfmPageController animated:YES completion:^(void){}];
        [appDelegate.sfmPageController.detailView didReceivePageLayoutOffline ];
    }
}
- (void) dismissSelf:(UIPopoverController *)popOver
{
    [popOver dismissPopoverAnimated:YES];
}

- (void) dismissPopOver:(UIPopoverController *)popOver
{
    [popOver dismissPopoverAnimated:YES];
}

#pragma mark -
#pragma mark Device Rotation Methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
    }
    else
        if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
            
        }
        else
            return NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // SMLog(@"willRotateToInterfaceOrientation");
}

- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // SMLog(@"willAnimateFirstHalfOfRotationToInterfaceOrientation");
}

- (void)didAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // SMLog(@"didAnimateFirstHalfOfRotationToInterfaceOrientation");
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration
{
    // SMLog(@"willAnimateSecondHalfOfRotationFromInterfaceOrientation");
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    // SMLog(@"willAnimateRotationToInterfaceOrientation");
	
    if (interfaceOrientation == UIInterfaceOrientationPortrait)
    {
        isPortrait = YES;
        
        self.view = portrait;	
        self.view.transform = CGAffineTransformIdentity; 
        self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(0));
        self.view.bounds = CGRectMake(0.0, 0.0, 768.0, 1004.0);
        
        if (!isShowingDailyView)
        {
            // [weekView setRotation:UIInterfaceOrientationPortrait];
            [portrait addSubview:weekView.view];
        }
        
        // [self RefreshPortraitEventPane];
        
        if (!isShowingDailyView)
        {
            // take week view off the screen, and place it back after rotation completes
            hideWeekView = YES;
            [UIView beginAnimations:@"HideWeeklyView" context:nil];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationDidStopSelector:@selector(removeWeekView:finished:context:)];
            weekView.view.alpha = 0.0;
            [UIView commitAnimations];
        }
    }
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        isPortrait = NO;
        
        self.view = landscape;
        self.view.transform = CGAffineTransformIdentity;
        self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(-90));
        self.view.bounds = CGRectMake(0.0, 0.0, 1024.0, 748.0);
        
        if (!isShowingDailyView)
        {
            [self.view addSubview:weekView.view];
        }
        
        [self RefreshLandscapeEventPane];
        
        if (!isShowingDailyView)
        {
            [UIView beginAnimations:@"ShowWeeklyView" context:nil];
            [UIView setAnimationDuration:0.3];
            weekView.view.alpha = 1.0;
            [UIView commitAnimations];
        }
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        isPortrait = YES;
        self.view = portrait;
        self.view.transform = CGAffineTransformIdentity; 
        self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(180));
        self.view.bounds = CGRectMake(0.0, 0.0, 768.0, 1004.0);
        
        if (!isShowingDailyView)
        {
            [portrait addSubview:weekView.view];
        }
        // [self RefreshPortraitEventPane];
        
        if (!isShowingDailyView)
        {
            // take week view off the screen, and place it back after rotation completes
            hideWeekView = YES;
            [UIView beginAnimations:@"HideWeeklyView" context:nil];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationDidStopSelector:@selector(removeWeekView:finished:context:)];
            weekView.view.alpha = 0.0;
            [UIView commitAnimations];
        }
    }
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        isPortrait = NO;
        
        self.view = landscape;
        self.view.transform = CGAffineTransformIdentity;
        self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(90));
        self.view.bounds = CGRectMake(0.0, 0.0, 1024.0, 748.0);
        
        if (!isShowingDailyView)
        {
            [self.view addSubview:weekView.view];
        }
        
        [self RefreshLandscapeEventPane];
        
        if (!isShowingDailyView)
        {
            [UIView beginAnimations:@"ShowWeeklyView" context:nil];
            [UIView setAnimationDuration:0.3];
            weekView.view.alpha = 1.0;
            [UIView commitAnimations];
        }
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (!isShowingDailyView)
    {
        if (hideWeekView)
        {
            hideWeekView = NO;
        }
        // show portrait oriented weekview and call refresh on it
    }
}


- (void) RefreshLandscapeEventPane
{
    // Remove all subviews of portraitEventView first
	
    NSArray * array = [rightPane subviews];
    for (int i = 0; i < [array count]; i++)
    {
        [[array objectAtIndex:i] removeFromSuperview];
    }
    
    // Add all events from the event array
    for (int i = 0; i < [eventViewArray count]; i++)
    {
        EventViewController * lEventView = [eventViewArray objectAtIndex:i];
        lEventView.view.frame = CGRectMake(lEventView.view.frame.origin.x, lEventView.view.frame.origin.y, [lEventView getLandscapeWidth], [lEventView getLandscapeHeight]);
        [rightPane addSubview:lEventView.view];
    } 
    
    
    UIView * _calendar = [leftPane viewWithTag:CALENDARTAG];
    [_calendar removeFromSuperview];
    // Set calendar frame
    calendar.view.frame = CGRectMake(0, 0, 444, 216);
    [leftPane addSubview:calendar.view];
	//  SMLog(@"%@", eventViewArray);
}




- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    return;
}


- (void)viewDidUnload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_EVENT_DATA_SYNC object:nil];
	
    [leftPane release];
    leftPane = nil;
    [rightPane release];
    rightPane = nil;
    [rightPaneParent release];
    rightPaneParent = nil;
    [bottomPane release];
    bottomPane = nil;
    [slider release];
    slider = nil;
    [sliderDateView release];
    sliderDateView = nil;
    [activity release];
    activity = nil;
    [showMapButton release];
    showMapButton = nil;
    [refreshButton release];
    refreshButton = nil;
	[HomeButton release];
    HomeButton = nil;
    [ltaskLabel release];
    ltaskLabel = nil;
    [rscheduleLabel release];
    rscheduleLabel = nil;
    [segmentButton release];
    segmentButton = nil;
    [todayBtn release];
    todayBtn = nil;
    [Add_event_Button release];
    Add_event_Button = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    if (isActive)
        appDelegate.didDayViewUnload = YES;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_EVENT_DATA_SYNC object:nil];
    [ltaskLabel release];
    [ltaskLabel release];
    [rscheduleLabel release];
    [todayBtn release];
    [HomeButton release];
    
    isLoaded = NO;
	
    [calendar release];
    
    [slider removeFromSuperview];
    [portraitSlider removeFromSuperview];
    
    [taskView release];
    
    [popOverController release];
    [addTaskView release];
    
    [tasks release];
    
    [_tableView removeFromSuperview];
    
    [segmentButton removeFromSuperview];
    [portraitSegmentButton removeFromSuperview];
    
    [sliderDateView release];
    [weekView release];
    weekView = nil;
	
    [eventViewArray release];
    [activity release];
    [workOrderId release];
    [workOrderIdArrayString release];
    [workOrderIdArray release];
    [eventsArray release];
    [workOrderArray release];
    [prevDateString release];
    [eventDetails release];
    [topLevelId release];
    [accountId release];
    [caseId release];
    [productId release];
    [currentDate release];
    [showMapButton release];
    
    [Add_event_Button release];
    [super dealloc];
}

#pragma mark -
#pragma mark Slider Action
- (IBAction) SetSlider
{
    isDateSetAction = YES;
    
    NSInteger sliderValue = slider.value;
    NSInteger portraitSliderValue = portraitSlider.value;
    
    if (slider.value - sliderValue > 0.5)
    {
        slider.value = sliderValue+1;
    }
    else
    {
        slider.value = sliderValue;
    }
    
    if (portraitSlider.value - portraitSliderValue > 0.5)
    {
        portraitSlider.value = portraitSliderValue+1;
    }
    else
    {
        portraitSlider.value = portraitSliderValue;
    }
    
    [calendar setDate:slider.value];
    
    // Remove all subviews of portraitEventView first
    NSArray * array = [rightPane subviews];
    for (int i = 0; i < [array count]; i++)
    {
        [[array objectAtIndex:i] removeFromSuperview];
    }
    
    [eventViewArray removeAllObjects];
    [eventPositionArray removeAllObjects];
    
	//pavaman 3rd Jan 2011 We need to call SetDate here just like date clicked event, right? Otherwise week view cache does not get updated
	
    /*Shravya-Calendar view 7408 */
    self.isDayButtonClicked = YES;
    self.shouldRedrawWeekView = YES;
    [self setDate:slider.value];
    self.isDayButtonClicked = NO;
    /*Shravya-Calendar view 7408 */
}

#pragma mark -
#pragma mark Calendar Methods

- (IBAction) SetToday
{
	/* if (![appDelegate isInternetConnectionAvailable] && (offline == YES))
	 {
	 [activity stopAnimating];
	 [appDelegate displayNoInternetAvailable];
	 return;
	 }*/
    
    [calendar GoToToday];
}

#pragma mark -
#pragma mark Calendar Delegate Method
#pragma mark Set Slider

- (void) setTotalDivisions:(NSUInteger) total
{
    slider.continuous = NO;
    portraitSlider.continuous = NO;
    slider.minimumValue = portraitSlider.minimumValue = 1;
    slider.maximumValue = portraitSlider.maximumValue = total;
    if (!isDateSetAction)
    {
        slider.value = 0;
        portraitSlider.value = 0;
    }
	
    // Set the slider dates
    switch (total)
    {
        case 28:
            sliderDateView.image = [UIImage imageNamed:@"slider-28-dates.png"];
            break;
        case 29:
            sliderDateView.image = [UIImage imageNamed:@"slider-29-dates.png"];
            break;
        case 30:
            sliderDateView.image = [UIImage imageNamed:@"slider-30-dates.png"];
            break;
        case 31:
            sliderDateView.image = [UIImage imageNamed:@"slider-31-dates.png"];
            break;
        default:
            break;
    }
}

- (void) setDate:(NSUInteger)date
{
	@try{
    didRunOperation = YES;
    
    [activity startAnimating];
    
    [self disableUI];
    
    // Set the slider position based upon the selected date
    if (isDateSetAction)
    {
        isDateSetAction = NO;
    }
    
    slider.value = date;
    portraitSlider.value = date;
    
    // Performance Enhancement - Set isViewDirty to YES only when date is not in weekView's current range
    
    // Samman - 24 Sep, 2011 - added code to release currentDate before retaining
    if ([currentDate retainCount] > 0)
    {
        [currentDate release];
        currentDate = nil;
    }
    currentDate = [[calendar getTodayString] retain];
	
	SMLog(@" SetDate - %@",currentDate);
    SMLog(@"%d", date);
    
    appDelegate.dateClicked = currentDate;
	//pavaman 12th Jan 2011
	if (didFirstTimeLoad == TRUE)
	{
		didFirstTimeLoad = FALSE;		
		NSArray *week_bounds = [calendar getWeekBoundaries:currentDate];
        SMLog(@"%@", week_bounds);
	}
	
    NSString * _date = [calendar getTodayString];
    [self setupTasksForDate:_date];
    
    // Samman - Thu Aug 4, 2011 - CLEAR eventPositionArray before display
    [eventPositionArray removeAllObjects];
    [eventViewArray removeAllObjects];
    
    //Shrini 28-sep-2011   Start
    appDelegate.wsInterface.currentDateRange = [calendar getWeekBoundaries:currentDate];
	
    NSMutableArray * currentDateRange = [[appDelegate getWeekdates:currentDate] retain];
    
        /*Shravya-Calendar view 7408 */
    NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
    appDelegate.wsInterface.eventArray = [appDelegate.calDataBase GetEventsFromDBWithStartDate:[currentDateRange objectAtIndex:0] endDate:[currentDateRange objectAtIndex:1]];
        [aPool drain];
        
    
        [currentDateRange release];
    SMLog(@"app = %@", appDelegate.wsInterface.eventArray);
    
    
    if ( (appDelegate.wsInterface.eventArray != nil ) && [appDelegate.wsInterface.eventArray count] > 0 )
    {
        NSArray * array = [rightPane subviews];
        for (int i = 0; i < [array count]; i++)
        {
            [[array objectAtIndex:i] removeFromSuperview];
        }    
		
        if ([self isDate:currentDate inRange:appDelegate.wsInterface.currentDateRange])
        {
            didRunOperation = YES;
            if ([appDelegate.wsInterface.rescheduleEvent isEqualToString:@"SUCCESS"])
            {
                appDelegate.wsInterface.currentDateRange = [calendar getWeekBoundaries:currentDate];
                appDelegate.wsInterface.startDate = [appDelegate.wsInterface.currentDateRange objectAtIndex:0];
                appDelegate.wsInterface.endDate = [appDelegate.wsInterface.currentDateRange objectAtIndex:1];
				
                SMLog(@"%@ %@", appDelegate.wsInterface.startDate, appDelegate.wsInterface.endDate);
            }
            // Samman - 24 Sep, 2011 - Removed following WSInterface GetEvents call as it is a duplicate call
			//            [appDelegate.wsInterface getEventsForStartDate:appDelegate.wsInterface.startDate EndDate:appDelegate.wsInterface.endDate];
            [self reloadCalendar];
        }
        else
        {
            appDelegate.wsInterface.currentDateRange = [calendar getWeekBoundaries:currentDate];
            
            NSMutableArray * currentDateRange = [[appDelegate getWeekdates:[appDelegate.wsInterface.currentDateRange objectAtIndex:0]] retain];
            
            /*Shravya-Calendar view 7408 */
            NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
            appDelegate.wsInterface.eventArray = [appDelegate.calDataBase GetEventsFromDBWithStartDate:[currentDateRange objectAtIndex:0] endDate:[currentDateRange objectAtIndex:1]];
            //Shrinivas 
			[aPool drain];
            [currentDateRange release];
            SMLog(@"app = %@", appDelegate.wsInterface.eventArray);
            [self reloadCalendar];
        }
    }
    else
    {
        appDelegate.wsInterface.currentDateRange = [calendar getWeekBoundaries:currentDate];
        appDelegate.wsInterface.startDate = [appDelegate.wsInterface.currentDateRange objectAtIndex:0];
        appDelegate.wsInterface.endDate = [appDelegate.wsInterface.currentDateRange objectAtIndex:1];
        
        NSMutableArray * currentDateRange = [[appDelegate getWeekdates:currentDate] retain];
        
        /*Shravya-Calendar view 7408 */
        NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
        appDelegate.wsInterface.eventArray = [appDelegate.calDataBase GetEventsFromDBWithStartDate:[currentDateRange objectAtIndex:0] endDate:[currentDateRange objectAtIndex:1]];
        
		[aPool drain];
        [currentDateRange release];
        SMLog(@"app = %@", appDelegate.wsInterface.eventArray);
        [self reloadCalendar];
    }
    }@catch (NSException *exp) {
        SMLog(@"Exception Name ModalViewController :setDate %@",exp.name);
        SMLog(@"Exception Reason ModalViewController :setDate %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
}

- (void) setEventsView:(NSString *)_date
{
    SMLog(@"%@", appDelegate.wsInterface.eventArray);
	 NSLog(@"setEventsView %d", [appDelegate.wsInterface.eventArray count]);
    EventViewController * events = nil;
    NSDictionary * dict;
    NSString * workOrderName;
    NSString * subject;
	
    SMLog(@"%@ %@", appDelegate.wsInterface.startDate, appDelegate.wsInterface.endDate);
    @try{
    NSArray * array = [rightPane subviews];
    for (int i = 0; i < [array count]; i++)
    {
        [[array objectAtIndex:i] removeFromSuperview];
    } 
    [eventPositionArray removeAllObjects];
    [eventViewArray removeAllObjects];
	
    /*Shravya-Calendar view 7408*/
    NSArray *conflictObjects = [appDelegate.calDataBase readConflictTableForEventInfo];

    SMLog(@"%@", appDelegate.wsInterface.eventArray);
    for ( int i = 0; i < [appDelegate.wsInterface.eventArray count]; i++ )
    {
        dict = [[appDelegate.wsInterface.eventArray objectAtIndex:i] retain]; /*Shravya-Calendar view 7408*/
        SMLog(@"%@", dict);
        workOrderName = [dict objectForKey:ADDITIONALINFO];
        subject = [dict objectForKey:SUBJECT];
        NSDate * temp_start_date_time , *temp_end_date_time ;
        SMLog(@"%@ %@", workOrderName, subject);
        
        NSDate * eventDateTime = [dict objectForKey:ACTIVITYDATE];
        SMLog(@"%@",eventDateTime);
		
        SMLog(@"Setdate = %@", _date);
        
        NSString * activtyDate  = [self dateStringConversion:eventDateTime];
        SMLog(@"%@",activtyDate);
		
        
        eventDateTime = [dict objectForKey:ACTIVITYDTIME];
        SMLog(@"%@",eventDateTime);
        
        NSString * dateString = [self dateStringConversion:eventDateTime];
        
        NSString * activityDateTime = dateString;
        SMLog(@"Activitydatetime = %@", activityDateTime);
        
		//    NSString * eventDate = [activityDateTime substringToIndex:10];
		//    SMLog(@"eventDate = %@", eventDate);
        
        eventDateTime = [dict objectForKey:STARTDATETIME];
        temp_start_date_time = [dict objectForKey:STARTDATETIME];
        SMLog(@"%@",eventDateTime);
        
        dateString = [self dateStringConversion:eventDateTime];
        
        NSString * startDateTime = dateString;
        SMLog(@"Startdatetime = %@", startDateTime);
        
        NSString * eventDate = [startDateTime substringToIndex:10];
		SMLog(@"eventDate = %@", eventDate);
		
        /*Shravya-Calendar view If the event is not today, no need to create nib for it 7408 */
        if ( [_date isEqualToString:eventDate] == NO ) {
            continue;
        }
        eventDateTime = [dict objectForKey:ENDDATETIME];
        temp_end_date_time =  [dict objectForKey:ENDDATETIME];
        
        SMLog(@"%@",eventDateTime);
        
        dateString = [self dateStringConversion:eventDateTime];
        
        NSString * endDateTime = dateString;
        SMLog(@"Enddatetime = %@", endDateTime);
		
        NSString * startime = [startDateTime substringFromIndex:11];
        [startime substringToIndex:2];
		
        SMLog(@"Starttime = %@", startime);
        
        NSString * duration = [dict objectForKey:DURATIONINMIN];
        NSTimeInterval interval;
        if([duration length] == 0)
        {
            if([duration intValue] == 0)
            {
                 interval = [temp_end_date_time timeIntervalSinceDate:temp_start_date_time];
                
            }
            if(interval > 0)
            {
                int duration_temp = interval/60;
                duration = @"";
                duration = [duration stringByAppendingFormat:@"%d",duration_temp];// [NSString stringWithFormat:@"%d",duration_temp];
            }
            
        }
        events = [[EventViewController alloc] initWithNibName:[EventViewController description] bundle:nil];
        events.delegate = self;
        
        // processName, processId, recordId, objectName, createdDate, accountId;
        SMLog(@"%@", [dict objectForKey:WHATID]);
        
        
        events.view.tag = [eventViewArray count];
        
        events.startDate = [self dateStringConversion:[dict objectForKey:STARTDATETIME]];
        events.endDate = [self dateStringConversion:[dict objectForKey:ENDDATETIME]];                    
        events.processId = @"";
        events.eventId = ([dict objectForKey:EVENTID] != nil)?[dict objectForKey:EVENTID]:@"";
        events.recordId = ([dict objectForKey:WHATID] != nil)?[dict objectForKey:WHATID]:@"";
        events.objectName = ([dict objectForKey:OBJECTAPINAME] != nil)?[dict objectForKey:OBJECTAPINAME]:@"";
        events.activityDate = ([dict objectForKey:ACTIVITYDATE] != nil)?[dict objectForKey:ACTIVITYDATE]:@"";
        events.accountId = ([dict objectForKey:ACCOUNTID] != nil)?[dict objectForKey:ACCOUNTID]:@"";
        events.local_id = ([dict objectForKey:EVENT_LOCAL_ID] != nil)?[dict objectForKey:EVENT_LOCAL_ID]:@"";
        NSString * objectAPIName = [dict objectForKey:OBJECTAPINAME];
        if ([objectAPIName isEqualToString:@"service_order__c"])
            objectAPIName = [NSString stringWithFormat:@"%@__%@",SVMX_ORG_PREFIX,objectAPIName];
        objectAPIName = [objectAPIName uppercaseString];
        
        for (int v = 0; v < [appDelegate.view_layout_array count]; v++)
        {
            NSDictionary * dict = [appDelegate.view_layout_array objectAtIndex:v];
            NSString * object_label = [dict objectForKey:VIEW_OBJECTNAME];
            object_label = [object_label uppercaseString];
            SMLog(@"%@ %@", object_label, objectAPIName);
            if ([object_label isEqualToString:objectAPIName])
            {
                events.processId = ([dict objectForKey:VIEW_SVMXC_ProcessID]!=nil)?[dict objectForKey:VIEW_SVMXC_ProcessID]:@"";
                break;
            }
        }
        
        
        //Shrinivas && Abinash
        //NSString * colourCode = [dict objectForKey:COLORCODE];
        NSString * colourCode = [appDelegate.calDataBase getColorCodeForPriority:([dict objectForKey:WHATID] != nil)?[dict objectForKey:WHATID]:@"" objectname:([dict objectForKey:OBJECTAPINAME] != nil)?[dict objectForKey:OBJECTAPINAME]:@""] ;
        UIColor * color = [appDelegate colorForHex:colourCode];
        SMLog(@"%@", color);
        
        
        
        if ( [_date isEqualToString:eventDate] == TRUE )
        {
			NSString * local_id = [appDelegate.databaseInterface getLocalIdFromSFId:events.recordId tableName:[dict objectForKey:OBJECTAPINAME]];
			
            /*Shravya-Calendar view 7408*/
            //Conflict logic is changed. Rather than checking conflict for every event, set of conflict is stored in conflictObjects
            BOOL conflictExists = NO;
            if ([conflictObjects count] > 0) {
                conflictExists = [appDelegate.calDataBase checkSyncConflictFor:events.recordId WithLocalId:local_id withObjectName:[dict objectForKey:OBJECTAPINAME] andArray:conflictObjects];
            }
            /*Shravya-Calendar view */
            
            
            events.conflictFlag = conflictExists;
            SMLog(@"%@ %@", [rightPane description], events.processName);
            [rightPane addSubview:events.view];
            [events setEvent:workOrderName Time:startime Duration:(CGFloat)[duration intValue]/60 Color:color];
            [events setLabelWorkorder:workOrderName Subject:subject];
            
            
            events.view.userInteractionEnabled = TRUE;
            UISwipeGestureRecognizer * swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(EvntgestureRecognizer:)];
            swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
            [events.view addGestureRecognizer:swipeRecognizer];
            
            [swipeRecognizer release];
            
            [eventViewArray addObject:events];
           
        }
        
         /*Shravya-Calendar view 7408 */
         [events release];
         events = nil;
        [dict release];
        dict = nil;
         /*Shravya-Calendar view 7408 */
    }
     }@catch (NSException *exp) {
        SMLog(@"Exception Name ModalViewController :setEventsView %@",exp.name);
        SMLog(@"Exception Reason ModalViewController :setEventsView %@",exp.reason);
         [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    @finally
    {
    [activity stopAnimating];
	
    [self didGetAllEvents];
     }
}


-(void)EvntgestureRecognizer:(id)sender
{
    NSLog(@"swiped on Event");
    UIGestureRecognizer * gestureRecog = sender;
    if([gestureRecog.view isKindOfClass:[EventViewController class]])
    {
//        EventViewController * gesture_view = (EventViewController *)gestureRecog.view;
//        [self SFMeditEvent:gesture_view.recordId];
        
        NSLog(@"its a view controller");
        
        }
    
    
}
- (void) didGetAllEvents
{
    calendarDidLoad = YES;
    [self didAllDataLoad];
}

- (NSString *)dateStringConversion:(NSDate*)date 
{
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    NSString * dateString = [dateFormatter stringFromDate:date];
    return  dateString;
}

#define START_DATE          0
#define END_DATE            1

- (BOOL) isDate:(NSString *)date inRange:(NSArray *)dateRange
{
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    if ([date length] > 10)
        date = [date substringToIndex:10];
    NSDate * selectedDate = [dateFormatter dateFromString:date];
    
    NSString * _startDate = [dateRange objectAtIndex:START_DATE];
    if ([_startDate length] > 10)
        _startDate = [_startDate substringToIndex:10];
    NSDate * startDate = [dateFormatter dateFromString:_startDate];
    
    NSString * _endDate = [dateRange objectAtIndex:END_DATE];
    if ([_endDate length] > 10)
        _endDate = [_endDate substringToIndex:10];
    NSDate * endDate = [dateFormatter dateFromString:_endDate];
    
    NSTimeInterval selectedDateInterval = [selectedDate timeIntervalSince1970];
    NSTimeInterval startDateInterval = [startDate timeIntervalSince1970];
    NSTimeInterval endDateInterval = [endDate timeIntervalSince1970];
    
    if ((selectedDateInterval >= startDateInterval) && (selectedDateInterval <= endDateInterval))
        return YES;
    return NO;
}

- (IBAction) IncrDate
{
	/* if (![appDelegate isInternetConnectionAvailable] && (offline == YES))
	 {
	 [activity stopAnimating];
	 [appDelegate displayNoInternetAvailable];
	 return;
	 }*/
    
    if (slider.value < slider.maximumValue)
        ++slider.value;
    else
    {
        [calendar NextMonthStart];
		//pavaman 16th Jan 2011
		[calendar setDate:slider.value];
        return;
    }
    
    if (portraitSlider.value < portraitSlider.maximumValue)
        ++portraitSlider.value;
    
    [calendar setDate:slider.value];
    
    // Remove all subviews of portraitEventView first
    NSArray * array = [rightPane subviews];
    for (int i = 0; i < [array count]; i++)
    {
        [[array objectAtIndex:i] removeFromSuperview];
    }
	
	//pavaman 3rd jan 2011 . call setdate instead
    [self setDate:slider.value];
}

- (IBAction) DecrDate
{
	/* if (![appDelegate isInternetConnectionAvailable] && (offline == YES))
	 {
	 [activity stopAnimating];
	 [appDelegate displayNoInternetAvailable];
	 return;
	 }*/
    
    if (slider.value > slider.minimumValue)
        --slider.value;
    else
    {
        [calendar PrevMonthEnd];
		//pavaman 16th Jan 2011
		[calendar setDate:slider.value];
        return;
    }
    
    if (portraitSlider.value > portraitSlider.minimumValue)
        --portraitSlider.value;
    
    [calendar setDate:slider.value];
    
    // Remove all subviews of portraitEventView first
    NSArray * array = [rightPane subviews];
    for (int i = 0; i < [array count]; i++)
    {
        [[array objectAtIndex:i] removeFromSuperview];
    }
	
	//pavaman 3rd jan 2011 . call setdate instead
    [self setDate:slider.value];
}

#pragma mark -
#pragma mark UIPopoverController Delegate Method

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

#pragma mark -
#pragma mark WeeklyViewControllerDelegate Method

- (void) enableRefreshButton:(BOOL)flag
{
    [refreshButton setUserInteractionEnabled:flag];
}

- (void) showSFMForWeek:(NSDictionary *)event
{
    appDelegate.From_SFM_Search=@"";
    appDelegate.showUI = FALSE;    //btn merge
    [activity startAnimating];
    appDelegate.sfmPageController = [[[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:TRUE] autorelease];
    
    NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    NSString * warning = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_WARNING];
    NSString * noView = [appDelegate.wsInterface.tagsDictionary objectForKey:NO_VIEW_PROCESS];

    if ([appDelegate.SFMPage retainCount] > 0)
    {
        appDelegate.SFMPage = nil;
    }
    @try{
    NSString * processId =  [appDelegate.switchViewLayouts objectForKey:[event objectForKey:OBJECTAPINAME]];
    appDelegate.sfmPageController.processId = (processId != nil)?processId:[event objectForKey:PROCESSID];
    
    NSString * object_name = [event objectForKey:OBJECTAPINAME];
    appDelegate.sfmPageController.objectName = [event objectForKey:OBJECTAPINAME];
	
    NSString * recordId =  [event objectForKey:RECORDID];
    if(recordId == nil || [recordId length] == 0)
    {
        NSString * version = [appDelegate serverPackageVersion];
        int _stringNumber = [version intValue];
        if(_stringNumber >=  (KMinPkgForScheduleEvents * 100000))
        {
            NSArray * processids_array = [appDelegate.databaseInterface getEventProcessIdForProcessType:VIEWRECORD SourceObject:@""];
            
            if([processids_array count] > 0)
            {
                NSString * event_local_id = [event objectForKey:EVENT_LOCAL_ID];
                NSString * event_process_id = [processids_array objectAtIndex:0];
                appDelegate.sfmPageController = [[[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:NO] autorelease];
                NSString * processId_for_event =  [appDelegate.switchViewLayouts objectForKey:@"Event"];
                appDelegate.sfmPageController.processId = (processId_for_event != nil)?processId_for_event:event_process_id;
                appDelegate.sfmPageController.recordId = event_local_id;
                //sahana offline
                appDelegate.sfmPageController.objectName = @"Event";
                
                processInfo * pinfo =  [appDelegate getViewProcessForObject:@"Event" record_id:event_local_id processId:appDelegate.sfmPageController.processId isswitchProcess:FALSE];
                BOOL process_exist = pinfo.process_exists;
                if(process_exist)
                {
                    appDelegate.sfmPageController.processId = pinfo.process_id;
                    [appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
                    [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
                    
                    [appDelegate.sfmPageController.detailView view];
                    [self presentViewController:appDelegate.sfmPageController animated:YES completion:nil];
                    [appDelegate.sfmPageController.detailView didReceivePageLayoutOffline];
                }
                else
                {
                    UIAlertView * alert1 = [[UIAlertView alloc] initWithTitle:warning message:noView delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
                    [alert1 show];
                    [alert1 release];
                }
                
                
            }
            else
            {
                UIAlertView * alert1 = [[UIAlertView alloc] initWithTitle:warning message:noView delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
                [alert1 show];
                [alert1 release];
            }
            
        }
        else
        {
            NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:cal_day_week_view_view_Id];
            NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
            NSString * Ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
            
            UIAlertView * alert1 = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:Ok otherButtonTitles:nil];
            [alert1 show];
            [alert1 release];
            [activity stopAnimating];
            return;
        }

    }
    else
    {
        appDelegate.sfmPageController.conflictExists  = FALSE;
        NSString * local_id = [appDelegate.databaseInterface getLocalIdFromSFId:recordId tableName:object_name];
        appDelegate.sfmPageController.recordId = local_id;
        
        
        appDelegate.sfmPageController.activityDate = [event objectForKey:ACTIVITYDATE];
        appDelegate.sfmPageController.accountId = [event objectForKey:ACCOUNTID];
        appDelegate.sfmPageController.topLevelId = [event objectForKey:TOPLEVELID];
        appDelegate.sfmPageController.conflictExists = [[event objectForKey:ISCONFLICT] boolValue];
        
        [appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
        [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        
        didRunOperation = YES;
        
        didRunOperation = NO;
        
        //sahana - offline
        appDelegate.didsubmitModelView = FALSE;
        
        
        processInfo * pinfo =  [appDelegate getViewProcessForObject:object_name record_id:local_id processId:appDelegate.sfmPageController.processId isswitchProcess:FALSE];
        BOOL process_exist = pinfo.process_exists;
        
        //check For view process
        if(process_exist)
        {
            appDelegate.sfmPageController.processId = pinfo.process_id;
            [appDelegate.sfmPageController.detailView view];
            [self presentViewController:appDelegate.sfmPageController animated:YES completion:nil];
            [appDelegate.sfmPageController.detailView didReceivePageLayoutOffline];
        }
        else
        {
            UIAlertView * alert1 = [[UIAlertView alloc] initWithTitle:warning message:noView delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
            [alert1 show];
            [alert1 release];
            [activity stopAnimating];
            return;
        }
    }
	}@catch (NSException *exp) {
	SMLog(@"Exception Name ModalViewController :showSFMForWeek %@",exp.name);
	SMLog(@"Exception Reason ModalViewController :showSFMForWeek %@",exp.reason);
	[appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

    [activity stopAnimating];
	
}

- (void) showJobWithEventDetail:(ZKSObject *)eventDetail WorkOrderDetail:(NSDictionary *)workOrderDetail
{
    
}

- (void) finishedLoading
{
    NSArray * array = [rightPane subviews];
    for (int i = 0; i < [array count]; i++)
    {
        [[array objectAtIndex:i] removeFromSuperview];
    }    
    
    [eventViewArray removeAllObjects];
    [eventPositionArray removeAllObjects];
    
    [activity stopAnimating];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark -
#pragma mark EventViews Touch Methods

- (NSSet *)touchesForGestureRecognizer:(UIGestureRecognizer *)gesture
{
    
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    @try
    {
        if (!allowTouches)
            return;
        // We only support single touches, so anyObject retrieves just that touch from touches
        UITouch *touch = [touches anyObject];
        BOOL flag = NO;
        eventView = nil;
        // Only move the event view if the touch was in the placard view
        if ([touch view] == rightPane)
        {
            initialPoint = [touch locationInView:rightPaneParent];
        }
        // if ([touch view] == eventView.view)
        {
            for (int i = 0; i < [eventViewArray count]; i++)
            {
                eventView = [eventViewArray objectAtIndex:i];
                if ([touch view] == eventView.view)
                {
                    initialPosition= eventView.view.frame;
                    flag = YES;
                    [rightPane bringSubviewToFront:eventView.view];
                    break;
                }
            }
        }
        
        if (!flag) return;
    }
    @catch (NSException *exception)
    {
        SMLog(@"touchesBegan: Caught & Handled Exception.");
        [activity stopAnimating];
    }
    @finally
    {
        SMLog(@"touchesBegan: Finally Handled Exception.");
        [activity stopAnimating];
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!allowTouches)
        return;
    
    UITouch * touch = [touches anyObject];
    
    if ([touch view] == self.view)
        return;
    
    if ([touch view] == slider)
        return;
    
    if ([touch view] == rightPane)
    {
        CGPoint location = [touch locationInView:rightPaneParent];
        // // SMLog(@"Right pane y = %f", rightPane.frame.origin.y);
        if ((rightPane.frame.origin.y <= 0) && (rightPane.frame.origin.y >= (-1 * rightPane.frame.size.height + rightPaneParent.frame.size.height)))
        {
            CGFloat diff = location.y - initialPoint.y;        
            rightPane.frame = CGRectMake(0, rightPane.frame.origin.y+diff, rightPane.frame.size.width, rightPane.frame.size.height);
			
            initialPoint = location;
        }
		
        return;
    }
    
    if ([touch view] == eventView.view)
    {
        // CGRect rect = eventView.view.frame;
		CGPoint location = [touch locationInView:rightPane];
        
        CGRect locationRect = [eventView getRectForLocation:location];
        if (CGRectEqualToRect(locationRect, CGRectZero))
        {
            return;
        }
		
        if (!CGRectEqualToRect(locationRect, eventView.view.frame))
        {
            if (((eventView.view.frame.origin.y + eventView.view.frame.size.height) >= (kTIMEFLOOR-kGAP)) &&
                CGRectIntersectsRect(eventView.view.frame, locationRect))
				
            {
                return;
            }
            // Change eventView's frame
            didMoveEvent = YES;
            isViewDirty = YES; // Reset only when toggling over to Week View
            [UIView beginAnimations:@"MoveEventView" context:nil];
            [UIView setAnimationDuration:0.3];
            eventView.view.frame = CGRectMake(eventView.view.frame.origin.x, locationRect.origin.y,
                                              eventView.view.frame.size.width, eventView.view.frame.size.height);
            [UIView commitAnimations];
            return;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    @try
	{
        if (!allowTouches)
            return;
        
        UITouch * touch = [touches anyObject];
        
        if ([touch view] == self.view)
            return;
        
        if ([touch view] == slider)
            return;
        
        if ([touch view] == rightPane)
        {
            if (rightPane.frame.origin.y > 0)
            {
                [UIView beginAnimations:@"resetRightPane" context:nil];
                [UIView setAnimationDuration:0.3];
                rightPane.frame = CGRectMake(0, 0, rightPane.frame.size.width, rightPane.frame.size.height);
                [UIView commitAnimations];
            }
            
            if (rightPane.frame.origin.y < (-1 * rightPane.frame.size.height + rightPaneParent.frame.size.height))
            {
                [UIView beginAnimations:@"resetRightPane" context:nil];
                [UIView setAnimationDuration:0.3];
                rightPane.frame = CGRectMake(0, (-1 * rightPane.frame.size.height + rightPaneParent.frame.size.height), rightPane.frame.size.width, rightPane.frame.size.height);
                [UIView commitAnimations];
            }
        }
        EventViewController *calEventView = [eventView retain];
        // If the touch was in the placardView, bounce it back to the center
        if ([touch view] == calEventView.view)
        {
            if (!didMoveEvent)
            {
                NSString * confictStr = [NSString stringWithFormat:@"%d",calEventView.conflictFlag];
                NSArray * keys = [NSArray arrayWithObjects:PROCESSID, RECORDID, OBJECTAPINAME, ACTIVITYDATE, ACCOUNTID, ISCONFLICT, EVENT_LOCAL_ID,nil];
                NSArray * objects = [NSArray arrayWithObjects:calEventView.processId, calEventView.recordId, calEventView.objectName, calEventView.activityDate, calEventView.accountId, confictStr,calEventView.local_id, nil];
                NSDictionary * _dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                [self disableUI];
                [self showSFMWithDayEvent:_dict];
                
            }
            else
            {
                [self disableUI];
                oldEventRect = calEventView.selfFrame;
                [calEventView moveTo:calEventView.view.frame];
                
                if(Continue_rescheduling)
                {
                    didRunOperation = YES;
                    if ([updatestartDateTime length] > 0 && [updateendDateTime length] > 0)
                    {
                        SMLog(@"%@", updatestartDateTime);
                        SMLog(@"%@", calEventView.eventId);
                        [appDelegate.calDataBase updateMovedEventWithStartTime:updatestartDateTime EndDate:updateendDateTime RecordID:calEventView.eventId event_localId:calEventView.local_id];
                        
                        //sahana Event Update  to datatriler table
                        NSString * local_id = [appDelegate.databaseInterface getLocalIdFromSFId:calEventView.eventId tableName:@"Event"];
                        //sahana 26/Feb
						// BOOL does_exists = [appDelegate.databaseInterface DoesTrailerContainTheRecord:local_id operation_type:UPDATE object_name:@"Event"];
						//  if(!does_exists)
                        {
							//Sync_Override
                            [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:local_id SF_id:calEventView.eventId record_type:MASTER operation:UPDATE object_name:@"Event" sync_flag:@"false" parentObjectName:@"" parent_loacl_id:@"" webserviceName:@"" className:@"" synctype:AGRESSIVESYNC headerLocalId:local_id requestData:nil finalEntry:NO];
                            
                        }
                        [appDelegate setAgrressiveSync_flag];
						//RADHA Defect Fix 5542
						appDelegate.shouldScheduleTimer = YES;
                        [appDelegate callDataSync];
                        
                        [activity stopAnimating];
                        updatestartDateTime = @"";
                        updateendDateTime = @"";
                    }
                    
                    appDelegate.wsInterface.didRescheduleEvent = FALSE; // Reusing this variable for get Events purpose
                    
                    //Shrinivas
                    
                    SMLog(@"%@ %@",appDelegate.wsInterface.startDate, appDelegate.wsInterface.endDate);
                    NSMutableArray * currentDateRange = [[appDelegate getWeekdates:currentDate] retain];
                    
                    
                    /*Shravya-Calendar view 7408 */
                    NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
                    appDelegate.wsInterface.eventArray = [appDelegate.calDataBase GetEventsFromDBWithStartDate:[currentDateRange objectAtIndex:0] endDate:[currentDateRange objectAtIndex:1]];
                    
                    
					[aPool drain];
                    
                    [currentDateRange release];
					
                    if ([appDelegate.wsInterface.rescheduleEvent isEqualToString:@"SUCCESS"])
                    {
                        [activity stopAnimating];
                    }
                    else
                        [activity stopAnimating];
                }
                else if(Event_edit_flag)
                {
                    NSString * local_id = calEventView.local_id;
                    [self SFMeditEvent:local_id what_id:calEventView.recordId];
                }
                else
                {
                    
                }
            }
        }
        didMoveEvent = NO;
        [calEventView release];
    }
    @catch (NSException *exception)
    {
        SMLog(@"touchesEnded: Caught & Handled Exception.");
    }
    @finally
    {
        SMLog(@"touchesEnded: Finally Handled Exception.");
    }
	[self enableUI];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    @try
    {
        if (!allowTouches)
            return;
        
        UITouch *touch = [touches anyObject];
        {
            // If the touch was in the placardView, bounce it back to the center
            if ([touch view] == eventView.view && touch.tapCount > 0)
            {
                eventView.view.frame = initialPosition;
                eventView = nil;
                initialPosition = CGRectZero;
            }
        }
    }
    @catch (NSException *exception)
    {
        SMLog(@"touchesCancelled: Caught & Handled Exception.");
    }
    @finally
    {
        SMLog(@"touchesCancelled: Finally Handled Exception.");
    }
}

-(void) SFMEditForWeekView:(NSDictionary  *)dict
{
    
    if ([appDelegate.SFMPage retainCount] > 0)
    {
        appDelegate.SFMPage = nil;
    }
    NSString * what_id = [dict objectForKey:RECORDID];
    NSString * local_id = [dict objectForKey:EVENT_LOCAL_ID];
    NSArray * processids_array = [appDelegate.databaseInterface getEventProcessIdForProcessType:EDIT SourceObject:@""];
    NSString * process_id = @"";
    NSString * referenceto_process_id = @"";
    for(NSString * temp_process_id in processids_array)
    {
        BOOL whatid_exist = FALSE;
        NSMutableDictionary * page_layoutInfo = [appDelegate.databaseInterface  queryProcessInfo:temp_process_id object_name:@"Event"];
        NSMutableDictionary * _header =  [page_layoutInfo objectForKey:@"header"];
        NSMutableArray * header_sections =  [_header objectForKey:@"hdr_Sections"];
        for(int i=0; i <[header_sections count] ;i++)
        {
            NSDictionary * section_info = [header_sections objectAtIndex:i];
            NSMutableArray * sectionFileds= [section_info objectForKey:@"section_Fields"];
            
            for(int j= 0;j<[sectionFileds count]; j++)
            {
                NSDictionary * filed_info =[sectionFileds objectAtIndex:j];
                NSString * field_api_name = [filed_info objectForKey:gFIELD_API_NAME];
                if([field_api_name isEqualToString:@"WhatId"])
                {
                    whatid_exist = TRUE;
                    break;
                }
                
            }
        }
        if(whatid_exist)
        {
            referenceto_process_id = temp_process_id;
            continue;
        }
        else
        {
            process_id = temp_process_id;
            break;
        }
        
    }
    
    if([process_id length] > 0)
    {
        appDelegate.sfmPageController = [[[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:NO] autorelease];
        if([what_id length] == 0 )
        {
            appDelegate.sfmPageController.processId = process_id;
            if([process_id length] ==0)
            {
                
                NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
                NSString * warning = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_WARNING];
                NSString * noView = [appDelegate.wsInterface.tagsDictionary objectForKey:NO_VIEW_PROCESS];
                UIAlertView * alert1 = [[UIAlertView alloc] initWithTitle:warning message:noView delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
                [alert1 show];
                [alert1 release];
                [activity stopAnimating];
                return;
            }
        }
        else
        {
            if([referenceto_process_id length] == 0)
            {
                 appDelegate.sfmPageController.processId = process_id;
            }
            else
            {
                appDelegate.sfmPageController.processId = referenceto_process_id;
            }
        }
        
        appDelegate.sfmPageController.recordId = local_id;
        //sahana offline
        appDelegate.sfmPageController.objectName = @"Event";
        
        [appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
        [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        
        [self presentViewController:appDelegate.sfmPageController animated:YES completion:^(void){}];
        [appDelegate.sfmPageController.detailView didReceivePageLayoutOffline ];
    }
    else
    {
        NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
        NSString * warning = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_WARNING];
        NSString * noView = [appDelegate.wsInterface.tagsDictionary objectForKey:NO_VIEW_PROCESS];
        UIAlertView * alert1 = [[UIAlertView alloc] initWithTitle:warning message:noView delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
        [alert1 show];
        [alert1 release];
        [activity stopAnimating];
        return;
        
    }
    

}

-(void) SFMeditEvent:(NSString *)record_id what_id:(NSString *)what_id
{
    if ([appDelegate.SFMPage retainCount] > 0)
    {
        appDelegate.SFMPage = nil;
    }
    
    NSArray * processids_array = [appDelegate.databaseInterface getEventProcessIdForProcessType:EDIT SourceObject:@""];
    NSString * process_id = @"";
     NSString * referenceto_process_id = @"";
    for(NSString * temp_process_id in processids_array)
    {
        BOOL whatid_exist = FALSE;
        NSMutableDictionary * page_layoutInfo = [appDelegate.databaseInterface  queryProcessInfo:temp_process_id object_name:@"Event"];
        NSMutableDictionary * _header =  [page_layoutInfo objectForKey:@"header"];
        NSMutableArray * header_sections =  [_header objectForKey:@"hdr_Sections"];
        for(int i=0; i <[header_sections count] ;i++)
        {
            NSDictionary * section_info = [header_sections objectAtIndex:i];
            NSMutableArray * sectionFileds= [section_info objectForKey:@"section_Fields"];
            
            for(int j= 0;j<[sectionFileds count]; j++)
            {
                NSDictionary * filed_info =[sectionFileds objectAtIndex:j];
                NSString * field_api_name = [filed_info objectForKey:gFIELD_API_NAME];
                if([field_api_name isEqualToString:@"WhatId"])
                {
                    whatid_exist = TRUE;
                    break;
                }
            
            }
        }
        if(whatid_exist)
        {
            referenceto_process_id = temp_process_id;
            continue;
        }
        else
        {
            process_id = temp_process_id;
            break;
        }


    }
    
    if([process_id length] > 0)
    {
//        NSString * process_id = [processids_array objectAtIndex:0];
        appDelegate.sfmPageController = [[[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:NO] autorelease];
        if([what_id length] == 0 )
        {
            appDelegate.sfmPageController.processId = process_id;
            if([process_id length] ==0)
            {
                
                NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
                NSString * warning = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_WARNING];
                NSString * noView = [appDelegate.wsInterface.tagsDictionary objectForKey:NO_VIEW_PROCESS];
                UIAlertView * alert1 = [[UIAlertView alloc] initWithTitle:warning message:noView delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
                [alert1 show];
                [alert1 release];
                [activity stopAnimating];
                return;
            }
            
        }
        else
        {
            if([referenceto_process_id length] == 0)
            {
                appDelegate.sfmPageController.processId = process_id;
            }
            else
            {
                appDelegate.sfmPageController.processId = referenceto_process_id;
            }
        }
        appDelegate.sfmPageController.recordId = record_id;
        //sahana offline
        appDelegate.sfmPageController.objectName = @"Event";
        
        [appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
        [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        
        [self presentViewController:appDelegate.sfmPageController animated:YES completion:^(void){}];
        [appDelegate.sfmPageController.detailView didReceivePageLayoutOffline ];
    }
    else
    {
        NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
        NSString * warning = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_WARNING];
        NSString * noView = [appDelegate.wsInterface.tagsDictionary objectForKey:NO_VIEW_PROCESS];
        UIAlertView * alert1 = [[UIAlertView alloc] initWithTitle:warning message:noView delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
        [alert1 show];
        [alert1 release];
        [activity stopAnimating];
        return;
        
    }
    

}

#pragma mark - SFM Page Display Mathod
- (void) showSFMWithDayEvent:(NSDictionary *)event
{
    appDelegate.From_SFM_Search=@"";
    appDelegate.showUI = FALSE;   //btn merge
    [activity startAnimating];
    appDelegate.sfmPageController = [[[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:TRUE] autorelease];
    
    if ([appDelegate.SFMPage retainCount] > 0)
    {
        appDelegate.SFMPage = nil;
    }   
	@try{
    NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    NSString * warning = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_WARNING];
    NSString * noView = [appDelegate.wsInterface.tagsDictionary objectForKey:NO_VIEW_PROCESS];
    NSString * processId =  [appDelegate.switchViewLayouts objectForKey:[event objectForKey:OBJECTAPINAME]];
    appDelegate.sfmPageController.processId = (processId != nil)?processId:[event objectForKey:PROCESSID];
    
    NSString * object_name = [event objectForKey:OBJECTAPINAME];
    appDelegate.sfmPageController.objectName = [event objectForKey:OBJECTAPINAME];
	
    
    NSString * recordId =  [event objectForKey:RECORDID];
    
    if(recordId == nil || [recordId length] == 0)
    {
        NSString * version = [appDelegate serverPackageVersion];
        int _stringNumber = [version intValue];
        if(_stringNumber >=  (KMinPkgForScheduleEvents * 100000))
        {
            NSArray * processids_array = [appDelegate.databaseInterface getEventProcessIdForProcessType:VIEWRECORD SourceObject:@""];

            if([processids_array count] > 0)
            {
                NSString * event_local_id = [event objectForKey:EVENT_LOCAL_ID];
                NSString * event_process_id = [processids_array objectAtIndex:0];
                appDelegate.sfmPageController = [[[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:NO] autorelease];
                
                NSString * processId_for_event =  [appDelegate.switchViewLayouts objectForKey:@"Event"];
                appDelegate.sfmPageController.processId = (processId_for_event != nil)?processId_for_event:event_process_id;
                appDelegate.sfmPageController.recordId = event_local_id;
                //sahana offline
                appDelegate.sfmPageController.objectName = @"Event";
                
                processInfo * pinfo =  [appDelegate getViewProcessForObject:@"Event" record_id:event_local_id processId:appDelegate.sfmPageController.processId isswitchProcess:FALSE];
                BOOL process_exist = pinfo.process_exists;
                if(process_exist)
                {
                     appDelegate.sfmPageController.processId = pinfo.process_id;
                    [appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
                    [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
                    [self presentViewController:appDelegate.sfmPageController animated:YES completion:^(void){}];
                    [appDelegate.sfmPageController.detailView didReceivePageLayoutOffline ];
                }
                else
                {
                    UIAlertView * alert1 = [[UIAlertView alloc] initWithTitle:warning message:noView delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
                    [alert1 show];
                    [alert1 release];
                }
                
                
            }
            else
            {
                UIAlertView * alert1 = [[UIAlertView alloc] initWithTitle:warning message:noView delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
                [alert1 show];
                [alert1 release];
            }
             
        }
        else
        {
            NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:cal_day_week_view_view_Id];
            NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
            NSString * Ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
            
            UIAlertView * alert1 = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:Ok otherButtonTitles:nil];
            [alert1 show];
            [alert1 release];
            [activity stopAnimating];
            return;
        }
        
    }
    else
    {
        appDelegate.sfmPageController.conflictExists = FALSE;
        NSString * local_id = [appDelegate.databaseInterface getLocalIdFromSFId:recordId tableName:object_name];
        appDelegate.sfmPageController.recordId = local_id;
        
        
        appDelegate.sfmPageController.activityDate = [event objectForKey:ACTIVITYDATE];
        appDelegate.sfmPageController.accountId = [event objectForKey:ACCOUNTID];
        appDelegate.sfmPageController.topLevelId = [event objectForKey:TOPLEVELID];
        appDelegate.sfmPageController.conflictExists = [[event objectForKey:ISCONFLICT] boolValue];
        
        [appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
        [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        
        didRunOperation = YES;
        
        didRunOperation = NO;
        
        //sahana - offline
        appDelegate.didsubmitModelView = FALSE;
        
        
        processInfo * pinfo =  [appDelegate getViewProcessForObject:object_name record_id:local_id processId:appDelegate.sfmPageController.processId isswitchProcess:FALSE];
        BOOL process_exist = pinfo.process_exists;
        
        //check For view process
        if(process_exist)
        {
            appDelegate.sfmPageController.processId = pinfo.process_id;
            [appDelegate.sfmPageController.detailView view];
            [self presentViewController:appDelegate.sfmPageController animated:YES completion:nil];
            [appDelegate.sfmPageController.detailView didReceivePageLayoutOffline];
        }
        else
        {
            UIAlertView * alert1 = [[UIAlertView alloc] initWithTitle:warning message:noView delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];        
            [alert1 show];
            [alert1 release];
            [activity stopAnimating];
            return;
        }
	
    }
    }@catch (NSException *exp) {
        SMLog(@"Exception Name ModalViewController :showSFMWithDayEvent %@",exp.name);
        SMLog(@"Exception Reason ModalViewController :showSFMWithDayEvent %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    @finally {
    [activity stopAnimating];
	}
}

- (IBAction) displayUser:(id)sender
{
    UIButton * button = (UIButton *)sender;
    About * about = [[[About alloc] initWithNibName:@"About" bundle:nil] autorelease];
    UIPopoverController * popover = [[UIPopoverController alloc] initWithContentViewController:about];
    [popover setContentViewController:about animated:YES];
    [popover setPopoverContentSize:about.view.frame.size];
    [popover presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

#pragma mark - SFMPage Delegate Method
- (void) Back
{
}

#pragma mark -
#pragma mark JobViewControllerDelegate Methods

- (void) ShowOtherView
{
    // [self ShowMap];
}

- (void) closeJobView
{
}

#pragma mark - Launch SmartVan

- (IBAction) launchSmartVan
{
    HTMLBrowser * htmlBrowser = [[HTMLBrowser alloc] initWithURLString:@"http://www.thesmartvan.com"];
    htmlBrowser.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    htmlBrowser.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:htmlBrowser animated:YES completion:nil];
    [htmlBrowser release];
}

- (void) enableUI
{
    [calendar enableUI];
    [refreshButton setUserInteractionEnabled:YES];
    [incrDateBtn setUserInteractionEnabled:YES];
    [decrDateBtn setUserInteractionEnabled:YES];
    [todayBtn setUserInteractionEnabled:YES];
    [slider setUserInteractionEnabled:YES];
    allowTouches = YES;
    [leftPane setUserInteractionEnabled:YES];
    [rightPane setUserInteractionEnabled:YES];
    [rightPaneParent setUserInteractionEnabled:YES];
    [self.view setUserInteractionEnabled:YES];
    [[super view] setUserInteractionEnabled:YES];
}

- (void) disableUI
{
	//    [calendar disableUI];
	//    [refreshButton setUserInteractionEnabled:NO] ;
	//    [incrDateBtn setUserInteractionEnabled:NO];
	//    [decrDateBtn setUserInteractionEnabled:NO];
	//    [todayBtn setUserInteractionEnabled:NO];
	//    [slider setUserInteractionEnabled:NO];
    allowTouches = NO;
    [leftPane setUserInteractionEnabled:NO];
    [rightPane setUserInteractionEnabled:NO];
	//    [rightPaneParent setUserInteractionEnabled:NO];
	//    [self.view setUserInteractionEnabled:NO];
	//    [[super view] setUserInteractionEnabled:NO];
}



- (void) showManualSyncUI
{
    ManualDataSync *manualDataSync = [[ManualDataSync alloc] initWithNibName:@"ManualDataSync" bundle:nil];
    
    manualDataSync.modalPresentationStyle = UIModalPresentationFullScreen;
    manualDataSync.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    //appDelegate.wsInterface.manualDataSyncUIDelegate = manualDataSync;
    
    [self presentViewController:manualDataSync animated:YES completion:nil];
}

-(void) showModalSyncStatus
{
    [appDelegate setSyncStatus:appDelegate.SyncStatus];
}


@end
