//
//  SMXHourAndMinLabel.h
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

@interface SMXHourAndMinLabel : UILabel

@property (nonatomic, strong) NSDate *dateHourAndMin;
@property (nonatomic) CGFloat topInset;
@property (nonatomic) CGFloat leftInset;
@property (nonatomic,assign) BOOL isAttributedString;

- (id)initWithFrame:(CGRect)frame date:(NSDate *)date;
- (void)showText;
-(void)showAttributedText;

@end
