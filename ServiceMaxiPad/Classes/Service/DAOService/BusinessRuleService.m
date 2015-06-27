//
//  BusinessRuleService.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 21/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "BusinessRuleService.h"
#import "BusinessRuleModel.h"

@implementation BusinessRuleService

- (NSString *)tableName
{
    return @"BusinessRule";
}

- (NSArray *)fetchBusinessRuleInfoByFields:(NSArray *)fieldNames andCriteriaArray:(NSArray *)criteriaArray {
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kBusinessruleTable andFieldNames:fieldNames whereCriterias:criteriaArray andAdvanceExpression:nil];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                BusinessRuleModel * model = [[BusinessRuleModel alloc] init];
                [resultSet kvcMagic:model];
                [records addObject:model];
            }
            [resultSet close];
        }];
    }
    return records;
}


-(NSArray *)fetchFieldUpdateRuleInfoByFields:(NSArray *)fieldNames andCriteriaArray:(NSArray *)criteriaArray {
    DBRequestSelect *requestSelect = [[DBRequestSelect alloc] initWithTableName:kBusinessruleTable andFieldNames:fieldNames whereCriterias:criteriaArray andAdvanceExpression:nil];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                BusinessRuleModel * model = [[BusinessRuleModel alloc] init];
                [resultSet kvcMagic:model];
                [records addObject:model];
            }
            [resultSet close];
        }];
    }
    return records;
}

- (NSArray *)fieldNamesToBeRemovedFromQuery {
    return @[@"expressionComponentsArray"];
}


@end
