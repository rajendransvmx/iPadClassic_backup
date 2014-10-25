//
//  SMXEventDetailPopoverController.h
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

@protocol SMXEventDetailPopoverControllerProtocol <NSObject>
@required
- (void)showPopoverEditWithEvent:(SMXEvent *)_event;
@end

@interface SMXEventDetailPopoverController : UIPopoverController

@property (nonatomic, strong) id<SMXEventDetailPopoverControllerProtocol> protocol;

- (id)initWithEvent:(SMXEvent *)eventInit;

@end
