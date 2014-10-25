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
        if ([self.Id length])
            self.gmtEventStartDateTime = [idEventStartValueMap objectForKey:self.Id];
        self.localEventStartDateTime = [self localTimeStringFromGMT:self.gmtEventStartDateTime withFormat:@"MMM dd, YYYY, hh:mma"];
        self.localScheduleDateTime = [self localTimeStringFromGMT:self.gmtScheduledDateTime withFormat:@"MMM dd, YYYY, hh:mma"];
        self.eventStartDateTime = [self getGMTDateForString:self.gmtEventStartDateTime];
        self.scheduledDateTime = [self getGMTDateForString:self.gmtScheduledDateTime];
        self.serviceLocationModel = [[ServiceLocationModel alloc] initWithTransactionModel:transactionModel];
    }
    return self;
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

- (void)explainMe
{
    NSLog(@"Id : %@ \n contactId : %@ \n localId : %@ \n companyName : %@ \n GMTscheduledDateTime : %@ \n GMTeventStartDateTime : %@ \n purposeOfVisit : %@ \n   problemDescription : %@ \n priority : %@ %@ \n eventStartDateTime : %@ \n scheduledDateTime : %@ \n localEventStartDateTime : %@ \n localScheduleDateTime : %@ \n",_Id, _contactId, _localId, _companyName, _gmtScheduledDateTime, _gmtEventStartDateTime, _purposeOfVisit, _problemDescription, _priorityString, _priority,_eventStartDateTime, _scheduledDateTime, _localEventStartDateTime, _localScheduleDateTime);
}

- (NSString*)localTimeStringFromGMT:(NSString*)timestamp withFormat:(NSString*)format {
    
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSString *dateString = nil;
    
    NSDate *date = [self getGMTDateForString:timestamp];
    NSDateFormatter *localDateFormatter = [[NSDateFormatter alloc] init];
    [localDateFormatter setDateFormat:format];
    [localDateFormatter setTimeZone:localTimeZone];
    [localDateFormatter setLocale:locale];
    dateString = [localDateFormatter stringFromDate:date];
    return dateString;
    
}

- (NSDate*)getGMTDateForString:(NSString*)dateString {
    
    NSTimeZone *gmtTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDate *date = nil;
    
    NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
    [gmtDateFormatter setDateStyle:NSDateFormatterFullStyle];
    [gmtDateFormatter setTimeZone:gmtTimeZone];
    [gmtDateFormatter setLocale:locale];
    date = [gmtDateFormatter dateFromString:dateString];
    return date;
    
}

@end


