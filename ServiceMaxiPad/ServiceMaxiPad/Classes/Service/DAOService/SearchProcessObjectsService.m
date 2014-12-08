//
//  SearchProcessObjectsService.m
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 21/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SearchProcessObjectsService.h"
#import "DBRequestSelect.h"
#import "DatabaseManager.h"
#import "SFMSearchProcessModel.h"
#import "SFMSearchObjectModel.h"
#import "SQLResultSet.h"

@implementation SearchProcessObjectsService

- (NSString *)tableName {
    return @"SFM_Search_Objects";
}
- (NSArray *)fieldNamesToBeRemovedFromQuery {
    
    NSArray *array = [[NSArray alloc] initWithObjects:@"searchFields",@"displayFields",@"sortFields", nil];
    return array;
}

- (NSArray *)getAllObjectApiNames
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:[NSArray arrayWithObjects:@"targetObjectName", nil]];
    [requestSelect setDistinctRowsOnly];
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            SFMSearchObjectModel * model = [[SFMSearchObjectModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
        [resultSet close];
    }];
    }
    return records;
}

- (NSArray *)getAllObjectApiNamesFor:(SFMSearchProcessModel*)processModel
{
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:@"moduleId" operatorType:SQLOperatorEqual andFieldValue:processModel.identifier];
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:[NSArray arrayWithObjects:@"objectId",@"name",@"advancedExpression",@"moduleId",@"targetObjectName", nil] whereCriteria:criteria];
    [requestSelect setDistinctRowsOnly];
    [requestSelect addOrderByFields:@[@"sequence"]];
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            SFMSearchObjectModel * model = [[SFMSearchObjectModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
        [resultSet close];
    }];
    }
    return records;
}

@end
