//
//  SFMWizardComponentService.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 20/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMWizardComponentService.h"
#import "WizardComponentModel.h"
#import "SFExpressionParser.h"
#import "WizardComponentModel.h"
#import "SFWizardModel.h"

@implementation SFMWizardComponentService

- (NSString *)tableName
{
    return @"SFWizardComponent";
}

- (NSArray *)fieldNamesToBeRemovedFromQuery
{
    return @[@"isEntryCriteriaMatching"];
}

- (NSArray * )fetchWizardComponentInfoByFields:(NSArray *)fieldNames
                                   andCriteria:(NSArray *)criteria
                                 andExpression:(NSString *)expression
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:expression];
    
    DBField *sortField = [[DBField alloc] initWithFieldName:@"sequence" tableName:[self tableName] andOrderType:SQLOrderByTypesAscending];
   
    [requestSelect setDistinctRowsOnly];
    [requestSelect addOrderByFields:@[sortField]];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {

        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            WizardComponentModel * model = [[WizardComponentModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
        [resultSet close];
    }];
    }
    return records;
}

- (void)getWizardComponentsForWizards:(NSMutableArray *)wizardArray recordId:(NSString *)recordId
{
    //NSMutableArray *wizardComponentsArray = [[NSMutableArray alloc]init];
    
    for (SFWizardModel *wizard in wizardArray) {
        
        DBCriteria * criteriaOne = [[DBCriteria alloc] initWithFieldName:@"wizardId"
                                                            operatorType:SQLOperatorEqual
                                                           andFieldValue:wizard.wizardId];
        NSArray * fieldNames = [[NSArray alloc] initWithObjects:@"actionDescription",@"expressionId",@"processId",@"actionType",@"actionName",@"className",@"methodName",@"customActionType",@"actionName",@"customUrl",nil];
        
        NSArray * criteriaObjects = [[NSArray alloc] initWithObjects:criteriaOne, nil];
        
        NSArray * wizardComponentArray = [self fetchWizardComponentInfoByFields:fieldNames andCriteria:criteriaObjects andExpression:nil];
        
        SFExpressionParser *parser = [[SFExpressionParser alloc] initWithExpressionId:nil objectName:nil];
        
        NSMutableArray *wizardComponentsWithEntryCriteria = [[NSMutableArray alloc]init];
        
        for (WizardComponentModel *wizardComponet in wizardComponentArray) {
            /*Check whether the wizard component matches the enrty criteria*/
            if ([wizardComponet.expressionId length] > 0)
            {
                parser.objectName = wizard.objectName;
                parser.expressionId = wizardComponet.expressionId;
                wizardComponet.isEntryCriteriaMatching = [parser isEntryCriteriaMatchingForRecordId:recordId];
            }
            else
            {
                wizardComponet.isEntryCriteriaMatching = TRUE;
            }
            
            [wizardComponentsWithEntryCriteria addObject:wizardComponet];
        }
        
        wizard.wizardComponents = wizardComponentsWithEntryCriteria;
    
        //[wizardComponentsArray addObject:wizardComponentsWithEntryCriteria];
    }
   /// return wizardComponentsArray;
}


-(void)updateWizardComponentWithModelArray:(NSArray*)modelArray
{
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldNameToBeBinded:@"wizardComponentId"];
    
    if([modelArray count] >0)
    {
        [self updateRecords:modelArray withFields:@[@"className",@"methodName"] withCriteria:@[criteria1]];
    }
}

-(void)updateWizardComponentWithModelArray_withCustomActionFields:(NSArray*)modelArray
{
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldNameToBeBinded:@"processId"];
    
    if([modelArray count] >0)
    {
        [self updateRecords:modelArray withFields:@[@"className",@"methodName",@"customActionType",@"actionDescription",@"customUrl"] withCriteria:@[criteria1]];
    }
}

#pragma mark - ProductIQ methods
- (NSArray*)getSFMProcessIdsWithSFMProcessArray:(NSMutableArray *)sfmProcessArray {
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString *query = [NSString stringWithFormat:@"SELECT pc.processId as processId FROM SFProcessComponent as pc JOIN InstallBaseObject as ib ON ib.objectName = pc.objectName JOIN SFSourceUpdate as su ON pc.processId = su.process WHERE pc.processId IN %@ UNION SELECT pc.processId FROM SFProcessComponent as pc JOIN InstallBaseObject as ib ON ib.objectName = pc.objectName JOIN SFProcess as p ON pc.processId = p.sfId WHERE pc.componentType IN ('TARGET', 'TARGETCHILD') AND p.processType != 'VIEW RECORD' AND pc.processId IN %@",sfmProcessArray,sfmProcessArray];
    
    query = [query stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                NSDictionary * dict = [resultSet resultDictionary];
                [records addObject:[dict objectForKey:@"processId"]];
                
            }
            [resultSet close];
        }];
    }
    
    return records;
}

- (NSArray*)getOutputDocumentrocessIdsWithOutputDocumentArray:(NSMutableArray *)outputdocumentArray {
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString *query = [NSString stringWithFormat:@"SELECT pc.processId as processId FROM SFProcessComponent as pc JOIN InstallBaseObject as ib ON ib.objectName = pc.objectName JOIN SFSourceUpdate as su ON pc.sfId = su.process WHERE pc.processId IN %@ ",outputdocumentArray];
    
    query = [query stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                NSDictionary * dict = [resultSet resultDictionary];
                [records addObject:[dict objectForKey:@"processId"]];
                
            }
            [resultSet close];
        }];
    }
    return records;
}


@end
