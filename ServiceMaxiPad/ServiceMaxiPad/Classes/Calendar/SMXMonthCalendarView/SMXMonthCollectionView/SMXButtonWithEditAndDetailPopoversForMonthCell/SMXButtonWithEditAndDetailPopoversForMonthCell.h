//
//  SMXButtonWithEditAndDetailPopoversForMonthCell.h
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

#import "SMXEvent.h"

@protocol SMXButtonWithEditAndDetailPopoversForMonthCellProtocol <NSObject>
@required
- (void)saveEditedEvent:(SMXEvent *)eventNew ofButton:(UIButton *)button;
- (void)deleteEventOfButton:(UIButton *)button;
@end

@interface SMXButtonWithEditAndDetailPopoversForMonthCell : UIButton

@property (nonatomic, strong) id<SMXButtonWithEditAndDetailPopoversForMonthCellProtocol> protocol;
@property (nonatomic, strong) SMXEvent *event;

@end
