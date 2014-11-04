//
//  UserGPSLogService.m
//  ServiceMaxiPad
//
//  Created by Pushpak on 17/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "UserGPSLogService.h"
#import "DBRequestDelete.h"

@implementation UserGPSLogService



- (BOOL)deleteGPSLogsIfRecordCountCrossedLimit:(NSInteger)limit {
    
    BOOL status = NO;
    NSInteger recordCount = [self getNumberOfRecordsFromObject:kJobLogsTableName
                                                withDbCriteria:nil
                                         andAdvancedExpression:nil];
    if (recordCount >= limit) {
        
        DBRequestSelect *innerSelect = [[DBRequestSelect alloc]initWithTableName:kUserGPSLogTableName
                                                                   andFieldNames:@[@"rowid"]
                                                                  whereCriterias:nil
                                                            andAdvanceExpression:nil];
    
        DBField *orderByfield = [[DBField alloc] initWithFieldName:@"rowid"
                                                         tableName:kUserGPSLogTableName
                                                      andOrderType:SQLOrderByTypesDescending];
    
        [innerSelect addOrderByFields:@[orderByfield]];
        [innerSelect setLimit:-1];
        [innerSelect setOffSet:limit-1];//-1 so that we have space for next insertion that follows. 
        
        DBCriteria *delCriteria = [[DBCriteria alloc]initWithFieldName:@"rowid"
                                                          operatorType:SQLOperatorIn
                                                  andInnerQUeryRequest:innerSelect];
        
        DBRequestDelete *delRequest = [[DBRequestDelete alloc]initWithTableName:kUserGPSLogTableName
                                                                  whereCriteria:@[delCriteria]
                                                           andAdvanceExpression:nil];
        NSString *delQuery = [delRequest query];
        status = [self executeStatement:delQuery];
    }
    return status;
}

- (UserGPSLogModel *)getLastGPSLog {
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kUserGPSLogTableName andFieldNames:nil whereCriteria:nil];
    DBField *orderByfield = [[DBField alloc] initWithFieldName:@"rowid"
                                                     tableName:kUserGPSLogTableName
                                                  andOrderType:SQLOrderByTypesDescending];
    [requestSelect addOrderByFields:@[orderByfield]];
    [requestSelect setLimit:1];

    
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    __block UserGPSLogModel * model;
    @autoreleasepool {
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        model = [[UserGPSLogModel alloc]init];
        if ([resultSet next]) {
            [resultSet kvcMagic:model];
        }
        [resultSet close];

    }];
    }
    return model;
}

- (NSString *)tableName {
    return kUserGPSLogTableName;
}

- (BOOL)removeLocalIdField {
    return NO;
}

- (NSArray *)fetchAllUserGPSLogs
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kUserGPSLogTableName andFieldNames:nil whereCriteria:nil];;
    [requestSelect addOrderByFields:@[@"rowid"] andDefaultOrderByOrder:SQLOrderByTypesDescending];
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            
            UserGPSLogModel * model = [[UserGPSLogModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
        [resultSet close];
    }];
    }
    return records;

}

- (BOOL)deleteGPSLogsWithLocalIds:(NSArray *)localIdList
{
    BOOL status = NO;
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorIn andFieldValues:localIdList];
    status = [self deleteRecordsFromObject:kUserGPSLogTableName whereCriteria:@[criteria] andAdvanceExpression:nil];
    return status;
}
@end
