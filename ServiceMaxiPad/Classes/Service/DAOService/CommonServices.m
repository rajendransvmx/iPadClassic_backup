//
//  CommonServices.m
//  ServiceMaxMobile
//
//  Created by shravya on 20/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "CommonServices.h"
#import "ParserUtility.h"
#import "DatabaseManager.h"
#import "DBRequestInsert.h"
#import "DBRequestUpdate.h"
#import "DBRequestDelete.h"
#import "PerformanceAnalyser.h"

@implementation CommonServices

- (BOOL)saveRecordsInTransaction:(id )model
{
    __block BOOL returnValue = NO;
    NSMutableArray* fieldNames =  (NSMutableArray*)[ParserUtility getPropertiesOfClass:model];
    
    if ([self removeLocalIdField]) {
        if ([fieldNames containsObject:kLocalId]) {
            [fieldNames removeObject:kLocalId];
        }
    }
    NSArray *fieldNamesToBeRemoved = [self fieldNamesToBeRemovedFromQuery];
    if ([fieldNamesToBeRemoved count] > 0) {
        for (NSString *eachFieldName in fieldNamesToBeRemoved) {
            if ([fieldNames containsObject:eachFieldName]) {
                [fieldNames removeObject:eachFieldName];
            }
        }
    }
 
    DBRequestInsert *insert =  [[DBRequestInsert alloc] initWithTableName:[self tableName] andFieldNames:fieldNames];
    
    if ([self enableInsertOrReplaceOption]) {
        [insert setInsertOrReplaceOption];
    }
    NSString *query = [insert query];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        returnValue = [db executeUpdate:query
                withParameterDictionary:[model dictionaryWithValuesForKeys:fieldNames]];
        }];
    }
    return returnValue;
}

- (BOOL)saveRecordModel:(id )model {
    
    BOOL retValue = NO;
    //PA
    NSString *context = @"DBOperationInsert/Update_static";
    NSString *subContextValue = [[PerformanceAnalyser sharedInstance] getSubContextNameForContext:context SubContext:[self tableName] forOperationTYpe:PAOperationTypeParsing];
    [[PerformanceAnalyser sharedInstance] observePerformanceForContext:context subContextName:subContextValue operationType:PAOperationTypeDBOperation andRecordCount:0];
    
    retValue = [self saveRecordsInTransaction:model];
    //PA
    [[PerformanceAnalyser sharedInstance] ObservePerformanceCompletionForContext:context subContextName:subContextValue operationType:PAOperationTypeDBOperation andRecordCount:1];
    
    return retValue;
    
}
- (BOOL)saveRecordModels:(NSMutableArray *)recordsArray {
    
    BOOL retValue = NO;
    //PA
    NSString *context = @"DBOperationInsert/Update_static";
    NSString *subContextValue = [[PerformanceAnalyser sharedInstance] getSubContextNameForContext:context SubContext:[self tableName] forOperationTYpe:PAOperationTypeParsing];
   
    [[PerformanceAnalyser sharedInstance] observePerformanceForContext:@"DBOperationInsert/Update_static" subContextName:subContextValue operationType:PAOperationTypeDBOperation andRecordCount:0];

    for (id model in recordsArray)
    {
        retValue = [self saveRecordsInTransaction:model];
    }
    //PA
    [[PerformanceAnalyser sharedInstance] ObservePerformanceCompletionForContext:context subContextName:subContextValue operationType:PAOperationTypeDBOperation andRecordCount:(int)[recordsArray count]];
    
    return retValue;
}

- (NSString *)tableName {
    return nil;
}
- (BOOL)removeLocalIdField {
    return YES;
}

- (NSArray *)fieldNamesToBeRemovedFromQuery {
    return nil;
}
- (BOOL)enableInsertOrReplaceOption {
    return NO;
}

-(BOOL)updateEachRecord:(id)model  withQuery:(NSString *)query_
{
    __block BOOL returnValue = NO;
    NSMutableArray* fieldNames =  (NSMutableArray*)[ParserUtility getPropertiesOfClass:model];
    
    if ([self removeLocalIdField]) {
        if ([fieldNames containsObject:kLocalId]) {
            [fieldNames removeObject:kLocalId];
        }
    }
    
    NSString *query =  query_;
    
   // NSLog(@"parameterdictionary = %@",[model dictionaryWithValuesForKeys:fieldNames]);
//    returnValue = [[DatabaseManager sharedInstance] executeUpdate:query
//                                          withParameterDictionary:[model dictionaryWithValuesForKeys:fieldNames]];
//
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
    returnValue = [db  executeUpdateWithEmptyStringInsertedForEmptyColumns:query
                                                   withParameterDictionary:[model dictionaryWithValuesForKeys:fieldNames]];
    }];
    }
    return returnValue;
}

-(BOOL)updateEachRecord:(id)model  withFields:(NSArray *)fieldsArray withCriteria:(NSArray *)criteriaArray
{
  DBRequestUpdate * updatequery = [[DBRequestUpdate alloc] initWithTableName:[self tableName] andFieldNames:fieldsArray whereCriteria:criteriaArray andAdvanceExpression:nil];
   BOOL status = [self updateEachRecord:model withQuery:[updatequery query]];
   return status;
}


-(void)updateRecords:(NSArray *)modelsArray  withFields:(NSArray *)fieldsArray withCriteria:(NSArray *)criteriaArray
{
    DBRequestUpdate * updatequery = [[DBRequestUpdate alloc] initWithTableName:[self tableName] andFieldNames:fieldsArray whereCriteria:criteriaArray andAdvanceExpression:nil];
   
    for (id  eachModel in modelsArray) {
         [self updateEachRecord:eachModel withQuery:[updatequery query]];
    }
}
- (NSString *)updateQuery
{
    return nil;
}

- (BOOL)executeStatement:(NSString*)queryStatement
{
    __block BOOL retValue = NO;
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        retValue = [db executeUpdate:queryStatement];
        
    }];
    }
    return retValue;

}

- (NSInteger)getNumberOfRecordsFromObject:(NSString *)objectName
                           withDbCriteria:(NSArray *)criterias
                    andAdvancedExpression:(NSString *)advancedExpression {
    
    DBRequestSelect *selectRequest = [[DBRequestSelect alloc] initWithTableName:objectName aggregateFunction:SQLAggregateFunctionCount whereCriterias:criterias andAdvanceExpression:advancedExpression];
    //__block NSInteger count = -1;
    //Defect Fix:033408 An Error of "-1" is Displayed On the Tech's Ipad (Similar to Sync Conflict)
    __block NSInteger count = 0;
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
    SQLResultSet * resultSet = [db executeQuery:[selectRequest query]];
    if([resultSet next])
    {
        NSDictionary * dict = [resultSet resultDictionary];
        if ([dict count]>0) {
            NSString *aValue = [dict valueForKey:kCountStart] ;
            if (![aValue isKindOfClass:[NSNull class]]) {
                count = [aValue intValue];
            }
        }
    }
        [resultSet close];
    }];
    }
    return count;
}
- (BOOL)doesRecordExistInTheTable {
    NSInteger totalCount =  [self getNumberOfRecordsFromObject:[self tableName] withDbCriteria:nil andAdvancedExpression:nil];
    if (totalCount > 0) {
        return YES;
    }
    return NO;
}

- (BOOL)deleteRecordsFromObject:(NSString *)objectName
                  whereCriteria:(NSArray *)criteriaArray
           andAdvanceExpression:(NSString *)advanceExpression {
    BOOL status = NO;
    NSAssert(objectName != nil, @"deleteRecordsFromObject:whereCriteria:andAdvanceExpression: The object name string must not be nil!");
    NSAssert(criteriaArray != nil, @"deleteRecordsFromObject:whereCriteria:andAdvanceExpression: The criteria array must not be nil!");
    
    DBRequestDelete *requestDelete = [[DBRequestDelete alloc] initWithTableName:objectName
                                                                  whereCriteria:criteriaArray
                                                           andAdvanceExpression:advanceExpression];
    status = [self executeStatement:[requestDelete query]];
    return status;
}

- (BOOL)doesObjectHavePermission:(NSString *)objectName
{
    //Getting object permission.
    return [self doesObjectAlreadyExist:objectName];
}

- (BOOL)doesObjectAlreadyExist:(NSString *)objectName {
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:@"objectName" operatorType:SQLOperatorEqual andFieldValue:objectName];
    NSInteger totalCount =  [self getNumberOfRecordsFromObject:@"SFObjectField" withDbCriteria:@[criteria] andAdvancedExpression:nil];
    
    if (totalCount > 0) {
        return YES;
        
    }
    return NO;
}

//HS 20 Nov
- (BOOL)doesRecordAlreadyExistWithfieldName:(NSString *)fieldName withFieldValue:(NSString *)fieldValue inTable:(NSString *)tableName {
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:fieldName operatorType:SQLOperatorEqual andFieldValue:fieldValue];
    NSInteger totalCount =  [self getNumberOfRecordsFromObject:tableName withDbCriteria:@[criteria] andAdvancedExpression:nil];
    
    if (totalCount > 0) {
        return YES;
        
    }
    return NO;
}

- (NSArray *)fetchDataForFields:(NSArray *)fields
                      criterias:(NSArray *)criteria
                     objectName:(NSString *)objectName
                  andModelClass:(Class)classType {
    
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:objectName andFieldNames:fields whereCriterias:criteria andAdvanceExpression:nil];
     NSMutableArray *allModels = [[NSMutableArray alloc] init];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
       
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {

        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            id model = [[classType alloc] init];
            [resultSet kvcMagic:model];
            [allModels addObject:model];
        }
        }];
    }
    return allModels;

}

- (NSArray *)fetchDataForFields:(NSArray *)fields
                      criterias:(NSArray *)criteria
                     objectName:(NSString *)objectName
             advancedExpression:(NSString*)advancedExpression
                  andModelClass:(Class)classType {
    
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:objectName andFieldNames:fields whereCriterias:criteria andAdvanceExpression:advancedExpression];
    NSMutableArray *allModels = [[NSMutableArray alloc] init];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                id model = [[classType alloc] init];
                [resultSet kvcMagic:model];
                [allModels addObject:model];
            }
        }];
    }
    return allModels;
    
}

- (BOOL)saveRecordsFromArray:(NSArray *)recordArray inTable:(NSString *)tableName
{
    BOOL retValue = NO;
    for (NSDictionary *dictionary in recordArray) {
        retValue = [self saveRecordFromDictionary:dictionary forFields:[dictionary allKeys] inTable:tableName];
    }
    return retValue;
}


-(BOOL)saveRecordFromDictionary:(NSDictionary *)recordDict forFields:(NSArray *)fieldNames inTable:(NSString *)tableName {
    __block BOOL returnValue = NO;
    
    DBRequestInsert *insert =  [[DBRequestInsert alloc] initWithTableName:tableName andFieldNames:[NSMutableArray arrayWithArray:fieldNames]];
    [insert setInsertOrReplaceOption];
    
    NSString *query = [insert query];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            returnValue = [db executeUpdate:query
                    withParameterDictionary:recordDict];
        }];
    }
    return returnValue;
}

@end
