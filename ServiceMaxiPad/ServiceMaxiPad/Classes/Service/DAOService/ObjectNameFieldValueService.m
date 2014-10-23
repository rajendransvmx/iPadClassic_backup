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


@implementation ObjectNameFieldValueService

- (NSArray * )fetchObjectNameFieldValueByFields:(NSArray *)fieldNames andCriteria:(DBCriteria *)criteria
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kObjectNameFieldValue andFieldNames:fieldNames whereCriteria:criteria];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            ObjectNameFieldValueModel *model = [[ObjectNameFieldValueModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
    }
    return records;
}

- (NSString *)tableName {
    return @"ObjectNameFieldValue";
}

@end
