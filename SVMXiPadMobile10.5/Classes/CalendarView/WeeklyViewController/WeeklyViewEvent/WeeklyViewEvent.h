//
//  WeeklyViewEvent.h
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 22/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "zkSObject.h"

@protocol WeeklyViewEventDelegate;

NSMutableArray * weeklyEventPositionArray;

@interface WeeklyViewEvent : UIViewController
{
    id <WeeklyViewEventDelegate> delegate;
    
    NSUInteger day, time;//, duration;
	CGFloat duration;
	
    IBOutlet UIImageView * imageView;
    IBOutlet UILabel * label;
    IBOutlet UITextView * text;
    
    CGRect selfFrame;
    
    CGRect dayFrame;
    
    ZKSObject * eventDetail;
    NSDictionary * workOrderDetail;
    NSString * eventId;
    
    IBOutlet UILabel * workOrderNumber;
    IBOutlet UILabel * workOrderType;
    IBOutlet UILabel * companyName;
    
    //Radha 10th April 2011
    //To set the workorder details on the calendar weekly view
   
    IBOutlet UILabel * subject;
    IBOutlet UILabel *workOrderName;
    NSString * processName;
    NSString * processId, * recordId, * objectName, * createdDate, * accountId, * startDate, * endDate,  * activityDate, * local_id ;
    //sahana 12th Sept
    BOOL didDismissAlertView , continue_reshceduling;
    BOOL edit_event;
    
    BOOL conflictFlag;
    NSMutableDictionary *mAccessibilityDict;
}

/*
 
 // 74, 95, 930, 534

 19 divisions vertically -> 534 / 19 = 28, 18*2 + 19*x = 534, x = 26
 7 divisions horizontally -> 930 / 7 = 132, 6*2 + 7*x = 930, x = 131
 
 Minimum size frame = 132, 32
 
*/
@property (nonatomic) BOOL edit_event;
@property (nonatomic , retain) NSString * local_id;
@property (nonatomic, assign) BOOL conflictFlag;

@property (nonatomic) BOOL didDismissAlertView , continue_reshceduling;

@property (nonatomic, retain) NSString * processName;
@property (nonatomic, retain) NSString * processId, * recordId, * objectName, * createdDate, * accountId, * startDate, * endDate,  * activityDate;
@property (nonatomic, retain) id <WeeklyViewEventDelegate> delegate;

@property NSUInteger time;
@property (nonatomic, retain) IBOutlet UIImageView * imageView;
@property (nonatomic, retain) IBOutlet UILabel * label;

@property CGRect selfFrame;
@property CGRect dayFrame;

@property (nonatomic, retain) ZKSObject * eventDetail;
@property (nonatomic, retain) NSDictionary * workOrderDetail;
@property (nonatomic, retain) NSString * eventId; 

//Radha 10th May  2011
-(void) setLabelsweeklyview:(NSArray *)event;

// Class Methods
+ (void) addEventRect:(CGRect)rect;
+ (void) modifyEvent:(NSUInteger)tag WithRect:(CGRect)rect;
+ (NSMutableArray *) getEventPositions;
// Instance Methods
- (void) setEvent:(NSArray *)event Day:(NSUInteger)_day Time:(NSString *)_time Duration:(CGFloat)_duration Color:(UIColor *)color;
- (CGFloat) getTimeMultipleFromStringTime:(NSString *)_time;
- (CGFloat) setXBasedOnDay:(NSUInteger)_day;
- (CGFloat) setYBasedOnTime:(NSUInteger)_time;
- (void) setPosition;

- (void) restorePositionToRect:(CGRect)rect;

- (NSDictionary *) getEventStartEndTime;

- (NSUInteger) getYFromIndex:(int)position;
- (void) moveTo:(CGRect)location;
- (CGRect) bringEventDownFromLocation:(CGRect)location;
- (CGRect) bringEventUpFromLocation:(CGRect)location;
- (NSUInteger)getGapMultipleFromTime:(NSUInteger)_time;
- (BOOL) canMoveToLocation;
- (void) setPositionAtY:(CGFloat)y;
- (UIImage *) getImageForColorIndex:(NSUInteger)colorIndex;

- (CGRect) getRectForLocation:(CGPoint)point;
- (BOOL) isEventInRect:(CGRect)_rect;
- (NSArray *) getIntersectedEventsWithLocation:(CGRect)location;
- (CGRect) getIntersectedEventWithLocation:(CGPoint)point;

- (void) setColor:(UIColor *)color;
- (void)updateAccesibilityDictValue:(NSString*)inValue forKey:(NSString*)inKey;
// Constants
// 609 + 11 approx to allow a little movement

#define STARTTIME             @"StartTime"
#define ENDTIME               @"EndTime"
#define DAY                   @"Day"

#define kwLOCATIONXZERO       0
#define kwLOCATIONYZERO       0
#define kwLOCATIONEND         514
#define kwXGAP                42
#define kwYGAP                3
#define kwTIMEMULTIPLE        26
#define kwDAYMULTIPLE         124

#define kwXCORRECTION         4
#define kwYCORRECTION         3

#define kwTIMEFLOOR           1300

#define kwTOTALTIMEINTERVALS  48
#define kwTOTALDAYINTERVALS   7

#define wEVENTWIDTH           124
#define wEVENTHEIGHT          24

@end

@protocol WeeklyViewEventDelegate

@optional
- (void) movedEvent:(WeeklyViewEvent *)event;
- (void) rescheduleEvent:(BOOL)continueReschedule;
- (void) setTouchesDisabled;
- (void)EditEvent:(BOOL)event_edit_flag;
@end

// Color Constants
#define cBLUE                 0
#define cBROWN                1
#define cGREEN                2
#define cORANGE               3
#define cPINK                 4
#define cPURPLE               5
#define cRED                  6
#define cYELLOW               7
