//
//  DateTimeFormatter.h
//  iService
//
//  Created by Samman Banerjee on 27/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DateTimeFormatter : NSObject
{
}

- (NSString *) getReadableDateFromDate:(NSString *)_date;
//- (NSString *) getReadableDateFromLongDateString:(NSString *)_date;//  Unused methods
//- (NSString *) getReadableDateFromShortDateString:(NSString *)_date;//  Unused methods
- (NSString *) getFormattedDateFromComponents:(NSDateComponents *)components;
- (NSString *) getWeekDayForIndex:(NSUInteger)index;
- (NSString *) getMonthForIndex:(NSUInteger)index;


@end
