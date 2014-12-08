//
//  SMXEventDetailView.h
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
#import "MapHelper.h"
#import "ContactImageModel.h"

#import "SMXEvent.h"
#import <CoreLocation/CoreLocation.h>

@protocol SMXEventDetailViewProtocol <NSObject>

-(void)rescheduleEvent:(SMXEvent *) _event;

- (void)showEditViewWithEvent:(SMXEvent *)_event;
@end

@interface SMXEventDetailView : UIView <CLLocationManagerDelegate>

@property (nonatomic, strong) id<SMXEventDetailViewProtocol> protocol;
@property (nonatomic, strong) UIButton *buttonDetailPopover;

@property (nonatomic, strong) UIButton *buttonReschedulePopover;

@property (nonatomic, strong) UIButton *buttonEmail;

@property (nonatomic, strong) UIButton *buttonChat;

@property (nonatomic, strong) UIButton *buttonMap;

- (id)initWithFrame:(CGRect)frame event:(SMXEvent *)_event;

@end
