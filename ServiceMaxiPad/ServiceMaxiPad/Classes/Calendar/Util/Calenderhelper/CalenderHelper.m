//
//  CalenderHelper.m
//  ServiceMaxMobile
//
//  Created by Sudguru Prasad on 07/10/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "CalenderHelper.h"
#import "SFObjectService.h"
#import "FactoryDAO.h"
#import "NSDate+TKCategory.h"
#import "TransactionObjectService.h"
#import "TransactionObjectDAO.h"
#import "TransactionObjectModel.h"
#import "WorkOrderSummaryModel.h"
#import "ContactImageModel.h"
#import "DateUtil.h"
#import "TagManager.h"
#import "NonTagConstant.h"
#import "DatabaseConstant.h"

#import "CalenderDAO.h"
#import "CalenderEventObjectModel.h"
#import "CalenderEventObjectService.h"

#import "CustomerOrgInfo.h"


#import "SFObjectDAO.h"
#import "SFObjectService.h"

#import "MobileDeviceSettingDAO.h"
#import "MobileDeviceSettingService.h"
#import "MobileDeviceSettingsModel.h"

#import "StringUtil.h"
#import "ModifiedRecordModel.h"
#import "SyncManager.h"


#import "ModifiedRecordsService.h"
#import "ServiceLocationModel.h"

#import "SFChildRelationshipDAO.h"
#import "SFChildRelationshipModel.h"

#import "SyncErrorConflictDAO.h"
#import "SyncErrorConflictModel.h"

#import "ObjectNameFieldValueDAO.h"
#import "SuccessiveSyncManager.h"

@interface CalenderHelper ()

+ (NSArray *)fetchDataForObject:(NSString *)objectName
                         fields:(NSArray *)fieldNames
                     expression:(NSString *)advancaeExpression
                       criteria:(NSArray *)criteria;
+ (NSMutableArray*)getWorkOrdersForWhatIds:(NSMutableDictionary*)whatEventStartDateValueMap;
@property (nonatomic, strong) NSString *cRangeOfDaysString;
@property (nonatomic, strong) NSMutableDictionary *cLocalIDandAssociatedWhatID;
@end

@implementation CalenderHelper
@synthesize cRangeOfDaysString;
@synthesize cLocalIDandAssociatedWhatID;

+ (NSArray *)fetchDataForObject:(NSString *)objectName
                         fields:(NSArray *)fieldNames
                     expression:(NSString *)advancaeExpression
                       criteria:(NSArray *)criteria
{
    id <CalenderDAO> CalEventService = [FactoryDAO serviceByServiceType:ServiceCalenderEventList];
    
    
    NSArray *dataArray = [CalEventService fetchDataForObject:objectName fields:fieldNames expression:advancaeExpression criteria:criteria];
    
    return dataArray;
}

+(NSDictionary *)fetchSFObjectTableDataForFields:(NSArray *)fields criteria:(NSArray *)criteria andExpression: (NSString *)expression
{
    
    
    id <CalenderDAO> CalEventService = [FactoryDAO serviceByServiceType:ServiceCalenderEventList];
    
    
    NSDictionary *lDataDict = [CalEventService fetchSFObjectTableDataForFields:fields criteria:criteria andExpression:expression];
    
    return lDataDict;
}

+ (NSArray *)fetchDataFromWorkOrderObject:(NSString *)objectName
                                   fields:(NSArray *)fieldNames
                               expression:(NSString *)advancaeExpression
                                 criteria:(NSArray *)criteria
{
    id <TransactionObjectDAO> transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    NSArray *dataArray = [transactionService fetchDataForObject:objectName fields:fieldNames expression:advancaeExpression criteria:criteria];
    return dataArray;
}

+(NSString *)fetchSyncDayRange
{
    id <MobileDeviceSettingDAO> mobileSettingService = [FactoryDAO serviceByServiceType:ServiceTypeMobileDeviceSettings];
    
    MobileDeviceSettingsModel *lMobileDeviceSettingsModel = [mobileSettingService fetchDataForSettingId:@"Synchronization To Get Events"];
    
    return lMobileDeviceSettingsModel.value;
}


+ (ContactImageModel *)getContactObjectForId:(NSString *)contactId {
    
    id <TransactionObjectDAO> transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorEqual andFieldValue:contactId];
    NSArray *fieldsArray = [[NSArray alloc] initWithObjects:kId,kContactName,kContactEmail,kContactPhone,kContactMobilePhone, nil];
    TransactionObjectModel *transModel = [transactionService getDataForObject:kContactTableName fields:fieldsArray expression:nil criteria:[NSArray arrayWithObject:criteria]];
    ContactImageModel *contactModel = [[ContactImageModel alloc] initWithTransactionModel:transModel];
    return contactModel;
    
}

+ (NSString*)prefixForWorkOrder {
    
    
    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:kWorkOrderTableName];
    
    id <SFObjectDAO> objectService = [FactoryDAO serviceByServiceType:ServiceTypeSFObject];
    
    SFObjectModel *model = [objectService getSFObjectInfo:criteria fieldName:[NSArray arrayWithObject:@"keyPrefix"]];
    
    if (model != nil) {
        return model.keyPrefix;
    }
    
    return nil;
    
}

- (NSArray*) workOrderSummaryArrayOfDay:(NSDate *)date;
{
    NSArray *eventsArray = [[self class] eventsOfDay:date];
    NSMutableDictionary *whatEventStartDateValueMap = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    for (TransactionObjectModel *transObjModel in eventsArray) {
        NSString *whatId = [transObjModel valueForField:kWhatId];
        if ([whatId length])
            [whatEventStartDateValueMap setValue:[transObjModel valueForField:kStartDateTime] forKey:whatId];
    }
    
    NSMutableArray *workOrderSummaryArray = [[self class] getWorkOrdersForWhatIds:whatEventStartDateValueMap];
    NSSortDescriptor *eventStartDateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"eventStartDateTime"
                                                                                   ascending:YES];
    NSSortDescriptor *prioritySortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"priority"
                                                                             ascending:YES];
    NSArray *sortedArray = [workOrderSummaryArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:eventStartDateSortDescriptor, prioritySortDescriptor, nil]];
    return sortedArray;

}

+ (NSArray*)workOrderSummaryArrayOfCurrentDay {
    
    NSArray *eventsArray = [self eventsOfCurrentDay];
    NSMutableDictionary *whatEventStartDateValueMap = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    for (TransactionObjectModel *transObjModel in eventsArray) {
        NSString *whatId = [transObjModel valueForField:kWhatId];
        if ([whatId length])
            [whatEventStartDateValueMap setValue:[transObjModel valueForField:kStartDateTime] forKey:whatId];
    }
    
    NSMutableArray *workOrderSummaryArray = [self getWorkOrdersForWhatIds:whatEventStartDateValueMap];
    NSSortDescriptor *eventStartDateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"eventStartDateTime" ascending:YES];
    NSSortDescriptor *prioritySortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"priority"  ascending:YES];
    NSArray *sortedArray = [workOrderSummaryArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:eventStartDateSortDescriptor, prioritySortDescriptor, nil]];
    return sortedArray;
    
}


+ (NSArray*)getWorkOrdersForWhatIds:(NSMutableDictionary*)whatEventStartDateValueMap {
    
    DBCriteria *criteriaOne = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIn andFieldValues:[whatEventStartDateValueMap allKeys]];
    NSArray *fieldsArray = [[NSArray alloc] initWithObjects:kId, klocalId,kWorkOrderContactId,kWorkOrderName,kWorkOrderCompanyId,kWorkOrderScheduledDateTime,kWorkOrderSTREET,kWorkOrderCITY, kWorkOrderSTATE, kWorkOrderCOUNTRY, kWorkOrderZIP, kWorkOrderPurposeOfVisit, kWorkOrderProblemDescription, kWorkOrderPriority, kWorkOrderLatitude, kWorkOrderLongitude, kWorkOrderBillingType, kWorkOrderOrderStatus, kWorkOrderCompanyId, kWorkOrderSite, nil];
    
    NSArray *workOrderArray = [self fetchDataFromWorkOrderObject:kWorkOrderTableName fields:fieldsArray expression:nil criteria:[NSArray arrayWithObject:criteriaOne]];
    
    NSMutableArray *workOrderSummaryArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (TransactionObjectModel *transObjModel in workOrderArray) {
        
        WorkOrderSummaryModel *woSummaryModel = [[WorkOrderSummaryModel alloc] initWithTransactionModel:transObjModel andIdEventStartValueMap:whatEventStartDateValueMap];
        
        NSString *companyName = [self getAccountNameForCompanyId:[transObjModel valueForField:kWorkOrderCompanyId]];
        
        
        if (![companyName length] && [woSummaryModel.companyId length])
        {
            NSMutableDictionary *accountDict = [self getValuesFromReferenceTable:[NSArray arrayWithObject:woSummaryModel.companyId]];
            companyName = [accountDict valueForKey:woSummaryModel.companyId];
        }
        else if (![companyName length])
        {
                companyName = woSummaryModel.companyId;

            
        }
        
        
            woSummaryModel.companyName = companyName;
        
        
        if ([[transObjModel valueForField:kWorkOrderSite] length]) {
            woSummaryModel.IPAtLocation = [self getInstalledListFromSite: [transObjModel valueForField:kWorkOrderSite]];

        }
        else{
            woSummaryModel.IPAtLocation = nil;
        }
        

        
        
        
        [workOrderSummaryArray addObject:woSummaryModel];
    }
    
    
    
    NSSortDescriptor *eventStartDateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"eventStartDateTime"
                                                                                   ascending:YES];
    NSSortDescriptor *prioritySortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"priority"
                                                                             ascending:YES];
    NSArray *sortedArray = [workOrderSummaryArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:eventStartDateSortDescriptor, prioritySortDescriptor, nil]];

    
    return sortedArray;
}


-(NSArray *) getEventDetailsForTheDay
{
    NSMutableArray *lEventListArray = (NSMutableArray *) [self eventsOfRangeOfDays];
    
    NSMutableArray *lEventArray = [self removeTheDayPadding:lEventListArray];
    
//    NSArray *fieldsArray = [[NSArray alloc] initWithObjects:@"keyPrefix", @"objectName",nil];
    
    // Get keyPrefix and Tablenames from sfObject Table
//    NSDictionary *lDictionary = [CalenderHelper fetchSFObjectTableDataForFields:fieldsArray criteria:nil andExpression:nil];
    
//    NSLog(@"lDictionary: %@", lDictionary);
    
    NSMutableDictionary *whatEventStartDateValueMap = [[NSMutableDictionary alloc] init];
    
    for (CalenderEventObjectModel *lModel in lEventArray) {
        
        if ([self isWhatIDbelongstoWorkOrder:lModel.WhatId]) {
            [whatEventStartDateValueMap setValue:lModel.startDateTime forKey:lModel.WhatId];
        }
        
        
        if ([lModel.WhatId length]) {
            lModel.conflict = [CalenderHelper isConflicted:lModel.WhatId];
        }
        
    }
    
    
    if (whatEventStartDateValueMap.count>0) {
        // if event is work order, attach WorkOrderSummaryModel to the CalenderEventObjectModel
        
        NSArray *lArray =  [CalenderHelper getWorkOrdersForWhatIds:whatEventStartDateValueMap];
        
        for (WorkOrderSummaryModel *lWOModel in lArray) {
            
            for (int i = 0 ; i < lEventArray.count ; i++) {
                CalenderEventObjectModel *lSEOModel = [lEventArray objectAtIndex:i];
                
                if ([lWOModel.Id isEqualToString:lSEOModel.WhatId])
                {
                    
                    if ([lSEOModel.WhatId length]) {
                        NSDictionary *slaPriorityDictionary = [CalenderHelper SLAAndPriorityStatusForwhatID:lSEOModel.WhatId];
                        
                        NSNumber *slaMetric = [slaPriorityDictionary objectForKey:@"slaStatus"];
                        lSEOModel.sla = [slaMetric boolValue];
                        
                        NSString *priorityStatus = [slaPriorityDictionary objectForKey:@"priorityStatus"];
                        if ([priorityStatus isEqualToString:@"High"]) {
                            lSEOModel.priority = YES;
                        }

                    }
                    
                    lSEOModel.cWorkOrderSummaryModel = lWOModel;
                    [lEventArray replaceObjectAtIndex:i withObject:lSEOModel];
                }
            }
            
        }
        
    }
    
    NSSortDescriptor *eventStartDateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startDateTime"
                                                                                   ascending:YES];

    NSArray *sortedArray = [lEventArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:eventStartDateSortDescriptor, nil]];

    
    return sortedArray;
    
}


+(BOOL)isConflicted:(NSString *)lWhatId
{
    id <CalenderDAO> serviceRequest = [FactoryDAO serviceByServiceType:ServiceCalenderEventList];
    
    TransactionObjectModel *model =  [serviceRequest getRecordForSalesforceId:lWhatId];
    
    id <SFChildRelationshipDAO> childRelationServiceRequest = [FactoryDAO serviceByServiceType:ServiceTypeSFChildRelationShip];
    
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:kCRObjectNameParentField operatorType:SQLOperatorEqual andFieldValue:model.objectAPIName];
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:kCRFieldNameField operatorType:SQLOperatorEqual andFieldValue:model.objectAPIName];


    NSArray *lChildModelArray = [childRelationServiceRequest fetchSFChildRelationshipInfoByFields:@[kCRObjectNameChildField] andCriterias:@[criteria1, criteria2] andAdvanceExpresion:@"(1 AND 2)"];
    
    if ((lChildModelArray == nil) || ([lChildModelArray count] < 1))
    {
        // No child records found. Lets go back
        return NO;
    }
    
    SFChildRelationshipModel * lCRModel = [lChildModelArray objectAtIndex:0];
    
    // Record of the children from child table.
     NSArray *lDataArray = [serviceRequest conflictStatusOfChildInTable:lCRModel.objectNameChild withWhatID:lWhatId andLocalID:model.recordLocalId forParentTable:model.objectAPIName];
    
    BOOL status = NO;
    for (TransactionObjectModel *lTransModel in lDataArray)
    {

        
        //Check if the child ids present in the SyncErrorConflictTable
        
        DBCriteria *syncCriteria1 = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:lTransModel.recordLocalId];
        
        DBCriteria *syncCriteria2 = [[DBCriteria alloc] initWithFieldName:kSyncRecordSFId operatorType:SQLOperatorEqual andFieldValue:lWhatId];
        
        id <SyncErrorConflictDAO> syncErrorService = [FactoryDAO serviceByServiceType:ServiceTypeSyncErrorConflict];
        
        int numberOfRecords = [syncErrorService getNumberOfRecordsFromObject:kSyncErrorConflictTableName withDbCriteria:@[syncCriteria1, syncCriteria2] andAdvancedExpression:@"(1 OR 2)"];
        
        if (numberOfRecords>0) {
            
            // this child has Sync error. Break from here and inform of the Sync Status
            status = YES;
            break;
        }
        else
        {
                // this child does not have Sync Error
        }
        
    }
    return status;
}



+(NSDictionary *)SLAAndPriorityStatusForwhatID:(NSString *)lWhatId
{
    
    id <CalenderDAO> serviceRequest = [FactoryDAO serviceByServiceType:ServiceCalenderEventList];
    
    TransactionObjectModel *model =  [serviceRequest getRecordForSalesforceId:lWhatId];

    id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorEqual andFieldValue:lWhatId];

    
    NSArray *objects =   [transObjectService fetchDataForObject:model.objectAPIName fields:@[kSLARestoratorationCustomer, kSLAResolutionCustomer, kSLAActualRestoration, kSLAActualResolution, kSLAClockPauseTime, kSLAClockPaused] expression:nil criteria:@[criteria]];
    
    BOOL status = NO;
    NSString *priorityStatus = @"Low";
    if ([objects count] > 0) {
        TransactionObjectModel *record =  [objects objectAtIndex:0];
        [record setObjectName:model.objectAPIName];
        
        NSDictionary *dataDictionary = [model getFieldValueDictionary];
        
        if (dataDictionary != nil) {
            if (dataDictionary.count > 0) {
                
                //if any field present then problem with SLA. Otherwise no other field apart from kSLAClockPaused will have any value.
                
                NSString *SLARestoratorationCustomer = [dataDictionary objectForKey:kSLARestoratorationCustomer];
                NSString *SLAResolutionCustomer = [dataDictionary objectForKey:kSLAResolutionCustomer];
                NSString *SLAActualRestoration = [dataDictionary objectForKey:kSLAActualRestoration];
                NSString *SLAActualResolution = [dataDictionary objectForKey:kSLAActualResolution];
                NSString *SLAClockPauseTime = [dataDictionary objectForKey:kSLAClockPauseTime];
                NSNumber *SLAClockPaused  = [dataDictionary objectForKey:kSLAClockPaused];
                NSString *lpriorityStatusTemp  = [dataDictionary objectForKey:kWorkOrderPriority];
                
                priorityStatus = (lpriorityStatusTemp.length>0 ? lpriorityStatusTemp:priorityStatus);
                
                if (SLARestoratorationCustomer && SLARestoratorationCustomer.length > 0) {
                    status = YES;

                }
                else if (SLAResolutionCustomer && SLAResolutionCustomer.length > 0) {
                    status = YES;
                    
                }
                else if (SLARestoratorationCustomer && SLARestoratorationCustomer.length > 0) {
                    status = YES;
                    
                }
                else if (SLAActualRestoration && SLAActualRestoration.length > 0) {
                    status = YES;
                    
                }
                else if (SLAActualResolution && SLAActualResolution.length > 0) {
                    status = YES;
                    
                }
                else if (SLAClockPauseTime && SLAClockPauseTime.length > 0) {
                    status = YES;
                    
                }
                else
                {
                    // check if SVMXC__Sla_Clock_Paused__C is 'O' or '1'. If '1', then issues with SLA.

                    int paused = [SLAClockPaused intValue];
                    if (SLAClockPaused && paused == 1)
                        status = YES;
                    else
                        status = NO;
                }
            }
            else
            {
                // No Data Present
                
                status = NO;
                
            }

        }
        
    }

    
    return @{@"slaStatus":[NSNumber numberWithBool:status], @"priorityStatus" : priorityStatus};
}

-(BOOL)isWhatIDbelongstoWorkOrder:(NSString *)lWhatID
{
    id <CalenderDAO> serviceRequest = [FactoryDAO serviceByServiceType:ServiceCalenderEventList];
    
    TransactionObjectModel *model =  [serviceRequest getRecordForSalesforceId:lWhatID];

    if (!cLocalIDandAssociatedWhatID) {
        cLocalIDandAssociatedWhatID = [[NSMutableDictionary alloc] init];
    }

    if (model) {
        [cLocalIDandAssociatedWhatID setObject:[model recordLocalId] forKey:lWhatID];
        return YES;
    }
    return NO;
}

-(ServiceLocationModel *)getTransactionModel:(NSString *)lWhatID
{
    id <CalenderDAO> serviceRequest = [FactoryDAO serviceByServiceType:ServiceCalenderEventList];
    
    TransactionObjectModel *model =  [serviceRequest getRecordForSalesforceId:lWhatID];
    
    ServiceLocationModel *ServiceModel = [[ServiceLocationModel alloc] initWithTransactionModel:model];
    return ServiceModel;
}

-(NSMutableArray *)removeTheDayPadding:(NSArray *)eventArray
{
    
    NSMutableArray *cEventListArray = [[NSMutableArray alloc] init];
    
    NSDateComponents *lTodayComponent = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    
    NSDateFormatter * lDF = [[NSDateFormatter alloc] init];
    [lDF setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    
    for (CalenderEventObjectModel *lModel in eventArray) {
        
        NSString *lStartDateString = [NSString stringWithFormat:@"%@", lModel.startDateTime];
        
        lStartDateString = [lStartDateString stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        lStartDateString = [lStartDateString stringByReplacingOccurrencesOfString:@".000Z" withString:@""];
        
        lStartDateString = [CalenderHelper localTimeFromGMT:lStartDateString];
        lStartDateString = [lStartDateString stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        lStartDateString = [lStartDateString stringByReplacingOccurrencesOfString:@"Z" withString:@""];
        
        NSDate *lEventStartDate = [lDF dateFromString:lStartDateString];
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:lEventStartDate];
        
        if (components.day >= lTodayComponent.day ) {
            if ((components.day - lTodayComponent.day) <= [cRangeOfDaysString intValue])
            {
                [cEventListArray addObject:lModel];
            }
        }
        else
        {
            if ((lTodayComponent.day - components.day) <= [cRangeOfDaysString intValue])
            {
                [cEventListArray addObject:lModel];
            }
        }
        
    }
    
    return cEventListArray;
}


/*
 
 Method Name: eventsOfRangeOfDays
 Description: This Method gets all the events in date range.
 
 Date Range Calculations
 
 Start Date = Current Day - SyncDayRange - 1
 End Date = Current + SyncDayRange + 1
 
 */

- (NSArray*) eventsOfRangeOfDays {
    
    cRangeOfDaysString = [CalenderHelper getSyncDayRangeFromMobileDeviceSettings];
    
    int lRangeDayInt = [cRangeOfDaysString intValue];
    
//    lRangeDayInt = 150; //TODO:Remove it. for testing only
    
    if (lRangeDayInt) {
        lRangeDayInt +=1;    // increasing the range by 1 day to accomodate GMT to local conversion issues which falls on the start or end of the day.
    }
    else
    {
        lRangeDayInt = 1;
    }
    
    
    NSArray *fieldsArray = [[NSArray alloc] initWithObjects:kActivityDate,kActivityDateTime,kDurationInMinutes,kEndDateTime, kStartDateTime, kSubject, kWhatId, kId, klocalId, nil];
    
    NSDate *lStartDate = [[NSDate date] dateByAddingTimeInterval:-60*60*24*lRangeDayInt];
    NSDate *lEndDate = [[NSDate date] dateByAddingDays:lRangeDayInt];
    
    
    NSTimeZone *gmt = [[NSTimeZone alloc] initWithName:@"GMT"];
    NSDate *startDate = [NSDate date:lStartDate withTimeZone:gmt];
    
    NSDate *endDate = [NSDate date:lEndDate withTimeZone:gmt];
    
    NSString *startDateString = [CalenderHelper convertDateToStringGMT:startDate];
    NSString *endDateString = [CalenderHelper convertDateToStringGMT:endDate];
    NSString *ownerId = [CalenderHelper ownerId];
    
    //    DBCriteria *criteriaOne = [[DBCriteria alloc] initWithFieldName:kWhatId operatorType:SQLOperatorLike andFieldValue:[self prefixForWorkOrder]];
    
    DBCriteria *criteriaTwo = [[DBCriteria alloc] initWithFieldName:kStartDateTime operatorType:SQLOperatorGreaterThanEqualTo andFieldValue:startDateString];
    
    DBCriteria *criteriaThree = [[DBCriteria alloc] initWithFieldName:kStartDateTime operatorType:SQLOperatorLessThan andFieldValue:endDateString];
    
    DBCriteria *criteriaFour = [[DBCriteria alloc] initWithFieldName:kEndDateTime operatorType:SQLOperatorGreaterThanEqualTo andFieldValue:startDateString];
    
    DBCriteria *criteriaFive = [[DBCriteria alloc] initWithFieldName:kEndDateTime operatorType:SQLOperatorLessThan andFieldValue:endDateString];
    
    NSArray *eventArray = nil;
    
    
    if ([ownerId length]) {
        
        DBCriteria *criteriaSix = [[DBCriteria alloc] initWithFieldName:kOwnerId operatorType:SQLOperatorEqual andFieldValue:ownerId];
        eventArray = [CalenderHelper fetchDataForObject:kEventObject fields:fieldsArray expression:@"(((1 AND 2) OR (3 AND 4)) AND 5)" criteria:[NSArray arrayWithObjects:criteriaTwo, criteriaThree, criteriaFour, criteriaFive, criteriaSix,nil]];
    }
    else {
        eventArray = [CalenderHelper fetchDataForObject:kEventObject fields:fieldsArray expression:@"((1 AND 2) OR (3 AND 4))" criteria:[NSArray arrayWithObjects: criteriaTwo, criteriaThree, criteriaFour, criteriaFive, nil]];
    }
    
    return eventArray;
}

+(NSString *)getSyncDayRangeFromMobileDeviceSettings
{
    NSString *rangeDay = [self fetchSyncDayRange];
    
    return rangeDay;
}





+ (void)updateEvent:(SMXEvent *)event toActivityDate:(NSDate *) activityDate andStartTime:(NSDate *)startTime withEndTime:(NSDate *)endTime;
{
    
    {
        
        // TODO: If the end datetime is the next day, then restrict the time to 23:59 of the activity date. This will change once the Multi-day event is implemented.
        
        NSDateComponents *startdateTimeComponent = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:startTime];
        
        NSDateComponents *enddateTimeComponent = [[NSCalendar currentCalendar] components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:endTime];
        
        if (startdateTimeComponent.day != enddateTimeComponent.day) {
            enddateTimeComponent.day = startdateTimeComponent.day;
            enddateTimeComponent.hour = 23;
            enddateTimeComponent.minute = 59;
            
            endTime = [[NSCalendar currentCalendar] dateFromComponents:enddateTimeComponent];
            
        }
    }
    
    SMXEvent *___lEvent = [SMXEvent new];
    ___lEvent.ActivityDateDay = activityDate;
    ___lEvent.localID = event.localID;
    ___lEvent.IDString = event.IDString;
    ___lEvent.dateTimeBegin = startTime;
    ___lEvent.dateTimeEnd = endTime;
    
    
    if (event != nil && [event.IDString length] > 0)
    {
        DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:___lEvent.localID];
        
        id <CalenderDAO> lCalenderService = [FactoryDAO serviceByServiceType:ServiceCalenderEventList];
        
        BOOL status = [lCalenderService updateEachRecord:[self getDataDict:___lEvent]
                                                withFields:[self getEventFields]
                                              withCriteria:[NSArray arrayWithObject:criteria]
                                             withTableName:@"Event"];
        
        if (status) {
            if (![StringUtil isStringEmpty:event.IDString]) {
                
                id modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
                if ([modifiedRecordService conformsToProtocol:@protocol(ModifiedRecordsDAO)]) {
                    
                    ModifiedRecordModel *modifiedRecord = [[ModifiedRecordModel alloc]init];
                    modifiedRecord.objectName = @"Event";
                    modifiedRecord.recordLocalId = event.localID;
                    modifiedRecord.sfId = event.IDString;
                    modifiedRecord.operation = kModificationTypeUpdate;
                    modifiedRecord.recordType = kRecordTypeMaster;
                    
                    BOOL saveStatus = [modifiedRecordService saveRecordModel:modifiedRecord];
                    if (saveStatus) {
                    	[[SuccessiveSyncManager sharedSuccessiveSyncManager] registerForSuccessiveSync:modifiedRecord withData:[self getDataDict:___lEvent]];
                        [[SyncManager sharedInstance] performSyncWithType:SyncTypeData];
                    }
                }
            }
            
        }
    }
    
}


+ (NSDictionary *)getDataDict:(SMXEvent *)event
{
    if (event != nil){
        [self checkAndUpdateTaskModel:event];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        [dateFormatter setTimeZone:gmt];

        dateFormatter.dateFormat = @"yyyy-MM-dd";
        [dict setObject:[DateUtil stringFromDate:event.ActivityDateDay inFormat:kDateFormatTypeOnlyDate] forKey:kActivityDate];
        
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        [dict setObject:[dateFormatter stringFromDate:event.dateTimeBegin]forKey:kActivityDateTime];

        [dict setObject:[dateFormatter stringFromDate:event.dateTimeBegin] forKey:kStartDateTime];
        [dict setObject:[dateFormatter stringFromDate:event.dateTimeEnd] forKey:kEndDateTime];
        
        [dict setObject:event.localID forKey:kLocalId];
        [dict setObject:event.IDString forKey:kId];
        return dict;
    }
    return nil;
}


+ (void)checkAndUpdateTaskModel:(SMXEvent *)event
{

    event.ActivityDateDay = (event.ActivityDateDay) != nil? event.ActivityDateDay:[NSDate date];
    event.IDString = (event.IDString) != nil? event.IDString:@"";
    event.localID = (event.localID) != nil? event.localID:@"";
    
}

+(NSArray *)getEventFields
{
    return @[kActivityDate,kActivityDateTime, kStartDateTime, kEndDateTime];
}

+ (NSString *)getAccountNameForCompanyId:(NSString *)accountId {  // Copied from MapHelper 28-Oct
    
    id <TransactionObjectDAO> transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorEqual andFieldValue:accountId];
    NSArray *fieldsArray = [[NSArray alloc] initWithObjects:kAccountName, nil];
    TransactionObjectModel *transModel = [transactionService getDataForObject:kAccountTableName fields:fieldsArray expression:nil criteria:[NSArray arrayWithObject:criteria]];
    
    return [transModel valueForField:kAccountName];
}

+ (NSMutableDictionary *)getValuesFromReferenceTable:(NSArray *)ids
{
    if ([ids count] > 0) {
        NSMutableDictionary *idValue = [[NSMutableDictionary alloc] initWithDictionary:0];
        
        DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIn andFieldValues:ids];
        
        id <ObjectNameFieldValueDAO> nameFieldValueService = [FactoryDAO serviceByServiceType:ServiceTypeObjectNameFieldValue];
        
        NSArray *resultSet = [nameFieldValueService fetchObjectNameFieldValueByFields:nil andCriteria:criteria];
        
        for (ObjectNameFieldValueModel *model in resultSet) {
            if (model != nil) {
                NSString *sfId = model.Id;
                NSString *value = model.value;
                if ([sfId length] > 0 && [value length] > 0) {
                    [idValue setValue:value forKey:sfId];
                }
            }
        }
        return idValue;
    }
    return nil;
}


+(NSArray *)getInstalledListFromSite:(NSString *)siteID
{

    id <CalenderDAO> calService = [FactoryDAO serviceByServiceType:ServiceCalenderEventList];
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kWorkOrderSite operatorType:SQLOperatorEqual andFieldValue:siteID];
    NSArray *fieldsArray = [[NSArray alloc] initWithObjects:kIPProductNameField, nil];
    NSArray *lDataArray = [calService fetchDataForIPObject:kInstalledProductTableName fields:fieldsArray expression:nil criteria:[NSArray arrayWithObject:criteria]];
    
    return lDataArray;
    
}


+ (NSString*)ownerId {
    return [CustomerOrgInfo sharedInstance].currentUserId;
}


+ (NSString*)convertDateToStringGMT:(NSDate*)date {
    if (date) {
        return [DateUtil getDatabaseStringForDate:date];
    }
    return nil;
}

+ (NSArray*)allKeysForWorkOrderPopup {
    
    return [NSArray arrayWithObjects:kMapWONumber, kMapAccount, kMapServiceLocation, kMapAppointment,kMapContact, kMapPurposeOfVisit, kMapProblemDescription, nil];
}

+ (NSArray*)allTagValuesForWorkOrderPopup {
    
    NSMutableArray *allValues = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSString *key in [CalenderHelper allKeysForWorkOrderPopup]) {
        
        NSString *tagvalue = [[TagManager sharedInstance] tagByName:key];
        
        if ([tagvalue length]) {
            [allValues addObject:tagvalue];
        }
        else {
            [allValues addObject:key];
        }
        
    }
    return allValues;
}

+ (NSString *) localTimeFromGMT:(NSString *)gmtDate
{
    if ([gmtDate isEqualToString:@""])
        return gmtDate;
    
    if ([gmtDate length] > 19)
    {
        gmtDate = [gmtDate substringToIndex:19];
        gmtDate = [NSString stringWithFormat:@"%@Z", gmtDate];
    }
    //for Gregorian Calendar
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setCalendar:cal];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString * tmpDate = [gmtDate substringToIndex:[gmtDate length]-0];
    
    tmpDate = [tmpDate stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    tmpDate = [tmpDate stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    tmpDate = [tmpDate stringByDeletingPathExtension];
    
    NSDate * originalDate = [dateFormatter dateFromString:tmpDate];
    [cal setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSDateComponents *date_comp = [cal components: NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:originalDate];
    
    NSString *someDateString = [self getLocalizedString:date_comp];
    [cal release];
    
    someDateString = [someDateString stringByReplacingOccurrencesOfString:@" " withString:@"T"];
    someDateString = [NSString stringWithFormat:@"%@Z", someDateString];
    
    [dateFormatter release];
    
    return someDateString;
}

+ (NSString *)getLocalizedString:(NSDateComponents *)date_comp {
    NSString *monthStr = nil,*dayStr = nil,*hourStr = nil,*minutesStr = nil,*secondsStr = nil;
    
    NSInteger year = [date_comp year];
    
    NSInteger month = [date_comp month];
    monthStr = [self getTwoDigitString:month];
    
    NSInteger day = [date_comp day];
    dayStr = [self getTwoDigitString:day];
    
    NSInteger hour = [date_comp  hour];
    hourStr = [self getTwoDigitString:hour];
    
    NSInteger minutes = [date_comp  minute];
    minutesStr = [self getTwoDigitString:minutes];
    
    NSInteger seconds = [date_comp second];
    secondsStr = [self getTwoDigitString:seconds];
    
    NSString *someDateString = [NSString stringWithFormat:@"%ld-%@-%@ %@:%@:%@",(long)year,monthStr,dayStr,hourStr,minutesStr,secondsStr];
    return someDateString;
}

+ (NSString *)getTwoDigitString:(NSInteger )dateInt {
    NSString *someString = nil;
    if (dateInt > 9) {
        someString = [NSString stringWithFormat:@"%ld",(long)dateInt];
    }
    else {
        someString = [NSString stringWithFormat:@"0%ld",(long)dateInt];
    }
    return someString;
}

+ (TransactionObjectModel *)getRecordForSalesforceId:(NSString *)salesforceId {
    
    if (salesforceId.length != 18) {
        return nil;
    }
    
    NSString *keyPrefix = [salesforceId substringToIndex:3];
    
    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:@"keyPrefix" operatorType:SQLOperatorEqual andFieldValue:keyPrefix];
    
    id <SFObjectDAO> objectService = [FactoryDAO serviceByServiceType:ServiceTypeSFObject];
    
    SFObjectModel *model = [objectService getSFObjectInfo:criteria fieldName:@[@"objectName"]];
    
    if (model.objectName != nil) {
        id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
        
        DBCriteria * innerCriteria = [[DBCriteria alloc] initWithFieldName:@"Id" operatorType:SQLOperatorEqual andFieldValue:salesforceId];
        
        NSArray *objects =   [transObjectService fetchDataForObject:model.objectName fields:nil expression:nil criteria:@[innerCriteria]];
        if ([objects count] > 0) {
            TransactionObjectModel *record =  [objects objectAtIndex:0];
            [record setObjectName:model.objectName];
            return record;
        }
    }
    
    return nil;
}



@end
