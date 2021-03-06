//
//  SFRTPicklistService.m
//  ServiceMaxMobile
//
//  Created by Pushpak on 25/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFRTPicklistService.h"
#import "DatabaseConstant.h"
#import "SFRTPicklistModel.h"

@implementation SFRTPicklistService

- (NSString *)tableName {
    return kSFRTPicklistTableName;
}

- (NSArray * )fetchSFRTPicklistByFields:(NSArray *)fieldNames andCriteria:(NSArray *)criteria
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kSFRTPicklistTableName andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:nil];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            
            SFRTPicklistModel * model = [[SFRTPicklistModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
        [resultSet close];
    }];
    }
    return records;
}

- (NSArray *)fetchSFRTPicklistByDistinctFields:(NSArray *)fieldNames andCriteria:(NSArray *)criteria
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kSFRTPicklistTableName andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:nil];
    [requestSelect setDistinctRowsOnly];
                                       
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            
            SFRTPicklistModel * model = [[SFRTPicklistModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
        [resultSet close];
    }];
    }
    return records;
}
@end
