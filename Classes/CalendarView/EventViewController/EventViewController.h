//
//  EventViewController.h
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 22/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "zkSObject.h"

@protocol EventViewControllerDelegate;

NSMutableArray * eventPositionArray;

@interface EventViewController : UIViewController
{
    id <EventViewControllerDelegate> delegate;
    
    CGFloat time, duration;
    IBOutlet UIImageView * imageView;
    IBOutlet UILabel * label;
    
    CGRect selfFrame;
    
    ZKSObject * eventDetail;
    NSDictionary * workOrderDetail;
    NSString * eventId;
    
    IBOutlet UILabel * companyName;
    
    //Radha 5th April 2011
    
    IBOutlet UILabel *subject;
    
    //Abhinash and shrini and radha 
    IBOutlet UILabel *subject1;
    
    //Radha 10th May 2011
    NSString * processName;
    NSString * processId, * recordId, * objectName, * activityDate, * accountId, * startDate, * endDate;
    
    BOOL conflictFlag;
    
    //sahana 12th sept 
    BOOL didDismissalertview ;
    BOOL Continue_rescheduling;
    
    
    
}

@property (nonatomic, assign) BOOL conflictFlag;

@property (nonatomic) BOOL didDismissalertview ;
@property (nonatomic) BOOL Continue_rescheduling;
@property (nonatomic, retain) id <EventViewControllerDelegate> delegate;

@property CGFloat time;
@property (nonatomic, retain) IBOutlet UIImageView * imageView;
@property (nonatomic, retain) IBOutlet UILabel * label;

@property CGRect selfFrame;

@property (nonatomic, retain) ZKSObject * eventDetail;
@property (nonatomic, retain) NSString * eventId;
@property (nonatomic, retain) NSDictionary * workOrderDetail;

@property (nonatomic, retain) IBOutlet UILabel * companyName;
@property (nonatomic, retain) IBOutlet UILabel * subject;

@property (nonatomic, retain) NSString * processName;
@property (nonatomic, retain) NSString * processId, * recordId, * objectName, * activityDate, * accountId, * startDate, * endDate;

//Radha 4th April 2011
- (void) setLabelWorkorder:(NSString *)name Subject:(NSString *)subject;

// Class Methods
+ (void) addEventRect:(CGRect)rect;
+ (void) modifyEvent:(NSUInteger)tag WithRect:(CGRect)rect;
+ (NSMutableArray *) getEventPositions;
// Instance Methods
- (void) setEvent:(NSString *)event Time:(NSString *)_time Duration:(CGFloat)_duration Color:(UIColor *)color;
- (CGFloat) getTimeMultipleFromStringTime:(NSString *)_time;
- (CGFloat) setYBasedOnTime:(NSUInteger)_time;
- (void) setPosition;

- (void) restorePositionToRect:(CGRect)rect;

- (NSDictionary *) getEventStartEndTime;

- (NSUInteger) getYFromIndex:(int)position;
- (void) moveTo:(CGRect)location;
- (CGRect) bringEventDownFromLocation:(CGRect)location;
- (CGRect) bringEventUpFromLocation:(CGRect)location;
- (BOOL) canMoveToLocation;
- (void) setPositionAtY:(CGFloat)y;
- (UIImage *) getImageForColorIndex:(NSUInteger)colorIndex;

- (NSArray *) getIntersectedEventsWithLocation:(CGRect)location;
- (CGRect) getIntersectedEventWithLocation:(CGPoint)point;
- (BOOL) isEventInRect:(CGRect)_rect;
- (CGRect) getRectForLocation:(CGPoint)point;

- (CGFloat) getPortraitHeight;
- (CGFloat) getPortraitWidth;

- (CGFloat) getLandscapeHeight;
- (CGFloat) getLandscapeWidth;

- (void) setEventColor:(UIColor *)Color;

// Constants
#define kLOCATIONZERO        0
#define kLOCATIONEND         582
#define kTIMEMULTIPLE        26

#define kTIMEFLOOR           1300

// CGRect Constants
#define kTOTALRECTS          48

#define kGAP                 1

#define EVENTX               63
#define EVENTWIDTH           393
#define EVENTHEIGHT          26
//Portrait Dimensions
#define EVENTPORTRAITWIDTH   393
#define EVENTPORTRAITHEIGHT  26


@end

@protocol EventViewControllerDelegate

@optional
- (void) movedEvent:(EventViewController *)event;
- (void) Continuetherescheduling:(BOOL)continue_rescheduling;

@end

#define STARTTIME             @"StartTime"
#define ENDTIME               @"EndTime"

// Color Constants
#define cBLUE                 0
#define cBROWN                1
#define cGREEN                2
#define cORANGE               3
#define cPINK                 4
#define cPURPLE               5
#define cRED                  6
#define cYELLOW               7
