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

@protocol blueButtonProtocol <NSObject>

-(void)dayEventSelected:(id)button;

@end

@interface SMXBlueButton : UIView

@property (nonatomic, strong) SMXEvent *event;
@property (nonatomic, strong) UILabel *eventName;
@property (nonatomic, strong) UILabel *eventAddress;
@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, assign) BOOL _IsWeekEvent;
@property (nonatomic, assign) int cuncurrentIndex;
@property (nonatomic, strong) UIImageView *firstImageView;
@property (nonatomic, strong) UIImageView *secondImageView;
@property (nonatomic, strong) UIImageView *thirdImageView;
@property (nonatomic, assign) id <blueButtonProtocol> buttonProtocol;
@property (nonatomic, strong) CALayer *cTopBorder;
@property (nonatomic,assign) BOOL isMultiDayEvent;
@property (nonatomic,assign) int eventIndex;

//overlaping eventChange
@property (nonatomic, assign) long xPosition;
@property (nonatomic, assign) long wDivision;
@property (nonatomic, assign) long intOverLapWith;

@property (nonatomic, strong) UILabel *eventSubject;

-(void)restContentFrames:(CGFloat )wirdth;

-(void)setThreeSideLayerForSmallerEvent;
-(void)removeBorderLayersFromButton;
-(BOOL)doesHaveBorder;
-(void)setEventSubjectLabelPosition;

-(void)setTheButtonForNormalState;
-(void)setTheButtonForSelectedState;
-(void)setTheButtonForDraggingState;
-(void)setTheEventTitleForNormalState;
-(void)setSubViewFramw;

@end
