//
//  EventTransactionObjectModel.m
//  ServiceMaxiPad
//
//  Created by Admin on 23/02/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "EventTransactionObjectModel.h"
#import "NSDate+TKCategory.h"
#import "SMXDateManager.h"
#import "DateUtil.h"
#import "TransactionObjectService.h"
#import "TransactionObjectDAO.h"
#import "FactoryDAO.h"
#import "CalenderHelper.h"

@interface EventTransactionObjectModel ()

@property(nonatomic, copy) NSString *keyStartDateTime;
@property(nonatomic, copy) NSString *keyEndDateTime;
@property(nonatomic, copy) NSString *keyDuration;
@property(nonatomic, copy) NSString *keyIndex;
@property(nonatomic, copy) NSString *keyNumberofevent;
@property(nonatomic, assign) BOOL isAllDayEvent;
@property(nonatomic, copy) NSString *keyIsAllDayEvent;


@end
@implementation EventTransactionObjectModel
@synthesize jsonEventArray;
@synthesize isMultiDay;

@synthesize keyStartDateTime;
@synthesize keyEndDateTime;
@synthesize keyDuration;
@synthesize keyNumberofevent;
@synthesize keyIndex;
@synthesize isAllDayEvent;
@synthesize keyIsAllDayEvent;


- (NSString *)getWhatId
{
    return [self valueForField:kSVMXWhatId];
}

-(BOOL)isItMultiDay
{
    [self setTheKeys];
    
//    NSDate *startDate = [DateUtil getLocalTimeFromDateBaseDate:[self valueForField:keyStartDateTime]];
//    NSDate *endDate = [DateUtil getLocalTimeFromDateBaseDate:[self valueForField:keyEndDateTime]];
    
    NSDate *startDate;
    NSDate *endDate;
    
    NSMutableDictionary *theDict = (NSMutableDictionary *) [self getFieldValueDictionary];

    isAllDayEvent=[[theDict objectForKey:keyIsAllDayEvent] boolValue];
    if (isAllDayEvent) {
        NSArray *theDateArray =[self getDateForAllDayEventOnDate:[self valueForField:keyStartDateTime] endDate:[self valueForField:keyEndDateTime]];
        
        startDate = [theDateArray objectAtIndex:0];
        endDate = [theDateArray objectAtIndex:1];
        
    }
    else
    {
        startDate = [CalenderHelper getStartEndDateTime:[self valueForField:keyStartDateTime]];
        endDate = [CalenderHelper getStartEndDateTime:[self valueForField:keyEndDateTime]];
    }
    

    
    
    if ([startDate isSameDay:endDate])
    {
        isMultiDay = NO;
    }
    else
    {
        isMultiDay = YES;
    }
    return isMultiDay;
    
}

-(BOOL)isMultidayForStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;
{
    if ([startDate isSameDay:endDate])
    {
        isMultiDay = NO;
    }
    else
    {
        isMultiDay = YES;
    }
    return isMultiDay;
}

-(void)setTheKeys
{
    if ([self.objectAPIName isEqualToString:kSVMXTableName])
    {
        keyStartDateTime = kSVMXStartDateTime;
        keyEndDateTime = kSVMXEndDateTime;
        keyDuration = kSVMXDurationInMinutes;
        /* index of the event */
        keyIndex=kEventIndex;
        keyNumberofevent=kEventNumber;
        keyIsAllDayEvent=kSVMXIsAlldayEvent;
    }
    else
    {
        keyStartDateTime = kStartDateTime;
        keyEndDateTime = kEndDateTime;
        keyDuration = kDurationInMinutes;
        /* index of the event */
        keyIndex=kEventIndex;
        keyNumberofevent=kEventNumber;
        keyIsAllDayEvent=kIsAlldayEvent;
    }
}

/* for multiday all day changes */
-(void)splittingTheEvent{
    
    [self setTheKeys];
    
    NSMutableDictionary *theDict = (NSMutableDictionary *) [self getFieldValueDictionary];
    isAllDayEvent=[[theDict objectForKey:keyIsAllDayEvent] boolValue];
    
    NSDate *startDate;
    NSDate *endDate;

        
    if (isAllDayEvent) {
       NSArray *theDateArray =[self getDateForAllDayEventOnDate:[self valueForField:keyStartDateTime] endDate:[self valueForField:keyEndDateTime]];
        
        startDate = [theDateArray objectAtIndex:0];
        endDate = [theDateArray objectAtIndex:1];

    }
    else
    {
        startDate = [CalenderHelper getStartEndDateTime:[self valueForField:keyStartDateTime]];
        endDate = [CalenderHelper getStartEndDateTime:[self valueForField:keyEndDateTime]];

    }
  
    
    if(!self.jsonEventArray)
        self.jsonEventArray = [NSMutableArray new];
    else
        [self.jsonEventArray removeAllObjects];
    
    if (![self isMultidayForStartDate:startDate andEndDate:endDate])
        return;
    

    int numberOfDays = [self numberOfDaysFromDate:startDate andEndDate:endDate];
    NSDate *newStartDate;
    NSDate *newEndDate;
    
    for (int i=0; i<numberOfDays; i++)
    {
        if (i==0) {
            if (isAllDayEvent)
                newStartDate = [self changeTime:startDate newHour:0 newMin:0 numberOfday:i]; //First day.
            else
                newStartDate = startDate; //First day.
            
            newEndDate = [self changeTime:startDate newHour:23 newMin:59 numberOfday:i];
        }else{
            newStartDate=[self changeTime:startDate newHour:0 newMin:0 numberOfday:i];//Middel Days
            newEndDate=[self changeTime:startDate newHour:23 newMin:59 numberOfday:i];
        }

        float duration = [newEndDate timeIntervalSinceDate:newStartDate]/60;
        [self createObjectForStartDate:newStartDate andEndDate:newEndDate andDuration:duration number:numberOfDays+1 index:i];
    }
    
    newStartDate=[self changeTime:startDate newHour:0 newMin:0 numberOfday:numberOfDays];
    if (isAllDayEvent)
        newEndDate=[self changeTime:endDate newHour:23 newMin:59 numberOfday:0];
    else
        newEndDate=endDate;
            
    float duration = [newEndDate timeIntervalSinceDate:newStartDate]/60;
    [self createObjectForStartDate:newStartDate andEndDate:newEndDate andDuration:duration number:numberOfDays+1 index:numberOfDays];
}

-(void)createObjectForStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate andDuration:(float) duration number:(int)number index:(int)index
{
//    NSString *startDateString = [DateUtil stringFromDate:startDate inFormat:kDateFormatType1];
//    NSString *endDateString = [DateUtil stringFromDate:endDate inFormat:kDateFormatType1];

    NSString *startDateString = [self dateForTheString:startDate];
    NSString *endDateString = [self dateForTheString:endDate];
    
    NSMutableDictionary *eventObject = [NSMutableDictionary new];
    
    if (startDateString != nil) {
        [eventObject setObject:startDateString forKey:keyStartDateTime];
    }
    if (endDateString != nil) {
        [eventObject setObject:endDateString forKey:keyEndDateTime];
    }
//    [eventObject setObject:startDateString forKey:keyStartDateTime];
//    [eventObject setObject:endDateString forKey:keyEndDateTime];
    [eventObject setObject:[NSString stringWithFormat:@"%d",number] forKey:keyNumberofevent];
    [eventObject setObject:[NSString stringWithFormat:@"%d",index] forKey:keyIndex];
    [eventObject setObject:[NSString stringWithFormat:@"%f", duration] forKey:keyDuration];
    [self.jsonEventArray addObject:eventObject];

}

-(NSString *)dateForTheString:(NSDate *)date
{
    NSDateFormatter * lDF = [[NSDateFormatter alloc] init];
    
    [lDF setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    [lDF setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    lDF.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    lDF.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    return [lDF stringFromDate:date];
    
}

-(NSString *)convertToJsonString
{
//    NSLog(@"self.jsonEventArray:%@", self.jsonEventArray);
    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:self.jsonEventArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
    SXLogDebug(@"jsonData as string:\n%@", jsonString);
    return jsonString;
}

-(BOOL)hasTimeZoneChanged
{
    NSMutableDictionary *theDict = (NSMutableDictionary *) [self getFieldValueDictionary];

    NSString *timeZoneValue = [theDict objectForKey:@"TimeZone"];

    long offsetFromGMT = (long)[timeZoneValue longLongValue];
    
    /*doing null check for time zone, If time zone is null then re- calculating event */
    if (((offsetFromGMT != (long)[self secondsFromTheGMT]) && [self isItMultiDay] ) || timeZoneValue ==nil)
    {
        [self updateTable];
        return YES;
    }
    return NO;
}

-(void)updateTable
{
    [self splittingTheEvent];

    NSMutableDictionary *eventDict = (NSMutableDictionary *) [self getFieldValueDictionary];
    [eventDict setObject:[NSNumber numberWithBool:[self isMultiDay]] forKey:@"isMultiDay"];
    [eventDict setObject:[self convertToJsonString] forKey:@"SplitDayEvents"];
    [eventDict setObject:[NSString stringWithFormat:@"%ld",(long)[self secondsFromTheGMT]] forKey:@"TimeZone"];
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:[self valueForField:kLocalId]];
    id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    [transObjectService updateEachRecord:eventDict withFields:[eventDict allKeys] withCriteria:@[criteria] withTableName:self.objectAPIName];
    
}

-(long)secondsFromTheGMT
{
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSInteger secondsFromGmt = [timeZone secondsFromGMT];
    return secondsFromGmt;
}

/*This method giving number of day diffrence beteen two date*/
-(int )numberOfDaysFromDate:(NSDate *)startDate andEndDate:(NSDate *)endDate{
    startDate=[self changeTime:startDate];
    endDate=[self changeTime:endDate];
    if ((startDate !=nil) && (endDate!=nil)) {
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
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
-(NSDate *)changeTime:(NSDate *)date {
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp = [cal components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    comp.hour = 00;
    comp.minute = 00;
    comp.second = 00;
    //NSDate *sevenDaysAgo = [[cal dateFromComponents:comp] dateByAddingTimeInterval:numberOfDay*24*60*60];
    return [cal dateFromComponents:comp];
}
-(NSDateComponents *)componentsOfDate:(NSDate *)date {
    
    //Time zone change for weekview change, here we are considering system reagion.
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //  NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *comp0 = [calender components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth| NSHourCalendarUnit |
                               NSMinuteCalendarUnit fromDate:date];
    return comp0;
}

/*Here changing date , adding number of day*/
-(NSDate *)changeTime:(NSDate *)date newHour:(int )hour newMin:(int)min numberOfday:(int)numberOfDay{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:numberOfDay]; // This is required to avoid Daylight saving effect.
    
    NSDate *end = [cal dateByAddingComponents:dateComponents toDate:date options:0];

    NSDateComponents *comp = [cal components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:end];
    comp.hour = hour;
    comp.minute = min;
    comp.second = 00;
    NSDate *sevenDaysAgo = [cal dateFromComponents:comp];
    return sevenDaysAgo;
}


-(NSArray *)getDateForAllDayEventOnDate:(NSString *)startDate endDate:(NSString *)endDate{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp = [cal components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[self dateFromString:startDate]];
    
    comp.second = 00;
    comp.hour = 00;
    comp.minute = 00;
    
    NSDate *theStartDate = [cal dateFromComponents:comp];
    comp = [cal components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[self dateFromString:endDate]];
    comp.hour = 23;
    comp.minute = 59;
    
    NSDate *theEndDate = [cal dateFromComponents:comp];
    
    
    
    return @[theStartDate, theEndDate];
}

-(NSDate *)dateFromString:(NSString *)dateString
{
    NSRange range = [dateString rangeOfString:@"T"];
    
    dateString = [dateString substringToIndex:range.location];
    NSDateFormatter *lDF = [[NSDateFormatter alloc] init];
    [lDF setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *date = [lDF dateFromString:dateString];
    return date;
}

@end
