//
//  ProcessBusinessRuleService.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 21/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "ProcessBusinessRuleService.h"
#import "DatabaseConstant.h"
#import "ProcessBusinessRuleModel.h"

@implementation ProcessBusinessRuleService

- (NSString *)tableName
{
    return @"ProcessBusinessRule";
}

- (NSArray * )fetchProcessBusinessRuleInfoByFields:(NSArray *)fieldNames
                                       andCriteria:(NSArray *)criteria
                                     andExpression:(NSString *)expression
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kProcessBusinessRuleTable andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:expression];
    
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                ProcessBusinessRuleModel * model = [[ProcessBusinessRuleModel alloc] init];
                [resultSet kvcMagic:model];
                [records addObject:model];
            }
            [resultSet close];
        }];
    }
    return records;

}

- (NSArray * )fetchProcessBusinessRuleInfoByFields:(NSArray *)fieldNames
                                        andCriteria:(DBCriteria *)criteria
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc]initWithTableName:kProcessBusinessRuleTable andFieldNames:nil whereCriteria:criteria];
    
    [requestSelect addOrderByFields:[[NSArray alloc]initWithObjects:kBizRuleProcessSequence, nil]];

    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                ProcessBusinessRuleModel * model = [[ProcessBusinessRuleModel alloc] init];
                [resultSet kvcMagic:model];
                [records addObject:model];
            }
            [resultSet close];
        }];
    }
    return records;

    
}

- (NSArray *)fieldNamesToBeRemovedFromQuery {
    return @[@"businessRuleModel"];
}


@end
