//
//  DateUtil.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/21/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//
/**
 *  @file   DateUtil.h
 *  @class  DateUtil
 *
 *  @brief  This contains utilitiy methods related to date and date formatting
 *
 *  \par
 *      This contains utilitiy methods related to date and date formatting
 *
 *
 *  The conversion specifications are as follows:-
 *
 *  %A    is replaced by national representation of the full weekday name.
 *
 *  %a    is replaced by national representation of the abbreviated weekday name.
 *
 *  %B    is replaced by national representation of the full month name.
 *
 *  %b    is replaced by national representation of the abbreviated month name.
 *
 *  %C    is replaced by (year / 100) as decimal number; single digits are preceded by a zero.
 *
 *  %c    is replaced by national representation of time and date.
 *
 *  %D    is equivalent to ``%m/%d/%y''.
 *
 *  %d    is replaced by the day of the month as a decimal number (01-31).
 *
 *  %E* %O*
 *  POSIX locale extensions.  The sequences %Ec %EC %Ex %EX %Ey %EY %Od %Oe %OH %OI %Om %OM %OS %Ou
 *  %OU %OV %Ow %OW %Oy are supposed to provide alternate representations.
 
 ****
 Additionally %OB implemented to represent alternative months names (used standalone, without day
 mentioned).
 
 %e    is replaced by the day of the month as a decimal number (1-31); single digits are preceded by a
 blank.
 
 %F    is equivalent to ``%Y-%m-%d''.
 
 %G    is replaced by a year as a decimal number with century.  This year is the one that contains the
 greater part of the week (Monday as the first day of the week).
 
 %g    is replaced by the same year as in ``%G'', but as a decimal number without century (00-99).
 
 %H    is replaced by the hour (24-hour clock) as a decimal number (00-23).
 
 %h    the same as %b.
 
 %I    is replaced by the hour (12-hour clock) as a decimal number (01-12).
 
 %j    is replaced by the day of the year as a decimal number (001-366).
 
 %k    is replaced by the hour (24-hour clock) as a decimal number (0-23); single digits are preceded by
 a blank.
 
 %l    is replaced by the hour (12-hour clock) as a decimal number (1-12); single digits are preceded by
 a blank.
 
 %M    is replaced by the minute as a decimal number (00-59).
 
 %m    is replaced by the month as a decimal number (01-12).
 
 %n    is replaced by a newline.
 
 %O*   the same as %E*.
 
 %p    is replaced by national representation of either "ante meridiem" (a.m.)  or "post meridiem"
 (p.m.)  as appropriate.
 
 %R    is equivalent to ``%H:%M''.
 
 %r    is equivalent to ``%I:%M:%S %p''.
 
 %S    is replaced by the second as a decimal number (00-60).
 
 %s    is replaced by the number of seconds since the Epoch, UTC (see mktime(3)).
 
 %T    is equivalent to ``%H:%M:%S''.
 
 %t    is replaced by a tab.
 
 %U    is replaced by the week number of the year (Sunday as the first day of the week) as a decimal
 number (00-53).
 
 %u    is replaced by the weekday (Monday as the first day of the week) as a decimal number (1-7).
 
 %V    is replaced by the week number of the year (Monday as the first day of the week) as a decimal
 number (01-53).  If the week containing January 1 has four or more days in the new year, then it
 is week 1; otherwise it is the last week of the previous year, and the next week is week 1.
 
 %v    is equivalent to ``%e-%b-%Y''.
 
 %W    is replaced by the week number of the year (Monday as the first day of the week) as a decimal
 number (00-53).
 
 %w    is replaced by the weekday (Sunday as the first day of the week) as a decimal number (0-6).
 
 %X    is replaced by national representation of the time.
 
 %x    is replaced by national representation of the date.
 
 %Y    is replaced by the year with century as a decimal number.
 
 %y    is replaced by the year without century as a decimal number (00-99).
 
 %Z    is replaced by the time zone name.
 
 %z    is replaced by the time zone offset from UTC; a leading plus sign stands for east of UTC, a minus
 sign for west of UTC, hours and minutes follow with two digits each and no delimiter between them
 (common form for RFC 822 date headers).
 
 %+    is replaced by national representation of the date and time (the format is similar to that pro-duced produced
 duced by date(1)).
 
 %-*   GNU libc extension.  Do not do any padding when performing numerical outputs.
 
 %_*   GNU libc extension.  Explicitly specify space for padding.
 
 %0*   GNU libc extension.  Explicitly specify zero for padding.
 
 %%    is replaced by `%'.
 
 
 Few examples are below.
 
 %Y%m%d           => 20071119                  Calendar date (basic)
 %F               => 2007-11-19                Calendar date (extended)
 %Y-%m            => 2007-11                   Calendar date, reduced accuracy, specific month
 %Y               => 2007                      Calendar date, reduced accuracy, specific year
 %C               => 20                        Calendar date, reduced accuracy, specific century
 %Y%j             => 2007323                   Ordinal date (basic)
 %Y-%j            => 2007-323                  Ordinal date (extended)
 %GW%V%u          => 2007W471                  Week date (basic)
 %G-W%V-%u        => 2007-W47-1                Week date (extended)
 %GW%V            => 2007W47                   Week date, reduced accuracy, specific week (basic)
 %G-W%V           => 2007-W47                  Week date, reduced accuracy, specific week (extended)
 %H%M%S           => 083748                    Local time (basic)
 %T               => 08:37:48                  Local time (extended)
 %H%M             => 0837                      Local time, reduced accuracy, specific minute (basic)
 %H:%M            => 08:37                     Local time, reduced accuracy, specific minute (extended)
 %H               => 08                        Local time, reduced accuracy, specific hour
 %H%M%S,%L        => 083748,000                Local time with decimal fraction, comma as decimal sign (basic)
 %T,%L            => 08:37:48,000              Local time with decimal fraction, comma as decimal sign (extended)
 %H%M%S.%L        => 083748.000                Local time with decimal fraction, full stop as decimal sign (basic)
 %T.%L            => 08:37:48.000              Local time with decimal fraction, full stop as decimal sign (extended)
 %H%M%S%z         => 083748-0600               Local time and the difference from UTC (basic)
 %T%:z            => 08:37:48-06:00            Local time and the difference from UTC (extended)
 %Y%m%dT%H%M%S%z  => 20071119T083748-0600      Date and time of day for calendar date (basic)
 %FT%T%:z         => 2007-11-19T08:37:48-06:00 Date and time of day for calendar date (extended)
 %Y%jT%H%M%S%z    => 2007323T083748-0600       Date and time of day for ordinal date (basic)
 %Y-%jT%T%:z      => 2007-323T08:37:48-06:00   Date and time of day for ordinal date (extended)
 %GW%V%uT%H%M%S%z => 2007W471T083748-0600      Date and time of day for week date (basic)
 %G-W%V-%uT%T%:z  => 2007-W47-1T08:37:48-06:00 Date and time of day for week date (extended)
 %Y%m%dT%H%M      => 20071119T0837             Calendar date and local time (basic)
 %FT%R            => 2007-11-19T08:37          Calendar date and local time (extended)
 %Y%jT%H%MZ       => 2007323T0837Z             Ordinal date and UTC of day (basic)
 %Y-%jT%RZ        => 2007-323T08:37Z           Ordinal date and UTC of day (extended)
 %GW%V%uT%H%M%z   => 2007W471T0837-0600        Week date and local time and difference from UTC (basic)
 *       %G-W%V-%uT%R%:z  => 2007-W47-1T08:37-06:00    Week date and local time and difference from UTC (extended)
 *
  // PCRD-220
 *
 *
 *  @author  Vipindas Palli
 *  @author  Pushpak N
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <Foundation/Foundation.h>

static NSString *kDateFormatDefault = @"%Y-%m-%dT%H:%M:%S%z";    /** 2014-05-18T16:36:20+0530 */
static NSString *kDateFormatType1   = @"%Y-%m-%d %H:%M:%S";      /** 2014-05-18 16:36:20 */
static NSString *kDateFormatType2   = @"%d %b %Y %H:%M:%S";      /** 18 May 2014 16:36:20 */
static NSString *kDateFormatType3   = @"%a, %d %b %Y %H:%M:%S";  /** Sun, 19 May 2002 15:21:36 */
static NSString *kDateFormatType4   = @"%Y-%m-%dT%H:%M:%S";      /** Sun, 18 May 2014 16:36:20 */
static NSString *kDateFormatType5   = @"EEE, dd MMM yyyy";  //ANOOP 017148: @"%a, %d %b %Y";/** Sun, 18 May 2014 **/
static NSString *kDateFormatType6   = @"%I:%M %p";               /** 8:36 PM **/
static NSString *kDateFormatType7   = @"EEE. MM/dd/yyyy"; //ANOOP 017148: @"%a. %m/%d/%Y  -";         /** Wed. 10/22/2014  -*/
static NSString *kDateFormatType9   = @"%Y-%m-%d %H:%M:%S %z";      /** 2014-05-18 16:36:20 +0530*/

static NSString *kDateFormatType12Hr   = @"%a, %d %b %Y %r";

static NSString *kDateFormatTypeOnlyDate = @"%Y-%m-%d";    /** 2014-05-18*/

static NSString *kDateFormatType8 = @"MMMM dd, yyyy";  //ANOOP 017148:@"%b %d, %Y"; /**March 23, 2014 */

static NSString *kDateFormatForSFMEdit = @"MMMM dd yyyy";  //ANOOP 017148:@"%b %d %Y"; /**March 23 2014 */

static NSString *kDataBaseDate = @"%Y-%m-%d";

static NSString *kDateAttachment = @"%m/%d/%Y";

static NSString *kDateImagesAndVideosAttachment = @"%m-%d-%Y";

static NSString *kDateFormatType24Hr  = @"%H:%M";

//RS-7606
static NSString *kFormulaDateTimeUserReadable24Hr = @"EEE MMM dd, yyyy HH:mm";
static NSString *kFormulaDateTimeUserReadable12Hr = @"EEE MMM dd, yyyy hh:mm a";

static NSString *kFormulaDateUserReadable = @"MMMM dd yyyy";
static NSString *kFormulaDateTimeForModule = @"yyyy-MM-dd HH:mm:ss";
static NSString *kFormulaDateForModule = @"yyyy-MM-dd";

/** Sync Profiling **/

static NSString *kSyncProfileDateFormat = @"YYYY-MM-dd HH:mm:ss.SSS";

@interface DateUtil : NSObject

+ (NSDateFormatter *)dateFormatter;

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

+ (NSDate *)dateFromString:(NSString *)string inFormat:(NSString *)format;


//Method for returning DateTime for DaylightTime Zone
+ (NSDate *)dateFromStringForDaylightTimeZone:(NSString *)gmtDate;



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

+ (NSString *)stringFromDate:(NSDate *)date inFormat:(NSString *)format;


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

+ (NSString *)gmtStringFromDate:(NSDate *)date inFormat:(NSString *)format;


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

+ (NSString *)getDatabaseStringForDate:(NSDate *)dateToBeConverted;

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

+ (NSString *)getSecZeroedDatabaseStringForDate:(NSDate *)dateToBeConverted;

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

+ (NSDate *)getDateFromDatabaseString:(NSString *)dateString;


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

+ (NSString *)currentGMTTimeInFormat:(NSString *)format;

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

+ (NSString *)currentLocalTimeInFormat:(NSString *)format;

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
+ (NSString *)getLiteralSupportedDateStringForDate:(NSDate *)date;
+ (NSString *)getLiteralSupported12Hr_24HrDateStringForDate:(NSDate *)date;
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

+ (NSString *)getLiteralSupportedDateOnlyStringForDate:(NSDate *)date;

/**
 * @name   getUserReadableDateForSyncStatus:(NSString *)format
 *
 * @author Himanshi Sharma
 *
 * @brief  Returns a string representation of NSdate passed using the receiver’s current settings.
 *
 *
 * @param  date The date to format.
 *
 * @return A string representation of date formatted  using the receiver’s current settings.
 *
 */
+ (NSString *) getUserReadableDateForSyncStatus:(NSDate *)date ;

/**
 * @name   iSDeviceTime24HourFormat
 *
 * @author Radha S
 *
 * @brief  Returns BOOL value, which conforms device time format
 *
 *
 * @param none
 *
 * @return A BOOL value which represent time format
 *
 */
+(BOOL)iSDeviceTime24HourFormat;


/**
 * @name   getUserReadableDateForDateBaseDate
 *
 * @author Radha S
 *
 * @brief  Returns the datestring with user readable format
 *
 *
 * @param none
 *
 * @return A datestring  with user readable format
 *
 */
+(NSString *)getUserReadableDateForDateBaseDate:(NSString *)dateString;

/**
 * @name   getUserTimeFormat
 *
 * @author Anoop
 *
 * @brief  Returns the datestring in 12 hr or 24 hr based on usertime settings
 *
 *
 * @param none
 *
 * @return A datestring  with user readable format
 *
 */
+(NSString *)getUserTimeFormat;

/**
 * @name   getUserReadableDateForGMT
 *
 * @author Radha S
 *
 * @brief  Returns the datestring with user readable format
 *
 *
 * @param none
 *
 * @return A datestring  with user readable format
 *
 */
+(NSString *)getUserReadableDateForGMT:(NSDate *)date;

/**
 * @name   getSecZeroedUserReadableDateForGMT
 *
 * @author Anoopsaai Ramani
 *
 * @brief  Returns the datestring with user readable format with seconds always zeroed
 *
 *
 * @param none
 *
 * @return A datestring  with user readable format
 *
 */
+(NSString *)getSecZeroedUserReadableDateForGMT:(NSDate *)date;

/**
 * @name  <getUserReadableDate>
 *
 * @author Krishna Shanbhag
 *
 *
 * \par
 *  < Date time to date >
 *
 *
 * @param  dateTime
 * Date time represented in DB
 * @param  ...
 *
 * @return Date string
 *
 */
+ (NSString *)getUserReadableDateForDBDateTime:(NSString *)dateTime;

+(NSDate *)getDateForLiteral:(NSString *)literal;

+(NSString *)evaluateDateLiteral:(NSString *)literal  dataType:(NSString *)dataType;

+(int )toLocalTime:(NSDate *)currentdate;

+ (NSString *)getDateStringForDBDateTime:(NSString *)dateTime inFormat:(NSString*)format;
+ (NSString *)getLocalTimeFromGMT:(NSString *)gmtDate;
+ (NSDate *)localDateForGMTDate:(NSDate *)dateInGMT;

+ (NSString *)getLiteralSupportedDateStringForChatterDate:(NSDate *)date;

+ (NSDate *)getLocalTimeFromDateBaseDate:(NSString *)date;

+ (NSDate *)getUserReadableDateForDateBaseDateString:(NSString *)dateString;

+ (NSString*)getLocalDateForGetpriceFromDateString:(NSString*)date;


#pragma mark - GE formula related

+(NSString *)getFormulaDateFromGMTDate:(NSString *)dateInGMT isDateWithTime:(BOOL)isDateWithTime;
+(NSString *)getGMTDateFromFormulaDate:(NSString *)formulaDate isDateWithTime:(BOOL)isDateWithTime;

#pragma mark - end

#pragma mark - Sync Profiling

+(NSString *)getCurrentDateForSyncProfiling;

@end

