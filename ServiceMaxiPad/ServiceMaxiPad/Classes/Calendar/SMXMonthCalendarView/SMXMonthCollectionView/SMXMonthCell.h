//
//  SMXMonthCell.h
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

@protocol SMXMonthCellProtocol <NSObject>
@required
- (void)saveEditedEvent:(SMXEvent *)eventNew ofCell:(UICollectionViewCell *)cell atIndex:(NSInteger)intIndex;
- (void)deleteEventOfCell:(UICollectionViewCell *)cell atIndex:(NSInteger)intIndex;
@end

@interface SMXMonthCell : UICollectionViewCell

@property (nonatomic, strong) id<SMXMonthCellProtocol> protocol;
@property (nonatomic, strong) NSMutableArray *arrayEvents;

@property (strong, nonatomic) UILabel *labelDay;
@property (strong, nonatomic) UIImageView *imageViewCircle;
@property (strong, nonatomic) UIButton *cellButton;
@property (strong, nonatomic) NSDate *cellDate;

- (void)initLayout;
- (void)markAsWeekend;
- (void)markAsCurrentDay;
-(void)firstDayOfTheMonth;
-(void)setFont:(UIFont *)font;
-(void)enableJumpToday:(CGRect )frame;

@end
