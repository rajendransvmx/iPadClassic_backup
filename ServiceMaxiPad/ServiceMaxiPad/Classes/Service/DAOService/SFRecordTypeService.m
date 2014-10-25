//
//  SFRecordTypeService.m
//  ServiceMaxMobile
//
//  Created by Aparna on 20/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFRecordTypeService.h"
#import "DatabaseManager.h"
#import "DBRequestInsert.h"
#import "SFRecordTypeModel.h"
#import "ParserUtility.h"
#import "DBRequestSelect.h"
#import "DBRequestUpdate.h"
#import "SQLResultSet.h"

@implementation SFRecordTypeService

- (SFRecordTypeModel *) getSFRecordTypeBySFId:(NSString *)sfId
{
    return nil;
}

- (NSString *)tableName {
    return @"SFRecordType";
}

- (NSArray * )fetchSFRecordTypeByFields:(NSArray *)fieldNames andCriteria:(DBCriteria *)criteria
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kSFRecordType andFieldNames:fieldNames whereCriteria:criteria];
    [requestSelect setDistinctRowsOnly];
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            SFRecordTypeModel * model = [[SFRecordTypeModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
    }
    return records;
}

- (NSArray * )fetchSFRecordTypeInfoByFields:(NSArray *)fieldNames
                             andCriteria:(NSArray *)criteria
                           andExpression:(NSString *)expression
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kSFRecordType andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:expression];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            SFRecordTypeModel * model = [[SFRecordTypeModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
    }
    return records;
}
- (NSArray*)fetchObjectAPINames
{
    NSArray *recordTypeModelList = [self fetchSFRecordTypeByFields:[NSArray arrayWithObjects:@"objectApiName",nil] andCriteria:nil];
    NSMutableArray *recordTypeList = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < [recordTypeModelList count]; i++) {
        
        SFRecordTypeModel *sfProcessModel = [[SFRecordTypeModel alloc]init];
        sfProcessModel = [recordTypeModelList objectAtIndex:i];
        [recordTypeList addObject:sfProcessModel.objectApiName];
    }
    
    return recordTypeList;
}

-(void)updateRecordTypeLabels:(NSArray *)recordTypeModels
{
    //    Query : @"UPDATE 'SFRecordType'  SET  recordType = :recordType WHERE (( recordTypeId = :recordTypeId))";
    
    NSArray * fieldsArray = [[NSArray alloc] initWithObjects:@"recordType", nil];
  //  DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldName:@"recordTypeId" operatorType:SQLOperatorEqual andFieldValue:[NSString stringWithFormat:@":%@",@"recordTypeId"]];
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldNameToBeBinded:@"recordTypeId"];
    if([recordTypeModels count] >0)
    {
        [self updateRecords:recordTypeModels withFields:fieldsArray withCriteria:[NSArray arrayWithObject:criteria1]];
    }
}

@end
