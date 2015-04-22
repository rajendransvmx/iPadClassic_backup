//
//  ChatterPostDetailService.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 24/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ChatterPostDetailService.h"
#import "ChatterPostDetailModel.h"
#import "DBRequestSelect.h"
#import "DBRequestDelete.h"

@implementation ChatterPostDetailService

- (BOOL)saveRecordModels:(NSMutableArray *)recordsArray {
    BOOL status = [super saveRecordModels:recordsArray];
    return status;
}

- (BOOL)deleteRecords:(DBCriteria *)criteria
{
    DBRequestDelete *deleteQuery = [[DBRequestDelete alloc] initWithTableName:[self tableName] whereCriteria:@[criteria] andAdvanceExpression:nil];
    
   return [self executeStatement:[deleteQuery query]];
}

- (NSMutableArray *)fetchRecordsForProductId:(NSArray *)criteria
                                     orderBy:(DBField *)dbField;
{
    DBRequestSelect *selectQuery = [[DBRequestSelect alloc] initWithTableName:[self tableName]
                                                                andFieldNames:nil
                                                               whereCriterias:criteria andAdvanceExpression:@"(1 AND 2 AND 3)"];
    [selectQuery addOrderByFields:@[dbField]];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            NSString * query = [selectQuery query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                ChatterPostDetailModel * model = [[ChatterPostDetailModel alloc] init];
                [resultSet kvcMagic:model];
                [records addObject:model];
            }
            [resultSet close];
        }];
    }
    return records;
}

- (NSString *)tableName
{
    return @"ChatterPostDetail";
}

@end
