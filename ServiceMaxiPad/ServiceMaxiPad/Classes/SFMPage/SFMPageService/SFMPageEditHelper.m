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

@implementation SFMPageEditHelper

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
    NSMutableArray * picklistArray = [[NSMutableArray alloc] init];
    
    id <SFPicklistDAO> picklistService = [FactoryDAO serviceByServiceType:ServiceTypeSFPickList];
    
    DBCriteria * criteriaObjectName1 = [[DBCriteria alloc] initWithFieldName:kfieldname operatorType:SQLOperatorEqual andFieldValue:fieldApiName];
    DBCriteria * criteriaObjectName2 = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:objectName];
    
    NSArray * criteriaObjects = [[NSArray alloc] initWithObjects:criteriaObjectName1, criteriaObjectName2, nil];
    
    DBField *orderByfield = [[DBField alloc] initWithFieldName:kindexValue andTableName:kSFPicklist];
    
    picklistArray = (NSMutableArray *)[picklistService fetchSFPicklistInfoByFields:[NSArray arrayWithObjects:kfieldname,klabel,kvalue,kindexValue,kvalidFor, nil] andCriteria:criteriaObjects andExpression:@"(1 AND 2)" OrderBy:[NSArray arrayWithObject:orderByfield]];
    
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
            index = picklistModel.indexValue;
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
    return dependentPicklistValues;
}


//For REcord Type Dependency
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


+ (BOOL)isRecordTypeDependent:(NSString *)fieldName RecordTypeFieldData:(NSString *)recordTypeValue
                andObjectName:(NSString *)objectName
{
    
    id <SFRTPicklistDAO> picklistService = [FactoryDAO serviceByServiceType:ServiceTypeSFRTPicklist];
    
    DBCriteria * criteriaObjectName1 = [[DBCriteria alloc] initWithFieldName:kobjectApiName operatorType:SQLOperatorEqual andFieldValue:objectName];
    DBCriteria * criteriaObjectName2 = [[DBCriteria alloc] initWithFieldName:kRecordTypeId operatorType:SQLOperatorEqual andFieldValue:recordTypeValue];
    
    DBCriteria * criteriaObjectName3 = [[DBCriteria alloc] initWithFieldName:kFieldAPIName operatorType:SQLOperatorEqual andFieldValue:fieldName];
    
    NSArray * criteriaObjects = [[NSArray alloc] initWithObjects:criteriaObjectName1,
                                 criteriaObjectName2,criteriaObjectName3, nil];
    
    NSInteger count = [picklistService getNumberOfRecordsFromObject:@"SFRTPicklist" withDbCriteria:criteriaObjects andAdvancedExpression:@"(1 AND 2 AND 3)"];
    if(count > 0)
        return TRUE;
    else
        return FALSE;
}

+ (NSArray *)getRecordTypePicklistData:(NSString *)objectName fieldName:(NSString *)fieldName
                         pageDataValue:(NSString *)internalValue
{
    NSArray *recordTypeDepList = nil;
    
    id <SFRTPicklistDAO> rtPicklistService = [FactoryDAO serviceByServiceType:ServiceTypeSFRTPicklist];
    
    DBCriteria * criteriaObjectName1 = [[DBCriteria alloc] initWithFieldName:kobjectApiName operatorType:SQLOperatorEqual andFieldValue:objectName];
    DBCriteria * criteriaObjectName2 = [[DBCriteria alloc] initWithFieldName:kRecordTypeId operatorType:SQLOperatorEqual andFieldValue:internalValue];
    
    DBCriteria * criteriaObjectName3 = [[DBCriteria alloc] initWithFieldName:kFieldAPIName operatorType:SQLOperatorEqual andFieldValue:fieldName];
    
    NSArray * criteriaObjects = [[NSArray alloc] initWithObjects:criteriaObjectName1,
                                 criteriaObjectName2,criteriaObjectName3, nil];
    
    recordTypeDepList = [rtPicklistService fetchSFRTPicklistByFields:[NSArray arrayWithObjects:kFieldAPIName,kRecordTypeId,klabel,kvalue, nil] andCriteria:criteriaObjects];
    
    return recordTypeDepList;
}


#pragma mark - Insert/Update functions
- (BOOL)insertRecord:(NSMutableDictionary *)record
      intoObjectName:(NSString *)objectName {
    
    NSMutableDictionary *headerRecord = [[NSMutableDictionary alloc] init];
 
    for (NSString *fieldName in record) {
        SFMRecordFieldData *fieldValue = [record objectForKey:fieldName];
        if (fieldValue.internalValue != nil) {
            [headerRecord setObject:fieldValue.internalValue forKey:fieldName];
        }
        
    }
    TransactionObjectModel *aModel = [[TransactionObjectModel alloc] initWithObjectApiName:objectName];
    [aModel mergeFieldValueDictionaryForFields:headerRecord];
    
     id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    TXFetchHelper *helper = [[TXFetchHelper alloc]init];
    DBRequestInsert *query =  [helper getInsertQuery:objectName];
    return [transObjectService insertTransactionObjects:@[aModel] andDbRequest:[query query]];
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
    
    TransactionObjectModel *aModel = [[TransactionObjectModel alloc] initWithObjectApiName:objectName];
    [aModel mergeFieldValueDictionaryForFields:eachRecord];
    
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


@end
