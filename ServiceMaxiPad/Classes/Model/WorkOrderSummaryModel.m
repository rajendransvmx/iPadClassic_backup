//
//  WorkOrderSummaryModel.m
//  ServiceMaxMobile
//
//  Created by Anoop on 9/19/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "WorkOrderSummaryModel.h"
#import "TransactionObjectModel.h"
#import "ServiceLocationModel.h"
#import "DateUtil.h"
#import "StringUtil.h"
#import "CalenderHelper.h"

@implementation WorkOrderSummaryModel

- (id)initWithTransactionModel:(TransactionObjectModel*)transactionModel andIdEventStartValueMap:(NSMutableDictionary*)idEventStartValueMap
{
    self = [super init];
    if (self)
    {
        self.Id                = [transactionModel valueForField:kId];
        self.contactId         = [transactionModel valueForField:kWorkOrderContactId];
        self.localId           = [transactionModel valueForField:klocalId];
        self.name              = [transactionModel valueForField:kWorkOrderName];
        self.companyId         = [transactionModel valueForField:kWorkOrderCompanyId];
        self.companyName       = @"";
        self.gmtScheduledDateTime = [transactionModel valueForField:kWorkOrderScheduledDateTime];
        self.purposeOfVisit    = [transactionModel valueForField:kWorkOrderPurposeOfVisit];
        self.problemDescription= [transactionModel valueForField:kWorkOrderProblemDescription];
        self.priorityString    = [transactionModel valueForField:kWorkOrderPriority];
        self.priority          = [self getPriorityForString:self.priorityString];
        NSDictionary *tempDict = [idEventStartValueMap objectForKey:self.Id];

        if (![StringUtil isStringEmpty:self.Id])
        {
            if ([tempDict isKindOfClass:[NSDictionary class]]) {

                self.gmtEventStartDateTime = [tempDict objectForKey:self.Id];
            }
            else
            {
                self.gmtEventStartDateTime = [idEventStartValueMap objectForKey:self.Id];
            }
        }
        if (![StringUtil isStringEmpty:self.gmtEventStartDateTime]) {
            

            if ([tempDict isKindOfClass:[NSDictionary class]]) {
                NSString *isAllday = [tempDict objectForKey:kGENERAL_ALL_DAY];
                
                if ([isAllday caseInsensitiveCompare:@"true"] == NSOrderedSame || [isAllday isEqualToString:@"1"]) {
                    
                    self.localEventStartDateTime = [self allDayEventStartDateTime:self.gmtEventStartDateTime];
                    
                }
                else
                    self.localEventStartDateTime = [self getLocalTimeFromGMT:self.gmtEventStartDateTime];

            }
           
            else
            {
                self.localEventStartDateTime = [self getLocalTimeFromGMT:self.gmtEventStartDateTime];

            }
            
                
                
        }
        if (![StringUtil isStringEmpty:self.gmtScheduledDateTime]) {
            self.localScheduleDateTime = [self getLocalTimeFromGMT:self.gmtScheduledDateTime];
        }
        self.serviceLocationModel = [[ServiceLocationModel alloc] initWithTransactionModel:transactionModel];
        self.billingType = [transactionModel valueForField:kWorkOrderBillingType];
        self.orderStatus = [transactionModel valueForField:kWorkOrderOrderStatus];
        self.site = [transactionModel valueForField:kWorkOrderSite];

    }
    return self;
}

- (NSString *)getLocalTimeFromGMT:(NSString *)gmtDate
{
    /* Problem with DaylightSaving. Hence, changed. _BSP 30-Mar-2015
     
    NSDate *gmtDateTime = [DateUtil dateFromString:gmtDate inFormat:kDateFormatDefault];
    NSDate *localDateTime = [DateUtil localDateForGMTDate:gmtDateTime];
    NSString *localDateTimeStr = [DateUtil stringFromDate:localDateTime inFormat:[DateUtil getUserTimeFormat]];
//     return localDateTimeStr;
    
    */
    NSDate *theDate =  [CalenderHelper getStartEndDateTime:gmtDate]; //[self theStartDate:gmtDate];
    NSString *localDateTimeStr1 = [DateUtil stringFromDate:theDate inFormat:[DateUtil getUserTimeFormat]];

    return localDateTimeStr1;
}

- (NSNumber*)getPriorityForString:(NSString*)priorityString {
    
    priorityString = [priorityString uppercaseString];
    
    if ([priorityString isEqualToString:@"HIGH"])
        return [NSNumber numberWithInteger:PriorityHigh];
    else if ([priorityString isEqualToString:@"MEDIUM"])
        return [NSNumber numberWithInteger:PriorityMedium];
    else //if ([priorityString isEqualToString:@"LOW"])
        return [NSNumber numberWithInteger:PriorityLow];

}

-(NSString *)allDayEventStartDateTime:(NSString *)lTempDateTime
{
    lTempDateTime = [lTempDateTime substringToIndex:[lTempDateTime rangeOfString:@"T"].location];
    
    NSDateFormatter *lDF = [[NSDateFormatter alloc] init];
    [lDF setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *date = [lDF dateFromString:lTempDateTime];
    
    [lDF setDateFormat:@"EE, dd MMM yyyy 00:00:00 aaa"];
    [lDF setAMSymbol:@"AM"];
    [lDF setPMSymbol:@"PM"];
    
    NSString *dateString =  [lDF stringFromDate:date];
    
    return dateString;
    
}

-(NSString *)theStartDate:(NSString *)startDateString
{
    NSDate *theDate = [CalenderHelper getStartEndDateTime:startDateString];
    
    NSDateFormatter *lDF = [[NSDateFormatter alloc] init];
    [lDF setDateFormat:[DateUtil getUserTimeFormat]];
    
    NSString *date = [lDF stringFromDate:theDate];
    return date;
}
- (void)explainMe
{
//    NSLog(@"Id : %@ \n contactId : %@ \n localId : %@ \n companyName : %@ \n GMTscheduledDateTime : %@ \n GMTeventStartDateTime : %@ \n purposeOfVisit : %@ \n   problemDescription : %@ \n priority : %@ %@ \n eventStartDateTime : %@ \n scheduledDateTime : %@ \n localEventStartDateTime : %@ \n localScheduleDateTime : %@ \n",_Id, _contactId, _localId, _companyName, _gmtScheduledDateTime, _gmtEventStartDateTime, _purposeOfVisit, _problemDescription, _priorityString, _priority,_eventStartDateTime, _scheduledDateTime, _localEventStartDateTime, _localScheduleDateTime);
}


@end


