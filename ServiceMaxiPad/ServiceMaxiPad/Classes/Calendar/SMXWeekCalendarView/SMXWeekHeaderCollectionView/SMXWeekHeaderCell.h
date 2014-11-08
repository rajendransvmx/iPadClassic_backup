//
//  SMXWeekHeaderCell.h
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

@interface SMXWeekHeaderCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSDate *date;

- (void)cleanCell;

@end
