//
//  SMXDayCell.h
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
#import "SMXBlueButton.h"
@protocol SMXDayCellProtocol <NSObject>
- (void)showViewDetailsWithEvent:(SMXBlueButton *)_button cell:(UICollectionViewCell *)cell;

@end

@interface SMXDayCell : UICollectionViewCell <UIAlertViewDelegate>

@property (nonatomic, strong) id<SMXDayCellProtocol> protocol;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) SMXBlueButton *cSelectedEventButton;

- (void)showEvents:(NSArray *)array;

@end
