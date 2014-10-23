//
//  SMXDayHeaderCell.h
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
#import "SMXDayHeaderButton.h"

@interface SMXDayHeaderCell : UICollectionViewCell

@property (nonatomic, strong) SMXDayHeaderButton *button;
@property (nonatomic, strong) UILabel *dayLabel;
@property (nonatomic, strong) UILabel *monthName;
@property (nonatomic, strong) UILabel *yearLabel;
@property (nonatomic, strong) NSDate *date;

@end
