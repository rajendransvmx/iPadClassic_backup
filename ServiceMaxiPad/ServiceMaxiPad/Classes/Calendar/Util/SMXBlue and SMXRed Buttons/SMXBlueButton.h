//
//  BlueButton.h
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
#import "SMXConstants.h"

@interface SMXBlueButton : UIView <UIAlertViewDelegate>

@property (nonatomic, strong) SMXEvent *event;
@property (nonatomic, strong) UILabel *eventName;
@property (nonatomic, strong) UILabel *eventAddress;
@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, assign) BOOL _IsWeekEvent;
@property (nonatomic, assign) int cuncurrentIndex;
@property (nonatomic, strong) UIImageView *workOrderSymbols;
-(void)restContentFrames:(CGFloat )wirdth;

@end
