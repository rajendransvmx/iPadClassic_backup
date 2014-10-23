//
//  SFProcessComponentService.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 19/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFProcessComponentService.h"
#import "DatabaseManager.h"
#import "DBRequestInsert.h"
#import "SFProcessComponentModel.h"
#import "DBRequestSelect.h"
#import "ParserUtility.h"

#import "SQLResultSet.h"
@implementation SFProcessComponentService

- (NSArray *)fetchSFProcessComponentsByCriteria:(DBCriteria *)criteria
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kProcessComponentTableName andFieldNames:nil whereCriteria:criteria];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            SFProcessComponentModel * model = [[SFProcessComponentModel alloc] init];
            NSDictionary *dict = [resultSet resultDictionary];
            [ParserUtility parseJSON:dict toModelObject:model withMappingDict:nil];
            [records addObject:model];
        }
    }
    return records;
}

- (NSString *)tableName {
    return kProcessComponentTableName;
}

- (NSArray * )fetchSFProcessComponentsByFields:(NSArray *)fieldNames
                                   andCriteria:(NSArray *)criteria
                                 andExpression:(NSString *)expression
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kProcessComponentTableName andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:expression];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            SFProcessComponentModel * model = [[SFProcessComponentModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
    }
    return records;
}


- (NSArray *)getAllObjectApiNames {
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:[NSArray arrayWithObjects:@"objectName", nil]];
    [requestSelect setDistinctRowsOnly];
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            SFProcessComponentModel * model = [[SFProcessComponentModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
    }
    return records;
}

@end
