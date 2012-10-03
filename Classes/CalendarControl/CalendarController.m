//
//  CalendarController.m
//  Calendar
//
//  Created by Samman Banerjee on 08/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CalendarController.h"
#import "LocalizationGlobals.h"

#import "iServiceAppDelegate.h"
extern void SVMXLog(NSString *format, ...);

@implementation CalendarController

@synthesize delegate;
// Row 1
@synthesize date11;
@synthesize date12;
@synthesize date13;
@synthesize date14;
@synthesize date15;
@synthesize date16;
@synthesize date17;
// Row 2
@synthesize date21;
@synthesize date22;
@synthesize date23;
@synthesize date24;
@synthesize date25;
@synthesize date26;
@synthesize date27;
// Row 3
@synthesize date31;
@synthesize date32;
@synthesize date33;
@synthesize date34;
@synthesize date35;
@synthesize date36;
@synthesize date37;
// Row 4
@synthesize date41;
@synthesize date42;
@synthesize date43;
@synthesize date44;
@synthesize date45;
@synthesize date46;
@synthesize date47;
// Row 5
@synthesize date51;
@synthesize date52;
@synthesize date53;
@synthesize date54;
@synthesize date55;
@synthesize date56;
@synthesize date57;
// Row 6
@synthesize date61;
@synthesize date62;
@synthesize date63;
@synthesize date64;
@synthesize date65;
@synthesize date66;
@synthesize date67;

@synthesize label;

@synthesize weeksArray;

@synthesize didReloadCalendar;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
        // Custom initialization
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
	[self ConnectButtonArray];
	[self initDayMonth];
    [self SetCurrentCalendar];
    
    
    //Radha 22nd April 2011
    //Assigning the text or label to the days to be localized in the calender view
    calMonday.font = [UIFont systemFontOfSize:12];
    calTuesday.font = [UIFont systemFontOfSize:12];
    calWednesday.font = [UIFont systemFontOfSize:12];
    calThursday.font = [UIFont systemFontOfSize:12];
    calFriday.font = [UIFont systemFontOfSize:12];
    calSaturday.font = [UIFont systemFontOfSize:12];
    calSunday.font = [UIFont systemFontOfSize:12];
    
    calMonday.text = ([appDelegate.wsInterface.tagsDictionary objectForKey:CAL_MON] != nil)?[appDelegate.wsInterface.tagsDictionary objectForKey:CAL_MON]:MON;
    calTuesday.text = ([appDelegate.wsInterface.tagsDictionary objectForKey:CAL_TUE] != nil)?[appDelegate.wsInterface.tagsDictionary objectForKey:CAL_TUE]:TUE;
    calWednesday.text = ([appDelegate.wsInterface.tagsDictionary objectForKey:CAL_WED] != nil)?[appDelegate.wsInterface.tagsDictionary objectForKey:CAL_WED]:WED;
    calThursday.text = ([appDelegate.wsInterface.tagsDictionary objectForKey:CAL_THU] != nil)?[appDelegate.wsInterface.tagsDictionary objectForKey:CAL_THU]:THU;
    calFriday.text = ([appDelegate.wsInterface.tagsDictionary objectForKey:CAL_FRI] != nil)?[appDelegate.wsInterface.tagsDictionary objectForKey:CAL_FRI]:FRI;
    calSaturday.text = ([appDelegate.wsInterface.tagsDictionary objectForKey:CAL_SAT] != nil)?[appDelegate.wsInterface.tagsDictionary objectForKey:CAL_SAT]:SAT;
    calSunday.text = ([appDelegate.wsInterface.tagsDictionary objectForKey:CAL_SUN] != nil)?[appDelegate.wsInterface.tagsDictionary objectForKey:CAL_SUN]:SUN;
    
    //END
}

- (void) ConnectButtonArray
{
	buttonArray = [[NSMutableArray alloc] initWithCapacity:43];
	//[buttonArray addObject:date11];
	[buttonArray addObject:date11];
	[buttonArray addObject:date12];
	[buttonArray addObject:date13];
	[buttonArray addObject:date14];
	[buttonArray addObject:date15];
	[buttonArray addObject:date16];
	[buttonArray addObject:date17];
	
	[buttonArray addObject:date21];
	[buttonArray addObject:date22];
	[buttonArray addObject:date23];
	[buttonArray addObject:date24];
	[buttonArray addObject:date25];
	[buttonArray addObject:date26];
	[buttonArray addObject:date27];
	
	[buttonArray addObject:date31];
	[buttonArray addObject:date32];
	[buttonArray addObject:date33];
	[buttonArray addObject:date34];
	[buttonArray addObject:date35];
	[buttonArray addObject:date36];
	[buttonArray addObject:date37];
	
	[buttonArray addObject:date41];
	[buttonArray addObject:date42];
	[buttonArray addObject:date43];
	[buttonArray addObject:date44];
	[buttonArray addObject:date45];
	[buttonArray addObject:date46];
	[buttonArray addObject:date47];
	
	[buttonArray addObject:date51];
	[buttonArray addObject:date52];
	[buttonArray addObject:date53];
	[buttonArray addObject:date54];
	[buttonArray addObject:date55];
	[buttonArray addObject:date56];
	[buttonArray addObject:date57];
	
	[buttonArray addObject:date61];
	[buttonArray addObject:date62];
	[buttonArray addObject:date63];
	[buttonArray addObject:date64];
	[buttonArray addObject:date65];
	[buttonArray addObject:date66];
	[buttonArray addObject:date67];
}

- (void) initDayMonth
{
/*	dayArray = [[NSArray alloc] initWithObjects:
                @"Bounds Correction", 
				@"Monday", 
				@"Tuesday", 
				@"Wednesday", 
				@"Thursday", 
				@"Friday", 
				@"Saturday",
                @"Sunday",
				nil];
	
	 monthArray = [[NSArray alloc] initWithObjects:
                  @"Bounds Correction",
				  @"January", 
				  @"February", 
				  @"March", 
				  @"April", 
				  @"May", 
				  @"June", 
				  @"July", 
				  @"August", 
				  @"September", 
				  @"October", 
				  @"November", 
				  @"December", 
				  nil];*/
    
    dayArray = [[NSArray alloc] initWithObjects:
                @"Bounds Correction", 
				[appDelegate.wsInterface.tagsDictionary objectForKey:DAY1LABEL], 
				[appDelegate.wsInterface.tagsDictionary objectForKey:DAY2LABEL], 
				[appDelegate.wsInterface.tagsDictionary objectForKey:DAY3LABEL], 
				[appDelegate.wsInterface.tagsDictionary objectForKey:DAY4LABEL], 
				[appDelegate.wsInterface.tagsDictionary objectForKey:DAY5LABEL], 
				[appDelegate.wsInterface.tagsDictionary objectForKey:DAY6LABEL],
                [appDelegate.wsInterface.tagsDictionary objectForKey:DAY7LABEL],
				nil];
    
    //Radha 22nd April 2011
    //For localization of calender date and month.
    monthArray = [[NSArray alloc] initWithObjects:
                  @"Bounds Correction",
                  [appDelegate.wsInterface.tagsDictionary objectForKey:MONTH1LABEL],  
                  [appDelegate.wsInterface.tagsDictionary objectForKey:MONTH2LABEL],      
                  [appDelegate.wsInterface.tagsDictionary objectForKey:MONTH3LABEL],          
                  [appDelegate.wsInterface.tagsDictionary objectForKey:MONTH4LABEL],        
                  [appDelegate.wsInterface.tagsDictionary objectForKey:MONTH5LABEL],            
                  [appDelegate.wsInterface.tagsDictionary objectForKey:MONTH6LABEL],            
                  [appDelegate.wsInterface.tagsDictionary objectForKey:MONTH7LABEL],          
                  [appDelegate.wsInterface.tagsDictionary objectForKey:MONTH8LABEL],         
                  [appDelegate.wsInterface.tagsDictionary objectForKey:MONTH9LABEL],      
                  [appDelegate.wsInterface.tagsDictionary objectForKey:MONTH10LABEL],         
                  [appDelegate.wsInterface.tagsDictionary objectForKey:MONTH11LABEL],      
                  [appDelegate.wsInterface.tagsDictionary objectForKey:MONTH12LABEL],
				  nil];
    
	monthDaysInYearDict = [[NSArray alloc] initWithObjects:
                       @"Bounds Correction",
					   @"31",
					   @"28",
					   @"31",
					   @"30",
					   @"31",
					   @"30",
					   @"31",
					   @"31",
					   @"30",
					   @"31",
					   @"30",
					   @"31",
					   nil];
}

- (void) GoToToday
{
    selDate = 0;
    [self SetCurrentCalendar];
}



- (void) SetCurrentCalendar
{
	NSDate * today = [NSDate date];
	NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setFirstWeekday:1];
	NSDateComponents * dateComponents = [gregorian components:(NSWeekdayCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:today];
    [gregorian release];

	dateLabel.text = [NSString stringWithFormat:@"%d", [dateComponents day]];
	NSInteger weekday = [dateComponents weekday];
    weekday = (weekday==1)?7:([dateComponents weekday]-1);
	
	// selMonth and selYear is currently selected month and year
    currDate = [dateComponents day];
	selMonth = [dateComponents month];
	selYear = [dateComponents year];
    
    if (didReloadCalendar)
    {
        dateLabel.text = [appDelegate.lastSelectedDate objectAtIndex:0];
        selDate = currDate = [[appDelegate.lastSelectedDate objectAtIndex:0] intValue];
        selMonth = [[appDelegate.lastSelectedDate objectAtIndex:1] intValue];
        selYear = [[appDelegate.lastSelectedDate objectAtIndex:2] intValue];
    }
	
	NSString * calendarLabel = @"";
	calendarLabel = [calendarLabel stringByAppendingString:[monthArray objectAtIndex:selMonth]];
	calendarLabel = [calendarLabel stringByAppendingString:@" "];
	calendarLabel = [calendarLabel stringByAppendingString:[NSString stringWithFormat:@"%d", selYear]];
	label.text = calendarLabel;
    
    if ( [dayArray count] > 0)
        dayLabel.text = [NSString stringWithFormat:@"%@, %@", [dayArray objectAtIndex:weekday], calendarLabel];

	[self UpdateDates];
}

- (IBAction) NextMonth
{
    /*if (!appDelegate.isInternetConnectionAvailable)
    {
        [appDelegate displayNoInternetAvailable];
        return;
    }*/
    
	if (++selMonth == 13)
	{
		selMonth = 1;
		selYear++;
	}
	
	[self RefreshCalendar];
    [self setDayLabel];
}

- (IBAction) PrevMonth
{
    /*if (!appDelegate.isInternetConnectionAvailable)
    {
        [appDelegate displayNoInternetAvailable];
        return;
    }*/

	if (--selMonth < 1)
	{
		selMonth = 12;
		selYear--;
	}

	[self RefreshCalendar];
    [self setDayLabel];
}

- (void) NextMonthStart
{
    if (++selMonth == 13)
	{
		selMonth = 1;
		selYear++;
	}
    selDate = currDate = 1;
	[self RefreshCalendar];
    [self setDayLabel];
}

- (void) PrevMonthEnd
{
    if (--selMonth < 1)
	{
		selMonth = 12;
		selYear--;
	}
    selDate = currDate = [[monthDaysInYearDict objectAtIndex:selMonth] intValue];
	[self RefreshCalendar];
    [self setDayLabel];
}

- (void) setDayLabel
{
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDateComponents * dayOne = [[NSDateComponents alloc] init];
    if ((currDate == selDate) && (selDate != 0))
        [dayOne setDay:currDate];
    else
    {
        if (selDate == 0)
            [dayOne setDay:currDate];
        else
            [dayOne setDay:selDate];
    }

	[dayOne setMonth:selMonth];
	[dayOne setYear:selYear];
    
    NSDate * FirstDay = [gregorian dateFromComponents:dayOne];
	NSDateComponents * dateComponents = [gregorian components:(NSWeekdayCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:FirstDay];
	NSInteger weekday = [dateComponents weekday];
    weekday = weekday==1?7:[dateComponents weekday]-1;
    
    NSString * calendarLabel = @"";
	calendarLabel = [calendarLabel stringByAppendingString:[monthArray objectAtIndex:selMonth]];
	calendarLabel = [calendarLabel stringByAppendingString:@" "];
	calendarLabel = [calendarLabel stringByAppendingString:[NSString stringWithFormat:@"%d", selYear]];
    
    dayLabel.text = [NSString stringWithFormat:@"%@, %@", [dayArray objectAtIndex:weekday], calendarLabel];
    
    [dayOne release];
    [gregorian release];
}

- (void) RefreshCalendar
{
	NSString * calendarLabel = @"";
	calendarLabel = [calendarLabel stringByAppendingString:[monthArray objectAtIndex:selMonth]];
	calendarLabel = [calendarLabel stringByAppendingString:@" "];
	calendarLabel = [calendarLabel stringByAppendingString:[NSString stringWithFormat:@"%d", selYear]];
	label.text = calendarLabel;
    
    for (int i = 0; i < [buttonArray count]; i++)
    {
        UIButton * button = [buttonArray objectAtIndex:i];
        [button setTitle:nil forState:UIControlStateNormal];
        button.titleLabel.text = nil;
        [button setTag:i]; // #3502
    }
	
	[self UpdateDates];
}

- (void) UpdateDates
{
	NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDateComponents * dayOne = [[NSDateComponents alloc] init];
	[dayOne setDay:1];
	[dayOne setMonth:selMonth];
	[dayOne setYear:selYear];
	
	NSDate * FirstDay = [gregorian dateFromComponents:dayOne];
	NSDateComponents * dateComponents = [gregorian components:(NSWeekdayCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:FirstDay];
	NSInteger weekday = [dateComponents weekday];
    weekday= weekday==1?7:[dateComponents weekday]-1;
	// Retrieve number of days in month
	NSString * numberOfDays = [monthDaysInYearDict objectAtIndex:selMonth];
	int numDays = [numberOfDays intValue];
	if ([self IsLeapYear:selYear])
	{
		if (selMonth == 2)
		{
			numDays++;
		}
	}
    
	[self PopulateDateFromDay:weekday totalDays:numDays];
    
    if ([delegate respondsToSelector:@selector(setTotalDivisions:)])
        [delegate setTotalDivisions:numDays];
	
	[dayOne release];
    [gregorian release];
    
    [self highlightCurrentDate];
    
    if ([delegate respondsToSelector:@selector(setDate:)])
        [delegate setDate:selDate];
}

- (void) highlightCurrentDate
{
    [self resetAllCellBackgroundColor];
    
    BOOL neverHighlightedDate = YES; // This means that the last date of the previous month does not exist in the current month

    if (selDate == 0)
    {
        selDate = currDate;
    }
    int index = 0;
    BOOL dateFound = NO;
    for (int i = 0; i < [buttonArray count]; i++)
    {
        UIButton * button = [buttonArray objectAtIndex:i];
        
        if (!dateFound && [button.titleLabel.text isEqualToString:@"1"])
        {
            index = i;
            dateFound = YES;
        }
        [button setBackgroundImage:nil forState:UIControlStateNormal];
        [button setBackgroundImage:nil forState:UIControlStateSelected];
    }
    
    for (int i = index; i < [buttonArray count]; i++)
    {
        UIButton * button = [buttonArray objectAtIndex:i];
        
        if ([button.titleLabel.text isEqualToString:[NSString stringWithFormat:@"%d", selDate]])
        {
            // [button setBackgroundColor:[UIColor colorWithRed:0 green:100 blue:100 alpha:0.5]];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"calendar-date-highlighter.png"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"calendar-date-highlighter.png"] forState:UIControlStateSelected];
            neverHighlightedDate = NO;
            break;
        }
    }
    
    // If last date of last month does not exist in current month
    // make last date of current month the selected date
    if (neverHighlightedDate)
    {
        selDate = currDate = [[monthDaysInYearDict objectAtIndex:selMonth] intValue];
        [self highlightCurrentDate];
        [self setDate:selDate];
    }
}

- (void) resetAllCellBackgroundColor
{
    BOOL is_prev_next_month = YES;
    BOOL isMonthStarted = NO;
    NSString *nextBtnTitle;
    NSString *curBtnTitle;
    
    for (NSUInteger i = 0; i < [buttonArray count]; i++)
    {
        UIButton * button = [buttonArray objectAtIndex:i];
        curBtnTitle  = [button titleForState:UIControlStateNormal];
        if(i+1 < [buttonArray count])
            nextBtnTitle = [[buttonArray objectAtIndex:i+1] titleForState:UIControlStateNormal];
        else
            nextBtnTitle = nil;
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        if([curBtnTitle isEqualToString:@"1"])
        {
            if(!isMonthStarted)
            {
                isMonthStarted = YES;
                is_prev_next_month = NO;
            }
            else
                is_prev_next_month = YES;
        }
        if(is_prev_next_month)
            // [button setTitleColor:[UIColor colorWithRed:0.79 green:0.79 blue:0.79 alpha:0.75] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithRed:0.79 green:0.79 blue:0.79 alpha:0.0] forState:UIControlStateNormal];
        
        if(!is_prev_next_month && nextBtnTitle!=nil)
        {
            if([curBtnTitle intValue] > [nextBtnTitle intValue])
                is_prev_next_month = YES;
        }
        
        [button setBackgroundImage:nil forState:UIControlStateNormal];
        [button setBackgroundImage:nil forState:UIControlStateSelected];
    }
}

- (BOOL) IsLeapYear:(int)year
{
	if (((year%4 == 0) && (year % 100 != 0)) || (year % 400 == 0))
		return YES;
	return NO;
}

- (void) PopulateDateFromDay:(NSInteger) weekday totalDays:(NSInteger) numDays
{
    if (dates == nil)
        dates = [[NSMutableArray alloc] initWithCapacity:43];
    else
    {
        if ([dates retainCount] > 0)
        {
            if ([dates count] > 0)
                [dates removeAllObjects];
        }
    }

	int dayCount = 1;

	for (int j = 0; j < weekday; j++)
	{
		[dates insertObject:@"" atIndex:j];
	}
	/*
	for (int k = 0; k < [buttonArray count]; k++)
	{
		UIButton * button = [buttonArray objectAtIndex:k];
		[button setTitle:nil forState:UIControlStateNormal];
		button.titleLabel.text = nil;
	}
    */
    // weekday = weekday==7?7:weekday-1; 

    NSMutableArray *prevDays = [self getRemainingDaysInMonth:selMonth-1 lastNumOfDays:weekday isPrevMonth:YES];
    for (int i = 0; i < weekday-1; i++)
	{
		[dates insertObject:[prevDays objectAtIndex:i+1] atIndex:i];
		UIButton * button = [buttonArray objectAtIndex:i];
		[button setTitle:[dates objectAtIndex:i] forState:UIControlStateNormal];
        [button setEnabled:NO];
	}
    //Siva Manne End Prev Month Days
	for (int i = weekday-1; i < numDays + weekday - 1; i++)
        // for (int i = 0; i < numDays; i++)
	{
        // // SMLog(@"Date inserted = %@", [NSString stringWithFormat:@"%d", dayCount]);
		[dates insertObject:[NSString stringWithFormat:@"%d", dayCount++] atIndex:i];
		UIButton * button = [buttonArray objectAtIndex:i];
		[button setTitle:[dates objectAtIndex:i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button setEnabled:YES];
	}
    //Siva Manne Next Month Days
    NSMutableArray *nextMonthDays = [self getRemainingDaysInMonth:selMonth lastNumOfDays:weekday isPrevMonth:NO];
    
    int count_next_month_days=0;
    for (int i = numDays + weekday - 1; i < numDays + weekday - 1+[nextMonthDays count]; i++)
	{
		[dates insertObject:[nextMonthDays objectAtIndex:count_next_month_days++] atIndex:i];
		UIButton * button = [buttonArray objectAtIndex:i];
		[button setTitle:[dates objectAtIndex:i] forState:UIControlStateNormal];
        [button setEnabled:NO];
	}
    //Keerti Remaining Buttons Set to NULL #4118
    for (int i = numDays + weekday - 1+[nextMonthDays count]; i < [buttonArray count]; i++)
    {
        UIButton * button = [buttonArray objectAtIndex:i];
        [button setTitle:nil forState:UIControlStateNormal];
        button.titleLabel.text = nil;
        [button setEnabled:NO];
    }
    [dates removeAllObjects];
    [dates release];
    dates = nil;
}
- (NSMutableArray *) getRemainingDaysInMonth:(int ) month 
                               lastNumOfDays:(NSInteger)noDays 
                                 isPrevMonth:(BOOL) prevMonth
{
    if(month == 0)
        month = 12;
    
    NSMutableArray *days = [[NSMutableArray alloc] init];
    NSString * numberOfDays = [monthDaysInYearDict objectAtIndex:month];
	int numDays = [numberOfDays intValue];
	if ([self IsLeapYear:selYear])
	{
		if (month == 2)
		{
			numDays++;
		}
	}
    if(prevMonth)
    {
        for(int i = numDays - noDays + 1;i<=numDays;i++)
            [days addObject:[NSString stringWithFormat:@"%d",i]];
    }
    else
    {
        int forDays = 7 - ((numDays+noDays)%7);
        if(forDays == 7)
            forDays = 0;
        if(forDays == 6)
            forDays = -1;
        for(int i = 1;i<=forDays +1 ;i++)
            [days addObject:[NSString stringWithFormat:@"%d",i]];        
    }
    return [days autorelease];
}

- (IBAction) DateClicked:(id)sender
{
	// Perform date clicked operation
	UIButton * dateButton = (UIButton *) sender;
    
    //Siva Manne 
    NSDateComponents * newDay = [[NSDateComponents alloc] init];
	[newDay setDay:1];
	[newDay setMonth:selMonth];
	[newDay setYear:selYear];
    
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate * NEWDay = [gregorian dateFromComponents:newDay];
	NSDateComponents * newDateComponents = [gregorian components:(NSWeekdayCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:NEWDay];
	NSInteger newWeekday = [newDateComponents weekday]==1?7:[newDateComponents weekday]-1;
    SMLog(@"Tag = %d WeekDay = %d",[dateButton tag],newWeekday);
    [newDay release];
    if (dateButton.titleLabel.text == nil)
    {
        [gregorian release];
        return;
    }
    
    selectedDate = dateButton;
    
    selDate = [selectedDate.titleLabel.text intValue];
    // SMLog(@"%d", selDate);
    
    NSDateComponents * dayOne = [[NSDateComponents alloc] init];
    NSUInteger selectedDt = [selectedDate.titleLabel.text intValue];
	[dayOne setDay:selectedDt];
	[dayOne setMonth:selMonth];
	[dayOne setYear:selYear];
	
	NSDate * FirstDay = [gregorian dateFromComponents:dayOne];
	NSDateComponents * dateComponents = [gregorian components:(NSWeekdayCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:FirstDay];
	NSInteger weekday = [dateComponents weekday]==1?7:[dateComponents weekday]-1;
    
    NSString * calendarLabel = @"";
	calendarLabel = [calendarLabel stringByAppendingString:[monthArray objectAtIndex:selMonth]];
	calendarLabel = [calendarLabel stringByAppendingString:@" "];
	calendarLabel = [calendarLabel stringByAppendingString:[NSString stringWithFormat:@"%d", selYear]];
    
    dayLabel.text = [NSString stringWithFormat:@"%@, %@", [dayArray objectAtIndex:weekday], calendarLabel];
    
    dateLabel.text = selectedDate.titleLabel.text;
    
    [delegate setDate:[dateLabel.text intValue]];
    
    [self highlightCurrentDate];
    
    [dayOne release];
    [gregorian release];
}

- (void) setDate:(NSUInteger) date
{
    selDate = date;
    dateLabel.text = [NSString stringWithFormat:@"%d", selDate];
    // [self RefreshCalendar];
    [self setDayLabel];
    [self highlightCurrentDate];
}

- (NSUInteger) getWeekNumber
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:selDate];
    [comps setMonth:selMonth];
    [comps setYear:selYear];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [gregorian dateFromComponents:comps];
    [comps release];
    NSDateComponents *weekComponents = [gregorian components:NSWeekCalendarUnit fromDate:date];
    int week = [weekComponents week];
    [gregorian release];

    return week;
}

- (NSMutableArray *) getWeeksArray
{
    // Run through the calendar and find out which days are present in which weeks
    if (weeksArray == nil)
        weeksArray = [[NSMutableArray alloc] initWithCapacity:0];
    else
        [weeksArray removeAllObjects];
    NSMutableArray * weekdays;
    NSUInteger dateIndex = 0;
    BOOL isAllNil = YES;
    currentWeek = 1;
    for (int i = 1; i <= 6; i++)
    {
        weekdays = [[NSMutableArray alloc] initWithCapacity:0];
        for (int j = 1; j <= 7; j++)
        {
            UIButton * button = [buttonArray objectAtIndex:dateIndex++];
            if (button.titleLabel.text != nil)
            {
                [weekdays addObject:button.titleLabel.text];
                isAllNil = NO;
            }
            else
            {
                [weekdays addObject:@""];
            }
            
            if (selDate == 0) selDate = currDate;
            if ((selDate == [button.titleLabel.text intValue]) && [button isEnabled])
            {
                currentWeek = i;
            }
        }
        if (!isAllNil)
            [weeksArray addObject:weekdays];

        isAllNil = YES;
    }
    return [weeksArray retain];
}

- (NSDictionary *) getWeekDetails
{
    // Get Month name
    // Get Year
    // Get current week - in index as in week 2 of 5 weeks for a month
    
    NSArray * keys = [NSArray arrayWithObjects:wMONTH, wMONTHNUMBER, wYEAR, wWEEKNUMBER, wWEEK, nil];
    NSArray * objects = [NSArray arrayWithObjects:
                         [monthArray objectAtIndex:selMonth],
                         [NSString stringWithFormat:@"%d", selMonth],
                         [NSString stringWithFormat:@"%d", selYear],
                         [NSString stringWithFormat:@"%d", [self getWeekNumber]],
                         [NSString stringWithFormat:@"%d", currentWeek], nil];
    
    NSDictionary * dict = [[[NSDictionary alloc] initWithObjects:objects forKeys:keys] autorelease];

    return dict;
}

- (NSUInteger) getToday
{
    NSDate * today = [NSDate date];
	NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setFirstWeekday:1];
	NSDateComponents * dateComponents = [gregorian components:(NSWeekdayCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:today];
    [gregorian release];

	NSInteger weekday = [dateComponents weekday];
    weekday = (weekday==1)?7:([dateComponents weekday]-1);
    
    return weekday;
}

//pavaman 3rd Jan 2011
- (NSUInteger) getSelDate
{
	return selDate;
}

- (void) setCalendarDate:(NSUInteger)date Month:(NSUInteger)month Year:(NSUInteger)year;
{
    currDate = selDate = date;
    selMonth = month;
    selYear = year;
    
    // [self SetCurrentCalendar];
    [self RefreshCalendar];
    [self setDayLabel];
}

- (NSArray *) getCalendarDate;
{
    return [NSArray arrayWithObjects:
            [NSNumber numberWithInt:selDate],
            [NSNumber numberWithInt:selMonth],
            [NSNumber numberWithInt:selYear],
            nil];
}

- (NSString *) getTodayString
{
    // YYYY-MM-DD
    
    NSString * year, * month, * date;
    year = [NSString stringWithFormat:@"%d", selYear];
    
    if (selMonth < 10)
        month = [NSString stringWithFormat:@"0%d", selMonth];
    else
        month = [NSString stringWithFormat:@"%d", selMonth];

    if (selDate < 10)
        date = [NSString stringWithFormat:@"0%d", selDate];
    else
        date = [NSString stringWithFormat:@"%d", selDate];
    
    NSString * todayStr = [NSString stringWithFormat:@"%@-%@-%@", year, month, date];
    
    if ([appDelegate.lastSelectedDate count] > 0)
        [appDelegate.lastSelectedDate removeAllObjects];
    [appDelegate.lastSelectedDate addObject:[NSString stringWithFormat:@"%d", selDate]];
    [appDelegate.lastSelectedDate addObject:month];
    [appDelegate.lastSelectedDate addObject:year];

    return todayStr;
}

//pavaman 16th Jan 2011 - caution: This accepts a local time zoned date (only) and returns week boundaries in GMT (date & time)
- (NSArray *) getWeekBoundaries:(NSString *)date
{
	
	NSMutableArray *bounds = [NSMutableArray arrayWithCapacity:2];
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    if ([date length] > 10)
        date = [date substringToIndex:10];
    NSDate *today = [dateFormatter dateFromString:date];
	
	
	
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	
	// Get the weekday component of the current date
	NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:today];
	NSUInteger weekday =  [weekdayComponents weekday]-1;
	if (weekday < 1)
		weekday = 7; //Sunday is the last day in our scheme
	
	
	/*
	 Create a date components to represent the number of days to subtract from the current date.
	 The weekday value for Sunday in the Gregorian calendar is 1, so subtract 1 from the number of days to subtract from the date in question.  (If today's Sunday, subtract 0 days.)
	 */
	NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
	[componentsToSubtract setDay: 0 - (weekday - 1)];
	
	NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:today options:0];
	
	[componentsToSubtract setDay:8-weekday];
	NSDate *endOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:today options:0];
	
	NSDateComponents *minus_onesec = [[NSDateComponents alloc] init];
	[minus_onesec setSecond:-1];
	endOfWeek = [gregorian dateByAddingComponents:minus_onesec toDate:endOfWeek options:0];

	 
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]]; 
	[bounds insertObject:[dateFormatter stringFromDate:beginningOfWeek] atIndex:0];
	[bounds insertObject:[dateFormatter stringFromDate:endOfWeek] atIndex:1];
	
	
	[componentsToSubtract release];
	[minus_onesec release];
	[dateFormatter release];
	
	return bounds;											
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [calSunday release];
    calSunday = nil;
    [calSunday release];
    calSunday = nil;
    [calSaturday release];
    calSaturday = nil;
    [calFriday release];
    calFriday = nil;
    [calThursday release];
    calThursday = nil;
    [calWednesday release];
    calWednesday = nil;
    [calTuesday release];
    calTuesday = nil;
    [calMonday release];
    calMonday = nil;
    
    [date11 release];
    date11 = nil;
	[date13 release];
    date12 = nil;
	[date13 release];
    date13 = nil;
	[date14 release];
    date14 = nil;
	[date15 release];
    date15 = nil;
	[date16 release];
    date16 = nil;
	[date17 release];
    date17 = nil;
	// Row 2
	[date21 release];
    date21 = nil;
	[date22 release];
    date22 = nil;
	[date23 release];
    date23 = nil;
	[date24 release];
    date24 = nil;
	[date25 release];
    date25 = nil;
	[date26 release];
    date26 = nil;
	[date27 release];
    date27 = nil;
	// Row 3
	[date31 release];
    date31 = nil;
	[date32 release];
    date32 = nil;
	[date33 release];
    date33 = nil;
	[date34 release];
    date34 = nil;
	[date35 release];
    date35 = nil;
	[date36 release];
    date36 = nil;
	[date37 release];
    date37 = nil;
	// Row 4
	[date41 release];
    date41 = nil;
	[date42 release];
    date42 = nil;
	[date43 release];
    date43 = nil;
	[date44 release];
    date44 = nil;
	[date45 release];
    date45 = nil;
	[date46 release];
    date46 = nil;
	[date47 release];
    date47 = nil;
	// Row 5
	[date51 release];
    date51 = nil;
	[date52 release];
    date52 = nil;
	[date53 release];
    date53 = nil;
	[date54 release];
    date54 = nil;
	[date55 release];
    date55 = nil;
	[date56 release];
    date56 = nil;
	[date57 release];
    date57 = nil;
	// Row 6
	[date61 release];
    date61 = nil;
	[date62 release];
    date62 = nil;
	[date63 release];
    date63 = nil;
	[date64 release];
    date64 = nil;
	[date65 release];
    date65 = nil;
	[date66 release];
    date66 = nil;
	[date67 release];
    date67 = nil;
    
    [label release];
    label = nil;
    
    [dateLabel release];
    dateLabel = nil;
    [dayLabel release];
    dayLabel = nil;
    [selectedDate release];
    selectedDate = nil;
    
    [super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc
{
	[dayArray release];
	[monthArray release];
    [calMonday release];
    [calTuesday release];
    [calWednesday release];
    [calThursday release];
    [calFriday release];
    [calSaturday release];
    [calSunday release];
    [calSunday release];
    [super dealloc];
}

- (void) enableUI
{
    NSArray * array = [self.view subviews];
    for (UIButton * button in array)
    {
        if ([button isKindOfClass:[UIButton class]])
            [button setUserInteractionEnabled:YES];
    }
}

- (void) disableUI
{
    NSArray * array = [self.view subviews];
    for (UIButton * button in array)
    {
        if ([button isKindOfClass:[UIButton class]])
            [button setUserInteractionEnabled:NO];
    }
}


@end
