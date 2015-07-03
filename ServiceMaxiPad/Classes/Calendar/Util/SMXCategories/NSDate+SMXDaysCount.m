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
    
    return [dateFormater stringFromDate:date];
}

+ (NSString *)stringTimeWithAMPMOfDate:(NSDate *)date {
    
    NSDateFormatter *dateFormater = [NSDateFormatter new];
    [dateFormater setDateFormat:@"hh:mm:ss a"];//HS 3Jul15 Fix:018737
    
    NSString *lTime = [dateFormater stringFromDate:date];
    
    lTime = [lTime stringByReplacingOccurrencesOfString:@"AM" withString:[[TagManager sharedInstance]tagByName:kTag_AM] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [lTime length])];
    lTime = [lTime stringByReplacingOccurrencesOfString:@"PM" withString:[[TagManager sharedInstance]tagByName:kTag_PM] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [lTime length])];

    return lTime;
}

+ (NSString *)stringDayOfDate:(NSDate *)date {
    
    NSDateComponents *comp = [NSDate componentsOfDate:date];

    //    return [NSString stringWithFormat:@"%@, %i/%i/%i", [dictWeekNumberName objectForKey:[NSNumber numberWithInt:comp.weekday]], comp.day, comp.month, comp.year];
    return [NSString stringWithFormat:@"%@ %@ %li, %li", [dictWeekNumberName objectForKey:[NSNumber numberWithInt:(int)comp.weekday]], [arrayMonthNameAbrev objectAtIndex:comp.month-1], (long)comp.day, (long)comp.year];
}

+ (NSString *)stringDayOfDate:(NSDate *)date WithTime:(NSDate *)time {
    
    
    NSDateComponents *comp = [NSDate componentsOfDate:date];
    NSString *lTime = [NSDate stringTimeWithAMPMOfDate:time];
    
    //    return [NSString stringWithFormat:@"%@, %i/%i/%i", [dictWeekNumberName objectForKey:[NSNumber numberWithInt:comp.weekday]], comp.day, comp.month, comp.year];
    
    return [NSString stringWithFormat:@"%@ %@ %li, %li  %@", [dictWeekNumberName objectForKey:[NSNumber numberWithInt:(int)comp.weekday]], [arrayMonthNameAbrev objectAtIndex:comp.month-1], (long)comp.day, (long)comp.year, lTime]; ////HS 3Jul Fix:018737 ,removed "hyphen"
}

//Niraj: Defect number 017148
//Here we are modifying date with local tags
+(NSString *)localStringFromDate:(NSDate *)date{
    NSDateComponents *comp = [NSDate componentsOfDate:date];
    NSString *lTime = [NSDate stringTimeWithAMPMOfDate:date];
    //return [NSString stringWithFormat:@"%@, %li %@ %li - %@", [dictWeekNumberName objectForKey:[NSNumber numberWithInt:(int)comp.weekday]], (long)comp.day,[arrayMonthNameAbrev objectAtIndex:comp.month-1], (long)comp.year,lTime];
    return [NSString stringWithFormat:@"%@ %@ %li, %li  %@", [dictWeekNumberName objectForKey:[NSNumber numberWithInt:(int)comp.weekday]], [arrayMonthNameAbrev objectAtIndex:comp.month-1], (long)comp.day, (long)comp.year, lTime]; //HS 3Jul Fix:018737 removed "hyphen"
}
//Niraj: Defect number 017148

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
