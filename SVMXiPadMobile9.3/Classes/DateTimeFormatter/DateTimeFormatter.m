//
//  DateTimeFormatter.m
//  iService
//
//  Created by Samman Banerjee on 27/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DateTimeFormatter.h"
#import "iOSInterfaceObject.h"

@implementation DateTimeFormatter

- (NSString *) getReadableDateFromDate:(NSString *)_date
{
    _date = [_date stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    _date = [_date stringByReplacingOccurrencesOfString:@"Z" withString:@" "];
    // Trime date from the end to remove fractional component of second yyyy-MM-dd HH:mm:ss.000
    _date = [_date stringByDeletingPathExtension];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * thisDate = [dateFormatter dateFromString:_date];
    [dateFormatter setDateStyle:kCFDateFormatterFullStyle];
    // NSString * date = [dateFormatter stringFromDate:thisDate];
    
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDateComponents * components = nil;
    
    if ([_date length] > 10)
        components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:thisDate];
    else
        components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:thisDate];
    
    [dateFormatter release];
    
    return [self getFormattedDateFromComponents:components];
}

- (NSString *) getReadableDateFromLongDateString:(NSString *)_date
{
    NSDateFormatter * _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * thisDate = [_dateFormatter dateFromString:_date];
    [_dateFormatter setDateStyle:kCFDateFormatterFullStyle];
    
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDateComponents * components = nil;
    
    if ([_date length] > 10)
        components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:thisDate];
    else
        components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:thisDate];
    
    [_dateFormatter release];
    
    NSString * longDateString = [self getFormattedDateFromComponents:components];
    
    NSString * timeString = [_date substringFromIndex:11];
    NSArray * timeComponents = [timeString componentsSeparatedByString:@":"];
    if ([[timeComponents objectAtIndex:0] intValue] > 12)
        timeString = [NSString stringWithFormat:@"%d:%@:%@ PM", [[timeComponents objectAtIndex:0] intValue]-12, [timeComponents objectAtIndex:1], [timeComponents objectAtIndex:2]];
    else if ([[timeComponents objectAtIndex:0] intValue] == 0)
    {
        timeString = [NSString stringWithFormat:@"12:%@:%@ AM", [timeComponents objectAtIndex:1], [timeComponents objectAtIndex:2]];
    }
    else if ([[timeComponents objectAtIndex:0] intValue] < 12 && [[timeComponents objectAtIndex:0] intValue] > 0)
        timeString = [NSString stringWithFormat:@"%d:%@:%@ AM", [[timeComponents objectAtIndex:0] intValue], [timeComponents objectAtIndex:1], [timeComponents objectAtIndex:2]];
    else
        timeString = [NSString stringWithFormat:@"%d:%@:%@ PM", [[timeComponents objectAtIndex:0] intValue], [timeComponents objectAtIndex:1], [timeComponents objectAtIndex:2]];
    
    longDateString = [longDateString stringByAppendingFormat:@" %@", timeString];
    
    return longDateString;
}

- (NSString *) getReadableDateFromShortDateString:(NSString *)_date
{
    NSDateFormatter * _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * thisDate = [_dateFormatter dateFromString:_date];
    [_dateFormatter setDateStyle:kCFDateFormatterFullStyle];
    
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDateComponents * components = nil;
    
    if ([_date length] > 10)
        components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:thisDate];
    else
        components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:thisDate];
    
    [_dateFormatter release];
    
    return [self getFormattedDateFromComponents:components];
}

- (NSString *) getFormattedDateFromComponents:(NSDateComponents *)components
{
    NSString * weekDay = [self getWeekDayForIndex:[components weekday]];
    NSString * month = [self getMonthForIndex:[components month]];
    
    return [NSString stringWithFormat:@"%@, %d %@ %d", weekDay, [components day], month, [components year]];
}

- (NSString *) getWeekDayForIndex:(NSUInteger)index
{
    switch (index) {
        case 1:
            return @"Sun";
        case 2:
            return @"Mon";
        case 3:
            return @"Tue";
        case 4:
            return @"Wed";
        case 5:
            return @"Thu";
        case 6:
            return @"Fri";
        case 7:
            return @"Sat";
        default:
            break;
    }
    return @"";
}

- (NSString *) getMonthForIndex:(NSUInteger)index
{
    switch (index) {
        case 1:
            return @"Jan";
        case 2:
            return @"Feb";
        case 3:
            return @"Mar";
        case 4:
            return @"Apr";
        case 5:
            return @"May";
        case 6:
            return @"Jun";
        case 7:
            return @"Jul";
        case 8:
            return @"Aug";
        case 9:
            return @"Sep";
        case 10:
            return @"Oct";
        case 11:
            return @"Nov";
        case 12:
            return @"Dec";
        default:
            break;
    }
    return @"";
}

@end
