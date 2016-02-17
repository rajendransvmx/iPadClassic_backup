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
#import "DateUtil.h"

@implementation SMXEvent

@synthesize title;
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
@synthesize dateTimeBegin_multi;
@synthesize dateTimeEnd_multi;
@synthesize isMultidayEvent;
@synthesize eventIndex;
@synthesize numberOfDays;
@synthesize duration;

@synthesize eventTableName;
@synthesize eventType;
@synthesize isAllDay;
@synthesize priorityString;

/* This method responsible for creating event model from DB */
-(SMXEvent *) initWithEventTransactionObjectModel:(EventTransactionObjectModel *)model
{
    if (self = [super init]) {
        
        NSString *key_LocalID;
        NSString *key_ID;
        NSString *key_WhatID;
        NSString *key_StartDateTime;
        NSString *key_EndDateTime;
        NSString *key_ActivityDate;
        NSString *key_ActivityDateTime;
        NSString *key_Title;
        NSString *key_Description;
        NSString *key_Duration;
        NSString *key_IsAllDay;

        if ([model.objectAPIName isEqualToString:kSVMXTableName])
        {
            key_LocalID = kSVMXlocalId;
            key_ID = kSVMXID;
            key_WhatID = kObjectSfId;
            key_StartDateTime = kSVMXStartDateTime;
            key_EndDateTime = kSVMXEndDateTime;
            key_ActivityDate = kSVMXActivityDate;
            key_ActivityDateTime = kSVMXActivityDateTime;
            key_Title = kSVMXEventName;
            key_Description = kSVMXEventDescription;
            key_Duration = kSVMXDurationInMinutes;
            key_IsAllDay = kSVMXIsAlldayEvent;
        }
        else
        {
            key_LocalID = klocalId;
            key_ID = kId;
            key_WhatID = kWhatId;
            key_StartDateTime = kStartDateTime;
            key_EndDateTime = kEndDateTime;
            key_ActivityDate = kActivityDate;
            key_ActivityDateTime = kActivityDateTime;
            key_Title = kSubject;
            key_Description = kEventDescription;
            key_Duration = kDurationInMinutes;
            key_IsAllDay = kIsAlldayEvent;

        }
        
        NSDictionary *dict = [model getFieldValueDictionary];
        BOOL isAllday = [[dict objectForKey:key_IsAllDay] boolValue];
        
        NSDate *startDate;
        NSDate *endDate;
        if (isAllday) {
            
            NSDictionary *dateArray = [self getDateForAllDayEventOnDate:[dict objectForKey:key_StartDateTime] endDate:[dict objectForKey:key_EndDateTime]];
            startDate = [dateArray objectForKey:@"startDate"];
            endDate = [dateArray objectForKey:@"endDate"];
        }
        else
        {
            startDate = [CalenderHelper getStartEndDateTime:[dict objectForKey:key_StartDateTime]];
            endDate = [CalenderHelper getStartEndDateTime:[dict objectForKey:key_EndDateTime]];
 
        }
        
        self.localID = [dict objectForKey:key_LocalID];
        self.IDString = [dict objectForKey:key_ID];
        self.whatId = [dict objectForKey:key_WhatID];
        
        self.subject = [dict objectForKey:key_Title];
        self.title = [dict objectForKey:@"eventTitle"];

        self.description = [dict objectForKey:key_Description];
        self.sla = NO;
        self.priority = NO;
        self.conflict = NO;
        self.newData = NO;
        
        self.dateTimeBegin = startDate;
        self.ActivityDateDay = [self getActivityDate:startDate];
        self.dateTimeBegin_multi = startDate;
        self.dateTimeEnd_multi= endDate;
        self.dateTimeEnd = endDate;
        self.duration = [endDate timeIntervalSinceDate: startDate]/60;
        
        self.isWorkOrder = ([dict objectForKey:@"isWorkOrder"]? YES:NO);
        self.isCaseEvent = ([dict objectForKey:@"isCaseEvent"]? YES:NO);
        self.eventTableName = model.objectAPIName;
        self.isAllDay = isAllday;
        
    }
    return self;
}

// CALLED FROM MULTIDAY
/* This method responsible for creating multiday event model from DB */
-(SMXEvent *) initWithEventWithKeyValue:(NSMutableDictionary *)dict EventTransactionObjectModel:(EventTransactionObjectModel *)model
{
    if (self = [super init]) {
        
        NSString *key_LocalID;
        NSString *key_ID;
        NSString *key_WhatID;
        NSString *key_StartDateTime;
        NSString *key_EndDateTime;
        NSString *key_ActivityDate;
        NSString *key_ActivityDateTime;
        NSString *key_Title;
        NSString *key_Description;
        NSString *key_Duration;
        NSString *key_IsAllDay;

        
        if ([model.objectAPIName isEqualToString:kSVMXTableName])
        {
            key_LocalID = kSVMXlocalId;
            key_ID = kSVMXID;
            key_WhatID = kObjectSfId;
            key_StartDateTime = kSVMXStartDateTime;
            key_EndDateTime = kSVMXEndDateTime;
            key_ActivityDate = kSVMXActivityDate;
            key_ActivityDateTime = kSVMXActivityDateTime;
            key_Title = kSVMXEventName;
            key_Description = kSVMXEventDescription;
            key_Duration = kSVMXDurationInMinutes;
            key_IsAllDay = kSVMXIsAlldayEvent;
        }
        else
        {
            key_LocalID = klocalId;
            key_ID = kId;
            key_WhatID = kWhatId;
            key_StartDateTime = kStartDateTime;
            key_EndDateTime = kEndDateTime;
            key_ActivityDate = kActivityDate;
            key_ActivityDateTime = kActivityDateTime;
            key_Title = kSubject;
            key_Description = kEventDescription;
            key_Duration = kDurationInMinutes;
            key_IsAllDay = kIsAlldayEvent;

        }
        BOOL isAllday = [[dict objectForKey:key_IsAllDay] boolValue];

        
        NSDate *startDate;
        NSDate *endDate;
        if (isAllday) {
            
            NSDictionary *dateArray = [self getDateForAllDayEventOnDate:[dict objectForKey:key_StartDateTime] endDate:[dict objectForKey:key_EndDateTime]];
            startDate = [dateArray objectForKey:@"startDate"];
            endDate = [dateArray objectForKey:@"endDate"];
        }else
        {
            startDate = [CalenderHelper getStartEndDateTime:[dict objectForKey:key_StartDateTime]];
            endDate = [CalenderHelper getStartEndDateTime:[dict objectForKey:key_EndDateTime]];
            
        }
        self.localID = [dict objectForKey:key_LocalID];
        self.IDString = [dict objectForKey:key_ID];
        self.whatId = [dict objectForKey:key_WhatID];
        
        self.subject = [dict objectForKey:key_Title];
        self.title = [dict objectForKey:@"eventTitle"];
        self.description = [dict objectForKey:key_Description];
        self.sla = NO;
        self.priority = NO;
        self.conflict = NO;
        self.newData = NO;
        
        self.dateTimeBegin = startDate;
        self.ActivityDateDay = [self getActivityDate:startDate];
        self.dateTimeBegin_multi = startDate;
        self.dateTimeEnd_multi= endDate;
        self.dateTimeEnd = endDate;
        self.duration = [endDate timeIntervalSinceDate: startDate]/60;
        
        self.isWorkOrder = ([dict objectForKey:@"isWorkOrder"]? YES:NO);
        self.isCaseEvent = ([dict objectForKey:@"isCaseEvent"]? YES:NO);
        self.eventTableName = model.objectAPIName;
        self.isAllDay=isAllday;

    }
    return self;
}

/* multiday event part, making multiday event into each day event */
-(SMXEvent *)initWithCalendarModel_self:(SMXEvent*)model
{
    self.localID = model.localID;
    self.IDString = model.IDString;
    self.subject = model.subject;
    self.title = model.title;
    self.description = model.description;
    self.whatId = model.whatId;
    self.sla = model.sla;
    self.priority = model.priority;
    self.conflict = model.conflict;
    self.newData = NO;
    self.dateTimeBegin = model.dateTimeBegin;
    self.dateTimeBegin_multi=model.dateTimeBegin;
    self.dateTimeEnd_multi=model.dateTimeEnd;
    self.ActivityDateDay =model.ActivityDateDay;
    self.dateTimeEnd = model.dateTimeEnd;
    self.duration = model.duration;
    self.isWorkOrder = model.isWorkOrder;
    self.isCaseEvent = model.isCaseEvent;
    self.eventTableName = model.eventTableName;
    self.eventType = model.eventType;
    self.isMultidayEvent = NO;
    self.eventIndex=model.eventIndex;
    self.isAllDay=model.isAllDay;

    return self;
}

-(NSDate *)getActivityDate:(NSDate *)date
{
    NSDateComponents *comp = [NSDate componentsOfDate:date];
    NSDate *newDate = [NSDate dateWithYear:comp.year month:comp.month day:comp.day];
    return newDate;
}

-(NSDictionary *)getDateForAllDayEventOnDate:(NSString *)startDate endDate:(NSString *)endDate{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSDateComponents *comp;
    if (startDate) {
        NSDateComponents *comp = [cal components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[self dateFromString:startDate]];
    
        comp.second = 00;
        comp.hour = 00;
        comp.minute = 00;
    
        NSDate *theStartDate = [cal dateFromComponents:comp];
        if (theStartDate)
            [dict setObject:theStartDate forKey:@"startDate"];
    }
    
    if (endDate) {
        comp = [cal components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[self dateFromString:endDate]];
        comp.hour = 23;
        comp.minute = 59;
        
        NSDate *theEndDate = [cal dateFromComponents:comp];
        if (theEndDate)
            [dict setObject:theEndDate forKey:@"endDate"];
    }
    return dict;
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

-(void)explainMe;
{
   SXLogInfo(@"IDString: %@, localID : %@, dateTimeBegin: %@ , dateTimeEnd : %@ billingType :%@", IDString, localID, dateTimeBegin, dateTimeEnd, billingType);
}



- (id)copyWithZone:(NSZone *)zone{
    id copy = [[[self class] alloc] init];
    if (copy)
    {
        
    }
    return copy;
}

-(void)convertDateForAllDay{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp = [cal components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self.dateTimeBegin_multi];
    
    comp.second = 00;
    comp.hour = 00;
    comp.minute = 00;
    
    self.dateTimeBegin_multi = [cal dateFromComponents:comp];
    self.dateTimeBegin= [cal dateFromComponents:comp];
    comp = [cal components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self.dateTimeEnd_multi];
    comp.hour = 23;
    comp.minute = 59;
    
    self.dateTimeEnd_multi = [cal dateFromComponents:comp];
    self.dateTimeEnd= [cal dateFromComponents:comp];
}
@end
