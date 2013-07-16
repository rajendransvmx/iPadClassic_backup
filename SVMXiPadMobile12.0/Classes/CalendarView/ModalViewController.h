//
//  ModalViewController.h
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 11/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iServiceAppDelegate.h"
#import "CalendarController.h"
#import "AddTaskController.h"
#import "TaskViewController.h"
#import "CellRepository.h"
#import "EventViewController.h"
#import "WeeklyViewController.h"
#import "SFMPageController.h"

@class LoginController;

@interface ModalViewController : UIViewController
<CalendarDelegate, 
UIPopoverControllerDelegate,
WeeklyViewControllerDelegate,
EventViewControllerDelegate,
iOSInterfaceObjectDelegate,
SFMPageDelegate,
DetailViewControllerDelegate, RefreshModalSyncStatusButton>
{
    iServiceAppDelegate * appDelegate;
    IBOutlet UIView * landscape;
    IBOutlet UIView * portrait; 

    IBOutlet UIView * leftPane;
    IBOutlet UIView * rightPane, * rightPaneParent;
    IBOutlet UIView * bottomPane;
    
    IBOutlet UIView * portraitDatePane;
    IBOutlet UIView * portraitEventPane;
    IBOutlet UIView * portraitBottomPane;
    
    IBOutlet UIButton * incrDateBtn, * decrDateBtn;
    
    CalendarController * calendar;
     
    IBOutlet UISlider * slider, * portraitSlider;
    
    TaskViewController * taskView;
    
    UIPopoverController * popOverController;
    AddTaskController * addTaskView;
    
    NSMutableArray * tasks;
    
    IBOutlet UITableView * _tableView;
   
    IBOutlet UISegmentedControl* portraitSegmentButton;
    BOOL isDateSetAction;
    BOOL isShowingDailyView;
    IBOutlet UIImageView * sliderDateView;
    
    BOOL isPortrait;
    WeeklyViewController * weekView;
    BOOL hideWeekView;
    
    BOOL didTogglePortraitView, didToggleLandscapeView;
    
    // Right Pane Event Objects
    EventViewController * eventView;
    EventViewController * aEventView;
    NSMutableArray * eventViewArray;
    CGRect initialPosition;
    CGPoint initialPoint;
    BOOL didMoveEvent;
    BOOL isViewDirty;
    
    iOSInterfaceObject * iOSObject;
    
    IBOutlet UIActivityIndicatorView * activity;
    
    NSThread * localThread;
    
    NSString * workOrderId;
    
    NSMutableString * workOrderIdArrayString;
    
    NSMutableArray * workOrderIdArray;
    NSUInteger workOrderIdArrayCounter;
    
    NSMutableArray * eventsArray;
    NSMutableArray * workOrderArray;
    
    NSString * prevDateString;
    
    NSArray * eventDetails;
    
    NSString * topLevelId, * accountId, * caseId;
    NSString * productId;
    
    NSString * currentDate, * previousDate;
    
    IBOutlet UIButton * showMapButton;
    
    BOOL isLoaded;
    BOOL didSetupWeekView;
    
    NSUInteger dateToRestore, monthToRestore, yearToRestore;
    
    NSArray * restoreDate;
    BOOL didRefresh;
    IBOutlet UIButton * refreshButton;
	
	//pavaman 12th Jan 2011
    IBOutlet UIButton *HomeButton;
	BOOL didFirstTimeLoad;
    
    //Radha 20th April 2011
    //For Localization
    IBOutlet UILabel * ltaskLabel;
    //Radha 21st April 2011
    IBOutlet UILabel * rscheduleLabel;
    IBOutlet UISegmentedControl * segmentButton;
    IBOutlet UIButton * todayBtn;
    
    //Radha 11th May 2011
    LoginController * login;
    
    CGRect homeButtonRect;
    CGRect refreshButtontRect;
    CGRect AddEventButtonRect;
    CGRect syncindicatorRect;
    
    NSString * updatestartDateTime, * updateendDateTime;
    //sahana 9th Sept 
   
    BOOL Continue_rescheduling;
    BOOL Event_edit_flag;
    BOOL didDismissalertview;
    BOOL isActive;

    BOOL tasksDidLoad, calendarDidLoad;
    
    BOOL allowTouches;
    
    BOOL didRunOperation;
    CGRect oldEventRect;
    
    BOOL offline;
    IBOutlet UIButton *Add_event_Button;
    
    NSString *updateStartTime, *updateEndTime;
    
    //Shrinivas
    UIButton * statusButton;
    UIImageView* animatedImageView;
    
    /*Shravya-Calendar view 7408 */
    BOOL   isDayButtonClicked;
    BOOL   rescheduledAnEvent;
    BOOL   shouldRedrawWeekView;
}

@property (nonatomic) BOOL Event_edit_flag;
@property (nonatomic,retain) NSString *updateStartTime, *updateEndTime;
@property (nonatomic) BOOL offline;
@property (nonatomic) BOOL didDismissalertview;
@property (nonatomic) BOOL Continue_rescheduling;
@property (nonatomic, retain)  IBOutlet UIButton *Add_event_Button;
@property (nonatomic ,retain) IBOutlet UIButton *HomeButton;
@property (nonatomic, retain) WeeklyViewController * weekView;
@property (nonatomic, retain) NSArray * eventDetails;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * activity;
@property (nonatomic,assign) BOOL   isDayButtonClicked;  /*Shravya-Calendar view 7408 */
@property (nonatomic,assign) BOOL   rescheduledAnEvent;
@property (nonatomic,assign) BOOL   shouldRedrawWeekView;

//Radha 5th April 2011
@property (nonatomic, retain) EventViewController * eventView;
//@property (nonatomic, retain) LoginController * login;


//sahana
-(void) SFMeditEvent:(NSString *)record_id  what_id:(NSString *)what_id;

//Radha 3rd April 2011
//set up the events
- (void) setEventsView:(NSString *)date;
- (NSString *)dateStringConversion:(NSDate*)date;
//-(void) getWeekDays:(NSDate *)date;
//-(NSArray *) getWeeksdatesarray;

// Calendar Methods
- (IBAction) SetToday;
- (IBAction) SetSlider;

// Right Pane Methods
- (void) setupEventsOnView:(UIView *)theView;

// Left Pane Methods
- (IBAction) AddTask:(id)sender;
- (void) setupTasksForDate:(NSString *)date;

- (void) dismissPopOver:(UIPopoverController *)popOver;

// - (UIColor *) getColorFromIndex:(NSUInteger)index;
// - (CGFloat) getHeightForRow:(NSUInteger) row;
// - (NSString *) getCellIdForIndex:(NSUInteger) index;

// - (CellRepository *) createNewCustomCellWithIndex:(NSUInteger)index;

- (IBAction) ShowMap;
- (IBAction) ToggleLandscapeView;

- (IBAction) goToHomePage:(id)sender;
-(IBAction)AddEvent:(id)sender;

- (void) setDate:(NSUInteger)date;
//- (void) setEventsFromWeekCache:(NSString *)_date;
- (BOOL) isDate:(NSString *)date inRange:(NSArray *)dateRange;

- (IBAction) IncrDate;
- (IBAction) DecrDate;

- (IBAction) Help;
// Event Methods
- (void) RefreshLandscapeEventPane;

- (NSUInteger) getPriorityColorByPriority:(NSString *)priority;

// iOS Related Methods
- (void) PopulateEventsOnView:(UIView *)theView ByDate:(NSString *)date;
- (void) stopActivity;

- (void) refreshCacheData;
- (IBAction) refreshViews;
- (void) refresh;

// Radha - 13 May, 2011
- (void) reloadCalendar;

- (void) didGetAllEvents;

- (IBAction) launchSmartVan;
- (void) didQueryTasksForDate:(ZKQueryResult *)result error:(NSError *)error context:(id)context;

// SFM Page display
- (void) showSFMWithDayEvent:(NSDictionary *)event;

// Display user name
- (IBAction) displayUser:(id)sender;

- (void) didAllDataLoad;

- (void) removeCrashProtector;

- (void) enableUI;
- (void) disableUI;


//Shrinivas
- (UIImage *) getStatusImage;

#define CALENDARTAG        1234
#define degreesToRadian(x) (M_PI * x / 180.0)

@end
