//
//  UILabel+SMXCustomMethods.m
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

#import "UILabel+SMXCustomMethods.h"

@implementation UILabel (SMXCustomMethods)

- (void)widthToFit {
    
    self.numberOfLines = 0;
    
    CGRect textRect = [self.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil];
    
    CGRect labelRect = self.frame;
    labelRect.size.width = textRect.size.width;
    
    [self setFrame:labelRect];
}

- (CGFloat)widthThatWouldFit {
    
    self.numberOfLines = 0;
    
    CGRect textRect = [self.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil];
    
    return textRect.size.width;
}

@end
