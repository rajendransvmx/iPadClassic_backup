    //
//  WeeklyViewController.m
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 19/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WeeklyViewController.h"
#import "HTMLBrowser.h"
#import "LocalizationGlobals.h"
#import <QuartzCore/QuartzCore.h>
extern void SVMXLog(NSString *format, ...);

@implementation WeeklyViewController

@synthesize delegate;
@synthesize calendar;
@synthesize updateEndTime, updateStartTime;
@synthesize eventDetails;
@synthesize eventsArray;
@synthesize isViewDirty;
@synthesize currentWeekDateRange;
@synthesize workOrderDictionary;
@synthesize activity;
//sahana  12th Sept
@synthesize didDismissAlertView, ContinueRescheduling;

//pavaman 16th Jan 2011
@synthesize firstTimeLoadFromCache;

//pavaman 21st Jan 2011
@synthesize didLoadWeekData;

@synthesize didMoveEvent;
@synthesize edit_event;
@synthesize eventView; //eventView

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
    eventViewArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self disableUI];
    
    iOSObject = [[iOSInterfaceObject alloc] initWithCaller:self];
    
    appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    // Calendar function
    [self setupWeeks];
    // Event setup
    [self setUpDayRect];
    
	
    
    //Radha 21st April 2011
    //For localization
    
    NSString * str = [appDelegate.wsInterface.tagsDictionary objectForKey:SLIDERCURWEEKLABEL];
    [curWeek setTitle:str forState:UIControlStateNormal];
	
	//Defect Fix :- 7454
	[curWeek.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
	curWeek.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;

    //Localizing the days in the week_view
    day1Label.font = [UIFont systemFontOfSize:12];
    day2Label.font = [UIFont systemFontOfSize:12];
    day3Label.font = [UIFont systemFontOfSize:12];
    day4Label.font = [UIFont systemFontOfSize:12];
    day5Label.font = [UIFont systemFontOfSize:13];
    day6Label.font = [UIFont systemFontOfSize:12];
    day7Label.font = [UIFont systemFontOfSize:12];
        
    day1Label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:DAY1LABEL];
    day2Label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:DAY2LABEL];
    day3Label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:DAY3LABEL];
    day4Label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:DAY4LABEL];
    day5Label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:DAY5LABEL];
    day6Label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:DAY6LABEL];    
    day7Label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:DAY7LABEL];
    
    [ prevWeek setAccessibilityIdentifier:@"PrevButton"];
    [ nextWeek setAccessibilityIdentifier:@"NextButton"];
    prevWeek.isAccessibilityElement = YES;
    [ prevWeek setAccessibilityIdentifier:@"PrevButton"];
    nextWeek.isAccessibilityElement = YES;
    [ nextWeek setAccessibilityIdentifier:@"NextButton"];

    /*Shravya-Calendar view 7408 Only one time call is enough*/
    [self setupEvents];
    //[self populateWeekView];
}

- (void) didInternetConnectionChange:(NSNotification *)notification
{
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber * currentReach = (NSNumber *) notification.object;
    BOOL isReachable = [currentReach boolValue];
    if (isReachable)
    {
        SMLog(@"Reachable");
        isInternetConnectionAvailable = YES;
    }
    else
    {
        SMLog(@"Not Reachable");
        isInternetConnectionAvailable = NO;
        
        if (didRunOperation)
        {
            [activity stopAnimating];
            //[appDelegate displayNoInternetAvailable];  --- Shrinivas
            didRunOperation = NO;
        }
    }
}

- (void) didAllDataLoad
{
    if (calendarDidLoad)
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

- (void) viewWillAppear:(BOOL)animated
{
    [self enableUI];
    
    NSLog(@"VIEW WILL APPEAR IN WEEKVIEW");
    /*Shravya-Calendar view 7408 */
    //Shravya - No need to load everytimes view will appear 
    //[self populateWeekView];
}

#pragma mark - Populate Week View
- (void) populateWeekView
{
    /*Shravya-Calendar view 7408 */
    // Shravya - Perform selector has been placed to induce a small delay so the activity indicator will be displayed in the screen
   [self clearWeekView];
   [self performSelector:@selector(contiuePopulateWeekView) withObject:nil afterDelay:0.0];
}

- (void)contiuePopulateWeekView {
    
    NSDictionary * dict;
    NSString * workOrderName;
    NSString * subject;
    NSArray * event;
    
    SMLog(@"%@", appDelegate.wsInterface.eventArray);
    
    /*Shravya-Calendar view 7408 */
    //Shravya - @synchronized is needed as refresh(Internally this function) gets called from multiple threads during Sync
    @synchronized(self){
    NSLog(@"populateWeekView %d", [appDelegate.wsInterface.eventArray count]);
    @try{
        
        /*Shravya-Calendar view 7408*/
        NSArray *conflictObjects = [appDelegate.calDataBase readConflictTableForEventInfo];
        
        for ( int i = 0; i < [appDelegate.wsInterface.eventArray count]; i++ )
        {
            
            NSDate * temp_start_date_time , *temp_end_date_time ;
            dict = [[appDelegate.wsInterface.eventArray objectAtIndex:i] retain]; /*Shravya-Calendar view 7408 */
            
            workOrderName = [dict objectForKey:ADDITIONALINFO];
            subject = [dict objectForKey:SUBJECT];
            
            //Taking the time and date of an event
            NSDate * eventDateTime = [dict objectForKey:ACTIVITYDATE];
            
            eventDateTime = [dict objectForKey:ACTIVITYDTIME];
            
            NSString * dateString = [self dateToStringConversion:eventDateTime];
            
            eventDateTime = [dict objectForKey:STARTDATETIME];
            temp_start_date_time = [dict objectForKey:STARTDATETIME];
            
            
            dateString = [self dateToStringConversion:eventDateTime];
            
            NSString * startDateTime = dateString;
            
            eventDateTime = [dict objectForKey:ENDDATETIME];
            temp_end_date_time = [dict objectForKey:ENDDATETIME];
            
            dateString = [self dateToStringConversion:eventDateTime];
            
            NSString * endDateTime = dateString;
            
            NSString * startime = [startDateTime substringFromIndex:11];
            [startime substringToIndex:2];
            
            NSString * endTime = [endDateTime substringFromIndex:11];
            endTime = [endTime substringToIndex:2];
            
            
            event = [NSArray arrayWithObjects:subject, workOrderName, nil];
            
            weeksArray = [calendar getWeeksArray];
            if(currentSliderPositionIndex+1 > [weeksArray count])
                currentSliderPositionIndex = 0;//#3845
            
            NSMutableArray * array = [weeksArray objectAtIndex:currentSliderPositionIndex];
            
            NSUInteger dayIndex = 0;
            
            //Radha 9th NOV 2011
            BOOL flag = FALSE;
            
            //Radha 22 sep 2011
            NSString * eventActualDate = [startDateTime substringToIndex:10];
            eventActualDate = [eventActualDate substringFromIndex:8];
            
            int day = [eventActualDate intValue];
            
            for (int i = 0; i < [array count]; i++)
            {
                for (int j = 0; j < [array count]; j++)
                {
                    int checkArrayDay = [[array objectAtIndex:j] intValue];
                    if (day == checkArrayDay)
                    {
                        flag = TRUE;
                        break;
                    }
                    else
                        flag = FALSE;
                }
                if (!flag)
                    break;
                int arrayDay = [[array objectAtIndex:i] intValue];
                if (arrayDay == day)
                {
                    dayIndex = i;
                    break;
                }
            }
            
            WeeklyViewEvent * events = nil;
            if (events == nil)
            {
                events = [[WeeklyViewEvent alloc] initWithNibName:[WeeklyViewEvent description] bundle:nil];
            }
            events.delegate = self;
            
            
            events.view.tag = [eventViewArray count];
            
            SMLog(@"%@", [dict objectForKey:SUBJECT]);
            events.processId = @"";
            events.eventId = ([dict objectForKey:EVENTID] != nil)?[dict objectForKey:EVENTID]:@"";
            
            events.recordId = ([dict objectForKey:WHATID] != nil)?[dict objectForKey:WHATID]:@"";
            events.objectName = ([dict objectForKey:OBJECTAPINAME] != nil)?[dict objectForKey:OBJECTAPINAME]:@"";
            events.createdDate = ([dict objectForKey:CREATEDDATE] != nil)?[dict objectForKey:CREATEDDATE]:@"";
            events.accountId = ([dict objectForKey:ACCOUNTID] != nil)?[dict objectForKey:ACCOUNTID]:@"";
            events.startDate = [self dateToStringConversion:[dict objectForKey:STARTDATETIME]];
            events.endDate = [self dateToStringConversion:[dict objectForKey:ENDDATETIME]];
            events.activityDate = ([dict objectForKey:ACTIVITYDATE] != nil)?[dict objectForKey:ACTIVITYDATE]:@"";
            events.local_id = ([dict objectForKey:EVENT_LOCAL_ID] != nil)?[dict objectForKey:EVENT_LOCAL_ID]:@"";
            
            NSString * objectAPIName = [dict objectForKey:OBJECTAPINAME];
            
            objectAPIName = [objectAPIName uppercaseString];
            
            for (int v = 0; v < [appDelegate.view_layout_array count]; v++)
            {
                NSDictionary * dict = [appDelegate.view_layout_array objectAtIndex:v];
                NSString * object_label = [dict objectForKey:VIEW_OBJECTNAME];
                object_label = [object_label uppercaseString];
                if ([object_label isEqualToString:objectAPIName])
                {
                    events.processId = [dict objectForKey:VIEW_SVMXC_ProcessID];
                    break;
                }
            }
            
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
            
            
            //30 minute event 8/sept/2012   ----> Changes for 30 min Event Defect.
            UIColor * color;
            int _duration = [duration intValue];
            if (_duration != 0)
            {
                NSString * colourCode = [appDelegate.calDataBase getColorCodeForPriority:([dict objectForKey:WHATID] != nil)?[dict objectForKey:WHATID]:@"" objectname:([dict objectForKey:OBJECTAPINAME] != nil)?[dict objectForKey:OBJECTAPINAME]:@""];
                color = [appDelegate colorForHex:colourCode];
            }else{
                color = [UIColor clearColor];
            }
            
            NSString * local_id = [appDelegate.databaseInterface getLocalIdFromSFId:events.recordId tableName:[dict objectForKey:OBJECTAPINAME]];
            
            /*Shravya-Calendar view 7408*/
            //Conflict logic is changed. Rather than checking conflict for every event, set of conflict is stored in conflictObjects
            BOOL conflictExists = NO;
            if ([conflictObjects count] > 0) {
                conflictExists = [appDelegate.calDataBase checkSyncConflictFor:events.recordId WithLocalId:local_id withObjectName:[dict objectForKey:OBJECTAPINAME] andArray:conflictObjects];
            }
            /*Shravya-Calendar view */
            
            events.conflictFlag = conflictExists;
            
            if (flag)
            {
                
                UISwipeGestureRecognizer * swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(EvntgestureRecognizer)];
                swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
                [events.view addGestureRecognizer:swipeRecognizer];
                
                [weekViewPane addSubview:events.view];
                [events setEvent:event Day:dayIndex Time:startime Duration:(CGFloat)[duration intValue]/60*2 Color:color];
                [events setLabelsweeklyview:event];
                [eventViewArray addObject:events];
                
            }
            else {
                NSLog(@"shouldNotHappen");
            }
            /*Shravya-Calendar view 7408 */
            [events release];
            events = nil;
            [dict release];
            dict = nil;
            /*Shravya-Calendar view 7408 */
        }
    }@catch (NSException *exp) {
        SMLog(@"Exception Name WeeklyViewController :populateWeekView %@",exp.name);
        SMLog(@"Exception Reason WeeklyViewController :populateWeekView %@",exp.reason);
    }
	@finally {
    [activity stopAnimating];
	}
    
    calendarDidLoad = YES;
    [self didAllDataLoad];
    }
}
-(void)EvntgestureRecognizer
{
    NSLog(@"Swipe Recorgnized weeklyview");
}
- (NSString *)dateToStringConversion:(NSDate*)date 
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return  dateString;
}

- (void) viewWillDisappear:(BOOL)animated
{
    // SMLog(@"viewWillDisappear");
}

- (void) viewDidDisappear:(BOOL)animated
{
    // SMLog(@"viewDidDisappear");
}

#pragma mark -
#pragma mark Calendar setup
- (void) setupWeeks
{
//    [self disableUI];
    if (weeksArray != nil)
    {
        [weeksArray removeAllObjects];
    }

    weeksArray = [calendar getWeeksArray];

    switch ([weeksArray count]) {
        case 4:
            sliderImageView.image = [UIImage imageNamed:@"slider4.png"];
            break;
        case 5:
            sliderImageView.image = [UIImage imageNamed:@"slider5.png"];
            break;
        case 6:
            sliderImageView.image = [UIImage imageNamed:@"slider6.png"];
            break;
        default:
            break;
    }

    [self setSliderBounds:[weeksArray count]];

    if (weekDetails != nil)
    {
        [weekDetails release];
        weekDetails = nil;
    }
    weekDetails = [[calendar getWeekDetails] retain];
    
    [self highlightToday];
    
    monthYear.text = [NSString stringWithFormat:@"%@ %@", [weekDetails objectForKey:wMONTH], [weekDetails objectForKey:wYEAR]];
    
	//pavaman 3rd Jan 2011
	if (currentSliderPositionIndex != [[weekDetails objectForKey:wWEEK] intValue]-1)
		isViewDirty = YES;
	
	currentSliderPositionIndex = [[weekDetails objectForKey:wWEEK] intValue]-1;
    CGRect locationRect = [[sliderBoundsArray objectAtIndex:currentSliderPositionIndex] CGRectValue];
    
    [UIView beginAnimations:@"setSliderPosition" context:nil];
    [UIView setAnimationDuration:0.3];
    sliderImage.center = CGPointMake((locationRect.origin.x + locationRect.size.width/2), sliderImage.center.y);
    [UIView commitAnimations];
    
    [self setDays];
}

- (NSArray *) getWeekStartEndDatesAtOptionalIndex:(NSString *)optionalIndex
{
    NSUInteger index = 0;
     int startMonth,endMonth;
    int startYear,endYear;
    NSString * startMonthString;
    NSString * endMonthString;
    NSUInteger month = [[weekDetails objectForKey:wMONTHNUMBER] intValue];
    NSUInteger year = [[weekDetails objectForKey:wYEAR] intValue];
    NSString * _startDate = @"", * _endDate = @"";
    @try{
    if (optionalIndex == nil)
        index = [[weekDetails objectForKey:wWEEK] intValue]-1;
    else
        index = [optionalIndex intValue];

    NSMutableArray * array = [weeksArray objectAtIndex:index];
    
    NSUInteger start = 0, end = 0;
    for (int i = 0; i < [array count]; i++)
    {
        if (![[array objectAtIndex:i] isEqualToString:@""])
        {
            start = [[array objectAtIndex:i] intValue];
            break;
        }
    }
    
    for (int j = [array count]-1; j >= 0; j--)
    {
        if (![[array objectAtIndex:j] isEqualToString:@""])
        {
            end = [[array objectAtIndex:j] intValue];
            break;
        }
    }
    
    
    if (start < 10)
        _startDate = [NSString stringWithFormat:@"0%d", start];
    else
        _startDate = [NSString stringWithFormat:@"%d", start];
    
    if (end < 10)
        _endDate = [NSString stringWithFormat:@"0%d", end];
    else
        _endDate = [NSString stringWithFormat:@"%d", end];
    
    // Retrieve current month and year
    
    startYear = endYear = year;
    startMonth =endMonth = month;
    if(index == 0)
    {
        if(start > end)
        {
            startMonth = month-1;
            if(startMonth == 0)
            {
                startMonth = 12;
                startYear = startYear - 1;
            }
        }
    }
    else
    {
        if(index == ([weeksArray count]-1))
        {
            if(start > end)
            {
                endMonth = month + 1;
                if(endMonth == 13)
                {
                    endMonth = 1;
                    endYear = endYear + 1;
                }
            }  
        }
    }
    if (startMonth < 10)
        startMonthString = [NSString stringWithFormat:@"0%d", startMonth];
    else
        startMonthString = [NSString stringWithFormat:@"%d", startMonth];
    if (endMonth < 10)
        endMonthString = [NSString stringWithFormat:@"0%d", endMonth];
    else
        endMonthString = [NSString stringWithFormat:@"%d", endMonth];
    
     }@catch (NSException *exp) {
	SMLog(@"Exception Name WeeklyViewController :getWeekStartEndDatesAtOptionalIndex %@",exp.name);
	SMLog(@"Exception Reason WeeklyViewController :getWeekStartEndDatesAtOptionalIndex %@",exp.reason);
    }

    NSString * weekStart = [NSString stringWithFormat:@"%d-%@-%@", startYear, startMonthString, _startDate];
    NSString * weekEnd = [NSString stringWithFormat:@"%d-%@-%@", endYear, endMonthString, _endDate];
    
    // Performance Enhancement
    if (currentWeekDateRange == nil)
    {
        currentWeekDateRange = [[NSArray alloc] initWithObjects:weekStart, weekEnd, nil];
    }
    else
    {
        [currentWeekDateRange release];
        currentWeekDateRange = nil;
        currentWeekDateRange = [[NSArray alloc] initWithObjects:weekStart, weekEnd, nil];
    }
    
    // Analyzer
    return [NSArray arrayWithObjects:weekStart, weekEnd, nil];
}

- (void) highlightToday
{
    switch ([calendar getToday]) {
        case 1:
            mondayHighlight.backgroundColor = [UIColor greenColor];
            mondayHighlight.layer.cornerRadius = 6;
            break;
        case 2:
            tuesdayHighlight.backgroundColor = [UIColor greenColor];
            tuesdayHighlight.layer.cornerRadius = 6;
            break;
        case 3:
            wednesdayHighlight.backgroundColor = [UIColor greenColor];
            wednesdayHighlight.layer.cornerRadius = 6;
            break;
        case 4:
            thursdayHighlight.backgroundColor = [UIColor greenColor];
            thursdayHighlight.layer.cornerRadius = 6;
            break;
        case 5:
            fridayHighlight.backgroundColor = [UIColor greenColor];
            fridayHighlight.layer.cornerRadius = 6;
            break;
        case 6:
            saturdayHighlight.backgroundColor = [UIColor greenColor];
            saturdayHighlight.layer.cornerRadius = 6;
            break;
        case 7:
            sundayHighlight.backgroundColor = [UIColor greenColor];
            sundayHighlight.layer.cornerRadius = 6;
            break;
        default:
            break;
    }
}

- (void) setDays
{
	@try{
    NSUInteger index = [[weekDetails objectForKey:wWEEK] intValue]-1;
    NSMutableArray * array = [weeksArray objectAtIndex:index];
    
    SMLog(@"%@", array);
    currentWeek = index;
    // Do not get confused by the assignment below, sunday corresponds to monday's label, monday corresponds to 
    // tuesday's label and so on.
    sunday.text = [array objectAtIndex:0];
    monday.text = [array objectAtIndex:1];
    tuesday.text = [array objectAtIndex:2];
    wednesday.text = [array objectAtIndex:3];
    thursday.text = [array objectAtIndex:4];
    friday.text = [array objectAtIndex:5];
    saturday.text = [array objectAtIndex:6];
    
    //Radha 21st April 2011
    //Localizing the days in the week_view
    
    NSArray * subViewArray = [weekViewModify subviews];
    for (int i = 0; i < [subViewArray count]; i++)
    {
        UILabel * label = (UILabel *)[subViewArray objectAtIndex:i];
        if (label.tag >= 1234)
            [label removeFromSuperview];
    }
    
    for (int i = 0; i < [weeksArray count]; i++)
    {
        array = [weeksArray objectAtIndex:i];
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 18)];
        CGRect rect = [[sliderBoundsArray objectAtIndex:i] CGRectValue];
        label.center = CGPointMake(rect.origin.x + (rect.size.width / 2), label.center.y+16);
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14];
        label.tag = 1234+i;
        label.textAlignment = UITextAlignmentCenter;
        NSString * firstLastStr = [self getFirstLastFromWeek:array];
        label.text = firstLastStr;
        [weekViewModify addSubview:label];
        [label release];
    }
    }@catch (NSException *exp) {
	SMLog(@"Exception Name WeeklyViewController :setDays %@",exp.name);
	SMLog(@"Exception Reason WeeklyViewController :setDays %@",exp.reason);
    }

}

- (void) setDaysAtSliderLocationIndex:(NSUInteger)index
{
	@try{
    currentWeek = index;

    NSMutableArray * array = [weeksArray objectAtIndex:index];
    
   sunday.text = [array objectAtIndex:0];
    monday.text = [array objectAtIndex:1];
    tuesday.text = [array objectAtIndex:2];
    wednesday.text = [array objectAtIndex:3];
    thursday.text = [array objectAtIndex:4];
    friday.text = [array objectAtIndex:5];
    saturday.text = [array objectAtIndex:6];
    
    [self setupEvents];
    }@catch (NSException *exp) {
        SMLog(@"Exception Name WeeklyViewController :setDaysAtSliderLocationIndex %@",exp.name);
        SMLog(@"Exception Reason WeeklyViewController :setDaysAtSliderLocationIndex %@",exp.reason);
    }
}

- (NSString *) getFirstLastFromWeek:(NSMutableArray *)array
{
    NSString * formattedString = nil;
    NSUInteger index = -1;
    @try{
    for (int i = 0; i < 7; i++)
    {
        if (![[array objectAtIndex:i] isEqualToString:@""])
        {
            if (index == -1)
            {
                index = i;
                // Start Date
                formattedString = [NSString stringWithFormat:@"%@", [array objectAtIndex:i]];
                // Reset i to start iterations again, but this time from the end
                i = 0;
            }
        }
        
        if (index != -1)
        {
            // index already obtained, hence start date already set
            // iterate from the end of the array and find last valid date
            if (![[array objectAtIndex:(6-i)] isEqualToString:@""] && (index != (6-i)))
            {
                formattedString = [formattedString stringByAppendingFormat:@" - %@", [array objectAtIndex:(6-i)]];
                // Found last date, break
                break;
            }
        }
    }
    }@catch (NSException *exp) {
        SMLog(@"Exception Name WeeklyViewController :getFirstLastFromWeek %@",exp.name);
        SMLog(@"Exception Reason WeeklyViewController :getFirstLastFromWeek %@",exp.reason);
    }

    return formattedString;
}

- (void) setSliderBounds:(NSUInteger)div
{
    if (sliderBoundsArray == nil)
        sliderBoundsArray = [[NSMutableArray alloc] initWithCapacity:0];
    else
        [sliderBoundsArray removeAllObjects];
    switch (div) {
        case 4:
            [sliderBoundsArray addObject:[NSValue valueWithCGRect:CGRectMake(154, 0, 168, 40)]];
            [sliderBoundsArray addObject:[NSValue valueWithCGRect:CGRectMake(321, 0, 169, 40)]];
            [sliderBoundsArray addObject:[NSValue valueWithCGRect:CGRectMake(490, 0, 169, 40)]];
            [sliderBoundsArray addObject:[NSValue valueWithCGRect:CGRectMake(659, 0, 169, 40)]];
            break;
        case 5:
            [sliderBoundsArray addObject:[NSValue valueWithCGRect:CGRectMake(154, 0, 135, 40)]];
            [sliderBoundsArray addObject:[NSValue valueWithCGRect:CGRectMake(289, 0, 135, 40)]];
            [sliderBoundsArray addObject:[NSValue valueWithCGRect:CGRectMake(424, 0, 135, 40)]];
            [sliderBoundsArray addObject:[NSValue valueWithCGRect:CGRectMake(559, 0, 135, 40)]];
            [sliderBoundsArray addObject:[NSValue valueWithCGRect:CGRectMake(694, 0, 135, 40)]];
            break;
        case 6:
            [sliderBoundsArray addObject:[NSValue valueWithCGRect:CGRectMake(154, 0, 112, 40)]];
            [sliderBoundsArray addObject:[NSValue valueWithCGRect:CGRectMake(266, 0, 112, 40)]];
            [sliderBoundsArray addObject:[NSValue valueWithCGRect:CGRectMake(378, 0, 112, 40)]];
            [sliderBoundsArray addObject:[NSValue valueWithCGRect:CGRectMake(490, 0, 112, 40)]];
            [sliderBoundsArray addObject:[NSValue valueWithCGRect:CGRectMake(602, 0, 112, 40)]];
            [sliderBoundsArray addObject:[NSValue valueWithCGRect:CGRectMake(714, 0, 112, 40)]];
            break;
        default:
            break;
    }
}

- (IBAction) changeWeek
{

}

- (IBAction) NextWeek
{
   /* if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }*/
    [self disableUI];
    if (currentSliderPositionIndex < ([sliderBoundsArray count]-1))
    {
        ++currentSliderPositionIndex;
        CGRect locationRect = [[sliderBoundsArray objectAtIndex:currentSliderPositionIndex] CGRectValue];
        if (CGRectEqualToRect(locationRect, CGRectZero))
        {
            return;
        }
        
        if (!CGRectContainsRect(locationRect, sliderImage.frame))
        {
            // SMLog(@"Location contains Rect %f, %f, %f, %f", sliderImage.frame.origin.x, sliderImage.frame.origin.y, sliderImage.frame.size.width, sliderImage.frame.size.height);
            [UIView beginAnimations:@"moveslider" context:nil];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(SliderMoved:finished:context:)];
            sliderImage.center = CGPointMake((locationRect.origin.x + locationRect.size.width/2), sliderImage.center.y);
            [UIView commitAnimations];
        }   
    }
    else
    {
        // go to next "calendar" month and retrieve details
        // show slider in the first location
        //pavaman 16th jan 2011 - we should go to NextMonthStart
		//[calendar NextMonth];
		[calendar NextMonthStart];
        [self RefreshLandscape];
        // Calendar function
        [self setupWeeks];
        // Event setup
        [self setUpDayRect];
        [self setupEvents];
        // Move slider to the first date
        [self setSliderToFirst];
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSArray * startEnd = [self getWeekStartEndDatesAtOptionalIndex:[NSString stringWithFormat:@"%d", currentSliderPositionIndex]];
    NSString * _currentDate = [startEnd objectAtIndex:0];
    NSMutableArray * currentDateRange = [[appDelegate getWeekdates:_currentDate] retain];
    
    [dict setValue:currentDateRange forKey:@"CurrentRange"];
    SBJsonWriter *writer = [[[SBJsonWriter alloc] init] autorelease];
    NSString *json = [writer stringWithObject:dict];
    [dict release];
    [nextWeek setAccessibilityValue:json];
}

- (IBAction) PrevWeek
{
    /*if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }*/
    
    [self disableUI];
    
    if (currentSliderPositionIndex > 0)
    {
        --currentSliderPositionIndex;
        CGRect locationRect = [[sliderBoundsArray objectAtIndex:currentSliderPositionIndex] CGRectValue];
        if (CGRectEqualToRect(locationRect, CGRectZero))
        {
            return;
        }
        
        if (!CGRectContainsRect(locationRect, sliderImage.frame))
        {
            // SMLog(@"Location contains Rect %f, %f, %f, %f", sliderImage.frame.origin.x, sliderImage.frame.origin.y, sliderImage.frame.size.width, sliderImage.frame.size.height);
            [UIView beginAnimations:@"moveslider" context:nil];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(SliderMoved:finished:context:)];
            sliderImage.center = CGPointMake((locationRect.origin.x + locationRect.size.width/2), sliderImage.center.y);
            [UIView commitAnimations];
        }
    }
    else 
    {
        // go to previous "calendar" month and retrieve details
        // show slider in the first location
        //pavaman 16th Jan 2011 - we should go the prev month end
		//[calendar PrevMonth];
        [calendar PrevMonthEnd];

		[self RefreshLandscape];
        // Calendar function
        [self setupWeeks];
        // Event setup
        [self setUpDayRect];
        // [self setupEvents];
        // Move slider to the last date
        [self setSliderToLast];
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSArray * startEnd = [self getWeekStartEndDatesAtOptionalIndex:[NSString stringWithFormat:@"%d", currentSliderPositionIndex]];
    NSString * _currentDate = [startEnd objectAtIndex:0];
    NSMutableArray * currentDateRange = [[appDelegate getWeekdates:_currentDate] retain];
    
    [dict setValue:currentDateRange forKey:@"CurrentRange"];
    SBJsonWriter *writer = [[[SBJsonWriter alloc] init] autorelease];
    NSString *json = [writer stringWithObject:dict];
    [dict release];
    [prevWeek setAccessibilityValue:json];
}

- (void) setSliderToFirst
{
    CGRect locationRect = [[sliderBoundsArray objectAtIndex:0] CGRectValue];
    currentSliderPositionIndex = 0;
    [UIView beginAnimations:@"setSliderPosition" context:nil];
    [UIView setAnimationDuration:0.3];
    sliderImage.center = CGPointMake((locationRect.origin.x + locationRect.size.width/2), sliderImage.center.y);
    [UIView commitAnimations];
}

- (void) setSliderToLast
{
    CGRect locationRect = [[sliderBoundsArray objectAtIndex:[sliderBoundsArray count]-1] CGRectValue];
    currentSliderPositionIndex = [sliderBoundsArray count]-1;
    [UIView beginAnimations:@"setSliderPosition" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(SliderMoved:finished:context:)];
    sliderImage.center = CGPointMake((locationRect.origin.x + locationRect.size.width/2), sliderImage.center.y);
    [UIView commitAnimations];
}

- (IBAction) goToCurrentWeek
{
    /*if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }*/
    
    [self disableUI];
    
    [self clearWeekView];
    [activity startAnimating];
    [calendar GoToToday];
    
    // Calendar function
    [self setupWeeks];
    // Event setup
    [self setUpDayRect];
    [self setupEvents];
}

- (void) goToWeek:(NSUInteger)weekNum
{
    
}

#pragma mark -
#pragma mark Setup Events

- (void) setUpDayRect
{
    if (dayRectArray == nil)
        dayRectArray = [[NSMutableArray alloc] initWithCapacity:0];
    else
    {
        [dayRectArray removeAllObjects];
        [dayRectArray release];
        dayRectArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    for (int i = 0; i < 7; i++)
    {
        CGRect rect = CGRectMake(i*kwDAYMULTIPLE + i*kwXGAP, 0, wEVENTWIDTH, kwLOCATIONEND);
        [dayRectArray addObject:[NSValue valueWithCGRect:rect]];
    }
}

#define START_DATE          0
#define END_DATE            1
- (void) setupEvents
{
	@try{
    NSArray * startEnd = [self getWeekStartEndDatesAtOptionalIndex:[NSString stringWithFormat:@"%d", currentSliderPositionIndex]];
    NSString * _currentDate = [startEnd objectAtIndex:START_DATE];
  //  startDate = [startEnd objectAtIndex:START_DATE];
   // endDate = [startEnd objectAtIndex:END_DATE];
 //   SMLog(@"%@ %@", startDate, endDate);
    currenSliderPositionMoved = NO;
    
    // Samman - Thu Aug 4, 2011 - CLEAR eventPositionArray before display
    [weeklyEventPositionArray removeAllObjects];
    [eventViewArray removeAllObjects];
    
    
    //to check database
    appDelegate.wsInterface.currentDateRange = [calendar getWeekBoundaries:_currentDate];
    startDate = [appDelegate.wsInterface.currentDateRange objectAtIndex:0];
    endDate = [appDelegate.wsInterface.currentDateRange objectAtIndex:1];

    
    NSMutableArray * currentDateRange = [[appDelegate getWeekdates:_currentDate] retain];
    
     /*Shravya-Calendar view 7408 */
    NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
    appDelegate.wsInterface.eventArray = [appDelegate.calDataBase GetEventsFromDBWithStartDate:[currentDateRange objectAtIndex:0]  endDate:[currentDateRange objectAtIndex:1]];
        
        
       
    [aPool drain];
	[currentDateRange release];
        
    /*Shravya-Calendar view 7408 */
    //Shravya- populateWeekView has to be called on main thread as UI operation happens in that function.
    [self performSelectorOnMainThread:@selector(populateWeekView) withObject:nil waitUntilDone:YES];
    //[self populateWeekView];
    
    //[appDelegate.wsInterface getEventsForStartDate:startDate EndDate:endDate];
    }@catch (NSException *exp) {
        SMLog(@"Exception Name WeeklyViewController :setupEvents %@",exp.name);
        SMLog(@"Exception Reason WeeklyViewController :setupEvents %@",exp.reason);
    }

}

- (void) stopActivity
{
    [activity stopAnimating];
}
- (void) setEventDetails:(NSArray *)_eventDetails
{
    eventDetails = [_eventDetails retain];
}

- (void) clearWeekView
{
	@try{
    // remove all events from view if any are present
    NSArray * array = [weekViewPane subviews];
    for (int i = 0; i < [array count]; i++)
    {
        [[array objectAtIndex:i] removeFromSuperview];
    }
    
    //radha 12th August 2011
    [weeklyEventPositionArray removeAllObjects];
    
    [eventViewArray removeAllObjects];
    [weeklyEventPositionArray removeAllObjects];
     }@catch (NSException *exp) {
        SMLog(@"Exception Name WeeklyViewController :clearWeekView %@",exp.name);
        SMLog(@"Exception Reason WeeklyViewController :clearWeekView %@",exp.reason);
    }

}

- (void) didQueryWorkOrder:(NSDictionary *)dictionary
{
    if (workOrderDictionary != nil)
    {
        [workOrderDictionary release];
        workOrderDictionary = nil;
    }
    workOrderDictionary = [dictionary retain];
    @try{
    eventsArray = [dictionary objectForKey:EVENTARRAY];
    NSArray * workOrderArray = [dictionary objectForKey:WORKORDERARRAY];
    NSArray * workOrderDetailsArray = [[dictionary objectForKey:WORKORDERDETAILSARRAY] copy];
    
    [self clearWeekView];
    
    for (int i = 0; i < [workOrderArray count]; i++)
    {
        
        NSArray * event = [[NSArray arrayWithObjects:
                        [[[workOrderArray objectAtIndex:i] objectForKey:WORKORDERNAME] isKindOfClass:[NSString class]]?[[workOrderArray objectAtIndex:i] objectForKey:WORKORDERNAME]:@"",
                        [[[workOrderArray objectAtIndex:i] objectForKey:WORKORDERTYPE] isKindOfClass:[NSString class]]?[[workOrderArray objectAtIndex:i] objectForKey:WORKORDERTYPE]:@"",
                        [[[workOrderArray objectAtIndex:i] objectForKey:SVMXCACCOUNTNAME] isKindOfClass:[NSString class]]?[[workOrderArray objectAtIndex:i] objectForKey:SVMXCACCOUNTNAME]:@"",
                             nil
                             ] retain];
        
        // Obtain day index by subtracting thisDate from first date in WeeksArray
        // NSUInteger index = [[weekDetails objectForKey:wWEEK] intValue]-1;
        NSMutableArray * array = [weeksArray objectAtIndex:currentSliderPositionIndex];
        // Analyser
        // NSUInteger dayIndex = [thisDate intValue] - [[array objectAtIndex:0] intValue];
        NSUInteger dayIndex = 0;

        // Obtain start time
        // Convert Event Time to local format
        NSString * eventTime = [[workOrderArray objectAtIndex:i] objectForKey:STARTDATETIME];
        NSString * startDateTime = [iOSInterfaceObject getLocalTimeFromGMT:eventTime];
        
        eventTime = [[workOrderArray objectAtIndex:i] objectForKey:ACTIVITYDATETIME];

        NSString * activityDateTime = [iOSInterfaceObject getLocalTimeFromGMT:eventTime];
        eventTime = activityDateTime;

        NSString * endDateTime = [[workOrderArray objectAtIndex:i] objectForKey:ENDDATETIME];
        endDateTime = [iOSInterfaceObject getLocalTimeFromGMT:endDateTime];
        
        // Compare eventTime with today. if eventTime->date != today, do not show it here
        NSString * eventTimeDate = [eventTime substringToIndex:10];
        // Find out which day does the event actually belong to
        NSString * eventActualDate = [eventTimeDate substringFromIndex:8];
        
        int day = [eventActualDate intValue];
        for (int i = 0; i < [array count]; i++)
        {
            int arrayDay = [[array objectAtIndex:i] intValue];
            if (arrayDay == day)
            {
                dayIndex = i;
                break;
            }
        }
        
        // Retrieve time of day and calculate integral multiple of time difference
        eventTime = [eventTime substringFromIndex:11];
        eventTime = [eventTime stringByReplacingOccurrencesOfString:@"Z" withString:@""];
        
        // Obtain duration
        NSString * duration = [[workOrderArray objectAtIndex:i] objectForKey:DURATION];
      
        
        
        // Obtain color coding
        NSString * priority = [[workOrderArray objectAtIndex:i] objectForKey:WORKORDERPRIORITY];
        NSUInteger colorCoding = [self getPriorityColorByPriority:priority];
        
        aEventView= [[WeeklyViewEvent alloc] initWithNibName:[WeeklyViewEvent description] bundle:nil];
        aEventView.delegate = self;
        
        for (int j = 0; j < [eventsArray count]; j++)
        {
            ZKSObject * obj = [eventsArray objectAtIndex:j];
            NSString * eventId = [[[obj fields] objectForKey:EVENTID] isKindOfClass:[NSString class]]?[[obj fields] objectForKey:EVENTID]:@"";
            NSString * eventIdFromWO = [[workOrderArray objectAtIndex:i] objectForKey:EVENTID];
            if ([eventId isEqualToString:eventIdFromWO])
            {
                ZKSObject * obj = [workOrderDetailsArray objectAtIndex:i];
                [obj setFieldValue:activityDateTime field:ACTIVITYDATETIME];
                [obj setFieldValue:startDateTime field:STARTDATETIME];
                [obj setFieldValue:endDateTime field:ENDDATETIME];
                
                aEventView.eventDetail = obj;
            }
        }
        
        aEventView.workOrderDetail = [[[workOrderArray objectAtIndex:i] mutableCopy] autorelease];
        aEventView.eventId = [[workOrderArray objectAtIndex:i] objectForKey:EVENTID];
        aEventView.view.tag = [eventViewArray count];
        
        [aEventView setEvent:event Day:dayIndex Time:eventTime Duration:(CGFloat)[duration intValue]/60*2 Color:colorCoding];
        [eventViewArray addObject:aEventView];
        [weekViewPane addSubview:aEventView.view];
        [aEventView release];
        aEventView = nil;
        
        // Analyser
        [event release];
    }
    
    [activity stopAnimating];
    
    // Analyser
    [workOrderDetailsArray release];
	
	//pavaman 21st Jan 2011		
	didLoadWeekData = TRUE;
	}@catch (NSException *exp) {
            SMLog(@"Exception Name WeeklyViewController :didQueryWorkOrder %@",exp.name);
            SMLog(@"Exception Reason WeeklyViewController :didQueryWorkOrder %@",exp.reason);
    }

}

- (NSString *) getLocalTimeFromGMT:(NSString *)gmtDate
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString * tmpDate = [gmtDate substringToIndex:[gmtDate length]-1];
    tmpDate = [tmpDate stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSDate * originalDate = [dateFormatter dateFromString:tmpDate];
    
    NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT];
    
    NSTimeInterval gmtTimeInterval = [originalDate timeIntervalSinceReferenceDate] + timeZoneOffset;
    
    NSDate * localDate = [NSDate dateWithTimeIntervalSinceReferenceDate:gmtTimeInterval];
    
    // Convert localDate back into string using dateFormatter
    NSString * newDate = [dateFormatter stringFromDate:localDate];
    newDate = [newDate stringByReplacingOccurrencesOfString:@" " withString:@"T"];
    newDate = [NSString stringWithFormat:@"%@Z", newDate];
    
    [dateFormatter release];
    
    return newDate;
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
#pragma mark WeeklyViewEventDelegate Methods

- (void) setTouchesDisabled
{
    [self disableUI];
}

- (void) movedEvent:(WeeklyViewEvent *)event
{
    //new start time and end time
    @try{
    [activity startAnimating];
    NSDictionary * startEndTime = [event getEventStartEndTime];
    SMLog(@"%@", startEndTime);
    
    NSString * startTime = [startEndTime objectForKey:STARTTIME];
    NSString * endTime = [startEndTime objectForKey:ENDTIME];
    
    NSString * time = endTime;

    NSNumber * day = [startEndTime objectForKey:DAY];
    
    NSString * _startDate = [event.startDate substringToIndex:11];
    
    startTime = [NSString stringWithFormat:@"%@ %@", _startDate, startTime];
    endTime = [NSString stringWithFormat:@"%@ %@", _startDate, endTime];
    
    NSArray * array = [weeksArray objectAtIndex:currentWeek];
    
    NSString * date = [array objectAtIndex:[day intValue]];
    
    if ([date intValue] <= 0)
    {
        // Event cannot be moved to this date as this belongs to a different month
        // Just refresh data from the server
        [self setupEvents];
        return;
    }
    
    if ([date intValue] < 10)
        date = [NSString stringWithFormat:@"0%d", [date intValue]];
    NSRange range = {8,2};
    int prevDate = [[startTime substringWithRange:range] intValue];  
    SMLog(@"PrevDate = %d and Next Date =%d",prevDate,[date intValue]);
    int diff = ([date intValue] > prevDate)?([date intValue] - prevDate):(prevDate - [date intValue]);
    if(diff > 7)
    {
        if( prevDate > [date intValue] )
        {
            NSRange monthRange = {5,2};
            int newMonth = [[startTime substringWithRange:monthRange] intValue]; 
            newMonth = newMonth + 1;
            if(newMonth == 13 )
            {
                newMonth = 1; 
                NSRange yearRange = {0,4};
                int newYear = [[startTime substringWithRange:yearRange] intValue]; 
                NSString *newMonthStr, *newYearStr;
                newMonthStr = [NSString stringWithFormat:@"0%d",newMonth];
                newYear = newYear + 1;
                newYearStr = [NSString stringWithFormat:@"%d",newYear];                                
                startTime = [startTime stringByReplacingCharactersInRange:NSMakeRange(5, 2) withString:newMonthStr];
                startTime = [startTime stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:newYearStr];
                endTime = [endTime stringByReplacingCharactersInRange:NSMakeRange(5, 2) withString:newMonthStr];
                endTime = [endTime stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:newYearStr];
                
            }
            else
            {
                NSString *newMonthStr;
                if(newMonth<10)
                    newMonthStr = [NSString stringWithFormat:@"0%d",newMonth];
                else
                    newMonthStr = [NSString stringWithFormat:@"%d",newMonth];
                startTime = [startTime stringByReplacingCharactersInRange:NSMakeRange(5, 2) withString:newMonthStr];
                endTime = [endTime stringByReplacingCharactersInRange:NSMakeRange(5, 2) withString:newMonthStr];
                
            }
            
        }
        else
        {
            NSRange monthRange = {5,2};
            int newMonth = [[startTime substringWithRange:monthRange] intValue]; 
            newMonth = newMonth -1;
            if(newMonth == 0 )
            {
                newMonth = 12; 
                NSRange yearRange = {0,4};
                int newYear = [[startTime substringWithRange:yearRange] intValue]; 
                NSString *newMonthStr, *newYearStr;
                if(newMonth<10)
                    newMonthStr = [NSString stringWithFormat:@"0%d",newMonth];
                else
                    newMonthStr = [NSString stringWithFormat:@"%d",newMonth];
                newYear = newYear -1;
                newYearStr = [NSString stringWithFormat:@"%d",newYear];                
                
                startTime = [startTime stringByReplacingCharactersInRange:NSMakeRange(5, 2) withString:newMonthStr];
                startTime = [startTime stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:newYearStr];
                endTime = [endTime stringByReplacingCharactersInRange:NSMakeRange(5, 2) withString:newMonthStr];
                endTime = [endTime stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:newYearStr];
            }
            else
            {
                NSString *newMonthStr;
                if(newMonth<10)
                    newMonthStr = [NSString stringWithFormat:@"0%d",newMonth];
                else
                    newMonthStr = [NSString stringWithFormat:@"%d",newMonth];
                startTime = [startTime stringByReplacingCharactersInRange:NSMakeRange(5, 2) withString:newMonthStr];
                endTime = [endTime stringByReplacingCharactersInRange:NSMakeRange(5, 2) withString:newMonthStr];
            }
        }
    }

    //Replace date with current date
    NSString * oldString = [startTime substringToIndex:10];
    NSString * newString = [startTime substringToIndex:8];
    newString = [newString stringByAppendingFormat:@"%@", date];
    
    startTime = [startTime stringByReplacingOccurrencesOfString:oldString withString:newString];
    if ([time isEqualToString:@"00:00:00"])
    {
        NSInteger value = [date integerValue];
        ++value;
        NSString * date1 = [NSString stringWithFormat:@"%d", value];
        newString = [startTime substringToIndex:8];
        newString = [newString stringByAppendingFormat:@"%@", date1];
        endTime = [endTime stringByReplacingOccurrencesOfString:oldString withString:newString];

    }
    else
        endTime = [endTime stringByReplacingOccurrencesOfString:oldString withString:newString];
    
    
    //Shrinivas
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
        SMLog(@"Exception Name WeeklyViewController :movedEvent %@",exp.name);
        SMLog(@"Exception Reason WeeklyViewController :movedEvent %@",exp.reason);
    }
     @finally {
    [self enableUI];
	 }
}
//sahana 12th Sept 2011
- (void) rescheduleEvent:(BOOL)continueReschedule;
{
    ContinueRescheduling = continueReschedule;
}
- (void)EditEvent:(BOOL)event_edit_flag
{
    edit_event = event_edit_flag;
}

- (void) didUpdateObjects:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
{
    SMLog(@"Updated objects");
    
    [self setupEvents];
}

- (void) didCreateObjects:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
{
    SMLog(@"Created objects");
}

- (CGRect) getSliderRectForLocation:(CGPoint)location
{
    for (int i = 0; i < [sliderBoundsArray count]; i++)
    {
        CGRect _rect = [[sliderBoundsArray objectAtIndex:i] CGRectValue];
        if (CGRectContainsPoint(_rect, location))
        {
            currentSliderPositionIndex = i;
            return _rect;
        }
    }
    return CGRectZero;
}

-(CGRect) getRectForLocation:(CGPoint)location
{
    for (int i = 0; i < 7; i++)
    {
        CGRect _rect = [[dayRectArray objectAtIndex:i] CGRectValue];
        if (CGRectContainsPoint(_rect, location))
            return _rect;
    }
    return CGRectZero;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    // SMLog(@"week view - willAnimateRotationToInterfaceOrientation");
}

- (void) setRotation:(UIInterfaceOrientation)_interfaceOrientation
{
    [[UIDevice currentDevice] performSelector:@selector(setOrientation:)
                                   withObject:(id)_interfaceOrientation];

}

#pragma mark -
#pragma mark EventViews Touch Methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
    if (!allowTouches)
        return;
	// We only support single touches, so anyObject retrieves just that touch from touches
	UITouch *touch = [touches anyObject];
	BOOL flag = NO;
    self.eventView = nil; //007746 
    
    if ([touch view] == weekViewPane)
    {
        initialPoint = [touch locationInView:weekViewPaneParent];
        return;
    }
    
	// Only move the event view if the touch was in the placard view
    for (int i = 0; i < [eventViewArray count]; i++)
    {
        self.eventView = [eventViewArray objectAtIndex:i]; ////007746
        if ([touch view] == eventView.view)
        {
            initialPosition = eventView.view.frame;
            flag = YES;
            didTap = YES;
            // SMLog(@"EventView %d tapped", i);
            [weekViewPane bringSubviewToFront:eventView.view];
            break;
        }
        else
        { 
            self.eventView = nil;  ////007746
        }
    }
    
    if ([touch view] == weekViewModify)
    {
        // Obtain location of touch, find locationRect, and move slider to locationRect, if possible
        CGPoint location = [touch locationInView:weekViewModify];
        
        CGRect locationRect = [self getSliderRectForLocation:location];
        if (CGRectEqualToRect(locationRect, CGRectZero))
        {
            return;
        }
        
        if (!CGRectContainsRect(locationRect, sliderImage.frame))
        {
           /* if (![appDelegate isInternetConnectionAvailable])
            {
                [activity stopAnimating];
                [appDelegate displayNoInternetAvailable];
                return;
            }*/
            [UIView beginAnimations:@"moveslider" context:nil];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(SliderMoved:finished:context:)];
            sliderImage.center = CGPointMake((locationRect.origin.x + locationRect.size.width/2), sliderImage.center.y);
            [UIView commitAnimations];
        }
    }
    
    if (!flag) return;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
    if (!allowTouches)
        return;

	UITouch *touch = [touches anyObject];
    
    didMove = YES;
    didMoveEvent = YES;
    
    if ([touch view] == weekViewPane)
    {
        CGPoint location = [touch locationInView:weekViewPaneParent];
        if ((weekViewPane.frame.origin.y <= 0) && (weekViewPane.frame.origin.y >= (-1 * weekViewPane.frame.size.height + weekViewPaneParent.frame.size.height)))
        {
            CGFloat diff = location.y - initialPoint.y;

            weekViewPane.frame = CGRectMake(0, weekViewPane.frame.origin.y+diff, weekViewPane.frame.size.width, weekViewPane.frame.size.height);
            
            initialPoint = location;
        }

        return;
    }
	
    if ([touch view] == sliderImage)
    {
        /*if (![appDelegate isInternetConnectionAvailable])
        {
            [activity stopAnimating];
            return;
        }*/
        
        CGPoint location = [touch locationInView:weekViewModify];
        
        CGRect locationRect = [self getSliderRectForLocation:location];
        if (CGRectEqualToRect(locationRect, CGRectZero))
        {
            return;
        }

        if (!CGRectContainsRect(locationRect, sliderImage.frame))
        {
            [UIView beginAnimations:@"moveslider" context:nil];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationDelegate:self];
            sliderImage.center = CGPointMake((locationRect.origin.x + locationRect.size.width/2), sliderImage.center.y);
            [UIView commitAnimations];
        }
    }

	// If the touch was in the eventView, move the eventView to its location
	if ([touch view] == eventView.view)
    {
		CGPoint location = [touch locationInView:weekViewPane];
        CGRect locationRect = [eventView getRectForLocation:location];
        
        if (CGRectEqualToRect(locationRect, CGRectZero))
        {
            return;
        }

        if (CGRectContainsRect(eventView.dayFrame, locationRect) || !CGRectEqualToRect(locationRect, eventView.view.frame))
        {
            if (((eventView.view.frame.origin.y + eventView.view.frame.size.height) > kwTIMEFLOOR) &&
                CGRectIntersectsRect(eventView.view.frame, locationRect))
            {
                return;
            }
            // Change eventView's frame
            eventView.dayFrame = locationRect;
            [UIView beginAnimations:@"move" context:nil];
            [UIView setAnimationDuration:0.3];
            eventView.view.frame = CGRectMake(locationRect.origin.x, locationRect.origin.y,
                                              eventView.view.frame.size.width, eventView.view.frame.size.height);
            [UIView commitAnimations];
            return;
        }
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
    if (!allowTouches)
        return;
    WeeklyViewEvent *calEvent = [eventView retain];
	UITouch *touch = [touches anyObject];
    @try{
    if ([touch view] == weekViewPane)
    {
        if (weekViewPane.frame.origin.y > 0)
        {
            [UIView beginAnimations:@"resetRightPane" context:nil];
            [UIView setAnimationDuration:0.3];
            weekViewPane.frame = CGRectMake(0, 0, weekViewPane.frame.size.width, weekViewPane.frame.size.height);
            [UIView commitAnimations];
        }
        
        if (weekViewPane.frame.origin.y < (-1 * weekViewPane.frame.size.height + weekViewPaneParent.frame.size.height))
        {
            [UIView beginAnimations:@"resetRightPane" context:nil];
            [UIView setAnimationDuration:0.3];
            weekViewPane.frame = CGRectMake(0, (-1 * weekViewPane.frame.size.height + weekViewPaneParent.frame.size.height), weekViewPane.frame.size.width, weekViewPane.frame.size.height);
            [UIView commitAnimations];
        }
    }
    
    if ([touch view] == sliderImage)
    {
        [activity startAnimating];
        // Invalidate current date range in appDelegate.wsInterface
        // This will automatically make the day view fetch fresh data from sfdc
        // when we go back to the day view
        appDelegate.wsInterface.currentDateRange = nil;
        [self setDaysAtSliderLocationIndex:currentSliderPositionIndex];
        return;
    }

    if (([touch view] == calEvent.view) && didTap && !didMove)
    {
        // Tapped the view, so do something
        didTap = didMove = NO;
//        NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
//        NSString * warning = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_WARNING];
//        NSString * noView = [appDelegate.wsInterface.tagsDictionary objectForKey:NO_VIEW_PROCESS];
        if (!didMoveEvent)
        {
            NSString * confictStr = [NSString stringWithFormat:@"%d",calEvent.conflictFlag];
        
            NSArray * keys = [NSArray arrayWithObjects:PROCESSID, RECORDID, OBJECTAPINAME, CREATEDDATE, ACCOUNTID, ACTIVITYDATE, ISCONFLICT,EVENT_LOCAL_ID, nil];
            NSArray * objects = [NSArray arrayWithObjects:calEvent.processId, calEvent.recordId, calEvent.objectName, calEvent.createdDate, calEvent.accountId, calEvent.activityDate,confictStr, calEvent.local_id,nil];
            NSDictionary * _dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
            [activity startAnimating];
                        
//            if ([[_dict objectForKey:PROCESSID] isEqualToString:@""] || [_dict objectForKey:PROCESSID] == nil)
//            {
//                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:warning message:noView delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
//                [alert show];
//                [alert release];
//            }
//            else
            {
                [self disableUI];
                
                didRunOperation = YES;
                [delegate showSFMForWeek:_dict];
                didRunOperation = NO;
            }
            [activity stopAnimating];
        }
        else
        {
            [self disableUI];
            [calEvent moveTo:calEvent.view.frame];
        }

        didTap = didMove = NO;
        [calEvent release];
        [self enableUI];
        return;
    }

    if ([touch view] == calEvent.view)
    {
        // CGPoint location = [touch locationInView:rightPane];
		// Disable user interaction so subsequent touches don't interfere with animation
        if (!didMoveEvent)
        {
        }
        else
        {
            [self disableUI];
            SMLog(@"%@", weeklyEventPositionArray);
            [calEvent moveTo:calEvent.view.frame];

            if(ContinueRescheduling == TRUE)
            {

                NSString * _currentDate;
                SMLog(@"%@", weeklyEventPositionArray);
                if ([updatestartDateTime length] > 0 && [updateendDateTime length] > 0)
                {
                    NSLog(@"Start Time = %@ and End Time = %@",updatestartDateTime,updateendDateTime);
                    //Shrinivas 
                    [appDelegate.calDataBase updateMovedEventWithStartTime:updatestartDateTime EndDate:updateendDateTime RecordID:calEvent.eventId event_localId:calEvent.local_id];
                    
                   NSString * local_id = [appDelegate.databaseInterface getLocalIdFromSFId:calEvent.eventId tableName:@"Event"];
                    NSLog(@"Local Id = %@ For Event Id = %@",local_id,calEvent.eventId);
                    //sahana 26/Feb
                    BOOL does_exists = [appDelegate.databaseInterface DoesTrailerContainTheRecord:local_id operation_type:UPDATE object_name:@"Event"];
                    if(!does_exists)
                    {
						//Sync_Override
                        [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:local_id SF_id:calEvent.eventId record_type:MASTER operation:UPDATE object_name:@"Event" sync_flag:@"false" parentObjectName:@"" parent_loacl_id:@"" webserviceName:@"" className:@"" synctype:AGRESSIVESYNC headerLocalId:local_id requestData:nil finalEntry:NO];
                    }
                    [appDelegate setAgrressiveSync_flag];
					//RADHA Defect Fix 5542
					appDelegate.shouldScheduleTimer = YES;
                    [appDelegate callDataSync];
                    
                    NSArray * startEnd = [self getWeekStartEndDatesAtOptionalIndex:[NSString stringWithFormat:@"%d", currentSliderPositionIndex]];
                     _currentDate = [startEnd objectAtIndex:START_DATE];
                    NSMutableArray * weekBound = [calendar getWeekBoundaries:_currentDate];
                    
                    startDate = [weekBound objectAtIndex:0];
                    endDate = [weekBound objectAtIndex:1];
                    
                                        
                    NSMutableArray * currentDateRange = [[appDelegate getWeekdates:_currentDate] retain];
                    
                    /*Shravya-Calendar view 7408 */
                    NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
                    appDelegate.wsInterface.eventArray = [appDelegate.calDataBase GetEventsFromDBWithStartDate:[currentDateRange objectAtIndex:0]  endDate:[currentDateRange objectAtIndex:1]];
                    
                    [aPool drain];
					[currentDateRange release];
                }
                
                updatestartDateTime = @"";
                updateendDateTime = @"";
                
                appDelegate.wsInterface.didRescheduleEvent = FALSE; //Reusing this variable for get Events purpose
               
             /*   if ([_currentDate length] == 0 )
                {
                   NSArray * startEnd = [self getWeekStartEndDatesAtOptionalIndex:[NSString stringWithFormat:@"%d", currentSliderPositionIndex]];
                    _currentDate = [startEnd objectAtIndex:START_DATE];
                }*/
                
                //Radha
                NSString * date = @"";
                NSArray * startEnd = [self getWeekStartEndDatesAtOptionalIndex:[NSString stringWithFormat:@"%d", currentSliderPositionIndex]];
                date = [startEnd objectAtIndex:START_DATE];
                
                NSMutableArray * currentDateRange = [[appDelegate getWeekdates:date] retain];
                
                /*Shravya-Calendar view 7408 */
                NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
                appDelegate.wsInterface.eventArray = [appDelegate.calDataBase GetEventsFromDBWithStartDate:[currentDateRange objectAtIndex:0]  endDate:[currentDateRange objectAtIndex:1]];
                
                [aPool drain];
                
				[currentDateRange release];
                if ([self.delegate respondsToSelector:@selector(setRescheduledAnEvent:)]) {
                    [self.delegate setRescheduledAnEvent:YES];
                }
                if ([appDelegate.wsInterface.rescheduleEvent isEqualToString:@"SUCCESS"])
                {
                    [activity stopAnimating];
                }
                else
                    [activity stopAnimating];

            }
            else if(!ContinueRescheduling && edit_event)
            {
                NSString * confictStr = [NSString stringWithFormat:@"%d",calEvent.conflictFlag];
                NSArray * keys = [NSArray arrayWithObjects:PROCESSID, RECORDID, OBJECTAPINAME, CREATEDDATE, ACCOUNTID, ACTIVITYDATE, ISCONFLICT,EVENT_LOCAL_ID, nil];
                NSArray * objects = [NSArray arrayWithObjects:calEvent.processId, calEvent.recordId, calEvent.objectName, calEvent.createdDate, calEvent.accountId, calEvent.activityDate,confictStr,calEvent.local_id, nil];
                NSDictionary * _dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                [delegate SFMEditForWeekView:_dict];
            }
            else
            {
            }
            
        }
	}
	 }@catch (NSException *exp) {
        SMLog(@"Exception Name WeeklyViewController :touchesEnded %@",exp.name);
        SMLog(@"Exception Reason WeeklyViewController :touchesEnded %@",exp.reason);
    }

    didMoveEvent = NO;
    didTap = didMove = NO;
    [calEvent release];
    [self enableUI];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
	// Sahana 12th Sept 2011
	// If the touch was in the placardView, bounce it back to the center
	if ([touch view] == eventView.view && touch.tapCount > 0)
    {
        eventView.view.frame = initialPosition;
//        eventView = nil;
        initialPosition = CGRectZero;
    }
}

- (void) SliderMoved:(NSString *)animationId finished:(NSNumber *)finished context:(void *)context
{
    [self disableUI];
    [self clearWeekView];
    [activity startAnimating];
    // Invalidate current date range in appDelegate.wsInterface
    // This will automatically make the day view fetch fresh data from sfdc
    // when we go back to the day view
    currenSliderPositionMoved = YES;
    appDelegate.wsInterface.currentDateRange = nil;
    [self setDaysAtSliderLocationIndex:currentSliderPositionIndex];
}

- (void) RefreshLandscape
{
    /*if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }*/
    didRunOperation = YES;
    for (int i = 0; i < [weeksArray count]; i++)
    {
        UILabel * label = (UILabel *)[weekViewModify viewWithTag:(i+1234)];
        [label removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [monday release];
    monday = nil;
    [tuesday release];
    tuesday = nil;
    [wednesday release];
    wednesday = nil;    
    [thursday release];
    thursday = nil;
    [friday release];
    friday = nil;
    [saturday release];
    saturday = nil;
    [sunday release];
    sunday = nil;
    [curWeek release];
    curWeek = nil;
    [day1Label release];
    day1Label = nil;
    [day2Label release];
    day2Label = nil;
    [day3Label release];
    day3Label = nil;
    [day4Label release];
    day4Label = nil;
    [day5Label release];
    day5Label = nil;
    [day6Label release];
    day6Label = nil;
    [day7Label release];
    day7Label = nil;
    
    [weekViewPane release];
    weekViewPane = nil;
    [weekViewPaneParent release];
    weekViewPaneParent = nil;
    [weekViewModify release];
    weekViewModify = nil;
    
    [sundayHighlight release];
    sundayHighlight = nil;
    [mondayHighlight release];
    mondayHighlight = nil;
    [tuesdayHighlight release];
    tuesdayHighlight = nil;
    [wednesdayHighlight release];
    wednesdayHighlight = nil;
    [thursdayHighlight release];
    thursdayHighlight = nil;
    [fridayHighlight release];
    fridayHighlight = nil;
    [saturdayHighlight release];
    saturdayHighlight = nil;
    
    [sliderImageView release];
    sliderImageView = nil;
    [sliderImage release];
    sliderImage = nil;
    
    [monthYear release];
    monthYear = nil;
    
    [activity release];
    activity = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [calendar release];
    [monday release];
    [tuesday release];
    [wednesday release];
    [thursday release];
    [friday release];
    [saturday release];
    [sunday release];
    [curWeek release];
    [day1Label release];
    [day2Label release];
    [day3Label release];
    [day4Label release];
    [day5Label release];
    [day6Label release];
    [day7Label release];
    [eventView release]; //eventView
    [super dealloc];
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
    [delegate enableRefreshButton:YES];
    [prevWeek setUserInteractionEnabled:YES];
    [nextWeek setUserInteractionEnabled:YES];
    [curWeek setUserInteractionEnabled:YES];
    calendarDidLoad = allowTouches = YES;
    [weekViewPane setUserInteractionEnabled:YES];
    [weekViewPaneParent setUserInteractionEnabled:YES];
    [self.view setUserInteractionEnabled:YES];
    [[super view] setUserInteractionEnabled:YES];
}

- (void) disableUI
{
//    [delegate enableRefreshButton:NO];
//    [prevWeek setUserInteractionEnabled:NO];
//    [nextWeek setUserInteractionEnabled:NO];
//    [curWeek setUserInteractionEnabled:NO];
 //   calendarDidLoad = allowTouches = NO;
    [weekViewPane setUserInteractionEnabled:NO];
    [weekViewPaneParent setUserInteractionEnabled:NO];
//    [self.view setUserInteractionEnabled:NO];
//    [[super view] setUserInteractionEnabled:NO];
}

@end
