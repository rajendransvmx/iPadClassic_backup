//
//  CalendarController.h
//  Calendar
//
//  Created by Samman Banerjee on 08/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Foundation/NSDate.h"
#import "Foundation/NSCalendar.h"

@class iServiceAppDelegate;

@protocol CalendarDelegate;

@interface CalendarController : UIViewController
{
    iServiceAppDelegate * appDelegate;
    id <CalendarDelegate> delegate;
	// IBOutlets for all date dates
	// Row 1
	IBOutlet UIButton * date11;
	IBOutlet UIButton * date12;
	IBOutlet UIButton * date13;
	IBOutlet UIButton * date14;
	IBOutlet UIButton * date15;
	IBOutlet UIButton * date16;
	IBOutlet UIButton * date17;
	// Row 2
	IBOutlet UIButton * date21;
	IBOutlet UIButton * date22;
	IBOutlet UIButton * date23;
	IBOutlet UIButton * date24;
	IBOutlet UIButton * date25;
	IBOutlet UIButton * date26;
	IBOutlet UIButton * date27;
	// Row 3
	IBOutlet UIButton * date31;
	IBOutlet UIButton * date32;
	IBOutlet UIButton * date33;
	IBOutlet UIButton * date34;
	IBOutlet UIButton * date35;
	IBOutlet UIButton * date36;
	IBOutlet UIButton * date37;
	// Row 4
	IBOutlet UIButton * date41;
	IBOutlet UIButton * date42;
	IBOutlet UIButton * date43;
	IBOutlet UIButton * date44;
	IBOutlet UIButton * date45;
	IBOutlet UIButton * date46;
	IBOutlet UIButton * date47;
	// Row 5
	IBOutlet UIButton * date51;
	IBOutlet UIButton * date52;
	IBOutlet UIButton * date53;
	IBOutlet UIButton * date54;
	IBOutlet UIButton * date55;
	IBOutlet UIButton * date56;
	IBOutlet UIButton * date57;
	// Row 6
	IBOutlet UIButton * date61;
	IBOutlet UIButton * date62;
	IBOutlet UIButton * date63;
	IBOutlet UIButton * date64;
	IBOutlet UIButton * date65;
	IBOutlet UIButton * date66;
	IBOutlet UIButton * date67;
	
	// Array of UIButtons
	NSMutableArray * buttonArray;
	
	// IBOutlet for Label
	IBOutlet UILabel * label;
	
	// Date and Month Dictionaries
	NSArray * dayArray;
	NSArray * monthArray;
	NSArray * monthDaysInYearDict;
	
	NSMutableArray * dates;
	
	// Selected Date, Month, and Year
    signed int selDate;
	signed int selMonth;
	NSUInteger selYear;
    
    // Current Date
    NSUInteger currDate;

    IBOutlet UILabel * dateLabel;
    IBOutlet UILabel * dayLabel;
    
    IBOutlet UIButton * selectedDate;
    
    NSMutableArray * weeksArray;
    NSUInteger currentWeek;
    
    // If last date is 31 for current month, and we move on to the next month
    // with 30 as the last date, the number to be highlighted is lost. Need below
    // BOOL to save the following situation
    // If last date is selected, then flag will be set. Now if we move to the next month
    // it will first check the BOOL flag, and then set the next month's last date accordingly
    BOOL isSelectedDateEndOfMonth;
    
    // Reload data on memory warning
    BOOL didReloadCalendar;
    
    //Radha 22nd April 2011
    //Localization of days in calender view
    
    IBOutlet UILabel * calMonday, * calTuesday, * calWednesday, 
        * calThursday, * calFriday, * calSaturday, * calSunday;
   }

// Properties

@property (nonatomic, assign) id <CalendarDelegate> delegate;

// Row 1
@property(nonatomic, retain) IBOutlet UIButton * date11;
@property(nonatomic, retain) IBOutlet UIButton * date12;
@property(nonatomic, retain) IBOutlet UIButton * date13;
@property(nonatomic, retain) IBOutlet UIButton * date14;
@property(nonatomic, retain) IBOutlet UIButton * date15;
@property(nonatomic, retain) IBOutlet UIButton * date16;
@property(nonatomic, retain) IBOutlet UIButton * date17;
// Row 2
@property(nonatomic, retain) IBOutlet UIButton * date21;
@property(nonatomic, retain) IBOutlet UIButton * date22;
@property(nonatomic, retain) IBOutlet UIButton * date23;
@property(nonatomic, retain) IBOutlet UIButton * date24;
@property(nonatomic, retain) IBOutlet UIButton * date25;
@property(nonatomic, retain) IBOutlet UIButton * date26;
@property(nonatomic, retain) IBOutlet UIButton * date27;
// Row 3
@property(nonatomic, retain) IBOutlet UIButton * date31;
@property(nonatomic, retain) IBOutlet UIButton * date32;
@property(nonatomic, retain) IBOutlet UIButton * date33;
@property(nonatomic, retain) IBOutlet UIButton * date34;
@property(nonatomic, retain) IBOutlet UIButton * date35;
@property(nonatomic, retain) IBOutlet UIButton * date36;
@property(nonatomic, retain) IBOutlet UIButton * date37;
// Row 4
@property(nonatomic, retain) IBOutlet UIButton * date41;
@property(nonatomic, retain) IBOutlet UIButton * date42;
@property(nonatomic, retain) IBOutlet UIButton * date43;
@property(nonatomic, retain) IBOutlet UIButton * date44;
@property(nonatomic, retain) IBOutlet UIButton * date45;
@property(nonatomic, retain) IBOutlet UIButton * date46;
@property(nonatomic, retain) IBOutlet UIButton * date47;
// Row 5
@property(nonatomic, retain) IBOutlet UIButton * date51;
@property(nonatomic, retain) IBOutlet UIButton * date52;
@property(nonatomic, retain) IBOutlet UIButton * date53;
@property(nonatomic, retain) IBOutlet UIButton * date54;
@property(nonatomic, retain) IBOutlet UIButton * date55;
@property(nonatomic, retain) IBOutlet UIButton * date56;
@property(nonatomic, retain) IBOutlet UIButton * date57;
// Row 6
@property(nonatomic, retain) IBOutlet UIButton * date61;
@property(nonatomic, retain) IBOutlet UIButton * date62;
@property(nonatomic, retain) IBOutlet UIButton * date63;
@property(nonatomic, retain) IBOutlet UIButton * date64;
@property(nonatomic, retain) IBOutlet UIButton * date65;
@property(nonatomic, retain) IBOutlet UIButton * date66;
@property(nonatomic, retain) IBOutlet UIButton * date67;

@property(nonatomic, retain) IBOutlet UILabel * label;

@property(nonatomic, retain) NSMutableArray * weeksArray;

@property BOOL didReloadCalendar;

// Methods
- (void) initDayMonth;
- (void) SetCurrentCalendar;
- (void) RefreshCalendar;
- (void) UpdateDates;
- (BOOL) IsLeapYear:(int)year;
- (void) PopulateDateFromDay:(NSInteger) weekday totalDays:(NSInteger) numDays;
- (void) ConnectButtonArray;

- (IBAction) DateClicked:(id)sender;
- (void) highlightCurrentDate;
- (void) resetAllCellBackgroundColor;

- (IBAction) NextMonth;
- (void) NextMonthStart;
- (IBAction) PrevMonth;
- (void) PrevMonthEnd;
- (void) setDayLabel;

- (void) GoToToday;

- (void) setDate:(NSUInteger) date;

- (NSUInteger) getWeekNumber;
- (NSMutableArray *) getWeeksArray;
- (NSDictionary *) getWeekDetails;
- (NSUInteger) getToday;

- (NSString *) getTodayString;

//pavaman 3rd Jan 2011
- (NSUInteger) getSelDate;

- (void) setCalendarDate:(NSUInteger)date Month:(NSUInteger)month Year:(NSUInteger)year;
- (NSArray *) getCalendarDate;
- (NSMutableArray *) getRemainingDaysInMonth:(int ) month 
                               lastNumOfDays:(NSInteger)noDays 
                                 isPrevMonth:(BOOL) prevMonth;
//pavaman 11th Jan 2011
- (NSMutableArray *) getWeekBoundaries:(NSString *)date;

- (void) displayNoInternetAvailable;

- (void) enableUI;
- (void) disableUI;

- (void)setDoNotLoadWeekviewFlag:(BOOL)flag; /*Shravya-Calendar view 7408 */

@end

#define wWEEKDAY            @"WEEKDAY"
#define wWEEK               @"WEEK"
#define wWEEKNUMBER         @"WEEKNUMBER"
#define wMONTH              @"MONTH"
#define wMONTHNUMBER        @"MONTHNUMBER"
#define wYEAR               @"YEAR"

@protocol CalendarDelegate <NSObject>

@optional
- (void) setTotalDivisions:(NSUInteger) total;
- (void) setDate:(NSUInteger)date;

@end
