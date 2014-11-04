//
//  DateUtil.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/21/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//
/**
 *  @file   DateUtil.m
 *  @class  DateUtil
 *
 *  @brief  This contains utilitiy methods related to date and date formatting
 *
 *
 *  This contains utilitiy methods related to date and date formatting
 *
 *  @author  Vipindas Palli
 *  @author  Pushpak N
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "DateUtil.h"
#import "NSDate+TKCategory.h"

#import <xlocale.h>
#include <time.h>

#import "TagConstant.h"
#import "TagManager.h"
/** 2014-04-30T09:44:42.000+0000 */

static NSString *kDateFormatForDatabase = @"%Y-%m-%dT%H:%M:%S.000%z";

@implementation DateUtil

/**
 * @name   dateFromString:(NSString *)string inFormat:(NSString *)format
 *
 * @author Pushpak N
 *
 * @brief  Returns a date representation of a given string interpreted via `strptime_l()` using the receiver’s current settings.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param  string The string to parse.
 * @param  format The format in which string is represented in.
 *
 * @return A date representation of *string* interpreted via `strptime_l()` using the receiver’s current settings. If `dateFromString:` can not parse the string, returns `nil`.
 *
 *
 */

+ (NSDate *)dateFromString:(NSString *)string inFormat:(NSString *)format
{
    NSAssert(format != NULL, @"dateFromString:inFormat: The format string must not be NULL!");
    NSAssert(string != NULL, @"dateFromString:inFormat: The date string must not be NULL!");
    
    time_t timeInterval;
    struct tm time;
    memset(&time, 0, sizeof(time));
    const char *formatString = [format cStringUsingEncoding:NSASCIIStringEncoding];
    strptime_l([string UTF8String], formatString, &time, NULL);
    
    timeInterval = mktime(&time);
    // timeInterval = calendar.timegm(&time);
    return [NSDate dateWithTimeIntervalSince1970:timeInterval];
}

/**
 * @name   stringFromDate:(NSDate *)date inFormat:(NSString *)format
 *
 * @author Pushpak N
 *
 * @brief  Returns a string representation of a given date formatted via `strftime_l()` using the receiver’s current settings.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param  date The date to format.
 * @param  format The format in which the string has to be returned.
 *
 * @return A string representation of *date* formatted via `strftime_l()` using the receiver’s current settings.
 *
 */

+ (NSString *)stringFromDate:(NSDate *)date inFormat:(NSString *)format
{
    NSAssert(format != NULL, @"stringFromDate:inFormat: The format string must not be NULL!");
    NSAssert(date != NULL, @"stringFromDate:inFormat: The input date must not be NULL!");
    
    time_t timeInterval;
    struct tm time;
    char buffer[80];
    const char *formatString = [format cStringUsingEncoding:NSASCIIStringEncoding];
    
    timeInterval = [date timeIntervalSince1970];
    time = *localtime(&timeInterval);
    //time = *gmtime (&timeInterval);
    
    strftime_l(buffer, sizeof(buffer), formatString, &time, NULL);
    
    return [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
}

/**
 * @name   gmtStringFromDate:(NSDate *)date inFormat:(NSString *)format
 *
 * @author Pushpak N
 *
 * @brief  Returns a gmt string representation of a given date formatted via `strftime_l()` using the receiver’s current settings.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param  date The date to format.
 * @param  format The format in which the string has to be returned.
 *
 * @return A string representation of *date* formatted via `strftime_l()` using the receiver’s current settings.
 *
 */

+ (NSString *)gmtStringFromDate:(NSDate *)date inFormat:(NSString *)format
{
    @synchronized(self)
    {
        char *tz;
        //Get current time zone
        tz = getenv("TZ");
        //Set zone to GMT
        setenv("TZ", "GMT", 1);
        tzset();
        
        NSString *result = [self stringFromDate:date inFormat:format];
        
        //Check and revert to previous time zone
        if (tz)
            setenv("TZ", tz, 1);
        else
            unsetenv("TZ");
        tzset();
        return result;
    }}

#pragma mark - SQLite Supported

/**
 * @name   getDatabaseStringForDate:(NSDate *)dateToBeConverted
 *
 * @author Pushpak N
 *
 * @brief  Returns a string representation of a given date formatted via `strftime_l()` using the receiver’s current settings.
 *
 * \par
 *   By default class internally will use  "%Y-%m-%dT%H:%M:%S.000%z" format
 *
 *
 * @param  date The date to format.
 *
 * @return A string representation of *date* formatted via `strftime_l()` using the receiver’s current settings.
 *
 */

+ (NSString *)getDatabaseStringForDate:(NSDate *)dateToBeConverted
{
    @synchronized(self)
    {
        char *tz;
        //Get current time zone
        tz = getenv("TZ");
        //Set zone to GMT
        setenv("TZ", "GMT", 1);
        tzset();
        
        NSString *result = [self stringFromDate:dateToBeConverted inFormat:kDateFormatForDatabase];
        
        //Check and revert to previous time zone
        if (tz)
            setenv("TZ", tz, 1);
        else
            unsetenv("TZ");
        tzset();
        return result;
    }
}

/**
 * @name   getDateFromDatabaseString:(NSString *)dateString
 *
 * @author Pushpak N
 *
 * @brief  Returns a date representation of a given string interpreted via `strptime_l()` using the receiver’s current settings.
 *
 * \par
 *   By default class internally will use "%Y-%m-%dT%H:%M:%S.000%z" format
 *
 *
 * @param  string The string to parse.
 *
 * @return A date representation of *string* interpreted via `strptime_l()` using the receiver’s current settings. If `dateFromString:` can not parse the string, returns `nil`.
 *
 *
 */

+ (NSDate *)getDateFromDatabaseString:(NSString *)dateString{
    
    return [self dateFromString:dateString inFormat:kDateFormatForDatabase];
}

#pragma mark - Current Date Time Methods

/**
 * @name   currentGMTTimeInFormat:(NSString *)format
 *
 * @author Pushpak N
 *
 * @brief  Returns a string representation of today's date in GMT formatted via `strftime_l()` using the receiver’s current settings.
 *
 *
 * @param  date The date to format.
 *
 * @return A string representation of today's date in GMT formatted via `strftime_l()` using the receiver’s current settings.
 *
 */

+ (NSString *)currentGMTTimeInFormat:(NSString *)format
{
    return [self gmtStringFromDate:[NSDate date] inFormat:format];
}

/**
 * @name   currentLocalTimeInFormat:(NSString *)format
 *
 * @author Pushpak N
 *
 * @brief  Returns a string representation of today's date formatted via `strftime_l()` using the receiver’s current settings.
 *
 *
 * @param  date The date to format.
 *
 * @return A string representation of today's date formatted via `strftime_l()` using the receiver’s current settings.
 *
 */
+ (NSString *)currentLocalTimeInFormat:(NSString *)format
{
    return [self stringFromDate:[NSDate date] inFormat:format];
}

/**
 * @name getLiteralSupportedDateStringForDate:(NSDate *)date
 *
 * @author Pushpak
 *
 * @brief get the dateString with Literal support (Today, Tomorrow, Yesterday) Without using date formatter.
 *
 * \par
 *  <Longer description starts here>
 *  Eg "Today 10:39 am"
 *
 *
 * @param date The date to format.
 *
 * @return A string representation of date formatted via `strftime_l()`.
 *
 */
+ (NSString *)getLiteralSupportedDateStringForDate:(NSDate *)date {
    
    NSString * dateInString = nil;
    NSString *datePrefix = nil;
    NSString *timeString = [self stringFromDate:date inFormat:kDateFormatType6];
    if ([date isToday]) {
        //Today
        datePrefix = [[TagManager sharedInstance] tagByName:@"IPAD008_TAG004"];
    } else if([date isTomorrow]) {
        //Tomorrow
        datePrefix = [[TagManager sharedInstance] tagByName:@"IPAD006_TAG090"];
    } else if([date isYesterday]) {
        //Yesterday
        datePrefix = [[TagManager sharedInstance] tagByName:@"IPAD008_TAG005"];
    } else {
        datePrefix = [self stringFromDate:date inFormat:kDateFormatType7];
    }
    dateInString = [NSString stringWithFormat:@"%@ %@",datePrefix,[timeString lowercaseString]];
    return dateInString;
}




+ (NSString *) getUserReadableDateForSyncStatus:(NSDate *)date {
    
    NSString * dateInString = nil;
  
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    
    NSString *datePrefix = nil;
    if([date isToday])
    {
        [formatter setDateFormat:@"hh:mm a"];
        datePrefix = @"Today";
        //datePrefix = [[SMXTagsManager sharedTagManager]getTagForId:Tag_Today];;
    }
    else if([date isTomorrow])
    {
        [formatter setDateFormat:@"hh:mm a"];
        datePrefix = @"Tomorrow";

        //datePrefix = [[SMXTagsManager sharedTagManager]getTagForId:Tag_Tomorrow];;
    }
    else if([date isYesterday])
    {
        [formatter setDateFormat:@"hh:mm a"];
        datePrefix = @"Yesterday";

        //datePrefix = [[SMXTagsManager sharedTagManager]getTagForId:CHATTER_YESTERDAY];;
    }
    else
    {
        [formatter setDateFormat:@"EEE"];
        NSString *dateString = [formatter stringFromDate:[NSDate date]];

        
        
        NSCalendar*       calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents* components = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
        NSInteger         day = [components day];
        NSInteger         month = [components month];
        NSInteger         year = [components year];
        
        NSString *monthStr = [NSString stringWithFormat:@". %d/%d/%d - ",day, month, year];
        dateString = [dateString stringByAppendingString:monthStr];

        datePrefix = dateString;
    }
    
    formatter.dateFormat = @"hh:mm a";
    [formatter setAMSymbol:@"am"];
    [formatter setPMSymbol:@"pm"];
    dateInString = [NSString stringWithFormat:@"%@ %@",datePrefix,[formatter stringFromDate:date]];
    
    return dateInString;
    
}

+(BOOL)iSDeviceTime24HourFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
    BOOL is24h = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
    

    return is24h;
}

+(NSString *)getUserReadableDateForDateBaseDate:(NSString *)dateString
{
    NSString *userdateString = nil;
    
    if ([dateString length] > 0){
        
        NSString *format = nil;
        if ([self iSDeviceTime24HourFormat]) {
            format = kDateFormatType3;
        }
        else{
            format = kDateFormatType12Hr;
        }
        NSDate * date = [self getDateFromDatabaseString:dateString];
        if (date != nil) {
            userdateString = [self stringFromDate:date inFormat:format];
        }
    }
    return userdateString;
    
}
+ (NSString *)getUserReadableDateForDBDateTime:(NSString *)dateTime
{
    NSString *dateString = nil;
    NSDate * date = [DateUtil dateFromString:dateTime inFormat:kDateFormatDefault];
    if (date != nil) {
        dateString = [DateUtil stringFromDate:date inFormat:kDateFormatForSFMEdit];
    }
    return dateString;
}
+(NSString *)getUserReadableDateForGMT:(NSDate *)date
{
    NSString *userdateString = nil;
    
    if (date != nil){
        NSString *format = nil;
        if ([self iSDeviceTime24HourFormat]) {
            format = kDateFormatType3;
        }
        else{
            format = kDateFormatType12Hr;
        }
        userdateString = [self stringFromDate:date inFormat:format];
    }
    return userdateString;
    
}

+ (NSDate *)dateWithOutTime:(NSDate *)datDate{
    if( datDate == nil ) {
        datDate = [NSDate date];
    }
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:datDate];
    [comps setHour:00];
    [comps setMinute:00];
    [comps setSecond:00];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

+ (NSDate *)dateWithOutTimeInGMT:(NSDate *)datDate {
    if( datDate == nil ) {
        datDate = [NSDate date];
    }
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* comps = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:datDate];
    [comps setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [comps setHour:00];
    [comps setMinute:00];
    [comps setSecond:00];
    return [cal dateFromComponents:comps];
}

+(NSString *)evaluateDateLiteral:(NSString *)literal  dataType:(NSString *)dataType
{
    NSDate * date = [DateUtil getDateForLiteral:literal];
    NSString * dateInString = nil;
   // NSString *format = [DateUtil getDateFormateForDataType:dataType];
    dateInString = [self getDatabaseStringForDate:date];
    return dateInString;
}

+(NSDate *)getDateForLiteral:(NSString *)literal
{
    NSDate * date = nil;
    
    if([literal caseInsensitiveCompare:kLiteralNow] == NSOrderedSame)
    {
        date = [NSDate date];
    }
    else if ([literal caseInsensitiveCompare:kLiteralToday] == NSOrderedSame)
    {
        date = [DateUtil dateWithOutTime:[NSDate date]];
    }
    else if ([literal caseInsensitiveCompare:kLiteralTomorrow] == NSOrderedSame)
    {
        date = [DateUtil dateWithOutTime:[NSDate tomorrow]];

    }
    else if ([literal caseInsensitiveCompare:kLiteralYesterday] == NSOrderedSame)
    {
        date = [DateUtil dateWithOutTime:[NSDate yesterday]];

    }
    else
    {
        date = [NSDate date];

    }
    
    return date;
}
+(NSString *)getDateFormateForDataType:(NSString *)dataType
{
    NSString *format = nil;
    if([dataType isEqualToString:kSfDTDateTime])
    {
        if ([self iSDeviceTime24HourFormat]) {
            format = kDateFormatType3;
        }
        else{
            format = kDateFormatType12Hr;
        }
    }
    else   if([dataType isEqualToString:kSfDTDate])
    {
        format = kDateFormatForSFMEdit;
    }
    return format;
}

+(int )toLocalTime:(NSDate *)currentdate
{
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate:currentdate];
    return seconds;
    //return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}
@end

