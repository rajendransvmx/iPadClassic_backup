//
//  Utility.m
//  iService
//
//  Created by Shravya shridhar on 2/20/13.
//
//

#import "Utility.h"

@implementation Utility

+ (BOOL)checkIfStringEmpty:(NSString *)str {
    
    
    if (str != nil && !([[str class] isEqual:[NSNull class]])) {
        
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (![str isEqualToString:@""] && !([str isEqualToString:@" "] ) ) {
            return NO;
        }
    }
    
    return YES;
}

+ (BOOL)isStringEmpty:(NSString *)newString {
    
    return [Utility checkIfStringEmpty:newString];
}

+ (NSDate *)getDateFromString:(NSString *)someDateString {
    
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyy-MM-dd"];
    [dateFormater setTimeZone:gmt];
    NSDate *someDate = [dateFormater dateFromString:someDateString];
    [dateFormater release];
    dateFormater = nil;
    return someDate;
}

+ (NSDate *)todayDateInGMT {
    return [NSDate date];
}

+ (BOOL)checkIfDate:(NSDate *)todayDate betweenDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    
    NSTimeInterval startTI = [startDate timeIntervalSinceReferenceDate];
    NSTimeInterval endTI = [endDate timeIntervalSinceReferenceDate];
    NSTimeInterval todayTI = [todayDate timeIntervalSinceReferenceDate];
    
    if (startTI <= todayTI &&  todayTI <= endTI  ) {
        return YES;
    }
    return NO;
}

+ (NSDictionary *)getTheParameterFromUrlParameterString:(NSString*)urlParam {
    
    NSArray *stringArray = [urlParam componentsSeparatedByString:@"&"];
    NSMutableDictionary *keysDictionary = [[NSMutableDictionary alloc] init];
    for (NSString *paramString in stringArray) {
        NSArray *valueArray =  [paramString componentsSeparatedByString:@"="];
        
        NSString *key = nil,*value = @"";
        if ([valueArray count] > 0) {
            key = [valueArray objectAtIndex:0];
        }
        
        if ([valueArray count] > 1) {
            value = [valueArray objectAtIndex:1];
        }
        if (key != nil) {
            [keysDictionary setObject:value forKey:key];
        }
    }
    return [keysDictionary autorelease];
}

+ (NSString *)replaceTinDateBySpace:(NSString *)stringToBeChanged {
   
    stringToBeChanged = [stringToBeChanged stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger length =  [stringToBeChanged rangeOfString:@"T"].length;
    if (length > 0 ) {
        stringToBeChanged = [stringToBeChanged stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    }
    return stringToBeChanged;
}
+ (NSString *)replaceSpaceinDateByT:(NSString *)stringToBeChanged {
    stringToBeChanged = [stringToBeChanged stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger length =  [stringToBeChanged rangeOfString:@" "].length;
    if (length > 0 ) {
        stringToBeChanged = [stringToBeChanged stringByReplacingOccurrencesOfString:@" " withString:@"T"];
    }
    return stringToBeChanged;
}

+ (BOOL)containsString:(NSString *)someString inString:(NSString *)parentString {
   NSRange range = [parentString rangeOfString:someString];
    if( NSEqualRanges(range, NSMakeRange(NSNotFound, 0)) ) {
            return NO;
    }
    return YES;
}

+ (BOOL)isItTrue:(NSString *)stringTrue {
     stringTrue = [stringTrue lowercaseString];
    if ([stringTrue isEqualToString:@"true"]  || [stringTrue isEqualToString:@"True"] ||  [stringTrue isEqualToString:@"1"] ) {
        return YES;
    }
    return NO;
}

+ (BOOL)isStringNotNULL:(NSString *)value {
    NSString *someString = [NSString stringWithFormat:@"%@",value];
    value = [someString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    value = [value lowercaseString];
    if([value isEqualToString:@"<null>"] || [value isEqualToString:@"<NULL>"] || [value isEqualToString:@"Null"] || [value isEqualToString:@"null"]){
        return NO;
    }
    return YES;
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
    
    return [concatenatedString autorelease];
}
@end
