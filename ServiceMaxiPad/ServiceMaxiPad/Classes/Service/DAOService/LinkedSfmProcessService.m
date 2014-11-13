//
//  LinkedSfmProcessService.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 08/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "LinkedSfmProcessService.h"

@implementation LinkedSfmProcessService

- (NSString *)tableName {
    return kLinkedProcessTable;
}


- (NSArray * )fetchLinkedProcessInfoByFields:(NSArray *)fieldNames
                             andCriteria:(NSArray *)criteria
                           andExpression:(NSString *)expression
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kLinkedProcessTable andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:expression];
    
    [requestSelect setDistinctRowsOnly];
    
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                LinkedSfmProcessModel * model = [[LinkedSfmProcessModel alloc] init];
                [resultSet kvcMagic:model];
                [records addObject:model];
            }
            [resultSet close];
        }];
    }
    return records;
}

@end
