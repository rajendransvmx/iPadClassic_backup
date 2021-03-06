//
//  NSDateAdditions.m
//  Created by Devin Ross on 7/28/09.
//
/*
 
 tapku || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */
#import "NSDate+TKCategory.h"
#import "CalenderHelper.h"

#pragma mark - NSDate + TKCategory
@implementation NSDate (TKCategory)

#pragma mark currentday

+ (NSDate*) date:(NSDate*)date withTimeZone:(NSTimeZone*)timeZone {
    NSDateComponents *comp = [date dateComponentsWithTimeZone:timeZone];
	return [NSDate dateWithDateComponents:comp];
}

+ (NSDate*) todayWithTimeZone:(NSTimeZone*)timeZone {
    NSDateComponents *comp = [[NSDate date] dateComponentsWithTimeZone:timeZone];
	return [NSDate dateWithDateComponents:comp];
}

#pragma mark Yesterday
+ (NSDate*) yesterday{
	return [NSDate yesterdayWithTimeZone:[NSTimeZone defaultTimeZone]];
}
+ (NSDate*) yesterdayWithTimeZone:(NSTimeZone*)timeZone{
	NSDateComponents *comp = [[NSDate date] dateComponentsWithTimeZone:timeZone];
	comp.day--;
	return [NSDate dateWithDateComponents:comp];
}


#pragma mark Tomorrow
+ (NSDate*) tomorrow{
	return [NSDate tomorrowWithTimeZone:[NSTimeZone defaultTimeZone]];
}
+ (NSDate*) tomorrowWithTimeZone:(NSTimeZone*)timeZone{
	NSDateComponents *comp = [[NSDate date] dateComponentsWithTimeZone:timeZone];
	comp.day++;
	return [NSDate dateWithDateComponents:comp];
}

#pragma mark Month
+ (NSDate*) month{
    return [[NSDate date] monthDateWithTimeZone:[NSTimeZone defaultTimeZone]];
}
+ (NSDate*) monthWithTimeZone:(NSTimeZone*)timeZone{
    return [[NSDate date] monthDateWithTimeZone:timeZone];
}
- (NSDate*) monthDate{
	return [self monthDateWithTimeZone:[NSTimeZone defaultTimeZone]];
}
- (NSDate*) monthDateWithTimeZone:(NSTimeZone*)timeZone{
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	gregorian.timeZone = timeZone;
	NSDateComponents *comp = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:self];
	[comp setDay:1];
	NSDate *date = [gregorian dateFromComponents:comp];
    return date;
}


#pragma mark Between
- (NSInteger) monthsBetweenDate:(NSDate *)toDate{
	return [self monthsBetweenDate:toDate timeZone:[NSTimeZone defaultTimeZone]];
}
- (NSInteger) monthsBetweenDate:(NSDate *)toDate timeZone:(NSTimeZone*)timeZone{
	if([self compare:toDate]==NSOrderedSame) return 0;
	
	NSDate *first = nil, *last = nil;
	if([self compare:toDate] == NSOrderedAscending){
		first = self;
		last = toDate;
	}else{
		first = toDate;
		last = self;
	}
	
	NSDateComponents *d1 = [first dateComponentsWithTimeZone:timeZone];
	NSDateComponents *d2 = [last dateComponentsWithTimeZone:timeZone];
	
	if(d1.year == d2.year)
		return d2.month - d1.month;
	
	
	NSInteger ret = 12 - d1.month;
	ret += d2.month;
	d1.year += 1;
	ret += 12 * (d2.year-d1.year);
	
	return ret;
}
- (NSInteger) daysBetweenDate:(NSDate*)date {
    NSTimeInterval time = [self timeIntervalSinceDate:date];
    return ((fabs(time) / (60.0 * 60.0 * 24.0)) + 0.5);
}

#pragma mark Same Day
- (BOOL) isSameDay:(NSDate*)anotherDate{
	return [self isSameDay:anotherDate timeZone:[NSTimeZone defaultTimeZone]];
}
- (BOOL) isSameDay:(NSDate*)anotherDate timeZone:(NSTimeZone*)timeZone{
	NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	calendar.timeZone = timeZone;
	NSDateComponents* components1 = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self];
	NSDateComponents* components2 = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:anotherDate];
	return ([components1 year] == [components2 year] && [components1 month] == [components2 month] && [components1 day] == [components2 day]);
}

#pragma mark Same Month
- (BOOL) isSameMonth:(NSDate *)anotherDate{
	return [self isSameMonth:anotherDate timeZone:[NSTimeZone defaultTimeZone]];
}
- (BOOL) isSameMonth:(NSDate *)anotherDate timeZone:(NSTimeZone *)timeZone{
	
	NSCalendar* calendar = [NSCalendar currentCalendar];
	calendar.timeZone = timeZone;
	NSDateComponents* components1 = [calendar components:NSCalendarUnitYear fromDate:self];
	NSDateComponents* components2 = [calendar components:NSCalendarUnitYear fromDate:anotherDate];
	return components1.year == components2.year && components1.month == components2.month;
}

#pragma mark Same Year
- (BOOL) isSameYear:(NSDate *)anotherDate{
	return [self isSameYear:anotherDate timeZone:[NSTimeZone defaultTimeZone]];
}
- (BOOL) isSameYear:(NSDate *)anotherDate timeZone:(NSTimeZone *)timeZone{
	
	NSCalendar* calendar = [NSCalendar currentCalendar];
	calendar.timeZone = timeZone;
	NSDateComponents* components1 = [calendar components:NSCalendarUnitYear fromDate:self];
	NSDateComponents* components2 = [calendar components:NSCalendarUnitYear fromDate:anotherDate];
	return components1.year == components2.year;

}

#pragma mark Is Today
- (BOOL) isToday{
	return [self isSameDay:[NSDate date]];
}
- (BOOL) isTodayWithTimeZone:(NSTimeZone*)timeZone{
	return [self isSameDay:[NSDate date] timeZone:timeZone];
}

- (BOOL) isTomorrow{
	return [self isTomorrowWithTimeZone:[NSTimeZone defaultTimeZone]];
}
- (BOOL) isTomorrowWithTimeZone:(NSTimeZone*)timeZone{
	NSDateComponents *comp = [[NSDate date] dateComponentsWithTimeZone:timeZone];
	comp.day++;
	NSDate *actualTomorrow = [NSDate dateWithDateComponents:comp];
	return [self isSameDay:actualTomorrow timeZone:timeZone];
}


- (BOOL) isYesterday{
	return [self isYesterdayWithTimeZone:[NSTimeZone defaultTimeZone]];
}
- (BOOL) isYesterdayWithTimeZone:(NSTimeZone*)timeZone{
	NSDateComponents *comp = [[NSDate date] dateComponentsWithTimeZone:timeZone];
	comp.day--;
	NSDate *actualTomorrow = [NSDate dateWithDateComponents:comp];
	return [self isSameDay:actualTomorrow timeZone:timeZone];
}

#pragma mark Month & Year String
- (NSString *) monthYearString{
	return [self monthYearStringWithTimeZone:[NSTimeZone defaultTimeZone]];
}

- (NSString *) monthYearStringWithTimeZone:(NSTimeZone*)timeZone{
    
    /*
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.timeZone = timeZone;
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];

	dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yMMMM"
															   options:0
																locale:[NSLocale currentLocale]];
    
     */
    
    //21-Jan-2015.Changed for localization. defect 13645

    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp = [cal components:NSCalendarUnitMonth|NSCalendarUnitYear fromDate:self];
    
    NSString *lYear = [NSString stringWithFormat:@"%ld", (long)comp.year];
    NSString *monthName = [CalenderHelper getTagValueForMonth:comp.month-1];
    
    NSString *combined = [NSString stringWithFormat:@"%@ %@", monthName, lYear];
//	return [dateFormatter stringFromDate:self];
    return combined;
}

- (NSString*) monthString{
	return [self monthStringWithTimeZone:[NSTimeZone defaultTimeZone]];
}
- (NSString*) monthStringWithTimeZone:(NSTimeZone*)timeZone{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.timeZone = timeZone;
	[dateFormatter setDateFormat:@"MMMM"];
	return [dateFormatter stringFromDate:self];
}

- (NSString*) yearString{
	return [self yearStringWithTimeZone:[NSTimeZone defaultTimeZone]];
}
- (NSString*) yearStringWithTimeZone:(NSTimeZone*)timeZone{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.timeZone = timeZone;
	[dateFormatter setDateFormat:@"yyyy"];
	return [dateFormatter stringFromDate:self];
}


#pragma mark Date Compontents
- (NSDateComponents*) dateComponentsWithTimeZone:(NSTimeZone*)timeZone{
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	gregorian.timeZone = timeZone;
	return [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitTimeZone) fromDate:self];
}
+ (NSDate*) dateWithDateComponents:(NSDateComponents*)components{
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	gregorian.timeZone = components.timeZone;
	return [gregorian dateFromComponents:components];
}


- (NSDate *) dateByAddingDays:(NSUInteger)days {
	NSDateComponents *c = [[NSDateComponents alloc] init];
	c.day = days;
	return [[NSCalendar currentCalendar] dateByAddingComponents:c toDate:self options:0];
}
+ (NSDate *) dateWithDatePart:(NSDate *)aDate andTimePart:(NSDate *)aTime {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"dd/MM/yyyy"];
	NSString *datePortion = [dateFormatter stringFromDate:aDate];
	
	[dateFormatter setDateFormat:@"HH:mm"];
	NSString *timePortion = [dateFormatter stringFromDate:aTime];
	
	[dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
	NSString *dateTime = [NSString stringWithFormat:@"%@ %@",datePortion,timePortion];
	return [dateFormatter dateFromString:dateTime];
}



- (NSDate*) firstDateOfWeekWithTimeZone:(NSTimeZone*)timeZone{
	NSCalendar *gregorian = [NSCalendar currentCalendar];
	
	NSDateComponents *weekdayComponents = [gregorian components:NSCalendarUnitWeekday fromDate:self];
	weekdayComponents.timeZone = timeZone;

	NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
	componentsToSubtract.timeZone = timeZone;
	
	[componentsToSubtract setDay: - ([weekdayComponents weekday] - [gregorian firstWeekday])];
	
	NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:self options:0];
	

	NSDateComponents *components = [gregorian components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate: beginningOfWeek];
	components.timeZone = timeZone;

	beginningOfWeek = [gregorian dateFromComponents: components];
	
	return beginningOfWeek;
}


- (NSDate*) firstDateOfWeek{
	return [self firstDateOfWeekWithTimeZone:[NSTimeZone defaultTimeZone]];
}


+ (NSDate*) firstDateOfWeekWithTimeZone:(NSTimeZone*)timeZone{
	return [[NSDate date] firstDateOfWeekWithTimeZone:timeZone];
}
+ (NSDate*) firstDateOfWeek{
	return [[NSDate date] firstDateOfWeek];
}


- (int) weekday{
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDateComponents *comps = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday) fromDate:self];
	int weekday = (int)[comps weekday];
	return weekday;
}
- (NSDate*) timelessDate {
	NSDate *day = self;
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDateComponents *comp = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:day];
	return [gregorian dateFromComponents:comp];
}
- (NSDate*) monthlessDate {
	NSDate *day = self;
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDateComponents *comp = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:day];
	return [gregorian dateFromComponents:comp];
}


- (TKDateInformation) dateInformationWithTimeZone:(NSTimeZone*)tz{
	
	
	TKDateInformation info;
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	[gregorian setTimeZone:tz];
	NSDateComponents *comp = [gregorian components:(NSCalendarUnitMonth | NSCalendarUnitMinute | NSCalendarUnitYear | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitSecond)
										  fromDate:self];
	info.day = (int)[comp day];
	info.month = (int)[comp month];
	info.year = (int)[comp year];
	
	info.hour = (int)[comp hour];
	info.minute = (int)[comp minute];
	info.second = (int)[comp second];
	
	info.weekday = (int)[comp weekday];
	
	
	return info;
	
}
- (TKDateInformation) dateInformation{
	
	TKDateInformation info;
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDateComponents *comp = [gregorian components:(NSCalendarUnitMonth | NSCalendarUnitMinute | NSCalendarUnitYear |
													NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitSecond)
										  fromDate:self];
	info.day = (int)[comp day];
	info.month = (int)[comp month];
	info.year = (int)[comp year];
	
	info.hour = (int)[comp hour];
	info.minute = (int)[comp minute];
	info.second = (int)[comp second];
	
	info.weekday = (int)[comp weekday];
	
    
	return info;
}
+ (NSDate*) dateFromDateInformation:(TKDateInformation)info timeZone:(NSTimeZone*)tz{
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	[gregorian setTimeZone:tz];
	NSDateComponents *comp = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:[NSDate date]];
	
	[comp setDay:info.day];
	[comp setMonth:info.month];
	[comp setYear:info.year];
	[comp setHour:info.hour];
	[comp setMinute:info.minute];
	[comp setSecond:info.second];
	[comp setTimeZone:tz];
	
	return [gregorian dateFromComponents:comp];
}
+ (NSDate*) dateFromDateInformation:(TKDateInformation)info{
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDateComponents *comp = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:[NSDate date]];
	
	[comp setDay:info.day];
	[comp setMonth:info.month];
	[comp setYear:info.year];
	[comp setHour:info.hour];
	[comp setMinute:info.minute];
	[comp setSecond:info.second];
	//[comp setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	return [gregorian dateFromComponents:comp];
}

+ (NSString*) dateInformationDescriptionWithInformation:(TKDateInformation)info{
	return [NSString stringWithFormat:@"%d %d %d %d:%d:%d",info.month,info.day,info.year,info.hour,info.minute,info.second];
}
/*This method giving number of day diffrence beteen two date*/
+(int )numberOfDaysFromStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate
{
    startDate=[self changeTime:startDate];
    endDate=[self changeTime:endDate];
    if ((startDate !=nil) && (endDate!=nil)) {
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                            fromDate:startDate
                                                              toDate:endDate
                                                             options:0];
        int i=(int)components.day;
        if(i==0){
            NSDateComponents *Scomp = [self componentsOfDate:startDate];
            NSDateComponents *Ecomp = [self componentsOfDate:endDate];
            if (Scomp.day!=Ecomp.day) {
                return 1;
            }
        }
        return i;   //TODO:NEED TO CHECK THIS FOR EVENT WHICH IS JUST CROSSING THE MIDNIGHT MARK. Eg: 1130PM to 1230AM
    }
    return 0;
}
+(NSDate *)changeTime:(NSDate *)date {
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp = [cal components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    comp.hour = 00;
    comp.minute = 00;
    comp.second = 00;
    //NSDate *sevenDaysAgo = [[cal dateFromComponents:comp] dateByAddingTimeInterval:numberOfDay*24*60*60];
    return [cal dateFromComponents:comp];
}
+(NSDateComponents *)componentsOfDate:(NSDate *)date {
    
    //Time zone change for weekview change, here we are considering system reagion.
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //  NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *comp0 = [calender components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth| NSCalendarUnitHour |
                               NSCalendarUnitMinute fromDate:date];
    return comp0;
}

@end
