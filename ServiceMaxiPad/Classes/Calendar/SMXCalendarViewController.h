/**
 *  @file   SMXCalendarViewController.m
 *  @class  SMXCalendarViewController
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
#import "CalendarMonthViewController.h"
#import "WizardViewController.h"
#import "SMXCurrentDayButton.h"
#import "FlowNode.h"
#import "SMXEvent.h"
#import "SMXBlueButton.h"

@protocol SMXCalendarViewControllerProtocol <NSObject>
@required
- (void)arrayUpdatedWithAllEvents:(NSMutableArray *)arrayUpdated;
@end

@interface SMXCalendarViewController : UIViewController<WizardDelegate,SMXCurrentDayDelegate,FlowDelegate>

@property (nonatomic, strong) id <SMXCalendarViewControllerProtocol> protocol;
@property (nonatomic, strong) NSMutableArray *arrayWithEvents;
@property (nonatomic, strong) CalendarMonthViewController *monthCalender;
@property (nonatomic, strong) NSArray *cEventListArray;
@property (nonatomic, strong) NSMutableDictionary *cWODetailsDict;
@property (nonatomic, strong) NSMutableDictionary *cCaseDetailsDict;

+ (instancetype) sharedInstance;

+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));


-(void)removeCalender;
-(void)eventSelectedShare:(SMXEvent *)eventData userInfor:(NSDictionary *)contactId;
- (void)removeAllEvents;
- (void) showDayCalender;
- (void)leftButtonTextChangeOnDateChange:(NSDate *) date;
-(void)dayEventSelected:(SMXBlueButton *)eventButton;

-(void)resetAllViews;
-(void)resetloadAllView;

@end
