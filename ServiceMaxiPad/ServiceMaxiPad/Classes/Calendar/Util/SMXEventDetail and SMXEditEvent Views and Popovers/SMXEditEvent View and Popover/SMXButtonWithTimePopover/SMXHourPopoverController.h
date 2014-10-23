//
//  SMXHourPopoverController.h
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

@protocol SMXHourPopoverControllerProtocol <NSObject>
@required
- (void) valueChanged:(NSDate *)newDate;
@end

@interface SMXHourPopoverController : UIPopoverController

@property (nonatomic, strong) id<SMXHourPopoverControllerProtocol> protocol;

- (id)initWithDate:(NSDate *)date;


@end
