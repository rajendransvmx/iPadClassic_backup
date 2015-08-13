//
//  StringUtil.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 4/11/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "StringUtil.h"

const NSString *utility_org_namespace = ORG_NAME_SPACE;

@implementation StringUtil


+ (BOOL)checkIfStringEmpty:(NSString *)str
{
    if (str != nil && [str isKindOfClass:[NSString class]])
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
    return [StringUtil checkIfStringEmpty:string];
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

+ (NSString *)getConcatenatedStringFromArray:(NSArray *)arayOfString withSingleQuotesAndBraces:(BOOL)isRequired {
    if ([arayOfString count] <= 0) {
        return nil;
    }
    NSMutableString *concatenatedString = [[NSMutableString alloc] init];
    
    if (isRequired) {
        for (int counter = 0; counter < [arayOfString count]; counter++) {
            
            NSString *tempStr = [arayOfString objectAtIndex:counter];
            if (counter == 0) {
                [concatenatedString appendFormat:@"('%@'",tempStr];
            }
            else{
                [concatenatedString appendFormat:@",'%@'",tempStr];
            }
        }
        [concatenatedString appendFormat:@")"];
    }
    else {
        for (int counter = 0; counter < [arayOfString count]; counter++) {
            
            NSString *tempStr = [arayOfString objectAtIndex:counter];
            if (counter == 0) {
                [concatenatedString appendFormat:@"%@",tempStr];
            }
            else{
                [concatenatedString appendFormat:@",%@",tempStr];
            }
        }
    }
    
    return concatenatedString;
}

+ (BOOL)isItTrue:(NSString *)stringTrue {
    if ([stringTrue isKindOfClass:[NSString class]]) {
        stringTrue = [stringTrue lowercaseString];
        if ([stringTrue isEqualToString:kTrue]  ||  [stringTrue isEqualToString:@"1"] ) {
            return YES;
        }
        else {
            return NO;
        }

    }
    
    if ([stringTrue isKindOfClass:[NSNumber class]]) {
        NSInteger intValue = [stringTrue intValue];
        if (intValue == 1) {
            return YES;
        }
        else{
            return NO;
        }
    }
    
    return NO;
}

+ (CGSize)getSizeOfText:(NSString*)text withFont:(UIFont*)font
{
    NSString *new = [text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    new = [new stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    
    NSDictionary *userAttributes = @{NSFontAttributeName: font};
    const CGSize textSize = [new sizeWithAttributes: userAttributes];
    return textSize;
}

+ (CGSize)getSizeOfText:(NSString*)text withFont:(UIFont*)font andRect:(CGRect)rect
{
    NSDictionary *userAttributes = @{NSFontAttributeName: font};
    
    // CGSize size =  [text sizeWithFont:font constrainedToSize:rect.size lineBreakMode:NSLineBreakByCharWrapping];
    CGRect size = [text boundingRectWithSize:CGSizeMake(rect.size.width, 0)
                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                  attributes:userAttributes
                                     context:nil];
    
    
    return size.size ;
}

+ (NSArray *)splitString:(NSString *)stringToBeSplit byString:(NSString *)subString {
    stringToBeSplit = [stringToBeSplit stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *componentsArray = [stringToBeSplit componentsSeparatedByString:subString];
    return componentsArray;
}

+(NSString *)appendOrgNameSpaceToString:(NSString *)toString {
    return [[NSString alloc ] initWithFormat:@"%@%@",utility_org_namespace,toString];
}

+ (BOOL)isStringNumber:(NSString *)string
{
    NSScanner *scanner = [NSScanner scannerWithString:string];
    BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
    
    return isNumeric;
}


+ (BOOL)containsStringinErrorMsg:(NSString *)subString inString:(NSString *)metaString
{
    BOOL containString = YES;
    
    if ((subString == nil) || (metaString == nil) )
    {
        containString = NO;
    }
    else
    {
        NSRange range = [metaString rangeOfString:subString options:NSCaseInsensitiveSearch];
        if (NSEqualRanges(range, NSMakeRange(NSNotFound, 0)) )
        {
            containString = NO;
        }
    }
    
    return containString;
}

@end
