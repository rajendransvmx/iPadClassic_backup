//
//
/**
 *  @file   NSDate+SMXDaysCount.h
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

#import <Foundation/Foundation.h>

@interface NSDate (SMXDaysCount)

- (NSDate *)lastDayOfMonth;
- (NSInteger)numberOfDaysInMonthCount;
- (NSInteger)numberOfWeekInMonthCount;
- (NSDateComponents *)componentsOfDate;


+ (NSString *)stringDayOfDate:(NSDate *)date;
+ (NSString *)stringEventDetailDayOfDate:(NSDate *)date;
+ (NSString *)stringTimeOfDate:(NSDate *)date;
+ (NSDateComponents *)componentsOfCurrentDate;
+ (NSDateComponents *)componentsOfDate:(NSDate *)date;
+ (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
+ (NSDate *)dateWithHour:(NSInteger)hour min:(NSInteger)min;
+ (NSDateComponents *)componentsWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
+ (NSDateComponents *)componentsWithHour:(NSInteger)hour min:(NSInteger)min;
+ (BOOL)isTheSameDateTheCompA:(NSDateComponents *)compA compB:(NSDateComponents *)compB;
+ (BOOL)isTheSameTimeTheCompA:(NSDateComponents *)compA compB:(NSDateComponents *)compB;
+ (NSDate *)combineDate:(NSDate *)date withTime:(NSDate *)time;

//Language localization display
+(NSString *)localDateTimeStringFromDate:(NSDate *)date;
+(NSString *)localDateTimeStringFromDate:(NSDate *)date inFormat:(NSString*)format;
+(NSString *)localDateStringFromDate:(NSDate *)date;

+ (NSString *)stringTime12hrDate:(NSDate *)date;
+ (NSString *)stringWeekDayDate:(NSDate *)date;
+ (NSString *)stringMonthDate:(NSDate *)date;
+ (NSString *)stringDayDate:(NSDate *)date;
+ (NSString *)stringYearDate:(NSDate *)date;
@end
