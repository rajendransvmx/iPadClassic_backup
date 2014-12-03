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

@protocol SMXCalendarViewControllerProtocol <NSObject>
@required
- (void)arrayUpdatedWithAllEvents:(NSMutableArray *)arrayUpdated;
@end

@interface SMXCalendarViewController : UIViewController<WizardDelegate,SMXCurrentDayDelegate>

@property (nonatomic, strong) id <SMXCalendarViewControllerProtocol> protocol;
@property (nonatomic, strong) NSMutableArray *arrayWithEvents;
@property (nonatomic, strong) CalendarMonthViewController *monthCalender;
@property (nonatomic, strong) NSArray *cEventListArray;

-(void)removeCalender;
@end
