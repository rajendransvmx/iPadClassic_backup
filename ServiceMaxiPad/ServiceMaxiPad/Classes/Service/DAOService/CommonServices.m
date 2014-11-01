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

@implementation CommonServices

- (BOOL)saveRecordsInTransaction:(id )model
{
    BOOL returnValue = NO;
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
    NSString *query = [insert query];
    
    if (![[DatabaseManager sharedInstance] inTransaction]) {
        NSLog(@"You need to start the transcation to use this functions");
        return NO;
    }
    returnValue = [[DatabaseManager sharedInstance] executeUpdate:query
                                          withParameterDictionary:[model dictionaryWithValuesForKeys:fieldNames]];
    return returnValue;
}

- (BOOL)saveRecordModel:(id )model {
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    BOOL retValue = YES;
    if(didOpen)
    {
        [[DatabaseManager sharedInstance] beginTransaction];
        retValue = [self saveRecordsInTransaction:model];
        [[DatabaseManager sharedInstance] commit];
    }
    return retValue;
    
}
- (BOOL)saveRecordModels:(NSMutableArray *)recordsArray {
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    BOOL retValue = YES;
    if (didOpen)
    {
        [[DatabaseManager sharedInstance] beginTransaction];
        
        for (id model in recordsArray)
        {
            retValue = [self saveRecordsInTransaction:model];
        }
        
        [[DatabaseManager sharedInstance] commit];
    }
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
-(BOOL)updateEachRecord:(id)model  withQuery:(NSString *)query_
{
    BOOL returnValue = NO;
    NSMutableArray* fieldNames =  (NSMutableArray*)[ParserUtility getPropertiesOfClass:model];
    
    if ([self removeLocalIdField]) {
        if ([fieldNames containsObject:kLocalId]) {
            [fieldNames removeObject:kLocalId];
        }
    }
    
    NSString *query =  query_;
    
    if (![[DatabaseManager sharedInstance] inTransaction]) {
        NSLog(@"You need to start the transcation to use this functions");
        return NO;
    }
   // NSLog(@"parameterdictionary = %@",[model dictionaryWithValuesForKeys:fieldNames]);
//    returnValue = [[DatabaseManager sharedInstance] executeUpdate:query
//                                          withParameterDictionary:[model dictionaryWithValuesForKeys:fieldNames]];
//
    
    returnValue = [[DatabaseManager sharedInstance]  executeUpdateWithEmptyStringInsertedForEmptyColumns:query withParameterDictionary:[model dictionaryWithValuesForKeys:fieldNames]];
    return returnValue;
}

-(BOOL)updateEachRecord:(id)model  withFields:(NSArray *)fieldsArray withCriteria:(NSArray *)criteriaArray
{
  DBRequestUpdate * updatequery = [[DBRequestUpdate alloc] initWithTableName:[self tableName] andFieldNames:fieldsArray whereCriteria:criteriaArray andAdvanceExpression:nil];
   [[DatabaseManager sharedInstance] beginTransaction];
   BOOL status = [self updateEachRecord:model withQuery:[updatequery query]];
    [[DatabaseManager sharedInstance] commit];
    return status;
}


-(void)updateRecords:(NSArray *)modelsArray  withFields:(NSArray *)fieldsArray withCriteria:(NSArray *)criteriaArray
{
    DBRequestUpdate * updatequery = [[DBRequestUpdate alloc] initWithTableName:[self tableName] andFieldNames:fieldsArray whereCriteria:criteriaArray andAdvanceExpression:nil];
   
    [[DatabaseManager sharedInstance] beginTransaction];
    for (id  eachModel in modelsArray) {
         [self updateEachRecord:eachModel withQuery:[updatequery query]];
    }
    [[DatabaseManager sharedInstance] commit];
}
- (NSString *)updateQuery
{
    return nil;
}

- (BOOL)executeStatement:(NSString*)queryStatement
{
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    BOOL retValue = YES;
    if (didOpen)
    {
        [[DatabaseManager sharedInstance] beginTransaction];
        
       retValue = [[DatabaseManager sharedInstance] executeUpdate:queryStatement];
        [[DatabaseManager sharedInstance] commit];
    }
    return retValue;

}

- (NSInteger)getNumberOfRecordsFromObject:(NSString *)objectName
                           withDbCriteria:(NSArray *)criterias
                    andAdvancedExpression:(NSString *)advancedExpression {
    
    DBRequestSelect *selectRequest = [[DBRequestSelect alloc] initWithTableName:objectName aggregateFunction:SQLAggregateFunctionCount whereCriterias:criterias andAdvanceExpression:advancedExpression];
    NSInteger count = -1;
    SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:[selectRequest query]];
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

@end
