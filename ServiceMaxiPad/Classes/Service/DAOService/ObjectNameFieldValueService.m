//
//  ObjectNameFieldValueService.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 25/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "ObjectNameFieldValueService.h"
#import "DatabaseManager.h"
#import "DBRequestInsert.h"
#import "ParserUtility.h"
#import "DBRequestSelect.h"
#import "DBRequestUpdate.h"
#import "SQLResultSet.h"
#import "TransactionObjectService.h"


@implementation ObjectNameFieldValueService

- (NSArray * )fetchObjectNameFieldValueByFields:(NSArray *)fieldNames andCriteria:(DBCriteria *)criteria
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kObjectNameFieldValue andFieldNames:fieldNames whereCriteria:criteria];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            ObjectNameFieldValueModel *model = [[ObjectNameFieldValueModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
        [resultSet close];
    }];
    }
    return records;
}

- (NSString *)tableName {
    return @"ObjectNameFieldValue";
}

- (BOOL)enableInsertOrReplaceOption {
    return YES;
}
- (BOOL)updateOrInsertTransactionObjects:(NSArray *)transactionObjects {
    
    
    DBRequestInsert *insertRequest = nil;
    DBRequestUpdate *updateRequest = nil;
    
    NSMutableArray *fieldsArray = [[NSMutableArray alloc] initWithCapacity:0];
    [fieldsArray addObject:@"Id"];
    [fieldsArray addObject:@"Value"];
    
    insertRequest = [[DBRequestInsert alloc] initWithTableName:self.tableName andFieldNames:fieldsArray];
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldNameToBeBinded:kId];
    updateRequest = [[DBRequestUpdate alloc] initWithTableName:self.tableName andFieldNames:fieldsArray whereCriteria:@[criteria] andAdvanceExpression:nil];

    TransactionObjectService * transService = [[TransactionObjectService alloc] init];
    
    BOOL isSucces = NO;
    
    /* Check the record count by looking for Id */
    if (insertRequest != nil || updateRequest != nil) {
            isSucces =  [transService updateOrInsertTransactionObjects:transactionObjects withObjectName:self.tableName andDbRequest:insertRequest andUpdateRequest:updateRequest];
            
        }

    
    return isSucces;
}

@end
