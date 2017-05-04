//
//  MapHelper.m
//  ServiceMaxMobile
//
//  Created by Anoop on 9/15/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "MapHelper.h"
#import "SFObjectService.h"
#import "FactoryDAO.h"
#import "DateUtil.h"
#import "NSDate+TKCategory.h"
#import "ServiceLocationModel.h"
#import "TransactionObjectService.h"
#import "TransactionObjectDAO.h"
#import "TransactionObjectModel.h"
#import "WorkOrderSummaryModel.h"
#import "ContactImageModel.h"
#import "DateUtil.h"
#import "TagManager.h"
#import "NonTagConstant.h"
#import "CustomerOrgInfo.h"
#import "ObjectNameFieldValueDAO.h"
#import "TaskManager.h"
#import "TaskModel.h"
#import "TaskGenerator.h"
#import "CacheManager.h"
#import "CacheConstants.h"
#import "AppManager.h"
#import "AlertMessageHandler.h"
#import "SFPicklistModel.h"
#import "SFMPageHelper.h"
#import "StringUtil.h"
#import "PlistManager.h"


@interface MapHelper ()

+ (NSArray *)fetchDataForObject:(NSString *)objectName
                         fields:(NSArray *)fieldNames
                     expression:(NSString *)advancaeExpression
                       criteria:(NSArray *)criteria;
+ (NSMutableArray*)getWorkOrdersForWhatIds:(NSMutableDictionary*)whatEventStartDateValueMap;

@end

@implementation MapHelper

+ (NSArray *)fetchDataForObject:(NSString *)objectName
                         fields:(NSArray *)fieldNames
                     expression:(NSString *)advancaeExpression
                       criteria:(NSArray *)criteria
{
    id <TransactionObjectDAO> transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    NSArray *dataArray = [transactionService fetchDataForObject:objectName fields:fieldNames expression:advancaeExpression criteria:criteria];
    return dataArray;
}

+ (ContactImageModel *)getContactObjectForId:(NSString *)contactId {
    
    id <TransactionObjectDAO> transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorEqual andFieldValue:contactId];
    NSArray *fieldsArray = [[NSArray alloc] initWithObjects:kId, kLocalId, kContactName,kContactEmail,kContactPhone,kContactMobilePhone, nil];
    TransactionObjectModel *transModel = [transactionService getDataForObject:kContactTableName fields:fieldsArray expression:nil criteria:[NSArray arrayWithObject:criteria]];
    ContactImageModel *contactModel = [[ContactImageModel alloc] initWithTransactionModel:transModel];
    
    if ([StringUtil isStringEmpty:contactModel.contactName] && ![StringUtil isStringEmpty:contactId])
    {
        NSMutableDictionary *contactDict = [MapHelper getValuesFromReferenceTable:[NSArray arrayWithObject:contactId]];
        contactModel.contactName = [contactDict valueForKey:contactId];
    }
    if ([StringUtil isStringEmpty:contactModel.contactName] && ![StringUtil isStringEmpty:contactId])
    {
        contactModel.contactName = contactId;
    }
    return contactModel;
    
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
                if (![StringUtil isStringEmpty:sfId] && ![StringUtil isStringEmpty:value]) {
                    [idValue setValue:value forKey:sfId];
                }
            }
        }
        return idValue;
    }
    return nil;
}

+ (NSString *)getAccountNameForId:(NSString *)accountId {
    
    id <TransactionObjectDAO> transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorEqual andFieldValue:accountId];
    NSArray *fieldsArray = [[NSArray alloc] initWithObjects:kAccountName, nil];
    TransactionObjectModel *transModel = [transactionService getDataForObject:kAccountTableName fields:fieldsArray expression:nil criteria:[NSArray arrayWithObject:criteria]];
    
    return [transModel valueForField:kAccountName];
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


+ (NSArray*)workOrderSummaryArrayOfCurrentDay:(NSDate*)selectedDate {
    
    NSArray *eventsArray = [self eventsOfCurrentDay:selectedDate];
    NSArray *allDayEventsArray = [self eventsOfCurrentDayForAllDayEvents:selectedDate];
    
    eventsArray = [eventsArray arrayByAddingObjectsFromArray:allDayEventsArray];
    NSArray *SVMX_EventsArray = [self eventsFromSVMXEVENTOfCurrentDay:selectedDate];
    NSArray *allDay_SVMX_EventsArray =  [self eventsFromSVMXEVENTOfCurrentDayForAllDayEvents:selectedDate];
    SVMX_EventsArray  = [SVMX_EventsArray arrayByAddingObjectsFromArray:allDay_SVMX_EventsArray];
    
    NSMutableDictionary *whatEventStartDateValueMap = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    
    for (TransactionObjectModel *transObjModel in eventsArray) {
        NSString *whatId = [transObjModel valueForField:kWhatId];
        if (![StringUtil isStringEmpty:whatId])
            
            //[whatEventStartDateValueMap setValue:[transObjModel valueForField:kStartDateTime] forKey:whatId];
            [whatEventStartDateValueMap setValue:@{whatId:[transObjModel valueForField:kStartDateTime], kGENERAL_ALL_DAY:[transObjModel valueForField:kIsAlldayEvent]} forKey:whatId];
    }
    
    for (TransactionObjectModel *transObjModel in SVMX_EventsArray) {
        NSString *whatId = [transObjModel valueForField:kObjectSfId];
        if (![StringUtil isStringEmpty:whatId])
//            [whatEventStartDateValueMap setValue:[transObjModel valueForField:kSVMXStartDateTime] forKey:whatId];
                    [whatEventStartDateValueMap setValue:@{whatId:[transObjModel valueForField:kSVMXStartDateTime], kGENERAL_ALL_DAY:[transObjModel valueForField:kSVMXIsAlldayEvent]} forKey:whatId];
    }
    
    
    NSMutableArray *workOrderSummaryArray = [self getWorkOrdersForWhatIds:whatEventStartDateValueMap];
    NSArray *sortedArray = [workOrderSummaryArray sortedArrayUsingComparator:^(WorkOrderSummaryModel *workOrderOne, WorkOrderSummaryModel *workOrderTwo) {
        
        NSComparisonResult result = [workOrderOne.gmtEventStartDateTime compare:workOrderTwo.gmtEventStartDateTime options:NSNumericSearch];
        if (result == NSOrderedSame) {
            result = [[workOrderOne.priority stringValue] compare:[workOrderTwo.priority stringValue] options:NSNumericSearch];
        }
        return result;
    }];
    return sortedArray;
}


+ (NSMutableArray*)getWorkOrdersForWhatIds:(NSMutableDictionary*)whatEventStartDateValueMap {

    DBCriteria *criteriaOne = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIn andFieldValues:[whatEventStartDateValueMap allKeys]];
    DBCriteria *criteriaTwo = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorIn andFieldValues:[whatEventStartDateValueMap allKeys]];
   // NSArray *fieldsArray = [[NSArray alloc] initWithObjects:kId, klocalId,kWorkOrderContactId,kWorkOrderName,kWorkOrderCompanyId,kWorkOrderSTREET,kWorkOrderCITY, kWorkOrderSTATE, kWorkOrderCOUNTRY, kWorkOrderZIP, kWorkOrderPurposeOfVisit, kWorkOrderProblemDescription, kWorkOrderPriority, kWorkOrderBillingType, kWorkOrderOrderStatus, kWorkOrderCompanyId, kWorkOrderSite, nil];
      NSArray *fieldsArray = [[NSArray alloc] initWithObjects:kId, klocalId,kWorkOrderContactId,kWorkOrderName,kWorkOrderCompanyId,kWorkOrderSTREET,kWorkOrderCITY, kWorkOrderSTATE, kWorkOrderCOUNTRY, kWorkOrderZIP,kWorkOrderLatitude,kWorkOrderLongitude, kWorkOrderPurposeOfVisit, kWorkOrderProblemDescription, kWorkOrderPriority, kWorkOrderBillingType, kWorkOrderOrderStatus, kWorkOrderCompanyId, kWorkOrderSite, nil];
    
    //HS 26Jul, updated query to fetch lat and long from WO table
    
    NSArray *workOrderArray = [self fetchDataForObject:kWorkOrderTableName fields:fieldsArray expression:@"(1 OR 2)" criteria:[NSArray arrayWithObjects:criteriaOne, criteriaTwo, nil]];

    NSMutableArray *workOrderSummaryArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (TransactionObjectModel *transObjModel in workOrderArray) {
        
        WorkOrderSummaryModel *woSummaryModel = [[WorkOrderSummaryModel alloc] initWithTransactionModel:transObjModel andIdEventStartValueMap:whatEventStartDateValueMap];
        [workOrderSummaryArray addObject:woSummaryModel];
    }
    
    return workOrderSummaryArray;
}

+ (NSArray*) eventsOfCurrentDay:(NSDate*)selectedDate {

    NSArray *fieldsArray = [[NSArray alloc] initWithObjects:kActivityDate,kActivityDateTime,kDurationInMinutes,kEndDateTime, kStartDateTime, kSubject, kIsAlldayEvent, kWhatId, kId, klocalId, kIsAlldayEvent, nil];
    NSTimeZone *gmt = [[NSTimeZone alloc] initWithName:@"GMT"];
    NSDate *startDate = [NSDate date:selectedDate withTimeZone:gmt];
    NSDate *endDate = [NSDate date:[selectedDate dateByAddingDays:1] withTimeZone:gmt];
    NSString *startDateString = [self convertDateToStringGMT:startDate];
    NSString *endDateString = [self convertDateToStringGMT:endDate];
    NSString *ownerId = [self ownerId];
    
    DBCriteria *criteriaOne = [[DBCriteria alloc] initWithFieldName:kWhatId operatorType:SQLOperatorLike andFieldValue:[self prefixForWorkOrder]];
    
    DBCriteria *criteriaTwo = [[DBCriteria alloc] initWithFieldName:kStartDateTime operatorType:SQLOperatorLessThan andFieldValue:endDateString];
    
    DBCriteria *criteriaThree = [[DBCriteria alloc] initWithFieldName:kEndDateTime operatorType:SQLOperatorGreaterThan  andFieldValue:startDateString];

    DBCriteria *allDayCriteriaOne = [[DBCriteria alloc] initWithFieldName:kIsAlldayEvent operatorType:SQLOperatorEqual  andFieldValue:@"false"];
    DBCriteria *allDayCriteriaTwo = [[DBCriteria alloc] initWithFieldName:kIsAlldayEvent operatorType:SQLOperatorEqual  andFieldValue:@"0"];

    NSArray *eventArray = nil;
    
    if (![StringUtil isStringEmpty:ownerId]) {
        
        DBCriteria *criteriaSix = [[DBCriteria alloc] initWithFieldName:kOwnerId operatorType:SQLOperatorEqual andFieldValue:ownerId];
        eventArray = [self fetchDataForObject:kEventObject fields:fieldsArray expression:@"(1 AND (2 AND 3) AND  4 AND (5 OR 6))" criteria:[NSArray arrayWithObjects:criteriaOne, criteriaTwo, criteriaThree, criteriaSix, allDayCriteriaOne, allDayCriteriaTwo, nil]];
    }
    else {
        eventArray = [self fetchDataForObject:kEventObject fields:fieldsArray expression:@"(1 AND (2 AND 3) AND (4 OR 5))" criteria:[NSArray arrayWithObjects:criteriaOne, criteriaTwo, criteriaThree, allDayCriteriaOne, allDayCriteriaTwo, nil]];
    }
    
    return eventArray;
}

+ (NSArray*) eventsOfCurrentDayForAllDayEvents:(NSDate*)selectedDate {
    
    NSArray *fieldsArray = [[NSArray alloc] initWithObjects:kActivityDate,kActivityDateTime,kDurationInMinutes,kEndDateTime, kStartDateTime, kSubject, kIsAlldayEvent, kWhatId, kId, klocalId, nil];
    NSTimeZone *gmt = [[NSTimeZone alloc] initWithName:@"GMT"];
    NSDate *startDate = [NSDate date:selectedDate withTimeZone:gmt];
    NSString *startDateString = [self removeTimeFromDate:startDate];
    NSString *ownerId = [self ownerId];
    
    DBCriteria *criteriaOne = [[DBCriteria alloc] initWithFieldName:kWhatId operatorType:SQLOperatorLike andFieldValue:[self prefixForWorkOrder]];
    DBCriteria *criteriaTwo = [[DBCriteria alloc] initWithFieldName:kStartDateTime operatorType:SQLOperatorLessThanEqualTo andFieldValue:startDateString];
    DBCriteria *criteriaFour = [[DBCriteria alloc] initWithFieldName:kEndDateTime operatorType:SQLOperatorGreaterThanEqualTo andFieldValue:startDateString];
    DBCriteria *allDayCriteriaOne = [[DBCriteria alloc] initWithFieldName:kIsAlldayEvent operatorType:SQLOperatorEqual  andFieldValue:@"true"];
    DBCriteria *allDayCriteriaTwo = [[DBCriteria alloc] initWithFieldName:kIsAlldayEvent operatorType:SQLOperatorEqual  andFieldValue:@"1"];
    
    NSArray *eventArray = nil;
    
    if (![StringUtil isStringEmpty:ownerId]) {
        
        DBCriteria *criteriaSix = [[DBCriteria alloc] initWithFieldName:kOwnerId operatorType:SQLOperatorEqual andFieldValue:ownerId];
        eventArray = [self fetchDataForObject:kEventObject fields:fieldsArray expression:@"(1 AND (2) AND  (3) AND (4 OR 5) AND 6)" criteria:[NSArray arrayWithObjects:criteriaOne, criteriaTwo, criteriaFour, allDayCriteriaOne, allDayCriteriaTwo, criteriaSix, nil]];
    }
    else {
        eventArray = [self fetchDataForObject:kEventObject fields:fieldsArray expression:@"(1 AND (2) AND  (3) AND (4 OR 5))" criteria:[NSArray arrayWithObjects:criteriaOne, criteriaTwo, criteriaFour, allDayCriteriaOne, allDayCriteriaTwo, nil]];
    }
    
    return eventArray;
}



+ (NSArray*) eventsFromSVMXEVENTOfCurrentDay:(NSDate*)selectedDate {
    
    NSArray *fieldsArray = [[NSArray alloc] initWithObjects:kSVMXActivityDate,kSVMXActivityDateTime,kSVMXDurationInMinutes,kSVMXEndDateTime, kSVMXStartDateTime, kSVMXEventName, kSVMXIsAlldayEvent, kSVMXWhatId, kId, klocalId, kObjectSfId,nil];
    NSTimeZone *gmt = [[NSTimeZone alloc] initWithName:@"GMT"];
    NSDate *startDate = [NSDate date:selectedDate withTimeZone:gmt];
    NSDate *endDate = [NSDate date:[selectedDate dateByAddingDays:1] withTimeZone:gmt];
    NSString *startDateString = [self convertDateToStringGMT:startDate];
    NSString *endDateString = [self convertDateToStringGMT:endDate];
    NSString *technicianID = [PlistManager getTechnicianId];
//TODO: working on this.
    
    DBCriteria *criteriaOne = [[DBCriteria alloc] initWithFieldName:kObjectSfId operatorType:SQLOperatorLike andFieldValue:[self prefixForWorkOrder]];
    
    DBCriteria *criteriaTwo = [[DBCriteria alloc] initWithFieldName:kSVMXStartDateTime operatorType:SQLOperatorLessThan andFieldValue:endDateString];
    
    DBCriteria *criteriaThree = [[DBCriteria alloc] initWithFieldName:kSVMXEndDateTime operatorType:SQLOperatorGreaterThan  andFieldValue:startDateString];
    
    NSArray *eventArray = nil;
    
    if (![StringUtil isStringEmpty:technicianID]) {
        
        DBCriteria *criteriaSix = [[DBCriteria alloc] initWithFieldName:kSVMXTechnicianId operatorType:SQLOperatorEqual andFieldValue:technicianID];
        
        eventArray = [self fetchDataForObject:kSVMXTableName fields:fieldsArray expression:@"(1 AND (2 AND 3) AND  4)" criteria:[NSArray arrayWithObjects:criteriaOne, criteriaTwo, criteriaThree, criteriaSix, nil]];

    }
    else {
        eventArray = [self fetchDataForObject:kSVMXTableName fields:fieldsArray expression:@"(1 AND (2 AND 3) )" criteria:[NSArray arrayWithObjects:criteriaOne, criteriaTwo, criteriaThree, nil]];
    }
    
    return eventArray;
}

+ (NSArray*) eventsFromSVMXEVENTOfCurrentDayForAllDayEvents:(NSDate*)selectedDate {
    
    NSArray *fieldsArray = [[NSArray alloc] initWithObjects:kSVMXActivityDate,kSVMXActivityDateTime,kSVMXDurationInMinutes,kSVMXEndDateTime, kSVMXStartDateTime, kSVMXEventName, kSVMXIsAlldayEvent, kSVMXWhatId, kId, klocalId,kObjectSfId, nil];
    NSTimeZone *gmt = [[NSTimeZone alloc] initWithName:@"GMT"];
    NSDate *startDate = [NSDate date:selectedDate withTimeZone:gmt];
    NSDate *endDate = [NSDate date:[selectedDate dateByAddingDays:1] withTimeZone:gmt];
    
    NSString *startDateString = [self removeTimeFromDate:startDate];
    NSString *endDateString = [self removeTimeFromDate:endDate];
//    NSString *ownerId = [self ownerId];
    NSString *technicianID = [PlistManager getTechnicianId];

    
    DBCriteria *criteriaOne = [[DBCriteria alloc] initWithFieldName:kObjectSfId operatorType:SQLOperatorLike andFieldValue:[self prefixForWorkOrder]];
    
    DBCriteria *criteriaTwo = [[DBCriteria alloc] initWithFieldName:kSVMXStartDateTime operatorType:SQLOperatorLessThanEqualTo andFieldValue:startDateString];
    
    DBCriteria *criteriaFour = [[DBCriteria alloc] initWithFieldName:kSVMXEndDateTime operatorType:SQLOperatorGreaterThanEqualTo andFieldValue:endDateString];
    
    DBCriteria *allDayCriteriaOne = [[DBCriteria alloc] initWithFieldName:kSVMXIsAlldayEvent operatorType:SQLOperatorEqual  andFieldValue:@"true"];
    DBCriteria *allDayCriteriaTwo = [[DBCriteria alloc] initWithFieldName:kSVMXIsAlldayEvent operatorType:SQLOperatorEqual  andFieldValue:@"1"];
    
    NSArray *eventArray = nil;
    
    if (![StringUtil isStringEmpty:technicianID]) {
        
        DBCriteria *criteriaSix = [[DBCriteria alloc] initWithFieldName:kSVMXTechnicianId operatorType:SQLOperatorEqual andFieldValue:technicianID];
        eventArray = [self fetchDataForObject:kSVMXTableName fields:fieldsArray expression:@"(1 AND (2) AND  (3) AND (4 OR 5) AND 6)" criteria:[NSArray arrayWithObjects:criteriaOne, criteriaTwo, criteriaFour, allDayCriteriaOne, allDayCriteriaTwo, criteriaSix, nil]];
    }
    else {
        eventArray = [self fetchDataForObject:kSVMXTableName fields:fieldsArray expression:@"(1 AND (2) AND  (3) AND (4 OR 5))" criteria:[NSArray arrayWithObjects:criteriaOne, criteriaTwo, criteriaFour, allDayCriteriaOne, allDayCriteriaTwo, nil]];
    }
    
    return eventArray;
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

+ (NSArray*)allTagValuesForWorkOrderPopup {
    
    return [NSArray arrayWithObjects:[[TagManager sharedInstance] tagByName:kTag_number], [[TagManager sharedInstance] tagByName:kTag_acInfo], [[TagManager sharedInstance] tagByName:kTag_service_location], [[TagManager sharedInstance] tagByName:kTag_appointment], [[TagManager sharedInstance] tagByName:kTag_contact], [[TagManager sharedInstance] tagByName:kTag_purposeofvisit], [[TagManager sharedInstance] tagByName:kTag_problemdescription], nil];
}

+ (NSMutableDictionary*)objectValueMapDictionary:(WorkOrderSummaryModel*)workOrder {
    
    NSMutableDictionary *objectValueMapDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    [objectValueMapDictionary setValue:![StringUtil isStringEmpty:workOrder.name] ? workOrder.name : @""
                                 forKey:[[TagManager sharedInstance] tagByName:kTag_number]];
    
    workOrder.companyName = [MapHelper getAccountNameForId:workOrder.companyId];
    if ([StringUtil isStringEmpty:workOrder.companyName] && ![StringUtil isStringEmpty:workOrder.companyId])
    {
    NSMutableDictionary *accountDict = [MapHelper getValuesFromReferenceTable:[NSArray arrayWithObject:workOrder.companyId]];
        workOrder.companyName = [accountDict valueForKey:workOrder.companyId];
    }
    if ([StringUtil isStringEmpty:workOrder.companyName] && ![StringUtil isStringEmpty:workOrder.companyId])
    {
        workOrder.companyName = workOrder.companyId;
    }
    
    [objectValueMapDictionary setValue:![StringUtil isStringEmpty:workOrder.companyName] ? workOrder.companyName : @""
                                 forKey:[[TagManager sharedInstance] tagByName:kTag_acInfo]];
    
    [objectValueMapDictionary setValue:workOrder.serviceLocationModel
                                 forKey:[[TagManager sharedInstance] tagByName:kTag_service_location]];
    
    if ([StringUtil isStringEmpty:workOrder.localScheduleDateTime]) {
        workOrder.localScheduleDateTime = workOrder.localEventStartDateTime;
    }
    
    [objectValueMapDictionary setValue:![StringUtil isStringEmpty:workOrder.localScheduleDateTime] ? workOrder.localScheduleDateTime : @""
                                 forKey:[[TagManager sharedInstance] tagByName:kTag_appointment]];
    
    ContactImageModel *contactModel = [MapHelper getContactObjectForId:workOrder.contactId];
    [objectValueMapDictionary setValue:contactModel
                                 forKey:[[TagManager sharedInstance] tagByName:kTag_contact]];
    
    NSString *purposeOfVisitValue = [self getPickListLabelForPurposeOfVisit:workOrder.purposeOfVisit];
    [objectValueMapDictionary setValue:![StringUtil isStringEmpty:purposeOfVisitValue] ? purposeOfVisitValue : @""
                                 forKey:[[TagManager sharedInstance] tagByName:kTag_purposeofvisit]];
    
    [objectValueMapDictionary setValue:![StringUtil isStringEmpty:workOrder.problemDescription] ? workOrder.problemDescription : @""
                                 forKey:[[TagManager sharedInstance] tagByName:kTag_problemdescription]];
    
    return objectValueMapDictionary;
}

+ (NSString*)getPickListLabelForPurposeOfVisit:(NSString*)selectedOption
{
    NSArray * picklistArray = [SFMPageHelper getPicklistValuesForObject:kWorkOrderTableName pickListFields:@[kWorkOrderPurposeOfVisit]];
    
    if ([picklistArray count] > 0)
    {
        for (SFPicklistModel * model in picklistArray)
        {
            if (model != nil)
            {
                if ([model.value isEqualToString:selectedOption])
                {
                    return model.label;
                }
            }
        }
    }
    return selectedOption;
}

+ (void)showMissingAddressWorkOrders:(NSMutableArray*)workOrders
{
    if ([workOrders count]) {
        
        NSString *message = nil;
        if ([workOrders count] > 1) {
            message = [workOrders componentsJoinedByString:@", "];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[TagManager sharedInstance] tagByName:kValidAddressMsgRecords] message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:[[TagManager sharedInstance] tagByName:kTagAlertErrorOk], nil];
            [alertView show];
            alertView = nil;
        }
        else {
            message = [workOrders lastObject];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[TagManager sharedInstance] tagByName:kValidAddressMsg] message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:[[TagManager sharedInstance] tagByName:kTagAlertErrorOk], nil];
            [alertView show];
            alertView = nil;
        }
    }
}

+ (void)requestTechnicianIdWithTheCallerDelegate:(id)delegate
{
    if ([[AppManager sharedInstance] hasTokenRevoked])
    {
        
        [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeAccessTokenExpired message:nil andDelegate:self];
    }
    else
    {
        TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeTechnicianDetails
                                                 requestParam:nil
                                               callerDelegate:delegate];
        [[TaskManager sharedInstance] addTask:taskModel];
    }
}

+ (void)requestTechnicianAddressForId:(NSString *)technicianId
                    andCallerDelegate:(id)delegate;
{
    if ([[AppManager sharedInstance] hasTokenRevoked])
    {
        
        [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeAccessTokenExpired message:nil andDelegate:self];
    }
    else
    {
        CacheManager *cache = [CacheManager sharedInstance];
        if ([StringUtil  isStringEmpty:technicianId]) {
            technicianId = @"";
        }
        [cache pushToCache:technicianId byKey:TECHNICIANID];
        TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeTechnicianAddress
                                                 requestParam:nil callerDelegate:delegate];
        [[TaskManager sharedInstance] addTask:taskModel];
    }
}


+(NSString *)removeTimeFromDate:(NSDate *)date
{
    NSString *lTheDateString = nil;
    lTheDateString =     [DateUtil stringFromDate:date inFormat:kDateFormatTypeOnlyDate];
    lTheDateString = [lTheDateString stringByAppendingString:@"T00:00:00.000+0000"];
    return lTheDateString;
    
}

@end
