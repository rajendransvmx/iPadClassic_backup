//
//  SMXConstants.h
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

#import <UIKit/UIKit.h>
#import "TagManager.h"
#import "TagConstant.h"

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

//#define dictWeekNumberName @{@1:@"Domingo", @2:@"Segunda-feira", @3:@"Terça-feira", @4:@"Quarta-feira", @5:@"Quinta-feira", @6:@"Sexta-feira", @7:@"Sábado"}
//#define arrayWeekAbrev @[@"dom", @"seg", @"ter", @"qua", @"qui", @"sex", @"sáb"]
//#define arrayMonthName @[@"Janeiro", @"Fevereiro", @"Março", @"Abril", @"Maio", @"Junho", @"Julho", @"Agosto", @"Setembro", @"Outubro", @"Novembro", @"Dezembro"]

//#define dictWeekNumberName @{@1:@"Sunday", @2:@"Monday", @3:@"Tuesday", @4:@"Wednesday", @5:@"Thursday", @6:@"Friday", @7:@"Saturday"}

#define dictWeekNumberName @{@1:@"Sun", @2:@"Mon", @3:@"Tue", @4:@"Wed", @5:@"Thur", @6:@"Fri", @7:@"Sat"}

#define arrayWeekAbrev @[[[TagManager sharedInstance]tagByName:kTag_s], [[TagManager sharedInstance]tagByName:kTag_m], [[TagManager sharedInstance]tagByName:kTag_t], [[TagManager sharedInstance]tagByName:kTag_w], [[TagManager sharedInstance]tagByName:kTag_t], [[TagManager sharedInstance]tagByName:kTag_f], [[TagManager sharedInstance]tagByName:kTag_s]]
#define arrayWeekAbrevWithThreeChars @[@"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat"]
#define arrayMonthName @[[[TagManager sharedInstance]tagByName:kTagJanuary], [[TagManager sharedInstance]tagByName:kTagFebruary], [[TagManager sharedInstance]tagByName:kTagMarch], [[TagManager sharedInstance]tagByName:kTagApril], [[TagManager sharedInstance]tagByName:kTagMay], [[TagManager sharedInstance]tagByName:kTagJune], [[TagManager sharedInstance]tagByName:kTagJuly], [[TagManager sharedInstance]tagByName:kTagAugust], [[TagManager sharedInstance]tagByName:kTagSeptember], [[TagManager sharedInstance]tagByName:kTagOctober], [[TagManager sharedInstance]tagByName:kTagNovember], [[TagManager sharedInstance]tagByName:kTagDecember]]

#define arrayMonthNameAbrev @[[[TagManager sharedInstance]tagByName:Tag_CAL_Jan], [[TagManager sharedInstance]tagByName:Tag_CAL_Feb], [[TagManager sharedInstance]tagByName:Tag_CAL_Mar], [[TagManager sharedInstance]tagByName:Tag_CAL_Apr], [[TagManager sharedInstance]tagByName:Tag_CAL_May], [[TagManager sharedInstance]tagByName:Tag_CAL_Jun], [[TagManager sharedInstance]tagByName:Tag_CAL_Jul], [[TagManager sharedInstance]tagByName:Tag_CAL_Aug], [[TagManager sharedInstance]tagByName:Tag_CAL_Sep], [[TagManager sharedInstance]tagByName:Tag_CAL_Oct], [[TagManager sharedInstance]tagByName:Tag_CAL_Nov], [[TagManager sharedInstance]tagByName:Tag_CAL_Dec]]


#define BUTTON_HEIGHT 44.

#define STORYBOARD_ID_ROOTVC @"root"

#define SPACE_COLLECTIONVIEW_CELL_YEAR 30.
#define SPACE_COLLECTIONVIEW_CELL 1.
#define HEADER_HEIGHT_MONTH 40.
#define HEADER_HEIGHT_SCROLL 70
#define HEADER_HEIGHT_SCROLL_WEEK 40.

//Notification for date and month to SMXCalendarViewController
#define DATE_MONTH_TEXT_NOTIFICATION @"dateAndMonthText"
#define CALENDER_VIEW_REMOVE @"removeCalenderView"
#define CALENDER_DAY_VIEW_REMOVE @"removeCalenderDayView"
#define DAY_VIEW_WIDTH 300.//anish
#define REUSE_IDENTIFIER_MONTH_CELL @"monthCell"
#define REUSE_IDENTIFIER_MONTH_HEADER @"headerCollection"
#define SHOW_DAY_CALENDAR @"showDayCalendar"

#define REUSE_IDENTIFIER_DAY_CELL @"dayCell"

#define MINUTES_INTERVAL 2.
#define HEIGHT_CELL_HOUR 70. //Calender changes
 #define WEEK_HEIGHT_CELL_HOUR 70.
#define HEIGHT_CELL_MIN HEIGHT_CELL_HOUR/MINUTES_INTERVAL
#define WEEK_HEIGHT_CELL_MIN WEEK_HEIGHT_CELL_HOUR/MINUTES_INTERVAL
#define MINUTES_PER_LABEL 60./MINUTES_INTERVAL
#define EVENT_SPACE_FROM_CELL_RIGHT 2
#define CELL_HEIGHT_MARGINE_BOTTOM 44
#define EVENT_CLICKED_WEEK @"br.com.SMXWeekCell.SMXBlueBUTTON.EventSelected"
#define RELOAD_CALENDAR_WEEK @"reloadCalendar"
#define CHECK_FOR_TIMEZONE_CHANGE @"timeZone_change"

#define Customer_ID @"idCustomer"
#define Customer_NOME @"nmCustomer"

#define AR_WIDTH_HEIGHT UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
#define AR_TOP_BOTTOM UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
#define AR_TOP_BOTTOM_MONTH  UIViewAutoresizingFlexibleBottomMargin
#define AR_LEFT_RIGHT UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
#define AR_LEFT_BOTTOM UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin

#define AR_LEFT_BOTTOM_TOP_RIGHT UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin 


//16-09-2014 Prasad
#define EVENT_CLICKED @"br.com.SMXBlueButton.EventSelected"  // when a event is clicked in Calender > Day

#define ORIENTATION_CHANGED @"br.com.SMXDayCalenderView.OrientationChanged"  // When the orientation is changed, the Event button in the left panel should be still highlighted.

#define EVENT_DISPLAY_RESET @"com.SMXCalendarViewController.EventDisplayReset"
#define CURRENT_TIME_LINE_MOVE @"br.com.SMXDayCell.ChangeTime"  // change the time-line displayed in Calender > Day to display the line for the current time.
#define CURRENT_TIME_LINE_MOVE_WEEK @"br.com.SMXDayCell.ChangeTime.week"  // change the time-line displayed in Calender > Day to display the line for the current time.
#define EVENT_RERENDERED_IN_DETAIL_VIEW @"br.com.SMXDayCell.EventsReRendered.DetailView"

float gNavBarHeight;  // Shifted from .pch file on 10-Oct-2014. PRASAD

@interface SMXConstants

@end
