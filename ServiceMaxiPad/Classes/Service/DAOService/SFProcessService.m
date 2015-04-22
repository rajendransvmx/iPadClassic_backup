 //
//  SFProcessService.m
//  ServiceMaxMobile
//
//  Created by Sahana on 14/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFProcessService.h"
#import "DatabaseManager.h"
#import "DBRequestInsert.h"
#import "ParserUtility.h"
#import "DBRequestSelect.h"
#import "DBRequestUpdate.h"

#import "SQLResultSet.h"
#import "CalenderHelper.h"
@implementation SFProcessService

- (NSString *)tableName {
    return kProcessTableName;
}
- (NSArray *)fetchSFProcessByFields:(NSArray *)fieldNames
{
    return [self fetchSFProcessInfoByFields:fieldNames andCriteria:nil andExpression:nil];
}

- (NSArray * )fetchSFProcessByFields:(NSArray *)fieldNames andlistOfCriteria:(NSArray*)criteriaArray
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kProcessTableName andFieldNames:fieldNames whereCriterias:criteriaArray andAdvanceExpression:@"1 AND 2"];

    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [requestSelect query];

        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            
            SFProcessModel * model = [[SFProcessModel alloc] init];
            
            [resultSet kvcMagic:model];
            
        /*    Below Commented code is different ways to fill the model */
            
               /* NSDictionary * dict = [resultSet resultDictionary]; */
            /*   1. [ParserUtility parseJSON:dict toModelObject:model
                        withMappingDict:nil]; */

           /*    2. for (NSString * eachFieldName in dict) {
               
                [model setValue:[dict objectForKey:eachFieldName] forKey:eachFieldName];
            }*/
            
            /* Suggesting to use kvcMagic method to fill the model since the execution time taken is very less*/
            [records addObject:model];
        }
    [resultSet close];
    }];
    }
    return records;
}

- (SFProcessModel *)getSFProcessBySalesForceId:(NSString *)sfId
{
    return nil;
}

- (SFProcessModel *)fetchSFProcessBySalesForceId:(NSString *)sfId andFields:(NSArray *)fieldNames
{
    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:ksfId operatorType:SQLOperatorEqual andFieldValue:sfId];
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kProcessTableName andFieldNames:fieldNames whereCriteria:criteria];
    
    __block SFProcessModel *model;
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        model = [[SFProcessModel alloc] init];
        
        if ([resultSet next]) {
            NSDictionary * dict = [resultSet resultDictionary];
            [ParserUtility parseJSON:dict toModelObject:model
             withMappingDict:nil];
        }
        [resultSet close];
    }];
    }
    return model;
}

- (SFProcessModel *)getSFProcessInfo:(DBCriteria *)criteria
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kProcessTableName andFieldNames:nil whereCriteria:criteria];
    
    __block SFProcessModel *model;
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        model = [[SFProcessModel alloc] init];
        
        if ([resultSet next]) {
            NSDictionary *dict = [resultSet resultDictionary];
            [ParserUtility parseJSON:dict toModelObject:model
                     withMappingDict:nil];
        }
        [resultSet close];
    }];
    }
    return model;
}

- (NSArray * )fetchSFProcessInfoByFields:(NSArray *)fieldNames
                             andCriteria:(NSArray *)criteria
                           andExpression:(NSString *)expression
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:kProcessTableName andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:expression];
    
    [requestSelect setDistinctRowsOnly];
    
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            SFProcessModel * model = [[SFProcessModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
        [resultSet close];
    }];
    }
    return records;
}


-(void)updatePageDataForPageLayoutIds:(NSArray *)processArray
{
    //Query : @"UPDATE 'SFProcess'  SET  pageLayoutId = :pageLayoutId, processInfo = :processInfo, objectApiName = :objectApiName WHERE (( pageLayoutId = :pageLayoutId))";
    NSArray * fieldsArray = [[NSArray alloc] initWithObjects:@"pageLayoutId",@"processInfo",@"objectApiName", nil];
    //DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldName:@"pageLayoutId" operatorType:SQLOperatorEqual andFieldValue:[NSString stringWithFormat:@":%@",@"pageLayoutId"]];
     DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldNameToBeBinded:@"pageLayoutId"];
    
    if([processArray count] >0)
    {
        [self updateRecords:processArray withFields:fieldsArray withCriteria:[NSArray arrayWithObject:criteria1]];
    }
    
}



- (NSArray*)fetchPageLayoutIds
{
    NSArray *listOfSFProcessModel = [self fetchSFProcessByFields:[NSArray arrayWithObjects:@"pageLayoutId",nil]];
    NSMutableArray *pageLayoutIds = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < [listOfSFProcessModel count]; i++) {
        
        SFProcessModel *sfProcessModel = [[SFProcessModel alloc]init];
        sfProcessModel = [listOfSFProcessModel objectAtIndex:i];
        if (sfProcessModel.pageLayoutId != nil) {
            [pageLayoutIds addObject:sfProcessModel.pageLayoutId];
            
        }
    }
    
    return pageLayoutIds;
}

- (NSArray*)fetchAllViewProcessForObjectName:(NSString*)objectName
{
    DBCriteria * criteriaOne = [[DBCriteria alloc] initWithFieldName:@"processType"
                                                               operatorType:SQLOperatorEqual
                                                              andFieldValue:@"VIEW RECORD"];
    DBCriteria *criteriaTwo = [[DBCriteria alloc] initWithFieldName:@"objectApiName"
                                                        operatorType:SQLOperatorEqual
                                                       andFieldValue:objectName];
    
    NSArray * fieldNames = [[NSArray alloc] initWithObjects:@"processId",@"objectApiName",@"processName",@"processDescription",@"sfId",nil];
    
    return  [self fetchSFProcessInfoByFields:fieldNames andCriteria:@[criteriaOne,criteriaTwo] andExpression:nil];
    
}

- (NSArray *)getProcessTypeForCriteria:(DBCriteria *)criteria {
    return  [self fetchSFProcessInfoByFields:@[@"processType"] andCriteria:@[criteria] andExpression:nil];

}

-(NSArray *)getS2TEventProcessForObject:(NSString *)objectName  targetObjectNAme:(NSString *)targetObjectName
{
    
    /*
     SELECT * FROM SFProcess where sfId in (select ProcessId  from SFProcessComponent where ( componentType = 'SOURCE' AND  objectName = 'SVMXC__Service_Order__c') )  and processType = 'SOURCE TO TARGET ALL' and objectApiName = 'Event'
     */
    
    DBCriteria *criteria5 = [[DBCriteria alloc] initWithFieldName:@"componentType" operatorType:SQLOperatorEqual andFieldValue:@"SOURCE"];
    
    DBCriteria *criteria6 = [[DBCriteria alloc] initWithFieldName:@"objectName" operatorType:SQLOperatorEqual andFieldValue:objectName];

    
    
    DBRequestSelect * selectstmt = [[DBRequestSelect alloc] initWithTableName:@"SFProcessComponent" andFieldNames:@[@"ProcessId"] whereCriterias:@[criteria5,criteria6] andAdvanceExpression:@"(1 AND 2)"];

    NSString *eventObjectName = targetObjectName;
    
    
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldName:kobjectApiName operatorType:SQLOperatorEqual andFieldValue:eventObjectName];
    DBCriteria * criteria2 = [[DBCriteria alloc] initWithFieldName:ktype operatorType:SQLOperatorEqual andFieldValue:kProcessTypeSRCToTargetAll];
    
    DBCriteria *criteria3 = [[DBCriteria alloc] initWithFieldName:@"sfId" operatorType:SQLOperatorIn andInnerQUeryRequest:selectstmt];
    
    NSMutableArray *processArray = (NSMutableArray *)[self fetchSFProcessInfoByFields:nil andCriteria:@[criteria1,criteria2,criteria3] andExpression:@"(1 AND 2 AND 3)"];
    
    return processArray;
    
}



@end
