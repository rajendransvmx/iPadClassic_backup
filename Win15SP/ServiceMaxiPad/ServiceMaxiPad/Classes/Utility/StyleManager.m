//
//  StyleManager.m
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 15/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//


/*----------------------------------------------------------------------------------------------------
Contains UIColor and UIFont constants for use throughout the app.
----------------------------------------------------------------------------------------------------*/


#import "StyleManager.h"


/*----------------------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------*/
@implementation UIColor (iPad_Additions)

/*----------------------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------*/
+ (UIColor*)dayViewTitleBG
{
	return [UIColor colorWithIntegerRed:230 green:230 blue:230 alpha:255];
    
}

/*----------------------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------*/
+ (UIColor*)loginInfoText;
{
	return [UIColor colorWithIntegerRed:20.0 green:86.0 blue:145.0 alpha:255];
}

/*----------------------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------*/
+ (UIColor*)navBarBG;
{
	return [UIColor colorWithHexString:@"#FF6633"];
}

/*----------------------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------*/
+ (UIColor*)navBarTitleColor;
{
	return [UIColor colorWithHexString:@"#FFFFFF"];
}
/*----------------------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------*/
+ (UIColor*)colorWithIntegerRed:(unsigned char)red green:(unsigned char)green blue:(unsigned char)blue alpha:(unsigned char)alpha;
{
	return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha / 255.0];
}

/*----------------------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------*/
+ (UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}
@end

/*----------------------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------*/
@implementation UIFont (iPad_Additions)

+ (UIFont*)navbarTitle
{
	return [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize18];
}

@end

@implementation UILabel (iPad_Additions)

+(UILabel *)navBarTitleLabel:(NSString *)titleText
{
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
    titleLabel.font = [UIFont navbarTitle];
    titleLabel.textColor = [UIColor navBarTitleColor];
    titleLabel.text = titleText;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    return titleLabel;
}



@end
