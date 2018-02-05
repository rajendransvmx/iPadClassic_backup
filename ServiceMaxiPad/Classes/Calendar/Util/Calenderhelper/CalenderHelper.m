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
//#import "TransactionObjectModel.h"
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
#import "ResolveConflictsHelper.h"
#import "SMXCalendarViewController.h"
#import "CaseObjectModel.h"
#import "SFMRecordFieldData.h"
#import "SFMPageEditManager.h"
#import "NSDate+SMXDaysCount.h"
#import "EventTransactionObjectModel.h"
#import "StringUtil.h"
#import "PlistManager.h"   //For getting Technician ID to be used in query to get events from SVMX_EVENT Table
#import "UniversalDAO.h"
#import "SMXProductListModel.h"
#import "SFObjectFieldDAO.h"
#import "SFObjectFieldService.h"
#import "NSDate+SMXDaysCount.h"
#import "DatabaseIndexManager.h"

#define stringLimitInProduct 80

#define EventTableSetting @"IPAD006_SET005" // For getting calendar title display fields for Salesforce Events.
#define SVMXEventTableSetting @"IPAD006_SET006"  // For getting calendar title display fields for SVMX Events.

@interface CalenderHelper ()

+ (NSArray *)fetchDataForObject:(NSString *)objectName
                         fields:(NSArray *)fieldNames
                     expression:(NSString *)advancaeExpression
                       criteria:(NSArray *)criteria;

@property (nonatomic, strong) NSString *cRangeOfDaysString;
@property (nonatomic, strong) NSDictionary *salesforceEventFieldList;
@property (nonatomic, strong) NSDictionary *svmxEventEventFieldList;
@property (nonatomic, strong) NSString *salesforceEventTitleSettingString;
@property (nonatomic, strong) NSString *svmxEventTitleSettingString;

@end

@implementation CalenderHelper
@synthesize cRangeOfDaysString;

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

+(NSString *)fetchBusinessHours
{
    
    id <MobileDeviceSettingDAO> mobileSettingService = [FactoryDAO serviceByServiceType:ServiceTypeMobileDeviceSettings];
    
    MobileDeviceSettingsModel *lMobileDeviceSettingsModel = [mobileSettingService fetchDataForSettingId:@"DCON001_SET052"];
    
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

+ (NSMutableDictionary*)getWorkOrdersForWhatIds:(NSMutableDictionary*)whatEventStartDateValueMap {
    
    DBCriteria *criteriaOne = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIn andFieldValues:[whatEventStartDateValueMap allKeys]];
    NSArray *fieldsArray = [[NSArray alloc] initWithObjects:kId, klocalId,kWorkOrderContactId,kWorkOrderName,kWorkOrderCompanyId,kWorkOrderSTREET,kWorkOrderCITY, kWorkOrderSTATE, kWorkOrderCOUNTRY, kWorkOrderZIP, kWorkOrderPurposeOfVisit, kWorkOrderProblemDescription, kWorkOrderPriority, kWorkOrderBillingType, kWorkOrderOrderStatus, kWorkOrderCompanyId, kWorkOrderSite, nil];
    
    NSArray *workOrderArray = [self fetchDataFromWorkOrderObject:kWorkOrderTableName fields:fieldsArray expression:nil criteria:[NSArray arrayWithObject:criteriaOne]];
    
    NSMutableDictionary *workOrderSummaryDict= [[NSMutableDictionary alloc] initWithCapacity:0];
    
    for (TransactionObjectModel *transObjModel in workOrderArray) {
        
        WorkOrderSummaryModel *woSummaryModel = [[WorkOrderSummaryModel alloc] initWithTransactionModel:transObjModel andIdEventStartValueMap:whatEventStartDateValueMap];
        
        NSString *companyName = [self getAccountNameForCompanyId:[transObjModel valueForField:kWorkOrderCompanyId]];
        
        
        if ([StringUtil isStringEmpty:companyName] && ![StringUtil isStringEmpty:woSummaryModel.companyId])
        {
            NSMutableDictionary *accountDict = [self getValuesFromReferenceTable:[NSArray arrayWithObject:woSummaryModel.companyId]];
            companyName = [accountDict valueForKey:woSummaryModel.companyId];
        }
        else if ([StringUtil isStringEmpty:companyName])
        {
            companyName = woSummaryModel.companyId;
            
        }
        woSummaryModel.companyName = companyName;
        
        if (![StringUtil isStringEmpty:[transObjModel valueForField:kWorkOrderSite]]) {
            woSummaryModel.IPAtLocation = [self getInstalledListFromSite: [transObjModel valueForField:kWorkOrderSite]];
            
        }
        else{
            woSummaryModel.IPAtLocation = nil;
        }
        
        [workOrderSummaryDict setObject:woSummaryModel forKey:woSummaryModel.Id];
        [workOrderSummaryDict setObject:woSummaryModel forKey:[woSummaryModel.Id substringToIndex:woSummaryModel.Id.length - 3]]; //For SVMX Event, the what ID is shorter by last 3 characters.
        
    }
    
    return workOrderSummaryDict;
}


-(NSArray *) getEventDetailsForTheDay
{
    
    NSMutableArray *lCaseSFIDArray = [[NSMutableArray alloc] init];
    NSDictionary *lTitleFieldDict =  [self getCalendarEventTitleData];
    self.salesforceEventFieldList = [lTitleFieldDict objectForKey:kEventObject];
    self.svmxEventEventFieldList = [lTitleFieldDict objectForKey:kSVMXTableName];
    
    //    NSLog(@"<<<<<<<<<<<<<<<<< START eventsOfRangeOfDays >>>>>>>>>>>>>>>>>>");
    NSMutableArray *lEventListArray = (NSMutableArray *) [self eventsOfRangeOfDaysForSalesForceEventTable];
    NSMutableArray *lSVMXEventListArray = (NSMutableArray *) [self eventsFromSVMXEventTable];
    
    //    NSLog(@"<<<<<<<<<<<<<<<<< END eventsOfRangeOfDays >>>>>>>>>>>>>>>>>>");
    
    NSMutableArray *lEventArray = lEventListArray;//[self removeTheDayPadding:lEventListArray];
    
    NSMutableDictionary *whatEventStartDateValueMap = [[NSMutableDictionary alloc] init];
    
    id <CalenderDAO> serviceRequest = [FactoryDAO serviceByServiceType:ServiceCalenderEventList];
    
    if (![SMXCalendarViewController sharedInstance].cCaseDetailsDict) {
        [SMXCalendarViewController sharedInstance].cCaseDetailsDict = [[NSMutableDictionary alloc]init];
    }
    for (EventTransactionObjectModel *lModel in lEventArray) {
        
        [lModel hasTimeZoneChanged];         //Checking if the split events are adhering to the current local timezone. Everything is done at the Model level.
        
        NSMutableDictionary *theDict = (NSMutableDictionary *) [lModel getFieldValueDictionary];
        
        NSString *objectName =  [serviceRequest getObjectName:[theDict objectForKey:kWhatId]];
        //
        if ([objectName isEqualToString:kWorkOrderTableName]) {
            
            [whatEventStartDateValueMap setObject:[theDict objectForKey:kStartDateTime]forKey:[theDict objectForKey:kWhatId]];
            
            [theDict setObject:@"YES" forKey:@"isWorkOrder"];
            
        }
        else if ([objectName isEqualToString:kCaseObject]) {
            [lCaseSFIDArray addObject:[theDict objectForKey:kWhatId]];
            [theDict setObject:@"YES" forKey:@"isCaseEvent"];
            CaseObjectModel *object = [CaseObjectModel new];
            [[SMXCalendarViewController sharedInstance].cCaseDetailsDict setObject:object forKey:[theDict objectForKey:kWhatId]];
        }
        [self settingTheTitleOfEvent:theDict forSalesforceEvent:YES];

    }
    
    for (EventTransactionObjectModel *lModel in lSVMXEventListArray) {
        
        [lModel hasTimeZoneChanged];         //Checking if the split events are adhering to the current local timezone. Everything is done at the Model level.
        
        NSMutableDictionary *theDict = (NSMutableDictionary *) [lModel getFieldValueDictionary];
        NSString *objectName =  [serviceRequest getObjectName:[theDict objectForKey:kObjectSfId]];
        
        if ([objectName isEqualToString:kWorkOrderTableName]) {
            
            [whatEventStartDateValueMap setObject:[theDict objectForKey:kSVMXStartDateTime]forKey:[theDict objectForKey:kObjectSfId]];
            //           lModel.isWorkOrder = YES;
            [theDict setObject:@"YES" forKey:@"isWorkOrder"];
        }
        else if ([objectName isEqualToString:kCaseObject]) {
            [lCaseSFIDArray addObject:[theDict objectForKey:kObjectSfId]];
            //            lModel.isCaseEvent = YES;
            [theDict setObject:@"YES" forKey:@"isCaseEvent"];
            
            CaseObjectModel *object = [CaseObjectModel new];
            [[SMXCalendarViewController sharedInstance].cCaseDetailsDict setObject:object forKey:[theDict objectForKey:kObjectSfId]];
        }
        [self settingTheTitleOfEvent:theDict forSalesforceEvent:NO];

    }
    
    if (whatEventStartDateValueMap.count>0) {
        // if event is work order, attach WorkOrderSummaryModel to the CalenderEventObjectModel
        
        [SMXCalendarViewController sharedInstance].cWODetailsDict =  [CalenderHelper getWorkOrdersForWhatIds:whatEventStartDateValueMap];
        
    }
    
    NSMutableSet *set = [NSMutableSet setWithArray:lEventListArray];
    [set addObjectsFromArray:lSVMXEventListArray];
    NSArray *combinedArray = [set allObjects];
    
    return combinedArray;
    
}

+(BOOL)isConflicted:(NSString *)lWhatId
{
    id <CalenderDAO> serviceRequest = [FactoryDAO serviceByServiceType:ServiceCalenderEventList];
    
    TransactionObjectModel *model =  [serviceRequest getRecordForSalesforceId:lWhatId];
    
    long numberOfRecords = [self getNumberOfConflictRecordsForTransactionModel:model];
    
    if (numberOfRecords>0) {
        
        //If the parent itself is there in the conflict table
        return YES;
    }
    
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
        
        long numberOfRecords = [self getNumberOfConflictRecordsForTransactionModel:lTransModel];
        
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


+(long)getNumberOfConflictRecordsForTransactionModel:(TransactionObjectModel *)lTransModel
{
    DBCriteria *syncCriteria1 = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:lTransModel.recordLocalId];
    
    DBCriteria *syncCriteria2 = [[DBCriteria alloc] initWithFieldName:kSyncRecordSFId operatorType:SQLOperatorEqual andFieldValue:[lTransModel valueForField:@"Id"]];
    
    id <SyncErrorConflictDAO> syncErrorService = [FactoryDAO serviceByServiceType:ServiceTypeSyncErrorConflict];
    
    long numberOfRecords = [syncErrorService getNumberOfRecordsFromObject:kSyncErrorConflictTableName withDbCriteria:@[syncCriteria1, syncCriteria2] andAdvancedExpression:@"(1 OR 2)"];
    
    return numberOfRecords;
}



-(void)getSLAPriorityForEventArray:(NSArray *)eventArray
{
    NSArray *lAllWOWhatIDs = [[SMXCalendarViewController sharedInstance].cWODetailsDict allKeys];
    NSArray *lAllCaseWhatIDs = [[SMXCalendarViewController sharedInstance].cCaseDetailsDict allKeys];
    
    NSMutableArray *lFinishedID = [NSMutableArray new];
    
    for (int i = 0; i<eventArray.count; i++) {
        
        SMXEvent *eventModel = [eventArray objectAtIndex:i];
        
        if ([eventModel.eventTableName isEqualToString:kSVMXTableName])
        {
            NSArray *whatIDs = [[SMXCalendarViewController sharedInstance].cWODetailsDict allKeysForObject:[[SMXCalendarViewController sharedInstance].cWODetailsDict objectForKey:eventModel.whatId]];
            
            for (NSString *whatID in whatIDs) {
                if (whatID.length>15) {
                    eventModel.whatId = whatID;
                    break;
                }
            }
        }
        
        if ([eventModel.whatId length] && ![lFinishedID containsObject:eventModel.whatId]) {
            
            [lFinishedID addObject:eventModel.whatId];
            
            BOOL conflict = [CalenderHelper isConflicted:eventModel.whatId];
            eventModel.conflict = conflict;
            
            NSDictionary *slaPriorityDictionary = [self SLAAndPriorityStatusForwhatID:eventModel.whatId];
            
            NSNumber *slaMetric = [slaPriorityDictionary objectForKey:@"slaStatus"];
            eventModel.sla = [slaMetric boolValue];
            
            NSString *priorityStatus = [slaPriorityDictionary objectForKey:@"priorityStatus"];
            if ([priorityStatus isEqualToString:@"High"]) {
                eventModel.priority = YES;
            }
            else
            {
                eventModel.priority = NO;
            }
            eventModel.priorityString = priorityStatus;
            
            
            if ([lAllWOWhatIDs containsObject:eventModel.whatId]) {
                WorkOrderSummaryModel *model = [[SMXCalendarViewController sharedInstance].cWODetailsDict objectForKey:eventModel.whatId];
                model.sla = [slaMetric boolValue];
                model.priority = [NSNumber numberWithBool:eventModel.priority];
            }
            
            else if ([lAllCaseWhatIDs containsObject:eventModel.whatId]) {
                CaseObjectModel *tempModel = [[SMXCalendarViewController sharedInstance].cCaseDetailsDict objectForKey:eventModel.whatId];
                tempModel.sla = [slaMetric boolValue];
                tempModel.priorityString = priorityStatus;
                if ([priorityStatus isEqualToString:@"High"]) {
                    tempModel.priority = YES;
                }
                else
                {
                    tempModel.priority = NO;
                }
                
            }
            
            
        }
        eventModel.newData = YES;
    }
    
    if (self.completionHandler)
    {
        self.completionHandler(eventArray);
    }
}


-(NSDictionary *)SLAAndPriorityStatusForwhatID:(NSString *)lWhatId
{
    
    id <CalenderDAO> serviceRequest = [FactoryDAO serviceByServiceType:ServiceCalenderEventList];
    
    TransactionObjectModel *model =  [serviceRequest getRecordForSalesforceId:lWhatId];
    
    if(!([model.objectAPIName isEqualToString:kCaseObject] || [model.objectAPIName isEqualToString:kWorkOrderTableName]))
    {
        
        //if the object is neither case nor WorkOrder
        return @{@"slaStatus":[NSNumber numberWithBool:NO], @"priorityStatus" : @"Low"};
    }
    
    
    
    id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorEqual andFieldValue:lWhatId];
    
    NSArray *objects =   [transObjectService fetchDataForObject:model.objectAPIName fields:@[kSLARestorationCustomer, kSLAResolutionCustomer, kSLAActualRestoration, kSLAActualResolution, kSLAClockPauseTime, kSLAClockPaused] expression:nil criteria:@[criteria]];
    
    BOOL status = NO;
    NSString *priorityStatus = @"Low";
    if ([objects count] > 0) {
        TransactionObjectModel *record =  [objects objectAtIndex:0];
        [record setObjectName:model.objectAPIName];
        NSDictionary *dataDictionary = [model getFieldValueDictionary];
        
        if (dataDictionary != nil) {
            if (dataDictionary.count > 0) {
                
                //if any field present then problem with SLA. Otherwise no other field apart from kSLAClockPaused will have any value.
                
                {
                    
                    NSString *SLARestoratorationCustomer = [dataDictionary objectForKey:kSLARestorationCustomer];
                    NSString *SLAResolutionCustomer = [dataDictionary objectForKey:kSLAResolutionCustomer];
                    NSString *SLAActualRestoration = [dataDictionary objectForKey:kSLAActualRestoration];
                    NSString *SLAActualResolution = [dataDictionary objectForKey:kSLAActualResolution];
                    NSString *SLAClockPauseTime = [dataDictionary objectForKey:kSLAClockPauseTime];
                    NSString *SLAClockPaused  = [dataDictionary objectForKey:kSLAClockPaused];
                    NSString *lpriorityStatusTemp;
                    
                    if ([model.objectAPIName isEqualToString:kCaseObject]) {
                        lpriorityStatusTemp = [dataDictionary objectForKey:@"Priority"];
                    }
                    else
                    {
                        lpriorityStatusTemp = [dataDictionary objectForKey:kWorkOrderPriority];
                        
                    }
                    
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
                        status = ([SLAClockPaused isEqualToString:@"true"]? YES:NO);
                        
                    }
                    
                    priorityStatus = (lpriorityStatusTemp.length>0 ? lpriorityStatusTemp:priorityStatus); //Priority
                    
                }
                
            }
        }
        
    }
    
    
    return @{@"slaStatus":[NSNumber numberWithBool:status], @"priorityStatus" : priorityStatus};
}

-(TransactionObjectModel *)isWhatIDbelongstoWorkOrder:(NSString *)lWhatID
{
    id <CalenderDAO> serviceRequest = [FactoryDAO serviceByServiceType:ServiceCalenderEventList];
    
    TransactionObjectModel *model =  [serviceRequest getRecordForSalesforceId:lWhatID];
    
    return model;
    
}

+(ServiceLocationModel *)getServiceLocationModel:(NSString *)lWhatID
{
    id <CalenderDAO> serviceRequest = [FactoryDAO serviceByServiceType:ServiceCalenderEventList];
    
    TransactionObjectModel *model =  [serviceRequest getRecordForSalesforceId:lWhatID];
    
    ServiceLocationModel *ServiceModel = [[ServiceLocationModel alloc] initWithTransactionModel:model];
    return ServiceModel;
}

/*
 
 Method Name: eventsOfRangeOfDaysForSalesForceEventTable
 Description: This Method gets all the events in date range.
 
 Date Range Calculations
 
 Start Date = Current Day - SyncDayRange - 1
 End Date = Current + SyncDayRange + 1
 
 */

- (NSArray*) eventsOfRangeOfDaysForSalesForceEventTable {
    
    cRangeOfDaysString = [CalenderHelper getSyncDayRangeFromMobileDeviceSettings];
    
    int lRangeDayInt = [cRangeOfDaysString intValue];
    
    //    lRangeDayInt = 150; //TODO:Remove it. for testing only
    
    if (lRangeDayInt<=0) {
        lRangeDayInt = 1;
    }
    
    NSDate *lStartDate = [self dateWithOutTime:[[NSDate date] dateByAddingTimeInterval:-60*60*24*lRangeDayInt]];
    NSDate *lEndDate = [self dateWithOutTime:[[NSDate date] dateByAddingDays:lRangeDayInt+1]];
    [[SMXDateManager sharedManager] setStartDateWindow:lStartDate];
    [[SMXDateManager sharedManager] setEndDateWindow:lEndDate];
    
    NSTimeZone *gmt = [[NSTimeZone alloc] initWithName:@"GMT"];
    NSDate *startDate = [NSDate date:lStartDate withTimeZone:gmt];
    
    NSDate *endDate = [NSDate date:lEndDate withTimeZone:gmt];
    
    NSString *startDateString = [CalenderHelper convertDateToStringGMT:startDate];
    NSString *endDateString = [CalenderHelper convertDateToStringGMT:endDate];
    NSString *ownerId = [CalenderHelper ownerId];
    
    // ==== START FOR MULTI-DAY EVENTS, WHEREIN THE EVENT IS STARTING BEFORE THE EVENT WINDOW
    DBCriteria *lMultiDayCriteriaOne = [[DBCriteria alloc] initWithFieldName:kStartDateTime operatorType:SQLOperatorLessThan andFieldValue:startDateString];
    
    DBCriteria *lMultiDayCriteriaTwo = [[DBCriteria alloc] initWithFieldName:kEndDateTime operatorType:SQLOperatorGreaterThanEqualTo andFieldValue:endDateString];
    
    // ==== END FOR MULTI-DAY EVENTS, WHEREIN THE EVENT IS STARTING BEFORE THE EVENT WINDOW
    
    DBCriteria *criteriaTwo = [[DBCriteria alloc] initWithFieldName:kStartDateTime operatorType:SQLOperatorGreaterThanEqualTo andFieldValue:startDateString];
    
    DBCriteria *criteriaThree = [[DBCriteria alloc] initWithFieldName:kStartDateTime operatorType:SQLOperatorLessThan andFieldValue:endDateString];
    
    DBCriteria *criteriaFour = [[DBCriteria alloc] initWithFieldName:kEndDateTime operatorType:SQLOperatorGreaterThanEqualTo andFieldValue:startDateString];
    
    DBCriteria *criteriaFive = [[DBCriteria alloc] initWithFieldName:kEndDateTime operatorType:SQLOperatorLessThan andFieldValue:endDateString];
    
    //When the Start date or end date are not present. Either NULl or blank.
    DBCriteria *criteriaWhenStartNotPresent = [[DBCriteria alloc] initWithFieldName:kStartDateTime operatorType:SQLOperatorIsNotNull andFieldValue:nil];
    
    DBCriteria *criteriaWhenEndNotPresent = [[DBCriteria alloc] initWithFieldName:kEndDateTime operatorType:SQLOperatorIsNotNull andFieldValue:nil];
    
    NSArray *eventArray = nil;
    
    id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    if (![StringUtil isStringEmpty:ownerId]) {
        
        DBCriteria *criteriaSix = [[DBCriteria alloc] initWithFieldName:kOwnerId operatorType:SQLOperatorEqual andFieldValue:ownerId];
        
        eventArray = [transObjectService fetchEventDataForObject:kEventObject fields:nil expression:@"(((1 AND 2) OR (3 AND 4) OR (5 AND 6)) AND 7 AND 8 AND 9)" criteria:[NSArray arrayWithObjects:criteriaTwo, criteriaThree, criteriaFour, criteriaFive, lMultiDayCriteriaOne, lMultiDayCriteriaTwo, criteriaWhenStartNotPresent, criteriaWhenEndNotPresent, criteriaSix, nil]];
    }
    else {
        //            eventArray = [transObjectService fetchEventDataForObject:kEventObject fields:fieldsArray expression:@"(((1 AND 2) OR (3 AND 4)) OR (6 AND 7) AND ())" criteria:[NSArray arrayWithObjects: criteriaTwo, criteriaThree, criteriaFour, criteriaFive, nil]];
        
        eventArray = [transObjectService fetchEventDataForObject:kEventObject fields:nil expression:@"(((1 AND 2) OR (3 AND 4) OR (5 AND 6)) AND (7 AND 8))" criteria:[NSArray arrayWithObjects:criteriaTwo, criteriaThree, criteriaFour, criteriaFive, lMultiDayCriteriaOne, lMultiDayCriteriaTwo, criteriaWhenStartNotPresent, criteriaWhenEndNotPresent, nil]];
    }
    
    return eventArray;
}


-(NSArray *)eventsFromSVMXEventTable
{
    int lRangeDayInt = [cRangeOfDaysString intValue];
    
    //    lRangeDayInt = 150; //TODO:Remove it. for testing only
    
    if (lRangeDayInt<=0) {
        lRangeDayInt = 1;
    }
    
    NSDate *lStartDate = [self dateWithOutTime:[[NSDate date] dateByAddingTimeInterval:-60*60*24*lRangeDayInt]];
    NSDate *lEndDate = [self dateWithOutTime:[[NSDate date] dateByAddingDays:lRangeDayInt+1]];
    
    NSTimeZone *gmt = [[NSTimeZone alloc] initWithName:@"GMT"];
    NSDate *startDate = [NSDate date:lStartDate withTimeZone:gmt];
    
    NSDate *endDate = [NSDate date:lEndDate withTimeZone:gmt];
    
    NSString *startDateString = [CalenderHelper convertDateToStringGMT:startDate];
    NSString *endDateString = [CalenderHelper convertDateToStringGMT:endDate];
    //    NSString *ownerId = [CalenderHelper ownerId];
    NSString *technicianID = [PlistManager getTechnicianId];
    
    // ==== START FOR MULTI-DAY EVENTS, WHEREIN THE EVENT IS STARTING BEFORE THE EVENT WINDOW
    DBCriteria *lMultiDayCriteriaOne = [[DBCriteria alloc] initWithFieldName:kSVMXStartDateTime operatorType:SQLOperatorLessThan andFieldValue:startDateString];
    
    DBCriteria *lMultiDayCriteriaTwo = [[DBCriteria alloc] initWithFieldName:kSVMXEndDateTime operatorType:SQLOperatorGreaterThanEqualTo andFieldValue:endDateString];
    
    // ==== END FOR MULTI-DAY EVENTS, WHEREIN THE EVENT IS STARTING BEFORE THE EVENT WINDOW
    
    DBCriteria *criteriaTwo = [[DBCriteria alloc] initWithFieldName:kSVMXStartDateTime operatorType:SQLOperatorGreaterThanEqualTo andFieldValue:startDateString];
    
    DBCriteria *criteriaThree = [[DBCriteria alloc] initWithFieldName:kSVMXStartDateTime operatorType:SQLOperatorLessThan andFieldValue:endDateString];
    
    DBCriteria *criteriaFour = [[DBCriteria alloc] initWithFieldName:kSVMXEndDateTime operatorType:SQLOperatorGreaterThanEqualTo andFieldValue:startDateString];
    
    DBCriteria *criteriaFive = [[DBCriteria alloc] initWithFieldName:kSVMXEndDateTime operatorType:SQLOperatorLessThan andFieldValue:endDateString];
    
    //When the Start date or end date are not present. Either NULl or blank.
    DBCriteria *criteriaWhenStartNotPresent = [[DBCriteria alloc] initWithFieldName:kSVMXStartDateTime operatorType:SQLOperatorIsNotNull andFieldValue:nil];
    
    DBCriteria *criteriaWhenEndNotPresent = [[DBCriteria alloc] initWithFieldName:kSVMXEndDateTime operatorType:SQLOperatorIsNotNull andFieldValue:nil];
    
    
    
    NSArray *eventArray = nil;
    
    id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    if (![StringUtil isStringEmpty:technicianID]) {
        
        DBCriteria *criteriaSix = [[DBCriteria alloc] initWithFieldName:kSVMXTechnicianId operatorType:SQLOperatorEqual andFieldValue:technicianID];
        
        eventArray = [transObjectService fetchEventDataForObject:kSVMXTableName fields:nil expression:@"(((1 AND 2) OR (3 AND 4) OR (7 AND 6)) AND 7 AND 8 AND 9)" criteria:[NSArray arrayWithObjects:criteriaTwo, criteriaThree, criteriaFour, criteriaFive, lMultiDayCriteriaOne, lMultiDayCriteriaTwo, criteriaWhenStartNotPresent, criteriaWhenEndNotPresent, criteriaSix, nil]];
    }
    else {
        //              eventArray = [transObjectService fetchEventDataForObject:kSVMXTableName fields:fieldsArray expression:@"(((1 AND 2) OR (3 AND 4)) OR (6 AND 7))" criteria:[NSArray arrayWithObjects: criteriaTwo, criteriaThree, criteriaFour, criteriaFive, nil]];
        
        eventArray = [transObjectService fetchEventDataForObject:kSVMXTableName fields:nil expression:@"((1 AND 2) OR (3 AND 4) OR (5 AND 6) AND 7 AND 8)" criteria:[NSArray arrayWithObjects:criteriaTwo, criteriaThree, criteriaFour, criteriaFive, lMultiDayCriteriaOne, lMultiDayCriteriaTwo, criteriaWhenStartNotPresent, criteriaWhenEndNotPresent, nil]];
    }
    
    return eventArray;
}


+(NSString *)getSyncDayRangeFromMobileDeviceSettings
{
    [self getBusinessHoursForTheUser];
    
    NSString *rangeDay = [self fetchSyncDayRange];
    //rangeDay = @"5";
    return rangeDay;
}

+(void)getBusinessHoursForTheUser
{
    NSString *lBHours = [self fetchBusinessHours];
    
    if(lBHours)
        [[SMXDateManager sharedManager] setBusinessHours:lBHours];
}



+ (void)updateEvent:(SMXEvent *)event toActivityDate:(NSDate *) activityDate andStartTime:(NSDate *)startTime withEndTime:(NSDate *)endTime multiDayEvent:(NSArray *)objectArray
{
    
    NSDateComponents *comp = [NSDate componentsOfDate:startTime];
    activityDate = [NSDate dateWithYear:comp.year month:comp.month day:comp.day];
    
    SMXEvent *___lEvent = [SMXEvent new];
    ___lEvent.ActivityDateDay = activityDate;
    ___lEvent.localID = event.localID;
    ___lEvent.IDString = event.IDString;
    ___lEvent.dateTimeBegin = startTime;
    ___lEvent.dateTimeEnd = endTime;
    ___lEvent.isMultidayEvent = event.isMultidayEvent;
    ___lEvent.eventTableName = event.eventTableName;
    
    if (event != nil && [event.localID length] > 0)
    {
        DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:___lEvent.localID];
        
        id <CalenderDAO> lCalenderService = [FactoryDAO serviceByServiceType:ServiceCalenderEventList];
        
        NSArray *lFieldsArray = [self getEventFieldsForEvent:event];
        
        //get modified field json by comparing data before update and data after update
        NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithDictionary:[self getDataDict:___lEvent forFields:lFieldsArray andSplitEventArray:nil]];
        
        for (NSString * key in [dataDictionary allKeys]) {
            SFMRecordFieldData *recordFieldData = [[SFMRecordFieldData alloc]init];
            recordFieldData.name =  key;
            recordFieldData.internalValue = [dataDictionary objectForKey:key];
            [dataDictionary setObject:recordFieldData forKey:key];
        }
        SFMPageEditManager *pageEditManager = [[SFMPageEditManager alloc]init];
        pageEditManager.dataDictionaryAfterModification = dataDictionary;
        
        NSString *modifiedFieldAsJson = [pageEditManager getJsonStringAfterComparisionForObject:event.eventTableName recordId:event.localID sfid:event.IDString andSettingsFlag:YES];
        
        //if servicemax event need to update svmx_event table
        //else update event table
        
        BOOL status = [lCalenderService updateEachRecord:[self getDataDict:___lEvent forFields:lFieldsArray andSplitEventArray:objectArray]
                                              withFields:lFieldsArray
                                            withCriteria:[NSArray arrayWithObject:criteria]
                                           withTableName:event.eventTableName];
        
        ModifiedRecordModel *modifiedRecord = [[ModifiedRecordModel alloc]init];
        modifiedRecord.objectName = event.eventTableName;
        modifiedRecord.recordLocalId = event.localID;
        modifiedRecord.sfId = event.IDString;
        modifiedRecord.operation = kModificationTypeUpdate;
        modifiedRecord.recordType = kRecordTypeMaster;
        modifiedRecord.timeStamp = [DateUtil getDatabaseStringForDate:[NSDate date]];
        
        BOOL canUpdate = YES;
        if ([modifiedRecord.operation isEqualToString:kModificationTypeUpdate]) {
            
            if (modifiedFieldAsJson != nil) {
                modifiedRecord.fieldsModified = modifiedFieldAsJson;
            }
            else{
                if (pageEditManager.isfieldMergeEnabled) {
                    canUpdate = NO;
                }
            }
        }
        
        if (status && canUpdate) {
            id modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
            
            if (![StringUtil isStringEmpty:event.IDString]) {
                
                if ([modifiedRecordService conformsToProtocol:@protocol(ModifiedRecordsDAO)]) {
                    BOOL saveStatus = [modifiedRecordService saveRecordModel:modifiedRecord];
                    if (saveStatus) {
                        [[SuccessiveSyncManager sharedSuccessiveSyncManager] registerForSuccessiveSync:modifiedRecord withData:[self getDataDict:___lEvent forFields:lFieldsArray andSplitEventArray:nil]];
                        [[SyncManager sharedInstance] performDataSyncIfNetworkReachable];
                    }
                }
            }else{
                [modifiedRecordService updateModifiedRecord:modifiedRecord];
            }
        }
    }
}


+ (NSDictionary *)getDataDict:(SMXEvent *)event forFields:(NSArray *)lFieldsArray andSplitEventArray:(NSArray *)splitArray
{
    NSString *activityDate = [lFieldsArray objectAtIndex:0];
    NSString *activityDateTime = [lFieldsArray objectAtIndex:1];
    NSString *startDateTime = [lFieldsArray objectAtIndex:2];
    NSString *endDateTime = [lFieldsArray objectAtIndex:3];
    NSString *durationDateTime = [lFieldsArray objectAtIndex:4];
    NSString *allDayEvent = [lFieldsArray objectAtIndex:5];
    
    
    if (event != nil)
    {
        [self checkAndUpdateTaskModel:event];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setTimeZone:gmt];
        
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        [dict setObject:[DateUtil stringFromDate:event.ActivityDateDay inFormat:kDateFormatTypeOnlyDate] forKey:activityDate];
        
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        
        //Bug: #015130 BSP
        //Change the activitydatetime, starttime, endtime to "yyyy-MM-dd'T'HH:mm:ss.SSSSZZZZ" to be saved in the DB.
        NSString *activityDateTimeValue = [[dateFormatter stringFromDate:event.dateTimeBegin] stringByAppendingString:@".000+0000"];
        NSString *startDateTimeValue = [[dateFormatter stringFromDate:event.dateTimeBegin] stringByAppendingString:@".000+0000"];
        NSString *endDateTimeValue = [[dateFormatter stringFromDate:event.dateTimeEnd] stringByAppendingString:@".000+0000"];
        
        [dict setObject:activityDateTimeValue forKey:activityDateTime];
        [dict setObject:startDateTimeValue forKey:startDateTime];
        [dict setObject:endDateTimeValue forKey:endDateTime];
        
        int duration = [event.dateTimeEnd timeIntervalSinceDate:event.dateTimeBegin]/60;
        
        [dict setObject:[NSString stringWithFormat:@"%d", duration] forKey:durationDateTime];
        
        [dict setObject:event.localID forKey:kLocalId]; //Same for both SVMX & Salesforce Event table
        [dict setObject:event.IDString forKey:kId]; //Same for both SVMX & Salesforce Event table
        
        [dict setObject:[NSNumber numberWithBool:event.isMultidayEvent] forKey:kIsMultiDayEvent]; // if splitArray = nil, that means the method has been called from somewhere else which doesnt update the DB.
        
        [dict setObject:@"false" forKey:allDayEvent];
        
        
        if (splitArray) {
            [dict setObject:[self convertToJsonStringFromArray:splitArray] forKey:kSplitDayEvents];
        }
        
        return dict;
    }
    return nil;
}

+(NSString *)convertToJsonStringFromArray:(NSArray *)splitArray
{
    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:splitArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (void)checkAndUpdateTaskModel:(SMXEvent *)event
{
    
    event.ActivityDateDay = (event.ActivityDateDay) != nil? event.ActivityDateDay:[NSDate date];
    event.IDString = (event.IDString) != nil? event.IDString:@"";
    event.localID = (event.localID) != nil? event.localID:@"";
    
}

+(NSArray *)getEventFieldsForEvent:(SMXEvent *)event
{
    if ([event.eventTableName isEqualToString:kSVMXTableName]) {
        return @[kSVMXActivityDate,kSVMXActivityDateTime, kSVMXStartDateTime, kSVMXEndDateTime, kSVMXDurationInMinutes, kSVMXIsAlldayEvent, kIsMultiDayEvent, kSplitDayEvents, kLocalId];
        
    }
    else
    {
        return @[kActivityDate,kActivityDateTime, kStartDateTime, kEndDateTime, kDurationInMinutes, kIsAlldayEvent, kIsMultiDayEvent, kSplitDayEvents, kLocalId];
        
    }
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
        NSMutableDictionary *idValue = [NSMutableDictionary new];
        
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
+(NSArray *)fetchValueFromRefrenceTable:(NSArray *)array{
    NSMutableDictionary *dict=[self getValuesFromReferenceTable:array];
    return [self getList:dict productId:array];
}

+(NSArray *)getInstalledListFromSite:(NSString *)siteID
{
    // IPAD-4804
    NSString *locationIndexing = [NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS IBLocationIndex ON '%@' (%@ ASC)", kInstalledProductTableName, kWorkOrderSite];
    DatabaseIndexManager *indexManager = [DatabaseIndexManager sharedInstance];
    [indexManager databaseOperationForIndexArray:@[locationIndexing]];
    
    id <CalenderDAO> calService = [FactoryDAO serviceByServiceType:ServiceCalenderEventList];
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kWorkOrderSite operatorType:SQLOperatorEqual andFieldValue:siteID];
    
    /*getting product Id from Install Product Table */
    NSArray *fieldsArray = [[NSArray alloc] initWithObjects:kProductField, nil];
    NSArray *lDataArray = [calService fetchDataForIPObject:kInstalledProductTableName fields:fieldsArray expression:nil criteria:[NSArray arrayWithObject:criteria]];
    
    if ([lDataArray count]>0 && lDataArray!=nil) {
        NSArray *nameOfTheProducts=[self getProductFromProductTable:lDataArray];
        
        /*Copying value from product table, If product table is not there the copying from Install table*/
        if (nameOfTheProducts) {
            return nameOfTheProducts;
        }
        
        /*copying value from refrence table*/
        return [self fetchValueFromRefrenceTable:lDataArray];
    }else{
        return nil;
    }
    
}


/* Here we are getting value from product table*/
+(NSArray *)getProductFromProductTable:(NSArray *)ids{
    DBCriteria *criteriaOne = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIn andFieldValues:ids];
    NSArray *fieldsArray = [[NSArray alloc] initWithObjects:KProductName,kId,nil];
    NSArray *workOrderArray = [self fetchDataFromWorkOrderObject:KProductTable fields:fieldsArray expression:nil criteria:[NSArray arrayWithObject:criteriaOne]];
    if ([workOrderArray count]>0) {
        NSMutableDictionary *dictI=[[NSMutableDictionary alloc] init];
        for (TransactionObjectModel *model in workOrderArray) {
            NSDictionary *dict=[model getFieldValueDictionary];
            [dictI setObject:[dict objectForKey:@"Name"] forKey:[dict objectForKey:kId]];
        }
        
        if (dictI.count != ids.count) {
            return nil;
        }
        return [self getList:dictI productId:ids];
    }else{
        return nil;
    }
}


+(NSArray *)getList:(NSMutableDictionary *)productIdToNameDictionary productId:(NSArray *)productIds{
    
    // productModels
    NSMutableDictionary *IdModel = [[NSMutableDictionary alloc] init];
    
    // Find the counts of Products
    for (NSString *productId in productIds)
    {
        //SMXProductDisplayModel
        SMXProductListModel *model = [IdModel objectForKey:productId];
        
        if (model)
        {
            model.count = model.count+1;
        }
        else
        {
            model = [[SMXProductListModel alloc] init];
            model.count = 1;
            model.productId = productId;
            // Product Name
            model.displayValue = [productIdToNameDictionary objectForKey:productId];
            [IdModel setObject:model forKey:productId];
        }
    }
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"displayValue" ascending:YES];
    return [[IdModel allValues] sortedArrayUsingDescriptors:@[sd]];
}

/* just truncate with the ellipsis */
+(NSString *)trimStringWithGivenLength:(NSString *)string{
    if (string.length>stringLimitInProduct) {
        string = [NSString stringWithFormat:@"%@... ",[string substringToIndex:stringLimitInProduct]];
        return string;
    }
    return string;
}

- (NSMutableArray *)getDetailsDataForQuery:(DBRequestSelect *)selectQuery
{
    NSMutableArray * detailsArray = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [selectQuery query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                NSDictionary * dict = [resultSet resultDictionary];
                //Method in model to set the values
                
                if ([[dict valueForKey:kProductField] length]) {
                    [detailsArray addObject:[dict valueForKey:kProductField]];
                }
            }
            [resultSet close];
        }];
    }
    return detailsArray;
}
+(NSString *)getServiceLocation:(NSString *)whatID
{
    
    ServiceLocationModel *model = [self getServiceLocationModel:whatID];
    NSString *cityAndState = nil;
    
    if (![StringUtil isStringEmpty:model.city]) {
        cityAndState = [NSString stringWithFormat:@"%@", model.city];
    }
    
    if (![StringUtil isStringEmpty:model.state]) {
        if (![StringUtil isStringEmpty:cityAndState]) {
            cityAndState = [NSString stringWithFormat:@"%@, %@", cityAndState, model.state];
            
        }
        else
        {
            cityAndState = [NSString stringWithFormat:@"%@", model.state];
            
        }
    }
    
    return cityAndState;
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

+(NSDate *)getStartEndDateTime:(NSString *)lTempDateTime
{
    lTempDateTime = [lTempDateTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    lTempDateTime = [lTempDateTime stringByReplacingOccurrencesOfString:@".000Z" withString:@""];
    lTempDateTime = [CalenderHelper localTimeFromGMT:lTempDateTime];
    lTempDateTime = [lTempDateTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    lTempDateTime = [lTempDateTime stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    
    NSDateFormatter * lDF = [[NSDateFormatter alloc] init];
    
    [lDF setTimeZone:[NSTimeZone systemTimeZone]];
    [lDF setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    
    [lDF setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    lDF.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    return [lDF dateFromString:lTempDateTime];
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
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setCalendar:cal];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString * tmpDate = [gmtDate substringToIndex:[gmtDate length]-0];
    
    tmpDate = [tmpDate stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    tmpDate = [tmpDate stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    tmpDate = [tmpDate stringByDeletingPathExtension];
    
    NSDate * originalDate = [dateFormatter dateFromString:tmpDate];
    [cal setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSDateComponents *date_comp = [cal components: NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:originalDate];
    
    NSString *someDateString = [self getLocalizedString:date_comp];
    
    someDateString = [someDateString stringByReplacingOccurrencesOfString:@" " withString:@"T"];
    someDateString = [NSString stringWithFormat:@"%@Z", someDateString];
    
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
    secondsStr = @"00";
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

+ (TransactionObjectModel *)getRecordForEvent:(SMXEvent *)event{
    
    NSString *objectName;
    NSString *fieldName = kId;
    
    NSString *whatId = event.whatId;
    
    if ([whatId length] < 1) {
        whatId = event.localID;
        objectName = event.eventTableName; // no SFID associated with this event. Either a local event or not not synced yet.
        fieldName = kLocalId;
    }
    
    else if (whatId.length > 20) {
        whatId = event.localID;
        objectName = event.eventTableName; // no SFID associated with this event. Either a local event or not not synced yet.
        fieldName = kLocalId;
    }
    else if (whatId.length >= 15) {
        objectName = [self getTheObjectName:whatId]; // It is a salesForceID.
    }
    else
    {
        //based on settings set event object name
        objectName = event.eventTableName; // no SFID associated with this event. Either a local event or not not synced yet.
        fieldName = kLocalId;
    }
    
    if (objectName != nil) {
        id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
        
        DBCriteria * innerCriteria = [[DBCriteria alloc] initWithFieldName:fieldName operatorType:SQLOperatorEqual andFieldValue:whatId];
        
        NSArray *objects =   [transObjectService fetchDataForObject:objectName fields:nil expression:nil criteria:@[innerCriteria]];
        if ([objects count] > 0) {
            TransactionObjectModel *record =  [objects objectAtIndex:0];
            [record setObjectName:objectName];
            return record;
        }
    }
    
    return nil;
}


+(NSString *)getTheObjectName:(NSString *)lSFID
{
    NSString *keyPrefix = [lSFID substringToIndex:3];
    
    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:@"keyPrefix" operatorType:SQLOperatorEqual andFieldValue:keyPrefix];
    
    id <SFObjectDAO> objectService = [FactoryDAO serviceByServiceType:ServiceTypeSFObject];
    
    SFObjectModel *model = [objectService getSFObjectInfo:criteria fieldName:@[@"objectName"]];
    
    return model.objectName;
}

+(NSString *)getStringValueForTheDate:(NSDate *)lDate
{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *comp = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitWeekday fromDate:lDate];
    
    NSString *monthString = [arrayMonthNameAbrev objectAtIndex:comp.month-1];
    NSString *dayString = [arrayWeekAbrevWithThreeChars objectAtIndex: comp.weekday -1];
    NSString *minuteString = [NSString stringWithFormat:@"%ld", (long)comp.minute];
    NSString *lAmPm = [[TagManager sharedInstance]tagByName:kTag_AM];
    if (comp.hour>11) {
        lAmPm = [[TagManager sharedInstance]tagByName:kTag_PM];
    }
    
    NSString *combinedString = [NSString stringWithFormat:@"%@ %@ %ld, %ld %d:%@ %@", dayString, monthString, (long)comp.day, (long)comp.year, (int)(comp.hour>12 ? comp.hour-12:(comp.hour == 0? 12:comp.hour)), (minuteString.length ==1? [@"0" stringByAppendingString:minuteString]:minuteString), lAmPm];
    return combinedString;
}

- (NSDate *)dateWithOutTime:(NSDate *)datDate{
    
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    if( datDate == nil ) {
        datDate = [NSDate date];
    }
    NSDateComponents* comps = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:datDate];
    [comps setHour:00];
    [comps setMinute:00];
    [comps setSecond:00];
    return [cal dateFromComponents:comps];
}


+(NSString *)getTagValueForMonth:(long)month
{
    NSArray *array = @[kTagJanuary,
                       kTagFebruary,
                       kTagMarch,
                       kTagApril,
                       kTagMay,
                       kTagJune,
                       kTagJuly,
                       kTagAugust,
                       kTagSeptember,
                       kTagOctober,
                       kTagNovember,
                       kTagDecember];
    
    return     [[TagManager sharedInstance]tagByName:[array objectAtIndex:month]];
    
}

#pragma mark - get mobile device settings value

+ (NSString*)getEventTypeFromMobileDeviceSettings
{
    MobileDeviceSettingService *mobileDeviceSettingService = [[MobileDeviceSettingService alloc]init];
    MobileDeviceSettingsModel *mobDeviceSettings = [mobileDeviceSettingService fetchDataForSettingId:@"GLOB001_GBL025"];
    return  mobDeviceSettings.value;
}

+ (NSString *)getTheHexaCodeForTheSettingId:(NSString *)settingId
{
    MobileDeviceSettingService *mobileDeviceSettingService = [[MobileDeviceSettingService alloc]init];
    MobileDeviceSettingsModel *mobDeviceSettings = [mobileDeviceSettingService fetchDataForSettingId:settingId];
    return  mobDeviceSettings.value;
    
}

+ (void)updateOriginalSfIdForSVMXEvent
{
    [self alterSVMXEventTable];
    
    NSArray *whatIds = [self getAllWhatIdsFormSVMXEvent];
    
    if ([whatIds count]) {
        
        NSDictionary *mappingDict = [self getObjectMappingForIds:whatIds];
        
        [self updateSVMXEventRecords:mappingDict];
    }
}

+ (void)alterSVMXEventTable
{
    id<UniversalDAO> universalDao =  [FactoryDAO serviceByServiceType:ServiceTypeUniversal];
    BOOL columnExist = [universalDao isColumn:@"objectSfId" existInTable:kServicemaxEventObject];
    
    if(!columnExist)
    {
        NSString *schema =[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN 'objectSfId' VARCHAR",kServicemaxEventObject];
        [universalDao alterTable:schema];
    }
}

+ (NSArray *)getAllWhatIdsFormSVMXEvent
{
    NSMutableArray *ids = [NSMutableArray new];
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kSVMXWhatId operatorType:SQLOperatorIsNotNull andFieldValue:nil];
    
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:kObjectSfId operatorType:SQLOperatorIsNull andFieldValue:nil];
    
    id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    NSArray * eventArray = [transObjectService fetchEventDataForObject:kSVMXTableName fields:@[kSVMXWhatId] expression:@"1 and 2" criteria:@[criteria, criteria1]];
    
    for (EventTransactionObjectModel *model in eventArray) {
        
        NSString *whatId = [model getWhatId];
        
        if (whatId && (![ids containsObject:whatId])) {
            [ids addObject:whatId];
        }
        
    }
    return ids;
}


+ (NSDictionary *)getObjectMappingForIds:(NSArray *)Ids
{
    NSMutableDictionary *mappingDict = [NSMutableDictionary new];
    for (NSString *whatId in Ids) {
        
        NSString *objectName = [self getTheObjectName:whatId];
        
        NSString *sfId = nil;
        
        if ([whatId length] == 18) {
            sfId = whatId;
        }
        else {
            sfId = [self getSfIdForWhatId:whatId objectName:objectName];
        }
        if ([sfId length]) {
            [mappingDict setObject:sfId forKey:whatId];
        }
    }
    return mappingDict;
}

+ (void)updateSVMXEventRecords:(NSDictionary *)mappingDict
{
    NSArray *allKeys = [mappingDict allKeys];
    
    @autoreleasepool {
        for(NSString *whatId in allKeys) {
            
            NSString *sfid = [mappingDict objectForKey:whatId];
            
            [self updateEachRecordWitSfId:sfid withWhatId:whatId];
        }
    }
}

+ (NSString *)getSfIdForWhatId:(NSString *)whatId objectName:(NSString *)objectName
{
    if (objectName && whatId) {
        DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorStartsWith  andFieldValue:whatId];
        
        id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
        
        TransactionObjectModel *model = [transObjectService getDataForObject:objectName fields:@[kId] expression:nil criteria:@[criteria]];
        
        return [model valueForField:kId];
        
    }
    return nil;
    
}

+ (void)updateEachRecordWitSfId:(NSString *)sfId withWhatId:(NSString *)whatId
{
    if (sfId && whatId) {
        DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kSVMXWhatId operatorType:SQLOperatorEqual andFieldValue:whatId];
        
        id <CalenderDAO> CalEventService = [FactoryDAO serviceByServiceType:ServiceCalenderEventList];
        
        [CalEventService updateEachRecord:@{kObjectSfId: sfId} withFields:@[kObjectSfId] withCriteria:@[criteria] withTableName:kSVMXTableName];
    }
    
}

#pragma mark - Custom Calendar Event Title Population

/*
 This method retreives the Event Title field names and values from and returns the same.
 */
-(NSDictionary *)getCalendarEventTitleData
{
    //Get the setting value from Mobile Device Setting Table
    NSArray *calendarTitleFieldList = [self getCalendarTitleInfoFromMobleDeviceSetting];
    NSArray *lEventFields;
    NSArray *lSVMXEventFields;
    for (MobileDeviceSettingsModel *model in calendarTitleFieldList) {
        
        if ([model.settingId isEqualToString:EventTableSetting]) {
            _salesforceEventTitleSettingString = model.value;
            lEventFields = [self getFieldsFromString:model.value];

        }
        else if ([model.settingId isEqualToString:SVMXEventTableSetting]) {
            _svmxEventTitleSettingString = model.value;
            lSVMXEventFields = [self getFieldsFromString:model.value];
        }
    }
    NSMutableArray *lEventFieldArray = [NSMutableArray new];
    
    for (int i = 0;i<lEventFields.count;i++) {
        
        NSString *trimmedString = [[lEventFields objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [lEventFieldArray addObject:trimmedString];
        
    }
    NSMutableArray *lSVMXEventFieldArray = [NSMutableArray new];
    
    for (int i = 0;i<lSVMXEventFields.count;i++) {
        
        NSString *trimmedString = [[lSVMXEventFields objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [lSVMXEventFieldArray addObject:trimmedString];
        
    }
    
    id sfObjectService = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    
    NSDictionary *lEventdict;
    NSDictionary *lSVMXEventdict;
    
    if ([sfObjectService conformsToProtocol:@protocol(SFObjectFieldDAO)]) {
        
        if (lEventFieldArray.count) {
            lEventdict = [sfObjectService getDataTypeForFields:lEventFieldArray objectName:@"Event"];
        }
        if (lSVMXEventFieldArray.count) {
            lSVMXEventdict = [sfObjectService getDataTypeForFields:lSVMXEventFieldArray objectName:kSVMXTableName];
            
        }
    }
    NSDictionary *eventDict;
    NSDictionary *svmxEventDict;
    if(lEventdict && lEventFieldArray){
        eventDict = @{kEventObject:lEventdict, EventTableSetting:lEventFieldArray};
    }
    if(lSVMXEventdict && lSVMXEventFieldArray){
        svmxEventDict = @{kSVMXTableName:lSVMXEventdict, SVMXEventTableSetting:lSVMXEventFieldArray};
    }
    
    if (eventDict && svmxEventDict) {
        return @{kEventObject:eventDict, kSVMXTableName:svmxEventDict};
        
    }
    else if(eventDict){
        return @{kEventObject:eventDict};
        
    }
    else if(svmxEventDict){
        return @{kSVMXTableName: svmxEventDict};
        
    }
    else
        return nil;
    
}

-(NSArray *)getFieldsFromString:(NSString *)sentence
{
    NSRange startRange = [sentence rangeOfString:@"{"];
    NSRange endRange = [sentence rangeOfString:@"}"];
    NSMutableArray *fields = [NSMutableArray new];
    while (endRange.location<sentence.length && startRange.location<endRange.location){
        long startLocation = startRange.location + startRange.length;
        long length = endRange.location - startLocation;
        
        NSString *field = [sentence substringWithRange:NSMakeRange(startLocation, length)];
        [fields addObject:field];
        sentence = [sentence substringFromIndex:endRange.location+1];
        startRange = [sentence rangeOfString:@"{"];
        endRange = [sentence rangeOfString:@"}"];
        
    }

    
    return fields;
}

/*
 This methods retrieves the Settings data from DB for Event Title Data.
 
 */

-(NSArray *)getCalendarTitleInfoFromMobleDeviceSetting
{
    id <MobileDeviceSettingDAO> mobileSettingService = [FactoryDAO serviceByServiceType:ServiceTypeMobileDeviceSettings];
    
    NSArray *calendarSettingData = [mobileSettingService fetchDataForSettingIds:@[EventTableSetting, SVMXEventTableSetting]];
    
    return calendarSettingData;
}


/*
 This method sets the title to be displayed for each event and saves it to the dictionary.
 */

-(void)settingTheTitleOfEvent:(NSMutableDictionary *)theRecordDict forSalesforceEvent:(BOOL)isSalesforceEvent
{
    
    NSArray *fieldsArray;
    NSDictionary *fieldTypeDict;
    NSString *settingString;
    if (isSalesforceEvent) {
        fieldsArray = [self.salesforceEventFieldList objectForKey:EventTableSetting];
        fieldTypeDict = [self.salesforceEventFieldList objectForKey:kEventObject];
        settingString = self.salesforceEventTitleSettingString;
    }
    else
    {
        fieldsArray = [self.svmxEventEventFieldList objectForKey:SVMXEventTableSetting];
        fieldTypeDict = [self.svmxEventEventFieldList objectForKey:kSVMXTableName];
        settingString = self.svmxEventTitleSettingString;
    }
    
    NSMutableDictionary *referenceKeyValueDict = [NSMutableDictionary new];
    NSArray *referenceFieldType = [fieldTypeDict allKeysForObject:kSfDTReference];
    
    if (referenceFieldType.count) {
        for (NSString *fieldName in referenceFieldType) {
            NSString *referenceID = [theRecordDict objectForKey:fieldName];
            TransactionObjectModel *model = [CalenderHelper getRecordForSalesforceId:referenceID];
            id sfObjectService = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
            
            if ([sfObjectService conformsToProtocol:@protocol(SFObjectFieldDAO)]) {
                NSString *nameField = [sfObjectService getNameFieldForObjectName:model.objectAPIName];
                if(nameField){
                    
                    NSString *value = [[model getFieldValueDictionaryForFields:@[nameField]] objectForKey:nameField];
                    [referenceKeyValueDict setObject:value forKey:fieldName];
                }
            }
            
        }
    }
    NSString *theTitle = settingString;
    for (NSString *thefield in fieldsArray) {
        
        if ([referenceFieldType containsObject:thefield] && [[referenceKeyValueDict allKeys] containsObject:thefield]) {

            theTitle = [theTitle stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}",thefield] withString:[referenceKeyValueDict objectForKey:thefield]];

        }
        else
        {
            NSString *trimmedString = [thefield stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([[theRecordDict allKeys] containsObject:trimmedString] || [[fieldTypeDict allKeys] containsObject:trimmedString]) {
                
                NSString *dateString=nil;
                if ([[fieldTypeDict objectForKey:trimmedString] isEqualToString:kSfDTDateTime]) {
                    NSDate *theDateTime = [CalenderHelper getStartEndDateTime:[theRecordDict objectForKey:trimmedString]];
                    dateString =  [NSDate localDateTimeStringFromDate:theDateTime];

                }
                else if ([[fieldTypeDict objectForKey:trimmedString] isEqualToString:kSfDTDate]){
                    NSDate *theDateTime = [CalenderHelper getStartEndDateTime:[theRecordDict objectForKey:trimmedString]];
                    dateString =  [NSDate localDateStringFromDate:theDateTime];
                }
                if (!dateString) {
                    dateString = [[theRecordDict objectForKey:trimmedString] description];
                }

                theTitle = [theTitle stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}",thefield] withString:(dateString?dateString:@"")];
                
            }
            else{
                // not field.
            }
        }
    }
    theTitle = [theTitle stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
//    theTitle = [theTitle stringByReplacingOccurrencesOfString:@"\\r" withString:@"\r"];
    theTitle = [theTitle stringByReplacingOccurrencesOfString:@"\\t" withString:@"\t"];


    if (theTitle) {
        NSString *trimmedString = [theTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        [theRecordDict setObject:(trimmedString?trimmedString:@"") forKey:@"eventTitle"];
        [theRecordDict setObject:@"YES" forKey:@"isSetting"];

    }
    else{
        [theRecordDict setObject:@"NO" forKey:@"isSetting"];
        [theRecordDict setObject:@"" forKey:@"eventTitle"];
    }
}

-(void)setRescheduledEventTitle:(SMXEvent *)event{
    
    NSDictionary *lTitleFieldDict =  [self getCalendarEventTitleData];
    
    NSArray *fieldsArray;
    NSDictionary *fieldTypeDict;
    NSString *settingString;

    if ([event.eventTableName isEqualToString:kEventObject]) {
        fieldsArray = [[lTitleFieldDict objectForKey:kEventObject] objectForKey:EventTableSetting];
        fieldTypeDict = [[lTitleFieldDict objectForKey:kEventObject] objectForKey:kEventObject];
        settingString = self.salesforceEventTitleSettingString;
    }
    else
    {
        fieldsArray = [[lTitleFieldDict objectForKey:kSVMXTableName] objectForKey:SVMXEventTableSetting];
        fieldTypeDict = [[lTitleFieldDict objectForKey:kSVMXTableName] objectForKey:kSVMXTableName];
        settingString = self.svmxEventTitleSettingString;
    }
    
    if (!event.isEventTitleSettingDriven) {
        //not settings driven.
        return;
    }
    
    id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:klocalId operatorType:SQLOperatorEqual andFieldValue:event.localID];
    
    NSArray *eventArray = [transObjectService fetchEventDataForObject:event.eventTableName fields:nil expression:nil criteria:@[criteria]];
    EventTransactionObjectModel *lModel = [eventArray objectAtIndex:0];
    NSDictionary *theRecordDict = [lModel getFieldValueDictionary];

    NSMutableDictionary *referenceKeyValueDict = [NSMutableDictionary new];
    NSArray *referenceFieldType = [fieldTypeDict allKeysForObject:kSfDTReference];
    
    if (referenceFieldType.count ) {
        for (NSString *fieldName in referenceFieldType) {
            NSString *referenceID = [theRecordDict objectForKey:fieldName];
            TransactionObjectModel *model = [CalenderHelper getRecordForSalesforceId:referenceID];
            id sfObjectService = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
            
            if ([sfObjectService conformsToProtocol:@protocol(SFObjectFieldDAO)]) {
                NSString *nameField = [sfObjectService getNameFieldForObjectName:model.objectAPIName];
                if(nameField){
                    
                    NSString *value = [[model getFieldValueDictionaryForFields:@[nameField]] objectForKey:nameField];
                    [referenceKeyValueDict setObject:value forKey:fieldName];
                }
            }
            
        }
    }
    NSString *theTitle = settingString;
    for (NSString *thefield in fieldsArray) {
        
        if ([referenceFieldType containsObject:thefield] && [[referenceKeyValueDict allKeys] containsObject:thefield]) {
            theTitle = [theTitle stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}",thefield] withString:[referenceKeyValueDict objectForKey:thefield]];
        }
        else
        {
            NSString *trimmedString = [thefield stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([[theRecordDict allKeys] containsObject:trimmedString] || [[fieldTypeDict allKeys] containsObject:trimmedString]) {
                
                
                NSString *dateString=nil;
                if ([[fieldTypeDict objectForKey:trimmedString] isEqualToString:kSfDTDateTime]) {
                    
                    NSDate *referenceDate = nil;
                    
                    if ([trimmedString isEqualToString:kStartDateTime] || [trimmedString isEqualToString:kEndDateTime] || [trimmedString isEqualToString:kActivityDateTime] || [trimmedString isEqualToString:kSVMXStartDateTime] || [trimmedString isEqualToString:kSVMXEndDateTime] || [trimmedString isEqualToString:kSVMXActivityDateTime]) {
                        if ([trimmedString isEqualToString:kStartDateTime] || [trimmedString isEqualToString:kActivityDateTime] || [trimmedString isEqualToString:kSVMXStartDateTime] || [trimmedString isEqualToString:kSVMXActivityDateTime]) {
                            referenceDate = event.dateTimeBegin;
                        }
                        else{
                            referenceDate = event.dateTimeEnd;
                        }
                    }
                    else{
                        referenceDate = [CalenderHelper getStartEndDateTime:[theRecordDict objectForKey:trimmedString]];
                    }
                    
                    //                    NSDate *theDateTime = [CalenderHelper getStartEndDateTime:[theRecordDict objectForKey:trimmedString]];
                    dateString =  [NSDate localDateTimeStringFromDate:referenceDate];
                    
                }
                else if ([[fieldTypeDict objectForKey:trimmedString] isEqualToString:kSfDTDate]){
                    if ([trimmedString isEqualToString:kSVMXActivityDate]||[trimmedString isEqualToString:kActivityDate]) {
                        
                        NSDateComponents *comp = [NSDate componentsOfDate:event.dateTimeBegin];
                        NSDate *newDate = [NSDate dateWithYear:comp.year month:comp.month day:comp.day];
                        
                        dateString =  [NSDate localDateStringFromDate:newDate];
                    }
                    else{
                        NSDate *theDateTime = [CalenderHelper getStartEndDateTime:[theRecordDict objectForKey:trimmedString]];
                        NSDateComponents *comp = [NSDate componentsOfDate:theDateTime];
                        NSDate *newDate = [NSDate dateWithYear:comp.year month:comp.month day:comp.day];
                        dateString =  [NSDate localDateStringFromDate:newDate];

                    }
                    
                    
                }
                if (!dateString) {
                    dateString = [[theRecordDict objectForKey:trimmedString] description];
                }
                theTitle = [theTitle stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}",thefield] withString:(dateString?dateString:@"")];

            }
            else{
            // Not fields.
            }
        }
    }
    
    theTitle = [theTitle stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
//    theTitle = [theTitle stringByReplacingOccurrencesOfString:@"\\r" withString:@"\r"];
    theTitle = [theTitle stringByReplacingOccurrencesOfString:@"\\t" withString:@"\t"];

    event.title = (theTitle?theTitle:@"");
    
}
#pragma - Custom Calendar Field End



#pragma mark - end

@end
