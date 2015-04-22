//
//  DataPurgeService.m
//  ServiceMaxiPad
//
//  Created by Chinnababu on 05/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "DataPurgeService.h"
#import "DataPurgeModel.h"
@implementation DataPurgeService

- (NSString *)tableName{
    return kDataPurgeHeapTable;
}

- (NSArray *)fetchDistinctObjectNames {

    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName]
                                                                   andFieldNames:@[@"objectName"]];
    [requestSelect setDistinctRowsOnly];
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                DataPurgeModel * model = [[DataPurgeModel alloc] init];
                [resultSet kvcMagic:model];
                [records addObject:model];
            }
            [resultSet close];
        }];
    }
    return records;
}

- (NSMutableArray *)fetchSfIdsForObjectName:(NSString *)objectName {
    
    DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:@"objectName"
                                                   operatorType:SQLOperatorEqual
                                                  andFieldValue:objectName];
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName]
                                                                   andFieldNames:@[@"sfId"]
                                                                   whereCriteria:criteria];
    [requestSelect setDistinctRowsOnly];
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                DataPurgeModel * model = [[DataPurgeModel alloc] init];
                [resultSet kvcMagic:model];
                [records addObject:model];
            }
            [resultSet close];
        }];
    }
    return records;
}
@end
