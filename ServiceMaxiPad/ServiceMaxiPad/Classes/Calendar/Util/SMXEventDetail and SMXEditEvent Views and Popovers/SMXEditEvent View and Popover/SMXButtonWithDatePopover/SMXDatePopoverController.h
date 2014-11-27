//
//  SMXDatePopoverController.h
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

@protocol SMXDatePopoverControllerProtocol <NSObject>
@required
- (void) valueChanged:(NSDate *)newDate;
@end

@interface SMXDatePopoverController : UIPopoverController

@property (nonatomic, strong) id<SMXDatePopoverControllerProtocol> protocol;

- (id)initWithDate:(NSDate *)date;

@end
