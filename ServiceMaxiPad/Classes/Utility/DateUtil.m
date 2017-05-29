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
#import "StringUtil.h"
#import "NSDate+SMXDaysCount.h"

/** 2014-04-30T09:44:42.000+0000 */

static NSString *kDateFormatForDatabase = @"%Y-%m-%dT%H:%M:%S.000%z";

@implementation DateUtil

/**
  // PCRD-220
 In Apple's code is used a static const, but since NSDateFormatter
 isn't thread safe a better approach is to use Thread local store
 to cache the NSDateFormatter instance
  // PCRD-220
 */
NSString * const kCachedDateFormatterKey = @"CachedDateFormatterKey";

+ (NSDateFormatter *)dateFormatter
{
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    NSDateFormatter *dateFormatter = [threadDictionary objectForKey:kCachedDateFormatterKey];
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSS"];
        [threadDictionary setObject:dateFormatter forKey:kCachedDateFormatterKey];
    }
    return dateFormatter;
}

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


//Defect Fix:032530
+ (NSDate *)dateFromStringForDaylightTimeZone:(NSString *)gmtDate
{
    NSDate *gmtDateTime = nil;
    
    if ([gmtDate length] > 19)
    {
        gmtDate = [gmtDate substringToIndex:19];
        gmtDate = [NSString stringWithFormat:@"%@Z", gmtDate];
    }
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString * tmpDate = [gmtDate substringToIndex:[gmtDate length]-0];
    tmpDate = [tmpDate stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    tmpDate = [tmpDate stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    tmpDate = [tmpDate stringByDeletingPathExtension];
    
    gmtDateTime = [dateFormatter dateFromString:tmpDate];
    return gmtDateTime;
    
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
    NSAssert(format != nil, @"stringFromDate:inFormat: The format string must not be nil!");
    NSAssert(date != nil, @"stringFromDate:inFormat: The input date must not be nil!");
    
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
 * @name   getSecZeroedDatabaseStringForDate:(NSDate *)dateToBeConverted
 *
 * @author Anoop
 *
 * @brief  Returns a string representation of a given date formatted via `strftime_l()` using the receiver’s current settings.
 *
 * \par
 *   By default class internally will use  "%Y-%m-%dT%H:%M:00.000%z" format
 *
 *
 * @param  date The date to format.
 *
 * @return A string representation of *date* formatted via `strftime_l()` using the receiver’s current settings.
 *
 */

+ (NSString *)getSecZeroedDatabaseStringForDate:(NSDate *)dateToBeConverted
{
    @synchronized(self)
    {
        char *tz;
        //Get current time zone
        tz = getenv("TZ");
        //Set zone to GMT
        setenv("TZ", "GMT", 1);
        tzset();
        
        NSString *result = [self stringFromDate:dateToBeConverted inFormat:@"%Y-%m-%dT%H:%M:00.000%z"];
        
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
    
    
    if ((dateString != NULL)||(dateString != nil))
    {

        return [self dateFromString:dateString inFormat:kDateFormatForDatabase];
      


    }
    return nil;
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
    NSString *timeString = nil;//[self stringFromDate:date inFormat:kDateFormatType6];
    if ([self iSDeviceTime24HourFormat])
    {
        timeString = [NSDate stringTimeOfDate:date];
    }
    else
    {
        timeString = [NSDate stringTime12hrDate:date];
    }
    
    if ([date isToday]) {
        //Today
        datePrefix = [[TagManager sharedInstance] tagByName:kTag_Today];
    } else if([date isTomorrow]) {
        //Tomorrow
        datePrefix = [[TagManager sharedInstance] tagByName:kTag_Tomorrow];
    } else if([date isYesterday]) {
        //Yesterday
        datePrefix = [[TagManager sharedInstance] tagByName:kTag_Yesterday];
    } else {
        datePrefix = [NSDate localDateTimeStringFromDate:date inFormat:kDateFormatType7];//[self stringFromDate:date inFormat:kDateFormatType7];
    }
    dateInString = [NSString stringWithFormat:@"%@ %@",datePrefix,[timeString lowercaseString]];
    return dateInString;
}


+ (NSString *)getLiteralSupported12Hr_24HrDateStringForDate:(NSDate *)date {
    
    NSString * dateInString = nil;
    NSString *datePrefix = nil;
    NSString *timeString = @"";
    if ([self iSDeviceTime24HourFormat])
    {
        timeString = [NSDate stringTimeOfDate:date];
    }
    else
    {
        timeString = [NSDate stringTime12hrDate:date];
    }
    
    if ([date isToday]) {
        //Today
        datePrefix = [[TagManager sharedInstance] tagByName:kTag_Today];
    } else if([date isTomorrow]) {
        //Tomorrow
        datePrefix = [[TagManager sharedInstance] tagByName:kTag_Tomorrow];
    } else if([date isYesterday]) {
        //Yesterday
        datePrefix = [[TagManager sharedInstance] tagByName:kTag_Yesterday];
    } else {
        datePrefix = [NSDate localDateTimeStringFromDate:date inFormat:kDateFormatType7];
        //[self stringFromDate:date inFormat:kDateFormatType7];
    }
    
    dateInString = [NSString stringWithFormat:@"%@ %@",datePrefix,[timeString lowercaseString]];
    return dateInString;
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
 *  Eg "Today"
 *
 *
 * @param date The date to format.
 *
 * @return A string representation of date formatted via `strftime_l()`.
 *
 */

+ (NSString *)getLiteralSupportedDateOnlyStringForDate:(NSDate *)date {
    
    NSString * dateInString = nil;
    NSString *datePrefix = nil;
    if ([date isToday]) {
        //Today
        datePrefix = [[TagManager sharedInstance] tagByName:kTag_Today];
    } else if([date isTomorrow]) {
        //Tomorrow
        datePrefix = [[TagManager sharedInstance] tagByName:kTag_Tomorrow];
    } else if([date isYesterday]) {
        //Yesterday
        datePrefix = [[TagManager sharedInstance] tagByName:kTag_Yesterday];
    } else {
        datePrefix = [NSDate localDateTimeStringFromDate:date inFormat:kDateFormatType5];
    }
    dateInString = datePrefix;
    return dateInString;
}



+ (NSString *)getUserReadableDateForSyncStatus:(NSDate *)date {
    
    NSString * dateInString = nil;
  
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    
    NSString *datePrefix = nil;
    if([date isToday])
    {
        [formatter setDateFormat:@"hh:mm a"];
        datePrefix = [[TagManager sharedInstance]tagByName:kTag_Today];
        //datePrefix = [[SMXTagsManager sharedTagManager]getTagForId:Tag_Today];;
    }
    else if([date isTomorrow])
    {
        [formatter setDateFormat:@"hh:mm a"];
        datePrefix = [[TagManager sharedInstance]tagByName:kTag_Tomorrow];

        //datePrefix = [[SMXTagsManager sharedTagManager]getTagForId:Tag_Tomorrow];;
    }
    else if([date isYesterday])
    {
        [formatter setDateFormat:@"hh:mm a"];
        datePrefix = [[TagManager sharedInstance]tagByName:kTag_Yesterday];

        //datePrefix = [[SMXTagsManager sharedTagManager]getTagForId:CHATTER_YESTERDAY];;
    }
    else
    {
        [formatter setDateFormat:@"EEE"];
        NSString *dateString = [formatter stringFromDate:date];
        
        NSCalendar*       calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents* components = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:date];
        NSInteger         day = [components day];
        NSInteger         month = [components month];
        NSInteger         year = [components year];
        
        NSString *monthStr = [NSString stringWithFormat:@". %d/%d/%d - ",(int)day, (int)month, (int)year];
        dateString = [dateString stringByAppendingString:monthStr];

        datePrefix = dateString;
    }

    if([self iSDeviceTime24HourFormat]) /* Defect 012688 , condition check to handle 24hr / 12hr format */
    {
        formatter.dateFormat = @"HH:mm";
    }else
    {
        formatter.dateFormat = @"hh:mm a";
        [formatter setAMSymbol:@"am"];
        [formatter setPMSymbol:@"pm"];
    }

    
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
    /*
     NSString *userdateString = nil;
     
     if ([dateString length] > 0){
     
     NSDate * date = [self getDateFromDatabaseString:dateString];
     if (date != nil) {
     userdateString = [self stringFromDate:date inFormat:[self getUserTimeFormat]];
     }
     }
     return userdateString;
     */
    //Anoop : 019268 017148 018047
    return [NSDate localDateTimeStringFromDate:[DateUtil getUserReadableDateForDateBaseDateString:dateString]];
    
}

+(NSString *)getUserTimeFormat
{
    NSString *dateFormat;
    if ([self iSDeviceTime24HourFormat]) {
        dateFormat = kDateFormatType3;
    }
    else{
        dateFormat = kDateFormatType12Hr;
    }
    return dateFormat;
}

+(NSString *)getSecsZeroedUserTimeFormat
{
    NSString *dateFormat;
    if ([self iSDeviceTime24HourFormat]) {
        dateFormat = @"%a, %d %b %Y %H:%M:00";
    }
    else{
        dateFormat = @"%a, %d %b %Y %I:%M:00 %p";
    }
    return dateFormat;
}

+ (NSString *)getUserReadableDateForDBDateTime:(NSString *)dateTime
{
    NSString *dateString = nil;
    NSDate * date = [DateUtil dateFromString:dateTime inFormat:kDateFormatDefault];
    if (date != nil) {
        dateString = [NSDate localDateTimeStringFromDate:date inFormat:kDateFormatForSFMEdit];//[DateUtil stringFromDate:date inFormat:kDateFormatForSFMEdit];
    }
    return dateString;
}


+(NSDate *)getUserReadableDateForDateBaseDateString:(NSString *)dateString
{
    if ([dateString length] > 0){
        NSDate * date = [self getDateFromDatabaseString:dateString];
        return date;
    }
    return nil;
}

+ (NSString *)getDateStringForDBDateTime:(NSString *)dateTime inFormat:(NSString*)format
{
    NSString *dateString = nil;
    NSDate * date = [DateUtil dateFromString:dateTime inFormat:kDateFormatDefault];
    if (date != nil) {
        dateString = [DateUtil stringFromDate:date inFormat:format];
    }
    return dateString;
}

+(NSString *)getUserReadableDateForGMT:(NSDate *)date
{
    NSString *userdateString = nil;
    
    if (date != nil){
        userdateString = [self stringFromDate:date inFormat:[self getUserTimeFormat]];
    }
    return userdateString;
    
}

+(NSString *)getSecZeroedUserReadableDateForGMT:(NSDate *)date
{
    NSString *userdateString = nil;
    
    if (date != nil){
        userdateString = [self stringFromDate:date inFormat:[self getSecsZeroedUserTimeFormat]];
    }
    return userdateString;
    
}

+ (NSDate *)dateWithOutTime:(NSDate *)datDate{
    if( datDate == nil ) {
        datDate = [NSDate date];
    }
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:datDate];
    [comps setHour:00];
    [comps setMinute:00];
    [comps setSecond:00];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

+(NSString *)evaluateDateLiteral:(NSString *)literal  dataType:(NSString *)dataType
{
    NSDate * date = [DateUtil getDateForLiteral:literal];
    NSString * dateInString = @"";
    if (date != nil) {
        dateInString = [self getDatabaseStringForDate:date];
    }
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
        date = nil; //021790
        
    }
    
    return date;
}

+(NSString *)getDateFormateForDataType:(NSString *)dataType
{
    NSString *format = nil;
    if([dataType isEqualToString:kSfDTDateTime])
    {
        format = [self getUserTimeFormat];
    }
    else   if([dataType isEqualToString:kSfDTDate])
    {
        format = kDateFormatForSFMEdit;
    }
    return format;
}

+(int )toLocalTime:(NSDate *)currentdate
{
    NSTimeZone *tz;
    tz = [NSTimeZone localTimeZone];
    int seconds = 0;//(int)[tz secondsFromGMTForDate:currentdate];
    return seconds;
    //return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

+ (NSString *)getLocalTimeFromGMT:(NSString *)gmtDate
{
    
    //NSDate *gmtDateTime = [self dateFromString:gmtDate inFormat:kDateFormatDefault]; // only for nonDaylight//Previous code before Fix
    
    //Defect Fix:032530
    NSDate *gmtDateTime;
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    BOOL isDayLightTimeZone = [localTimeZone isDaylightSavingTime];
      if(isDayLightTimeZone)
       {
           if ((gmtDate != NULL) || (gmtDate != nil))
           {
               gmtDateTime = [self dateFromStringForDaylightTimeZone:gmtDate];

           }
         }
        else{
        gmtDateTime = [self dateFromString:gmtDate inFormat:kDateFormatDefault]; // only for nonDaylight

    }
    
    
    
    NSDate *localDateTime = [self localDateForGMTDate:gmtDateTime];
    NSString *localDateTimeStr = [self stringFromDate:localDateTime inFormat:kDateFormatDefault];
    return localDateTimeStr;
}



+ (NSDate *)localDateForGMTDate:(NSDate *)dateInGMT
{
   NSDate *localDateTime = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT]
                                              sinceDate:dateInGMT]; 
  
    
    //HS 21Jul
    /*
    
    NSDate *localDateTime;
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    BOOL isDayLightTimeZone = [localTimeZone isDaylightSavingTime];
    if (isDayLightTimeZone)
    {
        NSTimeZone *daylightoffset = [NSTimeZone timeZoneForSecondsFromGMT:[localTimeZone daylightSavingTimeOffset]];
        
        localDateTime = [NSDate dateWithTimeInterval:[daylightoffset secondsFromGMT] sinceDate:dateInGMT];
    }
    else
    {
        localDateTime = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT]
                                           sinceDate:dateInGMT];
    }
     */
    
    
   
    return localDateTime;
}


+ (NSDate *)getLocalTimeFromDateBaseDate:(NSString *)date
{
    NSDate *gmtDateTime = [self dateFromString:date inFormat:kDateFormatDefault];
    return  [self localDateForGMTDate:gmtDateTime];
}

/*Chatter*/

+ (NSString *)getLiteralSupportedDateStringForChatterDate:(NSDate *)date {
    
    NSString * dateInString = nil;
    NSString *datePrefix = nil;
    NSString *timeString = nil;//[self stringFromDate:date inFormat:kDateFormatType6];
    if ([self iSDeviceTime24HourFormat])
    {
        timeString = [NSDate stringTimeOfDate:date];
    }
    else
    {
        timeString = [NSDate stringTime12hrDate:date];
    }
    if ([date isToday]) {
        datePrefix = [[TagManager sharedInstance] tagByName:kTag_Today];
    } else if([date isTomorrow]) {
        datePrefix = [[TagManager sharedInstance] tagByName:kTag_Tomorrow];
    } else if([date isYesterday]) {
        datePrefix = [[TagManager sharedInstance] tagByName:kTag_Yesterday];
    } else {
        datePrefix = [NSDate localDateTimeStringFromDate:date inFormat:kDateFormatType8];//[self stringFromDate:date inFormat:kDateFormatType8];
    }
    if ([datePrefix rangeOfString:@","].location == NSNotFound) {
        dateInString = [NSString stringWithFormat:@"%@, %@",datePrefix,timeString];
    }
    else {
        dateInString = [NSString stringWithFormat:@"%@ %@",datePrefix,timeString];
    }
    // dateInString = [NSString stringWithFormat:@"%@ %@",datePrefix,timeString];
    return dateInString;
}

//For DateTime
+ (NSString*)getLocalDateForGetpriceFromDateString:(NSString*)date
{
    // NSString *date = @"Sun, 09 Mar 2015 12:00:52 AM"; //@"2015-03-08 06:00:09";
    NSString *localDateInString = nil;
    NSDate *dateTime = nil;
    
    if (date != nil) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
        if([self iSDeviceTime24HourFormat])
        {
            [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:kFormulaDateTimeUserReadable24Hr options:0 locale:[NSLocale currentLocale]]];
        }
        else
        {
            [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:kFormulaDateTimeUserReadable12Hr options:0 locale:[NSLocale currentLocale]]];
        }
        dateTime = [dateFormatter dateFromString:date];
        
        NSDateFormatter *dateFormatterTwo = [[NSDateFormatter alloc] init];
        [dateFormatterTwo setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
        [dateFormatterTwo setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [dateFormatterTwo setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        localDateInString = [dateFormatterTwo stringFromDate:dateTime];
        return localDateInString;
    }
    return nil;
}



#pragma mark - GE formula

+(NSString *)getFormulaDateFromGMTDate:(NSString *)dateInGMT isDateWithTime:(BOOL)isDateWithTime {
    NSString *dateInDeviceTimeZone = @"";
    if (![StringUtil isStringEmpty:dateInGMT]) {
        dateInDeviceTimeZone = (isDateWithTime)?[DateUtil getUserReadableDateForDateBaseDate:dateInGMT]:[DateUtil getUserReadableDateForDBDateTime:dateInGMT];
        
        NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
        NSDateComponents * dateComponents = [DateUtil getDateComponents];
        //Defect Fix :027062 HS 11Feb2015
        [dateformatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale currentLocale]localeIdentifier]]];
        //ends here
         
        
        [dateformatter setTimeZone:[dateComponents timeZone]];
        
        NSString *dateFormat = @"";
        if (isDateWithTime) {
            dateFormat = ([DateUtil iSDeviceTime24HourFormat])?kFormulaDateTimeUserReadable24Hr:kFormulaDateTimeUserReadable12Hr;
        }
        else {
            dateFormat = kFormulaDateUserReadable;
        }
        
        [dateformatter setDateFormat:dateFormat];
        NSDate *date = [dateformatter dateFromString:dateInDeviceTimeZone];
        dateFormat = (isDateWithTime)?kFormulaDateTimeForModule:kFormulaDateForModule;
        [dateformatter setDateFormat:dateFormat];
        dateInDeviceTimeZone = [dateformatter stringFromDate:date];
    }
    return dateInDeviceTimeZone;
}


+(NSString *)getGMTDateFromFormulaDate:(NSString *)formulaDate isDateWithTime:(BOOL)isDateWithTime {
    NSString *gmtDate = @"";
    if (![StringUtil isStringEmpty:formulaDate]) {
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        NSString *dateFormat = (isDateWithTime)?kFormulaDateTimeForModule:kFormulaDateForModule;
        [dateFormatter setDateFormat:dateFormat];
        
        //Defect Fix :027062 HS 12Feb2015
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale currentLocale]localeIdentifier]]];
         NSDateComponents * dateComponents = [DateUtil getDateComponents];
        [dateFormatter setTimeZone:[dateComponents timeZone]];
        
        //ends here
        

        NSDate *date = [dateFormatter dateFromString:formulaDate];
        if(date != nil) {
            gmtDate = (isDateWithTime)?[DateUtil getSecZeroedDatabaseStringForDate:date]:[DateUtil stringFromDate:date inFormat:kDataBaseDate];
        }
        else {
            if (!isDateWithTime) {
                [dateFormatter setDateFormat:kFormulaDateTimeForModule];
                date = [dateFormatter dateFromString:formulaDate];
            }
            else {
                [dateFormatter setDateFormat:kFormulaDateForModule];
                date = [dateFormatter dateFromString:formulaDate];
            }
            
            if(date != nil) {
                gmtDate = (isDateWithTime)?[DateUtil getSecZeroedDatabaseStringForDate:date]:[DateUtil stringFromDate:date inFormat:kDataBaseDate];
            }
        }
    }
    return gmtDate;
}


+ (NSDateComponents *)getDateComponents {
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitTimeZone;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents * dateComponents = [gregorian components:unitFlags fromDate:[NSDate date]];
    return dateComponents;
}

#pragma mark - Sync Profiling

+(NSString *)getCurrentDateForSyncProfiling {
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [dateformatter setDateFormat:kSyncProfileDateFormat];
    [dateformatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    NSString *currentDate = [dateformatter stringFromDate:[NSDate date]];
    return currentDate;
}

@end

