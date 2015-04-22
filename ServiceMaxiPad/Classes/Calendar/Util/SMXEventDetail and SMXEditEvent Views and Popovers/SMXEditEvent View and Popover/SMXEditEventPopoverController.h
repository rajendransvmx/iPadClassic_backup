//
//  SMXEditEventPopoverController.h
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

@protocol SMXEditEventPopoverControllerProtocol <NSObject>
@required
- (void)saveEditedEvent:(SMXEvent *)eventNew;
- (void)deleteEvent;
@end

@interface SMXEditEventPopoverController : UIPopoverController

@property (nonatomic, strong) id<SMXEditEventPopoverControllerProtocol> protocol;

- (id)initWithEvent:(SMXEvent *)eventInit;

@end
