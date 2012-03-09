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

#define VAL 2
extern void SVMXLog(NSString *format, ...);
@implementation ModalViewController
@synthesize Continue_rescheduling;
@synthesize weekView;
@synthesize eventDetails, activity;
@synthesize eventView;
@synthesize HomeButton;

@synthesize didDismissalertview;

- (void)viewWillAppear:(BOOL)animated
{
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInternetConnectionChange:) name:kInternetConnectionChanged object:nil];
    }
    
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self disableUI];

    isActive = YES;

	//pavaman 12th Jan 2011
	didFirstTimeLoad = TRUE;
	
	//pavaman 16th Jan 2011
	workOrderArray = [[NSMutableArray alloc] initWithCapacity:0];
	eventViewArray = [[NSMutableArray alloc] initWithCapacity:0];
    eventPositionArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
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
    
    addTaskView = nil;
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
    
    [segmentButton setImage:[UIImage imageNamed:@"iService-Day-Button-Down-State.png"] forSegmentAtIndex:0];
    [segmentButton setImage:[UIImage imageNamed:@"iService-Week-Button-Up-State.png"] forSegmentAtIndex:1];
}

- (void) didInternetConnectionChange:(NSNotification *)notification
{
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber * currentReach = (NSNumber *) notification.object;
    BOOL isReachable = [currentReach boolValue];
    if (isReachable)
    {
        NSLog(@"ModalViewController Internet Reachable");
        // Special Handling
        // Enable slider
        [slider setUserInteractionEnabled:YES];
    }
    else
    {
        NSLog(@"ModalViewController Internet Not Reachable");
        // Special Handling
        // Disable slider
        [slider setUserInteractionEnabled:NO];
        if (didRunOperation)
        {
            [activity stopAnimating];
            [appDelegate displayNoInternetAvailable];
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
    NSLog(@"Removed Crash Protector");
    
    [self enableUI];
}

- (IBAction) Help;
{
    appDelegate.didUserInteract = YES;
    if (!appDelegate.isInternetConnectionAvailable)
    {
        [appDelegate displayNoInternetAvailable];
        return;
    }

    HelpController * help = [[HelpController alloc] initWithNibName:@"HelpController" bundle:nil];
    help.modalPresentationStyle = UIModalPresentationFullScreen;
    help.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    if (isShowingDailyView)
        help.helpString = @"day-view.html";
    else
        help.helpString = @"week-view.html";
    [self presentModalViewController:help animated:YES];
    [help release];
}

#pragma mark -
#pragma mark Setup Tasks
- (void) setupTasksForDate:(NSString *)date
{
    NSLog(@"SetupTask");
    [iOSObject queryTasksForDate:date];
}

// Callback Method
- (void) didQueryTasksForDate:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    NSLog(@"didQueryTasks");
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
    NSDictionary * startEndTime = [event getEventStartEndTime];
    NSLog(@"%@", startEndTime);
    
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

    startTime = [iOSInterfaceObject getGMTFromLocalTime:startTime];
    endTime = [iOSInterfaceObject getGMTFromLocalTime:endTime];
    
    updatestartDateTime = startTime;
    updateendDateTime = endTime;
    
    updateendDateTime = [updateendDateTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    updateendDateTime = [updateendDateTime stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    
    updatestartDateTime = [updatestartDateTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    updatestartDateTime = [updatestartDateTime stringByReplacingOccurrencesOfString:@"Z" withString:@""];

} 
//sahana 12th sept 2011
- (void) Continuetherescheduling:(BOOL)continue_rescheduling;
{
    Continue_rescheduling = continue_rescheduling;
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
    appDelegate.didUserInteract = YES;
    [self disableUI];
    if (!appDelegate.isInternetConnectionAvailable)
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }
    
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
    // Samman - 24 Sep, 2011 - Need to call WSInterface Method to perform an actual REFRESH
    [appDelegate.wsInterface getEventsForStartDate:appDelegate.wsInterface.startDate EndDate:appDelegate.wsInterface.endDate];
//    [self setDate:[slider value]];
}

- (void) reloadCalendar
{
//    [rightPaneParent setUserInteractionEnabled:NO];
    [self enableUI];
    NSLog(@"currentdate =  %@", currentDate);
    [self setEventsView:currentDate];
    if ((weekView != nil) && ([weekView retainCount] > 0))
    {
        [weekView populateWeekView];
        [weekView.activity stopAnimating];
    }
//    [rightPaneParent setUserInteractionEnabled:YES];
    [self enableUI];
}

- (void) didUpdateObjects:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
{
    NSLog(@"Updated objects");

	[self refreshCacheData];
    [self setupEventsOnView:rightPane];
}

#pragma mark -
#pragma mark Local IBActions

- (IBAction) ShowMap
{
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.didUserInteract = YES;
    
    if (!appDelegate.isInternetConnectionAvailable)
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }

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

    NSLog(@"%@", appDelegate.workOrderEventArray);

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
        for (int i = 0; i < [appDelegate.workOrderEventArray count]; i++)
        {
            NSDictionary * dict = [appDelegate.workOrderEventArray objectAtIndex:i];
            appDelegate.wsInterface.didGetWorkOder = FALSE;
            [appDelegate.wsInterface getWorkOrderMapViewForWorkOrderId:[dict objectForKey:WHATID]];
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, FALSE, 0))
            {
                NSLog(@"ModalViewController ShowMap in while loop");
                if (!appDelegate.isInternetConnectionAvailable)
                {
                    [appDelegate displayNoInternetAvailable];
                    [activity stopAnimating];
                    return;
                }
                if (appDelegate.wsInterface.didGetWorkOder)
                    break;
            }            
        }
        NSLog(@"%@", appDelegate.workOrderInfo);
        FirstDetailViewController * mapView = [[FirstDetailViewController alloc] initWithNibName:@"FirstDetailView" bundle:nil];
        mapView.currentDate = [calendar getTodayString];
        mapView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        mapView.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentModalViewController:mapView animated:YES];
        [mapView release];
    }
    
}

- (IBAction) ToggleLandscapeView
{
    appDelegate.didUserInteract = YES;
    if (!appDelegate.isInternetConnectionAvailable)
    {
        [appDelegate displayNoInternetAvailable];
        return;
    }
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
            [UIView commitAnimations];
        }
        
        [segmentButton setImage:[UIImage imageNamed:@"iService-Day-Button-Up-State.png"] forSegmentAtIndex:0];
        [segmentButton setImage:[UIImage imageNamed:@"iService-Week-Button-Down-State.png"] forSegmentAtIndex:1];
        
        [self enableUI];
    }
    
    if (isShowingDailyView)
    {
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
        }
        else
        {
            weekView.view.frame = CGRectMake(0, 44, weekView.view.frame.size.width, weekView.view.frame.size.height);
            [weekView setupWeeks];
			//3rd Jan 2011 pavaman
			if ([weekView isViewDirty] == YES)
				isViewDirty = [weekView isViewDirty];
			
            if (isViewDirty)
                if (!didSetupWeekView)
                {
                    [weekView setupEvents];
                    didSetupWeekView = NO;
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
        
        [calendar setCalendarDate:[[restoreDate objectAtIndex:0] intValue] Month:[[restoreDate objectAtIndex:1] intValue] Year:[[restoreDate objectAtIndex:2] intValue]];
        
        if (weekView.isViewDirty)
        {
			//pavaman 3rd Jan 2011 Should we do SetDate here instead? Otherwise weekview does not get refreshed
			[self setDate:[calendar getSelDate]];
            // Retrieve data for new date and refresh day view
			weekView.isViewDirty = NO;
        }
		else {
			//pavaman 3rd Jan 2011 Should we do SetDate here as the 'slider' needs to be snapped to correct date in any case?
			[self setDate:[calendar getSelDate]];					
			
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
    [self dismissModalViewControllerAnimated:YES];
}

- (void)removeWeekView:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [weekView.view removeFromSuperview];
    weekView = nil;
}

- (IBAction) AddTask:(id)sender
{
    appDelegate.didUserInteract = YES;
    if (!appDelegate.isInternetConnectionAvailable)
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }
    if(addTaskView != nil)
        [addTaskView release];
    addTaskView = [[AddTaskController alloc] initWithNibName:@"AddTaskController" bundle:nil];
    addTaskView.taskView = taskView;
    UIPopoverController * popOver = [[UIPopoverController alloc] initWithContentViewController:addTaskView];
    popOver.delegate = self;
    addTaskView.popOverController = popOver;
    [popOver setPopoverContentSize:CGSizeMake(320, 430)];
    UIButton * button = (UIButton *) sender;
    [popOver presentPopoverFromRect:button.frame inView:leftPane permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    popOverController = popOver;
    [popOver release];
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
    // NSLog(@"willRotateToInterfaceOrientation");
}

- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // NSLog(@"willAnimateFirstHalfOfRotationToInterfaceOrientation");
}

- (void)didAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // NSLog(@"didAnimateFirstHalfOfRotationToInterfaceOrientation");
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration
{
    // NSLog(@"willAnimateSecondHalfOfRotationFromInterfaceOrientation");
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    // NSLog(@"willAnimateRotationToInterfaceOrientation");

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
  //  NSLog(@"%@", eventViewArray);
}




- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    return;
}


- (void)viewDidUnload
{
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    if (isActive)
        appDelegate.didDayViewUnload = YES;
}


- (void)dealloc
{
    [ltaskLabel release];
    [ltaskLabel release];
    [rscheduleLabel release];
    [todayBtn release];
    [HomeButton release];
    [super dealloc];
    
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
	[self setDate:slider.value];
}

#pragma mark -
#pragma mark Calendar Methods

- (IBAction) SetToday
{
    appDelegate.didUserInteract = YES;
    if (!appDelegate.isInternetConnectionAvailable)
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }
    
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
	
	NSLog(@" SetDate - %@",currentDate);
    NSLog(@"%d", date);
    
    appDelegate.dateClicked = currentDate;
	//pavaman 12th Jan 2011
	if (didFirstTimeLoad == TRUE)
	{
		didFirstTimeLoad = FALSE;		
		NSArray *week_bounds = [calendar getWeekBoundaries:currentDate];
        NSLog(@"%@", week_bounds);
	}

    NSString * _date = [calendar getTodayString];
    [self setupTasksForDate:_date];
    
    // Samman - Thu Aug 4, 2011 - CLEAR eventPositionArray before display
    [eventPositionArray removeAllObjects];
    [eventViewArray removeAllObjects];

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

                NSLog(@"%@ %@", appDelegate.wsInterface.startDate, appDelegate.wsInterface.endDate);
            }
            // Samman - 24 Sep, 2011 - Removed following WSInterface GetEvents call as it is a duplicate call
//            [appDelegate.wsInterface getEventsForStartDate:appDelegate.wsInterface.startDate EndDate:appDelegate.wsInterface.endDate];
            [self reloadCalendar];
        }
        else
        {
            appDelegate.wsInterface.currentDateRange = [calendar getWeekBoundaries:currentDate];
            NSString * _startDate = [appDelegate.wsInterface.currentDateRange objectAtIndex:0];
            NSString * _endDate = [appDelegate.wsInterface.currentDateRange objectAtIndex:1];

            [appDelegate.wsInterface getEventsForStartDate:_startDate EndDate:_endDate];
            NSLog(@"app = %@", appDelegate.wsInterface.eventArray);
        }
    }
    else
    {
        appDelegate.wsInterface.currentDateRange = [calendar getWeekBoundaries:currentDate];
        appDelegate.wsInterface.startDate = [appDelegate.wsInterface.currentDateRange objectAtIndex:0];
        appDelegate.wsInterface.endDate = [appDelegate.wsInterface.currentDateRange objectAtIndex:1];
        
        NSLog(@"%@ %@", appDelegate.wsInterface.startDate, appDelegate.wsInterface.endDate);
        [appDelegate.wsInterface getEventsForStartDate:appDelegate.wsInterface.startDate EndDate:appDelegate.wsInterface.endDate];
        
        NSLog(@"app = %@", appDelegate.wsInterface.eventArray);
    }
}

- (void) setEventsView:(NSString *)_date
{
    NSLog(@"%@", appDelegate.wsInterface.eventArray);

    EventViewController * events = nil;
    NSDictionary * dict;
    NSString * workOrderName;
    NSString * subject;
       
    NSLog(@"%@ %@", appDelegate.wsInterface.startDate, appDelegate.wsInterface.endDate);
    
    NSArray * array = [rightPane subviews];
    for (int i = 0; i < [array count]; i++)
    {
        [[array objectAtIndex:i] removeFromSuperview];
    } 
    [eventPositionArray removeAllObjects];
    [eventViewArray removeAllObjects];

    NSLog(@"%@", appDelegate.wsInterface.eventArray);
    for ( int i = 0; i < [appDelegate.wsInterface.eventArray count]; i++ )
    {
        dict = [appDelegate.wsInterface.eventArray objectAtIndex:i];
        NSLog(@"%@", dict);
        workOrderName = [dict objectForKey:ADDITIONALINFO];
        subject = [dict objectForKey:SUBJECT];
        
        NSLog(@"%@ %@", workOrderName, subject);
        
        NSDate * eventDateTime = [dict objectForKey:ACTIVITYDATE];
        NSLog(@"%@",eventDateTime);
  
        NSLog(@"Setdate = %@", _date);
        
        NSString * activtyDate  = [self dateStringConversion:eventDateTime];
        NSLog(@"%@",activtyDate);

        
        eventDateTime = [dict objectForKey:ACTIVITYDTIME];
        NSLog(@"%@",eventDateTime);
        
        NSString * dateString = [self dateStringConversion:eventDateTime];
        
        NSString * activityDateTime = dateString;
        NSLog(@"Activitydatetime = %@", activityDateTime);
        
        NSString * eventDate = [activityDateTime substringToIndex:10];
        NSLog(@"eventDate = %@", eventDate);
        
        eventDateTime = [dict objectForKey:STARTDATETIME];
        NSLog(@"%@",eventDateTime);
        
        dateString = [self dateStringConversion:eventDateTime];
        
        NSString * startDateTime = dateString;
        NSLog(@"Startdatetime = %@", startDateTime);

        eventDateTime = [dict objectForKey:ENDDATETIME];
        NSLog(@"%@",eventDateTime);
        
        dateString = [self dateStringConversion:eventDateTime];
        
        NSString * endDateTime = dateString;
        NSLog(@"Enddatetime = %@", endDateTime);

        NSString * startime = [startDateTime substringFromIndex:11];
        [startime substringToIndex:2];
     
        NSLog(@"Starttime = %@", startime);
        
        NSString * duration = [dict objectForKey:DURATIONINMIN];
        
        events = [[EventViewController alloc] initWithNibName:[EventViewController description] bundle:nil];
        events.delegate = self;
        
        // processName, processId, recordId, objectName, createdDate, accountId;
        NSLog(@"%@", [dict objectForKey:WHATID]);
        
        events.view.tag = [eventViewArray count];
        
        events.startDate = [self dateStringConversion:[dict objectForKey:STARTDATETIME]];
        events.endDate = [self dateStringConversion:[dict objectForKey:ENDDATETIME]];                    
        events.processId = @"";
        events.eventId = ([dict objectForKey:EVENTID] != nil)?[dict objectForKey:EVENTID]:@"";
        events.recordId = ([dict objectForKey:WHATID] != nil)?[dict objectForKey:WHATID]:@"";
        events.objectName = ([dict objectForKey:OBJECTAPINAME] != nil)?[dict objectForKey:OBJECTAPINAME]:@"";
        events.activityDate = ([dict objectForKey:ACTIVITYDATE] != nil)?[dict objectForKey:ACTIVITYDATE]:@"";
        events.accountId = ([dict objectForKey:ACCOUNTID] != nil)?[dict objectForKey:ACCOUNTID]:@"";
        
        NSString * objectAPIName = [dict objectForKey:OBJECTAPINAME];
        if ([objectAPIName isEqualToString:@"service_order__c"])
            objectAPIName = [NSString stringWithFormat:@"%@__%@",SVMX_ORG_PREFIX,objectAPIName];
        objectAPIName = [objectAPIName uppercaseString];
        
        for (int v = 0; v < [appDelegate.wsInterface.viewLayoutsArray count]; v++)
        {
            NSDictionary * dict = [appDelegate.wsInterface.viewLayoutsArray objectAtIndex:v];
            NSString * object_label = [dict objectForKey:VIEW_OBJECTNAME];
            object_label = [object_label uppercaseString];
            NSLog(@"%@ %@", object_label, objectAPIName);
            if ([object_label isEqualToString:objectAPIName])
            {
                events.processId = @"";
                events.processId = ([dict objectForKey:VIEW_SVMXC_ProcessID]!=nil)?[dict objectForKey:VIEW_SVMXC_ProcessID]:@"";
                NSLog(@"[SetEventsView] Events Process ID = %@",events.processId);
                break;
            }
        }
        	
        NSString * colourCode = [dict objectForKey:COLORCODE];
        UIColor * color = [appDelegate colorForHex:colourCode];
        NSLog(@"%@", color);
        
        if ( [_date isEqualToString:eventDate] == TRUE )
        {
            NSLog(@"%@ %@", [rightPane description], events.processName);
            [rightPane addSubview:events.view];
            [events setEvent:workOrderName Time:startime Duration:(CGFloat)[duration intValue]/60 Color:color];
            [events setLabelWorkorder:workOrderName Subject:subject];  
            [eventViewArray addObject:events];
            [events release];
        }
    }
    
    [activity stopAnimating];

    [self didGetAllEvents];
}

- (void) didGetAllEvents
{
    calendarDidLoad = YES;
    [self didAllDataLoad];
}

- (NSString *)dateStringConversion:(NSDate*)date 
{
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
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
    appDelegate.didUserInteract = YES;
    if (!appDelegate.isInternetConnectionAvailable)
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }
    
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
    appDelegate.didUserInteract = YES;
    if (!appDelegate.isInternetConnectionAvailable)
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }
    
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
    if ([appDelegate.SFMPage retainCount] > 0)
    {
        [appDelegate.SFMPage release];
        appDelegate.SFMPage = nil;
    }
    
    appDelegate.sfmPageController = [[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:TRUE];
    
    NSString * processId = [appDelegate.switchViewLayouts objectForKey:[event objectForKey:OBJECTAPINAME]];
    appDelegate.sfmPageController.processId = (processId != nil)?processId:[event objectForKey:PROCESSID];
    NSLog(@"[%@] processId = %@",NSStringFromSelector(_cmd),appDelegate.sfmPageController.processId );
    appDelegate.sfmPageController.recordId = [event objectForKey:RECORDID];
    appDelegate.sfmPageController.objectName = [event objectForKey:OBJECTAPINAME];
    appDelegate.sfmPageController.activityDate = [event objectForKey:ACTIVITYDATE];
    appDelegate.sfmPageController.accountId = [event objectForKey:ACCOUNTID];
    appDelegate.sfmPageController.topLevelId = [event objectForKey:TOPLEVELID];
    
    [appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
    [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [appDelegate.sfmPageController.detailView view];
    if (appDelegate.wsInterface.errorLoadingSFM == FALSE)
        [self presentModalViewController:appDelegate.sfmPageController animated:YES];
    else
        appDelegate.wsInterface.errorLoadingSFM = FALSE;
    [appDelegate.sfmPageController release];
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
        NSLog(@"touchesBegan: Caught & Handled Exception.");
    }
    @finally
    {
        NSLog(@"touchesBegan: Finally Handled Exception.");
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
        // // NSLog(@"Right pane y = %f", rightPane.frame.origin.y);
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
        
        // If the touch was in the placardView, bounce it back to the center
        if ([touch view] == eventView.view)
        {
            if (!didMoveEvent)
            {
                NSArray * keys = [NSArray arrayWithObjects:PROCESSID, RECORDID, OBJECTAPINAME, ACTIVITYDATE, ACCOUNTID, nil];
                NSArray * objects = [NSArray arrayWithObjects:eventView.processId, eventView.recordId, eventView.objectName, eventView.activityDate, eventView.accountId, nil];
                
                NSDictionary * _dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
                
                if ([_dict objectForKey:PROCESSID] == @"" || [_dict objectForKey:PROCESSID] == nil)
                {
                    NSString * noView = [appDelegate.wsInterface.tagsDictionary objectForKey:NO_VIEW_PROCESS];
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:noView delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                }
                else
                {
                    //Siva Manne
                    NSString * rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    NSString * plistPath = [rootPath stringByAppendingPathComponent:SWITCH_VIEW_LAYOUTS_PLIST];
                    NSMutableDictionary * sViewLayouts = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
                    NSLog(@"Data From Plist =%@ File = %@",sViewLayouts,plistPath);
                    [sViewLayouts release];

                    if (([eventView.recordId length] == 0) || (![eventView.recordId isKindOfClass:[NSString class]]))
                        return;
                    if (!appDelegate.isInternetConnectionAvailable)
                    {
                        [activity stopAnimating];
                        [appDelegate displayNoInternetAvailable];
                        return;
                    }
                    [self disableUI];
                    [self showSFMWithDayEvent:_dict];
                }
            }
            else
            {
                [self disableUI];
                oldEventRect = eventView.selfFrame;
                [eventView moveTo:eventView.view.frame];
                
                if(Continue_rescheduling)
                {
                    didRunOperation = YES;
                    if ([updatestartDateTime length] > 0 && [updateendDateTime length] > 0)
                    {
                        if (appDelegate.isInternetConnectionAvailable)
                        {
                            [appDelegate.wsInterface getUpdateEventsForStartDate:updatestartDateTime EndDate:updateendDateTime
                                                                    recordID:eventView.eventId];
                        }
                        
                        while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, 1, FALSE))
                        {
                            NSLog(@"ModalViewController touchesEnded in while loop");
                            if (!appDelegate.isInternetConnectionAvailable)
                            {
                                [activity stopAnimating];
                                appDelegate.wsInterface.didRescheduleEvent = FALSE;
                                [eventView restorePositionToRect:oldEventRect];
                                [appDelegate displayNoInternetAvailable];
                                break;
                            }
                            
                            if ( appDelegate.wsInterface.didRescheduleEvent == TRUE )
                            {
                                appDelegate.wsInterface.didRescheduleEvent = FALSE;
                                break;
                            }
                        }
                        
                        updatestartDateTime = @"";
                        updateendDateTime = @"";
                    }
                    
                    if (!appDelegate.isInternetConnectionAvailable)
                    {
                        [activity stopAnimating];
                        return;
                    }
                    
                    appDelegate.wsInterface.didRescheduleEvent = FALSE; // Reusing this variable for get Events purpose
                    [appDelegate.wsInterface getEventsForStartDate:appDelegate.wsInterface.startDate EndDate:appDelegate.wsInterface.endDate];
                    
                    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, 1, FALSE))
                    {
                        NSLog(@"ModalViewController touchesEnded in while loop");
                        if (!appDelegate.isInternetConnectionAvailable)
                        {
                            [activity stopAnimating];
                            appDelegate.wsInterface.didRescheduleEvent = FALSE;
                            break;
                        }
                        if ( appDelegate.wsInterface.didRescheduleEvent == TRUE )
                        {
                            appDelegate.wsInterface.didRescheduleEvent = FALSE;
                            break;
                        }
                    }
                    
                    if ([appDelegate.wsInterface.rescheduleEvent isEqualToString:@"SUCCESS"])
                    {
                        [activity stopAnimating];
                    }
                    else
                        [activity stopAnimating];
                }
                else
                {
                    
                }
            }
        }
        didMoveEvent = NO;
    }
    @catch (NSException *exception)
    {
        NSLog(@"touchesEnded: Caught & Handled Exception.");
    }
    @finally
    {
        NSLog(@"touchesEnded: Finally Handled Exception.");
    }
    
    if (appDelegate.isInternetConnectionAvailable)
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
        NSLog(@"touchesCancelled: Caught & Handled Exception.");
    }
    @finally
    {
        NSLog(@"touchesCancelled: Finally Handled Exception.");
    }
}

#pragma mark - SFM Page Display Mathod
- (void) showSFMWithDayEvent:(NSDictionary *)event
{
    [activity startAnimating];
    appDelegate.sfmPageController = [[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:TRUE];
    
    if ([appDelegate.SFMPage retainCount] > 0)
    {
        [appDelegate.SFMPage release];
        appDelegate.SFMPage = nil;
    }

    NSString * processId = [appDelegate.switchViewLayouts objectForKey:[event objectForKey:OBJECTAPINAME]];
    appDelegate.sfmPageController.processId = (processId != nil)?processId:[event objectForKey:PROCESSID];
    appDelegate.sfmPageController.recordId = [event objectForKey:RECORDID];
    appDelegate.sfmPageController.objectName = [event objectForKey:OBJECTAPINAME];
    appDelegate.sfmPageController.activityDate = [event objectForKey:ACTIVITYDATE];
    appDelegate.sfmPageController.accountId = [event objectForKey:ACCOUNTID];
    appDelegate.sfmPageController.topLevelId = [event objectForKey:TOPLEVELID];
    
    [appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
    [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    
    didRunOperation = YES;
    [appDelegate.sfmPageController.detailView view];
    didRunOperation = NO;
    
    if (appDelegate.wsInterface.errorLoadingSFM == FALSE)
        [self presentModalViewController:appDelegate.sfmPageController animated:YES];
    else
        appDelegate.wsInterface.errorLoadingSFM = FALSE;
    [appDelegate.sfmPageController release];
    [activity stopAnimating];
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
    [self presentModalViewController:htmlBrowser animated:YES];
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

@end
