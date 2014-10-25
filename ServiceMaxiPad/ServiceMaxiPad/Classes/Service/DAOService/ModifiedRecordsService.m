//
//  ModifiedRecordsService.m
//  ServiceMaxMobile
//
//  Created by Sahana on 08/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "ModifiedRecordsService.h"
#import "DBCriteria.h"
#import "DBRequestSelect.h"
#import "DatabaseManager.h"
#import "SQLResultSet.h"
#import "ModifiedRecordModel.h"
#import "DatabaseConstant.h"


@implementation ModifiedRecordsService


- (NSDictionary *)getInsertedSyncRecords
{
    return [self getSyncRecordsOfType:kModificationTypeInsert];
}

- (NSDictionary *) getUpdatedRecords
{
    return [self getSyncRecordsOfType:kModificationTypeUpdate];
}

- (NSDictionary *)getDeletedRecords
{
    return [self getSyncRecordsOfType:kModificationTypeDelete];
    
}

- (NSMutableDictionary *) getSyncRecordsOfType:(NSString *)opertationType
{
    NSMutableDictionary * syncRecordDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    DBCriteria * criteriaObj = [[DBCriteria alloc] initWithFieldName:kSyncRecordOperation operatorType:SQLOperatorEqual andFieldValue:opertationType];
    

    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:[NSArray arrayWithObjects:kSyncRecordLocalId,kSyncRecordObjectname,kSyncRecordType,kSyncRecordSFId, nil] whereCriteria:criteriaObj];
    [requestSelect setDistinctRowsOnly];
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            
            ModifiedRecordModel * modifiedRecord = [[ModifiedRecordModel alloc] init];
            
            [resultSet kvcMagic:modifiedRecord];
           
            if (modifiedRecord.recordLocalId.length < 15) {
                modifiedRecord.recordLocalId = @"";
            }
            NSMutableDictionary *objectDictionary = [syncRecordDict valueForKey:modifiedRecord.recordType];
            if (nil == objectDictionary) {
                objectDictionary = [[NSMutableDictionary alloc] init];
                [syncRecordDict setObject:objectDictionary forKey:modifiedRecord.recordType];
            }
            NSMutableArray *recordsArray = [objectDictionary valueForKey:modifiedRecord.objectName];
            if (nil == recordsArray) {
                recordsArray = [[NSMutableArray alloc] init];
                [objectDictionary setObject:recordsArray forKey:modifiedRecord.objectName];
            }
            [recordsArray addObject:modifiedRecord];
        }
        
    }
    
    return syncRecordDict;
}

-(NSString *)tableName
{
    return kModifiedRecords;
}

- (NSInteger)getLastLocalId {
    DBField *aField = [[DBField alloc] initWithFieldName:kLocalId andTableName:kModifiedRecords];
    DBRequestSelect *selectRequest = [[DBRequestSelect alloc] initWithField:aField aggregateFunction:SQLAggregateFunctionMax whereCriterias:nil andAdvanceExpression:nil];
    NSInteger maxNumber = -1;
    SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:[selectRequest query]];
    if([resultSet next])
    {
        NSString *keyString = [[NSString alloc] initWithFormat:@"%@(%@)",kSQLAggregateFunctionMax,kLocalId];
        NSDictionary * dict = [resultSet resultDictionary];
        if ([dict count]>0) {
            NSString *aValue = [dict valueForKey:keyString] ;
            if (![aValue isKindOfClass:[NSNull class]]) {
                maxNumber = [aValue intValue];
            }
        }
    }
    return maxNumber;
}

- (NSArray *)fieldNamesToBeRemovedFromQuery {
    return @[@"cannotSendToServer",@"jsonRecord"];
}

-(BOOL)deleteRecordsForRecordLocalIds:(NSArray *)recordsIds
{
    DBCriteria *criteriaOne = [[DBCriteria alloc]initWithFieldName:@"recordLocalId"
                                                      operatorType:SQLOperatorIn
                                                    andFieldValues:recordsIds];
    
    BOOL status = [self deleteRecordsFromObject:kModifiedRecords
                                  whereCriteria:[NSArray arrayWithObject:criteriaOne]
                           andAdvanceExpression:nil];
    return status;
}


- (NSArray *) getSyncRecordsOfType:(NSString *)opertationType andObjectName:(NSString *)objectName
{
   
    
    DBCriteria * criteriaObj = [[DBCriteria alloc] initWithFieldName:kSyncRecordOperation operatorType:SQLOperatorEqual andFieldValue:opertationType];
    
    DBCriteria * criteriaObj2 = [[DBCriteria alloc] initWithFieldName:kSyncRecordObjectname operatorType:SQLOperatorEqual andFieldValue:objectName];
    
    
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:[NSArray arrayWithObjects:kSyncRecordLocalId, nil] whereCriterias:@[criteriaObj,criteriaObj2] andAdvanceExpression:nil];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    NSMutableArray *allRecordArray = [[NSMutableArray alloc] init];
    if (didOpen)
    {
        
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            
            ModifiedRecordModel * modifiedRecord = [[ModifiedRecordModel alloc] init];
            
            [resultSet kvcMagic:modifiedRecord];
            
            if (modifiedRecord.recordLocalId != nil) {
                [allRecordArray addObject:modifiedRecord.recordLocalId];
            }
            
        }
    }
    
    return allRecordArray;
}

@end
