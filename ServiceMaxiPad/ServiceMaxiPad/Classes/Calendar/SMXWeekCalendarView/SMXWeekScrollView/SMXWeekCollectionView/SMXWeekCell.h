//
//  SMXWeekCell.h
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

@protocol SMXWeekCellProtocol <NSObject>
@required
- (void)saveEditedEvent:(SMXEvent *)eventNew ofCell:(UICollectionViewCell *)cell atIndex:(NSInteger)intIndex;
- (void)deleteEventOfCell:(UICollectionViewCell *)cell atIndex:(NSInteger)intIndex;
@end

@interface SMXWeekCell : UICollectionViewCell

@property (nonatomic, strong) id<SMXWeekCellProtocol>protocol;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) CAShapeLayer *_border;


- (void)clean;

- (void)showEvents:(NSArray *)array;

@end
