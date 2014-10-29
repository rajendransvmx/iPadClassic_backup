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
#import "SFMSearchFieldModel.h"


@interface TransactionObjectService ()

- (NSMutableDictionary*)getresultDictionarySet:(SQLResultSet *)resultSet;
- (NSMutableArray *)getDataAsAllFieldString:(DBRequestSelect *)selectQuery ;

@end
@implementation TransactionObjectService


- (TransactionObjectModel *)getDataForObject:(NSString *)objectName fields:(NSArray *)fieldNames recordId:(NSString *)recordId
{
    DBCriteria * criteria = [[DBCriteria alloc]initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:recordId];
    
    DBRequestSelect * selectQuery = [[DBRequestSelect alloc] initWithTableName:objectName
                                                                andFieldNames:fieldNames
                                                            whereCriteria:criteria];
    TransactionObjectModel *model = nil;
    

    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [selectQuery query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            model = [[TransactionObjectModel alloc] init];
            NSMutableDictionary * dict = [self getresultDictionarySet:resultSet];
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
    TransactionObjectModel * model = nil;
    
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [selectQuery query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            model = [[TransactionObjectModel alloc] init];
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
    
    TransactionObjectModel * model = nil;
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [selectQuery query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            model = [[TransactionObjectModel alloc] init];
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
    [selectQuery setDistinctRowsOnly];
    
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

/* Last modified Shravya*/
-(BOOL)updateEachRecord:(NSDictionary *)dictionary  withQuery:(NSString *)query_
{
    BOOL returnValue = NO;
    NSString *query =  query_;
    
    if (![[DatabaseManager sharedInstance] inTransaction]) {
        NSLog(@"You need to start the transcation to use this functions");
        return NO;
    }
    returnValue = [[DatabaseManager sharedInstance] executeUpdateWithEmptyStringInsertedForEmptyColumns:query
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
        return [fieldValue objectForKey:kId];
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
- (NSMutableArray *)getDataForSearchQuery:(NSString *)selectQuery forSearchFields:(NSArray *)searchFields
{
    NSMutableArray * detailsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = selectQuery;
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            NSDictionary *dict = [self resultDictionaryForFields:searchFields withResultset:resultSet];
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
- (NSDictionary*)resultDictionaryForFields:(NSArray *)fields withResultset:(SQLResultSet *)resultSet {
    
    SQLStatement *sqlStatement = [resultSet statement];
    
    NSUInteger num_cols = (NSUInteger)sqlite3_data_count([sqlStatement statement]);
    
    if (num_cols > 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:num_cols];
        
        int columnCount = sqlite3_column_count([sqlStatement statement]);
        
        int columnIdx = 0;
        for (columnIdx = 0; columnIdx < columnCount; columnIdx++) {
            
            NSString *columnName = @"";
            if (columnIdx > 1) {
                SFMSearchFieldModel *searchField = fields[columnIdx-2];
                //2 because id and local id. fields array will be consisting all those configured display fields.
                columnName = [searchField getDisplayField];
            }
            else
            {
                columnName = [NSString stringWithUTF8String:sqlite3_column_name([sqlStatement statement], columnIdx)];
            }
            id objectValue = [resultSet stringObjectForAllColumnIndex:columnIdx];
            //id objectValue = [resultSet objectForColumnIndex:columnIdx];
            
            if ([objectValue isKindOfClass:[NSNull class]]) {
                [dict setValue:nil forKey:columnName];
            }
            else{
                [dict setObject:objectValue forKey:columnName];
            }
            
        }
        
        return dict;
    }
    else {
        NSLog(@"Warning: There seem to be no columns in this set.");
    }
    
    return nil;
}


- (void)replaceAllFieldValueByRecordFieldIn:(TransactionObjectModel *)model {
 
    NSMutableDictionary *recordFieldDictionary = [model getFieldValueMutableDictionary];
    NSArray *allKeys = [recordFieldDictionary allKeys];
    //for (NSString *eachFieldKey in recordFieldDictionary) {
    for (NSString *key in allKeys) {
        
        NSString *eachValue = [recordFieldDictionary objectForKey:key];
        
        SFMRecordFieldData *recordFieldModel = [[SFMRecordFieldData alloc] initWithFieldName:key value:eachValue andDisplayValue:eachValue];
        [recordFieldDictionary setObject:recordFieldModel forKey:key];
        
    }
}
-(BOOL)doesRecordExistsForObject:(NSString *)objectName forRecordId:(NSString *)recordId
{
    BOOL flag = NO;
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:recordId];
    
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorEqual andFieldValue:recordId];
    
   NSInteger totalCount =  [self getNumberOfRecordsFromObject:objectName withDbCriteria:@[criteria1,criteria2] andAdvancedExpression:@"(1 or 2)"];
    
    if(totalCount > 0)
    {
        flag = YES;
    }
    
    return flag;
}


#pragma mark  - Fetching data with all fields as string
- (NSArray *)fetchDataWithhAllFieldsAsStringObjects:(NSString *)objectName
                         fields:(NSArray *)fieldNames
                     expression:(NSString *)advancaeExpression
                       criteria:(NSArray *)criteria
{
    
    DBRequestSelect * selectQuery = [[DBRequestSelect alloc] initWithTableName:objectName andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:advancaeExpression];
    
    NSMutableArray * detailsArray = [self getDataAsAllFieldString:selectQuery];
  return detailsArray;
}

- (NSMutableArray *)getDataAsAllFieldString:(DBRequestSelect *)selectQuery {
    NSMutableArray * detailsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [selectQuery query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            NSMutableDictionary * dict = [self getresultDictionarySet:resultSet];
            //Method in model to set the values
            TransactionObjectModel * model = [[TransactionObjectModel alloc] init];
            [model setRecordLocalId:[dict objectForKey:kLocalId]];
            
            NSString *sfid = [dict objectForKey:kId];
            if (sfid == nil || sfid.length < 10) {
                
                for (NSString *eachFieldName in  selectQuery.fieldNames) {
                    
                    NSString *eachValue = [dict objectForKey:eachFieldName];
                    if (eachValue == nil || eachValue.length < 1) {
                        
                        [dict removeObjectForKey:eachFieldName];
                    }
                }
            }
            
            [model mergeFieldValueDictionaryForFields:dict];
            if (model != nil) {
                [detailsArray addObject:model];
            }
        }
    }
    return detailsArray;

}


- (NSMutableDictionary*)getresultDictionarySet:(SQLResultSet *)resultSet {
    
    @synchronized([self class]) {
        SQLStatement *sqlStatement = [resultSet statement];
    
        NSUInteger num_cols = (NSUInteger)sqlite3_data_count([sqlStatement statement]);
    
        if (num_cols > 0) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:num_cols];
        
            int columnCount = sqlite3_column_count([sqlStatement statement]);
        
            int columnIdx = 0;
            for (columnIdx = 0; columnIdx < columnCount; columnIdx++) {
            
            NSString *columnName = @"";
            columnName = [NSString stringWithUTF8String:sqlite3_column_name([sqlStatement statement], columnIdx)];
            id objectValue = [resultSet stringObjectForAllColumnIndex:columnIdx];
            
            if ([objectValue isKindOfClass:[NSNull class]]) {
                [dict setValue:nil forKey:columnName];
            }
            else{
                [dict setObject:objectValue forKey:columnName];
            }
        }
        
        return dict;
    }
    else {
        NSLog(@"Warning: There seem to be no columns in this set.");
    }
    
    }
    return nil;
}

#pragma mark  End

@end
