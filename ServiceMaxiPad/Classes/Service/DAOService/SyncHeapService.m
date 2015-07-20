//
//  SyncHeapService.m
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 22/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SyncHeapService.h"
#import "DBRequestSelect.h"
#import "DatabaseManager.h"
#import "SyncRecordHeapModel.h"
#import "SQLResultSet.h"
#import "DBRequestDelete.h"

@implementation SyncHeapService

- (NSString *)tableName
{
    return @"Sync_Records_Heap";
}

-(NSArray *)getAllIdsFromHeapTableForObjectName:(NSString *)objectName
                                       forLimit:(NSInteger)limit
                            forParallelSyncType:(NSString*)parallelSyncType;
{
    DBCriteria *criteriaOne = [[DBCriteria alloc] initWithFieldName:@"objectName" operatorType:SQLOperatorEqual andFieldValue:objectName];
    DBRequestSelect * requestSelect = nil;
    if (parallelSyncType != nil && ![parallelSyncType isKindOfClass:[NSNull class]])
    {
        DBCriteria *criteriaTwo = [[DBCriteria alloc] initWithFieldName:@"parallelSyncType" operatorType:SQLOperatorEqual andFieldValue:parallelSyncType];
        requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:[NSArray arrayWithObjects:@"sfId", nil] whereCriterias:@[criteriaOne, criteriaTwo] andAdvanceExpression:nil];
    }
    else
    {
        DBCriteria *criteriaTwo = [[DBCriteria alloc] initWithFieldName:@"parallelSyncType" operatorType:SQLOperatorIsNull andFieldValue:nil];
        requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:[NSArray arrayWithObjects:@"sfId", nil] whereCriterias:@[criteriaOne, criteriaTwo] andAdvanceExpression:nil];
    }
    
    if(limit != 0)
    {
        [requestSelect setLimit:limit];
    }
    [requestSelect setDistinctRowsOnly];
    
    return [self getRecordsFromQuery:[requestSelect query]];
 
}

-(NSArray *)getDistinctObjectNames
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:[NSArray arrayWithObjects:@"objectName", nil] whereCriteria:nil];
    
    [requestSelect setDistinctRowsOnly];
    
    return [self getRecordsFromQuery:[requestSelect query]];
    
    return nil;
}

-(void)deleteRecordsForSfIds:(NSArray *)recordsIds
         forParallelSyncType:(NSString*)parallelSyncType
{
    DBCriteria *criteriaOne = [[DBCriteria alloc] initWithFieldName:@"sfId" operatorType:SQLOperatorIn andFieldValues:recordsIds];
    DBRequestDelete *requestDelete = nil;
    
    if (parallelSyncType != nil && ![parallelSyncType isKindOfClass:[NSNull class]])
    {
        DBCriteria *criteriaTwo = [[DBCriteria alloc] initWithFieldName:@"parallelSyncType" operatorType:SQLOperatorEqual andFieldValue:parallelSyncType];
        requestDelete = [[DBRequestDelete alloc] initWithTableName:[self tableName] whereCriteria:@[criteriaOne, criteriaTwo] andAdvanceExpression:nil];
    }
    else
    {
        DBCriteria *criteriaTwo = [[DBCriteria alloc] initWithFieldName:@"parallelSyncType" operatorType:SQLOperatorIsNull andFieldValue:nil];
        requestDelete = [[DBRequestDelete alloc] initWithTableName:[self tableName] whereCriteria:@[criteriaOne, criteriaTwo] andAdvanceExpression:nil];
    }
    [self executeStatement:[requestDelete query]];
}

- (NSArray*)getRecordsFromQuery:(NSString*)query
{
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            SyncRecordHeapModel * model = [[SyncRecordHeapModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
        [resultSet close];
    }];
    }
    return records;
}

-(void)deleteRecordsFromHeap:(NSDictionary *)deletedIdsdict
         forParallelSyncType:(NSString*)parallelSyncType
{
    NSMutableArray * idsArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray * allkeys = [deletedIdsdict allKeys];
    
    for (NSString * objName in allkeys )
    {
        NSDictionary  *idsListDict = [deletedIdsdict objectForKey:objName];
        [idsArray addObjectsFromArray:[idsListDict allKeys]];
    }
   [self deleteRecordsForSfIds:idsArray forParallelSyncType:parallelSyncType];
}

- (BOOL)doesRecordExistForId:(NSString *)recordId {
    BOOL flag = NO;
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:@"localId" operatorType:SQLOperatorEqual andFieldValue:recordId];
    
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:@"sfId" operatorType:SQLOperatorEqual andFieldValue:recordId];
    
    NSInteger totalCount =  [self getNumberOfRecordsFromObject:[self tableName] withDbCriteria:@[criteria1,criteria2] andAdvancedExpression:@"(1 or 2)"];
    
    if(totalCount > 0)
    {
        flag = YES;
    }
    
    return flag;
}



@end
