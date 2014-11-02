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
- (NSArray *)getAllIdsFromHeapTableForObjectName:(NSString *) objectName  forLimit:(NSInteger)limit
{
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:@"objectName" operatorType:SQLOperatorEqual andFieldValue:objectName];
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:[NSArray arrayWithObjects:@"sfId", nil] whereCriteria:criteria1];
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
{
    DBCriteria *criteriaOne = [[DBCriteria alloc]initWithFieldName:@"sfId" operatorType:SQLOperatorIn andFieldValues:recordsIds];
    DBRequestDelete *requestDelete = [[DBRequestDelete alloc] initWithTableName:[self tableName] whereCriteria:[NSArray arrayWithObject:criteriaOne] andAdvanceExpression:nil];
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
{
    NSMutableArray * idsArray = [[NSMutableArray alloc] init];
    
    NSArray * allkeys = [deletedIdsdict allKeys];
    
    for (NSString * objName in allkeys ) {
        NSDictionary  *idsListDict = [deletedIdsdict objectForKey:objName];
        [idsArray addObjectsFromArray:[idsListDict allKeys]];
    }
   [self deleteRecordsForSfIds:idsArray];
}
@end
