//
//  SMXDayCalendarView.h
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

@protocol SMXDayCalendarViewProtocol <NSObject>
@required
- (void)setNewDictionary:(NSDictionary *)dict;
@end

@interface SMXDayCalendarView : UIView

@property (nonatomic, strong) id<SMXDayCalendarViewProtocol> protocol;
@property (nonatomic, strong) NSMutableDictionary *dictEvents;

- (void)invalidateLayout;
- (void)showLeftPanel;
-(void)removeCalender;
@end
