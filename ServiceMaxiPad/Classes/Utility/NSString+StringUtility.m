//
//  NSString+StringUtility.m
//  ServiceMaxMobile
//
//  Created by Pushpak on 21/05/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   NSString+StringUtility.h
 *  @class  NSString (StringUtility)
 *
 *  @brief  Category on NSString class with handy methods.
 *
 *  @author Pushpak
 *
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import "NSString+StringUtility.h"
#import <stdarg.h>
#import <stdio.h>
#import <string.h>
#import <stdlib.h>

@implementation NSString (StringUtility)

/**
 Method is using hardcoded buffer lenght value.
+ (NSString *)getStringWithFormat:(char *)fmt, ... {
    
    char buf[250];     // this should really be sized appropriately
    va_list vl;
    va_start(vl, fmt);
    vsnprintf(buf, sizeof(buf), fmt, vl);
    va_end( vl);
    NSString *s = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
    return s;
    
}
*/

+ (NSString *)stringWithDefinedFormat:(char *)fmt, ...
{
    va_list vl;
    int  len = 0;
    va_start(vl, fmt);
    len += vsnprintf(0, 0, fmt, vl);
    va_end(vl);
    char buf[len];
    va_start(vl, fmt);
    vsnprintf(buf,len+1, fmt, vl);
    va_end(vl);
    NSString *s = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
    return s;
}

+ (NSString *)custAppend:(NSString *)list, ...
{
    NSMutableString * res = [NSMutableString string];
    [res appendString:list];
    va_list args;
    va_start(args, list);
    id arg = nil;
    while(( arg = va_arg(args, id))){
        [res appendString:arg];
    }
    va_end(args);
    return res;
}

- (BOOL)stringContains:(NSString*)string
{
    return [self rangeOfString:string].location != NSNotFound;
}

- (BOOL)stringContainsOnlyLetters
{
    NSCharacterSet *blockedCharacters = [[NSCharacterSet letterCharacterSet] invertedSet];
    return ([self rangeOfCharacterFromSet:blockedCharacters].location == NSNotFound);
}

- (BOOL)stringContainsOnlyNumbers
{
    NSCharacterSet *numbers = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    return ([self rangeOfCharacterFromSet:numbers].location == NSNotFound);
}

- (BOOL)stringContainsOnlyNumbersAndLetters
{
    NSCharacterSet *blockedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    return ([self rangeOfCharacterFromSet:blockedCharacters].location == NSNotFound);
}


- (NSString*)custStringByRemovingPrefix:(NSString*)prefix
{
    NSRange range = [self rangeOfString:prefix];
    if(range.location == 0) {
        return [self stringByReplacingCharactersInRange:range withString:@""];
    }
    return self;
}

- (NSString*)custStringByRemovingPrefixes:(NSArray*)prefixes
{
    for(NSString *prefix in prefixes) {
        NSRange range = [self rangeOfString:prefix];
        if(range.location == 0) {
            return [self stringByReplacingCharactersInRange:range withString:@""];
        }
    }
    return self;
}

- (BOOL)custHasPrefixes:(NSArray*)prefixes
{
    for(NSString *prefix in prefixes) {
        if([self hasPrefix:prefix])
            return YES;
    }
    return NO;
}

- (BOOL)custIsEqualToOneOf:(NSArray*)strings
{
    for(NSString *string in strings) {
        if([self isEqualToString:string]) {
            return YES;
        }
    }
    return NO;
}

-(BOOL)custIsBlank
{
    if([[self custStringByStrippingWhitespace] isEqualToString:@""])
        return YES;
    return NO;
}

-(NSString *)custStringByStrippingWhitespace
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString *)custSubstringFrom:(NSInteger)from to:(NSInteger)to
{
    NSString *rightPart = [self substringFromIndex:from];
    return [rightPart substringToIndex:to-from];
}

// PCRD-90 #279

- (BOOL)custContainsString:(NSString*)other; {
    NSRange range = [self rangeOfString:other];
    return range.length != 0;
}


@end
