//
//  RecentDaoService.m
//  ServiceMaxiPad
//
//  Created by Shubha S on 30/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "RecentDaoService.h"
#import "RecentModel.h"
#import "DBRequestInsert.h"
#import "DBRequestDelete.h"
#import "DateUtil.h"

@implementation RecentDaoService


- (NSString *)tableName
{
    return @"RecentRecord";
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
    [requestDelete addLimit:1 andOffSet:0];
    [requestDelete addOrderByFields:@[@"createdDate"] andDefaultOrderByOrder:SQLOrderByTypesDescending];
    status = [self executeStatement:[requestDelete query]];
    return status;
}

- (void)deleteRecentObject
{
    [self deleteRecordsFromObject:[self tableName] whereCriteria:nil andAdvanceExpression:nil];
}

- (void)saveRecentRecord:(RecentModel*)model
{
    model.createdDate = [DateUtil getDatabaseStringForDate:[NSDate date]];
    [self saveRecordModel:model];
}

- (NSArray * )fetchRecentRecordInfoByFields:(NSArray *)fieldNames
                          andCriteria:(NSArray *)criteria
                        andExpression:(NSString *)expression
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:expression];
    DBField *dbField = [[DBField alloc]initWithFieldName:@"createdDate" tableName:[self tableName] andOrderType:SQLOrderByTypesDescending];
    
    [requestSelect addOrderByFields:@[dbField] andDefaultOrderByOrder:SQLOrderByTypesDescending];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            RecentModel * model = [[RecentModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
        [resultSet close];
    }];
    }
    return records;
}

- (NSArray *)getRecentRecordInfo
{
    NSArray *fieldNames = @[@"objectName",@"localId",@"createdDate"];
    return [self fetchRecentRecordInfoByFields:fieldNames andCriteria:nil andExpression:nil];
}

- (NSArray *)fieldNamesToBeRemovedFromQuery {
    
    return @[@"nameFieldValue"];
}

- (BOOL)removeLocalIdField {
    
    return NO;
}

@end
