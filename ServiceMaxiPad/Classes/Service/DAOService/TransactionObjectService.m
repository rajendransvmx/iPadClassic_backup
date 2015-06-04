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
#import "EventTransactionObjectModel.h"
#import "SFObjectDAO.h"
#import "FactoryDAO.h"
#import "SuccessiveSyncManager.h"

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
    __block TransactionObjectModel *model = nil;
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [selectQuery query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            model = [[TransactionObjectModel alloc] init];
            NSMutableDictionary * dict = (NSMutableDictionary *)[resultSet resultDictionaryWithFieldsAsString];
            //Method in model to set the values
            [model setObjectName:objectName];
            [model setRecordLocalId:recordId];
            [model mergeFieldValueDictionaryForFields:dict];
        }
        [resultSet close];
    }];
    }
    return model;
}

- (TransactionObjectModel *)getBeforeModificationDataForObject:(NSString *)objectName fields:(NSArray *)fieldNames recordId:(NSString *)recordId
{
    DBCriteria * criteria = [[DBCriteria alloc]initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:recordId];
    
    DBRequestSelect * selectQuery = [[DBRequestSelect alloc] initWithTableName:objectName
                                                                 andFieldNames:fieldNames
                                                                 whereCriteria:criteria];
    __block TransactionObjectModel *model = nil;
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [selectQuery query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                model = [[TransactionObjectModel alloc] init];
                NSMutableDictionary * dict = (NSMutableDictionary *)[resultSet beforeModificationDictionaryWithFieldsAsString];
                //Method in model to set the values
                [model setObjectName:objectName];
                [model setRecordLocalId:recordId];
                [model mergeFieldValueDictionaryForFields:dict];
            }
            [resultSet close];
        }];
    }
    return model;
}


- (TransactionObjectModel *)getLocalIDForObject:(NSString *)objectName recordId:(NSString *)recordId
{
    DBCriteria * criteria = [[DBCriteria alloc]initWithFieldName:kId operatorType:SQLOperatorEqual andFieldValue:recordId];
    
    DBRequestSelect * selectQuery = [[DBRequestSelect alloc] initWithTableName:objectName
                                                                 andFieldNames:[NSArray arrayWithObject:kLocalId]
                                                                 whereCriteria:criteria];
    __block TransactionObjectModel * model = nil;
    
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [selectQuery query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            model = [[TransactionObjectModel alloc] init];
            NSDictionary * dict = [resultSet resultDictionary];
            //Method in model to set the values
            [model setRecordLocalId:recordId];
            [model mergeFieldValueDictionaryForFields:dict];
        }
        [resultSet close];
    }];
    }
    return model;
}

- (TransactionObjectModel *)getTechnicianIdForObject:(NSString *)objectName ownerId:(NSString *)ownerId
{
    DBCriteria * criteria = [[DBCriteria alloc]initWithFieldName:ORG_NAME_SPACE"__Salesforce_User__c" operatorType:SQLOperatorEqual andFieldValue:ownerId];
    
    DBRequestSelect * selectQuery = [[DBRequestSelect alloc] initWithTableName:objectName
                                                                 andFieldNames:[NSArray arrayWithObject:kId]
                                                                 whereCriteria:criteria];
    __block TransactionObjectModel * model = nil;
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [selectQuery query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                model = [[TransactionObjectModel alloc] init];
                NSDictionary * dict = [resultSet resultDictionary];
                //Method in model to set the values
                [model mergeFieldValueDictionaryForFields:dict];
            }
            [resultSet close];
        }];
    }
    return model;
}

- (TransactionObjectModel *)getDataForObject:(NSString *)objectName
                                      fields:(NSArray *)fieldNames
                                  expression:(NSString *)advancaeExpression
                                    criteria:(NSArray *)criteria
{
    
    DBRequestSelect * selectQuery = [[DBRequestSelect alloc] initWithTableName:objectName andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:advancaeExpression];
    
    __block TransactionObjectModel * model = nil;
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [selectQuery query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            model = [[TransactionObjectModel alloc] init];
            NSDictionary * dict = [resultSet resultDictionary];
            [model setRecordLocalId:[dict objectForKey:kLocalId]];
            //Method in model to set the values
            [model mergeFieldValueDictionaryForFields:dict];
        }
        [resultSet close];
    }];
    }
    return model;
}


#pragma mark - for sfmpage precision fix

- (NSArray *)fetchDataForObjectForSfmPage:(NSString *)objectName
                         fields:(NSArray *)fieldNames
                     expression:(NSString *)advancaeExpression
                       criteria:(NSArray *)criteria
{
    
    DBRequestSelect * selectQuery = [[DBRequestSelect alloc] initWithTableName:objectName andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:advancaeExpression];
    
    NSMutableArray * detailsArray = [self getDetailsDataForQueryForSfmPage:selectQuery];
    return detailsArray;
}

- (NSMutableArray *)getDetailsDataForQueryForSfmPage:(DBRequestSelect *)selectQuery
{
    NSMutableArray * detailsArray = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [selectQuery query];
            
            //   query = @"SELECT tSource.id, tDestination.id FROM SVMXC__Service_Order__c tSource, SVMXC__Service_Order_Line__c tDestination WHERE tDestination.SVMXC__Service_Order__c = tSource.localId or tDestination.SVMXC__Service_Order__c = tSource.id";
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                // NSDictionary * dict = [resultSet resultDictionary];
                NSDictionary * dict = [resultSet resultDictionaryWithFieldsAsString];
                
                //Method in model to set the values
                TransactionObjectModel * model = [[TransactionObjectModel alloc] init];
                [model setRecordLocalId:[dict objectForKey:kLocalId]];
                [model mergeFieldValueDictionaryForFields:dict];
                if (model != nil) {
                    [detailsArray addObject:model];
                }
            }
            [resultSet close];
        }];
    }
    return detailsArray;
}

#pragma mark - End
- (NSArray *)fetchDataForObject:(NSString *)objectName
                                    fields:(NSArray *)fieldNames
                                  expression:(NSString *)advancaeExpression
                                    criteria:(NSArray *)criteria
{
    
    DBRequestSelect * selectQuery = [[DBRequestSelect alloc] initWithTableName:objectName andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:advancaeExpression];
    
    NSMutableArray * detailsArray = [self getDetailsDataForQuery:selectQuery];
    return detailsArray;
}

- (NSArray *)fetchEventDataForObject:(NSString *)objectName
                         fields:(NSArray *)fieldNames
                     expression:(NSString *)advancaeExpression
                       criteria:(NSArray *)criteria
{
    
    DBRequestSelect * selectQuery = [[DBRequestSelect alloc] initWithTableName:objectName andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:advancaeExpression];
    
    NSMutableArray * detailsArray = [self getEventDataForQuery:selectQuery];
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
    
    SXLogDebug(@"Query = %@", [selectQuery query] );
    
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
    
    NSMutableArray * detailsArray = [self getDetailsDataForQueryForSfmPage:selectQuery];

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
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [selectQuery query];
        
     //   query = @"SELECT tSource.id, tDestination.id FROM SVMXC__Service_Order__c tSource, SVMXC__Service_Order_Line__c tDestination WHERE tDestination.SVMXC__Service_Order__c = tSource.localId or tDestination.SVMXC__Service_Order__c = tSource.id";
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
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
        [resultSet close];
    }];
    }
    return detailsArray;
}

- (NSMutableArray *)getEventDataForQuery:(DBRequestSelect *)selectQuery
{
    NSMutableArray * detailsArray = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [selectQuery query];
            
            NSLog(@"query:%@", query);
            //   query = @"SELECT tSource.id, tDestination.id FROM SVMXC__Service_Order__c tSource, SVMXC__Service_Order_Line__c tDestination WHERE tDestination.SVMXC__Service_Order__c = tSource.localId or tDestination.SVMXC__Service_Order__c = tSource.id";
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                NSDictionary * dict = [resultSet resultDictionary];
                //Method in model to set the values
                EventTransactionObjectModel *model = [[EventTransactionObjectModel alloc] init];
                
                [model setRecordLocalId:[dict objectForKey:kLocalId]];
                [model mergeFieldValueDictionaryForFields:dict];
                [model setObjectName:selectQuery.objectName];
//                [model splittingTheEvent];
//                [model performSelectorInBackground:@selector(splittingTheEvent) withObject:nil];

                if (model != nil) {
                    [detailsArray addObject:model];
                }
            }
            [resultSet close];
        }];
    }
    return detailsArray;
}

- (BOOL)isTransactiontableEmpty:(NSString *)objectName
{
    DBRequestSelect *dbSelect = [[DBRequestSelect alloc] initWithTableName:objectName aggregateFunction:SQLAggregateFunctionCount whereCriterias:nil andAdvanceExpression:nil];
    
    __block BOOL isRecordExist = NO;
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [dbSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        if([resultSet next])
        {
            NSDictionary * dict = [resultSet resultDictionary];
            
           
            if ([dict count]>0) {
                isRecordExist = [[dict valueForKey:@"COUNT(*)"] boolValue];
            }
            else
            {
                // SXLogDebug(@"%@ count zero ", objectName);
            }
        }
        [resultSet close];
    }];
    }
    
    SXLogInfo(@"isTransactiontableEmpty : %@ - %d", objectName, isRecordExist);
    return isRecordExist;
}


- (BOOL)isTransactionTableExist:(NSString *)objectName // // 2-June BSP: For Defect 17514: Sorting on SFM Search
{
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:@"type" operatorType:SQLOperatorEqual andFieldValue:@"table"];
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:@"name" operatorType:SQLOperatorEqual andFieldValue:objectName];
    
    DBRequestSelect * selectQuery = [[DBRequestSelect alloc] initWithTableName:@"sqlite_master" andFieldNames:@[@"name"] whereCriterias:@[criteria1, criteria2] andAdvanceExpression:nil];
    
    
    __block NSString *tableName;
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [selectQuery query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            if([resultSet next])
            {
                NSDictionary * dict = [resultSet resultDictionary];
                
                
                if ([dict count]>0) {
                    tableName = [dict valueForKey:[[dict allKeys] objectAtIndex:0]];
                }
                else
                {
                    // SXLogDebug(@"%@ count zero ", objectName);
                }
            }
            [resultSet close];
        }];
    }
    
    SXLogInfo(@"isTransactiontableExist : %@ - %d", objectName, tableName);
    if (tableName.length) {
        return YES;
    }
    return NO;
}


#pragma mark - transcation object insert function 
- (BOOL)insertRecordInTransaction:(TransactionObjectModel *)transModel
                  andInsertRequest:(DBRequest *)insertRequest
{
    __block BOOL returnValue = NO;
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
    NSString *insertQuery = [insertRequest query];
    returnValue = [db executeUpdateWithEmptyStringInsertedForEmptyColumns:insertQuery
                                          withParameterDictionary:[transModel getFieldValueDictionary]];
    }];
    }
    return returnValue;
}

- (BOOL)executeRecordInTransaction:(TransactionObjectModel *)transModel
                 andQuery:(NSString *)insertQuery
{
    __block BOOL returnValue = NO;
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
    returnValue = [db executeUpdateWithEmptyStringInsertedForEmptyColumns:insertQuery
                                                  withParameterDictionary:[transModel getFieldValueDictionary]];
    }];
    }
    return returnValue;
}


- (BOOL)insertTransactionObjects:(NSArray *)transactionObjects
                    andDbRequest:(NSString *)insertQuery {
    
    BOOL retValue = YES;
   
    for (TransactionObjectModel *model in transactionObjects)
    {
        retValue = [self executeRecordInTransaction:model andQuery:insertQuery];
    }
        
    
    return retValue;
}

- (BOOL)updateOrInsertTransactionObjects:(NSArray *)transactionObjects
                          withObjectName:(NSString *)objectName
                            andDbRequest:(DBRequest *)insertRequest
                        andUpdateRequest:(DBRequest *)dbRequestUpdate  {
    
        BOOL retValue = YES;
        
        NSString *insertQuery = [insertRequest query];
        NSString *updateQuery = [dbRequestUpdate query];
        
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
            if (finalQuery) {
                retValue = [self executeRecordInTransaction:model andQuery:finalQuery];
            }
            
            // fix 17505 - from Spr 15 - v15.30.012
            ModifiedRecordModel *succmodel = [[SuccessiveSyncManager sharedSuccessiveSyncManager] successiveSyncRecordForSfId:[model valueForField:kId]];
            
            if (succmodel) {
                [[SuccessiveSyncManager sharedSuccessiveSyncManager] updateRecord:succmodel.recordDictionary inObjectName:succmodel.objectName andLocalId:succmodel.recordLocalId];
            }
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
    BOOL status = [self updateEachRecord:dictionary withQuery:[updatequery query]];
    return status;
}

/* Last modified Shravya*/
-(BOOL)updateEachRecord:(NSDictionary *)dictionary  withQuery:(NSString *)query_
{
    __block BOOL returnValue = NO;
    NSString *query =  query_;
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
    returnValue = [db executeUpdateWithEmptyStringInsertedForEmptyColumns:query
                                                                                withParameterDictionary:dictionary];
    }];
    }
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
    BOOL status = [self updateEachRecord:dataDictionary withQuery:[updatequery query]];
    return status;
}

- (NSArray *)getFieldValueForObjectName:(NSString *)objectName andNameFiled:(NSString*)nameField
{
    
    DBRequestSelect * selectQuery = [[DBRequestSelect alloc] initWithTableName:objectName
                                                                 andFieldNames:@[nameField,@"CreatedDate",@"localId"]
                                                                whereCriteria:nil];
    NSMutableArray *modelArray = [[NSMutableArray alloc]init];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [selectQuery query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            
            TransactionObjectModel * model = [[TransactionObjectModel alloc] initWithObjectApiName:objectName];
            NSDictionary * dict = [resultSet resultDictionary];
            //Method in model to set the values
           // [model setRecordLocalId:recordId];
            [model mergeFieldValueDictionaryForFields:dict];
            [modelArray addObject:model];
            model.nameField = nameField;
        }
        [resultSet close];
    }];
    }
    return modelArray;
}

- (NSString *)getFieldValueForObjectName:(NSString *)objectName nameFiled:(NSString*)nameField andLocalId:(NSString*)localId
{
    DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:@"localId" operatorType:SQLOperatorEqual andFieldValue:localId];
    DBRequestSelect * selectQuery = [[DBRequestSelect alloc] initWithTableName:objectName
                                                                 andFieldNames:@[nameField,@"CreatedDate",@"localId"]
                                                                 whereCriteria:criteria];
    NSMutableArray *modelArray = [[NSMutableArray alloc]init];
    
    __block NSString *fieldValue = nil;
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {

        NSString * query = [selectQuery query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            
            TransactionObjectModel * model = [[TransactionObjectModel alloc] initWithObjectApiName:objectName];
            NSDictionary * dict = [resultSet resultDictionary];
            //Method in model to set the values
            // [model setRecordLocalId:recordId];
            [model mergeFieldValueDictionaryForFields:dict];
            [modelArray addObject:model];
            model.nameField = nameField;
           
            NSDictionary *fieldValueDictionary = [model getFieldValueDictionary];
            fieldValue = [fieldValueDictionary objectForKey:nameField];
        }
        }];
    }
    return fieldValue;
}

- (NSMutableArray *)getDataForSearchQuery:(NSString *)selectQuery forSearchFields:(NSArray *)searchFields
{
    NSMutableArray * detailsArray = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = selectQuery;
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
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
        [resultSet close];
    }];
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
        SXLogWarning(@"There seem to be no columns in this set.");
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
    
    __block NSMutableArray * detailsArray = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        
        NSString * query = [selectQuery query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            NSMutableDictionary * dict = (NSMutableDictionary *)[resultSet resultDictionaryWithFieldsAsString];
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
        [resultSet close];
    }];
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
        SXLogWarning(@"There seem to be no columns in this set.");
    }
    
    }
    return nil;
}

#pragma mark  End


#pragma mark - Data Purge
- (NSArray *)getLocalIDForObject:(NSString *)objectName recordIds:(NSArray *)recordIds
{
    DBCriteria * criteria = [[DBCriteria alloc]initWithFieldName:kId
                                                    operatorType:SQLOperatorIn
                                                  andFieldValues:recordIds];
    
    DBRequestSelect * selectQuery = [[DBRequestSelect alloc] initWithTableName:objectName
                                                                 andFieldNames:[NSArray arrayWithObject:kLocalId]
                                                                 whereCriteria:criteria];
    
    NSMutableArray *modelArray = [[NSMutableArray alloc]init];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [selectQuery query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                TransactionObjectModel *model = [[TransactionObjectModel alloc] init];
                NSDictionary * dict = [resultSet resultDictionary];
                [model setRecordLocalId:[dict objectForKey:kLocalId]];
                //[model mergeFieldValueDictionaryForFields:dict];
                [modelArray addObject:model];
            }
            [resultSet close];
        }];
    }
    return modelArray;
}
#pragma mark - End

#pragma mark - fill complete what id

//-(NSString *)getObjectNameForWhatId:(NSString *)whatId {
//    
//    if (whatId.length < 15) {
//        return nil;
//    }
//    
//    NSString *keyPrefix = [whatId substringToIndex:3];
//    
//    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:@"keyPrefix" operatorType:SQLOperatorEqual andFieldValue:keyPrefix];
//    
//    id <SFObjectDAO> objectService = [FactoryDAO serviceByServiceType:ServiceTypeSFObject];
//    
//    SFObjectModel *model = [objectService getSFObjectInfo:criteria fieldName:@[@"objectName"]];
//    
//    return model.objectName;
//}

//- (NSArray*)fetchAllTheIdsForGivenSetOfPartialWhatId:(NSArray*)listOfPartialWhatId
//{
//    //SELECT id
//   // FROM SVMXDEV__Service_Order__c where id LIKE ( (select
//                                                  //  SVMXDEV__WhatId__c from SVMXDEV__SVMX_Event__c where
//                                                  //  SVMXDEV__Service_Order__c = ' ' )) || '%'
//}

#pragma mark - end
@end
