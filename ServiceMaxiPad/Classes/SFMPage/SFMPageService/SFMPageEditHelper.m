//
//  SFMPageEditHelper.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 08/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SFMPageEditHelper.h"
#import "SFPicklistModel.h"
#import "StringUtil.h"
#import "BitSet.h"
#import "SFPicklistModel.h"
#import "FactoryDAO.h"
#import "SFPicklistDAO.h"
#import "SFRTPicklistDAO.h"
#import "SFRecordTypeDAO.h"
#import "SFPicklistDAO.h"
#import "DBCriteria.h"
#import "TransactionObjectModel.h"
#import "TransactionObjectDAO.h"
#import "SFMRecordFieldData.h"
#import "DBRequestInsert.h"
#import "TXFetchHelper.h"
#import "SFProcessDAO.h"
#import "SFObjectMappingComponentDAO.h"
#import "SFObjectFieldDAO.h"
#import "SFRecordTypeModel.h"
#import "LinkedSfmProcessDAO.h"
#import "MobileDeviceSettingDAO.h"
#import "EventTransactionObjectModel.h"

@implementation SFMPageEditHelper

+ (NSString *)getObjectNameForProcessId:(NSString *)processId
{
    NSString *objectName = nil;
    
    id sfProcessService  = [FactoryDAO serviceByServiceType:ServiceTypeProcess];
    
    if ([sfProcessService conformsToProtocol:@protocol(SFProcessDAO)]) {
        
       SFProcessModel *model = [sfProcessService fetchSFProcessBySalesForceId:processId
                                            andFields:[NSArray arrayWithObject:kobjectApiName]];
        if (model != nil) {
            objectName = model.objectApiName;
        }
    }
    return objectName;
}

+ (NSArray *)getFieldMappingDataForMappingId:(NSString *)objectMappingId
{
    id mappingService = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectMappingComponent];
    
    if ([mappingService conformsToProtocol:@protocol(SFObjectMappingComponentDAO) ]) {
        
        return [mappingService getObjectMappingDictForMappingId:objectMappingId];
    }
    return nil;    
}

+ (NSDictionary *)getRecordTypeDataByName:(NSString *)objectname
{
    NSMutableDictionary *resultDict = [NSMutableDictionary new];
    
    NSArray *result = [self getRecordTypeValuesForObject:objectname];
    
    for (SFRecordTypeModel *model in result) {
        
        if (model != nil && model.recordType != nil) {
            [resultDict setObject:model forKey:model.recordType];
        }
    }
    return resultDict;
}


+ (NSDictionary *)getObjectFieldInfoByType:(NSString *)objectName
{
    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:objectName];
    
    id <SFObjectFieldDAO> sfObjectField = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    NSArray * resultSet = [sfObjectField fetchSFObjectFieldsInfoByFields:nil andCriteria:criteria];
    
    NSMutableDictionary * fieldTypeDict = [NSMutableDictionary new];
    
    if ([resultSet count] > 0) {
        for (SFObjectFieldModel * model in resultSet) {
            if (model != nil) {
                [fieldTypeDict setObject:model.type forKey:model.fieldName];
            }
        }
    }
    return fieldTypeDict;
}

+ (NSArray *)getPickListInfoForObject:(NSString *)objectName field:(NSString *)fieldName;
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray *resultSet = [self getPicklistValuesForObject:objectName
                                           pickListFields:[NSArray arrayWithObject:fieldName]];
    
    if([resultSet count] > 0) {
        
        for (SFPicklistModel *model in resultSet) {
            [dataArray addObject:model.value];
        }
    }
    return dataArray;
}

+ (NSMutableArray *)getPicklistValuesForField:(NSString *)fieldApiName  objectName:(NSString *)objectName
{
   // NSMutableArray * picklistArray = [[NSMutableArray alloc] init];
    
    id <SFPicklistDAO> picklistService = [FactoryDAO serviceByServiceType:ServiceTypeSFPickList];
    
    DBCriteria * criteriaObjectName1 = [[DBCriteria alloc] initWithFieldName:kfieldname operatorType:SQLOperatorEqual andFieldValue:fieldApiName];
    DBCriteria * criteriaObjectName2 = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:objectName];
    
    NSArray * criteriaObjects = [[NSArray alloc] initWithObjects:criteriaObjectName1, criteriaObjectName2, nil];
    
    DBField *orderByfield = [[DBField alloc] initWithFieldName:kindexValue andTableName:kSFPicklist];
    
    NSMutableArray *  picklistArray = (NSMutableArray *)[picklistService fetchSFPicklistInfoByFields:[NSArray arrayWithObjects:kfieldname, klabel, kvalue, kindexValue, kvalidFor, nil]
                                                                       andCriteria:criteriaObjects
                                                                     andExpression:@"(1 AND 2)"
                                                                           OrderBy:[NSArray arrayWithObject:orderByfield]];
    
    return picklistArray;
}

//For Fetching Record Type Values in Picklist
+ (NSMutableArray *)getRecordTypeValuesForObjectName:(NSString *)objectName
{
    NSMutableArray * recordTypeArray = nil;
    
    id <SFRecordTypeDAO> picklistService = [FactoryDAO serviceByServiceType:ServiceTypeSFRecordType];
    
    DBCriteria * criteriaObjectName1 = [[DBCriteria alloc] initWithFieldName:kobjectApiName operatorType:SQLOperatorEqual andFieldValue:objectName];
    
    recordTypeArray = (NSMutableArray *)[picklistService fetchSFRecordTypeByFields:[NSArray arrayWithObjects:kRecordtypeLabel,kRecordTypeId,nil] andCriteria:criteriaObjectName1];
    
    return recordTypeArray;
    
}

//get the dependent picklist based on the controller name and complete set of list from where to get the dependent list
+ (NSArray *)getDependentPicklistValuesForPageField:(SFMPageField *)controllerPageField recordFieldVal:(NSString *)recordFieldValue objectName:(NSString *)objectName fromPicklist:(NSArray *)picklist
{
    int index = 0;
    
    //Here we can check if recordField.value = @"", then load complet set
    if ([StringUtil isStringEmpty:recordFieldValue])
    {
        //Returning complet set of DependentPicklist if there is nothing selected in Controlling Field
        return picklist;
    }
    
    if ([controllerPageField.dataType isEqualToString:kSfDTPicklist])
    {
        //NSString * picklistValue_Handled = [recordFieldValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        
        id <SFPicklistDAO> picklistService = [FactoryDAO serviceByServiceType:ServiceTypeSFPickList];
        
        DBCriteria * criteriaObjectName1 = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:objectName];
        DBCriteria * criteriaObjectName2 = [[DBCriteria alloc] initWithFieldName:kfieldname operatorType:SQLOperatorEqual andFieldValue:controllerPageField.fieldName];
        
        DBCriteria * criteriaObjectName3 = [[DBCriteria alloc] initWithFieldName:kvalue operatorType:SQLOperatorEqual andFieldValue:recordFieldValue];
        
        NSArray * criteriaObjects = [[NSArray alloc] initWithObjects:criteriaObjectName1, criteriaObjectName2,
                                     criteriaObjectName3, nil];
        
        NSArray * resultSet = [picklistService fetchDistinctSFPicklistByFields:[NSArray arrayWithObject:kindexValue] andCriteria:criteriaObjects andExpression:@"(1 AND 2 AND 3)"];
        
        if ([resultSet count] > 0){
            
            SFPicklistModel *picklistModel =  [resultSet objectAtIndex:0];
            index = (int)picklistModel.indexValue;
        }
    }
    else
    {
        //It will be for CheckBox dependency
        //consider the record field.value as it is , if it is true make it 0 , else make it 1 and pass to index.
        index =([StringUtil isItTrue:recordFieldValue])?1:0;
        
    }
    NSArray *dependentPicklistValues = [self getDependentPicklistValuesForIndex:index fromPicklist:picklist];
    return dependentPicklistValues;
}

//Bit Set Algorithm to find correct set of dependent picklist out of Complete set of picklist values
+ (NSArray *)getDependentPicklistValuesForIndex:(int)index fromPicklist:(NSArray *)picklist
{
    NSMutableArray *dependentPicklistValues = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
        
        for(int j = 0 ; j< [picklist count];j++)
        {
            SFPicklistModel * eachPickerObj = [picklist objectAtIndex:j];
            
            NSString * obj = eachPickerObj.validFor;
            obj = [obj stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            if(obj == nil || [obj isEqualToString:@""])
            {
                // SMLog(kLogLevelVerbose,@" object  %@" , obj);
                continue;
                //HS 9June commented as _valid_for flag was coming nil in case of RecordType Picklist ,as we donthave that flag in SFRecordType Table
            }
            
            BitSet *bitObj = [[BitSet alloc] initWithString:obj];
            
            for(int k=0; k< [bitObj size]; k++)
            {
                if(k < index)
                    continue;
                if(( k == index) && ([bitObj testBit:index]))
                {
                    [dependentPicklistValues addObject:eachPickerObj];
                    break;
                }
            }
        }
    }
    
    return dependentPicklistValues;
}


//For Record Type Dependency
+ (NSArray*)getCommonDependentValuesFromRecordTypeValue:(NSArray*)recordTypeDepValues andDependentValues:(NSArray *)dependentPicklistValues
{
    
    NSMutableArray *finalArray = [[NSMutableArray alloc]init];
    
    for (SFPicklistModel* depobj in dependentPicklistValues)
    {
        for (SFPicklistModel* recordObj in recordTypeDepValues)
        {
            if ([depobj.value isEqualToString:recordObj.value] && ![finalArray containsObject:depobj])
            {
                [finalArray addObject:depobj];
            }
        }
    }
    
    return finalArray;
}


+ (BOOL)isRecordTypeDependent:(NSString *)fieldName
          RecordTypeFieldData:(NSString *)recordTypeValue
                andObjectName:(NSString *)objectName
{
    
    id <SFRTPicklistDAO> picklistService = [FactoryDAO serviceByServiceType:ServiceTypeSFRTPicklist];
    
    DBCriteria * criteriaObjectName1 = [[DBCriteria alloc] initWithFieldName:kobjectApiName operatorType:SQLOperatorEqual andFieldValue:objectName];
    DBCriteria * criteriaObjectName2 = [[DBCriteria alloc] initWithFieldName:kRecordTypeId operatorType:SQLOperatorEqual andFieldValue:recordTypeValue];
    
    DBCriteria * criteriaObjectName3 = [[DBCriteria alloc] initWithFieldName:kFieldAPIName operatorType:SQLOperatorEqual andFieldValue:fieldName];
    
    NSArray * criteriaObjects = [[NSArray alloc] initWithObjects:criteriaObjectName1,
                                 criteriaObjectName2,criteriaObjectName3, nil];
    
    NSInteger count = [picklistService getNumberOfRecordsFromObject:@"SFRTPicklist" withDbCriteria:criteriaObjects andAdvancedExpression:@"(1 AND 2 AND 3)"];
    
    criteriaObjects = nil;
    criteriaObjectName3 = nil;
    criteriaObjectName2 = nil;
    criteriaObjectName1 = nil;
    
    if(count > 0)
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

+ (NSArray *)getRecordTypePicklistData:(NSString *)objectName fieldName:(NSString *)fieldName
                         pageDataValue:(NSString *)internalValue
{
    NSArray *recordTypeDepList = nil;
    
    id <SFRTPicklistDAO> rtPicklistService = [FactoryDAO serviceByServiceType:ServiceTypeSFRTPicklist];
    
    DBCriteria * criteriaObjectName1 = [[DBCriteria alloc] initWithFieldName:kobjectApiName operatorType:SQLOperatorEqual andFieldValue:objectName];
    DBCriteria * criteriaObjectName2 = [[DBCriteria alloc] initWithFieldName:kRecordTypeId operatorType:SQLOperatorEqual andFieldValue:internalValue];
    
    DBCriteria * criteriaObjectName3 = [[DBCriteria alloc] initWithFieldName:kFieldAPIName operatorType:SQLOperatorEqual andFieldValue:fieldName];
    
    NSArray * criteriaObjects = [NSArray arrayWithObjects:criteriaObjectName1,
                                 criteriaObjectName2,criteriaObjectName3, nil];
    
    recordTypeDepList = [rtPicklistService fetchSFRTPicklistByFields:[NSArray arrayWithObjects:kFieldAPIName,kRecordTypeId,klabel,kvalue, nil] andCriteria:criteriaObjects];
    
    return recordTypeDepList;
}

+ (NSArray *)getRTDependencyFieldsForobject:(NSString *)objectName recordTypeId:(NSString *)value
{
    NSMutableArray *recordTypeDepFields = nil;
    
    id <SFRTPicklistDAO> rtPicklistService = [FactoryDAO serviceByServiceType:ServiceTypeSFRTPicklist];
  
    NSArray *criteriaObjects = nil;
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kobjectApiName operatorType:SQLOperatorEqual andFieldValue:objectName];
    
    if ([value length] > 0) {
        DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:kRecordTypeId operatorType:SQLOperatorEqual andFieldValue:value];
        criteriaObjects = [NSArray arrayWithObjects:criteria, criteria1, nil];
    }
    else {
        criteriaObjects = [NSArray arrayWithObject:criteria];
    }
    
    NSArray * resultSet = [rtPicklistService fetchSFRTPicklistByDistinctFields:[NSArray arrayWithObject:kFieldAPIName] andCriteria:criteriaObjects];
    
    if ([resultSet count] > 0) {
        
        recordTypeDepFields = [NSMutableArray new];
        
        for (SFRTPicklistModel *model in resultSet) {
            if (model != nil) {
                [recordTypeDepFields addObject:model.fieldAPIName];
            }
        }
    }
    return recordTypeDepFields;
}


+ (NSDictionary *)getDefaultValueForRTDepFields:(NSArray *)fields
                                objectName:(NSString *)objectName
                              recordTypeId:(NSString *)recordTypeId
{
    NSMutableDictionary *recordTypeDepFields = nil;
    
    id <SFRTPicklistDAO> rtPicklistService = [FactoryDAO serviceByServiceType:ServiceTypeSFRTPicklist];
    
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kobjectApiName operatorType:SQLOperatorEqual andFieldValue:objectName];
    
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:kRecordTypeId operatorType:SQLOperatorEqual andFieldValue:recordTypeId];
    
    DBCriteria *field = [[DBCriteria alloc] initWithFieldName:kFieldAPIName operatorType:SQLOperatorIn andFieldValues:fields];
    
    NSArray * resultSet = [rtPicklistService fetchSFRTPicklistByDistinctFields:[NSArray arrayWithObjects:kdefaultValue, kdefaultLabel, kFieldAPIName, nil] andCriteria:[NSArray arrayWithObjects:criteria, criteria1, field, nil]];
    
    if ([resultSet count] > 0) {
        
        recordTypeDepFields = [NSMutableDictionary new];
        
        for (SFRTPicklistModel *model in resultSet) {
            if ([model.defaultLabel length] > 0 && [model.defaultValue length] > 0) {
                NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:model.defaultValue, kdefaultValue, model.defaultLabel, kdefaultLabel, nil];
                
                [recordTypeDepFields setObject:dict forKey:model.fieldAPIName];

            }
        }
    }
    return recordTypeDepFields;
}

+ (NSDictionary *)getProcessNameForProcessId:(NSArray *)processIds
{
    NSMutableDictionary *processInfoDict = [NSMutableDictionary new];
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:ksfId operatorType:SQLOperatorIn andFieldValues:processIds];
    
    id sfProcessService = [FactoryDAO serviceByServiceType:ServiceTypeProcess];
    
    if ([sfProcessService conformsToProtocol:@protocol(SFProcessDAO)]) {
        
        NSArray *resultSet = [sfProcessService fetchSFProcessInfoByFields:[NSArray arrayWithObjects:ksfId, kprocessName, ktype, nil] andCriteria:[NSArray arrayWithObject:criteria] andExpression:nil];
        
        for (SFProcessModel *model in resultSet) {
            if (model != nil) {
                [processInfoDict setObject:model forKey:model.sfID];
            }
        }
    }
    return processInfoDict;
}

+ (NSArray *)getLinkedProcessIdsForDetail:(NSString *)processId componentId:(NSString *)componentId
{
    id linkedSfmService = [FactoryDAO serviceByServiceType:ServiceTypeLinkedSFMProcess];
    
    NSMutableArray *resultSet = nil;
    
    if ([linkedSfmService conformsToProtocol:@protocol(LinkedSfmProcessDAO)]) {
        
        DBCriteria *criteriaHeader = [[DBCriteria alloc] initWithFieldName:kLinkedSfmSourceHeaderId operatorType:SQLOperatorEqual andFieldValue:processId];
        
        DBCriteria *criteriaDetail = [[DBCriteria  alloc] initWithFieldName:kLinkedSfmSourceDetailId operatorType:SQLOperatorEqual andFieldValue:componentId];
        
        resultSet = [NSMutableArray new];
        
        NSArray *criterias = [NSArray arrayWithObjects:criteriaHeader, criteriaDetail, nil];
        NSArray *fields = [NSArray arrayWithObject:kLinkedSfmTargetHeaderId];
        
        NSArray *record = [linkedSfmService fetchLinkedProcessInfoByFields:fields andCriteria:criterias
                                                             andExpression:@"1 AND 2"];
        for (LinkedSfmProcessModel *model in record) {
            if (model.targetHeader != nil) {
                [resultSet addObject:model.targetHeader];
            }
        }
    }
    return resultSet;
}

#pragma mark - Insert/Update functions
- (BOOL)insertRecord:(NSMutableDictionary *)record
      intoObjectName:(NSString *)objectName {
    
    NSMutableDictionary *headerRecord = [[NSMutableDictionary alloc] init];
    
    NSDictionary *fieldTyDictionary =  [SFMPageEditHelper getObjectFieldInfoByType:objectName];
    for (NSString *eachFieldName in fieldTyDictionary) {
        
        NSString *fieldType = [fieldTyDictionary objectForKey:eachFieldName];
        if ([fieldType isEqualToString:kSfDTBoolean]) {
            [headerRecord setObject:kFalse forKey:eachFieldName];
        }
        
    }
    
    for (NSString *fieldName in record) {
        SFMRecordFieldData *fieldValue = [record objectForKey:fieldName];
        if (![StringUtil isStringEmpty:fieldValue.internalValue]) {
            [headerRecord setObject:fieldValue.internalValue forKey:fieldName];
        }
        
    }
    NSArray *transactionObjects = [[NSArray alloc]init];
    if ([objectName isEqualToString:kServicemaxEventObject] || [objectName isEqualToString:kEventObject]) {
        transactionObjects = @[[self getEventTransactionObjectForObject:objectName withData:headerRecord]];
    }else {
        
        TransactionObjectModel *aModel = [[TransactionObjectModel alloc] initWithObjectApiName:objectName];
        
        [aModel mergeFieldValueDictionaryForFields:headerRecord];
        transactionObjects = @[aModel];
    }
    
    id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    TXFetchHelper *helper = [[TXFetchHelper alloc]init];
    DBRequestInsert *query =  [helper getInsertQuery:objectName];
    return [transObjectService insertTransactionObjects:transactionObjects andDbRequest:[query query]];
}

- (BOOL)updateRecord:(NSDictionary *)record inObjectName:(NSString *)objectName andLocalId:(NSString *)localId {
    
    NSMutableDictionary *eachRecord = [[NSMutableDictionary alloc] init];
   
    NSMutableArray *allFields = [[NSMutableArray alloc] init];
    for (NSString *fieldName in record) {
        SFMRecordFieldData *fieldValue = [record objectForKey:fieldName];
        if ([fieldName isEqualToString:kId]) {
            continue;
        }
        if (fieldValue.internalValue != nil) {
            [eachRecord setObject:fieldValue.internalValue forKey:fieldName];
        }
        [allFields addObject:fieldName];
    }
    if ([objectName isEqualToString:kServicemaxEventObject] || [objectName isEqualToString:kEventObject]) {
        
        [allFields addObject:kIsMultiDayEvent];
        [allFields addObject:kSplitDayEvents];
        [allFields addObject:kTimeZone];
        EventTransactionObjectModel *model = [[EventTransactionObjectModel alloc] initWithObjectApiName:objectName];
        [model mergeFieldValueDictionaryForFields:eachRecord];
        [model splittingTheEvent];
        [model isItMultiDay];
        
        NSTimeZone *timeZone = [NSTimeZone localTimeZone];
        NSInteger secondsFromGmt = [timeZone secondsFromGMT];
        [eachRecord setObject:[NSNumber numberWithBool:model.isItMultiDay] forKey:kIsMultiDayEvent];
        [eachRecord setObject:[model convertToJsonString] forKey:kSplitDayEvents];
        [eachRecord setObject:[NSString stringWithFormat:@"%ld",(long)secondsFromGmt] forKey:kTimeZone];
        [model mergeFieldValueDictionaryForFields:eachRecord];
        
    }else {
    TransactionObjectModel *aModel = [[TransactionObjectModel alloc] initWithObjectApiName:objectName];
    [aModel mergeFieldValueDictionaryForFields:eachRecord];
    }
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:localId];
    
    id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
   return [transObjectService updateEachRecord:eachRecord withFields:allFields withCriteria:@[criteria] withTableName:objectName];
}

- (void)deleteRecordWithId:(NSString *)recordId fromObjectName:(NSString *)objectName {
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:recordId];
    id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];

    [transObjectService deleteRecordsFromObject:objectName whereCriteria:@[criteria] andAdvanceExpression:nil];
}

- (void)deleteRecordWithIds:(NSArray *)recordIds
             fromObjectName:(NSString *)objectName
       andCriteriaFieldName:(NSString *)fieldName {
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:fieldName operatorType:SQLOperatorIn andFieldValues:recordIds];
    id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    [transObjectService deleteRecordsFromObject:objectName whereCriteria:@[criteria] andAdvanceExpression:nil];
}

- (BOOL)updateFinalRecord:(NSDictionary *)eachRecord inObjectName:(NSString *)objectName andLocalId:(NSString *)localId {
  
    TransactionObjectModel *aModel = [[TransactionObjectModel alloc] initWithObjectApiName:objectName];
    [aModel mergeFieldValueDictionaryForFields:eachRecord];
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:localId];
    
    id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    return [transObjectService updateEachRecord:eachRecord withFields:[eachRecord allKeys] withCriteria:@[criteria] withTableName:objectName];
}

+ (BOOL)getObjectFieldCountForObject:(NSString *)objectName
{
    BOOL result = NO;
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:objectName];
    
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:kfieldname operatorType:SQLOperatorNotEqual andFieldValue:@"\"\""];
    
    id <SFObjectFieldDAO> objectFieldService = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];

    NSInteger count = [objectFieldService getNumberOfRecordsFromObject:kSFObjectField
                                                        withDbCriteria:[NSArray arrayWithObjects:criteria, criteria1, nil]
                                                 andAdvancedExpression:@"1 AND 2"];
    if (count > 0) {
        result = YES;
    }
    return result;
}



#pragma mark - Support functions
+ (NSDictionary *)getAllDataForObject:(NSString *)objectName
                          andRecordId:(NSString *)recordId

{
    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorEqual andFieldValue:recordId];
    id <TransactionObjectDAO>  transObj = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    NSArray * transactionRecords =  [transObj fetchDataWithhAllFieldsAsStringObjects:objectName fields:nil expression:nil criteria:@[criteria]];
    
    if ([transactionRecords count]> 0) {
        TransactionObjectModel *model = [transactionRecords objectAtIndex:0];
        return [model getFieldValueDictionary];
    }
    return nil;
}

+(SFRecordTypeModel *)getRecordTypeobjectForIdOrName:(NSString *)recordType andObjectName:(NSString *)objectName {
    id <SFRecordTypeDAO> picklistService = [FactoryDAO serviceByServiceType:ServiceTypeSFRecordType];
    
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldName:kobjectApiName operatorType:SQLOperatorEqual andFieldValue:objectName];
    DBCriteria * criteria2 = [[DBCriteria alloc] initWithFieldName:kRecordType operatorType:SQLOperatorEqual andFieldValue:recordType];
    DBCriteria * criteria3 = [[DBCriteria alloc] initWithFieldName:kRecordTypeId operatorType:SQLOperatorEqual andFieldValue:recordType];
    
    NSArray * fieldNames = [[NSArray alloc] initWithObjects:kRecordType, kRecordTypeId, kRecordtypeLabel, nil];
    
    NSArray * resultSet = [picklistService fetchSFRecordTypeInfoByFields:fieldNames andCriteria:@[criteria1,criteria2,criteria3] andExpression:@"( 1 and ( 2 or 3))"];
    
    if ([resultSet count] > 0) {
        return [resultSet objectAtIndex:0];
    }
    return nil;
}
+ (SFPicklistModel *)getPickListLabelFor:(NSString *)picklistValue
                           withFieldName:(NSString *)fieldApiName
                           andObjectName:(NSString *)objectName {
    id <SFPicklistDAO> picklistService = [FactoryDAO serviceByServiceType:ServiceTypeSFPickList];
    
    DBCriteria * criteriaObjectName1 = [[DBCriteria alloc] initWithFieldName:kfieldname operatorType:SQLOperatorEqual andFieldValue:fieldApiName];
    DBCriteria * criteriaObjectName2 = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:objectName];
    
    DBCriteria * criteriaObjectName3 = [[DBCriteria alloc] initWithFieldName:kvalue operatorType:SQLOperatorEqual andFieldValue:picklistValue];
    
    NSArray * criteriaObjects = [[NSArray alloc] initWithObjects:criteriaObjectName1, criteriaObjectName2,criteriaObjectName3, nil];
    
    
    
    NSArray *resultSet = [picklistService fetchSFPicklistInfoByFields:@[klabel] andCriteria:criteriaObjects andExpression:nil];
    if ([resultSet count] > 0) {
        return [resultSet objectAtIndex:0];
    }
    return nil;
}

+ (NSDictionary *)getPicklistLabelsFor:(NSArray *)picklistValues
                         withFieldName:(NSString *)fieldApiName
                         andObjectName:(NSString *)objectName  {
    id <SFPicklistDAO> picklistService = [FactoryDAO serviceByServiceType:ServiceTypeSFPickList];
    
    DBCriteria * criteriaObjectName1 = [[DBCriteria alloc] initWithFieldName:kfieldname operatorType:SQLOperatorEqual andFieldValue:fieldApiName];
    DBCriteria * criteriaObjectName2 = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:objectName];
    
    DBCriteria * criteriaObjectName3 = [[DBCriteria alloc] initWithFieldName:kvalue operatorType:SQLOperatorIn andFieldValues:picklistValues];
    
    NSArray * criteriaObjects = [[NSArray alloc] initWithObjects:criteriaObjectName1, criteriaObjectName2,criteriaObjectName3, nil];
    
    
    
    NSArray *resultSet = [picklistService fetchSFPicklistInfoByFields:@[kvalue,klabel] andCriteria:criteriaObjects andExpression:nil];
    if ([resultSet count] > 0) {
        NSMutableDictionary *allRecordsDictionary = [[NSMutableDictionary alloc] init];
        for (SFPicklistModel *model in resultSet) {
            if (model.value != nil && model.label != nil) {
                [allRecordsDictionary setObject:model.label forKey:model.value];
            }
        }
        return allRecordsDictionary;
    }
    return nil;

    
}
+ (NSString *) getSettingValueForKey:(NSString *)setting {
    
    id <MobileDeviceSettingDAO> settingDaoObject = [FactoryDAO serviceByServiceType:ServiceTypeMobileDeviceSettings];
    NSString *settingValue = @"";
    
    if ([settingDaoObject conformsToProtocol:@protocol(MobileDeviceSettingDAO)]) {
        MobileDeviceSettingsModel *settingModel = [settingDaoObject fetchDataForSettingId:setting];
        settingValue = settingModel.value;
    }
    return settingValue;
}

- (EventTransactionObjectModel*)getEventTransactionObjectForObject:(NSString*)objectName withData:(NSDictionary*)dataDict
{
    EventTransactionObjectModel *model = [[EventTransactionObjectModel alloc] initWithObjectApiName:objectName];
    [model mergeFieldValueDictionaryForFields:dataDict];
    [model splittingTheEvent];
    [model isItMultiDay];
    
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSInteger secondsFromGmt = [timeZone secondsFromGMT];
    
    NSMutableDictionary *eventDict = [NSMutableDictionary dictionaryWithDictionary:dataDict];
    
    [eventDict setObject:[NSNumber numberWithBool:model.isItMultiDay] forKey:kIsMultiDayEvent];
    [eventDict setObject:[model convertToJsonString] forKey:kSplitDayEvents];
    [eventDict setObject:[NSString stringWithFormat:@"%ld",(long)secondsFromGmt] forKey:kTimeZone];
    [model mergeFieldValueDictionaryForFields:eventDict];
    return model;
}

#pragma mark End

@end
