//
//  UIColor+SMXMoreColors.m
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

#import "UIColor+SMXMoreColors.h"

@implementation UIColor (SMXMoreColors)

+ (UIColor *)smxOrangeColor;
{
    return [UIColor colorWithRed:250.0/255.0 green:104.0/255.0 blue:32.0/255.0 alpha:1.0];
}

+ (UIColor *)lighterGrayColor
{
    return [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
}


+ (UIColor *)lighterGrayCustom {
    return [UIColor colorWithWhite:0.95 alpha:1];
}

+ (UIColor *)lightGrayCustom {
   return [UIColor colorWithWhite:0.8 alpha:1];
}

@end
