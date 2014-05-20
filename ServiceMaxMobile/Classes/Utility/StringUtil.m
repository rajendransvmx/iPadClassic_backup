//
//  StringUtil.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 4/11/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "StringUtil.h"

@implementation StringUtil


+ (BOOL)checkIfStringEmpty:(NSString *)str
{
    if (str != nil && !([[str class] isEqual:[NSNull class]]))
    {
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
     
        if (![str isEqualToString:@""] && !([str isEqualToString:@" "] ) )
        {
            return NO;
        }
    }
    return YES;
}


+ (BOOL)isStringEmpty:(NSString *)string
{
    BOOL isEmpty = NO;
    
    if ( (string == nil) || ([[string class] isEqual:[NSNull class]]))
    {
        isEmpty = YES;
    }
    else
    {
        // Lets trim new line nd white space character
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (([string isEqualToString:@""] )|| ([string length] == 0) )
        {
            // Yes, the string is empty after trimming
            isEmpty = YES;
        }
    }
    
    return isEmpty;
}


+ (BOOL)isValidOrZeroLengthString:(NSString *)string
{
    BOOL isValid = NO;
    
    if (string != nil)
    {
        if ([[string class] isEqual:[NSString class]])
        {
            isValid = YES;
        }
    }
    
    return isValid;
}


+ (BOOL)isStringNotNULL:(NSString *)value
{
    BOOL isNotNull = YES;
    
    NSString *someString = [NSString stringWithFormat:@"%@",value];

    // Lets remove white characters and new line characters
    value = [someString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    value = [value lowercaseString];
    
    if (  ([value isEqualToString:@"<null>"])
       || ([value isEqualToString:@"<NULL>"])
       || ([value isEqualToString:@"Null"])
       || ([value isEqualToString:@"null"]) )
    {
        isNotNull = NO;
    }
    
    return isNotNull;
}


+ (BOOL)containsString:(NSString *)subString inString:(NSString *)metaString
{
    BOOL containString = YES;
   
    if ((subString == nil) || (metaString == nil) )
    {
        containString = NO;
    }
    else
    {
        NSRange range = [metaString rangeOfString:subString];
        if (NSEqualRanges(range, NSMakeRange(NSNotFound, 0)) )
        {
            containString = NO;
        }
    }

    return containString;
}

@end
