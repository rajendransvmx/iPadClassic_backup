//
//  SFPicklistService.m
//  ServiceMaxMobile
//
//  Created by shravya on 23/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFPicklistService.h"
#import "DatabaseManager.h"
#import "DBRequestInsert.h"
#import "SFPicklistModel.h"
#import "ParserUtility.h"
#import "DBRequestSelect.h"
#import "DBRequestUpdate.h"
#import "SQLResultSet.h"
#import "SFObjectMappingComponentModel.h"

@implementation SFPicklistService

- (NSString *)tableName{
    return @"SFPickList";
}
- (NSArray * )fetchSFPicklistByFields:(NSArray *)fieldNames andCriteria:(DBCriteria *)criteria
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kSFPicklist andFieldNames:fieldNames whereCriteria:criteria];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            
            SFPicklistModel * model = [[SFPicklistModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
        [resultSet close];
    }];
    }
    return records;
}

//HS added for Distinct Field needed for Dependent Picklist
- (NSArray * )fetchDistinctSFPicklistByFields:(NSArray *)fieldNames andCriteria:(NSArray *)criteria andExpression:(NSString *)expression

{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kSFPicklist andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:expression];
    [requestSelect setDistinctRowsOnly];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            
            SFPicklistModel * model = [[SFPicklistModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
        [resultSet close];
    }];
    }
    return records;
}
//HS ends here

- (NSArray * )fetchSFPicklistInfoByFields:(NSArray *)fieldNames
                             andCriteria:(NSArray *)criteria
                           andExpression:(NSString *)expression
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kSFPicklist andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:expression];
    
    return [self getListOfPicklistValues:requestSelect];
}

- (NSArray * )fetchSFPicklistInfoByFields:(NSArray *)fieldNames
                              andCriteria:(NSArray *)criteria
                            andExpression:(NSString *)expression
                                  OrderBy:(NSArray *)orberBy
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kSFPicklist andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:expression];
    
    if ([orberBy count] > 0) {
        [requestSelect addOrderByFields:orberBy andDefaultOrderByOrder:SQLOrderByTypesAscending];
    }
    return [self getListOfPicklistValues:requestSelect];
}


- (NSArray *)getListOfPicklistValues:(DBRequestSelect *)select
{
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [select query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            SFPicklistModel * model = [[SFPicklistModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
        [resultSet close];
    }];
    }
    return records;
}

-(void)updateSFPicklistTable:(NSArray *)sfPickListTables
{
    NSArray * fieldsArray = [[NSArray alloc] initWithObjects:@"validFor",@"indexValue", nil];
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldNameToBeBinded:@"objectName"];
    DBCriteria * criteria2 = [[DBCriteria alloc] initWithFieldNameToBeBinded:@"fieldName"];
    DBCriteria * criteria3 = [[DBCriteria alloc] initWithFieldNameToBeBinded:@"value"];
    
    if([sfPickListTables count] >0)
    {
        [self updateRecords:sfPickListTables withFields:fieldsArray withCriteria:[NSArray arrayWithObjects:criteria1,criteria2,criteria3, nil]];
    }
}

- (NSString *)updateQuery
{

     return  @"UPDATE  'SFPicklist' SET  validFor = :validFor , indexValue = :indexValue  WHERE  ((objectName = :objectName AND fieldName = :fieldName  AND value = :value))";
}

- (NSArray *)getListOfLaborActivityType {
    
    DBCriteria * objectNameCriteria = [[DBCriteria alloc] initWithFieldName:@"objectName"
                                                               operatorType:SQLOperatorEqual
                                                              andFieldValue:ORG_NAME_SPACE@"__Service_Order_Line__c"];
    
    DBCriteria * fieldNameCriteria = [[DBCriteria alloc] initWithFieldName:@"fieldName"
                                                              operatorType:SQLOperatorEqual
                                                             andFieldValue:ORG_NAME_SPACE@"__Activity_Type__c"];
    
    NSArray * fieldNames = [[NSArray alloc] initWithObjects:@"value", nil];
    
    NSArray * criteriaObjects = [[NSArray alloc] initWithObjects:fieldNameCriteria,
                                 objectNameCriteria,
                                 nil];
    
    NSArray * resultSet = [self fetchSFPicklistInfoByFields:fieldNames
                                                andCriteria:criteriaObjects
                                              andExpression:@"(1 AND 2)"];
    
    return resultSet;

}

-(NSString *) getDisplayValueFromPicklistForObjectName:(NSString *)objectName withMappingCompenent:(SFObjectMappingComponentModel *)mappingCompenent
{
 
    NSString *displayValue = nil;

    DBCriteria * criteriaObjectName1 = [[DBCriteria alloc] initWithFieldName:kfieldname operatorType:SQLOperatorEqual andFieldValue:mappingCompenent.targetFieldName];
    
    DBCriteria * criteriaObjectName2 = [[DBCriteria alloc] initWithFieldName:kvalue operatorType:SQLOperatorEqual andFieldValue:mappingCompenent.mappingValue];
    
     DBCriteria * criteriaObjectName3 = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:objectName];
    
    
    NSArray * criteriaObjects = [[NSArray alloc] initWithObjects:criteriaObjectName1, criteriaObjectName2,criteriaObjectName3,
                                  nil];
    NSArray * fieldNames = [[NSArray alloc] initWithObjects:@"label", nil];
    
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kSFPicklist andFieldNames:fieldNames whereCriterias:criteriaObjects andAdvanceExpression:@"(1 AND 2 AND 3)"];
    
    __block NSString *labelValue = nil;
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                labelValue = [resultSet stringForColumn:@"label"];
                
            }
            [resultSet close];
        }];
    }
    
    displayValue = labelValue;
    
    return displayValue;
}



@end
