//
//  NumberUtility.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 01/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   NumberUtility.h
 *  @class  NumberUtility
 *
 *  @brief  Utility class for number
 *
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import "NumberUtility.h"

static const NSInteger SalesForceIntegerNumberMaxLength = 18;
static const NSInteger SalesForceRealNumberMaxLength = 19;

//static const NSInteger  MAX_iOS_int = 2147483647
//MAX_iOS_DOUBLE = 9223372036854775808.0
//MAX_iOS_Long_Long = 9223372036854775807
//MAX_iOS_Long_Long = 9223372036854775807

int       iOSSystemIntegerMax   = 2147483647;
long long iOSSystemLongLongMax  = 9223372036854775807LL;
long long SQLiteIntegerMax      = 9223372036854775807;

double    iOSSystemRealMax      = 9223372036854775807.0F;
double    SQLiteRealMax         = 9223372036854775808.0F;

@implementation NumberUtility

/**
 * @name   (NumberSystemLimit)isValidRealNumber:(NSString *)realNumber withPrecision:(int)precision
 *
 * @author Vipindas Palli
 *
 * @brief  Validate given real number meeting matching criteria of sales force limit, SQLite limit and iOS limit
 *
 * \par
 *  <Longer description starts here>
 * @param1 realNumber a number in string format
 * @param1 precision  a number in string format  which represnets in precision part of the real number
 * @return NumberSystemLimit value
 *
 */

+ (NumberSystemLimit)isValidRealNumber:(NSString *)realNumber withPrecision:(int)precision
{
        NumberSystemLimit valid = NSLimitValid;
    
        if ([realNumber length] > SalesForceRealNumberMaxLength)
        {
            valid = NSLimitExceedingSalesForceRealLimit;
        }
        else
        {
            if (precision > 0)
            {
                // Precision defined earlier. Lets verify precision matching
                NSArray *subStrings = [realNumber  componentsSeparatedByString:@"."];
                if ([subStrings count] == 2)
                {
                    NSString *secondString = [subStrings objectAtIndex:1];
                    if ([secondString length] > precision)
                    {
                        // Wooo Precision is not matching.
                        valid = NSLimitOverFlowConfiguredPrecisionLimit;
                    }
                }
            }
            
            if (valid == NSLimitValid)
            {
                double number =  [realNumber doubleValue];
                
                if (number > SQLiteRealMax)
                {
                    valid = NSLimitExceedingSQLiteRealLimit;
                }
                else  if (number > iOSSystemRealMax)
                {
                    valid = NSLimitExceedingiOSDoubleLimit;
                }
            }
        }
    
    return valid;
}

/**
 * @name   (NumberSystemLimit)isValidInteger:(NSString *)intValue;
 *
 * @author Vipindas Palli
 *
 * @brief  Validate given integer number meeting matching criteria of sales force limit, SQLite limit and iOS limit
 *
 * \par
 *  <Longer description starts here>
 * @param1 intValue a number in string format
 * @return NumberSystemLimit value
 *
 */

+ (NumberSystemLimit)isValidInteger:(NSString *)intValue
{
    NumberSystemLimit valid = NSLimitValid;
    
    if ([intValue length] > SalesForceIntegerNumberMaxLength)
    {
        valid = NSLimitExceedingSalesForceIntgerLimit;
    }
    else
    {
        if (valid == NSLimitValid)
        {
            long long number =  [intValue doubleValue];
            
            if (number > SQLiteIntegerMax)
            {
                valid = NSLimitExceedingSQLiteIntgerLimit;
            }
            else if (number > iOSSystemLongLongMax)
            {
                valid = NSLimitExceedingiOSLonLongLimit;
            }
        }
    }
    
    return valid;
}

+ (NumberSystemLimit)isValidInteger:(NSString *)intValue withEnabledLangLimit:(BOOL)bolean
{
        return YES;
}

+ (BOOL)isDotFoundInText:(NSString*)text
{
    NSString * substring = [text substringFromIndex:0];
    NSRange dotrange = [substring rangeOfString:@"."];
    
    if(dotrange.location == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}

+(BOOL)isValidIntegerValue:(NSString*)text
{
    NSScanner * scanner = [NSScanner scannerWithString:text];
    int val;
    BOOL isInt = [scanner scanInt:&val] && [scanner isAtEnd];
    return isInt;
}


@end
