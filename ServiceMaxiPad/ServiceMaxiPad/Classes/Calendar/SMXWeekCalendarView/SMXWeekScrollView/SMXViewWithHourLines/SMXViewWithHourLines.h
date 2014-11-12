//
//  SMXViewWithHourLines.h
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

@interface SMXViewWithHourLines : UIView

@property (nonatomic, strong) UILabel *labelWithSameYOfCurrentHour;
@property (nonatomic) CGFloat totalHeight;

- (UILabel *)labelWithCurrentHourWithWidth:(CGFloat)_width;
- (void)labelWithCurrentHourWithWidth_refresh:(CGFloat)_width ;

@end
