//
//  SFChildRelationshipService.m
//  ServiceMaxMobile
//
//  Created by shravya on 23/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFChildRelationshipService.h"
#import "SFChildRelationshipModel.h"
#import "ParserUtility.h"

@implementation SFChildRelationshipService
- (NSString *)tableName{
    return @"SFChildRelationship";
}


- (NSArray * )fetchSFObjectFieldsInfoByFields:(NSArray *)fieldNames andCriteria:(DBCriteria *)criteria
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kSFObjectField andFieldNames:fieldNames whereCriteria:criteria];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            SFChildRelationshipModel * model = [[SFChildRelationshipModel alloc] init];
            NSDictionary *dict = [resultSet resultDictionary];
            [ParserUtility parseJSON:dict toModelObject:model withMappingDict:nil];
            [records addObject:model];
        }
    }
    return records;
}


-(NSArray *) fetchSFChildRelationshipInfoByFields:(NSArray *)fieldNames andCriterias:(NSArray *)criteria andAdvanceExpresion:(NSString *) expression
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kChildRelationshipTableName andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:expression];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            SFChildRelationshipModel * model = [[SFChildRelationshipModel alloc] init];
            NSDictionary *dict = [resultSet resultDictionary];
            [ParserUtility parseJSON:dict toModelObject:model withMappingDict:nil];
            [records addObject:model];
        }
    }
    return records;

}
@end
