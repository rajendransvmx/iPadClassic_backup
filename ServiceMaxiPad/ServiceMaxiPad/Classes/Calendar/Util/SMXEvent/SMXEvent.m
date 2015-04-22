//
//  SMXEvent.m
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

#import "SMXEvent.h"
#import "CalenderHelper.h"
#import "NSDate+SMXDaysCount.h"
#import "NSDate+TKCategory.h"

@implementation SMXEvent

@synthesize stringCustomerName;
@synthesize numCustomerID;
@synthesize ActivityDateDay;
@synthesize dateTimeBegin;
@synthesize dateTimeEnd;
@synthesize arrayWithGuests;
//@synthesize cWorkOrderSummaryModel;
@synthesize description;
@synthesize IDString;
@synthesize localID;
@synthesize billingType;
@synthesize sla;
@synthesize priority;
@synthesize conflict;
@synthesize newData;
@synthesize isCaseEvent;
@synthesize isWorkOrder;
@synthesize isAlldayEvent;

@synthesize isMultiDayEvent;
@synthesize dateTimeEnd_Multi;
@synthesize dateTimeStart_Multi;

-(instancetype)initWithCalendarModel:(CalenderEventObjectModel*)model;
{
    if (self = [super init]) {
        
        NSString *lActivityDate =   [NSString stringWithFormat:@"%@",model.activityDate];
        NSString *lStartDateTime =   [NSString stringWithFormat:@"%@",model.startDateTime];
        NSString *lEndDateTime = [NSString stringWithFormat:@"%@",model.endDateTime];
        
        self.localID = model.localId;
        self.IDString = model.Id;
        self.stringCustomerName = model.subject;
        self.description = model.description;
        self.whatId = model.WhatId;
        self.sla = model.sla;
        self.priority = model.priority;
        self.conflict = model.conflict;
        self.newData = NO;
        self.isAlldayEvent = ([model.isAllDayEvent isEqualToString:@"false"] ? NO:YES);
        
        if (self.isAlldayEvent) {
            NSArray *theDates = [self theAllDayStartAndEndDate:lStartDateTime andEndDate:lEndDateTime];
            self.dateTimeBegin = [theDates objectAtIndex:0];
            self.ActivityDateDay = [[theDates objectAtIndex:0] copy];
            self.dateTimeEnd = [theDates objectAtIndex:1];
        }
        else
        {
            self.dateTimeBegin = [self getStartEndDateTime:lStartDateTime];
            self.ActivityDateDay = [self getActivityDate:lActivityDate];
            self.dateTimeEnd = [self getStartEndDateTime:lEndDateTime];
            

        }
        
        if ([self isItMultiDay]) {
            /*
             1) If it is multi-day, render only on the first day. So make the dateTimeEnd is the startDay and time should be hardcoded to 11:59PM.
             2) Create another variable to save the actual end date. That end date has to be displayed in detail view.
             */
            
            self.dateTimeEnd_Multi = [self.dateTimeEnd copy];
            self.dateTimeStart_Multi = self.dateTimeBegin;
            self.dateTimeEnd = [self createHardCodedEndDate:lEndDateTime];
        }
        
        //        self.cWorkOrderSummaryModel = model.cWorkOrderSummaryModel;
        self.isWorkOrder = model.isWorkOrder;
        self.isCaseEvent = model.isCaseEvent;
    }
    return self;
    
}

-(NSDate *)getActivityDate:(NSString *)dateString
{
    //First set the event DATETIMEBEGIN and then call this method. -- Changes done on 27/Jan/2015 BSP
    
    NSDateComponents *comp = [NSDate componentsOfDate:self.dateTimeBegin];
    NSDate *newDate = [NSDate dateWithYear:comp.year month:comp.month day:comp.day];
    
    return newDate;
    
    /*
     NSDateFormatter * lDF = [[NSDateFormatter alloc] init];
     [lDF setDateFormat: @"yyyy-MM-dd 00:00:00"];
     lDF.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
     lDF.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
     
     return [lDF dateFromString:dateString];
     */
    
}

-(NSDate *)getStartEndDateTime:(NSString *)lTempDateTime
{
    lTempDateTime = [lTempDateTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    lTempDateTime = [lTempDateTime stringByReplacingOccurrencesOfString:@".000Z" withString:@""];
    lTempDateTime = [CalenderHelper localTimeFromGMT:lTempDateTime];
    lTempDateTime = [lTempDateTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    lTempDateTime = [lTempDateTime stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    
    NSDateFormatter * lDF = [[NSDateFormatter alloc] init];
    [lDF setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    lDF.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    lDF.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    return [lDF dateFromString:lTempDateTime];
}

-(NSArray *)theAllDayStartAndEndDate:(NSString *)lTempDateTime andEndDate:(NSString *)lTempEndDateTime
{
    lTempDateTime = [lTempDateTime substringToIndex:[lTempDateTime rangeOfString:@"T"].location];
    lTempEndDateTime = [lTempEndDateTime substringToIndex:[lTempEndDateTime rangeOfString:@"T"].location];

    NSString *startDate = [lTempDateTime stringByAppendingString:@" 19:00:00"];
    NSString *endDate = [lTempEndDateTime stringByAppendingString:@" 23:59:00"];
    
    
    NSDateFormatter * lDF = [[NSDateFormatter alloc] init];
    [lDF setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    lDF.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    lDF.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *startDateTime = [lDF dateFromString:startDate];
    NSDate *endDateTime = [lDF dateFromString:endDate];
    
    return @[startDateTime, endDateTime];
    
}

-(void)explainMe;
{
    SXLogInfo(@"IDString: %@, localID : %@, dateTimeBegin: %@ , dateTimeEnd : %@ billingType :%@", IDString, localID, dateTimeBegin, dateTimeEnd, billingType);
}


-(BOOL)isItMultiDay
{
    
    //    NSDate *startDate = [DateUtil getLocalTimeFromDateBaseDate:[self valueForField:keyStartDateTime]];
    //    NSDate *endDate = [DateUtil getLocalTimeFromDateBaseDate:[self valueForField:keyEndDateTime]];
    
    
    if ([self.dateTimeBegin isSameDay:self.dateTimeEnd])
    {
        self.isMultiDayEvent = NO;
    }
    else
    {
        self.isMultiDayEvent = YES;
    }
    
    return self.isMultiDayEvent;
}

-(NSDate *)createHardCodedEndDate:(NSString *)lTempDateTime
{
    lTempDateTime = [lTempDateTime substringToIndex:[lTempDateTime rangeOfString:@"T"].location];
    
//    NSString *startDate = [lTempDateTime stringByAppendingString:@" 19:00:00"];
    NSString *endDate = [lTempDateTime stringByAppendingString:@" 23:59:00"];
    
    
    NSDateFormatter * lDF = [[NSDateFormatter alloc] init];
    [lDF setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    lDF.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    lDF.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *endDateTime = [lDF dateFromString:endDate];
    
    return endDateTime;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy)
    {
        
    }
    
    return copy;
}
@end
