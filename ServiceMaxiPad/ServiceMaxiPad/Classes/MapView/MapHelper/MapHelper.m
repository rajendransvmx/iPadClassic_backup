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
#import "NSDate+TKCategory.h"
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
    NSArray *fieldsArray = [[NSArray alloc] initWithObjects:kId,kContactName,kContactEmail,kContactPhone,kContactMobilePhone, nil];
    TransactionObjectModel *transModel = [transactionService getDataForObject:kContactTableName fields:fieldsArray expression:nil criteria:[NSArray arrayWithObject:criteria]];
    ContactImageModel *contactModel = [[ContactImageModel alloc] initWithTransactionModel:transModel];
    
    if (![contactModel.contactName length] && [contactId length])
    {
        NSMutableDictionary *contactDict = [MapHelper getValuesFromReferenceTable:[NSArray arrayWithObject:contactId]];
        contactModel.contactName = [contactDict valueForKey:contactId];
    }
    if (![contactModel.contactName length] && [contactId length])
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
                if ([sfId length] > 0 && [value length] > 0) {
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


+ (NSArray*)workOrderSummaryArrayOfCurrentDay {
    
    NSArray *eventsArray = [self eventsOfCurrentDay];
    NSMutableDictionary *whatEventStartDateValueMap = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    for (TransactionObjectModel *transObjModel in eventsArray) {
        NSString *whatId = [transObjModel valueForField:kWhatId];
        if ([whatId length])
            [whatEventStartDateValueMap setValue:[transObjModel valueForField:kStartDateTime] forKey:whatId];
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
    NSArray *fieldsArray = [[NSArray alloc] initWithObjects:kId, klocalId,kWorkOrderContactId,kWorkOrderName,kWorkOrderCompanyId,kWorkOrderScheduledDateTime,kWorkOrderSTREET,kWorkOrderCITY, kWorkOrderSTATE, kWorkOrderCOUNTRY, kWorkOrderZIP, kWorkOrderPurposeOfVisit, kWorkOrderProblemDescription, kWorkOrderPriority, kWorkOrderLatitude, kWorkOrderLongitude, nil];
    
    NSArray *workOrderArray = [self fetchDataForObject:kWorkOrderTableName fields:fieldsArray expression:nil criteria:[NSArray arrayWithObject:criteriaOne]];

    NSMutableArray *workOrderSummaryArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (TransactionObjectModel *transObjModel in workOrderArray) {
        
        WorkOrderSummaryModel *woSummaryModel = [[WorkOrderSummaryModel alloc] initWithTransactionModel:transObjModel andIdEventStartValueMap:whatEventStartDateValueMap];
        [workOrderSummaryArray addObject:woSummaryModel];
    }
    
    return workOrderSummaryArray;
}

+ (NSArray*) eventsOfCurrentDay {

    NSArray *fieldsArray = [[NSArray alloc] initWithObjects:kActivityDate,kActivityDateTime,kDurationInMinutes,kEndDateTime, kStartDateTime, kSubject, kWhatId, kId, klocalId, nil];
    NSTimeZone *gmt = [[NSTimeZone alloc] initWithName:@"GMT"];
    NSDate *startDate = [NSDate todayWithTimeZone:gmt];
    NSDate *endDate = [NSDate tomorrowWithTimeZone:gmt];
    NSString *startDateString = [self convertDateToStringGMT:startDate];
    NSString *endDateString = [self convertDateToStringGMT:endDate];
    NSString *ownerId = [self ownerId];
    
    DBCriteria *criteriaOne = [[DBCriteria alloc] initWithFieldName:kWhatId operatorType:SQLOperatorLike andFieldValue:[self prefixForWorkOrder]];
    
    DBCriteria *criteriaTwo = [[DBCriteria alloc] initWithFieldName:kStartDateTime operatorType:SQLOperatorGreaterThanEqualTo andFieldValue:startDateString];
    
    DBCriteria *criteriaThree = [[DBCriteria alloc] initWithFieldName:kStartDateTime operatorType:SQLOperatorLessThan andFieldValue:endDateString];
    
    DBCriteria *criteriaFour = [[DBCriteria alloc] initWithFieldName:kEndDateTime operatorType:SQLOperatorGreaterThanEqualTo andFieldValue:startDateString];
    
    DBCriteria *criteriaFive = [[DBCriteria alloc] initWithFieldName:kEndDateTime operatorType:SQLOperatorLessThan andFieldValue:endDateString];
    
    NSArray *eventArray = nil;
    
    if ([ownerId length]) {
        
        DBCriteria *criteriaSix = [[DBCriteria alloc] initWithFieldName:kOwnerId operatorType:SQLOperatorEqual andFieldValue:ownerId];
        eventArray = [self fetchDataForObject:kEventObject fields:fieldsArray expression:@"(1 AND (2 AND 3) OR (4 AND 5) AND 6)" criteria:[NSArray arrayWithObjects:criteriaOne, criteriaTwo, criteriaThree, criteriaFour, criteriaFive, criteriaSix,nil]];
    }
    else {
        eventArray = [self fetchDataForObject:kEventObject fields:fieldsArray expression:@"(1 AND (2 AND 3) OR (4 AND 5))" criteria:[NSArray arrayWithObjects:criteriaOne, criteriaTwo, criteriaThree, criteriaFour, criteriaFive,nil]];
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

+ (NSArray*)allKeysForWorkOrderPopup {
    
    return [NSArray arrayWithObjects:kMapWONumber, kMapAccount, kMapServiceLocation, kMapAppointment,kMapContact, kMapPurposeOfVisit, kMapProblemDescription, nil];
}

+ (NSArray*)allTagValuesForWorkOrderPopup {
    
    NSMutableArray *allValues = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSString *key in [MapHelper allKeysForWorkOrderPopup]) {
        
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

+ (NSMutableDictionary*)objectValueMapDictionary:(WorkOrderSummaryModel*)workOrder {
    
    NSMutableDictionary *objectValueMapDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    [objectValueMapDictionary setValue:[workOrder.name length] ? workOrder.name : @""
                                 forKey:kMapWONumber];
    
    workOrder.companyName = [MapHelper getAccountNameForId:workOrder.companyId];
    if (![workOrder.companyName length] && [workOrder.companyId length])
    {
    NSMutableDictionary *accountDict = [MapHelper getValuesFromReferenceTable:[NSArray arrayWithObject:workOrder.companyId]];
        workOrder.companyName = [accountDict valueForKey:workOrder.companyId];
    }
    else
    {
        workOrder.companyName = workOrder.companyId;
    }
    
    [objectValueMapDictionary setValue:[workOrder.companyName length] ? workOrder.companyName : @""
                                 forKey:kMapAccount];
    
    [objectValueMapDictionary setValue:workOrder.serviceLocationModel
                                 forKey:kMapServiceLocation];
    
    [objectValueMapDictionary setValue:[workOrder.localScheduleDateTime length] ? workOrder.localScheduleDateTime : @""
                                 forKey:kMapAppointment];
    
    ContactImageModel *contactModel = [MapHelper getContactObjectForId:workOrder.contactId];
    [objectValueMapDictionary setValue:contactModel
                                 forKey:kMapContact];
    
    [objectValueMapDictionary setValue:[workOrder.purposeOfVisit length] ? workOrder.purposeOfVisit : @""
                                 forKey:kMapPurposeOfVisit];
    
    [objectValueMapDictionary setValue:[workOrder.problemDescription length] ? workOrder.problemDescription : @""
                                 forKey:kMapProblemDescription];
    
    return objectValueMapDictionary;
}

+ (void)showMissingAddressWorkOrders:(NSMutableArray*)workOrders
{
    if ([workOrders count]) {
        
        NSString *message = nil;
        if ([workOrders count] > 1) {
            message = [workOrders componentsJoinedByString:@", "];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:KMapNoValidAddresses message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:[[TagManager sharedInstance] tagByName:kTagAlertErrorOk], nil];
            [alertView show];
            alertView = nil;
        }
        else {
            message = [workOrders lastObject];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:KMapNoValidAddress message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:[[TagManager sharedInstance] tagByName:kTagAlertErrorOk], nil];
            [alertView show];
            alertView = nil;
        }
    }
}

@end
