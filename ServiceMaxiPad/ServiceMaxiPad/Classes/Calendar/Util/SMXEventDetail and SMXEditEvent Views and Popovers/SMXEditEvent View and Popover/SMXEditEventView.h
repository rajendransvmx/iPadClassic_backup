//
//  EditView.h
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

@protocol SMXEditEventViewProtocol <NSObject>
@required
- (void)saveEvent:(SMXEvent *)_event;
- (void)deleteEvent:(SMXEvent *)_event;
- (void)removeThisView:(UIView *)view;
@end

@interface SMXEditEventView : UIView

@property (nonatomic, strong) id<SMXEditEventViewProtocol> protocol;

- (id)initWithFrame:(CGRect)frame event:(SMXEvent *)_event;

@end
