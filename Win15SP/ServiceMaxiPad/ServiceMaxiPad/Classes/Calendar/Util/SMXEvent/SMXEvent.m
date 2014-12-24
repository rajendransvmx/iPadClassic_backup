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
        self.ActivityDateDay = [self getActivityDate:lActivityDate];
        self.dateTimeBegin = [self getStartEndDateTime:lStartDateTime];
        self.dateTimeEnd = [self getStartEndDateTime:lEndDateTime];
//        self.cWorkOrderSummaryModel = model.cWorkOrderSummaryModel;
        self.isWorkOrder = model.isWorkOrder;
        self.isCaseEvent = model.isCaseEvent;
    }
    return self;
    
}

-(NSDate *)getActivityDate:(NSString *)dateString
{
    NSDateFormatter * lDF = [[NSDateFormatter alloc] init];
    [lDF setDateFormat: @"yyyy-MM-dd 00:00:00"];
    return [lDF dateFromString:dateString];
    

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
    
    return [lDF dateFromString:lTempDateTime];
}

-(void)explainMe;
{
   SXLogInfo(@"IDString: %@, localID : %@, dateTimeBegin: %@ , dateTimeEnd : %@ billingType :%@", IDString, localID, dateTimeBegin, dateTimeEnd, billingType);
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
