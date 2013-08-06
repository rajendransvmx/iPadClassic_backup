//
//  WeeklyViewController.h
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 19/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iServiceAppDelegate.h"
#import "WeeklyViewEvent.h"
#import "CalendarController.h"
#import "iOSInterfaceObject.h"

// Portrait mode - 610, 854

@protocol WeeklyViewControllerDelegate

@optional
- (void) finishedLoading;
- (void) showJobWithEventDetail:(ZKSObject *)eventDetail WorkOrderDetail:(NSDictionary *)workOrderDetail;
- (void) showSFMForWeek:(NSDictionary *)event;
- (void) enableRefreshButton:(BOOL)flag;
-(void) SFMEditForWeekView:(NSDictionary *)dict;

@end

@interface WeeklyViewController : UIViewController
<WeeklyViewEventDelegate>
{
    iServiceAppDelegate * appDelegate;
    
    id <WeeklyViewControllerDelegate> delegate;
    IBOutlet UIView * landscape;
    IBOutlet UIView * portrait;
    
    IBOutlet UIView * weekViewPane, * weekViewPaneParent;
    IBOutlet UIView * weekViewModify;
    
    IBOutlet UIImageView * sundayHighlight, * mondayHighlight, * tuesdayHighlight, * wednesdayHighlight, * thursdayHighlight, * fridayHighlight, * saturdayHighlight;
    
    // WeekView Pane Event Objects
    WeeklyViewEvent * eventView;
    WeeklyViewEvent * aEventView;
    NSMutableArray * eventViewArray;
    CGRect initialPosition;
    CGPoint initialPoint;
    
    BOOL didMove, didTap;
    BOOL sliderDidMove;
    BOOL isViewDirty;
    
    NSMutableArray * dayRectArray;
    
    // Calendar Implementation
    CalendarController * calendar;
    IBOutlet UIImageView * sliderImageView;

    IBOutlet UIImageView * sliderImage;
    NSUInteger currentWeek;
    NSMutableArray * sliderBoundsArray;
    NSDictionary * weekDetails;
    NSMutableArray * weeksArray;
    
    signed int currentSliderPositionIndex;
    
    IBOutlet UILabel * monthYear;
    IBOutlet UILabel * monday; 
    //Radha  21st April 2011
    IBOutlet UILabel * tuesday; 
    IBOutlet UILabel * wednesday; 
    IBOutlet UILabel * thursday;  
    IBOutlet UILabel * friday; 
    IBOutlet UILabel * saturday; 
    IBOutlet UILabel * sunday;
    
    // Job View Controller
    JobViewController * jobView;
    
    NSThread * localThread;
    IBOutlet UIActivityIndicatorView * activity;
    
    // iOS Members
    iOSInterfaceObject * iOSObject;
    
    NSArray * eventDetails;
    NSMutableArray * eventsArray;
    
    NSString * topLevelId, * accountId, * caseId;
    NSString * productId;
    
    NSString * currentDate, * previousDate;
    // Performance Enhancement - maintain an array (2) of the current date range 
    // (start and end dates for the particular week)
    NSArray * currentWeekDateRange;
    NSDictionary * workOrderDictionary;
	
	//pavaman 16th Jan 2011
	BOOL firstTimeLoadFromCache;
	
	//pavaman 21st Jan 2011
	BOOL didLoadWeekData;
    
    // For Localization declaring the current week
    //Radha 21st April 2011
    NSString * startDate, * endDate;
    BOOL currenSliderPositionMoved;
    
    IBOutlet UIButton * curWeek;
    IBOutlet UILabel * day1Label, * day2Label, * day3Label, * day4Label,
        * day5Label, * day6Label, * day7Label;
    BOOL didMoveEvent;
    //sahana 12th Sept
   
    BOOL didDismissAlertView;
    BOOL ContinueRescheduling;
    
    NSString * updatestartDateTime, * updateendDateTime;
    
    BOOL calendarDidLoad, allowTouches;
    
    BOOL isInternetConnectionAvailable;
    
    BOOL didRunOperation;
    
    IBOutlet UIButton * prevWeek, * nextWeek;
    
    //Shrinivas
    NSString *updateStartTime, *updateEndTime;
    BOOL edit_event;

}

@property (nonatomic, retain)  NSString *updateStartTime, *updateEndTime;
@property (nonatomic) BOOL didDismissAlertView;
@property (nonatomic) BOOL ContinueRescheduling;
@property (nonatomic)  BOOL edit_event;

@property (nonatomic) BOOL didMoveEvent;
@property (nonatomic, assign) id <WeeklyViewControllerDelegate> delegate;
@property (nonatomic, retain) CalendarController * calendar;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * activity;

@property (nonatomic, retain) NSArray * eventDetails;
@property (nonatomic, retain) NSMutableArray * eventsArray;

@property BOOL isViewDirty;

@property (nonatomic, retain) NSArray * currentWeekDateRange;
@property (nonatomic, retain) NSDictionary * workOrderDictionary;

//pavaman 16th Jan 2011
@property (nonatomic, assign) BOOL firstTimeLoadFromCache;

//pavaman 21st Jan 2011
@property (nonatomic, assign) BOOL didLoadWeekData;

//Radha 10th April 2011
- (void) populateWeekView;
- (NSString *)dateToStringConversion:(NSDate*)date;

@property (nonatomic,retain)  WeeklyViewEvent * eventView;  ////007981


- (void) highlightToday;
- (void) setupWeeks;
- (IBAction) changeWeek;
- (IBAction) NextWeek;
- (IBAction) PrevWeek;
- (IBAction) goToCurrentWeek;
- (void) setSliderBounds:(NSUInteger)div;
- (CGRect) getSliderRectForLocation:(CGPoint)location;

- (void) setDays;
- (void) setDaysAtSliderLocationIndex:(NSUInteger)index;
- (NSString *) getFirstLastFromWeek:(NSMutableArray *)array;

- (void) setUpDayRect;
- (void) setupEvents;

- (void) RefreshLandscape;

- (void) setRotation:(UIInterfaceOrientation)_interfaceOrientation;

- (void) clearWeekView;

- (NSArray *) getWeekStartEndDatesAtOptionalIndex:(NSString *)optionalIndex;

- (NSUInteger) getPriorityColorByPriority:(NSString *)priority;

- (void) setSliderToFirst;
- (void) setSliderToLast;

- (IBAction) launchSmartVan;

- (void) didAllDataLoad;

- (void) removeCrashProtector;

- (void) enableUI;
- (void) disableUI;

@end
