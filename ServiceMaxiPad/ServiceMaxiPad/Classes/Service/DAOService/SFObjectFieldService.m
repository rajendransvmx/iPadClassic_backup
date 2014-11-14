//
//  SFObjectFieldService.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 21/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFObjectFieldService.h"
#import "DatabaseManager.h"
#import "DBRequestInsert.h"
#import "ParserUtility.h"
#import "DBRequestSelect.h"
#import "SQLResultSet.h"
#import "DatabaseManager.h"
#import "StringUtil.h"

@implementation SFObjectFieldService

- (NSArray * )fetchSFObjectFieldsInfoByFields:(NSArray *)fieldNames andCriteria:(DBCriteria *)criteria
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kSFObjectField andFieldNames:fieldNames whereCriteria:criteria];
    
    [requestSelect setDistinctRowsOnly];
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [requestSelect query];//
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            SFObjectFieldModel * model = [[SFObjectFieldModel alloc] init];
            NSDictionary *dict = [resultSet resultDictionary];
            [ParserUtility parseJSON:dict toModelObject:model withMappingDict:nil];
            [records addObject:model];
        }
        [resultSet close];
    }];
    }
    return records;
}

- (NSMutableArray *)executeQuery:(DBRequestSelect *)requestSelect
{
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [requestSelect query];//
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            SFObjectFieldModel * model = [[SFObjectFieldModel alloc] init];
            NSDictionary *dict = [resultSet resultDictionary];
            [ParserUtility parseJSON:dict toModelObject:model withMappingDict:nil];
            [records addObject:model];
        }
        [resultSet close];
    }];
    }
    return records;
}

- (NSArray * )fetchSFObjectFieldsInfoByFields:(NSArray *)fieldNames andCriteriaArray:(NSArray *)criteriaArray advanceExpression:(NSString *)advExp
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc]  initWithTableName:[self tableName] andFieldNames:fieldNames whereCriterias:criteriaArray andAdvanceExpression:advExp];
    NSMutableArray *records;
    records = [self executeQuery:requestSelect];
    return records;
}



- (SFObjectFieldModel *)getSFObjectFieldInfo:(id)criteria advanceExpression:(NSString *)advExp
{
    DBRequestSelect * requestSelect = nil;
    
    if ([criteria isKindOfClass:[NSArray class]]) {
        requestSelect = [[DBRequestSelect alloc] initWithTableName:kSFObjectField andFieldNames:nil whereCriterias:criteria andAdvanceExpression:advExp];
    }
    else{
        requestSelect = [[DBRequestSelect alloc] initWithTableName:kSFObjectField andFieldNames:nil whereCriteria:criteria];

    }
    __block SFObjectFieldModel * model;
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        model = [[SFObjectFieldModel alloc] init];
        if ([resultSet next]) {
            NSDictionary *dict = [resultSet resultDictionary];
            [ParserUtility parseJSON:dict toModelObject:model withMappingDict:nil];
        }
        [resultSet close];
    }];
    }
    return model;
}

- (SFObjectFieldModel *)getSFObjectFieldInfo:(NSArray *)fields criteria:(NSArray *)criteria
                           advanceExpression:(NSString *)advExp
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kSFObjectField andFieldNames:fields
                                                                  whereCriterias:criteria
                                                            andAdvanceExpression:advExp];
    __block SFObjectFieldModel * model;
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        model = [[SFObjectFieldModel alloc] init];
        if ([resultSet next]) {
            NSDictionary *dict = [resultSet resultDictionary];
            [ParserUtility parseJSON:dict toModelObject:model withMappingDict:nil];
        }
        [resultSet close];
    }];
    }
    return model;
}

- (NSString *)tableName{
    return kSFObjectField;
}

-(void)updateSFObjectField:(NSArray *)sfObjectFields
{
    NSArray * fieldsArray = [[NSArray alloc] initWithObjects:@"controlerField", nil];
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldNameToBeBinded:@"objectName"];
     DBCriteria * criteria2 = [[DBCriteria alloc] initWithFieldNameToBeBinded:@"fieldName"];
    
    if([sfObjectFields count] >0)
    {
        [self updateRecords:sfObjectFields withFields:fieldsArray withCriteria:[NSArray arrayWithObjects:criteria1,criteria2, nil]];
    }
}

- (NSString *)updateQuery
{
    
    return  @"UPDATE  'SFObjectField' SET  controlerField = :controlerField  WHERE  ((objectName = :objectName AND fieldName = :fieldName))";
}

- (NSArray * )fetchDistinctSFObjectFieldsInfoByFields:(NSArray *)fieldNames andCriteria:(DBCriteria *)criteria
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kSFObjectField andFieldNames:fieldNames whereCriteria:criteria];
    [requestSelect setDistinctRowsOnly];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            SFObjectFieldModel * model = [[SFObjectFieldModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
        [resultSet close];
    }];
    }
    return records;
}

- (NSMutableArray*)getDependantPickListObjectNames
{
    NSMutableArray *listOfObjectName = [[NSMutableArray alloc]init];
    DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:@"dependentPicklist"
                                                   operatorType:SQLOperatorEqual
                                                  andFieldValue:@"true"];
    
    NSArray *listOfSFObjectFieldModel = [self fetchDistinctSFObjectFieldsInfoByFields:[NSArray arrayWithObject:@"objectName"]
                                                                          andCriteria:criteria];
    
    for (int i = 0; i < [listOfSFObjectFieldModel count]; i++)
    {
        if([listOfSFObjectFieldModel objectAtIndex:i] != nil)
        {
            SFObjectFieldModel *sfObjectModel = [listOfSFObjectFieldModel objectAtIndex:i];
            
            if (![StringUtil isStringEmpty:sfObjectModel.objectName])
            {
                [listOfObjectName addObject:sfObjectModel.objectName];
            }
        }
    }
    return listOfObjectName;
}

-(NSArray *)getSFObjectFieldsForObject:(NSString *)objectName
{
    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:@"objectName" operatorType:SQLOperatorEqual andFieldValue:objectName];
    NSArray * fieldsArray = [self fetchSFObjectFieldsInfoByFields:[NSArray arrayWithObjects:@"objectName",@"fieldName",@"type",@"referenceTo", nil] andCriteria:criteria];
    
    return fieldsArray;
}

-(NSArray *)getSFObjectFieldsForObjectWithLocalId:(NSString *)objectName
{
    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:@"objectName" operatorType:SQLOperatorEqual andFieldValue:objectName];
    NSMutableArray * fieldsArray = (NSMutableArray *)[self fetchSFObjectFieldsInfoByFields:[NSArray arrayWithObjects:@"objectName",@"fieldName",@"type", nil] andCriteria:criteria];
    
    SFObjectFieldModel *aModel = [[SFObjectFieldModel alloc] init];
    aModel.fieldName = kLocalId;
    aModel.objectName = objectName;
    aModel.type = @"text";
    [fieldsArray insertObject:aModel atIndex:0];
    return fieldsArray;
}


-(NSDictionary *)getFieldsInformationFor:(NSArray *)fields objectName:(NSString *)obejctName
{
    NSMutableDictionary * fieldLabelDict = [[NSMutableDictionary alloc] initWithCapacity:0];

    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:obejctName];
    
    DBCriteria * criteria2 = [[DBCriteria alloc] initWithFieldName:kfieldname operatorType:SQLOperatorIn andFieldValues:fields];

    NSArray * resultSet =   [self fetchSFObjectFieldsInfoByFields:nil andCriteriaArray:[NSArray arrayWithObjects:criteria1,criteria2, nil] advanceExpression:@"( 1 AND 2 )"];
    
    if ([resultSet count] > 0) {
        for (SFObjectFieldModel * model in resultSet) {
            if (model != nil) {
                [fieldLabelDict setObject:model forKey:model.fieldName];
            }
        }
    }
    return fieldLabelDict;

}


- (NSString *)getFieldNameForRelationShipName:(NSString *)relationship withRelatedObjectName:(NSString *)relatedObjectName andObjectName:(NSString *)objectName
{
    NSArray *criteriaArray = nil;
    NSString *advExpr = nil;
    
    if (relatedObjectName.length > 2)
    {
        DBCriteria *objNameCriteria = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:objectName];
        DBCriteria *relationCriteria = [[DBCriteria alloc] initWithFieldName:@"relationName" operatorType:SQLOperatorEqual andFieldValue:relationship];
        DBCriteria *referenceCriteria = [[DBCriteria alloc] initWithFieldName:kSFObjectFieldReferenceTo operatorType:SQLOperatorEqual andFieldValue:relatedObjectName];
        criteriaArray = [[NSArray alloc] initWithObjects:objNameCriteria, relationCriteria, referenceCriteria, nil];
        advExpr = @"1 and 2 and 3";
    }
    else
    {
        DBCriteria *objNameCriteria = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:objectName];
        DBCriteria *relationCriteria = [[DBCriteria alloc] initWithFieldName:@"relationName" operatorType:SQLOperatorEqual andFieldValue:relationship];
        criteriaArray = [[NSArray alloc] initWithObjects:objNameCriteria, relationCriteria, nil];
        advExpr = @"1 and 2 and 3";
    }
    
    __block NSString *resultFieldName = @"";
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kSFObjectField andFieldNames:@[kfieldname]
                                                                  whereCriterias:criteriaArray
                                                            andAdvanceExpression:advExpr];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        SFObjectFieldModel * model = [[SFObjectFieldModel alloc] init];
        if ([resultSet next]) {
            NSDictionary *dict = [resultSet resultDictionary];
            [ParserUtility parseJSON:dict toModelObject:model withMappingDict:nil];
        }
        resultFieldName = model.fieldName;
        [resultSet close];
    }];
    }
    return  resultFieldName;

}

-(NSArray *)getAllSFObjectFieldsForObject:(NSString *)objectName
{
    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:@"objectName" operatorType:SQLOperatorEqual andFieldValue:objectName];
    NSArray * fieldsArray = [self fetchSFObjectFieldsInfoByFields:[NSArray arrayWithObjects:@"fieldName",@"type", nil] andCriteria:criteria];
    
    return fieldsArray;
}


- (BOOL)isObjectExists:(NSArray *)criteria
{
    __block BOOL isObjectExists = NO;
    
    DBRequestSelect *select = [[DBRequestSelect alloc] initWithTableName:kSFObjectField aggregateFunction:SQLAggregateFunctionCount whereCriterias:criteria andAdvanceExpression:nil];
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            NSString * query = [select query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            if([resultSet next])
            {
                NSDictionary * dict = [resultSet resultDictionary];
                if ([dict count]>0) {
                    isObjectExists = [[dict valueForKey:@"COUNT(*)"] boolValue];
                }
            }
            [resultSet close];
        }];
    }
    return isObjectExists;
    
}

@end
