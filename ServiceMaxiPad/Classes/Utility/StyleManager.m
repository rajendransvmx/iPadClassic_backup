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
	return [UIColor getUIColorFromHexValue:@"#FF6633"];
}

/*----------------------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------*/
+ (UIColor*)navBarTitleColor;
{
	return [UIColor getUIColorFromHexValue:@"#FFFFFF"];
}
/*----------------------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------*/
+ (UIColor*)colorWithIntegerRed:(unsigned char)red green:(unsigned char)green blue:(unsigned char)blue alpha:(unsigned char)alpha;
{
	return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha / 255.0];
}

/*----------------------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------*/
+ (UIColor*)getUIColorFromHexValue:(NSString*)hxVal
{
    NSString *colorString = [[hxVal stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];

    // strip 0X if it appears
    if ([colorString hasPrefix:@"0X"]) {
        colorString = [colorString substringFromIndex:2];
    }
    
    // strip # if it appears
    if ([colorString hasPrefix:@"#"]) {
        colorString = [colorString substringFromIndex:1];
    }
    
    // String should be 6 or 8 characters
    if ([colorString length] < 6 || [colorString length] != 6) {
        return [UIColor grayColor];
    }
    
    // Separate into red, green, blue substrings
    NSRange stringRange;
    stringRange.length = 2;
    
    //for red
    stringRange.location = 0;
    NSString *redString = [colorString substringWithRange:stringRange];
    
    //for green
    stringRange.location = 2;
    NSString *greenString = [colorString substringWithRange:stringRange];
    
    //for blue
    stringRange.location = 4;
    NSString *blueString = [colorString substringWithRange:stringRange];
    
    // Scan values
    unsigned int red, green, blue;
    [[NSScanner scannerWithString:redString] scanHexInt:&red];
    [[NSScanner scannerWithString:greenString] scanHexInt:&green];
    [[NSScanner scannerWithString:blueString] scanHexInt:&blue];
    
    UIColor *color = [UIColor colorWithRed:((float) red / 255.0f) green:((float) green / 255.0f) blue:((float) blue / 255.0f) alpha:1.0f];
    
    return color;
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
