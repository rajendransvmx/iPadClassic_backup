//
//  SFObjectService.m
//  ServiceMaxMobile
//
//  Created by shravya on 23/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFObjectService.h"
#import "DBCriteria.h"
#import "DBRequestSelect.h"
#import "DatabaseManager.h"
#import "SQLResultSet.h"

@implementation SFObjectService

- (NSString *)tableName {
    return kSFObject;
}
-(NSArray *)getDistinctObjects
{
    NSArray *fieldNames = @[kobjectName,klabel];
    NSArray * objects = [self fetchRecordsByFields:fieldNames andCriteria:nil];
    return objects;
}

- (NSArray * )fetchRecordsByFields:(NSArray *)fieldNames andCriteria:(DBCriteria *)criteria
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:fieldNames whereCriteria:criteria];
    
    [requestSelect setDistinctRowsOnly];
    [requestSelect addOrderByFields:@[klabel]];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            
            SFObjectModel * model = [[SFObjectModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
    }
    return records;
}

- (SFObjectModel *)getSFObjectInfo:(DBCriteria *)criteria fieldName:(NSArray *)fielNames
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kSFObject andFieldNames:fielNames whereCriteria:criteria];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        SFObjectModel * model = [[SFObjectModel alloc] init];
        
        if ([resultSet next]) {
            [resultSet kvcMagic:model];
        }
        return model;
    }
    return nil;
}

- (NSString*)getLabelForObjectApiName:(NSString*)objectName
{
    NSArray *fieldNames = @[@"label"];
    DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:@"objectName" operatorType:SQLOperatorEqual andFieldValue:objectName];
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:fieldNames whereCriteria:criteria];
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    NSString *label = nil;
    if (didOpen)
    {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            
            SFObjectModel * model = [[SFObjectModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
            
            label = model.label;
        }
    }
    return label;
}

@end
