//
//  SMXMonthCalendarView.h
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

@protocol SMXMonthCalendarViewProtocol <NSObject>
@required
- (void)setNewDictionary:(NSDictionary *)dict;
@end

@interface SMXMonthCalendarView : UIView

@property (nonatomic, strong) NSMutableDictionary *dictEvents;
@property (nonatomic, assign) id<SMXMonthCalendarViewProtocol> protocol;
@property (nonatomic, strong)  UIImageView *grayBorder;
@property (nonatomic, strong)  UIImageView *whiteBorder;
- (void)invalidateLayout;

@end
