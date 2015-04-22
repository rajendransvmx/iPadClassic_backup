//
//  SMXWeekCalendarView.h
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
#import "SMXReschedulePopup.h"

@protocol SMXWeekCalendarViewProtocol <NSObject>
@required
- (void)setNewDictionary:(NSDictionary *)dict;
@optional
-(void)addReshudlingWindow:(SMXEvent *)event_Loc; //Rescheduling popup call
@end

@interface SMXWeekCalendarView : UIView<UIScrollViewDelegate>

@property (nonatomic, assign) id<SMXWeekCalendarViewProtocol> protocol;
@property (nonatomic, strong) NSMutableDictionary *dictEvents;
@property (nonatomic, strong) UIImageView *grayBorder;
@property (nonatomic,strong) SMXReschedulePopup *sMXReschedulePopup;
- (void)invalidateLayout;

@end
