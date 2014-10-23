//
//  TransactionObjectService.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 22/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "TransactionObjectService.h"
#import "DatabaseManager.h"
#import "DBRequestInsert.h"
#import "SFProcessModel.h"
#import "ParserUtility.h"
#import "DBRequestSelect.h"
#import "SQLResultSet.h"
#import "DBRequestUpdate.h"
#import "SFMRecordFieldData.h"

@implementation TransactionObjectService


- (TransactionObjectModel *)getDataForObject:(NSString *)objectName fields:(NSArray *)fieldNames recordId:(NSString *)recordId
{
    DBCriteria * criteria = [[DBCriteria alloc]initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:recordId];
    
    DBRequestSelect * selectQuery = [[DBRequestSelect alloc] initWithTableName:objectName
                                                                andFieldNames:fieldNames
                                                            whereCriteria:criteria];
    TransactionObjectModel * model = [[TransactionObjectModel alloc] init];
    

    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [selectQuery query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            NSDictionary * dict = [resultSet resultDictionary];
            //Method in model to set the values
            [model setRecordLocalId:recordId];
            [model mergeFieldValueDictionaryForFields:dict];
        }
    }
    return model;
}


- (TransactionObjectModel *)getLocalIDForObject:(NSString *)objectName recordId:(NSString *)recordId
{
    DBCriteria * criteria = [[DBCriteria alloc]initWithFieldName:kId operatorType:SQLOperatorEqual andFieldValue:recordId];
    
    DBRequestSelect * selectQuery = [[DBRequestSelect alloc] initWithTableName:objectName
                                                                 andFieldNames:[NSArray arrayWithObject:kLocalId]
                                                                 whereCriteria:criteria];
    TransactionObjectModel * model = [[TransactionObjectModel alloc] init];
    
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [selectQuery query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            NSDictionary * dict = [resultSet resultDictionary];
            //Method in model to set the values
            [model setRecordLocalId:recordId];
            [model mergeFieldValueDictionaryForFields:dict];
        }
    }
    return model;
}


- (TransactionObjectModel *)getDataForObject:(NSString *)objectName
                                      fields:(NSArray *)fieldNames
                                  expression:(NSString *)advancaeExpression
                                    criteria:(NSArray *)criteria
{
    
    DBRequestSelect * selectQuery = [[DBRequestSelect alloc] initWithTableName:objectName andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:advancaeExpression];
    
    TransactionObjectModel * model = [[TransactionObjectModel alloc] init];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [selectQuery query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            NSDictionary * dict = [resultSet resultDictionary];
            [model setRecordLocalId:[dict objectForKey:kLocalId]];
            //Method in model to set the values
            [model mergeFieldValueDictionaryForFields:dict];
        }
    }
    return model;
}


- (NSArray *)fetchDataForObject:(NSString *)objectName
                                    fields:(NSArray *)fieldNames
                                  expression:(NSString *)advancaeExpression
                                    criteria:(NSArray *)criteria
{
    
    DBRequestSelect * selectQuery = [[DBRequestSelect alloc] initWithTableName:objectName andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:advancaeExpression];
    
    NSMutableArray * detailsArray = [self getDetailsDataForQuery:selectQuery];
    return detailsArray;
}

- (NSArray *)fetchDataForObject:(NSString *)objectName
                         fields:(NSArray *)fieldNames
                     expression:(NSString *)advancaeExpression
                       criteria:(NSArray *)criteria
                   recordsLimit:(NSInteger)recordLimit
{
    DBRequestSelect * selectQuery = [[DBRequestSelect alloc] initWithTableName:objectName andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:advancaeExpression];
    selectQuery.limit = recordLimit;
    
    NSMutableArray * detailsArray = [self getDetailsDataForQuery:selectQuery];
    return detailsArray;
}


- (NSArray *)fetchDetailDataForObject:(NSString *)objectName
                         fields:(NSArray *)fieldNames
                     expression:(NSString *)advancaeExpression
                       criteria:(NSArray *)criteria
                    withSorting:(NSDictionary *)sortingData
{
    
    DBRequestSelect * selectQuery = [[DBRequestSelect alloc] initWithTableName:objectName andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:advancaeExpression];
    
    if ([sortingData count] > 0) {
        
        NSArray *array = [sortingData objectForKey:@"ORDER BY"];
        
        if ([array count] > 0) {
            [selectQuery addOrderByFields:array];
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:sortingData];
        [dict removeObjectForKey:@"ORDER BY"];
        if ([dict count] > 0) {
            [self addJoinQuery:selectQuery data:dict];
        }
    }
    
    NSMutableArray * detailsArray = [self getDetailsDataForQuery:selectQuery];

    return detailsArray;
}

- (void)addJoinQuery:(DBRequestSelect *)selectQuery data:(NSDictionary *)joinDict
{
    for (NSString *key in joinDict) {
        
        NSString *tableName = [joinDict objectForKey:key];
        
        if ([tableName length] > 0) {
            [selectQuery addLeftOuterJoinTable:tableName andPrimaryTableFieldName:key];
        }
    }
}

- (NSMutableArray *)getDetailsDataForQuery:(DBRequestSelect *)selectQuery
{
    NSMutableArray * detailsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [selectQuery query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            NSDictionary * dict = [resultSet resultDictionary];
            //Method in model to set the values
            TransactionObjectModel * model = [[TransactionObjectModel alloc] init];
            [model setRecordLocalId:[dict objectForKey:kLocalId]];
            [model mergeFieldValueDictionaryForFields:dict];
            if (model != nil) {
                [detailsArray addObject:model];
            }
        }
    }
    return detailsArray;
}

- (BOOL)isTransactiontableEmpty:(NSString *)objectName
{
    DBRequestSelect *dbSelect = [[DBRequestSelect alloc] initWithTableName:objectName aggregateFunction:SQLAggregateFunctionCount whereCriterias:nil andAdvanceExpression:nil];
    
    BOOL isRecordExist = NO;
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [dbSelect query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        if([resultSet next])
        {
            NSDictionary * dict = [resultSet resultDictionary];
            if ([dict count]>0) {
                isRecordExist = [[dict valueForKey:@"COUNT(*)"] boolValue];
            }
        }
    }
    return isRecordExist;
}

#pragma mark - transcation object insert function 
- (BOOL)insertRecordInTransaction:(TransactionObjectModel *)transModel
                  andInsertRequest:(DBRequest *)insertRequest
{
    BOOL returnValue = NO;
    if (![[DatabaseManager sharedInstance] inTransaction]) {
        NSLog(@"You need to start the transcation to use this functions");
        return NO;
    }
    
    NSString *insertQuery = [insertRequest query];
    returnValue = [[DatabaseManager sharedInstance] executeUpdateWithEmptyStringInsertedForEmptyColumns:insertQuery
                                          withParameterDictionary:[transModel getFieldValueDictionary]];
    return returnValue;
}

- (BOOL)executeRecordInTransaction:(TransactionObjectModel *)transModel
                 andQuery:(NSString *)insertQuery
{
    BOOL returnValue = NO;
    if (![[DatabaseManager sharedInstance] inTransaction]) {
        NSLog(@"You need to start the transcation to use this functions");
        return NO;
    }
    returnValue = [[DatabaseManager sharedInstance] executeUpdateWithEmptyStringInsertedForEmptyColumns:insertQuery
                                                                                withParameterDictionary:[transModel getFieldValueDictionary]];
    return returnValue;
}


- (BOOL)insertTransactionObjects:(NSArray *)transactionObjects
                    andDbRequest:(NSString *)insertQuery {
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    BOOL retValue = YES;
    if (didOpen)
    {
        [[DatabaseManager sharedInstance] beginTransaction];
        
        for (TransactionObjectModel *model in transactionObjects)
        {
            retValue = [self executeRecordInTransaction:model andQuery:insertQuery];
        }
        
        [[DatabaseManager sharedInstance] commit];
    }
    return retValue;
}

- (BOOL)updateOrInsertTransactionObjects:(NSArray *)transactionObjects
                          withObjectName:(NSString *)objectName
                            andDbRequest:(DBRequest *)insertRequest
                        andUpdateRequest:(DBRequest *)dbRequestUpdate  {
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    BOOL retValue = YES;
    if (didOpen)
    {
        NSString *insertQuery = [insertRequest query];
        NSString *updateQuery = [dbRequestUpdate query];
        [[DatabaseManager sharedInstance] beginTransaction];
        
        for (TransactionObjectModel *model in transactionObjects)
        {
            NSString *finalQuery = nil;
            BOOL recordExist = [self checkIfRecordExist:model andObjectName:objectName];
            if (recordExist) {
                /* Update */
                finalQuery = updateQuery;
            }
            else{
                /* Insert */
                finalQuery = insertQuery;
            }
            retValue = [self executeRecordInTransaction:model andQuery:finalQuery];
        }
        
        [[DatabaseManager sharedInstance] commit];
    }
    return retValue;
}

- (BOOL)checkIfRecordExist:(TransactionObjectModel *)model andObjectName:(NSString *)objectName {
    NSString *sfId = [model valueForField:kId];
    DBCriteria *aCriteria = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorEqual andFieldValue:sfId];
    NSInteger count =  [self getNumberOfRecordsFromObject:objectName withDbCriteria:@[aCriteria] andAdvancedExpression:nil];
    if (count > 0) {
        return YES;
    }
    return NO;
}
//Used in GetPriceDataCall Number 3
- (NSArray *)getListWorkorderCurrencies  {
    
    NSArray *retValue = [self fetchDataForObject:kWorkOrderTableName
                                          fields:@[@"CurrencyIsoCode"]
                                      expression:nil
                                        criteria:nil];
    return retValue;
}
-(BOOL)updateEachRecord:(NSDictionary *)dictionary  withFields:(NSArray *)fieldsArray withCriteria:(NSArray *)criteriaArray withTableName:(NSString *)tableName
{
    DBRequestUpdate * updatequery = [[DBRequestUpdate alloc] initWithTableName:tableName andFieldNames:fieldsArray whereCriteria:criteriaArray andAdvanceExpression:nil];
    [[DatabaseManager sharedInstance] beginTransaction];
    BOOL status = [self updateEachRecord:dictionary withQuery:[updatequery query]];
    [[DatabaseManager sharedInstance] commit];
    return status;
}
-(BOOL)updateEachRecord:(NSDictionary *)dictionary  withQuery:(NSString *)query_
{
    BOOL returnValue = NO;
    NSString *query =  query_;
    
    if (![[DatabaseManager sharedInstance] inTransaction]) {
        NSLog(@"You need to start the transcation to use this functions");
        return NO;
    }
    returnValue = [[DatabaseManager sharedInstance] executeUpdate:query
                                          withParameterDictionary:dictionary];
    return returnValue;
}
-(BOOL)isRecordExistsForObject:(NSString *)objectName forRecordLocalId:(NSString *)recordLoclaId
{
    BOOL flag = NO;
   TransactionObjectModel * model =  [self getDataForObject:objectName fields:Nil recordId:recordLoclaId];
    
    if([[model getFieldValueDictionary ] count] > 0)
    {
        flag = YES;
    }
    
    return flag;
}
-(NSString *)getSfIdForLocalId:(NSString *)recordLoclaId forObjectName:(NSString *)objectName
{
    TransactionObjectModel * model =  [self getDataForObject:objectName fields:[NSArray arrayWithObject:kId] recordId:recordLoclaId];
    
 
     NSDictionary * fieldValue = [model getFieldValueDictionaryForFields:[NSArray arrayWithObject:kId]];
    
    if (fieldValue != nil && [fieldValue count] > 0)
    {
        [fieldValue objectForKey:@"Id"];
    }
    return nil;
}
- (BOOL)updateField:(DBField *)field
          withValue:(NSString *)value
      andDbCriteria:(DBCriteria *)criteria {
    
    NSDictionary *dataDictionary = @{field.name:value};
    DBRequestUpdate * updatequery = [[DBRequestUpdate alloc] initWithTableName:field.tableName andFieldNames:@[field.name] whereCriteria:@[criteria] andAdvanceExpression:nil];
    [[DatabaseManager sharedInstance] beginTransaction];
    BOOL status = [self updateEachRecord:dataDictionary withQuery:[updatequery query]];
    [[DatabaseManager sharedInstance] commit];
    return status;
}

- (NSArray *)getFieldValueForObjectName:(NSString *)objectName andNameFiled:(NSString*)nameField
{
    
    DBRequestSelect * selectQuery = [[DBRequestSelect alloc] initWithTableName:objectName
                                                                 andFieldNames:@[nameField,@"CreatedDate",@"localId"]
                                                                whereCriteria:nil];
    NSMutableArray *modelArray = [[NSMutableArray alloc]init];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [selectQuery query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            
            TransactionObjectModel * model = [[TransactionObjectModel alloc] initWithObjectApiName:objectName];
            NSDictionary * dict = [resultSet resultDictionary];
            //Method in model to set the values
           // [model setRecordLocalId:recordId];
            [model mergeFieldValueDictionaryForFields:dict];
            [modelArray addObject:model];
            model.nameField = nameField;
        }
    }
    return modelArray;
}
- (NSMutableArray *)getDataForSearchQuery:(NSString *)selectQuery
{
    NSMutableArray * detailsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = selectQuery;
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            NSDictionary * dict = [resultSet resultDictionary];
            //Method in model to set the values
            TransactionObjectModel * model = [[TransactionObjectModel alloc] init];
            [model setRecordLocalId:[dict objectForKey:kLocalId]];
            [model mergeFieldValueDictionaryForFields:dict];
            [self replaceAllFieldValueByRecordFieldIn:model];
            if (model != nil) {
                [detailsArray addObject:model];
            }
        }
    }
    return detailsArray;
}
- (void)replaceAllFieldValueByRecordFieldIn:(TransactionObjectModel *)model {
 
    NSMutableDictionary *recordFieldDictionary = [model getFieldValueMutableDictionary];
    NSArray *allKeys = [recordFieldDictionary allKeys];
    //for (NSString *eachFieldKey in recordFieldDictionary) {
    for (NSString *key in allKeys) {
        
        NSString *eachValue = [recordFieldDictionary objectForKey:key];
        
        SFMRecordFieldData *recordFieldModel = [[SFMRecordFieldData alloc] initWithFieldName:eachValue value:eachValue andDisplayValue:eachValue];
        [recordFieldDictionary setObject:recordFieldModel forKey:key];
        
    }
}
@end
