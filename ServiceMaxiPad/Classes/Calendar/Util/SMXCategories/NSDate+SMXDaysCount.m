//
//  NSDate+SMXDaysCount.m
/**
 *  @file   FILE_NAME.m
 *  @class  CLASS_NAME
 *
 *  @brief  This class will provide .....
 *
 *
 *
 *  @author  AUTHOR_NAME
 *
 *  @bug     No known bugs
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "NSDate+SMXDaysCount.h"
#import "SMXImportantFilesForCalendar.h"
#import "StringUtil.h"
#import "TagManager.h"
#import "DateUtil.h"

@implementation NSDate (SMXDaysCount)

-(NSDate*)lastDayOfMonth {
    
    NSInteger dayCount = [self numberOfDaysInMonthCount];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSDateComponents *comp = [calendar components:
                              NSYearCalendarUnit |
                              NSMonthCalendarUnit |
                              NSDayCalendarUnit fromDate:self];
    
    [comp setDay:dayCount];
    
    return [calendar dateFromComponents:comp];
}

-(NSInteger)numberOfDaysInMonthCount {
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
//    [calendar setTimeZone:[NSTimeZone timeZoneWithName:TIMEZONE]];
    
    NSRange dayRange = [calendar rangeOfUnit:NSDayCalendarUnit
                                      inUnit:NSMonthCalendarUnit
                                     forDate:self];
    
    return dayRange.length;
}

/*- (NSInteger)numberOfWeekInMonthCount {
    
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSRange weekRange = [calender rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:self];
    return weekRange.length;
}*/
- (NSInteger)numberOfWeekInMonthCount {
    
    //NSCalendar *calender = [NSCalendar currentCalendar];
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];//this change for country's region
    NSRange weekRange = [calender rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:self];
    return weekRange.length;
}

- (NSDateComponents *)componentsOfDate{
    //Time zone change for weekview
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //NSCalendar *calender = [NSCalendar currentCalendar];
    return [calender components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday | NSHourCalendarUnit |
            NSMinuteCalendarUnit fromDate:self];
}

#pragma mark - Methods Statics

+ (NSDateComponents *)componentsOfCurrentDate {
    
    return [NSDate componentsOfDate:[NSDate date]];
}

+ (NSDateComponents *)componentsOfDate:(NSDate *)date {
    
    //Time zone change for weekview change, here we are considering system reagion.
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  //  NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *comp0 = [calender components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth| NSHourCalendarUnit |
                               NSMinuteCalendarUnit fromDate:date];
    return comp0;
}

+ (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [NSDate componentsWithYear:year month:month day:day];
    
    return [calendar dateFromComponents:components];
}

+ (NSDate *)dateWithHour:(NSInteger)hour min:(NSInteger)min {
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [NSDate componentsWithHour:hour min:min];
    
    return [calendar dateFromComponents:components];
}

+ (NSString *)stringTimeOfDate:(NSDate *)date {
    
    NSDateFormatter *dateFormater = [NSDateFormatter new];
    [dateFormater setDateFormat:@"HH:mm"];
    [dateFormater setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    return [dateFormater stringFromDate:date];
}

+ (NSString *)stringTimeWithAMPMOfDate:(NSDate *)date {
    
    NSDateFormatter *dateFormater = [NSDateFormatter new];
    [dateFormater setDateFormat:@"hh:mm a"];
    
    NSString *lTime = [dateFormater stringFromDate:date];
    
    lTime = [lTime stringByReplacingOccurrencesOfString:@"AM" withString:[[TagManager sharedInstance]tagByName:kTag_AM] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [lTime length])];
    lTime = [lTime stringByReplacingOccurrencesOfString:@"PM" withString:[[TagManager sharedInstance]tagByName:kTag_PM] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [lTime length])];

    return lTime;
}

+ (NSString *)stringDayOfDate:(NSDate *)date
{
    return [self localDateTimeStringFromDate:date];
    /*
    NSDateComponents *comp = [NSDate componentsOfDate:date];
    return [NSString stringWithFormat:@"%@ %@ %li, %li", [dictWeekNumberName objectForKey:[NSNumber numberWithInt:(int)comp.weekday]], [arrayMonthNameAbrev objectAtIndex:comp.month-1], (long)comp.day, (long)comp.year];
     */
}

+ (NSString *)stringEventDetailDayOfDate:(NSDate *)date {
    
    NSString *lTime = nil;
    if ([DateUtil iSDeviceTime24HourFormat])
    {
        lTime = [NSDate localDateTimeStringFromDate:date inFormat:@"EEE MMM dd, yyyy - HH:mm"];
    }
    else
    {
        lTime = [NSDate localDateTimeStringFromDate:date inFormat:@"EEE MMM dd, yyyy - hh:mm a"];
    }
    return lTime;
/*
    NSDateComponents *comp = [NSDate componentsOfDate:date];
    NSString *lTime = [NSDate stringTimeWithAMPMOfDate:date];
    return [NSString stringWithFormat:@"%@ %@ %li, %li - %@", [dictWeekNumberName objectForKey:[NSNumber numberWithInt:(int)comp.weekday]], [arrayMonthNameAbrev objectAtIndex:comp.month-1], (long)comp.day, (long)comp.year, lTime];
 */
}

//Niraj: Defect number 017148
//Here we are modifying date with local tags
+(NSString *)localDateTimeStringFromDate:(NSDate *)date
{
    NSString *lTime = nil;
    if (date != nil) {
        NSDateFormatter *dateFormater = [NSDateFormatter new];
        [dateFormater setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
        if ([DateUtil iSDeviceTime24HourFormat]) {
            [dateFormater setDateFormat:@"EEE MMM dd, yyyy HH:mm"];
            lTime = [dateFormater stringFromDate:date];
        }
        else
        {
            [dateFormater setDateFormat:@"EEE MMM dd, yyyy hh:mm a"];
            lTime = [dateFormater stringFromDate:date];
        }
    }
    return lTime;
}

+(NSString *)localDateTimeStringFromDate:(NSDate *)date inFormat:(NSString*)format
{
    NSString *lTime = nil;
    NSDateFormatter *dateFormater = [NSDateFormatter new];
    [dateFormater setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    [dateFormater setDateFormat:format];
    lTime = [dateFormater stringFromDate:date];

    return lTime;
}

 //@"EEE MMM dd, yyyy HH:mm"
 //return [NSString stringWithFormat:@"%@ %@ %@, %@ %@", [NSDate stringWeekDayDate:date], [NSDate stringMonthDate:date], [NSDate stringDayDate:date], [NSDate stringYearDate:date], lTime];
 
+ (NSString *)stringTime12hrDate:(NSDate *)date {
    
    NSDateFormatter *dateFormater = [NSDateFormatter new];
    [dateFormater setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    [dateFormater setDateFormat:@"hh:mm a"];
    NSString *lTime = [dateFormater stringFromDate:date];
    return lTime;
}

+ (NSString *)stringWeekDayDate:(NSDate *)date {
    
    NSDateFormatter *dateFormater = [NSDateFormatter new];
    [dateFormater setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    [dateFormater setDateFormat:@"EEE"];
    NSString *weekDay = [dateFormater stringFromDate:date];
    return weekDay;
}

+ (NSString *)stringMonthDate:(NSDate *)date {
    
    NSDateFormatter *dateFormater = [NSDateFormatter new];
    [dateFormater setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    [dateFormater setDateFormat:@"MMM"];
    NSString *month = [dateFormater stringFromDate:date];
    return month;
}

+ (NSString *)stringDayDate:(NSDate *)date {
    
    NSDateFormatter *dateFormater = [NSDateFormatter new];
    [dateFormater setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    [dateFormater setDateFormat:@"dd"];
    NSString *day = [dateFormater stringFromDate:date];
    return day;
}

+ (NSString *)stringYearDate:(NSDate *)date {
    
    NSDateFormatter *dateFormater = [NSDateFormatter new];
    [dateFormater setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    [dateFormater setDateFormat:@"yyyy"];
    NSString *year = [dateFormater stringFromDate:date];
    return year;
}

+ (NSDateComponents *)componentsWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    
    return components;
}

+ (NSDateComponents *)componentsWithHour:(NSInteger)hour min:(NSInteger)min {
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setHour:hour];
    [components setMinute:min];
    
    return components;
}

+ (BOOL)isTheSameDateTheCompA:(NSDateComponents *)compA compB:(NSDateComponents *)compB {
    
    return ([compA day]==[compB day] && [compA month]==[compB month ]&& [compA year]==[compB year]);
}

+ (BOOL)isTheSameTimeTheCompA:(NSDateComponents *)compA compB:(NSDateComponents *)compB {
    
    return ([compA hour]==[compB hour] && [compA minute]==[compB minute]);
}

+ (NSDate *)combineDate:(NSDate *)date withTime:(NSDate *)time {
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    unsigned unitFlagsDate = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *dateComponents = [gregorian components:unitFlagsDate fromDate:date];
    unsigned unitFlagsTime = NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit;
    NSDateComponents *timeComponents = [gregorian components:unitFlagsTime fromDate:time];
    
    [dateComponents setSecond:[timeComponents second]];
    [dateComponents setHour:[timeComponents hour]];
    [dateComponents setMinute:[timeComponents minute]];
    
    NSDate *combDate = [gregorian dateFromComponents:dateComponents];
    
    
    return combDate;
}

@end
