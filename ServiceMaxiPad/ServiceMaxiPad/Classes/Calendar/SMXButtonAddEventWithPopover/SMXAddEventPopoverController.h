//
//  SMXAddEventPopoverController.h
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

@protocol SMXAddEventPopoverControllerProtocol <NSObject>
@required
- (void)addNewEvent:(SMXEvent *)eventNew;
@end


@interface SMXAddEventPopoverController : UIPopoverController

@property (nonatomic, strong) id<SMXAddEventPopoverControllerProtocol> protocol;

- (id)initPopover;

@end
