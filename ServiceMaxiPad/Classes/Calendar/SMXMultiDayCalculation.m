//
//  SMXMultiDayCalculation.m
//  ServiceMaxiPad
//
//  Created by ServiceMax on 2/16/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "SMXMultiDayCalculation.h"
#import "DateUtil.h"

@implementation SMXMultiDayCalculation

@synthesize multiEvent;
@synthesize eventDictinory;
@synthesize eventObjects;

-(void)updateMultiDayEvent:(SMXEvent *)event fromActivityDate:(NSDate *)fromActivityDate toActivityDate:(NSDate *)toActivityDate andStartTime:(NSDate *)startTime withEndTime:(NSDate *)endTim cellIndex:(int)fromIndex toIndex:(int)toIndex{
    eventObjects =[[NSMutableArray alloc] init];
    eventDictinory=[[SMXDateManager sharedManager] getdictEvents];
    [self removeEventFromArray:event numberOfDays:[self isMultidayEvent:event]];
    SMXEvent *newEvent =[[SMXEvent alloc] initWithCalendarModel_self:event];
    newEvent.dateTimeBegin = startTime;
    newEvent.dateTimeEnd = endTim;
    newEvent.dateTimeBegin_multi = startTime;
    newEvent.dateTimeEnd_multi = endTim;
    [self processEvent:newEvent];
}

//Changes for multiday event for date range. Here we are removing events.
//Currently we are not using this method, It was impleted for multiday event with given Date range.
-(void)removeEventFromArray_EventWindow:(SMXEvent *)event numberOfDays:(int)numberOfDays{
    NSRange dateRange= [self eventWindow:event.dateTimeBegin_multi endDate:event.dateTimeEnd_multi];
    int length=(int)(dateRange.length);
    if (length>=0) {
        for (int i=(int)dateRange.location; i<(numberOfDays+length); i++) {
            if (i==0) {
                [self removeEventFromArray:event eventdate:[self changeTime:event.dateTimeBegin_multi newHour:23 newMin:59 numberOfday:i]];
            }else{
                [self removeEventFromArray:event eventdate:[self changeTime:event.dateTimeBegin_multi newHour:0 newMin:0 numberOfday:i]];
            }
        }
        [self removeEventFromArray:event eventdate:[self changeTime:event.dateTimeBegin_multi newHour:0 newMin:0 numberOfday:numberOfDays]];
    }else{
        for (int i=(int)dateRange.location; i<(numberOfDays+length+1); i++) {
            if (i==0) {
                [self removeEventFromArray:event eventdate:[self changeTime:event.dateTimeBegin_multi newHour:23 newMin:59 numberOfday:i]];
            }else{
                [self removeEventFromArray:event eventdate:[self changeTime:event.dateTimeBegin_multi newHour:0 newMin:0 numberOfday:i]];
            }
        }
        [self removeEventFromArray:event eventdate:[self changeTime:event.dateTimeBegin_multi newHour:0 newMin:0 numberOfday:numberOfDays]];
    }
    
}

-(void)removeEventFromArray:(SMXEvent *)event numberOfDays:(int)numberOfDays{
    //NSRange dateRange= [self eventWindow:event.dateTimeBegin_multi endDate:event.dateTimeEnd_multi];
    //int length=(int)(dateRange.length);
    for (int i=0; i<numberOfDays; i++) {
        if (i==0) {
            [self removeEventFromArray:event eventdate:[self changeTime:event.dateTimeBegin_multi newHour:23 newMin:59 numberOfday:i]];
        }else{
            [self removeEventFromArray:event eventdate:[self changeTime:event.dateTimeBegin_multi newHour:0 newMin:0 numberOfday:i]];
        }
    }
    [self removeEventFromArray:event eventdate:[self changeTime:event.dateTimeBegin_multi newHour:0 newMin:0 numberOfday:numberOfDays]];
}
-(void)removeEventFromArray:(SMXEvent *)multiDayEvent eventdate:(NSDate *)date{
    NSDateComponents *comp = [NSDate componentsOfDate:date];
    NSDate *newDate = [NSDate dateWithYear:comp.year month:comp.month day:comp.day];
    NSMutableArray *array = [eventDictinory objectForKey:newDate];
    for (SMXEvent *event in array) {
        if ([multiDayEvent.localID isEqualToString:event.localID]) {
            [array removeObject:event];
            break;
        }
    }
}

-(void)processEvent:(SMXEvent *)event_local{
    int numberOfdays=[self isMultidayEvent:event_local];
    if (numberOfdays>0) {
        event_local.isMultidayEvent=YES;
        [self makingEvent:event_local numberOfDays:numberOfdays];
    }else{
        event_local.dateTimeBegin_multi=event_local.dateTimeBegin;
        event_local.dateTimeEnd_multi=event_local.dateTimeEnd;
        event_local.isMultidayEvent=NO;
        [self addEventIntoArray:event_local];
    }
    [[SMXDateManager sharedManager] setDictEvents:eventDictinory];
    [[SMXCalendarViewController sharedInstance] resetloadAllView];
}

/*This method is responsible for multiday event condition*/
-(int)isMultidayEvent:(SMXEvent *)event{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"yyyy-MM-ddHH:mm:ss ZZZ"];
    NSDate *startDate = event.dateTimeBegin_multi;
    NSDate *endDate = event.dateTimeEnd_multi;
    if ([event.dateTimeBegin_multi isSameDay:event.dateTimeEnd_multi]) {
        return 0;
    }
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:0];
    if (components.day>0)
        return (int)components.day;
    else
        return 1;
    
    return 0;
}

+(int)isMultidayEvent:(NSDate *)startDate endDate:(NSDate *)endDate{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"yyyy-MM-ddHH:mm:ss ZZZ"];
    if ([startDate isSameDay:endDate]) {
        return 0;
    }
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:0];
    int i=(int)components.day;
    if (i>0) {
        if(i==0){
            NSDateComponents *Scomp = [NSDate componentsOfDate:startDate];
            NSDateComponents *Ecomp = [NSDate componentsOfDate:endDate];
            if (Scomp.day!=Ecomp.day) {
                return 1;
            }
        }
        return i;
    }
    return 0;
}

/*This method is responsible for filter event on event window range*/
-(NSRange )eventWindow:(NSDate *)startDate endDate:(NSDate *)endDate{
    int location=[self numberOfDate:startDate endDate:[[SMXDateManager sharedManager] getStartDateWindow]];
    int range=[self numberOfDate:endDate endDate:[[SMXDateManager sharedManager] getEndDateWindow]];
    if (location<0) {
        location=0;
    }
    if (range>0) {
        range=0;
    }else{
        
    }
    return NSMakeRange(location, range);
}

/*This method giving number of day diffrence beteen two date*/
-(int )numberOfDate:(NSDate *)startDate endDate:(NSDate *)endDate{
    if ((startDate !=nil) && (endDate!=nil)) {
        if ([startDate isSameDay:endDate]) {
            return 0;
        }
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit
                                                            fromDate:startDate
                                                              toDate:endDate
                                                             options:0];
        int i=(int)components.day;
        if(i==0){
            NSDateComponents *Scomp = [NSDate componentsOfDate:startDate];
            NSDateComponents *Ecomp = [NSDate componentsOfDate:endDate];
            if (Scomp.day!=Ecomp.day) {
                return 1;
            }
        }
        return i;
    }
    return 0;
}
+(NSDateComponents *)componentsOfDate:(NSDate *)date {
    
    //Time zone change for weekview change, here we are considering system reagion.
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp0 = [calender components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth| NSHourCalendarUnit |
                               NSMinuteCalendarUnit fromDate:date];
    return comp0;
}

/*Here we are spliting multiDay event and making each day event, adding into locat Model and DB */
//Currently we are not using this method, It was impleted for multiday event with given Date range.
-(void)makingEvent_DateWindow:(SMXEvent *)multiDayEvent numberOfDays:(int)numberOfDays{
    NSRange dateRange= [self eventWindow:multiDayEvent.dateTimeBegin endDate:multiDayEvent.dateTimeEnd];
    int length=(int)(dateRange.length);
    int location=(int)(dateRange.location);
    if (length>=0) {
        for (int i=0; i<numberOfDays; i++) {
            SMXEvent *newEvent =[[SMXEvent alloc] initWithCalendarModel_self:multiDayEvent];
            newEvent.dateTimeBegin_multi=multiDayEvent.dateTimeBegin;
            newEvent.dateTimeEnd_multi=multiDayEvent.dateTimeEnd;
            newEvent.isMultidayEvent=YES;
            if (i==0) {
                 /* This is for First day of the event */
                newEvent.dateTimeBegin=multiDayEvent.dateTimeBegin;
                newEvent.dateTimeEnd=[self changeTime:multiDayEvent.dateTimeBegin newHour:23 newMin:59 numberOfday:i];
            }else{
                newEvent.dateTimeBegin=[self changeTime:multiDayEvent.dateTimeBegin newHour:0 newMin:0 numberOfday:i];
                newEvent.dateTimeEnd=[self changeTime:multiDayEvent.dateTimeBegin newHour:23 newMin:59 numberOfday:i];
            }
            newEvent.eventIndex=i;
            newEvent.numberOfDays=numberOfDays+1;
            newEvent.duration = [newEvent.dateTimeEnd timeIntervalSinceDate:newEvent.dateTimeBegin]/60;  //NEW BSP
            [self makingEventObjects:newEvent];
            if (i>=location && i<=(numberOfDays+length)) {
                [self addEventIntoArray:newEvent];
            }
        }
        /* This is for last day of the event */
        SMXEvent *newEvent =[[SMXEvent alloc] initWithCalendarModel_self:multiDayEvent];
        newEvent.dateTimeBegin_multi=multiDayEvent.dateTimeBegin;
        newEvent.dateTimeEnd_multi=multiDayEvent.dateTimeEnd;
        newEvent.isMultidayEvent=YES;
        newEvent.dateTimeBegin=[self changeTime:multiDayEvent.dateTimeBegin newHour:0 newMin:0 numberOfday:numberOfDays];
        newEvent.dateTimeEnd=multiDayEvent.dateTimeEnd;
        newEvent.eventIndex=numberOfDays;
        newEvent.numberOfDays=numberOfDays+1;
        newEvent.duration = [newEvent.dateTimeEnd timeIntervalSinceDate:newEvent.dateTimeBegin]/60;  //NEW BSP
        [self makingEventObjects:newEvent];
        if (length==0) {
            [self addEventIntoArray:newEvent];
        }
    }else{
        for (int i=0; i<numberOfDays; i++) {
            SMXEvent *newEvent =[[SMXEvent alloc] initWithCalendarModel_self:multiDayEvent];
            newEvent.dateTimeBegin_multi=multiDayEvent.dateTimeBegin;
            newEvent.dateTimeEnd_multi=multiDayEvent.dateTimeEnd;
            newEvent.isMultidayEvent=YES;
            if (i==0) {
                 /* This is for first day of the event */
                newEvent.dateTimeBegin=multiDayEvent.dateTimeBegin;
                newEvent.dateTimeEnd=[self changeTime:multiDayEvent.dateTimeBegin newHour:23 newMin:59 numberOfday:i];
            }else{
                newEvent.dateTimeBegin=[self changeTime:multiDayEvent.dateTimeBegin newHour:0 newMin:0 numberOfday:i];
                newEvent.dateTimeEnd=[self changeTime:multiDayEvent.dateTimeBegin newHour:23 newMin:59 numberOfday:i];
            }
            newEvent.eventIndex=i;
            newEvent.numberOfDays=numberOfDays+1;
            newEvent.duration = [newEvent.dateTimeEnd timeIntervalSinceDate:newEvent.dateTimeBegin]/60;  //NEW BSP
            [self makingEventObjects:newEvent];
            if (i>=location && i<=(numberOfDays+length)) {
                [self addEventIntoArray:newEvent];
            }
        }
         /* This is for last day of the event */
        SMXEvent *newEvent =[[SMXEvent alloc] initWithCalendarModel_self:multiDayEvent];
        newEvent.dateTimeBegin_multi=multiDayEvent.dateTimeBegin;
        newEvent.dateTimeEnd_multi=multiDayEvent.dateTimeEnd;
        newEvent.isMultidayEvent=YES;
        newEvent.dateTimeBegin=[self changeTime:multiDayEvent.dateTimeBegin newHour:0 newMin:0 numberOfday:numberOfDays];
        newEvent.dateTimeEnd=multiDayEvent.dateTimeEnd;
        newEvent.eventIndex=numberOfDays;
        newEvent.numberOfDays=numberOfDays+1;
        newEvent.duration = [newEvent.dateTimeEnd timeIntervalSinceDate:newEvent.dateTimeBegin]/60;  //NEW BSP
        [self makingEventObjects:newEvent];
        if (length==0) {
            [self addEventIntoArray:newEvent];
        }
    }
}

-(void)makingEvent:(SMXEvent *)multiDayEvent numberOfDays:(int)numberOfDays{
    for (int i=0; i<numberOfDays; i++) {
        SMXEvent *newEvent =[[SMXEvent alloc] initWithCalendarModel_self:multiDayEvent];
        newEvent.dateTimeBegin_multi=multiDayEvent.dateTimeBegin;
        newEvent.dateTimeEnd_multi=multiDayEvent.dateTimeEnd;
        newEvent.isMultidayEvent=YES;
        if (i==0) {
            /* This is for First day of the event */
            newEvent.dateTimeBegin=multiDayEvent.dateTimeBegin;
            newEvent.dateTimeEnd=[self changeTime:multiDayEvent.dateTimeBegin newHour:23 newMin:59 numberOfday:i];
        }else{
            newEvent.dateTimeBegin=[self changeTime:multiDayEvent.dateTimeBegin newHour:0 newMin:0 numberOfday:i];
            newEvent.dateTimeEnd=[self changeTime:multiDayEvent.dateTimeBegin newHour:23 newMin:59 numberOfday:i];
        }
        newEvent.eventIndex=i;
        newEvent.numberOfDays=numberOfDays+1;
        newEvent.duration = [newEvent.dateTimeEnd timeIntervalSinceDate:newEvent.dateTimeBegin]/60;  //NEW BSP
        [self makingEventObjects:newEvent];
        [self addEventIntoArray:newEvent];
    }
    /* This is for last day of the event */
    SMXEvent *newEvent =[[SMXEvent alloc] initWithCalendarModel_self:multiDayEvent];
    newEvent.dateTimeBegin_multi=multiDayEvent.dateTimeBegin;
    newEvent.dateTimeEnd_multi=multiDayEvent.dateTimeEnd;
    newEvent.isMultidayEvent=YES;
    newEvent.dateTimeBegin=[self changeTime:multiDayEvent.dateTimeBegin newHour:0 newMin:0 numberOfday:numberOfDays];
    newEvent.dateTimeEnd=multiDayEvent.dateTimeEnd;
    newEvent.eventIndex=numberOfDays;
    newEvent.numberOfDays=numberOfDays+1;
    newEvent.duration = [newEvent.dateTimeEnd timeIntervalSinceDate:newEvent.dateTimeBegin]/60;  //NEW BSP
    [self makingEventObjects:newEvent];
    [self addEventIntoArray:newEvent];
}
-(void)makingEventObjects:(SMXEvent *)localEvent{
    [self createObjectWithEvnet:localEvent]; //Making model of the day for DB, Adding thging into db.
}
-(void)createObjectWithEvnet:(SMXEvent *)eventLocal{
    NSMutableDictionary *eventObject = [NSMutableDictionary new];
    NSString *startDateString = [self dateForTheString:eventLocal.dateTimeBegin];
    NSString *endDateString = [self dateForTheString:eventLocal.dateTimeEnd];
    
    if ([eventLocal.eventTableName isEqualToString:kSVMXTableName]){
        [eventObject setObject:startDateString forKey:kSVMXStartDateTime];
        [eventObject setObject:endDateString forKey:kSVMXEndDateTime];
        [eventObject setObject:[NSString stringWithFormat:@"%d",eventLocal.numberOfDays] forKey:kEventNumber];
        [eventObject setObject:[NSString stringWithFormat:@"%d",eventLocal.eventIndex] forKey:kEventIndex];
        [eventObject setObject:[NSString stringWithFormat:@"%f",eventLocal.duration] forKey:kSVMXDurationInMinutes];
    }else{
        [eventObject setObject:startDateString forKey:kStartDateTime];
        [eventObject setObject:endDateString forKey:kEndDateTime];
        [eventObject setObject:[NSString stringWithFormat:@"%d",eventLocal.numberOfDays] forKey:kEventNumber];
        [eventObject setObject:[NSString stringWithFormat:@"%d",eventLocal.eventIndex] forKey:kEventIndex];
        [eventObject setObject:[NSString stringWithFormat:@"%f", eventLocal.duration] forKey:kDurationInMinutes];
    }
    [eventObjects addObject:eventObject];
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

/*Here changing date , adding number of day*/
-(NSDate *)changeTime:(NSDate *)date newHour:(int )hour newMin:(int)min numberOfday:(int)numberOfDay{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp = [cal components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    comp.hour = hour;
    comp.minute = min;
    comp.second = 00;
    NSDate *sevenDaysAgo = [[cal dateFromComponents:comp] dateByAddingTimeInterval:numberOfDay*24*60*60];
    return sevenDaysAgo;
}

/*Adding event into array, if array is exist then adding event other wise creating*/
-(void)addEventIntoArray:(SMXEvent *)multiDayEvent{
    NSDateComponents *comp = [NSDate componentsOfDate:multiDayEvent.dateTimeBegin];
    NSDate *newDate = [NSDate dateWithYear:comp.year month:comp.month day:comp.day];
    NSMutableArray *array = [eventDictinory objectForKey:newDate];
    if (!array) {
        array = [NSMutableArray new];
        [eventDictinory setObject:array forKey:newDate];
    }
    if (![array containsObject:multiDayEvent]) {
        [array addObject:multiDayEvent];
        NSSortDescriptor *eventStartDateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateTimeBegin_multi" ascending:YES];
        NSSortDescriptor *eventDurationSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"duration" ascending:YES];
        array = (NSMutableArray *)[array sortedArrayUsingDescriptors:[NSArray arrayWithObjects:eventStartDateSortDescriptor, eventDurationSortDescriptor, nil]];
        NSMutableArray *sortedArray = [[NSMutableArray alloc] initWithArray:array];
        [eventDictinory setObject:sortedArray forKey:newDate];
    }
}


@end
